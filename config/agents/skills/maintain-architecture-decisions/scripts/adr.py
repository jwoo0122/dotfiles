#!/usr/bin/env python3
"""Initialize, index, and validate a semantic living ADR directory."""

from __future__ import annotations

import argparse
import os
import re
import stat
import sys
import tempfile
from datetime import date
from pathlib import Path
from typing import Any

try:
    import yaml
except ImportError:
    print(
        "adr error: PyYAML is required for this interpreter; use the sibling `scripts/adr` launcher to find a compatible one.",
        file=sys.stderr,
    )
    raise SystemExit(2)


STATUSES = {"proposed", "accepted", "superseded", "retired"}
ENFORCEMENT_EXCEPTION_STATUSES = {"manual", "not-applicable", "deferred"}
SYSTEM_MARKER = ".adr-system.yaml"
SYSTEM_NAME = "maintain-architecture-decisions"
SYSTEM_VERSION = 2
RELATION_FIELDS = ("constrains", "depends_on", "supersedes", "superseded_by")
REQUIRED_FIELDS = (
    "id",
    "status",
    "scope",
    "decision_type",
    "applies_to",
    "summary",
    *RELATION_FIELDS,
    "last_reviewed",
    "enforcement",
)
REQUIRED_SECTIONS = (
    "Decision question",
    "Current decision",
    "Context and forces",
    "Invariants",
    "Alternatives and trade-offs",
    "Consequences",
    "Enforcement",
    "Revisit when",
)
TEMPLATE_PLACEHOLDERS = (
    "Concise statement of the current intent.",
    "What durable architectural question does this record answer?",
    "State the current answer with normative MUST or MUST NOT language.",
    "Explain the requirements and constraints that make the decision necessary.",
    "List rules that implementation and review can verify.",
    "Record only alternatives likely to be reconsidered.",
    "Record intended benefits, costs, and operational effects.",
    "Name tests, lint rules, schemas, or review points that enforce the decision.",
    "List observable conditions that justify reopening the decision.",
)
ID_PATTERN = re.compile(r"^[a-z][a-z0-9-]*(?:\.[a-z][a-z0-9-]*)+$")
ENFORCEMENT_ID_PATTERN = re.compile(r"^[a-z][a-z0-9-]*$")
SCOPE_PATTERN = re.compile(r"^[a-z][a-z0-9-]*$")


class AdrError(Exception):
    """A user-correctable ADR structure error."""


class IndentDumper(yaml.SafeDumper):
    """Keep sequence indentation stable and human-readable."""

    def increase_indent(self, flow: bool = False, indentless: bool = False) -> None:
        return super().increase_indent(flow, False)


class UniqueKeyLoader(yaml.SafeLoader):
    """Reject mappings whose later keys would otherwise overwrite earlier keys."""


def construct_unique_mapping(
    loader: UniqueKeyLoader, node: yaml.nodes.MappingNode, deep: bool = False
) -> dict[Any, Any]:
    mapping: dict[Any, Any] = {}
    for key_node, value_node in node.value:
        key = loader.construct_object(key_node, deep=deep)
        if key in mapping:
            raise yaml.constructor.ConstructorError(
                "while constructing a mapping",
                node.start_mark,
                f"duplicate key: {key!r}",
                key_node.start_mark,
            )
        mapping[key] = loader.construct_object(value_node, deep=deep)
    return mapping


UniqueKeyLoader.add_constructor(
    yaml.resolver.BaseResolver.DEFAULT_MAPPING_TAG,
    construct_unique_mapping,
)


def dump_yaml(value: Any) -> str:
    return yaml.dump(
        value,
        Dumper=IndentDumper,
        allow_unicode=True,
        default_flow_style=False,
        sort_keys=False,
    )


def asset_path(name: str) -> Path:
    return Path(__file__).resolve().parents[1] / "assets" / name


def load_yaml_text(text: str, source: Path) -> Any:
    try:
        return yaml.load(text, Loader=UniqueKeyLoader)
    except yaml.YAMLError as error:
        raise AdrError(f"invalid YAML in {source}: {error}") from error


def assert_safe_adr_tree(root: Path) -> Path:
    resolved_root = root.resolve()
    adr_root = resolved_root / "adr"
    if adr_root.is_symlink():
        raise AdrError(f"refusing symlinked ADR directory: {adr_root}")
    if adr_root.exists() and not adr_root.is_dir():
        raise AdrError(f"ADR path is not a directory: {adr_root}")
    if adr_root.exists():
        for path in adr_root.rglob("*"):
            if path.is_symlink():
                raise AdrError(f"refusing symlink inside ADR directory: {path}")
            try:
                path.resolve().relative_to(resolved_root)
            except ValueError as error:
                raise AdrError(f"ADR path escapes repository root: {path}") from error
    return adr_root


