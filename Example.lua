local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/driffiti/ReduceUI/main/Library.lua"))()

Library:SetConfigFolder("ReduceUI/configs")

local Window = Library:CreateWindow({
	Title = "Reduce",
	Logo = "R",
	ToggleKey = Enum.KeyCode.LeftAlt,
	SidebarKey = Enum.KeyCode.B,
	Size = Vector2.new(1000, 640),
	ShowStats = true,
	CanvasGroup = true,
	ConfigFolder = "ReduceUI/configs",
})

local Showcase = Window:AddPage({
	Name = "Showcase",
	Section = "MAIN",
	Icon = "layout-dashboard",
	Description = "All element types",
})

local show = Showcase:AddSection("Elements")

local tog = show:AddToggle({
	Name = "Enable Feature",
	Description = "Master switch",
	Default = true,
	Flag = "ShowToggle",
	Callback = function() end,
})

local slider = show:AddSlider({
	Name = "Intensity",
	Description = "Adjust strength",
	Min = 0,
	Max = 100,
	Step = 1,
	Default = 50,
	Suffix = "%",
	Flag = "ShowSlider",
	Callback = function() end,
})
tog:Bind(slider)

show:AddDropdown({
	Name = "Mode",
	Description = "Select a mode",
	Options = { "Alpha", "Beta", "Gamma", "Delta" },
	Default = "Beta",
	Flag = "ShowDropdown",
	Callback = function() end,
})

show:AddDropdown({
	Name = "Multi Select",
	Description = "Pick multiple",
	Options = { "One", "Two", "Three", "Four", "Five" },
	Default = { "One", "Three" },
	Multi = true,
	Searchable = true,
	Flag = "ShowMulti",
	Callback = function() end,
})

show:AddSegmented({
	Name = "State",
	Description = "Auto / Manual / Off",
	Options = { "Auto", "Manual", "Off" },
	Default = "Manual",
	Flag = "ShowSegmented",
	Callback = function() end,
})

show:AddColorPicker({
	Name = "Accent Color",
	Description = "Pick a colour",
	Default = Color3.fromRGB(34, 197, 94),
	Flag = "ShowColor",
	Callback = function(c)
		Library:SetTheme({ Accent = c })
	end,
})

show:AddKeybind({
	Name = "Hotkey",
	Description = "Press to bind",
	Default = Enum.KeyCode.E,
	Flag = "ShowKey",
	Callback = function() end,
})

show:AddInput({
	Name = "Text Field",
	Description = "Type then save",
	Default = "Hello",
	Placeholder = "Enter text…",
	Flag = "ShowInput",
	Callback = function() end,
})

show:AddButton({
	Name = "Action",
	Description = "Run an action",
	Text = "Run",
	Callback = function()
		Window:Notify({ Title = "Action", Text = "Button pressed", Type = "success", Duration = 2 })
	end,
})

show:AddService({
	Name = "Background Task",
	Id = "task-1",
	Note = "Idle",
	NoteColor = "Gray",
	IdleNote = "Idle",
	IdleNoteColor = "Gray",
	RunningNote = "Running",
	RunningNoteColor = "Green",
	Options = { "Auto", "Manual", "Off" },
	Default = "Manual",
	Running = false,
	Flag = "ShowService",
	Callback = function() end,
	OnRun = function(running)
		Window:Notify({
			Title = "Task",
			Text = running and "Running" or "Stopped",
			Type = running and "success" or "info",
			Duration = 2,
		})
	end,
})

show:AddPlayerDropdown({
	Name = "Player",
	Description = "Select a player",
	Flag = "ShowPlayer",
	Callback = function() end,
})

show:AddLabel("Label example text")
show:AddParagraph({
	Title = "Paragraph",
	Content = "Short body text for documentation or notes inside a section card.",
})

local cfgShow = Showcase:AddSection("Config")
cfgShow:AddConfigManager({ Default = "default" })

local Combat = Window:AddPage({
	Name = "Combat",
	Section = "MAIN",
	Icon = "crosshair",
	Description = "Aim assist options",
})

local aimSec = Combat:AddSection("Aimbot")
local aimOn = aimSec:AddToggle({
	Name = "Enabled",
	Description = "Master switch",
	Default = false,
	Flag = "AimbotEnabled",
	Callback = function(v)
		Window:Notify({
			Title = "Aimbot",
			Text = v and "Enabled" or "Disabled",
			Type = v and "success" or "info",
			Duration = 2,
		})
	end,
})

