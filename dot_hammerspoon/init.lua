--- start quick open applications
function open_app(name)
	return function()
		hs.application.launchOrFocus(name)
		if name == "Finder" then
			hs.appfinder.appFromName(name):activate()
		end
	end
end

--- quick open applications
hs.hotkey.bind({ "option", "shift" }, hs.keycodes.map["h"], open_app("iTerm"))
hs.hotkey.bind({ "option", "shift" }, hs.keycodes.map["w"], open_app("Safari"))
hs.hotkey.bind({ "option", "shift" }, hs.keycodes.map["s"], open_app("Slack"))
hs.hotkey.bind({ "option", "shift" }, hs.keycodes.map["f"], open_app("Finder"))
hs.hotkey.bind({ "option", "shift" }, hs.keycodes.map["t"], open_app("Telegram"))
--- end quick open applications

hs.hotkey.bind({ "option", "shift" }, hs.keycodes.map["o"], function()
	local clicked, query = hs.dialog.textPrompt("Google Search", "", "", "Search", "Cancel")
	if clicked == "Cancel" then
		return
	end
	local query_encoded = hs.http.encodeForQuery(query)
	hs.execute("open " .. "https://google.com/search?q=" .. query_encoded)
end)
