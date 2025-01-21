--- start quick open applications
local function open_app(name)
	return function()
		hs.application.launchOrFocus(name)
		if name == "Finder" then
			hs.appfinder.appFromName(name):activate()
		end
	end
end

--- quick open applications
hs.hotkey.bind({ "option", "shift" }, hs.keycodes.map["h"], open_app("kitty"))
hs.hotkey.bind({ "option", "shift" }, hs.keycodes.map["v"], open_app("Cursor"))
hs.hotkey.bind({ "option", "shift" }, hs.keycodes.map["w"], open_app("Safari"))
hs.hotkey.bind({ "option", "shift" }, hs.keycodes.map["s"], open_app("Slack"))
hs.hotkey.bind({ "option", "shift" }, hs.keycodes.map["f"], open_app("Finder"))
hs.hotkey.bind({ "option", "shift" }, hs.keycodes.map["t"], open_app("Telegram"))
hs.hotkey.bind({ "option", "shift" }, hs.keycodes.map["l"], open_app("Linear"))
hs.hotkey.bind({ "option", "shift" }, hs.keycodes.map["c"], open_app("Google Chrome"))
hs.hotkey.bind({ "option", "shift" }, hs.keycodes.map["n"], open_app("Notion"))
hs.hotkey.bind({ "option", "shift" }, hs.keycodes.map["x"], open_app("xcode"))
hs.hotkey.bind({ "option", "shift" }, hs.keycodes.map["m"], open_app("Mail"))

hs.hotkey.bind({ "option", "shift" }, hs.keycodes.map["o"], function()
	local clicked, query = hs.dialog.textPrompt("Search on web", "", "", "Search", "Cancel")
	if clicked == "Cancel" then
		return
	end
	local query_encoded = hs.http.encodeForQuery(query)
	hs.execute("open " .. "https://duckduckgo.com/?q=" .. query_encoded)
end)