def atomic_write(path: Path, content: str) -> None:
    if path.is_symlink():
        raise AdrError(f"refusing symlink write target: {path}")
    if path.exists():
        target_mode = stat.S_IMODE(path.stat().st_mode)
    else:
        current_umask = os.umask(0)
        os.umask(current_umask)
        target_mode = 0o666 & ~current_umask
    temporary: Path | None = None
    try:
        with tempfile.NamedTemporaryFile(
            mode="w",
            encoding="utf-8",
            dir=path.parent,
            prefix=f".{path.name}.",
            suffix=".tmp",
            delete=False,
        ) as handle:
            handle.write(content)
            handle.flush()
            os.fsync(handle.fileno())
            temporary = Path(handle.name)
        os.chmod(temporary, target_mode)
        os.replace(temporary, path)
        temporary = None
    finally:
        if temporary is not None:
            temporary.unlink(missing_ok=True)


def marker_data() -> dict[str, Any]:
    return {"schema": SYSTEM_NAME, "version": SYSTEM_VERSION}


def validate_marker(adr_root: Path) -> None:
    marker = adr_root / SYSTEM_MARKER
    if not marker.is_file():
        raise AdrError(
            f"ADR ownership marker is missing: {marker}; refusing to adopt an existing directory"
        )
    actual = load_yaml(marker)
    compatible = (
        isinstance(actual, dict)
        and actual.get("schema") == SYSTEM_NAME
        and type(actual.get("version")) is int
        and actual.get("version") == SYSTEM_VERSION
    )
    if not compatible:
        raise AdrError(
            f"ADR ownership marker/version conflict in {marker}: expected {marker_data()!r}"
        )


def init_repository(root: Path) -> None:
    root = root.resolve()
    adr_root = assert_safe_adr_tree(root)
    nonempty = adr_root.exists() and any(adr_root.iterdir())
    if nonempty:
        validate_marker(adr_root)
    records = adr_root / "records"
    records.mkdir(parents=True, exist_ok=True)
    templates = {
        adr_root / SYSTEM_MARKER: "system-marker.yaml",
        adr_root / "README.md": "adr-readme.md",
        adr_root / "_template.md": "record-template.md",
        adr_root / "index.yaml": "index-template.yaml",
    }
    created: list[str] = []
    for destination, source_name in templates.items():
        if destination.exists():
            continue
        atomic_write(destination, asset_path(source_name).read_text(encoding="utf-8"))
        created.append(str(destination.relative_to(root.resolve())))
    if created:
        print("initialized: " + ", ".join(created))
    else:
        print("initialized: no changes")


def load_yaml(path: Path) -> Any:
    return load_yaml_text(path.read_text(encoding="utf-8"), path)


