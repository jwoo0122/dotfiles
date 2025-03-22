-- start quick open applications
local function open_app(name)
	return function()
		hs.application.launchOrFocus(name)
		if name == "Finder" then
			hs.appfinder.appFromName(name):activate()
		end
	end
end

--- quick open applications
hs.hotkey.bind({ "option", "shift" }, hs.keycodes.map["h"], open_app("ghostty"))
hs.hotkey.bind({ "option", "shift" }, hs.keycodes.map["v"], open_app("Cursor"))
hs.hotkey.bind({ "option", "shift" }, hs.keycodes.map["w"], open_app("Safari"))
hs.hotkey.bind({ "option", "shift" }, hs.keycodes.map["s"], open_app("Slack"))
hs.hotkey.bind({ "option", "shift" }, hs.keycodes.map["f"], open_app("Finder"))
hs.hotkey.bind({ "option", "shift" }, hs.keycodes.map["t"], open_app("Telegram"))
hs.hotkey.bind({ "option", "shift" }, hs.keycodes.map["l"], open_app("Linear"))
hs.hotkey.bind({ "option", "shift" }, hs.keycodes.map["c"], open_app("Google Chrome"))
hs.hotkey.bind({ "option", "shift" }, hs.keycodes.map["n"], open_app("Notes"))
hs.hotkey.bind({ "option", "shift" }, hs.keycodes.map["x"], open_app("xcode"))
hs.hotkey.bind({ "option", "shift" }, hs.keycodes.map["m"], open_app("Mail"))
-- hs.hotkey.bind({ "option", "shift" }, hs.keycodes.map["p"], open_app("Perplexity"))

hs.hotkey.bind({ "option", "shift" }, hs.keycodes.map["o"], function()
	local clicked, query = hs.dialog.textPrompt("Search on web", "", "", "Search", "Cancel")
	if clicked == "Cancel" then
		return
	end
	local query_encoded = hs.http.encodeForQuery(query)
	hs.execute("open " .. "https://duckduckgo.com/?q=" .. query_encoded)
end)

hs.hotkey.bind({ "option", "shift" }, hs.keycodes.map["p"], function()
  local clicked, query = hs.dialog.textPrompt("Search on Perplexity", "", "", "Search", "Cancel")
  if clicked == "Cancel" then
    return
  end
  local query_encoded = hs.http.encodeForQuery(query)
  hs.execute("open " .. "https://www.perplexity.ai/search?q=" .. query_encoded)
end)

-- Window management
-- half of screen
-- https://martinlwx.github.io/en/how-to-manage-windows-using-hammerspoon/
hs.hotkey.bind({'ctrl', 'option'}, 'left', function() hs.window.focusedWindow():moveToUnit({0, 0, 0.5, 1}) end)
hs.hotkey.bind({'ctrl', 'option'}, 'right', function() hs.window.focusedWindow():moveToUnit({0.5, 0, 0.5, 1}) end)
hs.hotkey.bind({'ctrl', 'option'}, 'up', function() hs.window.focusedWindow():moveToUnit({0, 0, 1, 0.5}) end)
hs.hotkey.bind({'ctrl', 'option'}, 'down', function() hs.window.focusedWindow():moveToUnit({0, 0.5, 1, 0.5}) end)

-- full screen
hs.hotkey.bind({'ctrl', 'option'}, 'return', function() hs.window.focusedWindow():moveToUnit({0, 0, 1, 1}) end)
hs.hotkey.bind({'ctrl', 'option'}, 'c', function() hs.window.focusedWindow():centerOnScreen() end)
