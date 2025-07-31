hs = hs or {}
spoon = spoon or {}
hs.loadSpoon("SpoonInstall")
spoon.SpoonInstall:andUse("RecursiveBinder")
local singleKey = spoon.RecursiveBinder.singleKey
local arrowKeys = {
	[123] = "left",
	[124] = "right",
	[125] = "down",
	[126] = "up",
}

local numberKeys = {
	[18] = "1",
	[19] = "2",
	[20] = "3",
	[21] = "4",
	[23] = "5",
	[22] = "6",
	[26] = "7",
	[28] = "8",
	[25] = "9",
	[29] = "10",
}

local keybLayouts = hs.keycodes.layouts()
local currentKeybLayout = hs.keycodes.currentLayout()
local currentLayoutIndex = hs.fnutils.indexOf(keybLayouts, currentKeybLayout)
local previousKeybLayout = keybLayouts[currentLayoutIndex - 1] or keybLayouts[#keybLayouts]

local function outputHandler(successMessage)
	return function(exitCode, stdOut, stdErr)
		if exitCode == 0 then
			-- show success message if provided, otherwise don't show anything
			if successMessage then
				hs.alert.show(successMessage)
			end
			return stdOut
		else
			hs.alert.show("Error:" .. stdErr)
			return stdErr
		end
	end
end

local command = "/opt/homebrew/bin/aerospace"

local function asCmd(args, successMessage)
	return function()
		local task = hs.task.new(command, outputHandler(successMessage), args)
		task:start()
	end
end

-- flagsMatch: returns true only if the flags exactly match the expected modifiers.
-- expectedModifiers is a table with the modifier names as strings (e.g. { "ctrl" }).
local function flagsMatch(flags, expectedModifiers, ignoreModifiers)
	-- List of possible modifier
	local possibleModifiers = { "ctrl", "alt", "shift", "cmd", "fn" }

	local expectedSet = {}
	for _, mod in ipairs(expectedModifiers) do
		expectedSet[mod] = true
	end

	local ignoreSet = {}
	for _, mod in ipairs(ignoreModifiers) do
		ignoreSet[mod] = true
	end

	-- For each modifier, ensure it is pressed if and only if it is expected.
	for _, mod in ipairs(possibleModifiers) do
		if not ignoreSet[mod] then
			local isExpected = expectedSet[mod] or false
			local isPressed = flags[mod] or false
			if isExpected ~= isPressed then
				return false
			end
		end
	end
	return true
end

Eventtap = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(event)
	local keyCode = event:getKeyCode()
	local flags = event:getFlags()
	local isCtrlOnly = flagsMatch(flags, { "ctrl" }, { "fn" })

	if isCtrlOnly and arrowKeys[keyCode] then
		asCmd({
			"focus",
			arrowKeys[keyCode],
			"--boundaries-action",
			"wrap-around-the-workspace",
		})()
		return true
	end

	-- Handle Control + Number Keys (1-0)
	if isCtrlOnly and numberKeys[keyCode] then
		asCmd({ "workspace", numberKeys[keyCode] }, "Workspace " .. numberKeys[keyCode])()
		return true
	end
end)

Eventtap:start() -- Start listening for key events