def parse_record(path: Path, adr_root: Path) -> dict[str, Any]:
    text = path.read_text(encoding="utf-8")
    if not text.startswith("---\n") or "\n---\n" not in text[4:]:
        raise AdrError(f"missing YAML frontmatter in {path}")
    frontmatter_text, body = text[4:].split("\n---\n", 1)
    data = load_yaml_text(frontmatter_text, path)
    if not isinstance(data, dict):
        raise AdrError(f"frontmatter must be a mapping in {path}")
    if data.get("template") is True:
        raise AdrError(f"template sentinel remains in ADR record: {path}")

    missing = [field for field in REQUIRED_FIELDS if field not in data]
    if missing:
        raise AdrError(f"missing fields in {path}: {', '.join(missing)}")

    decision_id = data["id"]
    if not isinstance(decision_id, str) or not ID_PATTERN.fullmatch(decision_id):
        raise AdrError(f"non-semantic ADR id in {path}: {decision_id!r}")
    if re.match(r"^\d{4}-", path.name):
        raise AdrError(f"chronological ADR filename is not allowed: {path}")

    scope = data["scope"]
    if not isinstance(scope, str) or not SCOPE_PATTERN.fullmatch(scope):
        raise AdrError(f"invalid scope in {path}: {scope!r}")
    if decision_id.split(".", 1)[0] != scope:
        raise AdrError(f"ADR id scope and scope field differ in {path}")

    expected = Path("records") / Path(*decision_id.split(".")).with_suffix(".md")
    actual = path.relative_to(adr_root)
    if actual != expected:
        raise AdrError(f"ADR path must be {expected}, found {actual}")

    status = data["status"]
    if status not in STATUSES:
        raise AdrError(f"invalid status in {path}: {status!r}")
    for field in ("decision_type", "summary"):
        if not isinstance(data[field], str) or not data[field].strip():
            raise AdrError(f"{field} must be a non-empty string in {path}")

    applies_to = data["applies_to"]
    if not isinstance(applies_to, list) or not applies_to or not all(
        isinstance(item, str) and item.strip() for item in applies_to
    ):
        raise AdrError(f"applies_to must be a non-empty string list in {path}")

    for field in RELATION_FIELDS:
        value = data[field]
        if not isinstance(value, list) or not all(isinstance(item, str) for item in value):
            raise AdrError(f"{field} must be a string list in {path}")
        if len(value) != len(set(value)):
            raise AdrError(f"{field} contains duplicates in {path}")
        if decision_id in value:
            raise AdrError(f"{field} cannot reference the record itself in {path}")

    enforcement = data["enforcement"]
    if not isinstance(enforcement, list):
        raise AdrError(f"enforcement must be a list in {path}")
    enforcement_ids: set[str] = set()
    for check in enforcement:
        if not isinstance(check, dict):
            raise AdrError(f"each enforcement check must be a mapping in {path}")
        if set(check) - {"id", "path", "must_contain", "must_not_contain"}:
            unexpected = sorted(set(check) - {"id", "path", "must_contain", "must_not_contain"})
            raise AdrError(f"unknown enforcement fields in {path}: {', '.join(unexpected)}")
        check_id = check.get("id")
        if not isinstance(check_id, str) or not ENFORCEMENT_ID_PATTERN.fullmatch(check_id):
            raise AdrError(f"invalid enforcement check id in {path}: {check_id!r}")
        if check_id in enforcement_ids:
            raise AdrError(f"duplicate enforcement check id in {path}: {check_id}")
        enforcement_ids.add(check_id)
        target = check.get("path")
        if not isinstance(target, str) or not target.strip() or "\x00" in target:
            raise AdrError(f"enforcement path must be a non-empty string in {path}")
        target_path = Path(target)
        if target_path.is_absolute() or ".." in target_path.parts:
            raise AdrError(f"enforcement path must stay inside the repository in {path}: {target!r}")
        for field in ("must_contain", "must_not_contain"):
            assertions = check.get(field, [])
            if not isinstance(assertions, list) or not all(
                isinstance(item, str) and item for item in assertions
            ):
                raise AdrError(f"{field} must be a string list in enforcement check {check_id} of {path}")
            if len(assertions) != len(set(assertions)):
                raise AdrError(f"{field} contains duplicates in enforcement check {check_id} of {path}")
        if not check.get("must_contain") and not check.get("must_not_contain"):
            raise AdrError(f"enforcement check has no assertions in {path}: {check_id}")
        overlap = set(check.get("must_contain", [])) & set(check.get("must_not_contain", []))
        if overlap:
            raise AdrError(f"enforcement check asserts both presence and absence in {path}: {check_id}")

    exception = data.get("enforcement_exception")
    if exception is not None:
        if not isinstance(exception, dict):
            raise AdrError(f"enforcement_exception must be a mapping or null in {path}")
        allowed_exception_fields = {"status", "reason", "evidence", "revisit_when"}
        unexpected = set(exception) - allowed_exception_fields
        if unexpected:
            raise AdrError(
                f"unknown enforcement_exception fields in {path}: {', '.join(sorted(unexpected))}"
            )
        exception_status = exception.get("status")
        if exception_status not in ENFORCEMENT_EXCEPTION_STATUSES:
            raise AdrError(
                f"invalid enforcement_exception status in {path}: {exception_status!r}"
            )
        if not isinstance(exception.get("reason"), str) or not exception["reason"].strip():
            raise AdrError(f"enforcement_exception reason must be non-empty in {path}")
        for field in ("evidence", "revisit_when"):
            values = exception.get(field)
            if not isinstance(values, list) or not all(
                isinstance(item, str) and item.strip() for item in values
            ):
                raise AdrError(
                    f"enforcement_exception {field} must be a non-empty string list in {path}"
                )
    data["enforcement_exception"] = exception

    reviewed = data["last_reviewed"]
    if isinstance(reviewed, date):
        reviewed = reviewed.isoformat()
    if not isinstance(reviewed, str):
        raise AdrError(f"last_reviewed must be an ISO date in {path}")
    try:
        date.fromisoformat(reviewed)
    except ValueError as error:
        raise AdrError(f"last_reviewed must be an ISO date in {path}: {reviewed!r}") from error
    data["last_reviewed"] = reviewed

    if not re.search(r"^#\s+\S", body, re.MULTILINE):
        raise AdrError(f"missing record title in {path}")
    for section in REQUIRED_SECTIONS:
        match = re.search(
            rf"^## {re.escape(section)}\s*\n(?P<content>.*?)(?=^##\s|\Z)",
            body,
            re.MULTILINE | re.DOTALL,
        )
        if not match:
            raise AdrError(f"missing section '{section}' in {path}")
        if not match.group("content").strip():
            raise AdrError(f"empty section '{section}' in {path}")

    remaining_placeholder = next(
        (placeholder for placeholder in TEMPLATE_PLACEHOLDERS if placeholder in text), None
    )
    if remaining_placeholder:
        raise AdrError(f"template placeholder remains in ADR record {path}: {remaining_placeholder}")

    data["_file"] = actual.as_posix()
    return data