aimSec:AddDropdown({
	Name = "Target Part",
	Description = "Lock part",
	Options = { "Head", "HumanoidRootPart", "UpperTorso", "LowerTorso" },
	Default = "Head",
	Flag = "AimbotPart",
	Callback = function() end,
})

aimSec:AddDropdown({
	Name = "Method",
	Options = { "Camera", "Mouse", "Silent" },
	Default = "Camera",
	Flag = "AimbotMethod",
	Callback = function() end,
})

local fov = aimSec:AddSlider({
	Name = "FOV",
	Min = 10,
	Max = 360,
	Step = 1,
	Default = 120,
	Suffix = "°",
	Flag = "AimbotFOV",
	Callback = function() end,
})
local smooth = aimSec:AddSlider({
	Name = "Smoothness",
	Min = 1,
	Max = 20,
	Step = 0.5,
	Default = 5,
	Flag = "AimbotSmooth",
	Callback = function() end,
})
aimOn:Bind(fov, smooth)

aimSec:AddToggle({
	Name = "Team Check",
	Default = true,
	Flag = "AimbotTeamCheck",
	Callback = function() end,
})

aimSec:AddKeybind({
	Name = "Aim Key",
	Default = Enum.KeyCode.E,
	Flag = "AimbotKey",
	Callback = function() end,
})

aimSec:AddColorPicker({
	Name = "FOV Color",
	Default = Color3.fromRGB(34, 197, 94),
	Flag = "AimbotFOVColor",
	Callback = function() end,
})

local targetSec = Combat:AddSection("Targeting")
targetSec:AddPlayerDropdown({
	Name = "Priority Target",
	Flag = "AimbotPriority",
	Callback = function() end,
})
targetSec:AddPlayerDropdown({
	Name = "Ignore List",
	Multi = true,
	Flag = "AimbotIgnore",
	Callback = function() end,
})

local Visuals = Window:AddPage({
	Name = "Visuals",
	Section = "MAIN",
	Icon = "eye",
	Description = "ESP options",
})

local espTab = Visuals:AddTab("ESP")
local worldTab = Visuals:AddTab("World")

local espSec = espTab:AddSection("Player ESP")
espSec:AddToggle({ Name = "Box ESP", Default = false, Flag = "ESPBox", Callback = function() end })
espSec:AddToggle({ Name = "Name ESP", Default = true, Flag = "ESPName", Callback = function() end })
espSec:AddToggle({ Name = "Health Bar", Default = true, Flag = "ESPHealth", Callback = function() end })
espSec:AddToggle({ Name = "Tracers", Default = false, Flag = "ESPTracers", Callback = function() end })
espSec:AddSlider({
	Name = "Max Distance",
	Min = 50,
	Max = 2000,
	Step = 50,
	Default = 500,
	Suffix = " studs",
	Flag = "ESPDistance",
	Callback = function() end,
})
espSec:AddColorPicker({ Name = "Enemy Color", Default = Color3.fromRGB(239, 68, 68), Flag = "ESPEnemyColor", Callback = function() end })
espSec:AddColorPicker({ Name = "Team Color", Default = Color3.fromRGB(34, 197, 94), Flag = "ESPTeamColor", Callback = function() end })

local worldSec = worldTab:AddSection("World")
worldSec:AddToggle({ Name = "Fullbright", Default = false, Flag = "Fullbright", Callback = function() end })
worldSec:AddToggle({ Name = "No Fog", Default = false, Flag = "NoFog", Callback = function() end })
worldSec:AddSlider({
	Name = "FOV",
	Min = 70,
	Max = 120,
	Step = 1,
	Default = 70,
	Flag = "CameraFOV",
	Callback = function() end,
})

local Movement = Window:AddPage({
	Name = "Movement",
	Section = "MAIN",
	Icon = "zap",
	Description = "Character options",
})

local moveSec = Movement:AddSection("Character")
local speedToggle = moveSec:AddToggle({
	Name = "Speed Hack",
	Description = "Modify walk speed",
	Default = false,
	Flag = "SpeedEnabled",
	Callback = function() end,
})
local walkSlider = moveSec:AddSlider({
	Name = "Walk Speed",
	Min = 16,
	Max = 200,
	Step = 1,
	Default = 16,
	Flag = "WalkSpeed",
	Callback = function() end,
})
speedToggle:Bind(walkSlider)

local jumpToggle = moveSec:AddToggle({
	Name = "Jump Power",
	Default = false,
	Flag = "JumpEnabled",
	Callback = function() end,
})
local jumpSlider = moveSec:AddSlider({
	Name = "Jump Height",
	Min = 50,
	Max = 300,
	Step = 5,
	Default = 50,
	Flag = "JumpPower",
	Callback = function() end,
})
jumpToggle:Bind(jumpSlider)