hs.hotkey.bind(
	{},
	"F16",
	spoon.RecursiveBinder.recursiveBind({
		[singleKey(",", "Settings")] = function()
			hs.application.launchOrFocus("System Preferences")
		end,
		[singleKey("R", "Reload config")] = function()
			hs.reload()
		end,
		[singleKey("j", "Scroll")] = function()
			hs.eventtap.keyStroke({ "alt", "ctrl", "alt", "cmd", "shift" }, "9")
		end,
		[singleKey("f", "Click")] = function()
			hs.eventtap.keyStroke({ "alt", "ctrl", "alt", "cmd", "shift" }, "8")
		end,
		[singleKey("s", "Search & Click")] = function()
			hs.eventtap.keyStroke({ "alt", "ctrl", "alt", "cmd", "shift" }, "7")
		end,
		[singleKey("tab", "Focus previous")] = asCmd({ "focus-back-and-forth" }),
		[singleKey("w", "Window+")] = {
			[singleKey("X", "Close all but current")] = asCmd({ "close-all-but-current" }),
			[singleKey("q", "Toggle AS")] = asCmd({ "enable", "toggle" }),
			-- focusing
			[singleKey("l", "Focus right")] = asCmd({
				"focus",
				"right",
				"--boundaries-action",
				"wrap-around-the-workspace",
			}),
			[singleKey("h", "Focus left")] = asCmd({
				"focus",
				"left",
				"--boundaries-action",
				"wrap-around-the-workspace",
			}),
			[singleKey("k", "Focus up")] = asCmd({ "focus", "up", "--boundaries-action", "wrap-around-the-workspace" }),
			[singleKey("j", "Focus down")] = asCmd({
				"focus",
				"down",
				"--boundaries-action",
				"wrap-around-the-workspace",
			}),
			-- moving
			[singleKey("L", "Move right")] = asCmd({ "move", "right" }),
			[singleKey("H", "Move left")] = asCmd({ "move", "left" }),
			[singleKey("K", "Move up")] = asCmd({ "move", "up" }),
			[singleKey("J", "Move down")] = asCmd({ "move", "down" }),
			[singleKey("w", "Mv prev ws")] = asCmd({ "move-node-to-workspace", "prev" }),
			[singleKey("e", "Mv next ws")] = asCmd({ "move-node-to-workspace", "next" }),
			-- -- layouts
			[singleKey("t", "Lay. titling")] = asCmd({ "layout", "tiles", "accordion" }),
			[singleKey("o", "Lay. orientation")] = asCmd({ "layout", "horizontal", "vertical" }),
			[singleKey("f", "Lay. mode")] = asCmd({ "layout", "tiling", "floating" }),
			-- move to workspace
			[singleKey("g", "Throw+")] = {
				[singleKey("1", "Workspace 1")] = asCmd({ "move-node-to-workspace", "--focus-follows-window", "1" }),
				[singleKey("2", "Workspace 2")] = asCmd({ "move-node-to-workspace", "--focus-follows-window", "2" }),
				[singleKey("3", "Workspace 3")] = asCmd({ "move-node-to-workspace", "--focus-follows-window", "3" }),
				[singleKey("4", "Workspace 4")] = asCmd({ "move-node-to-workspace", "--focus-follows-window", "4" }),
				[singleKey("5", "Workspace 5")] = asCmd({ "move-node-to-workspace", "--focus-follows-window", "5" }),
				[singleKey("6", "Workspace 6")] = asCmd({ "move-node-to-workspace", "--focus-follows-window", "6" }),
				[singleKey("7", "Workspace 7")] = asCmd({ "move-node-to-workspace", "--focus-follows-window", "7" }),
				[singleKey("8", "Workspace 8")] = asCmd({ "move-node-to-workspace", "--focus-follows-window", "8" }),
				[singleKey("9", "Workspace 9")] = asCmd({ "move-node-to-workspace", "--focus-follows-window", "9" }),
				[singleKey("0", "Workspace 10")] = asCmd({ "move-node-to-workspace", "--focus-follows-window", "10" }),
			},
			-- move workspace to monitor
			[singleKey("m", "Monitor+")] = {
				[singleKey("k", "Next")] = asCmd({ "move-workspace-to-monitor", "--wrap-around", "next" }),
				[singleKey("j", "Prev")] = asCmd({ "move-workspace-to-monitor", "--wrap-around", "prev" }),
			},
			-- split
			[singleKey("s", "Split+")] = {
				[singleKey("h", "Left")] = asCmd({ "join-with", "left" }),
				[singleKey("j", "Down")] = asCmd({ "join-with", "down" }),
				[singleKey("k", "Up")] = asCmd({ "join-with", "up" }),
				[singleKey("l", "Right")] = asCmd({ "join-with", "right" }),
			},
		},

		[singleKey("a", "Apps+")] = {
			[singleKey("t", "Terminal")] = function()
				hs.application.launchOrFocus("Ghostty")
			end,
			[singleKey("k", "Calendar")] = function()
				hs.application.launchOrFocus("Calendar")
			end,
			[singleKey("z", "Zed")] = function()
				hs.application.launchOrFocus("Zed")
			end,
			[singleKey("x", "XCode")] = function()
				hs.application.launchOrFocus("Xcode")
			end,
			[singleKey("a", "Android Studio")] = function()
				hs.application.launchOrFocus("Android Studio")
			end,
			[singleKey("f", "Finder")] = function()
				hs.application.launchOrFocus("Finder")
			end,
			[singleKey("e", "TextEdit")] = function()
				hs.application.launchOrFocus("TextEdit")
			end,
			[singleKey("p", "Proxyman")] = function()
				hs.application.launchOrFocus("Proxyman")
			end,
			[singleKey("w", "Web Browser+")] = {
				[singleKey("q", "Qutebrowser")] = function()
					hs.application.launchOrFocus("qutebrowser")
				end,
				[singleKey("a", "Arc")] = function()
					hs.application.launchOrFocus("Arc")
				end,
				[singleKey("s", "Safari")] = function()
					hs.application.launchOrFocus("Safari")
				end,
				[singleKey("f", "Firefox")] = function()
					hs.application.launchOrFocus("Firefox Developer Edition")
				end,
				[singleKey("o", "Orion")] = function()
					hs.application.launchOrFocus("Orion")
				end,
				[singleKey("b", "Brave")] = function()
					hs.application.launchOrFocus("Brave")
				end,
			},
			[singleKey("s", "Messaging+")] = {
				[singleKey("s", "Slack")] = function()
					hs.application.launchOrFocus("Slack")
				end,
				[singleKey("t", "Teams")] = function()
					hs.application.launchOrFocus("Microsoft Teams")
				end,
			},
			[singleKey("b", "Debugging+")] = {
				[singleKey("p", "Proxyman")] = function()
					hs.application.launchOrFocus("Proxyman")
				end,
				[singleKey("r", "reactotron")] = function()
					hs.application.launchOrFocus("reactotron")
				end,
				[singleKey("l", "Flipper")] = function()
					hs.application.launchOrFocus("Flipper")
				end,
				[singleKey("i", "Simulator")] = function()
					hs.application.launchOrFocus("Simulator")
				end,
			},
			[singleKey("g", "ChatGPT")] = function()
				hs.application.launchOrFocus("ChatGPT")
			end,
		},
		[singleKey("l", "Keyb. Layout+")] = {
			[singleKey("j", "Previous Layout")] = function()
				currentLayoutIndex = currentLayoutIndex > 1 and currentLayoutIndex - 1 or #keybLayouts
				hs.keycodes.setLayout(keybLayouts[currentLayoutIndex])
			end,
			[singleKey("k", "Next Layout")] = function()
				currentLayoutIndex = currentLayoutIndex < #keybLayouts and currentLayoutIndex + 1 or 1
				hs.keycodes.setLayout(keybLayouts[currentLayoutIndex])
			end,
			[singleKey("f", "Toggle Layout")] = function()
				local current = hs.keycodes.currentLayout()
				hs.keycodes.setLayout(previousKeybLayout)
				previousKeybLayout = current
			end,
		},
	})
)