def load_records(adr_root: Path) -> dict[str, dict[str, Any]]:
    records_root = adr_root / "records"
    if not records_root.is_dir():
        raise AdrError(f"missing records directory: {records_root}")
    records: dict[str, dict[str, Any]] = {}
    for path in sorted(records_root.rglob("*.md")):
        record = parse_record(path, adr_root)
        decision_id = record["id"]
        if decision_id in records:
            raise AdrError(f"duplicate ADR id: {decision_id}")
        records[decision_id] = record
    return records


def find_cycle(records: dict[str, dict[str, Any]], field: str) -> list[str] | None:
    visited: set[str] = set()
    active: list[str] = []

    def visit(node: str) -> list[str] | None:
        if node in active:
            start = active.index(node)
            return active[start:] + [node]
        if node in visited:
            return None
        active.append(node)
        for target in records[node][field]:
            cycle = visit(target)
            if cycle:
                return cycle
        active.pop()
        visited.add(node)
        return None

    for node in sorted(records):
        cycle = visit(node)
        if cycle:
            return cycle
    return None


def validate_relationships(records: dict[str, dict[str, Any]]) -> None:
    for decision_id, record in records.items():
        for field in RELATION_FIELDS:
            for target in record[field]:
                if target not in records:
                    raise AdrError(f"{decision_id}.{field} references missing ADR: {target}")

        if record["status"] == "accepted":
            for dependency_id in record["depends_on"]:
                dependency_status = records[dependency_id]["status"]
                if dependency_status != "accepted":
                    raise AdrError(
                        f"accepted ADR {decision_id} depends on {dependency_status} ADR: {dependency_id}"
                    )

        if record["status"] == "superseded" and not record["superseded_by"]:
            raise AdrError(f"superseded ADR lacks superseded_by: {decision_id}")
        if record["status"] != "superseded" and record["superseded_by"]:
            raise AdrError(f"only superseded ADRs may set superseded_by: {decision_id}")
        if record["supersedes"] and record["status"] not in {"accepted", "superseded"}:
            raise AdrError(
                f"only accepted or superseded ADRs may supersede another ADR: {decision_id}"
            )

        for replaced_id in record["supersedes"]:
            replaced = records[replaced_id]
            if decision_id not in replaced["superseded_by"]:
                raise AdrError(f"supersession is not bidirectional: {decision_id} -> {replaced_id}")
            if replaced["status"] != "superseded":
                raise AdrError(f"superseded target must have superseded status: {replaced_id}")
        for replacement_id in record["superseded_by"]:
            replacement = records[replacement_id]
            if replacement["status"] not in {"accepted", "superseded"}:
                raise AdrError(
                    "superseded_by target must have accepted or superseded status: "
                    f"{replacement_id}"
                )
            if decision_id not in replacement["supersedes"]:
                raise AdrError(f"supersession is not bidirectional: {replacement_id} -> {decision_id}")

    for field in ("depends_on", "supersedes"):
        cycle = find_cycle(records, field)
        if cycle:
            raise AdrError(f"{field} cycle: {' -> '.join(cycle)}")


def build_index(records: dict[str, dict[str, Any]]) -> dict[str, Any]:
    decisions: list[dict[str, Any]] = []
    for decision_id in sorted(records):
        record = records[decision_id]
        decisions.append(
            {
                "id": decision_id,
                "status": record["status"],
                "scope": record["scope"],
                "decision_type": record["decision_type"],
                "summary": record["summary"],
                "applies_to": record["applies_to"],
                "file": record["_file"],
                "constrains": record["constrains"],
                "depends_on": record["depends_on"],
                "supersedes": record["supersedes"],
                "superseded_by": record["superseded_by"],
                "last_reviewed": record["last_reviewed"],
                "enforcement": record["enforcement"],
                "enforcement_exception": record["enforcement_exception"],
            }
        )
    return {
        "version": 1,
        "generated_by": "maintain-architecture-decisions",
        "decisions": decisions,
    }