local flyToggle = moveSec:AddToggle({
	Name = "Fly",
	Description = "Toggle flight",
	Default = false,
	Flag = "FlyEnabled",
	Callback = function() end,
})
local flySlider = moveSec:AddSlider({
	Name = "Fly Speed",
	Min = 1,
	Max = 100,
	Step = 1,
	Default = 50,
	Flag = "FlySpeed",
	Callback = function() end,
})
local flyKey = moveSec:AddKeybind({
	Name = "Fly Key",
	Default = Enum.KeyCode.F,
	Flag = "FlyKey",
	OnPress = function() end,
})
flyToggle:Bind(flySlider, flyKey)

local Misc = Window:AddPage({
	Name = "Misc",
	Section = "TOOLS",
	Icon = "wrench",
	Description = "Utilities",
})

local svcSec = Misc:AddSection("Services")
svcSec:AddService({
	Name = "Auto Farm",
	Id = "autofarm",
	Note = "Idle",
	NoteColor = "Gray",
	IdleNote = "Idle",
	IdleNoteColor = "Gray",
	RunningNote = "Running",
	RunningNoteColor = "Green",
	Options = { "Auto", "Manual", "Off" },
	Default = "Off",
	Running = false,
	Flag = "ServiceFarm",
	Callback = function() end,
	OnRun = function(running)
		Window:Notify({
			Title = "Auto Farm",
			Text = running and "Started" or "Stopped",
			Type = running and "success" or "info",
			Duration = 2,
		})
	end,
})

svcSec:AddService({
	Name = "Auto Collect",
	Id = "autocollect",
	Note = "Idle",
	NoteColor = "Gray",
	IdleNote = "Idle",
	IdleNoteColor = "Gray",
	RunningNote = "Running",
	RunningNoteColor = "Green",
	Options = { "Auto", "Manual", "Off" },
	Default = "Manual",
	Running = false,
	Flag = "ServiceCollect",
	Callback = function() end,
	OnRun = function(running)
		Window:Notify({
			Title = "Auto Collect",
			Text = running and "Running" or "Stopped",
			Type = running and "success" or "info",
			Duration = 2,
		})
	end,
})

local utilSec = Misc:AddSection("Utilities")
utilSec:AddButton({
	Name = "Rejoin",
	Text = "Rejoin",
	Callback = function()
		Window:Notify({ Title = "Rejoin", Text = "Requested", Type = "warn" })
	end,
})
utilSec:AddButton({
	Name = "Server Hop",
	Text = "Hop",
	Callback = function()
		Window:Notify({ Title = "Server Hop", Text = "Requested", Type = "info" })
	end,
})
utilSec:AddInput({
	Name = "Webhook URL",
	Placeholder = "https://…",
	Flag = "WebhookURL",
	Callback = function() end,
})

local Settings = Window:AddPage({
	Name = "Settings",
	Section = "CONFIG",
	Icon = "settings",
	Description = "Theme and configs",
})

local themeSec = Settings:AddSection("Appearance")
themeSec:AddDropdown({
	Name = "Theme",
	Options = { "Default", "Ocean", "Rose", "Violet", "Amber" },
	Default = "Default",
	Flag = "Theme",
	Callback = function(name)
		Library:SetTheme(name)
	end,
})
themeSec:AddColorPicker({
	Name = "Accent",
	Default = Color3.fromRGB(34, 197, 94),
	Flag = "AccentColor",
	Callback = function(c)
		Library:SetTheme({ Accent = c })
	end,
})

local keySec = Settings:AddSection("Menu Keybinds")
keySec:AddKeybind({
	Name = "Toggle Menu",
	Default = Enum.KeyCode.LeftAlt,
	Flag = "MenuToggleKey",
	Callback = function(key)
		if key then Window:SetToggleKey(key) end
	end,
})
keySec:AddKeybind({
	Name = "Sidebar Key",
	Default = Enum.KeyCode.B,
	Flag = "MenuSidebarKey",
	Callback = function(key)
		if key then Window:SetSidebarKey(key) end
	end,
})

local cfgSec = Settings:AddSection("Configs")
cfgSec:AddConfigManager({ Default = "default" })

Window:Notify({
	Title = "Reduce",
	Text = "LeftAlt toggle · Ctrl+B sidebar · Ctrl+K search",
	Duration = 4,
	Type = "info",
})