def records_and_index(
    root: Path, *, require_index: bool = True
) -> tuple[Path, dict[str, dict[str, Any]], dict[str, Any]]:
    adr_root = assert_safe_adr_tree(root)
    validate_marker(adr_root)
    required_paths = [adr_root / "README.md", adr_root / "_template.md"]
    if require_index:
        required_paths.append(adr_root / "index.yaml")
    for required in required_paths:
        if not required.is_file():
            raise AdrError(f"missing ADR system file: {required}")
    records = load_records(adr_root)
    validate_relationships(records)
    return adr_root, records, build_index(records)


def reindex_repository(root: Path) -> None:
    adr_root, _, expected = records_and_index(root, require_index=False)
    index_path = adr_root / "index.yaml"
    content = dump_yaml(expected)
    if index_path.is_file() and index_path.read_text(encoding="utf-8") == content:
        print("reindex: unchanged")
        return
    atomic_write(index_path, content)
    print(f"reindex: wrote {index_path}")


def validate_repository(root: Path) -> None:
    adr_root, records, expected = records_and_index(root)
    index_path = adr_root / "index.yaml"
    actual = load_yaml(index_path)
    if actual != expected:
        raise AdrError(f"stale index: run reindex for {index_path}")
    print(f"validate: ok ({len(records)} records)")


def enforce_repository(root: Path) -> None:
    resolved_root = root.resolve()
    adr_root, records, expected_index = records_and_index(resolved_root)
    actual_index = load_yaml(adr_root / "index.yaml")
    if actual_index != expected_index:
        raise AdrError(f"stale index: run reindex for {adr_root / 'index.yaml'}")
    total_checks = 0
    total_exceptions = 0
    for decision_id, record in sorted(records.items()):
        if record["status"] != "accepted":
            continue
        checks = record["enforcement"]
        exception = record["enforcement_exception"]
        if not checks:
            if exception is None:
                raise AdrError(f"accepted ADR has no enforcement checks or declared exception: {decision_id}")
            total_exceptions += 1
            continue
        if exception is not None:
            raise AdrError(
                f"ADR cannot declare both enforcement checks and an exception: {decision_id}"
            )
        for check in checks:
            total_checks += 1
            target = check["path"]
            matches = sorted(resolved_root.glob(target))
            files = []
            for match in matches:
                if match.is_symlink():
                    raise AdrError(
                        f"enforcement target is a symlink: {decision_id}/{check['id']}: {match}"
                    )
                if match.is_file():
                    try:
                        match.resolve().relative_to(resolved_root)
                    except ValueError as error:
                        raise AdrError(
                            f"enforcement target escapes repository: {decision_id}/{check['id']}: {match}"
                        ) from error
                    files.append(match)
            if not files:
                raise AdrError(
                    f"enforcement target matched no files: {decision_id}/{check['id']}: {target}"
                )
            for path in files:
                try:
                    content = path.read_text(encoding="utf-8")
                except UnicodeDecodeError as error:
                    raise AdrError(
                        f"enforcement target is not UTF-8 text: {decision_id}/{check['id']}: {path}"
                    ) from error
                for expected in check.get("must_contain", []):
                    if expected not in content:
                        raise AdrError(
                            f"enforcement failed: {decision_id}/{check['id']} requires {expected!r} in {path}"
                        )
                for forbidden in check.get("must_not_contain", []):
                    if forbidden in content:
                        raise AdrError(
                            f"enforcement failed: {decision_id}/{check['id']} forbids {forbidden!r} in {path}"
                        )
    if total_exceptions:
        label = "exception" if total_exceptions == 1 else "exceptions"
        suffix = f", {total_exceptions} declared {label}"
    else:
        suffix = ""
    print(f"check: ok ({total_checks} enforcement checks{suffix})")

def parser() -> argparse.ArgumentParser:
    command_parser = argparse.ArgumentParser(description=__doc__)
    subcommands = command_parser.add_subparsers(dest="command", required=True)
    for name in ("init", "reindex", "validate", "check"):
        subcommand = subcommands.add_parser(name)
        subcommand.add_argument("--root", type=Path, default=Path.cwd())
    return command_parser


def main() -> int:
    args = parser().parse_args()
    try:
        if args.command == "init":
            init_repository(args.root)
        elif args.command == "reindex":
            reindex_repository(args.root)
        elif args.command == "validate":
            validate_repository(args.root)
        else:
            enforce_repository(args.root)
    except AdrError as error:
        print(f"adr error: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
