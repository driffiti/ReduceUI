local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")
local Stats = game:GetService("Stats")

local Theme = {
	Background = Color3.fromRGB(21, 21, 21),
	Sidebar = Color3.fromRGB(24, 24, 24),
	Card = Color3.fromRGB(26, 26, 26),
	Input = Color3.fromRGB(19, 19, 19),
	Active = Color3.fromRGB(42, 42, 42),
	Stroke = Color3.fromRGB(42, 42, 42),
	StrokeLight = Color3.fromRGB(62, 62, 62),
	Text = Color3.fromRGB(240, 240, 240),
	Muted = Color3.fromRGB(150, 150, 150),
	Dim = Color3.fromRGB(100, 100, 100),
	Dot = Color3.fromRGB(95, 95, 95),
	Accent = Color3.fromRGB(34, 197, 94),
	Notes = {
		Green = { Text = Color3.fromRGB(34, 197, 94), Bg = Color3.fromRGB(20, 48, 32) },
		Yellow = { Text = Color3.fromRGB(234, 179, 8), Bg = Color3.fromRGB(54, 46, 16) },
		Red = { Text = Color3.fromRGB(239, 68, 68), Bg = Color3.fromRGB(58, 26, 26) },
		Gray = { Text = Color3.fromRGB(160, 160, 160), Bg = Color3.fromRGB(38, 38, 38) },
		Blue = { Text = Color3.fromRGB(96, 165, 250), Bg = Color3.fromRGB(22, 38, 64) },
	},
}

local Library = {}
Library.__index = Library
Library.Theme = Theme
Library.CustomIcons = {}
Library.Listening = false
Library.ConfigFolder = "ReduceUI/configs"
Library.Presets = {
	Default = {},
	Ocean = {
		Accent = Color3.fromRGB(56, 189, 248),
		Background = Color3.fromRGB(15, 20, 28),
		Sidebar = Color3.fromRGB(18, 24, 33),
		Card = Color3.fromRGB(21, 28, 38),
		Input = Color3.fromRGB(14, 19, 27),
		Active = Color3.fromRGB(32, 44, 60),
		Stroke = Color3.fromRGB(34, 46, 62),
		StrokeLight = Color3.fromRGB(52, 68, 90),
	},
	Rose = { Accent = Color3.fromRGB(244, 114, 182) },
	Violet = { Accent = Color3.fromRGB(167, 139, 250) },
	Amber = { Accent = Color3.fromRGB(251, 191, 36) },
}
local DefaultTheme = {}
for k, v in pairs(Theme) do
	if k ~= "Notes" then
		DefaultTheme[k] = v
	end
end

local DefaultNotes = {}
for k, v in pairs(Theme.Notes) do
	DefaultNotes[k] = { Text = v.Text, Bg = v.Bg }
end

local WindowClass = {}
WindowClass.__index = WindowClass
local PageClass = {}
PageClass.__index = PageClass
local TabClass = {}
TabClass.__index = TabClass
local SectionClass = {}
SectionClass.__index = SectionClass
local ItemClass = {}
ItemClass.__index = ItemClass
local IconClass = {}
IconClass.__index = IconClass

local Binds = {}

local function bind(inst, fn)
	fn()
	Binds[#Binds + 1] = { inst = inst, fn = fn }
end

local function runBinds()
	local alive = {}
	for _, b in ipairs(Binds) do
		if b.inst.Parent ~= nil then
			pcall(b.fn)
			alive[#alive + 1] = b
		end
	end
	Binds = alive
end

local ThemeProps = {
	Bg = "BackgroundColor3",
	Tc = "TextColor3",
	Ic = "ImageColor3",
	Sc = "ScrollBarImageColor3",
	Pc = "PlaceholderColor3",
	Cc = "Color",
}

local function create(class, props, children)
	local inst = Instance.new(class)
	if inst:IsA("GuiObject") then
		inst.BorderSizePixel = 0
	end
	local parent
	local themed
	for k, v in pairs(props or {}) do
		if k == "Parent" then
			parent = v
		elseif ThemeProps[k] then
			themed = themed or {}
			themed[ThemeProps[k]] = v
		else
			inst[k] = v
		end
	end
	if themed then
		for prop, key in pairs(themed) do
			bind(inst, function()
				inst[prop] = Theme[key]
			end)
		end
	end
	for _, child in ipairs(children or {}) do
		child.Parent = inst
	end
	if parent then
		inst.Parent = parent
	end
	return inst
end

local function corner(radius)
	return create("UICorner", { CornerRadius = UDim.new(0, radius) })
end

local function stroke(key, thickness)
	return create("UIStroke", {
		Cc = key or "Stroke",
		Thickness = thickness or 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})
end

local function padding(l, t, r, b)
	return create("UIPadding", {
		PaddingLeft = UDim.new(0, l or 0),
		PaddingTop = UDim.new(0, t or 0),
		PaddingRight = UDim.new(0, r or 0),
		PaddingBottom = UDim.new(0, b or 0),
	})
end

local function list(direction, gap, valign)
	return create("UIListLayout", {
		FillDirection = direction or Enum.FillDirection.Vertical,
		Padding = UDim.new(0, gap or 0),
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = valign or Enum.VerticalAlignment.Top,
	})
end

local FONT = Enum.Font.BuilderSans
local FONT_MED = Enum.Font.BuilderSansMedium
local FONT_BOLD = Enum.Font.BuilderSansBold

local function newLabel(props, children)
	local p = {
		BackgroundTransparency = 1,
		Font = FONT,
		TextSize = 13,
		Text = "",
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
	}
	if props.TextColor3 == nil and props.Tc == nil then
		p.Tc = "Text"
	end
	for k, v in pairs(props) do
		p[k] = v
	end
	return create("TextLabel", p, children)
end

local function tween(obj, time, props, style, dir)
	local tw = TweenService:Create(
		obj,
		TweenInfo.new(time, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out),
		props
	)
	tw:Play()
	return tw
end

local function pressable(button, amount)
	local sc = create("UIScale", { Parent = button })
	button.MouseButton1Down:Connect(function()
		tween(sc, 0.08, { Scale = amount or 0.96 })
	end)
	local function release()
		tween(sc, 0.25, { Scale = 1 }, Enum.EasingStyle.Back)
	end
	button.MouseButton1Up:Connect(release)
	button.MouseLeave:Connect(release)
end

local function trim(s)
	return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function prettyKey(key)
	if not key then
		return "None"
	end
	local name = key.Name
	name = name:gsub("(%l)(%u)", "%1 %2")
	return name
end

local function mountGui(gui)
	local env = getfenv()
	local ghui = env.gethui
	if type(ghui) == "function" then
		local ok, parent = pcall(ghui)
		if ok and parent then
			gui.Parent = parent
			return
		end
	end
	local ok = pcall(function()
		gui.Parent = game:GetService("CoreGui")
	end)
	if ok and gui.Parent then
		return
	end
	gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
end

local function makeDraggable(handle, target)
	local dragging = false
	local startPos, startInput
	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			startInput = input.Position
			startPos = target.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if
			dragging
			and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch)
		then
			local delta = input.Position - startInput
			target.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)
end

local function trackDrag(conns, hit, onUpdate)
	local dragging = false
	hit.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			onUpdate(input.Position)
		end
	end)
	table.insert(
		conns,
		UserInputService.InputChanged:Connect(function(input)
			if
				dragging
				and (
					input.UserInputType == Enum.UserInputType.MouseMovement
					or input.UserInputType == Enum.UserInputType.Touch
				)
			then
				onUpdate(input.Position)
			end
		end)
	)
	table.insert(
		conns,
		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = false
			end
		end)
	)
end

local Icons = {
	State = "idle",
	Pending = {},
	Provider = nil,
	Cache = {},
	All = setmetatable({}, { __mode = "k" }),
}

local ICON_SOURCES = {
	"https://raw.githubusercontent.com/deividcomsono/lucide-roblox-direct/refs/heads/main/source.lua",
	"https://github.com/latte-soft/lucide-roblox/releases/latest/download/lucide-roblox.luau",
}

local function toSpec(r)
	if type(r) == "string" then
		return { Image = r }
	end
	if type(r) ~= "table" then
		return nil
	end
	local image = r.Url or r.Image
	if not image and r.Id then
		image = "rbxassetid://" .. tostring(r.Id)
	end
	if image then
		return { Image = image, Offset = r.ImageRectOffset or r.RectOffset, Size = r.ImageRectSize or r.RectSize }
	end
	if r.FontFace and r.Text then
		return { FontFace = r.FontFace, Text = r.Text }
	end
	return nil
end

local function providerSpec(name)
	local p = Icons.Provider
	if not p then
		return nil
	end
	local cached = Icons.Cache[name]
	if cached ~= nil then
		return cached or nil
	end
	local spec = nil
	if type(p) == "function" then
		local ok, r = pcall(p, name)
		if ok then
			spec = toSpec(r)
		end
	elseif type(p) == "table" then
		if type(p.GetAsset) == "function" then
			local ok, r = pcall(p.GetAsset, name)
			if ok then
				spec = toSpec(r)
			end
		end
		if not spec and type(p.GetFontAsset) == "function" then
			local ok, r = pcall(p.GetFontAsset, name)
			if ok then
				spec = toSpec(r)
			end
		end
	end
	Icons.Cache[name] = spec or false
	return spec
end

local function loadProvider()
	local env = getfenv()
	local ls = env.loadstring or loadstring
	if type(ls) ~= "function" then
		return nil
	end
	for _, url in ipairs(ICON_SOURCES) do
		local ok, src = pcall(function()
			return game:HttpGet(url)
		end)
		if ok and type(src) == "string" and #src > 0 then
			local ok2, fn = pcall(ls, src)
			if ok2 and type(fn) == "function" then
				local ok3, mod = pcall(fn)
				if ok3 and type(mod) == "table" and (mod.GetAsset or mod.GetFontAsset) then
					return mod
				end
			end
		end
	end
	return nil
end

local function ensureIcons()
	if Icons.State ~= "idle" then
		return
	end
	if Library.IconProvider then
		Icons.Provider = Library.IconProvider
		Icons.State = "ready"
		return
	end
	Icons.State = "loading"
	task.spawn(function()
		local mod = loadProvider()
		Icons.Provider = mod
		Icons.State = mod and "ready" or "failed"
		local pending = Icons.Pending
		Icons.Pending = {}
		for _, o in ipairs(pending) do
			if o.Holder.Parent then
				o:Apply()
			end
		end
	end)
end

local function looksLikeName(s)
	return s:match("^[%a%d_%-:]+$") ~= nil
end

function IconClass:_show(spec)
	if spec.FontFace then
		self.Txt.FontFace = spec.FontFace
		self.Txt.Text = spec.Text
		self.Txt.Visible = true
		return true
	end
	if spec.Image then
		self.Img.Image = spec.Image
		self.Img.ImageRectOffset = spec.Offset or Vector2.new(0, 0)
		self.Img.ImageRectSize = spec.Size or Vector2.new(0, 0)
		self.Img.Visible = true
		return true
	end
	return false
end

function IconClass:_try(c)
	if type(c) == "number" then
		c = "rbxassetid://" .. tostring(c)
	end
	if type(c) ~= "string" or c == "" then
		return false
	end
	local custom = Library.CustomIcons[c:lower()]
	if custom then
		local spec = toSpec(custom)
		if spec then
			return self:_show(spec)
		end
	end
	if c:find("/", 1, true) then
		return self:_show({ Image = c })
	end
	if looksLikeName(c) then
		local key = c:lower():gsub("^lucide:", "")
		local spec = providerSpec(key)
		if spec then
			return self:_show(spec)
		end
		return false
	end
	self.Txt.Font = FONT
	self.Txt.Text = c
	self.Txt.Visible = true
	return true
end

function IconClass:Apply()
	self.Img.Visible = false
	self.Txt.Visible = false
	local candidates = self.Icon
	if type(candidates) ~= "table" then
		candidates = { candidates }
	end
	local needsProvider = false
	for _, c in ipairs(candidates) do
		if type(c) == "string" and looksLikeName(c) and not Library.CustomIcons[c:lower()] then
			needsProvider = true
		end
	end
	if needsProvider and Icons.State == "loading" then
		table.insert(Icons.Pending, self)
		return
	end
	for _, c in ipairs(candidates) do
		if self:_try(c) then
			return
		end
	end
end

function IconClass:SetIcon(icon)
	self.Icon = icon
	ensureIcons()
	self:Apply()
end

function IconClass:SetColor(color, animate)
	self.Color = color
	if animate then
		tween(self.Img, 0.2, { ImageColor3 = color })
		tween(self.Txt, 0.2, { TextColor3 = color })
	else
		self.Img.ImageColor3 = color
		self.Txt.TextColor3 = color
	end
end

function IconClass:SetShown(v)
	self.Holder.Visible = v
end

local function newIcon(parent, icon, size, position, anchor, colorKey)
	local obj = setmetatable({ Icon = icon, Color = Theme.Muted }, IconClass)
	obj.Holder = create("Frame", {
		BackgroundTransparency = 1,
		AnchorPoint = anchor or Vector2.new(0, 0),
		Position = position or UDim2.new(),
		Size = UDim2.fromOffset(size, size),
		Parent = parent,
	})
	obj.Img = create("ImageLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Visible = false,
		Parent = obj.Holder,
	})
	obj.Txt = create("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Text = "",
		TextSize = size,
		Font = FONT,
		Visible = false,
		Parent = obj.Holder,
	})
	Icons.All[obj] = true
	ensureIcons()
	obj:Apply()
	if colorKey then
		bind(obj.Holder, function()
			obj:SetColor(Theme[colorKey])
		end)
	else
		obj:SetColor(obj.Color)
	end
	return obj
end

function Library:SetIconProvider(provider)
	Library.IconProvider = provider
	Icons.Provider = provider
	Icons.State = "ready"
	Icons.Cache = {}
	for o in pairs(Icons.All) do
		if o.Holder.Parent then
			o:Apply()
		end
	end
end

function Library:SetCustomIcon(name, asset)
	Library.CustomIcons[string.lower(name)] = asset
	for o in pairs(Icons.All) do
		if o.Holder.Parent then
			o:Apply()
		end
	end
end

function Library:SetTheme(t)
	if type(t) == "string" then
		local preset = Library.Presets[t]
		if not preset then
			return
		end
		for k, v in pairs(DefaultTheme) do
			Theme[k] = v
		end
		for k, v in pairs(DefaultNotes) do
			Theme.Notes[k] = { Text = v.Text, Bg = v.Bg }
		end
		t = preset
	end
	local hadAccent = t.Accent ~= nil
	local hadActive = t.Active ~= nil
	for k, v in pairs(t) do
		if k == "Notes" and type(v) == "table" then
			for nk, nv in pairs(v) do
				Theme.Notes[nk] = nv
			end
		else
			Theme[k] = v
		end
	end
	if hadAccent and not hadActive and Theme.Accent then
		Theme.Active = Theme.Accent:Lerp(Theme.Background, 0.82)
		Theme.StrokeLight = Theme.Accent:Lerp(Theme.Stroke, 0.55)
	end
	runBinds()
end

function Library:GetTheme()
	return Theme
end

local function makeSegmented(parent, options, default, callback, width)
	local obj = { Options = options, Value = nil }
	local holder = create("Frame", {
		Name = "Segmented",
		Size = UDim2.fromOffset(width or (#options * 70), 30),
		Bg = "Input",
		Parent = parent,
	}, { corner(8), stroke("Stroke") })
	local inner = create("Frame", {
		Size = UDim2.new(1, -6, 1, -6),
		Position = UDim2.fromOffset(3, 3),
		BackgroundTransparency = 1,
		Parent = holder,
	})
	local thumb = create("Frame", { Bg = "Active", Parent = inner }, { corner(6), stroke("StrokeLight") })
	local buttons = {}
	obj.Frame = holder

	local function thumbPos(idx)
		local n = math.max(#obj.Options, 1)
		return UDim2.new((idx - 1) / n, 1, 0, 0)
	end

	local function paint()
		for opt, b in pairs(buttons) do
			b.TextColor3 = (opt == obj.Value) and Theme.Text or Theme.Muted
		end
	end

	local function select(opt, silent, instant)
		local idx = table.find(obj.Options, opt)
		if not idx then
			return
		end
		obj.Value = opt
		if instant then
			thumb.Position = thumbPos(idx)
			paint()
		else
			tween(thumb, 0.28, { Position = thumbPos(idx) })
			for o, b in pairs(buttons) do
				tween(b, 0.2, { TextColor3 = (o == opt) and Theme.Text or Theme.Muted })
			end
		end
		if not silent and callback then
			task.spawn(callback, opt)
		end
	end

	local function build()
		for _, b in pairs(buttons) do
			b:Destroy()
		end
		buttons = {}
		local n = math.max(#obj.Options, 1)
		thumb.Size = UDim2.new(1 / n, -2, 1, 0)
		for i, opt in ipairs(obj.Options) do
			local b = create("TextButton", {
				Size = UDim2.new(1 / n, 0, 1, 0),
				Position = UDim2.new((i - 1) / n, 0, 0, 0),
				BackgroundTransparency = 1,
				Text = tostring(opt),
				Font = FONT_MED,
				TextSize = 11,
				TextColor3 = Theme.Muted,
				AutoButtonColor = false,
				ZIndex = 2,
				Parent = inner,
			})
			buttons[opt] = b
			b.MouseButton1Click:Connect(function()
				select(opt, false)
			end)
		end
	end

	function obj.Set(value, silent)
		select(value, silent, false)
	end
	function obj.Get()
		return obj.Value
	end
	function obj.SetOptions(newOptions, keepValue)
		local old = obj.Value
		obj.Options = newOptions
		build()
		if keepValue and table.find(newOptions, old) then
			select(old, true, true)
		else
			select(newOptions[1], true, true)
		end
	end

	build()
	local idx = table.find(options, default) or 1
	obj.Value = options[idx]
	thumb.Position = thumbPos(idx)
	paint()
	bind(holder, paint)
	return obj
end

local function makeSwitch(parent, default, callback)
	local obj = { Value = default and true or false }
	local track = create("TextButton", {
		Size = UDim2.fromOffset(40, 22),
		Text = "",
		AutoButtonColor = false,
		Parent = parent,
	}, { corner(11), stroke("Stroke") })
	local knob = create("Frame", {
		Size = UDim2.fromOffset(16, 16),
		Position = UDim2.fromOffset(3, 3),
		Parent = track,
	}, { corner(8) })
	obj.Frame = track

	local trackStroke = track:FindFirstChildOfClass("UIStroke")
	local function paint(animate)
		local on = obj.Value
		local tc = on and Theme.Accent or Theme.Input
		local kp = UDim2.fromOffset(on and 21 or 3, 3)
		local kc = on and Color3.new(1, 1, 1) or Theme.Muted
		local sc = on and Theme.Accent or Theme.Stroke
		if animate then
			tween(track, 0.2, { BackgroundColor3 = tc })
			tween(knob, 0.3, { Position = kp, BackgroundColor3 = kc }, Enum.EasingStyle.Back)
			if trackStroke then tween(trackStroke, 0.2, { Color = sc }) end
		else
			track.BackgroundColor3 = tc
			knob.Position = kp
			knob.BackgroundColor3 = kc
			if trackStroke then trackStroke.Color = sc end
		end
	end
	function obj.Set(value, silent)
		obj.Value = value and true or false
		paint(true)
		if not silent and callback then
			task.spawn(callback, obj.Value)
		end
	end
	function obj.Get()
		return obj.Value
	end
	track.MouseButton1Click:Connect(function()
		obj.Set(not obj.Value, false)
	end)
	bind(track, function()
		paint(false)
	end)
	return obj
end

local function makeNote(parent, text, colorKey)
	local pill = create("Frame", {
		Size = UDim2.new(0, 0, 0, 20),
		AutomaticSize = Enum.AutomaticSize.X,
		LayoutOrder = 1,
		Parent = parent,
	}, { corner(10), padding(10, 0, 10, 0) })
	local lbl = newLabel({
		Size = UDim2.new(0, 0, 1, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		Text = text,
		TextSize = 9,
		Font = FONT_MED,
		Parent = pill,
	})
	local function paint()
		local scheme
		if typeof(colorKey) == "Color3" then
			scheme = { Text = colorKey, Bg = colorKey:Lerp(Color3.new(0, 0, 0), 0.8) }
		else
			scheme = Theme.Notes[colorKey or "Green"] or Theme.Notes.Green
		end
		pill.BackgroundColor3 = scheme.Bg
		lbl.TextColor3 = scheme.Text
	end
	bind(pill, paint)
	local sc = create("UIScale", { Scale = 0.6, Parent = pill })
	tween(sc, 0.35, { Scale = 1 }, Enum.EasingStyle.Back)
	return pill, lbl
end

function Library:CreateWindow(opts)
	opts = opts or {}
	ensureIcons()
	local self = setmetatable({}, WindowClass)
	self.Pages = {}
	self.NavSections = {}
	self.NavSectionCount = 0
	self.SidebarOpen = true
	self.Connections = {}
	self.Visible = true
	self.ToggleKey = opts.ToggleKey or Enum.KeyCode.LeftAlt
	self.SidebarKey = opts.SidebarKey or Enum.KeyCode.B
	self.ToggleToken = 0
	self.Results = {}
	self.ResultIndex = 0
	self.Flags = {}
	self.ConfigFolder = opts.ConfigFolder or Library.ConfigFolder or "ReduceUI/configs"

	local size = opts.Size or Vector2.new(1000, 640)
	local lp = Players.LocalPlayer
	local userOpts = opts.User or {}

	local gui = create("ScreenGui", {
		Name = opts.Name or "ReduceUI",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		IgnoreGuiInset = true,
		DisplayOrder = 999,
	})
	mountGui(gui)
	self.Gui = gui

	local useCanvas = opts.CanvasGroup ~= false
	local main = create(useCanvas and "CanvasGroup" or "Frame", {
		Name = "Main",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(size.X, size.Y),
		Bg = "Background",
		ClipsDescendants = true,
		Parent = gui,
	}, { corner(14), stroke("Stroke") })
	self.Main = main
	self.IsCanvas = useCanvas

	self.Scale = create("UIScale", { Parent = main })
	self.BaseScale = 1
	local cam = workspace.CurrentCamera
	if cam then
		local vp = cam.ViewportSize
		self.BaseScale = math.min(1, vp.X / (size.X + 40), vp.Y / (size.Y + 40))
	end
	self.Scale.Scale = self.BaseScale

	local sidebar = create("Frame", {
		Name = "Sidebar",
		Size = UDim2.new(0, 256, 1, 0),
		Bg = "Sidebar",
		ClipsDescendants = true,
		Parent = main,
	})
	create("Frame", {
		Size = UDim2.new(0, 1, 1, 0),
		Position = UDim2.new(1, -1, 0, 0),
		Bg = "Stroke",
		ZIndex = 5,
		Parent = sidebar,
	})
	local sbInner = create("Frame", {
		Size = UDim2.new(0, 256, 1, 0),
		BackgroundTransparency = 1,
		Parent = sidebar,
	})
	self.Sidebar = sidebar

	local sbHeader = create("Frame", {
		Size = UDim2.new(1, 0, 0, 68),
		BackgroundTransparency = 1,
		Parent = sbInner,
	})
	local logoBox = create("Frame", {
		Size = UDim2.fromOffset(36, 36),
		Position = UDim2.fromOffset(20, 16),
		Bg = "Card",
		Parent = sbHeader,
	}, { corner(10), stroke("Stroke") })
	self.LogoText = newLabel({
		Size = UDim2.fromScale(1, 1),
		Text = opts.Logo or "R",
		Font = FONT_BOLD,
		TextSize = 18,
		TextXAlignment = Enum.TextXAlignment.Center,
		Parent = logoBox,
	})
	self.LogoIcon = newIcon(logoBox, opts.LogoIcon, 20, UDim2.fromScale(0.5, 0.5), Vector2.new(0.5, 0.5), "Text")
	self.LogoIcon:SetShown(opts.LogoIcon ~= nil)
	self.LogoText.Visible = opts.LogoIcon == nil
	self.SidebarTitle = newLabel({
		Position = UDim2.fromOffset(68, 0),
		Size = UDim2.new(1, -88, 1, 0),
		Text = opts.Title or "Reduce",
		Font = FONT_MED,
		TextSize = 14,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = sbHeader,
	})

	local navClip = create("Frame", {
		Name = "NavClip",
		Position = UDim2.fromOffset(0, 68),
		Size = UDim2.new(1, 0, 1, -140),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Parent = sbInner,
	})
	self.NavClip = navClip
	self.NavHighlight = create("Frame", {
		Size = UDim2.new(1, -24, 0, 40),
		Position = UDim2.fromOffset(12, 0),
		BackgroundColor3 = Theme.Active,
		Visible = false,
		ZIndex = 1,
		Parent = navClip,
	}, { corner(10) })
	bind(self.NavHighlight, function()
		self.NavHighlight.BackgroundColor3 = Theme.Accent:Lerp(Theme.Sidebar, 0.88)
	end)
	local navList = create("ScrollingFrame", {
		Name = "Nav",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ScrollBarThickness = 0,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ZIndex = 2,
		Parent = navClip,
	}, { padding(12, 0, 12, 8), list(Enum.FillDirection.Vertical, 2) })
	self.NavList = navList

	local sbFooter = create("Frame", {
		Position = UDim2.new(0, 0, 1, -72),
		Size = UDim2.new(1, 0, 0, 72),
		BackgroundTransparency = 1,
		Parent = sbInner,
	})
	create("Frame", { Size = UDim2.new(1, 0, 0, 1), Bg = "Stroke", Parent = sbFooter })
	local avatar = create("Frame", {
		Size = UDim2.fromOffset(40, 40),
		Position = UDim2.fromOffset(18, 16),
		Bg = "Active",
		ClipsDescendants = true,
		Parent = sbFooter,
	}, { corner(20) })
	self.AvatarInitial = newLabel({
		Size = UDim2.fromScale(1, 1),
		Text = "?",
		Font = FONT_BOLD,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Center,
		Parent = avatar,
	})
	self.AvatarImage = create("ImageLabel", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ImageTransparency = 1,
		Parent = avatar,
	}, { corner(20) })
	self.UserName = newLabel({
		Position = UDim2.fromOffset(70, 15),
		Size = UDim2.new(1, -90, 0, 18),
		Text = "",
		Font = FONT_MED,
		TextSize = 12,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = sbFooter,
	})
	create("Frame", {
		Position = UDim2.fromOffset(70, 42),
		Size = UDim2.fromOffset(6, 6),
		Bg = "Accent",
		Parent = sbFooter,
	}, { corner(3) })
	self.UserSub = newLabel({
		Position = UDim2.fromOffset(82, 36),
		Size = UDim2.new(1, -100, 0, 18),
		Text = "",
		Tc = "Muted",
		TextSize = 11,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = sbFooter,
	})

	local content = create("Frame", {
		Name = "Content",
		Position = UDim2.fromOffset(256, 0),
		Size = UDim2.new(1, -256, 1, 0),
		BackgroundTransparency = 1,
		Parent = main,
	})
	self.Content = content

	local topbar = create("Frame", {
		Size = UDim2.new(1, 0, 0, 66),
		BackgroundTransparency = 1,
		ZIndex = 10,
		Parent = content,
	})
	create("Frame", {
		Position = UDim2.new(0, 0, 1, -1),
		Size = UDim2.new(1, 0, 0, 1),
		Bg = "Stroke",
		Parent = topbar,
	})
	makeDraggable(topbar, main)

	self.TitleLabel = newLabel({
		Position = UDim2.fromOffset(28, 0),
		Size = UDim2.new(0, 260, 1, 0),
		Text = "",
		Font = FONT_MED,
		TextSize = 13,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 10,
		Parent = topbar,
	})

	local searchFrame = create("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -28, 0.5, 0),
		Size = UDim2.fromOffset(340, 36),
		Bg = "Input",
		ZIndex = 10,
		Parent = topbar,
	}, { corner(18), stroke("Stroke") })
	newIcon(searchFrame, { "search", "⌕" }, 15, UDim2.new(0, 14, 0.5, 0), Vector2.new(0, 0.5), "Muted")
	local searchBox = create("TextBox", {
		Position = UDim2.fromOffset(40, 0),
		Size = UDim2.new(1, -110, 1, 0),
		BackgroundTransparency = 1,
		Text = "",
		PlaceholderText = "Search everything",
		Pc = "Muted",
		Tc = "Text",
		Font = FONT,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false,
		ZIndex = 10,
		Parent = searchFrame,
	})
	create("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.fromOffset(46, 20),
		Bg = "Card",
		ZIndex = 10,
		Parent = searchFrame,
	}, {
		corner(5),
		stroke("Stroke"),
		newLabel({
			Size = UDim2.fromScale(1, 1),
			Text = "Ctrl K",
			TextSize = 9,
			Tc = "Muted",
			TextXAlignment = Enum.TextXAlignment.Center,
			ZIndex = 10,
		}),
	})
	self.SearchBox = searchBox
	self.SearchFrame = searchFrame

	self.ResultsFrame = create("Frame", {
		Name = "Results",
		Position = UDim2.new(0, 0, 1, 8),
		Size = UDim2.new(1, 0, 0, 0),
		Bg = "Card",
		ClipsDescendants = true,
		Visible = false,
		ZIndex = 20,
		Parent = searchFrame,
	}, { corner(12), stroke("Stroke") })
	self.ResultsScroll = create("ScrollingFrame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ScrollBarThickness = 3,
		Sc = "StrokeLight",
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ZIndex = 21,
		Parent = self.ResultsFrame,
	}, { padding(6, 6, 6, 6), list(Enum.FillDirection.Vertical, 2) })

	searchBox:GetPropertyChangedSignal("Text"):Connect(function()
		self:_showResults(self:_search(searchBox.Text))
	end)
	searchBox.FocusLost:Connect(function(enter)
		if enter and self.Results[self.ResultIndex] then
			self:GoTo(self.Results[self.ResultIndex])
		end
		task.delay(0.15, function()
			if not searchBox:IsFocused() then
				self:_hideResults()
			end
		end)
	end)
	searchBox.Focused:Connect(function()
		if searchBox.Text ~= "" then
			self:_showResults(self:_search(searchBox.Text))
		end
	end)

	self.PageHolder = create("Frame", {
		Position = UDim2.fromOffset(0, 66),
		Size = UDim2.new(1, 0, 1, -122),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Parent = content,
	})
	self.PageCover = create("Frame", {
		Size = UDim2.fromScale(1, 1),
		Bg = "Background",
		BackgroundTransparency = 1,
		ZIndex = 50,
		Active = false,
		Parent = self.PageHolder,
	})

	local statusBar = create("Frame", {
		Position = UDim2.new(0, 0, 1, -56),
		Size = UDim2.new(1, 0, 0, 56),
		BackgroundTransparency = 1,
		Parent = content,
	})
	create("Frame", { Size = UDim2.new(1, 0, 0, 1), Bg = "Stroke", Parent = statusBar })
	newLabel({
		Position = UDim2.fromOffset(28, 10),
		Size = UDim2.fromOffset(200, 14),
		Text = "ACTIVE VIEW",
		TextSize = 8,
		Tc = "Dim",
		Font = FONT_MED,
		Parent = statusBar,
	})
	self.FooterLabel = newLabel({
		Position = UDim2.fromOffset(28, 26),
		Size = UDim2.fromOffset(300, 18),
		Text = "",
		TextSize = 11,
		Font = FONT_MED,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = statusBar,
	})
	self.StatsLabel = newLabel({
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -28, 0, 10),
		Size = UDim2.fromOffset(260, 14),
		Text = "",
		TextSize = 9,
		Tc = "Muted",
		TextXAlignment = Enum.TextXAlignment.Right,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = statusBar,
	})
	self.HintLabel = newLabel({
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -28, 0, 28),
		Size = UDim2.fromOffset(300, 14),
		Text = "",
		TextSize = 9,
		Tc = "Dim",
		TextXAlignment = Enum.TextXAlignment.Right,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = statusBar,
	})
	self.CustomHint = opts.FooterHint
	self:_updateHint()

	local searchNav = create("TextButton", {
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		LayoutOrder = 0,
		Parent = navList,
	}, { corner(10) })
	newIcon(searchNav, { "search", "⌕" }, 17, UDim2.fromOffset(12, 11), nil, "Muted")
	newLabel({
		Position = UDim2.fromOffset(50, 0),
		Size = UDim2.new(1, -60, 1, 0),
		Text = "Search",
		Tc = "Muted",
		Font = FONT_MED,
		Parent = searchNav,
	})
	searchNav.MouseEnter:Connect(function()
		tween(searchNav, 0.15, { BackgroundTransparency = 0.6, BackgroundColor3 = Theme.Active })
	end)
	searchNav.MouseLeave:Connect(function()
		tween(searchNav, 0.2, { BackgroundTransparency = 1 })
	end)
	searchNav.MouseButton1Click:Connect(function()
		searchBox:CaptureFocus()
	end)

	self.Toasts = create("Frame", {
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -20, 1, -20),
		Size = UDim2.new(0, 300, 1, -40),
		BackgroundTransparency = 1,
		Parent = gui,
	}, { list(Enum.FillDirection.Vertical, 8, Enum.VerticalAlignment.Bottom) })

	local displayName = userOpts.Name
	if not displayName then
		if lp then
			displayName = opts.UseDisplayName and lp.DisplayName or lp.Name
		else
			displayName = "Player"
		end
	end
	self:SetUser({ Name = displayName, Subtitle = userOpts.Subtitle or userOpts.Role, Avatar = userOpts.Avatar })
	if not (userOpts.Subtitle or userOpts.Role) then
		self.UserSub.Text = game.Name
		task.spawn(function()
			local ok, info = pcall(function()
				return MarketplaceService:GetProductInfo(game.PlaceId)
			end)
			if ok and info and info.Name and self.Gui.Parent and not self.UserSubCustom then
				self.UserSub.Text = info.Name
			end
		end)
	end
	if not userOpts.Avatar and lp then
		task.spawn(function()
			local ok, url = pcall(function()
				return Players:GetUserThumbnailAsync(lp.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
			end)
			if ok and url and self.Gui.Parent then
				self.AvatarImage.Image = url
				tween(self.AvatarImage, 0.4, { ImageTransparency = 0 })
			end
		end)
	end

	table.insert(
		self.Connections,
		UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if input.UserInputType ~= Enum.UserInputType.Keyboard then
				return
			end
			if Library.Listening then
				return
			end
			local ctrl = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
				or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)

			if ctrl and input.KeyCode == Enum.KeyCode.K then
				if not self.Visible then
					self:SetVisible(true)
				end
				task.defer(function()
					if searchBox and searchBox.Parent then
						searchBox:CaptureFocus()
					end
				end)
				return
			end

			if searchBox:IsFocused() then
				if input.KeyCode == Enum.KeyCode.Down then
					self:_moveResult(1)
				elseif input.KeyCode == Enum.KeyCode.Up then
					self:_moveResult(-1)
				elseif input.KeyCode == Enum.KeyCode.Escape then
					searchBox.Text = ""
					searchBox:ReleaseFocus()
					self:_hideResults()
				elseif input.KeyCode == Enum.KeyCode.Return or input.KeyCode == Enum.KeyCode.KeypadEnter then
					if self.Results[self.ResultIndex] then
						self:GoTo(self.Results[self.ResultIndex])
					end
				end
				return
			end
			if UserInputService:GetFocusedTextBox() then
				return
			end
			if input.KeyCode == self.ToggleKey then
				self:Toggle()
				return
			end
			if ctrl and input.KeyCode == self.SidebarKey then
				self:ToggleSidebar()
			end
		end)
	)

	if opts.ShowStats ~= false then
		local frames = 0
		table.insert(
			self.Connections,
			RunService.RenderStepped:Connect(function()
				frames = frames + 1
			end)
		)
		task.spawn(function()
			local last = os.clock()
			while self.Gui.Parent do
				task.wait(0.5)
				local now = os.clock()
				local fps = math.floor(frames / (now - last) + 0.5)
				frames = 0
				last = now
				local ping = 0
				pcall(function()
					ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue() + 0.5)
				end)
				self.StatsLabel.Text = string.format("%d FPS  |  %d ms", fps, ping)
			end
		end)
	end

	main.Visible = false
	self.Visible = false
	task.defer(function()
		self:SetVisible(true)
	end)

	return self
end

function WindowClass:_updateHint()
	local text = self.CustomHint
	if not text then
		text = prettyKey(self.ToggleKey) .. " to toggle  |  Ctrl+" .. prettyKey(self.SidebarKey) .. " sidebar"
	end
	self.HintLabel.Text = text
end

function WindowClass:SetFooterHint(text)
	self.CustomHint = text
	self:_updateHint()
end

function WindowClass:SetToggleKey(key)
	self.ToggleKey = key
	self:_updateHint()
end

function WindowClass:SetSidebarKey(key)
	self.SidebarKey = key
	self:_updateHint()
end

function WindowClass:SetTitle(text)
	self.SidebarTitle.Text = text
end

function WindowClass:SetLogo(text, icon)
	if text ~= nil and icon == nil and type(text) == "string" then
		local looksIcon = text:find("rbxassetid://", 1, true)
			or text:find("http://", 1, true)
			or text:find("https://", 1, true)
			or text:match("^%d+$")
		if looksIcon then
			icon = text
			text = nil
		end
	end
	if type(icon) == "number" then
		icon = "rbxassetid://" .. tostring(icon)
	end
	if icon ~= nil then
		self.LogoText.Visible = false
		self.LogoIcon:SetShown(true)
		self.LogoIcon:SetIcon(icon)
	else
		self.LogoText.Text = text or "R"
		self.LogoText.Visible = true
		self.LogoIcon:SetShown(false)
	end
end

function WindowClass:SetUser(u)
	u = u or {}
	if u.Name then
		self.UserName.Text = u.Name
		self.AvatarInitial.Text = string.upper(string.sub(u.Name, 1, 1))
	end
	if u.Subtitle or u.Role then
		self.UserSub.Text = u.Subtitle or u.Role
		self.UserSubCustom = true
	end
	if u.Avatar then
		self.AvatarImage.Image = u.Avatar
		self.AvatarImage.ImageTransparency = 0
	end
end

function WindowClass:SetVisible(v, instant)
	self.Visible = v
	self.ToggleToken = self.ToggleToken + 1
	local token = self.ToggleToken
	local main = self.Main
	local scale = self.Scale
	local stroke = main:FindFirstChildOfClass("UIStroke")
	if v then
		main.Visible = true
		if stroke then stroke.Transparency = 0 end
		if instant then
			if self.IsCanvas then
				main.GroupTransparency = 0
			end
			scale.Scale = self.BaseScale
		else
			if self.IsCanvas then
				main.GroupTransparency = 1
				tween(main, 0.28, { GroupTransparency = 0 })
			end
			if stroke then
				stroke.Transparency = 1
				tween(stroke, 0.28, { Transparency = 0 })
			end
			scale.Scale = self.BaseScale * 0.94
			tween(scale, 0.4, { Scale = self.BaseScale }, Enum.EasingStyle.Back)
		end
	else
		if self.IsCanvas then
			tween(main, 0.18, { GroupTransparency = 1 })
		end
		if stroke then
			tween(stroke, 0.15, { Transparency = 1 })
		end
		tween(scale, 0.18, { Scale = self.BaseScale * 0.94 }, Enum.EasingStyle.Quad)
		task.delay(0.2, function()
			if self.ToggleToken == token and not self.Visible then
				main.Visible = false
				if stroke then stroke.Transparency = 0 end
			end
		end)
	end
end

function WindowClass:Toggle()
	self:SetVisible(not self.Visible)
end

function WindowClass:ToggleSidebar()
	self.SidebarOpen = not self.SidebarOpen
	local w = self.SidebarOpen and 256 or 0
	tween(self.Sidebar, 0.35, { Size = UDim2.new(0, w, 1, 0) })
	tween(self.Content, 0.35, { Position = UDim2.fromOffset(w, 0), Size = UDim2.new(1, -w, 1, 0) })
end

function WindowClass:Destroy()
	for _, c in ipairs(self.Connections) do
		c:Disconnect()
	end
	self.Gui:Destroy()
end

function WindowClass:_moveHighlight(btn, instant)
	local hl = self.NavHighlight
	if not btn or not btn.Parent then
		hl.Visible = false
		return
	end
	local s = self.Scale.Scale
	if s <= 0 then
		return
	end
	local y = (btn.AbsolutePosition.Y - self.NavClip.AbsolutePosition.Y) / s
	local h = btn.AbsoluteSize.Y / s
	if h <= 0 then
		return
	end
	local pos = UDim2.new(0, 12, 0, y)
	local sz = UDim2.new(1, -24, 0, h)
	if not hl.Visible or instant then
		hl.Visible = true
		hl.Position = pos
		hl.Size = sz
	else
		tween(hl, 0.35, { Position = pos, Size = sz })
	end
end

function WindowClass:SelectPage(page, instant)
	if self.CurrentPage == page then
		return
	end
	self.CurrentPage = page
	for _, p in ipairs(self.Pages) do
		local on = (p == page)
		p.Active = on
		p:_paint(not instant)
		p.Scroll.Visible = on
	end
	self.TitleLabel.Text = page.Name
	self.FooterLabel.Text = page.Name
	if page.CurrentTab and page.CurrentTab.Frame then
		page.CurrentTab.Frame.Visible = true
		local sc = page.CurrentTab.Frame:FindFirstChildOfClass("UIScale")
		if sc then sc.Scale = 1 end
	end
	for _, tab in ipairs(page.Tabs) do
		for _, sec in ipairs(tab.Sections) do
			sec.Frame.Visible = true
			for _, it in ipairs(sec.Items) do
				if it.Row and not it._depHidden then
					it.Row.Visible = true
				end
			end
		end
	end
	page:_enter(instant)
	task.defer(function()
		self:_moveHighlight(page.NavButton, instant)
	end)
end

function WindowClass:Notify(opts)
	opts = opts or {}
	local colorKey = ({ success = "Accent", warn = "Yellow", error = "Red", info = "Accent" })[opts.Type or "info"]
	local accent = Theme.Accent
	if colorKey == "Yellow" or colorKey == "Red" then
		accent = Theme.Notes[colorKey].Text
	end
	local toast = create(self.IsCanvas and "CanvasGroup" or "Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Bg = "Card",
		Parent = self.Toasts,
	}, {
		corner(12),
		stroke("Stroke"),
		padding(16, 12, 16, 0),
		list(Enum.FillDirection.Vertical, 3),
	})
	local sc = create("UIScale", { Scale = 0.9, Parent = toast })
	if self.IsCanvas then
		toast.GroupTransparency = 1
	end
	newLabel({
		Size = UDim2.new(1, 0, 0, 16),
		Text = opts.Title or "Notice",
		Font = FONT_MED,
		TextSize = 13,
		TextColor3 = accent,
		LayoutOrder = 1,
		Parent = toast,
	})
	newLabel({
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Text = opts.Text or "",
		Tc = "Muted",
		TextSize = 12,
		TextWrapped = true,
		TextYAlignment = Enum.TextYAlignment.Top,
		LayoutOrder = 2,
		Parent = toast,
	})
	create("Frame", {
		Size = UDim2.new(1, 0, 0, 8),
		BackgroundTransparency = 1,
		LayoutOrder = 3,
		Parent = toast,
	})
	local duration = opts.Duration or 4
	local toastStroke = toast:FindFirstChildOfClass("UIStroke")
	if self.IsCanvas then
		toast.GroupTransparency = 1
		tween(toast, 0.3, { GroupTransparency = 0 })
	end
	if toastStroke then
		toastStroke.Transparency = 1
		tween(toastStroke, 0.3, { Transparency = 0 })
	end
	tween(sc, 0.4, { Scale = 1 }, Enum.EasingStyle.Back)
	task.delay(duration, function()
		if not toast.Parent then
			return
		end
		-- fade the border together with everything else, then remove it immediately
		-- (a stroke on a UIScale'd group otherwise lingers after the body is gone)
		if self.IsCanvas then
			tween(toast, 0.22, { GroupTransparency = 1 })
		else
			tween(toast, 0.22, { BackgroundTransparency = 1 })
			for _, d in ipairs(toast:GetDescendants()) do
				if d:IsA("TextLabel") then
					tween(d, 0.22, { TextTransparency = 1 })
				end
			end
		end
		if toastStroke then
			tween(toastStroke, 0.18, { Transparency = 1 })
		end
		tween(sc, 0.22, { Scale = 0.9 })
		task.delay(0.23, function()
			if toast.Parent then
				toast.Visible = false
				toast:Destroy()
			end
		end)
	end)
end

function WindowClass:_search(q)
	q = trim(q):lower()
	local results = {}
	if q == "" then
		return results
	end
	local tokens = {}
	for tok in q:gmatch("%S+") do
		tokens[#tokens + 1] = tok
	end
	local function hit(hay)
		for _, t in ipairs(tokens) do
			if not hay:find(t, 1, true) then
				return false
			end
		end
		return true
	end
	for _, page in ipairs(self.Pages) do
		if hit(page.Name:lower()) then
			results[#results + 1] = { Title = page.Name, Sub = "Page", Page = page }
		end
		for _, tab in ipairs(page.Tabs) do
			for _, section in ipairs(tab.Sections) do
				for _, item in ipairs(section.Items) do
					local hay = (page.Name .. " " .. tab.Name .. " " .. section.Name .. " " .. item.Name .. " " .. item.Desc .. " " .. item.Id):lower()
					if hit(hay) then
						local sub = page.Name
						if not tab.Hidden then
							sub = sub .. " / " .. tab.Name
						end
						if section.Name ~= "" then
							sub = sub .. " / " .. section.Name
						end
						results[#results + 1] = {
							Title = item.Name ~= "" and item.Name or "(untitled)",
							Sub = sub,
							Page = page,
							Tab = tab,
							Item = item,
							Icon = page.IconSpec,
						}
					end
				end
			end
		end
		if #results >= 40 then
			break
		end
	end
	return results
end

function WindowClass:_hideResults()
	local f = self.ResultsFrame
	if not f.Visible then
		return
	end
	local tw = tween(f, 0.15, { Size = UDim2.new(1, 0, 0, 0) })
	tw.Completed:Connect(function()
		if self.ResultsFrame.Size.Y.Offset == 0 then
			f.Visible = false
		end
	end)
	self.Results = {}
	self.ResultIndex = 0
end

function WindowClass:_paintResults()
	for i, b in ipairs(self.ResultButtons or {}) do
		tween(b, 0.12, { BackgroundTransparency = (i == self.ResultIndex) and 0 or 1 })
	end
end

function WindowClass:_moveResult(delta)
	local n = #self.Results
	if n == 0 then
		return
	end
	self.ResultIndex = ((self.ResultIndex - 1 + delta) % n) + 1
	self:_paintResults()
end

function WindowClass:_showResults(results)
	for _, c in ipairs(self.ResultsScroll:GetChildren()) do
		if c:IsA("TextButton") or c:IsA("TextLabel") then
			c:Destroy()
		end
	end
	self.ResultButtons = {}
	self.Results = results
	self.ResultIndex = (#results > 0) and 1 or 0
	local q = self.SearchBox.Text
	if trim(q) == "" then
		self:_hideResults()
		return
	end
	local f = self.ResultsFrame
	if #results == 0 then
		newLabel({
			Size = UDim2.new(1, 0, 0, 40),
			Text = "No results",
			Tc = "Muted",
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Center,
			ZIndex = 22,
			Parent = self.ResultsScroll,
		})
		f.Visible = true
		tween(f, 0.2, { Size = UDim2.new(1, 0, 0, 52) })
		return
	end
	for i, r in ipairs(results) do
		local b = create("TextButton", {
			Size = UDim2.new(1, 0, 0, 46),
			Bg = "Active",
			BackgroundTransparency = 1,
			Text = "",
			AutoButtonColor = false,
			LayoutOrder = i,
			ZIndex = 22,
			Parent = self.ResultsScroll,
		}, { corner(8) })
		newIcon(b, r.Page.Icon or "•", 15, UDim2.new(0, 12, 0.5, 0), Vector2.new(0, 0.5), "Muted").Holder.ZIndex = 23
		newLabel({
			Position = UDim2.fromOffset(40, 7),
			Size = UDim2.new(1, -52, 0, 16),
			Text = r.Title,
			Font = FONT_MED,
			TextSize = 12,
			TextTruncate = Enum.TextTruncate.AtEnd,
			ZIndex = 23,
			Parent = b,
		})
		newLabel({
			Position = UDim2.fromOffset(40, 24),
			Size = UDim2.new(1, -52, 0, 14),
			Text = r.Sub,
			Tc = "Muted",
			TextSize = 10,
			TextTruncate = Enum.TextTruncate.AtEnd,
			ZIndex = 23,
			Parent = b,
		})
		b.MouseEnter:Connect(function()
			self.ResultIndex = i
			self:_paintResults()
		end)
		b.MouseButton1Click:Connect(function()
			self:GoTo(r)
		end)
		table.insert(self.ResultButtons, b)
	end
	self:_paintResults()
	f.Visible = true
	tween(f, 0.25, { Size = UDim2.new(1, 0, 0, math.min(#results, 7) * 48 + 12) })
end

function WindowClass:GoTo(result)
	if not result then
		return
	end
	self.SearchBox.Text = ""
	self.SearchBox:ReleaseFocus()
	self:_hideResults()
	self:SelectPage(result.Page)
	if result.Tab then
		result.Page:SelectTab(result.Tab)
	end
	local item = result.Item
	if item then
		task.spawn(function()
			task.wait(0.15)
			if not item.Row.Parent then
				return
			end
			local scroll = result.Page.Scroll
			local s = self.Scale.Scale
			local y = (item.Row.AbsolutePosition.Y - scroll.AbsolutePosition.Y) / s + scroll.CanvasPosition.Y - 90
			tween(scroll, 0.4, { CanvasPosition = Vector2.new(0, math.max(0, y)) })
			local row = item.Row
			row.BackgroundColor3 = Theme.Accent
			row.BackgroundTransparency = 0.8
			tween(row, 1.2, { BackgroundTransparency = 1 }, Enum.EasingStyle.Quad)
			task.delay(1.25, function()
				if row.Parent then
					row.BackgroundColor3 = Color3.new(1, 1, 1)
				end
			end)
		end)
	end
end

function WindowClass:AddPage(opts)
	opts = opts or {}
	local page = setmetatable({
		Window = self,
		Name = opts.Name or "Page",
		Icon = opts.Icon,
		Tabs = {},
		Items = {},
		FilterText = "",
		Active = false,
		BadgeText = opts.Badge and tostring(opts.Badge) or "",
	}, PageClass)

	local sectionName = opts.Section or "MAIN"
	local sec = self.NavSections[sectionName]
	if not sec then
		self.NavSectionCount = self.NavSectionCount + 1
		sec = { Order = self.NavSectionCount * 1000, Count = 0 }
		self.NavSections[sectionName] = sec
		newLabel({
			Name = "NavSection",
			Size = UDim2.new(1, 0, 0, 34),
			Text = string.upper(sectionName),
			TextSize = 9,
			Tc = "Dim",
			Font = FONT_MED,
			LayoutOrder = sec.Order,
			Parent = self.NavList,
		}, { padding(13, 10, 0, 0) })
	end
	sec.Count = sec.Count + 1

	local btn = create("TextButton", {
		Name = page.Name,
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		LayoutOrder = sec.Order + sec.Count,
		Parent = self.NavList,
	}, { corner(10) })
	page.NavButton = btn
	page.NavIcon = newIcon(btn, opts.Icon or "layout-dashboard", 17, UDim2.fromOffset(12, 11))
	page.NavText = newLabel({
		Position = UDim2.fromOffset(50, 0),
		Size = UDim2.new(1, -70, 1, 0),
		Text = page.Name,
		Tc = "Muted",
		Font = FONT_MED,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = btn,
	})
	page.NavBadge = newLabel({
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -28, 0.5, 0),
		Size = UDim2.fromOffset(28, 18),
		Text = page.BadgeText,
		Tc = "Muted",
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Right,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = btn,
	})
	page.NavChevron = newIcon(btn, { "chevron-right", "›" }, 14, UDim2.new(1, -12, 0.5, 0), Vector2.new(1, 0.5))
	page.NavChevron:SetShown(false)

	btn.MouseEnter:Connect(function()
		if not page.Active then
			tween(btn, 0.15, { BackgroundTransparency = 0.6, BackgroundColor3 = Theme.Active })
			tween(page.NavText, 0.15, { TextColor3 = Theme.Text })
			page.NavIcon:SetColor(Theme.Text, true)
		end
	end)
	btn.MouseLeave:Connect(function()
		if not page.Active then
			tween(btn, 0.2, { BackgroundTransparency = 1 })
			tween(page.NavText, 0.2, { TextColor3 = Theme.Muted })
			page.NavIcon:SetColor(Theme.Muted, true)
		end
	end)
	btn.MouseButton1Click:Connect(function()
		self:SelectPage(page)
	end)
	btn:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
		if self.CurrentPage == page then
			self:_moveHighlight(btn, true)
		end
	end)
	bind(btn, function()
		page:_paint(false)
	end)

	local scroll = create("ScrollingFrame", {
		Name = page.Name .. "_Page",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ScrollBarThickness = 4,
		Sc = "StrokeLight",
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Visible = false,
		Parent = self.PageHolder,
	}, { padding(28, 28, 28, 28), list(Enum.FillDirection.Vertical, 18) })
	page.Scroll = scroll

	local header = create("Frame", {
		Size = UDim2.new(1, 0, 0, 62),
		BackgroundTransparency = 1,
		LayoutOrder = 1,
		Parent = scroll,
	})
	page.HeaderTitle = newLabel({
		Size = UDim2.new(1, -330, 0, 32),
		Text = page.Name,
		Font = FONT_MED,
		TextSize = 24,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = header,
	})
	page.HeaderDesc = newLabel({
		Position = UDim2.fromOffset(0, 36),
		Size = UDim2.new(1, -330, 0, 20),
		Text = opts.Description or "",
		Tc = "Muted",
		TextSize = 11,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = header,
	})

	if opts.Filterable ~= false then
		local filter = create("Frame", {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, 0, 0, 0),
			Size = UDim2.fromOffset(300, 38),
			Bg = "Input",
			Parent = header,
		}, { corner(12), stroke("Stroke") })
		newIcon(filter, { "search", "⌕" }, 15, UDim2.new(0, 14, 0.5, 0), Vector2.new(0, 0.5), "Muted")
		local box = create("TextBox", {
			Position = UDim2.fromOffset(40, 0),
			Size = UDim2.new(1, -52, 1, 0),
			BackgroundTransparency = 1,
			Text = "",
			PlaceholderText = opts.FilterPlaceholder or "Filter",
			Pc = "Muted",
			Tc = "Text",
			Font = FONT,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			ClearTextOnFocus = false,
			Parent = filter,
		})
		box:GetPropertyChangedSignal("Text"):Connect(function()
			page.FilterText = box.Text:lower()
			page:_applyFilter()
		end)
	end

	page.TabBar = create("Frame", {
		Size = UDim2.new(1, 0, 0, 42),
		BackgroundTransparency = 1,
		Visible = false,
		LayoutOrder = 2,
		Parent = scroll,
	})
	create("Frame", {
		Position = UDim2.new(0, 0, 1, -1),
		Size = UDim2.new(1, 0, 0, 1),
		Bg = "Stroke",
		Parent = page.TabBar,
	})
	page.TabButtons = create("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Parent = page.TabBar,
	}, { list(Enum.FillDirection.Horizontal, 6) })

	page.TabContent = create("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = 3,
		Parent = scroll,
	})

	table.insert(self.Pages, page)
	page.IconSpec = nil
	if #self.Pages == 1 then
		self:SelectPage(page, true)
	else
		page:_paint(false)
	end
	return page
end

function PageClass:_paint(animate)
	local on = self.Active
	local tc = on and Theme.Text or Theme.Muted
	local ic = on and Theme.Accent or Theme.Muted
	if animate then
		tween(self.NavText, 0.25, { TextColor3 = tc })
		tween(self.NavButton, 0.25, { BackgroundTransparency = 1 })
	else
		self.NavText.TextColor3 = tc
		self.NavButton.BackgroundTransparency = 1
	end
	self.NavIcon:SetColor(ic, animate)
	if self.NavChevron then
		self.NavChevron:SetShown(on)
		self.NavChevron:SetColor(Theme.Accent, animate)
	end
	self.NavBadge.Visible = not on and self.BadgeText ~= ""
end

function PageClass:_enter(instant)
	if instant then
		return
	end
	local cover = self.Window.PageCover
	cover.BackgroundTransparency = 0
	tween(cover, 0.28, { BackgroundTransparency = 1 }, Enum.EasingStyle.Quad)
	self.Scroll.Position = UDim2.fromOffset(0, 14)
	tween(self.Scroll, 0.4, { Position = UDim2.fromOffset(0, 0) }, Enum.EasingStyle.Quint)
end

function PageClass:_applyFilter()
	local q = self.FilterText
	for _, tab in ipairs(self.Tabs) do
		for _, section in ipairs(tab.Sections) do
			local any = (#section.Items == 0)
			for _, item in ipairs(section.Items) do
				local match = (q == "") or (item.Matches and item:Matches(q))
				if item._depHidden then
					item.Row.Visible = false
				else
					item.Row.Visible = match and true or false
					if match then
						any = true
					end
				end
			end
			section.Frame.Visible = any
		end
	end
end

function PageClass:SetName(name)
	self.Name = name
	self.NavText.Text = name
	self.HeaderTitle.Text = name
	if self.Window.CurrentPage == self then
		self.Window.TitleLabel.Text = name
		self.Window.FooterLabel.Text = name
	end
end

function PageClass:SetIcon(icon)
	self.Icon = icon
	self.NavIcon:SetIcon(icon)
end

function PageClass:SetDescription(text)
	self.HeaderDesc.Text = text or ""
end

function PageClass:SetBadge(text)
	self.BadgeText = text and tostring(text) or ""
	self.NavBadge.Text = self.BadgeText
	self:_paint(false)
end

function PageClass:SetVisible(v)
	self.NavButton.Visible = v
end

function PageClass:Remove()
	local win = self.Window
	local idx = table.find(win.Pages, self)
	if idx then
		table.remove(win.Pages, idx)
	end
	self.NavButton:Destroy()
	self.Scroll:Destroy()
	if win.CurrentPage == self then
		win.CurrentPage = nil
		if win.Pages[1] then
			win:SelectPage(win.Pages[1], true)
		end
	end
end

function PageClass:_newTab(name, hideBar)
	local tab = setmetatable({
		Page = self,
		Name = name,
		Sections = {},
		Items = {},
		ShowCount = true,
		Hidden = hideBar,
	}, TabClass)

	tab.Frame = create("Frame", {
		Name = name,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Visible = false,
		Parent = self.TabContent,
	}, { padding(0, 22, 0, 0), list(Enum.FillDirection.Vertical, 22) })

	if not hideBar then
		tab.Button = create("TextButton", {
			Size = UDim2.new(0, 0, 1, 0),
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundTransparency = 1,
			Text = name,
			Font = FONT_MED,
			TextSize = 11,
			TextTruncate = Enum.TextTruncate.AtEnd,
			AutoButtonColor = false,
			LayoutOrder = #self.Tabs + 1,
			Parent = self.TabButtons,
		}, { padding(12, 0, 12, 0) })
		tab.Underline = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 1, -2),
			Size = UDim2.new(0, 0, 0, 2),
			Bg = "Text",
			ZIndex = 3,
			Parent = tab.Button,
		})
		tab.Button.MouseButton1Click:Connect(function()
			self:SelectTab(tab)
		end)
		tab.Button.MouseEnter:Connect(function()
			if self.CurrentTab ~= tab then
				tween(tab.Button, 0.15, { TextColor3 = Theme.Text })
			end
		end)
		tab.Button.MouseLeave:Connect(function()
			if self.CurrentTab ~= tab then
				tween(tab.Button, 0.2, { TextColor3 = Theme.Muted })
			end
		end)
		bind(tab.Button, function()
			tab.Button.TextColor3 = (self.CurrentTab == tab) and Theme.Text or Theme.Muted
		end)
	end

	table.insert(self.Tabs, tab)
	if #self.Tabs == 1 then
		self:SelectTab(tab, true)
	end
	return tab
end

function PageClass:AddTab(name)
	self.TabBar.Visible = true
	return self:_newTab(name, false)
end

function PageClass:SelectTab(tab, instant)
	if self.CurrentTab == tab then
		return
	end
	local prev = self.CurrentTab
	self.CurrentTab = tab
	for _, t in ipairs(self.Tabs) do
		local on = (t == tab)
		if t.Button then
			tween(t.Button, 0.25, { TextColor3 = on and Theme.Text or Theme.Muted })
			tween(t.Underline, on and 0.4 or 0.2, { Size = UDim2.new(on and 1 or 0, 0, 0, 2) }, Enum.EasingStyle.Quint)
		end
	end
	if instant then
		if prev then
			prev.Frame.Visible = false
		end
		tab.Frame.Visible = true
		return
	end
	if prev and prev ~= tab then
		local oldFrame = prev.Frame
		local oldScale = oldFrame:FindFirstChildOfClass("UIScale")
		if not oldScale then
			oldScale = create("UIScale", { Parent = oldFrame })
		end
		tween(oldScale, 0.15, { Scale = 0.97 }, Enum.EasingStyle.Quad)
		task.delay(0.12, function()
			if oldFrame.Parent and self.CurrentTab ~= prev then
				oldFrame.Visible = false
				oldScale.Scale = 1
			end
		end)
	end
	local newScale = tab.Frame:FindFirstChildOfClass("UIScale")
	if not newScale then
		newScale = create("UIScale", { Parent = tab.Frame })
	end
	newScale.Scale = 0.96
	tab.Frame.Visible = true
	tween(newScale, 0.35, { Scale = 1 }, Enum.EasingStyle.Quint)
	if tab.Button then
		self:_enter(false)
	end
end

function PageClass:AddSection(name)
	if not self.DefaultTab then
		self.DefaultTab = self:_newTab("Default", true)
	end
	return self.DefaultTab:AddSection(name)
end

function TabClass:_updateCount()
	if self.Button and self.ShowCount then
		self.Button.Text = string.format("%s (%d)", self.Name, #self.Items)
	end
end

function TabClass:SetName(name)
	self.Name = name
	self:_updateCount()
	if self.Button and not self.ShowCount then
		self.Button.Text = name
	end
end

function TabClass:Remove()
	local page = self.Page
	local idx = table.find(page.Tabs, self)
	if idx then
		table.remove(page.Tabs, idx)
	end
	for _, item in ipairs(self.Items) do
		local pi = table.find(page.Items, item)
		if pi then
			table.remove(page.Items, pi)
		end
	end
	if self.Button then
		self.Button:Destroy()
	end
	self.Frame:Destroy()
	if page.CurrentTab == self then
		page.CurrentTab = nil
		if page.Tabs[1] then
			page:SelectTab(page.Tabs[1], true)
		end
	end
end

function TabClass:AddSection(name)
	local sec = setmetatable({
		Tab = self,
		Page = self.Page,
		Window = self.Page.Window,
		Name = name or "",
		Items = {},
	}, SectionClass)

	sec.Frame = create("Frame", {
		Name = name or "Section",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = #self.Sections + 1,
		Parent = self.Frame,
	}, { list(Enum.FillDirection.Vertical, 10) })

	sec.Label = newLabel({
		Size = UDim2.new(1, 0, 0, 14),
		Text = string.upper(name or ""),
		TextSize = 9,
		Tc = "Dim",
		Font = FONT_MED,
		LayoutOrder = 1,
		Visible = (name ~= nil and name ~= ""),
		Parent = sec.Frame,
	})

	sec.Card = create("Frame", {
		Name = "Card",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Bg = "Card",
		LayoutOrder = 2,
		Parent = sec.Frame,
	}, { corner(14), stroke("Stroke"), padding(6, 6, 6, 6), list(Enum.FillDirection.Vertical, 0) })

	table.insert(self.Sections, sec)
	return sec
end

function SectionClass:SetName(name)
	self.Name = name
	self.Label.Text = string.upper(name)
	self.Label.Visible = name ~= ""
end

function SectionClass:Remove()
	local tab = self.Tab
	local idx = table.find(tab.Sections, self)
	if idx then
		table.remove(tab.Sections, idx)
	end
	for _, item in ipairs(self.Items) do
		local pi = table.find(self.Page.Items, item)
		if pi then
			table.remove(self.Page.Items, pi)
		end
		local ti = table.find(tab.Items, item)
		if ti then
			table.remove(tab.Items, ti)
		end
	end
	tab:_updateCount()
	self.Frame:Destroy()
end

function ItemClass:Matches(q)
	local hay = (self.Name .. " " .. self.Desc .. " " .. self.Id):lower()
	return hay:find(q, 1, true) ~= nil
end

function ItemClass:_layout()
	local sub = (self.Desc ~= "") and self.Desc or self.Id
	local two = sub ~= ""
	self.BaseH = two and 68 or 54
	self.Top.Size = UDim2.new(1, 0, 0, self.BaseH)
	local x = self.Indent
	self.NameLabel.Position = two and UDim2.fromOffset(x, 15) or UDim2.new(0, x, 0.5, -9)
	self.DescLabel.Visible = two
	self.DescLabel.Text = sub
	self.DescLabel.Position = UDim2.fromOffset(x, 35)
	self.Row.Size = UDim2.new(1, 0, 0, self.BaseH + self.Extra)
	if self.OnLayout then
		self.OnLayout()
	end
end

function ItemClass:SetExtra(h, animate)
	self.Extra = h
	local size = UDim2.new(1, 0, 0, self.BaseH + h)
	if animate then
		tween(self.Row, 0.35, { Size = size })
	else
		self.Row.Size = size
	end
end

function ItemClass:SetName(text)
	self.Name = text
	self.NameLabel.Text = text
	self.Row.Name = text
end

function ItemClass:SetDescription(text)
	self.Desc = text or ""
	self:_layout()
end

function ItemClass:SetVisible(v)
	self.Row.Visible = v
end

function ItemClass:Remove()
	local sec = self.Section
	local function drop(t)
		local i = table.find(t, self)
		if i then
			table.remove(t, i)
		end
	end
	drop(sec.Items)
	drop(sec.Page.Items)
	drop(sec.Tab.Items)
	sec.Tab:_updateCount()
	self.Row:Destroy()
end
ItemClass.Destroy = ItemClass.Remove

function SectionClass:_makeRow(opts)
	opts = opts or {}
	local item = setmetatable({
		Section = self,
		Page = self.Page,
		Tab = self.Tab,
		Name = opts.Name or "",
		Desc = opts.Description or "",
		Id = opts.Id or "",
		Indent = opts.Indent or 18,
		Extra = 0,
		BaseH = 54,
	}, ItemClass)

	item.Row = create("Frame", {
		Name = opts.Name or "Row",
		Size = UDim2.new(1, 0, 0, 54),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		LayoutOrder = #self.Items + 1,
		Parent = self.Card,
	}, { corner(10) })
	item.Top = create("Frame", {
		Size = UDim2.new(1, 0, 0, 54),
		BackgroundTransparency = 1,
		Parent = item.Row,
	})
	item.NameLabel = newLabel({
		Size = opts.Wide and UDim2.new(1, -(item.Indent + 16), 0, 18) or UDim2.new(0.5, -item.Indent, 0, 18),
		Text = item.Name,
		Font = FONT_MED,
		TextSize = 13,
		Tc = opts.Muted and "Muted" or "Text",
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = item.Top,
	})
	item.DescLabel = newLabel({
		Size = UDim2.new(0.5, -item.Indent, 0, 14),
		Text = "",
		Tc = "Muted",
		TextSize = 10,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = item.Top,
	})
	item.Controls = create("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -16, 0.5, 0),
		Size = UDim2.new(0, 0, 0, 30),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		Parent = item.Top,
	}, { list(Enum.FillDirection.Horizontal, 12, Enum.VerticalAlignment.Center) })

	item.Row.MouseEnter:Connect(function()
		if item.Row.BackgroundColor3 == Color3.new(1, 1, 1) then
			tween(item.Row, 0.15, { BackgroundTransparency = 0.975 })
		end
	end)
	item.Row.MouseLeave:Connect(function()
		if item.Row.BackgroundColor3 == Color3.new(1, 1, 1) then
			tween(item.Row, 0.2, { BackgroundTransparency = 1 })
		end
	end)

	table.insert(self.Items, item)
	table.insert(self.Page.Items, item)
	table.insert(self.Tab.Items, item)
	self.Tab:_updateCount()
	item:_layout()
	return item
end

function SectionClass:AddService(opts)
	opts = opts or {}
	opts.Indent = 46
	local item = self:_makeRow(opts)
	item.Running = opts.Running and true or false

	local dot = create("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 20, 0.5, 0),
		Size = UDim2.fromOffset(8, 8),
		Parent = item.Top,
	}, { corner(4) })
	bind(dot, function()
		dot.BackgroundColor3 = item.Running and Theme.Accent or Theme.Dot
	end)

	local notePill
	local function setNote(text, color)
		if notePill then
			notePill:Destroy()
			notePill = nil
		end
		if text and text ~= "" then
			notePill = makeNote(item.Controls, text, color)
		end
	end
	setNote(opts.Note, opts.NoteColor)

	local play = create("TextButton", {
		Size = UDim2.fromOffset(28, 28),
		Bg = "Input",
		Text = "",
		AutoButtonColor = false,
		LayoutOrder = 2,
		Parent = item.Controls,
	}, { corner(8), stroke("Stroke") })
	local playIcon = newIcon(play, { "play", "▶" }, 12, UDim2.fromScale(0.5, 0.5), Vector2.new(0.5, 0.5))
	local function paintPlay()
		playIcon:SetIcon(item.Running and { "square", "■" } or { "play", "▶" })
		playIcon:SetColor(item.Running and Theme.Accent or Theme.Muted)
		play.BackgroundColor3 = item.Running and Theme.Active or Theme.Input
	end
	paintPlay()
	play.MouseEnter:Connect(function()
		playIcon:SetColor(Theme.Accent, true)
	end)
	play.MouseLeave:Connect(function()
		playIcon:SetColor(item.Running and Theme.Accent or Theme.Muted, true)
	end)
	pressable(play, 0.85)
	function item.SetRunning(state)
		item.Running = state and true or false
		tween(dot, 0.3, { BackgroundColor3 = item.Running and Theme.Accent or Theme.Dot })
		paintPlay()
		if item.Running then
			setNote(opts.RunningNote or "Running", opts.RunningNoteColor or "Green")
		else
			setNote(opts.IdleNote or opts.Note or "Idle", opts.IdleNoteColor or opts.NoteColor or "Gray")
		end
	end
	play.MouseButton1Click:Connect(function()
		item.SetRunning(not item.Running)
		if opts.OnRun then
			task.spawn(opts.OnRun, item.Running)
		end
	end)

	local seg = makeSegmented(item.Controls, opts.Options or { "Auto", "Manual", "Off" }, opts.Default or "Manual", opts.Callback, 214)
	seg.Frame.LayoutOrder = 3

	item.Set = seg.Set
	item.Get = seg.Get
	item.SetOptions = seg.SetOptions
	item.SetNote = setNote
	if opts.Flag then
		item.Flag = opts.Flag
		item.ConfigType = "service"
		self.Window:_registerFlag(item)
	end
	return item
end

function SectionClass:AddSegmented(opts)
	opts = opts or {}
	local item = self:_makeRow(opts)
	local seg = makeSegmented(item.Controls, opts.Options or { "Auto", "Manual", "Off" }, opts.Default, opts.Callback, opts.Width or 214)
	item.Set = seg.Set
	item.Get = seg.Get
	item.SetOptions = seg.SetOptions
	if opts.Flag then
		item.Flag = opts.Flag
		item.ConfigType = "value"
		self.Window:_registerFlag(item)
	end
	return item
end

function SectionClass:AddToggle(opts)
	opts = opts or {}
	local item = self:_makeRow(opts)
	item._dependents = {}
	item._isToggle = true
	item.Row.Visible = true
	item._depHidden = false

	local function updateDeps(on)
		on = on and true or false
		for _, dep in ipairs(item._dependents) do
			if type(dep) == "table" and dep.Row and not dep._isToggle then
				dep._depHidden = not on
				local row = dep.Row
				local targetH = (dep.BaseH or 54) + (dep.Extra or 0)
				if on then
					row.Visible = true
					row.ClipsDescendants = true
					local sc = row:FindFirstChild("_DepScale")
					if not sc then
						sc = Instance.new("UIScale")
						sc.Name = "_DepScale"
						sc.Parent = row
					end
					sc.Scale = 0.92
					row.Size = UDim2.new(1, 0, 0, 0)
					tween(row, 0.28, { Size = UDim2.new(1, 0, 0, targetH) }, Enum.EasingStyle.Quint)
					tween(sc, 0.32, { Scale = 1 }, Enum.EasingStyle.Quint)
				else
					local sc = row:FindFirstChild("_DepScale")
					if sc then
						tween(sc, 0.18, { Scale = 0.94 })
					end
					local tw = tween(row, 0.2, { Size = UDim2.new(1, 0, 0, 0) }, Enum.EasingStyle.Quad)
					task.delay(0.2, function()
						if dep._depHidden and row.Parent then
							row.Visible = false
							row.Size = UDim2.new(1, 0, 0, targetH)
							if sc then sc.Scale = 1 end
						end
					end)
				end
			end
		end
	end

	local userCb = opts.Callback
	local sw = makeSwitch(item.Controls, opts.Default, function(v)
		updateDeps(v)
		if userCb then
			task.spawn(userCb, v)
		end
	end)

	function item.Set(v, silent)
		local nv = v and true or false
		sw.Set(nv, true)
		updateDeps(nv)
		if not silent and userCb then
			task.spawn(userCb, nv)
		end
	end
	function item.Get()
		return sw.Get()
	end

	function item.Bind(...)
		local args = { ... }
		for i = 1, #args do
			local dep = args[i]
			if type(dep) == "table" and dep.Row and dep ~= item then
				table.insert(item._dependents, dep)
			end
		end
		updateDeps(sw.Get())
		return item
	end

	if opts.Flag then
		item.Flag = opts.Flag
		item.ConfigType = "bool"
		self.Window:_registerFlag(item)
	end
	return item
end

function SectionClass:AddButton(opts)
	opts = opts or {}
	local item = self:_makeRow(opts)
	local b = create("TextButton", {
		Size = UDim2.new(0, 0, 0, 30),
		AutomaticSize = Enum.AutomaticSize.X,
		Bg = "Input",
		Text = opts.Text or "Run",
		Font = FONT_MED,
		TextSize = 11,
		Tc = "Text",
		AutoButtonColor = false,
		Parent = item.Controls,
	}, { corner(8), stroke("Stroke"), padding(16, 0, 16, 0) })
	pressable(b, 0.94)
	b.MouseEnter:Connect(function()
		tween(b, 0.15, { BackgroundColor3 = Theme.Active })
	end)
	b.MouseLeave:Connect(function()
		tween(b, 0.2, { BackgroundColor3 = Theme.Input })
	end)
	b.MouseButton1Click:Connect(function()
		if opts.Callback then
			task.spawn(opts.Callback)
		end
	end)
	item.Button = b
	function item.SetText(t)
		b.Text = t
	end
	return item
end

function SectionClass:AddLabel(text)
	local item = self:_makeRow({ Name = text or "", Muted = true, Wide = true })
	function item.Set(t)
		item:SetName(t)
	end
	return item
end

function SectionClass:AddParagraph(opts)
	opts = opts or {}
	local item = setmetatable({
		Section = self,
		Page = self.Page,
		Tab = self.Tab,
		Name = opts.Title or "",
		Desc = opts.Content or "",
		Id = "",
	}, ItemClass)
	item.Row = create("Frame", {
		Name = opts.Title or "Paragraph",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 1,
		LayoutOrder = #self.Items + 1,
		Parent = self.Card,
	}, { corner(10), padding(18, 14, 18, 14), list(Enum.FillDirection.Vertical, 4) })
	item.NameLabel = newLabel({
		Size = UDim2.new(1, 0, 0, 18),
		Text = item.Name,
		Font = FONT_MED,
		TextSize = 13,
		TextTruncate = Enum.TextTruncate.AtEnd,
		LayoutOrder = 1,
		Parent = item.Row,
	})
	item.DescLabel = newLabel({
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Text = item.Desc,
		Tc = "Muted",
		TextSize = 11,
		TextWrapped = true,
		TextYAlignment = Enum.TextYAlignment.Top,
		LayoutOrder = 2,
		Parent = item.Row,
	})
	function item._layout()
		item.NameLabel.Text = item.Name
		item.DescLabel.Text = item.Desc
	end
	table.insert(self.Items, item)
	table.insert(self.Page.Items, item)
	table.insert(self.Tab.Items, item)
	self.Tab:_updateCount()
	function item.Set(t)
		item.Desc = t
		item.DescLabel.Text = t
	end
	return item
end

function SectionClass:AddSlider(opts)
	opts = opts or {}
	local item = self:_makeRow(opts)
	local min, max = opts.Min or 0, opts.Max or 100
	local step = opts.Step or 1
	local suffix = opts.Suffix or ""
	local decimals = 0
	local stepText = tostring(step)
	local dot = stepText:find("%.")
	if dot then
		decimals = #stepText - dot
	end
	local value = min
	local conns = self.Window.Connections

	local holder = create("Frame", {
		Size = UDim2.fromOffset(270, 30),
		BackgroundTransparency = 1,
		Parent = item.Controls,
	})
	local track = create("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.new(1, -72, 0, 6),
		Bg = "Input",
		Parent = holder,
	}, { corner(3), stroke("Stroke") })
	local fill = create("Frame", { Size = UDim2.fromScale(0, 1), Bg = "Accent", Parent = track }, { corner(3) })
	local knob = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.fromOffset(14, 14),
		BackgroundColor3 = Color3.new(1, 1, 1),
		ZIndex = 2,
		Parent = track,
	}, { corner(7) })
	local knobScale = create("UIScale", { Parent = knob })
	local box = create("TextBox", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.fromOffset(60, 26),
		Bg = "Input",
		Text = "",
		TextSize = 11,
		Font = FONT,
		Tc = "Text",
		ClearTextOnFocus = false,
		Parent = holder,
	}, { corner(7), stroke("Stroke") })
	local hit = create("TextButton", {
		Size = UDim2.new(1, -72, 1, 0),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		ZIndex = 3,
		Parent = holder,
	})

	local function snap(v)
		v = math.clamp(v, min, max)
		v = math.floor((v - min) / step + 0.5) * step + min
		local mult = 10 ^ decimals
		v = math.floor(v * mult + 0.5) / mult
		return math.clamp(v, min, max)
	end
	local function render(animate)
		local rel = (max == min) and 0 or (value - min) / (max - min)
		local t = animate and 0.12 or 0
		if animate then
			tween(fill, t, { Size = UDim2.fromScale(rel, 1) })
			tween(knob, t, { Position = UDim2.fromScale(rel, 0.5) })
		else
			fill.Size = UDim2.fromScale(rel, 1)
			knob.Position = UDim2.fromScale(rel, 0.5)
		end
		box.Text = tostring(value) .. suffix
	end
	local function setValue(v, silent, animate)
		local nv = snap(v)
		local changed = nv ~= value
		value = nv
		render(animate)
		if changed and not silent and opts.Callback then
			task.spawn(opts.Callback, value)
		end
	end

	trackDrag(conns, hit, function(pos)
		local rel = math.clamp((pos.X - hit.AbsolutePosition.X) / math.max(hit.AbsoluteSize.X, 1), 0, 1)
		setValue(min + rel * (max - min), false, true)
	end)
	hit.MouseButton1Down:Connect(function()
		tween(knobScale, 0.15, { Scale = 1.3 }, Enum.EasingStyle.Back)
	end)
	local function relaxKnob()
		tween(knobScale, 0.2, { Scale = 1 })
	end
	hit.MouseButton1Up:Connect(relaxKnob)
	table.insert(
		conns,
		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				relaxKnob()
			end
		end)
	)
	box.FocusLost:Connect(function()
		local n = tonumber((box.Text:gsub("[^%d%.%-]", "")))
		if n then
			setValue(n, false, true)
		else
			render(false)
		end
	end)

	value = snap(opts.Default or min)
	render(false)
	function item.Set(v, silent)
		setValue(v, silent, true)
	end
	function item.Get()
		return value
	end
	function item.SetRange(newMin, newMax)
		min, max = newMin, newMax
		setValue(value, true, true)
	end
	if opts.Flag then
		item.Flag = opts.Flag
		item.ConfigType = "number"
		self.Window:_registerFlag(item)
	end
	return item
end

function SectionClass:AddDropdown(opts)
	opts = opts or {}
	local item = self:_makeRow(opts)
	local multi = opts.Multi == true
	local searchable = opts.Searchable == true or (opts.Options and #opts.Options > 8)
	local options = opts.Options or {}
	local current = nil
	local selected = {}
	local open = false
	local filterQ = ""
	local ROW_H = 30
	local SEARCH_H = searchable and 34 or 0

	local btn = create("TextButton", {
		Size = UDim2.fromOffset(opts.Width or 210, 30),
		Bg = "Input",
		Text = "",
		AutoButtonColor = false,
		Parent = item.Controls,
	}, { corner(8), stroke("Stroke") })
	local shown = newLabel({
		Position = UDim2.fromOffset(12, 0),
		Size = UDim2.new(1, -36, 1, 0),
		Text = "",
		TextSize = 12,
		Font = FONT,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = btn,
	})
	local chevron = newIcon(btn, { "chevron-down", "▾" }, 14, UDim2.new(1, -10, 0.5, 0), Vector2.new(1, 0.5), "Muted")

	local panel = create("Frame", {
		Position = UDim2.fromOffset(16, 0),
		Size = UDim2.new(1, -32, 0, 0),
		Bg = "Card",
		ClipsDescendants = true,
		Visible = false,
		Parent = item.Row,
	}, { corner(10), stroke("Stroke") })

	local searchBox
	if searchable then
		local searchHolder = create("Frame", {
			Size = UDim2.new(1, -8, 0, 28),
			Position = UDim2.fromOffset(4, 4),
			Bg = "Input",
			Parent = panel,
		}, { corner(6), stroke("Stroke") })
		newIcon(searchHolder, { "search", "⌕" }, 13, UDim2.new(0, 8, 0.5, 0), Vector2.new(0, 0.5), "Muted")
		searchBox = create("TextBox", {
			Position = UDim2.fromOffset(28, 0),
			Size = UDim2.new(1, -36, 1, 0),
			BackgroundTransparency = 1,
			Text = "",
			PlaceholderText = "Search…",
			Pc = "Muted",
			Tc = "Text",
			Font = FONT,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			ClearTextOnFocus = false,
			Parent = searchHolder,
		})
	end

	local listScroll = create("ScrollingFrame", {
		Position = UDim2.fromOffset(0, SEARCH_H > 0 and (SEARCH_H + 2) or 0),
		Size = UDim2.new(1, 0, 1, -(SEARCH_H > 0 and (SEARCH_H + 2) or 0)),
		BackgroundTransparency = 1,
		ScrollBarThickness = 3,
		Sc = "StrokeLight",
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = panel,
	}, { padding(4, 4, 4, 4), list(Enum.FillDirection.Vertical, 1) })

	local function filteredOptions()
		if filterQ == "" then
			return options
		end
		local out = {}
		local q = filterQ:lower()
		for _, o in ipairs(options) do
			if tostring(o):lower():find(q, 1, true) then
				out[#out + 1] = o
			end
		end
		return out
	end

	local function listHeight()
		local n = #filteredOptions()
		return math.min(math.max(n, 1), 6) * ROW_H + 8 + SEARCH_H
	end
	local function placePanel()
		panel.Position = UDim2.fromOffset(16, item.BaseH - 2)
		panel.Size = UDim2.new(1, -32, 0, listHeight())
		listScroll.Position = UDim2.fromOffset(0, SEARCH_H > 0 and (SEARCH_H + 2) or 0)
		listScroll.Size = UDim2.new(1, 0, 1, -(SEARCH_H > 0 and (SEARCH_H + 2) or 0))
	end
	item.OnLayout = placePanel

	local function selectedArray()
		local arr = {}
		for _, o in ipairs(options) do
			if selected[o] then
				arr[#arr + 1] = o
			end
		end
		return arr
	end
	local function display()
		if multi then
			local arr = selectedArray()
			if #arr == 0 then
				shown.Text = opts.Placeholder or "None"
				shown.TextColor3 = Theme.Muted
			else
				shown.Text = table.concat(arr, ", ")
				shown.TextColor3 = Theme.Text
			end
		else
			if current ~= nil then
				shown.Text = tostring(current)
				shown.TextColor3 = Theme.Text
			else
				shown.Text = opts.Placeholder or "Select"
				shown.TextColor3 = Theme.Muted
			end
		end
	end

	local optionButtons = {}
	local function paintOptions(animate)
		for o, ob in pairs(optionButtons) do
			local on = multi and selected[o] or (current == o)
			local tcol = on and Theme.Text or Theme.Muted
			if animate then
				tween(ob.Btn, 0.15, { BackgroundTransparency = on and 0 or 1 })
				tween(ob.Label, 0.15, { TextColor3 = tcol })
			else
				ob.Btn.BackgroundTransparency = on and 0 or 1
				ob.Label.TextColor3 = tcol
			end
			ob.Check:SetShown(on and true or false)
		end
	end

	local function fire()
		if opts.Callback then
			if multi then
				task.spawn(opts.Callback, selectedArray())
			else
				task.spawn(opts.Callback, current)
			end
		end
	end

	local function setOpen(v)
		open = v
		if v then
			placePanel()
			panel.Visible = true
			item:SetExtra(listHeight() + 10, true)
		else
			panel.Visible = false
			panel.Size = UDim2.new(1, -32, 0, 0)
			item:SetExtra(0, true)
		end
		tween(chevron.Holder, 0.3, { Rotation = v and 180 or 0 })
		if v and searchBox then
			task.defer(function()
				searchBox:CaptureFocus()
			end)
		end
	end

	local function build()
		for _, ob in pairs(optionButtons) do
			ob.Btn:Destroy()
		end
		optionButtons = {}
		local filtered = filteredOptions()
		if #filtered == 0 then
			newLabel({
				Size = UDim2.new(1, 0, 0, ROW_H),
				Text = "No results",
				Tc = "Muted",
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Center,
				Parent = listScroll,
			})
		end
		for i, o in ipairs(filtered) do
			local ob = create("TextButton", {
				Size = UDim2.new(1, 0, 0, ROW_H),
				Bg = "Active",
				BackgroundTransparency = 1,
				Text = "",
				AutoButtonColor = false,
				LayoutOrder = i,
				Parent = listScroll,
			}, { corner(6) })
			local lbl = newLabel({
				Position = UDim2.fromOffset(10, 0),
				Size = UDim2.new(1, -36, 1, 0),
				Text = tostring(o),
				TextSize = 12,
				Font = FONT,
				Tc = "Muted",
				TextTruncate = Enum.TextTruncate.AtEnd,
				Parent = ob,
			})
			local check = newIcon(ob, { "check", "✓" }, 13, UDim2.new(1, -10, 0.5, 0), Vector2.new(1, 0.5), "Accent")
			optionButtons[o] = { Btn = ob, Label = lbl, Check = check }
			ob.MouseEnter:Connect(function()
				if not (multi and selected[o] or current == o) then
					tween(ob, 0.12, { BackgroundTransparency = 0.5 })
				end
			end)
			ob.MouseLeave:Connect(function()
				if not (multi and selected[o] or current == o) then
					tween(ob, 0.15, { BackgroundTransparency = 1 })
				end
			end)
			ob.MouseButton1Click:Connect(function()
				if multi then
					selected[o] = not selected[o] or nil
					display()
					paintOptions(true)
					fire()
				else
					current = o
					display()
					paintOptions(true)
					fire()
					setOpen(false)
				end
			end)
		end
		paintOptions(false)
		if open then
			placePanel()
			item:SetExtra(listHeight() + 10, true)
		end
	end

	if searchBox then
		searchBox:GetPropertyChangedSignal("Text"):Connect(function()
			filterQ = searchBox.Text
			build()
		end)
	end

	btn.MouseButton1Click:Connect(function()
		setOpen(not open)
	end)

	if multi then
		for _, o in ipairs(opts.Default or {}) do
			selected[o] = true
		end
	else
		current = opts.Default
	end
	build()
	display()

	function item.Set(v, silent)
		if multi then
			selected = {}
			for _, o in ipairs(v or {}) do
				selected[o] = true
			end
		else
			current = v
		end
		display()
		paintOptions(true)
		if not silent then
			fire()
		end
	end
	function item.Get()
		if multi then
			return selectedArray()
		end
		return current
	end
	function item.SetOptions(newOptions)
		options = newOptions
		if not multi and current ~= nil and not table.find(options, current) then
			current = nil
		end
		build()
		display()
	end
	function item.Open()
		setOpen(true)
	end
	function item.Close()
		setOpen(false)
	end
	if opts.Flag then
		item.Flag = opts.Flag
		item.ConfigType = multi and "multi" or "value"
		self.Window:_registerFlag(item)
	end
	return item
end

function SectionClass:AddPlayerDropdown(opts)
	opts = opts or {}
	local item = self:_makeRow(opts)
	local multi = opts.Multi == true
	local selected = {}
	local current = nil
	local open = false
	local filterQ = ""
	local ROW_H = 34
	local SEARCH_H = 34
	local playerConns = {}

	local btn = create("TextButton", {
		Size = UDim2.fromOffset(opts.Width or 220, 30),
		Bg = "Input",
		Text = "",
		AutoButtonColor = false,
		Parent = item.Controls,
	}, { corner(8), stroke("Stroke") })
	local shown = newLabel({
		Position = UDim2.fromOffset(12, 0),
		Size = UDim2.new(1, -36, 1, 0),
		Text = opts.Placeholder or "Select player",
		TextSize = 12,
		Font = FONT,
		Tc = "Muted",
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = btn,
	})
	local chevron = newIcon(btn, { "chevron-down", "▾" }, 14, UDim2.new(1, -10, 0.5, 0), Vector2.new(1, 0.5), "Muted")

	local panel = create("Frame", {
		Position = UDim2.fromOffset(16, 0),
		Size = UDim2.new(1, -32, 0, 0),
		Bg = "Card",
		ClipsDescendants = true,
		Visible = false,
		Parent = item.Row,
	}, { corner(10), stroke("Stroke") })

	local searchHolder = create("Frame", {
		Size = UDim2.new(1, -8, 0, 28),
		Position = UDim2.fromOffset(4, 4),
		Bg = "Input",
		Parent = panel,
	}, { corner(6), stroke("Stroke") })
	newIcon(searchHolder, { "search", "⌕" }, 13, UDim2.new(0, 8, 0.5, 0), Vector2.new(0, 0.5), "Muted")
	local searchBox = create("TextBox", {
		Position = UDim2.fromOffset(28, 0),
		Size = UDim2.new(1, -36, 1, 0),
		BackgroundTransparency = 1,
		Text = "",
		PlaceholderText = "Search players…",
		Pc = "Muted",
		Tc = "Text",
		Font = FONT,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false,
		Parent = searchHolder,
	})

	local listScroll = create("ScrollingFrame", {
		Position = UDim2.fromOffset(0, SEARCH_H + 2),
		Size = UDim2.new(1, 0, 1, -(SEARCH_H + 2)),
		BackgroundTransparency = 1,
		ScrollBarThickness = 3,
		Sc = "StrokeLight",
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = panel,
	}, { padding(4, 4, 4, 4), list(Enum.FillDirection.Vertical, 1) })

	local function playerList()
		local list = {}
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= Players.LocalPlayer then
				local name = p.DisplayName ~= p.Name and (p.DisplayName .. " (@" .. p.Name .. ")") or p.Name
				if filterQ == "" or name:lower():find(filterQ:lower(), 1, true) or p.Name:lower():find(filterQ:lower(), 1, true) then
					list[#list + 1] = p
				end
			end
		end
		table.sort(list, function(a, b)
			return a.Name:lower() < b.Name:lower()
		end)
		return list
	end

	local function listHeight()
		local n = #playerList()
		return math.min(math.max(n, 1), 5) * ROW_H + 8 + SEARCH_H
	end
	local function placePanel()
		panel.Position = UDim2.fromOffset(16, item.BaseH - 2)
		panel.Size = UDim2.new(1, -32, 0, listHeight())
	end
	item.OnLayout = placePanel

	local function selectedArray()
		local arr = {}
		for p, v in pairs(selected) do
			if v and p.Parent then
				arr[#arr + 1] = p
			end
		end
		return arr
	end
	local function display()
		if multi then
			local arr = selectedArray()
			if #arr == 0 then
				shown.Text = opts.Placeholder or "Select players"
				shown.TextColor3 = Theme.Muted
			else
				local names = {}
				for _, p in ipairs(arr) do
					names[#names + 1] = p.Name
				end
				shown.Text = table.concat(names, ", ")
				shown.TextColor3 = Theme.Text
			end
		else
			if current and current.Parent then
				shown.Text = current.Name
				shown.TextColor3 = Theme.Text
			else
				current = nil
				shown.Text = opts.Placeholder or "Select player"
				shown.TextColor3 = Theme.Muted
			end
		end
	end

	local function fire()
		if opts.Callback then
			if multi then
				task.spawn(opts.Callback, selectedArray())
			else
				task.spawn(opts.Callback, current)
			end
		end
	end

	local function setOpen(v)
		open = v
		if v then
			placePanel()
			panel.Visible = true
			item:SetExtra(listHeight() + 10, true)
		else
			panel.Visible = false
			panel.Size = UDim2.new(1, -32, 0, 0)
			item:SetExtra(0, true)
		end
		tween(chevron.Holder, 0.3, { Rotation = v and 180 or 0 })
		if v then
			task.defer(function()
				searchBox:CaptureFocus()
			end)
		end
	end

	local function build()
		for _, c in ipairs(listScroll:GetChildren()) do
			if c:IsA("TextButton") or c:IsA("TextLabel") then
				c:Destroy()
			end
		end
		local plist = playerList()
		if #plist == 0 then
			newLabel({
				Size = UDim2.new(1, 0, 0, ROW_H),
				Text = filterQ ~= "" and "No players found" or "No other players",
				Tc = "Muted",
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Center,
				Parent = listScroll,
			})
		end
		for i, p in ipairs(plist) do
			local on = multi and selected[p] or (current == p)
			local row = create("TextButton", {
				Size = UDim2.new(1, 0, 0, ROW_H),
				Bg = "Active",
				BackgroundTransparency = on and 0 or 1,
				Text = "",
				AutoButtonColor = false,
				LayoutOrder = i,
				Parent = listScroll,
			}, { corner(6) })
			local av = create("Frame", {
				Size = UDim2.fromOffset(22, 22),
				Position = UDim2.fromOffset(8, 6),
				Bg = "Active",
				ClipsDescendants = true,
				Parent = row,
			}, { corner(11) })
			local avImg = create("ImageLabel", {
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Parent = av,
			}, { corner(11) })
			task.spawn(function()
				local ok, url = pcall(function()
					return Players:GetUserThumbnailAsync(p.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
				end)
				if ok and url and avImg.Parent then
					avImg.Image = url
				end
			end)
			local label = (p.DisplayName ~= p.Name) and (p.DisplayName .. "  @" .. p.Name) or p.Name
			newLabel({
				Position = UDim2.fromOffset(38, 0),
				Size = UDim2.new(1, -64, 1, 0),
				Text = label,
				TextSize = 12,
				Font = FONT,
				Tc = on and "Text" or "Muted",
				TextTruncate = Enum.TextTruncate.AtEnd,
				Parent = row,
			})
			local check = newIcon(row, { "check", "✓" }, 13, UDim2.new(1, -10, 0.5, 0), Vector2.new(1, 0.5), "Accent")
			check:SetShown(on)
			row.MouseEnter:Connect(function()
				if not on then
					tween(row, 0.12, { BackgroundTransparency = 0.5 })
				end
			end)
			row.MouseLeave:Connect(function()
				if not (multi and selected[p] or current == p) then
					tween(row, 0.15, { BackgroundTransparency = 1 })
				end
			end)
			row.MouseButton1Click:Connect(function()
				if multi then
					selected[p] = not selected[p] or nil
					display()
					build()
					fire()
				else
					current = p
					display()
					fire()
					setOpen(false)
				end
			end)
		end
		placePanel()
		if open then
			item:SetExtra(listHeight() + 10, true)
		end
	end

	searchBox:GetPropertyChangedSignal("Text"):Connect(function()
		filterQ = searchBox.Text
		build()
	end)
	btn.MouseButton1Click:Connect(function()
		setOpen(not open)
		if open then
			build()
		end
	end)

	table.insert(self.Window.Connections, Players.PlayerAdded:Connect(function()
		if open then
			build()
		end
		display()
	end))
	table.insert(self.Window.Connections, Players.PlayerRemoving:Connect(function(p)
		if selected[p] then
			selected[p] = nil
		end
		if current == p then
			current = nil
		end
		if open then
			build()
		end
		display()
	end))

	build()
	display()

	function item.Set(v, silent)
		if multi then
			selected = {}
			for _, p in ipairs(v or {}) do
				if typeof(p) == "Instance" and p:IsA("Player") then
					selected[p] = true
				end
			end
		else
			current = (typeof(v) == "Instance" and v:IsA("Player")) and v or nil
		end
		display()
		if open then
			build()
		end
		if not silent then
			fire()
		end
	end
	function item.Get()
		if multi then
			return selectedArray()
		end
		return current
	end
	function item.Open()
		setOpen(true)
		build()
	end
	function item.Close()
		setOpen(false)
	end
	if opts.Flag then
		item.Flag = opts.Flag
		item.ConfigType = multi and "players_multi" or "player"
		self.Window:_registerFlag(item)
	end
	return item
end

function SectionClass:AddKeybind(opts)
	opts = opts or {}
	local item = self:_makeRow(opts)
	local key = opts.Default
	local listening = false
	local conns = self.Window.Connections

	local btn = create("TextButton", {
		Size = UDim2.fromOffset(110, 30),
		Bg = "Input",
		Text = "",
		AutoButtonColor = false,
		Parent = item.Controls,
	}, { corner(8), stroke("Stroke") })
	local lbl = newLabel({
		Size = UDim2.fromScale(1, 1),
		Text = prettyKey(key),
		TextSize = 11,
		Font = FONT_MED,
		TextXAlignment = Enum.TextXAlignment.Center,
		Parent = btn,
	})
	pressable(btn, 0.95)

	local function render()
		lbl.Text = listening and "Press a key..." or prettyKey(key)
		tween(lbl, 0.15, { TextColor3 = listening and Theme.Accent or Theme.Text })
	end
	local function stopListening()
		listening = false
		Library.Listening = false
		render()
	end
	btn.MouseButton1Click:Connect(function()
		if listening then
			stopListening()
			return
		end
		listening = true
		Library.Listening = true
		render()
	end)
	table.insert(
		conns,
		UserInputService.InputBegan:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.Keyboard then
				return
			end
			if listening then
				if input.KeyCode == Enum.KeyCode.Escape then
					stopListening()
				elseif input.KeyCode == Enum.KeyCode.Backspace then
					key = nil
					stopListening()
					if opts.Callback then
						task.spawn(opts.Callback, nil)
					end
				else
					key = input.KeyCode
					task.defer(stopListening)
					if opts.Callback then
						task.spawn(opts.Callback, key)
					end
				end
				return
			end
			if Library.Listening or UserInputService:GetFocusedTextBox() then
				return
			end
			if key and input.KeyCode == key and opts.OnPress then
				task.spawn(opts.OnPress)
			end
		end)
	)
	function item.Set(k, silent)
		key = k
		render()
		if not silent and opts.Callback then
			task.spawn(opts.Callback, key)
		end
	end
	function item.Get()
		return key
	end
	if opts.Flag then
		item.Flag = opts.Flag
		item.ConfigType = "keybind"
		self.Window:_registerFlag(item)
	end
	return item
end

function SectionClass:AddInput(opts)
	opts = opts or {}
	local item = self:_makeRow(opts)
	local showSave = opts.SaveButton ~= false and not opts.Live
	local width = opts.Width or (showSave and 240 or 210)

	local holder = create("Frame", {
		Size = UDim2.fromOffset(width, 30),
		BackgroundTransparency = 1,
		Parent = item.Controls,
	}, { list(Enum.FillDirection.Horizontal, 6, Enum.VerticalAlignment.Center) })

	local frame = create("Frame", {
		Size = UDim2.new(1, showSave and -70 or 0, 1, 0),
		Bg = "Input",
		Parent = holder,
	}, { corner(8), stroke("Stroke") })
	local box = create("TextBox", {
		Position = UDim2.fromOffset(12, 0),
		Size = UDim2.new(1, -24, 1, 0),
		BackgroundTransparency = 1,
		Text = opts.Default or "",
		PlaceholderText = opts.Placeholder or "Type here",
		Pc = "Muted",
		Tc = "Text",
		Font = FONT,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false,
		Parent = frame,
	})
	local fstroke = frame:FindFirstChildOfClass("UIStroke")
	box.Focused:Connect(function()
		tween(fstroke, 0.2, { Color = Theme.Accent })
	end)
	box.FocusLost:Connect(function(enter)
		tween(fstroke, 0.2, { Color = Theme.Stroke })
		if opts.Callback and not opts.Live and not showSave then
			task.spawn(opts.Callback, box.Text, enter)
		end
	end)
	if opts.Live then
		box:GetPropertyChangedSignal("Text"):Connect(function()
			if opts.Callback then
				task.spawn(opts.Callback, box.Text)
			end
		end)
	end

	if showSave then
		local saveBtn = create("TextButton", {
			Size = UDim2.fromOffset(64, 30),
			Bg = "Active",
			Text = opts.SaveText or "Save",
			Font = FONT_MED,
			TextSize = 11,
			Tc = "Text",
			AutoButtonColor = false,
			Parent = holder,
		}, { corner(8), stroke("Stroke") })
		pressable(saveBtn, 0.94)
		local saveIdle = true
		saveBtn.MouseEnter:Connect(function()
			if saveIdle then
				tween(saveBtn, 0.15, { BackgroundColor3 = Theme.Accent })
			end
		end)
		saveBtn.MouseLeave:Connect(function()
			if saveIdle then
				tween(saveBtn, 0.2, { BackgroundColor3 = Theme.Active })
			end
		end)
		saveBtn.MouseButton1Click:Connect(function()
			if opts.Callback then
				task.spawn(opts.Callback, box.Text, true)
			end
			saveIdle = false
			saveBtn.Text = "Saved"
			tween(saveBtn, 0.15, { BackgroundColor3 = Theme.Accent })
			task.delay(1.2, function()
				if saveBtn.Parent then
					saveBtn.Text = opts.SaveText or "Save"
					tween(saveBtn, 0.25, { BackgroundColor3 = Theme.Active })
					saveIdle = true
				end
			end)
		end)
		item.SaveButton = saveBtn
	end

	function item.Set(t, silent)
		box.Text = t
		if not silent and opts.Callback then
			task.spawn(opts.Callback, t)
		end
	end
	function item.Get()
		return box.Text
	end
	if opts.Flag then
		item.Flag = opts.Flag
		item.ConfigType = "value"
		self.Window:_registerFlag(item)
	end
	return item
end

function SectionClass:AddColorPicker(opts)
	opts = opts or {}
	local item = self:_makeRow(opts)
	local conns = self.Window.Connections
	local color = opts.Default or Color3.fromRGB(255, 255, 255)
	local h, s, v = color:ToHSV()
	local open = false
	local PANEL_H = 248

	local swatch = create("TextButton", {
		Size = UDim2.fromOffset(36, 28),
		Text = "",
		AutoButtonColor = false,
		Parent = item.Controls,
	}, { corner(8), stroke("StrokeLight") })
	pressable(swatch, 0.92)

	local hexFrame = create("Frame", {
		Size = UDim2.fromOffset(92, 28),
		Bg = "Input",
		Parent = item.Controls,
	}, { corner(8), stroke("Stroke") })
	local hex = create("TextBox", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = "",
		Font = FONT,
		TextSize = 12,
		Tc = "Text",
		TextXAlignment = Enum.TextXAlignment.Center,
		ClearTextOnFocus = false,
		Parent = hexFrame,
	})
	local hexStroke = hexFrame:FindFirstChildOfClass("UIStroke")

	local panel = create("Frame", {
		Size = UDim2.new(1, -32, 0, 0),
		BackgroundTransparency = 1,
		Visible = false,
		ClipsDescendants = true,
		Parent = item.Row,
	})
	local function placePanel()
		panel.Position = UDim2.fromOffset(16, item.BaseH + 4)
	end
	item.OnLayout = placePanel

	local body = create("Frame", {
		Size = UDim2.new(1, 0, 0, PANEL_H),
		Bg = "Input",
		Parent = panel,
	}, { corner(12), stroke("Stroke"), padding(12, 12, 12, 12) })

	local sv = create("Frame", {
		Size = UDim2.new(1, -40, 0, 120),
		BackgroundColor3 = Color3.fromHSV(h, 1, 1),
		ClipsDescendants = true,
		Parent = body,
	}, { corner(8) })
	create("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1), Parent = sv }, {
		create("UIGradient", {
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(1, 1),
			}),
		}),
	})
	create("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), Parent = sv }, {
		create("UIGradient", {
			Rotation = 90,
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(1, 0),
			}),
		}),
	})
	local svCursor = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromOffset(16, 16),
		BackgroundTransparency = 1,
		ZIndex = 4,
		Parent = sv,
	}, {
		corner(8),
		create("UIStroke", { Color = Color3.new(1, 1, 1), Thickness = 2 }),
		create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(6, 6),
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 0.4,
			ZIndex = 5,
		}, { corner(3) }),
	})
	local svHit = create("TextButton", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		ZIndex = 6,
		Parent = sv,
	})

	local hueBar = create("Frame", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -12, 0, 12),
		Size = UDim2.fromOffset(22, 120),
		BackgroundColor3 = Color3.new(1, 1, 1),
		Parent = body,
	}, {
		corner(6),
		create("UIGradient", {
			Rotation = 90,
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
				ColorSequenceKeypoint.new(1 / 6, Color3.fromHSV(1 / 6, 1, 1)),
				ColorSequenceKeypoint.new(2 / 6, Color3.fromHSV(2 / 6, 1, 1)),
				ColorSequenceKeypoint.new(3 / 6, Color3.fromHSV(3 / 6, 1, 1)),
				ColorSequenceKeypoint.new(4 / 6, Color3.fromHSV(4 / 6, 1, 1)),
				ColorSequenceKeypoint.new(5 / 6, Color3.fromHSV(5 / 6, 1, 1)),
				ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1)),
			}),
		}),
	})
	local hueCursor = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0),
		Size = UDim2.new(1, 6, 0, 8),
		BackgroundColor3 = Color3.new(1, 1, 1),
		ZIndex = 4,
		Parent = hueBar,
	}, { corner(4), create("UIStroke", { Color = Color3.fromRGB(20, 20, 20), Thickness = 1 }) })
	local hueHit = create("TextButton", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		ZIndex = 5,
		Parent = hueBar,
	})

	local bottom = create("Frame", {
		Position = UDim2.fromOffset(12, 140),
		Size = UDim2.new(1, -24, 0, 36),
		BackgroundTransparency = 1,
		Parent = body,
	})
	local preview = create("Frame", {
		Size = UDim2.fromOffset(36, 36),
		Parent = bottom,
	}, { corner(8), stroke("StrokeLight") })
	local hexBig = create("TextBox", {
		Position = UDim2.fromOffset(44, 4),
		Size = UDim2.fromOffset(100, 28),
		Bg = "Card",
		Text = "",
		Font = FONT_MED,
		TextSize = 13,
		Tc = "Text",
		TextXAlignment = Enum.TextXAlignment.Center,
		ClearTextOnFocus = false,
		Parent = bottom,
	}, { corner(8), stroke("Stroke") })

	local function makeCh(label, x)
		local f = create("Frame", {
			Position = UDim2.fromOffset(x, 4),
			Size = UDim2.fromOffset(58, 28),
			Bg = "Card",
			Parent = bottom,
		}, { corner(8), stroke("Stroke") })
		newLabel({
			Position = UDim2.fromOffset(6, 0),
			Size = UDim2.fromOffset(10, 28),
			Text = label,
			TextSize = 10,
			Tc = "Muted",
			Font = FONT_MED,
			Parent = f,
		})
		local b = create("TextBox", {
			Position = UDim2.fromOffset(18, 0),
			Size = UDim2.new(1, -22, 1, 0),
			BackgroundTransparency = 1,
			Text = "0",
			Font = FONT,
			TextSize = 12,
			Tc = "Text",
			ClearTextOnFocus = false,
			Parent = f,
		})
		return b
	end
	local rBox = makeCh("R", 152)
	local gBox = makeCh("G", 216)
	local bBox = makeCh("B", 280)

	local function fire()
		if opts.Callback then
			task.spawn(opts.Callback, color)
		end
	end
	local function refresh(animate)
		color = Color3.fromHSV(h, s, v)
		sv.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
		svCursor.Position = UDim2.fromScale(s, 1 - v)
		hueCursor.Position = UDim2.fromScale(0.5, h)
		local r = math.floor(color.R * 255 + 0.5)
		local g = math.floor(color.G * 255 + 0.5)
		local b = math.floor(color.B * 255 + 0.5)
		rBox.Text = tostring(r)
		gBox.Text = tostring(g)
		bBox.Text = tostring(b)
		local hx = string.format("#%02X%02X%02X", r, g, b)
		hex.Text = hx
		hexBig.Text = hx
		if animate then
			tween(swatch, 0.12, { BackgroundColor3 = color })
			tween(preview, 0.12, { BackgroundColor3 = color })
		else
			swatch.BackgroundColor3 = color
			preview.BackgroundColor3 = color
		end
	end
	local function applyHex(str)
		local ok, c = pcall(function()
			return Color3.fromHex((str:gsub("#", "")))
		end)
		if ok and c then
			h, s, v = c:ToHSV()
			refresh(true)
			fire()
			return true
		end
		refresh(false)
		return false
	end
	local function applyRgb()
		local r = math.clamp(tonumber(rBox.Text) or 0, 0, 255)
		local g = math.clamp(tonumber(gBox.Text) or 0, 0, 255)
		local b = math.clamp(tonumber(bBox.Text) or 0, 0, 255)
		h, s, v = Color3.fromRGB(r, g, b):ToHSV()
		refresh(true)
		fire()
	end

	trackDrag(conns, svHit, function(pos)
		s = math.clamp((pos.X - sv.AbsolutePosition.X) / math.max(sv.AbsoluteSize.X, 1), 0, 1)
		v = 1 - math.clamp((pos.Y - sv.AbsolutePosition.Y) / math.max(sv.AbsoluteSize.Y, 1), 0, 1)
		refresh(true)
		fire()
	end)
	trackDrag(conns, hueHit, function(pos)
		h = math.clamp((pos.Y - hueBar.AbsolutePosition.Y) / math.max(hueBar.AbsoluteSize.Y, 1), 0, 0.999)
		refresh(true)
		fire()
	end)
	hex.Focused:Connect(function()
		tween(hexStroke, 0.2, { Color = Theme.Accent })
	end)
	hex.FocusLost:Connect(function()
		tween(hexStroke, 0.2, { Color = Theme.Stroke })
		applyHex(hex.Text)
	end)
	hexBig.FocusLost:Connect(function()
		applyHex(hexBig.Text)
	end)
	for _, box in ipairs({ rBox, gBox, bBox }) do
		box.FocusLost:Connect(applyRgb)
	end
	hex.FocusLost:Connect(function()
		applyHex(hex.Text)
	end)
	hexBig:GetPropertyChangedSignal("Text"):Connect(function() end)
	hexBig.FocusLost:Connect(function()
		applyHex(hexBig.Text)
	end)

	local presets = {
		Color3.fromRGB(255, 255, 255), Color3.fromRGB(0, 0, 0),
		Color3.fromRGB(239, 68, 68), Color3.fromRGB(249, 115, 22),
		Color3.fromRGB(234, 179, 8), Color3.fromRGB(34, 197, 94),
		Color3.fromRGB(56, 189, 248), Color3.fromRGB(99, 102, 241),
		Color3.fromRGB(168, 85, 247), Color3.fromRGB(244, 114, 182),
	}
	local chipRow = create("Frame", {
		Position = UDim2.fromOffset(12, 186),
		Size = UDim2.new(1, -24, 0, 22),
		BackgroundTransparency = 1,
		Parent = body,
	}, { list(Enum.FillDirection.Horizontal, 6) })
	for _, pc in ipairs(presets) do
		local chip = create("TextButton", {
			Size = UDim2.fromOffset(22, 22),
			BackgroundColor3 = pc,
			Text = "",
			AutoButtonColor = false,
			Parent = chipRow,
		}, { corner(6), stroke("StrokeLight") })
		chip.MouseButton1Click:Connect(function()
			h, s, v = pc:ToHSV()
			refresh(true)
			fire()
		end)
	end

	local function setOpen(v)
		open = v
		placePanel()
		if v then
			panel.Visible = true
			panel.Size = UDim2.new(1, -32, 0, PANEL_H + 8)
			item:SetExtra(PANEL_H + 16, true)
		else
			panel.Visible = false
			panel.Size = UDim2.new(1, -32, 0, 0)
			item:SetExtra(0, true)
		end
	end
	swatch.MouseButton1Click:Connect(function()
		setOpen(not open)
	end)
	hexFrame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			hex:CaptureFocus()
		end
	end)

	refresh(false)
	function item.Set(c, silent)
		h, s, v = c:ToHSV()
		refresh(true)
		if not silent then
			fire()
		end
	end
	function item.Get()
		return color
	end
	if opts.Flag then
		item.Flag = opts.Flag
		item.ConfigType = "color"
		self.Window:_registerFlag(item)
	end
	return item
end

function SectionClass:AddConfigManager(opts)
	opts = opts or {}
	local win = self.Window
	local item = setmetatable({
		Section = self,
		Page = self.Page,
		Tab = self.Tab,
		Name = "ConfigManager",
		Desc = "",
		Id = "",
	}, ItemClass)

	item.Row = create("Frame", {
		Name = "ConfigManager",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = #self.Items + 1,
		Parent = self.Card,
	}, { padding(10, 10, 10, 10), list(Enum.FillDirection.Vertical, 10) })

	local nameRow = create("Frame", {
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundTransparency = 1,
		Parent = item.Row,
	})
	local nameFrame = create("Frame", {
		Size = UDim2.new(1, -210, 1, 0),
		Bg = "Input",
		Parent = nameRow,
	}, { corner(10), stroke("Stroke") })
	newIcon(nameFrame, { "folder", "📁" }, 14, UDim2.fromOffset(12, 11), nil, "Muted")
	local nameBox = create("TextBox", {
		Position = UDim2.fromOffset(36, 0),
		Size = UDim2.new(1, -48, 1, 0),
		BackgroundTransparency = 1,
		Text = opts.Default or "default",
		PlaceholderText = "Config name",
		Pc = "Muted",
		Tc = "Text",
		Font = FONT,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false,
		Parent = nameFrame,
	})
	local btnHold = create("Frame", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 0),
		Size = UDim2.fromOffset(200, 36),
		BackgroundTransparency = 1,
		Parent = nameRow,
	}, { list(Enum.FillDirection.Horizontal, 6, Enum.VerticalAlignment.Center) })
	local saveBtn = create("TextButton", {
		Size = UDim2.fromOffset(96, 36),
		Bg = "Accent",
		Text = "Save",
		Font = FONT_MED,
		TextSize = 12,
		TextColor3 = Color3.new(1, 1, 1),
		AutoButtonColor = false,
		Parent = btnHold,
	}, { corner(10) })
	pressable(saveBtn, 0.95)
	saveBtn.MouseButton1Click:Connect(function()
		win:SaveConfig(nameBox.Text)
		item._refresh()
	end)
	local overBtn = create("TextButton", {
		Size = UDim2.fromOffset(98, 36),
		Bg = "Active",
		Text = "Overwrite",
		Font = FONT_MED,
		TextSize = 12,
		Tc = "Text",
		AutoButtonColor = false,
		Parent = btnHold,
	}, { corner(10), stroke("Stroke") })
	pressable(overBtn, 0.95)
	overBtn.MouseButton1Click:Connect(function()
		local n = nameBox.Text
		if n == "" then return end
		win:SaveConfig(n)
		item._refresh()
		win:Notify({ Title = "Config", Text = "Overwrote \"" .. n .. "\"", Type = "success", Duration = 2 })
	end)
	nameFrame.Size = UDim2.new(1, -210, 1, 0)

	local listFrame = create("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Bg = "Input",
		Parent = item.Row,
	}, { corner(10), stroke("Stroke"), padding(6, 6, 6, 6), list(Enum.FillDirection.Vertical, 4) })

	local emptyLbl = newLabel({
		Size = UDim2.new(1, 0, 0, 32),
		Text = "No configs yet — save one above",
		Tc = "Muted",
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Center,
		Parent = listFrame,
	})

	function item._refresh()
		for _, c in ipairs(listFrame:GetChildren()) do
			if c:IsA("TextButton") or (c:IsA("TextLabel") and c ~= emptyLbl) then
				c:Destroy()
			end
		end
		local names = win:GetConfigs()
		emptyLbl.Visible = #names == 0
		for i, name in ipairs(names) do
			local row = create("TextButton", {
				Size = UDim2.new(1, 0, 0, 40),
				Bg = "Card",
				BackgroundTransparency = 0,
				Text = "",
				AutoButtonColor = false,
				LayoutOrder = i,
				Parent = listFrame,
			}, { corner(8) })
			newIcon(row, { "file", "📄" }, 14, UDim2.fromOffset(12, 13), nil, "Muted")
			newLabel({
				Position = UDim2.fromOffset(36, 0),
				Size = UDim2.new(1, -150, 1, 0),
				Text = name,
				Font = FONT_MED,
				TextSize = 13,
				TextTruncate = Enum.TextTruncate.AtEnd,
				Parent = row,
			})
			local loadB = create("TextButton", {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -52, 0.5, 0),
				Size = UDim2.fromOffset(50, 26),
				BackgroundColor3 = Theme.Active,
				Text = "Load",
				Font = FONT_MED,
				TextSize = 11,
				TextColor3 = Theme.Text,
				AutoButtonColor = false,
				Parent = row,
			}, { corner(6), stroke("StrokeLight") })
			bind(loadB, function()
				loadB.BackgroundColor3 = Theme.Active
				loadB.TextColor3 = Theme.Text
			end)
			loadB.MouseEnter:Connect(function()
				tween(loadB, 0.15, { BackgroundColor3 = Theme.Accent, TextColor3 = Color3.new(1, 1, 1) })
			end)
			loadB.MouseLeave:Connect(function()
				tween(loadB, 0.2, { BackgroundColor3 = Theme.Active, TextColor3 = Theme.Text })
			end)
			loadB.MouseButton1Click:Connect(function()
				nameBox.Text = name
				win:LoadConfig(name)
			end)
			local delB = create("TextButton", {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -8, 0.5, 0),
				Size = UDim2.fromOffset(36, 26),
				Bg = "Input",
				Text = "",
				AutoButtonColor = false,
				Parent = row,
			}, { corner(6) })
			local delIcon = newIcon(delB, { "trash-2", "trash", "🗑" }, 14, UDim2.fromScale(0.5, 0.5), Vector2.new(0.5, 0.5), "Muted")
			delB.MouseEnter:Connect(function()
				delIcon:SetColor(Theme.Notes.Red.Text, true)
			end)
			delB.MouseLeave:Connect(function()
				delIcon:SetColor(Theme.Muted, true)
			end)
			delB.MouseButton1Click:Connect(function()
				win:DeleteConfig(name)
				item._refresh()
			end)
			row.MouseEnter:Connect(function()
				tween(row, 0.12, { BackgroundColor3 = Theme.Active })
			end)
			row.MouseLeave:Connect(function()
				tween(row, 0.15, { BackgroundColor3 = Theme.Card })
			end)
		end
	end

	item._refresh()
	table.insert(self.Items, item)
	table.insert(self.Page.Items, item)
	table.insert(self.Tab.Items, item)
	self.Tab:_updateCount()
	return item
end

local function ensureFolder(path)
	if type(isfolder) ~= "function" then
		return false
	end
	if not isfolder(path) then
		pcall(function()
			makefolder(path)
		end)
	end
	return isfolder(path)
end

local function encodeValue(item)
	local t = item.ConfigType
	local v = item.Get and item.Get()
	if t == "bool" or t == "number" or t == "value" then
		return v
	elseif t == "multi" then
		return v
	elseif t == "keybind" then
		return v and v.Name or nil
	elseif t == "color" then
		if typeof(v) == "Color3" then
			return {
				math.floor(v.R * 255 + 0.5),
				math.floor(v.G * 255 + 0.5),
				math.floor(v.B * 255 + 0.5),
			}
		end
	elseif t == "service" then
		return { Mode = item.Get and item.Get(), Running = item.Running }
	elseif t == "player" then
		return v and v.Name or nil
	elseif t == "players_multi" then
		local names = {}
		for _, pl in ipairs(v or {}) do
			names[#names + 1] = pl.Name
		end
		return names
	end
	return v
end

local function decodeValue(item, data)
	local t = item.ConfigType
	if data == nil then
		return
	end
	if t == "bool" or t == "number" or t == "value" or t == "multi" then
		item.Set(data, true)
	elseif t == "keybind" then
		if type(data) == "string" then
			local ok, key = pcall(function()
				return Enum.KeyCode[data]
			end)
			if ok and key then
				item.Set(key, true)
			end
		end
	elseif t == "color" then
		if type(data) == "table" and #data >= 3 then
			item.Set(Color3.fromRGB(data[1], data[2], data[3]), true)
		end
	elseif t == "service" then
		if type(data) == "table" then
			if data.Mode and item.Set then
				item.Set(data.Mode, true)
			end
			if data.Running ~= nil and item.SetRunning then
				item.SetRunning(data.Running)
			end
		end
	elseif t == "player" then
		if type(data) == "string" then
			local pl = Players:FindFirstChild(data)
			if pl then
				item.Set(pl, true)
			end
		end
	elseif t == "players_multi" then
		if type(data) == "table" then
			local list = {}
			for _, name in ipairs(data) do
				local pl = Players:FindFirstChild(name)
				if pl then
					list[#list + 1] = pl
				end
			end
			item.Set(list, true)
		end
	end
end

function WindowClass:_registerFlag(item)
	if item.Flag and item.Flag ~= "" then
		self.Flags[item.Flag] = item
	end
end

function WindowClass:SetConfigFolder(path)
	self.ConfigFolder = path or "ReduceUI/configs"
end

function Library:SetConfigFolder(path)
	Library.ConfigFolder = path or "ReduceUI/configs"
end

function WindowClass:GetConfigs()
	local folder = self.ConfigFolder
	local names = {}
	if type(listfiles) ~= "function" then
		return names
	end
	ensureFolder(folder)
	local ok, files = pcall(listfiles, folder)
	if not ok or type(files) ~= "table" then
		return names
	end
	for _, f in ipairs(files) do
		local name = f:match("([^/\\]+)%.json$") or f:match("([^/\\]+)$")
		if name then
			names[#names + 1] = name:gsub("%.json$", "")
		end
	end
	table.sort(names)
	return names
end

function WindowClass:SaveConfig(name)
	name = tostring(name or "default"):gsub("[^%w%-%_]", "")
	if name == "" then
		name = "default"
	end
	local folder = self.ConfigFolder
	ensureFolder(folder)
	local data = {
		__meta = {
			ToggleKey = self.ToggleKey and self.ToggleKey.Name or nil,
			SidebarKey = self.SidebarKey and self.SidebarKey.Name or nil,
			ThemeAccent = {
				math.floor(Theme.Accent.R * 255 + 0.5),
				math.floor(Theme.Accent.G * 255 + 0.5),
				math.floor(Theme.Accent.B * 255 + 0.5),
			},
		},
	}
	for flag, item in pairs(self.Flags) do
		local ok, val = pcall(encodeValue, item)
		if ok then
			data[flag] = val
		end
	end
	local json
	if type(HttpService) == "userdata" or game:GetService("HttpService") then
		local hs = game:GetService("HttpService")
		json = hs:JSONEncode(data)
	else
		json = "{}"
	end
	local path = folder .. "/" .. name .. ".json"
	if type(writefile) == "function" then
		local ok, err = pcall(writefile, path, json)
		if ok then
			self:Notify({ Title = "Config", Text = "Saved \"" .. name .. "\"", Type = "success", Duration = 2 })
			return true
		else
			self:Notify({ Title = "Config", Text = "Save failed: " .. tostring(err), Type = "error" })
			return false
		end
	else
		self:Notify({ Title = "Config", Text = "writefile not available", Type = "warn" })
		return false
	end
end

function WindowClass:LoadConfig(name)
	name = tostring(name or "default"):gsub("[^%w%-%_]", "")
	local path = self.ConfigFolder .. "/" .. name .. ".json"
	if type(readfile) ~= "function" then
		self:Notify({ Title = "Config", Text = "readfile not available", Type = "warn" })
		return false
	end
	local ok, raw = pcall(readfile, path)
	if not ok or type(raw) ~= "string" then
		self:Notify({ Title = "Config", Text = "Config \"" .. name .. "\" not found", Type = "error" })
		return false
	end
	local hs = game:GetService("HttpService")
	local ok2, data = pcall(function()
		return hs:JSONDecode(raw)
	end)
	if not ok2 or type(data) ~= "table" then
		self:Notify({ Title = "Config", Text = "Invalid config file", Type = "error" })
		return false
	end
	if type(data.__meta) == "table" then
		local m = data.__meta
		if type(m.ToggleKey) == "string" then
			local ok, key = pcall(function() return Enum.KeyCode[m.ToggleKey] end)
			if ok and key then self:SetToggleKey(key) end
		end
		if type(m.SidebarKey) == "string" then
			local ok, key = pcall(function() return Enum.KeyCode[m.SidebarKey] end)
			if ok and key then self:SetSidebarKey(key) end
		end
		if type(m.ThemeAccent) == "table" and #m.ThemeAccent >= 3 then
			Library:SetTheme({ Accent = Color3.fromRGB(m.ThemeAccent[1], m.ThemeAccent[2], m.ThemeAccent[3]) })
		end
	end
	for flag, val in pairs(data) do
		if flag ~= "__meta" then
			local item = self.Flags[flag]
			if item then
				pcall(decodeValue, item, val)
			end
		end
	end
	self:Notify({ Title = "Config", Text = "Loaded \"" .. name .. "\"", Type = "success", Duration = 2 })
	return true
end

function WindowClass:DeleteConfig(name)
	name = tostring(name or ""):gsub("[^%w%-%_]", "")
	local path = self.ConfigFolder .. "/" .. name .. ".json"
	if type(delfile) == "function" then
		pcall(delfile, path)
		self:Notify({ Title = "Config", Text = "Deleted \"" .. name .. "\"", Type = "info", Duration = 2 })
		return true
	end
	return false
end

--------------------------------------------------------------------------------
-- ReduceUI 2.1 additions
--
--   Elements   Section:AddList / AddCodeBlock / AddStats / AddProgress / AddStatus
--              Section:AddActions / AddDivider / AddTextArea
--   Window     Window:Confirm({Title, Text, ConfirmText, CancelText, Danger, OnConfirm, OnCancel})
--   Helpers    item.Set(x) AND item:Set(x) both work on every element (dual-call)
--              Library.SetClipboard(text), Library.Classes, Library.Version, Library.Features
--
--   AddList        {Title, Height=260, RowHeight=46, MaxRows=80, RightWidth=150, Empty, Icons,
--                   HeaderButtons={{Text, Callback}}, CountFormat(shown,total), OnSelect(entry,id)}
--                  entry = {Id, Title, Subtitle, Tag, TagColor, Right, RightColor, Icon}
--                  :SetItems(entries) :Select(id,silent) :GetSelected() :Clear() :SetCount(text)
--                  :SetEmptyText(text) :Count() :ScrollToTop()
--                  Rows are diffed by Id, so refreshing keeps scroll position and never flickers.
--   AddCodeBlock   {Title, Height=160, Wrap=true, PageSize=12000 (long text is paged with ‹ ›), Placeholder, Copy=true,
--                   WrapToggle=true, Buttons={{Text, Callback}}, OnCopy}
--                  :Set(text) :Get() :Append(text) :Clear()
--   AddStats       {Items={{Id, Name, Value, Note, NoteColor, Icon}}, Height=78}
--                  :Set(id, value, note, noteColor) :SetAll({id=value | {Value, Note, NoteColor}})
--   AddProgress    {Name, Description, Min, Max, Default, Width, Percent, Format(v,max), WarnAt, DangerAt}
--                  :Set(value, text) :Get() :SetRange(min,max)
--   AddStatus      {Name, Description, Id, State="ok|warn|error|off", Running, Note, NoteColor, Value}
--                  :SetState(s) :SetRunning(bool) :SetNote(text,color) :SetValue(text)
--   AddActions     {Buttons={{Text, Icon, Style="Default|Accent|Danger", Callback, Id}}, Height=34}
--                  :SetEnabled(indexOrId, bool) :SetText(indexOrId, text)
--   AddDivider     (text)
--   AddTextArea    {Name, Description, Height=96, Default, Placeholder, Live, ReadOnly, Flag, Callback}
--                  :Set(text, silent) :Get() :Append(text)
--------------------------------------------------------------------------------

Library.Version = "2.3.0"
Library.Features = {
	List = true,
	CodeBlock = true,
	Stats = true,
	Progress = true,
	Status = true,
	Actions = true,
	Divider = true,
	TextArea = true,
	Confirm = true,
	DualCall = true,
}
Library.Classes = {
	Window = WindowClass,
	Page = PageClass,
	Tab = TabClass,
	Section = SectionClass,
	Item = ItemClass,
}

do
	local FONT_MONO = Enum.Font.RobotoMono

	local function clipboard(text)
		text = tostring(text or "")
		local fn = nil
		if type(setclipboard) == "function" then
			fn = setclipboard
		elseif type(toclipboard) == "function" then
			fn = toclipboard
		end
		if not fn then
			return false
		end
		return (pcall(fn, text))
	end
	Library.SetClipboard = clipboard

	local function sanitize(s)
		return (tostring(s):gsub("%c", function(c)
			if c == "\n" or c == "\t" then
				return c
			end
			if c == "\r" then
				return ""
			end
			return "."
		end))
	end

	-- resolve "Green" / "Muted" / Color3 into a Color3
	local function resolveColor(key, fallback)
		if typeof(key) == "Color3" then
			return key
		end
		if type(key) == "string" then
			if Theme.Notes[key] then
				return Theme.Notes[key].Text
			end
			if Theme[key] and typeof(Theme[key]) == "Color3" then
				return Theme[key]
			end
		end
		return fallback or Theme.Muted
	end

	local function smallButton(parent, text, order)
		local b = create("TextButton", {
			Size = UDim2.new(0, 0, 0, 22),
			AutomaticSize = Enum.AutomaticSize.X,
			Bg = "Input",
			Text = text,
			Font = FONT_MED,
			TextSize = 10,
			Tc = "Muted",
			AutoButtonColor = false,
			LayoutOrder = order or 0,
			Parent = parent,
		}, { corner(6), stroke("Stroke"), padding(10, 0, 10, 0) })
		pressable(b, 0.94)
		b.MouseEnter:Connect(function()
			tween(b, 0.12, { BackgroundColor3 = Theme.Active, TextColor3 = Theme.Text })
		end)
		b.MouseLeave:Connect(function()
			tween(b, 0.18, { BackgroundColor3 = Theme.Input, TextColor3 = Theme.Muted })
		end)
		return b
	end

	local function header(parent, title, order)
		local h = create("Frame", {
			Size = UDim2.new(1, 0, 0, 22),
			BackgroundTransparency = 1,
			LayoutOrder = order or 1,
			Parent = parent,
		})
		local t = newLabel({
			Size = UDim2.new(0.5, 0, 1, 0),
			Text = title or "",
			Font = FONT_MED,
			TextSize = 11,
			Tc = "Muted",
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = h,
		})
		local right = create("Frame", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, 0, 0.5, 0),
			Size = UDim2.new(0, 0, 1, 0),
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundTransparency = 1,
			Parent = h,
		}, { list(Enum.FillDirection.Horizontal, 6, Enum.VerticalAlignment.Center) })
		return h, t, right
	end

	-- A transparent, auto-sized row that registers itself like any other element.
	local function customRow(section, o)
		local pad = o.Padding or { 10, 10, 10, 10 }
		local item = setmetatable({
			Section = section,
			Page = section.Page,
			Tab = section.Tab,
			Name = o.Name or "",
			Desc = o.Description or "",
			Id = o.Id or "",
			Extra = 0,
			BaseH = 54,
			Indent = 18,
		}, ItemClass)
		item.Row = create("Frame", {
			Name = o.RowName or "Row",
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 1,
			LayoutOrder = #section.Items + 1,
			Parent = section.Card,
		}, {
			corner(10),
			padding(pad[1], pad[2], pad[3], pad[4]),
			list(Enum.FillDirection.Vertical, o.Gap or 8),
		})
		item._layout = function() end
		if o.NoSearch then
			item.NoSearch = true
			item.Matches = function()
				return true
			end
		end
		table.insert(section.Items, item)
		table.insert(section.Page.Items, item)
		table.insert(section.Tab.Items, item)
		section.Tab:_updateCount()
		return item
	end

	----------------------------------------------------------------------------
	-- AddList
	----------------------------------------------------------------------------
	function SectionClass:AddList(opts)
		opts = opts or {}
		local item = customRow(self, {
			Name = opts.Title or "",
			RowName = "List",
			NoSearch = true,
			Padding = { 10, 10, 10, 10 },
			Gap = 8,
		})
		local rowH = opts.RowHeight or 46
		local maxRows = opts.MaxRows or 80
		local rightReserve = opts.RightWidth or 150
		local twoLine = rowH >= 38

		local countLbl
		if opts.Title or opts.HeaderButtons then
			local _, titleLbl, hdrRight = header(item.Row, opts.Title, 1)
			item.NameLabel = titleLbl
			countLbl = newLabel({
				Size = UDim2.new(0, 0, 1, 0),
				AutomaticSize = Enum.AutomaticSize.X,
				Text = "",
				Tc = "Dim",
				TextSize = 10,
				LayoutOrder = 0,
				Parent = hdrRight,
			})
			for i, hb in ipairs(opts.HeaderButtons or {}) do
				local sb = smallButton(hdrRight, hb.Text or "Action", i)
				sb.MouseButton1Click:Connect(function()
					if hb.Callback then
						task.spawn(hb.Callback)
					end
				end)
			end
		end

		local frame = create("Frame", {
			Size = UDim2.new(1, 0, 0, opts.Height or 260),
			Bg = "Input",
			ClipsDescendants = true,
			LayoutOrder = 2,
			Parent = item.Row,
		}, { corner(10), stroke("Stroke") })
		local scroll = create("ScrollingFrame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			ScrollBarThickness = 4,
			Sc = "StrokeLight",
			CanvasSize = UDim2.new(),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			Parent = frame,
		}, { padding(6, 6, 6, 6), list(Enum.FillDirection.Vertical, 3) })
		local empty = newLabel({
			Size = UDim2.fromScale(1, 1),
			Text = opts.Empty or "Nothing here yet",
			Tc = "Dim",
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Center,
			Parent = frame,
		})

		local rows, entries = {}, {}
		local selectedId = nil
		local shown, total = 0, 0

		local function pillColors(key)
			if typeof(key) == "Color3" then
				return key, key:Lerp(Color3.new(0, 0, 0), 0.8)
			end
			local scheme = Theme.Notes[key or "Gray"] or Theme.Notes.Gray
			return scheme.Text, scheme.Bg
		end

		-- colours are applied directly (no per-row theme binds, rows are short lived)
		local function paintRow(r, animate)
			local sel = (r.Id == selectedId)
			local goalColor, goalTransparency
			if sel then
				goalColor = Theme.Accent:Lerp(Theme.Card, 0.84)
				goalTransparency = 0
			else
				goalColor = Theme.Active
				goalTransparency = r.Hover and 0.55 or 1
			end
			r.Bar.Visible = sel
			r.Bar.BackgroundColor3 = Theme.Accent
			if animate then
				tween(r.Btn, 0.15, { BackgroundColor3 = goalColor, BackgroundTransparency = goalTransparency })
			else
				r.Btn.BackgroundColor3 = goalColor
				r.Btn.BackgroundTransparency = goalTransparency
			end
			r.Title.TextColor3 = Theme.Text
			r.Sub.TextColor3 = Theme.Muted
			r.RightLbl.TextColor3 = resolveColor(r.RC, Theme.Muted)
			if r.Pill then
				local tc, bg = pillColors(r.TgC)
				r.Pill.BackgroundColor3 = bg
				r.PillLbl.TextColor3 = tc
			end
			if r.Icon then
				r.Icon:SetColor(Theme.Muted)
			end
		end

		local function build(id)
			local btn = create("TextButton", {
				Size = UDim2.new(1, 0, 0, rowH),
				BackgroundColor3 = Theme.Active,
				BackgroundTransparency = 1,
				Text = "",
				AutoButtonColor = false,
				Parent = scroll,
			}, { corner(8) })
			local bar = create("Frame", {
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, 0, 0.5, 0),
				Size = UDim2.new(0, 3, 0.6, 0),
				BackgroundColor3 = Theme.Accent,
				Visible = false,
				Parent = btn,
			}, { corner(2) })
			local r = { Id = id, Btn = btn, Bar = bar, Hover = false }
			local leftX = 14
			if opts.Icons then
				r.Icon = newIcon(btn, "circle", 14, UDim2.new(0, 12, 0.5, 0), Vector2.new(0, 0.5))
				leftX = 36
			end
			r.Title = newLabel({
				Position = UDim2.fromOffset(leftX, twoLine and 6 or 0),
				Size = UDim2.new(1, -(leftX + rightReserve), 0, twoLine and 18 or rowH),
				Text = "",
				TextColor3 = Theme.Text,
				Font = FONT_MED,
				TextSize = 12,
				TextTruncate = Enum.TextTruncate.AtEnd,
				Parent = btn,
			})
			r.Sub = newLabel({
				Position = UDim2.fromOffset(leftX, 24),
				Size = UDim2.new(1, -(leftX + rightReserve), 0, 14),
				Text = "",
				TextColor3 = Theme.Muted,
				TextSize = 10,
				TextTruncate = Enum.TextTruncate.AtEnd,
				Visible = twoLine,
				Parent = btn,
			})
			r.Right = create("Frame", {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -10, 0.5, 0),
				Size = UDim2.new(0, 0, 0, 22),
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundTransparency = 1,
				Parent = btn,
			}, { list(Enum.FillDirection.Horizontal, 8, Enum.VerticalAlignment.Center) })
			r.RightLbl = newLabel({
				Size = UDim2.new(0, 0, 1, 0),
				AutomaticSize = Enum.AutomaticSize.X,
				Text = "",
				TextColor3 = Theme.Muted,
				TextSize = 11,
				TextXAlignment = Enum.TextXAlignment.Right,
				LayoutOrder = 2,
				Parent = r.Right,
			})
			btn.MouseEnter:Connect(function()
				r.Hover = true
				if r.Id ~= selectedId then
					tween(btn, 0.12, { BackgroundTransparency = 0.55 })
				end
			end)
			btn.MouseLeave:Connect(function()
				r.Hover = false
				if r.Id ~= selectedId then
					tween(btn, 0.18, { BackgroundTransparency = 1 })
				end
			end)
			btn.MouseButton1Click:Connect(function()
				item.Select(r.Id)
			end)
			paintRow(r, false)
			return r
		end

		local function update(r, e)
			if r.T ~= e.Title then
				r.T = e.Title
				r.Title.Text = tostring(e.Title or "")
			end
			if r.S ~= e.Subtitle then
				r.S = e.Subtitle
				r.Sub.Text = tostring(e.Subtitle or "")
			end
			if r.Tg ~= e.Tag or r.TgC ~= e.TagColor then
				r.Tg, r.TgC = e.Tag, e.TagColor
				if r.Pill then
					r.Pill:Destroy()
					r.Pill, r.PillLbl = nil, nil
				end
				if e.Tag and e.Tag ~= "" then
					local tc, bg = pillColors(e.TagColor)
					r.Pill = create("Frame", {
						Size = UDim2.new(0, 0, 0, 18),
						AutomaticSize = Enum.AutomaticSize.X,
						BackgroundColor3 = bg,
						LayoutOrder = 1,
						Parent = r.Right,
					}, { corner(9), padding(8, 0, 8, 0) })
					r.PillLbl = newLabel({
						Size = UDim2.new(0, 0, 1, 0),
						AutomaticSize = Enum.AutomaticSize.X,
						Text = tostring(e.Tag),
						TextColor3 = tc,
						TextSize = 9,
						Font = FONT_MED,
						Parent = r.Pill,
					})
				end
			end
			if r.R ~= e.Right or r.RC ~= e.RightColor then
				r.R, r.RC = e.Right, e.RightColor
				r.RightLbl.Text = tostring(e.Right or "")
				r.RightLbl.TextColor3 = resolveColor(e.RightColor, Theme.Muted)
			end
			if r.Icon and r.I ~= e.Icon then
				r.I = e.Icon
				r.Icon:SetIcon(e.Icon or "circle")
			end
		end

		function item.SetItems(newItems)
			newItems = newItems or {}
			entries = {}
			total = #newItems
			local seen = {}
			local n = 0
			for i, e in ipairs(newItems) do
				local id = e.Id
				if id == nil then
					id = i
				end
				entries[id] = e
				if n < maxRows then
					n = n + 1
					local r = rows[id]
					if not r then
						r = build(id)
						rows[id] = r
					end
					update(r, e)
					r.Btn.LayoutOrder = n
					seen[id] = true
				end
			end
			for id, r in pairs(rows) do
				if not seen[id] then
					r.Btn:Destroy()
					rows[id] = nil
				end
			end
			shown = n
			empty.Visible = (n == 0)
			if selectedId ~= nil and entries[selectedId] == nil then
				selectedId = nil
			end
			if countLbl then
				if opts.CountFormat then
					countLbl.Text = tostring(opts.CountFormat(shown, total))
				elseif total > shown then
					countLbl.Text = shown .. " of " .. total
				else
					countLbl.Text = tostring(total)
				end
			end
		end

		function item.Select(id, silent)
			selectedId = id
			for _, r in pairs(rows) do
				paintRow(r, true)
			end
			if not silent and id ~= nil and opts.OnSelect then
				task.spawn(opts.OnSelect, entries[id], id)
			end
		end
		function item.GetSelected()
			return entries[selectedId], selectedId
		end
		function item.Clear()
			item.SetItems({})
		end
		function item.SetCount(text)
			if countLbl then
				countLbl.Text = tostring(text or "")
			end
		end
		function item.SetEmptyText(text)
			empty.Text = tostring(text or "")
		end
		function item.Count()
			return total
		end
		function item.ScrollToTop()
			scroll.CanvasPosition = Vector2.new(0, 0)
		end

		bind(frame, function()
			for _, r in pairs(rows) do
				paintRow(r, false)
			end
		end)
		return item
	end

	----------------------------------------------------------------------------
	-- AddCodeBlock
	----------------------------------------------------------------------------
	function SectionClass:AddCodeBlock(opts)
		opts = opts or {}
		local item = customRow(self, {
			Name = opts.Title or "",
			RowName = "CodeBlock",
			NoSearch = true,
			Padding = { 10, 10, 10, 10 },
			Gap = 8,
		})
		local full = ""
		local wrap = opts.Wrap ~= false
		local maxChars = opts.MaxChars or 12000

		local _, titleLbl, hdrRight = header(item.Row, opts.Title, 1)
		item.NameLabel = titleLbl
		local order = 0
		for _, b in ipairs(opts.Buttons or {}) do
			order = order + 1
			local sb = smallButton(hdrRight, b.Text or "Action", order)
			sb.MouseButton1Click:Connect(function()
				if b.Callback then
					task.spawn(b.Callback)
				end
			end)
		end
		local wrapBtn, copyBtn
		if opts.WrapToggle ~= false then
			order = order + 1
			wrapBtn = smallButton(hdrRight, "Wrap", order)
		end
		if opts.Copy ~= false then
			order = order + 1
			copyBtn = smallButton(hdrRight, "Copy", order)
		end

		local frame = create("Frame", {
			Size = UDim2.new(1, 0, 0, opts.Height or 160),
			Bg = "Input",
			ClipsDescendants = true,
			LayoutOrder = 2,
			Parent = item.Row,
		}, { corner(10), stroke("Stroke") })
		local scroll = create("ScrollingFrame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			ScrollBarThickness = 6,
			Sc = "StrokeLight",
			CanvasSize = UDim2.new(),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			ElasticBehavior = Enum.ElasticBehavior.Never,
			Parent = frame,
		}, { padding(10, 8, 10, 8) })
		local box = create("TextBox", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Text = "",
			PlaceholderText = opts.Placeholder or "",
			Pc = "Dim",
			Tc = "Text",
			Font = FONT_MONO,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextWrapped = true,
			MultiLine = true,
			ClearTextOnFocus = false,
			Parent = scroll,
		})
		-- read-only but still selectable with the mouse
		pcall(function()
			box.TextEditable = false
		end)

		local onWrapChanged
		local function applyWrap()
			if wrap then
				scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
				scroll.ScrollingDirection = Enum.ScrollingDirection.Y
				box.TextWrapped = true
				box.Size = UDim2.new(1, 0, 0, 0)
				box.AutomaticSize = Enum.AutomaticSize.Y
			else
				scroll.AutomaticCanvasSize = Enum.AutomaticSize.XY
				scroll.ScrollingDirection = Enum.ScrollingDirection.XY
				box.TextWrapped = false
				box.Size = UDim2.new(0, 0, 0, 0)
				box.AutomaticSize = Enum.AutomaticSize.XY
			end
			if wrapBtn then
				wrapBtn.TextColor3 = wrap and Theme.Accent or Theme.Muted
			end
		end
		applyWrap()
		if wrapBtn then
			wrapBtn.MouseButton1Click:Connect(function()
				wrap = not wrap
				applyWrap()
				if onWrapChanged then
					onWrapChanged()
				end
			end)
		end
		if copyBtn then
			copyBtn.MouseButton1Click:Connect(function()
				local ok = clipboard(full)
				if opts.OnCopy then
					task.spawn(opts.OnCopy, full)
				end
				copyBtn.Text = ok and "Copied" or "No clipboard"
				task.delay(1.2, function()
					if copyBtn.Parent then
						copyBtn.Text = "Copy"
					end
				end)
			end)
		end

		-- long text is split into pages (on line boundaries) so huge scripts stay smooth;
		-- each page scrolls normally, and the full text is always available through Copy / Get
		local pageSize = math.max(2000, opts.PageSize or opts.MaxChars or 12000)
		local pages, page = { "" }, 1
		local prevBtn = smallButton(hdrRight, "‹", -3)
		local pageLbl = newLabel({
			Size = UDim2.new(0, 0, 0, 22),
			AutomaticSize = Enum.AutomaticSize.X,
			Text = "",
			Font = FONT_MED,
			TextSize = 10,
			Tc = "Muted",
			TextXAlignment = Enum.TextXAlignment.Center,
			LayoutOrder = -2,
			Parent = hdrRight,
		}, { padding(4, 0, 4, 0) })
		local nextBtn = smallButton(hdrRight, "›", -1)

		local function paginate(text)
			local out, cur, n = {}, {}, 0
			for line in (text .. "\n"):gmatch("(.-)\n") do
				while #line > pageSize do
					if n > 0 then
						out[#out + 1] = table.concat(cur, "\n")
						cur, n = {}, 0
					end
					out[#out + 1] = line:sub(1, pageSize)
					line = line:sub(pageSize + 1)
				end
				if n > 0 and n + #line + 1 > pageSize then
					out[#out + 1] = table.concat(cur, "\n")
					cur, n = {}, 0
				end
				cur[#cur + 1] = line
				n = n + #line + 1
			end
			if #cur > 0 or #out == 0 then
				out[#out + 1] = table.concat(cur, "\n")
			end
			return out
		end

		local function render(toBottom)
			page = math.clamp(page, 1, #pages)
			box.Text = pages[page]
			local multi = #pages > 1
			prevBtn.Visible, nextBtn.Visible, pageLbl.Visible = multi, multi, multi
			if multi then
				pageLbl.Text = string.format("%d / %d", page, #pages)
				prevBtn.TextTransparency = page == 1 and 0.6 or 0
				nextBtn.TextTransparency = page == #pages and 0.6 or 0
			end
			scroll.CanvasPosition = Vector2.new(0, toBottom and 1e6 or 0)
		end
		local function go(delta)
			local np = math.clamp(page + delta, 1, #pages)
			if np ~= page then
				page = np
				render(delta < 0)
			end
		end
		prevBtn.MouseButton1Click:Connect(function()
			go(-1)
		end)
		nextBtn.MouseButton1Click:Connect(function()
			go(1)
		end)

		-- Roblox clips text that gets too wide/long to render, so very long lines are folded
		-- for display (continuations start with an arrow). Copy/Get always return the original.
		local function fold(text)
			local limit = wrap and 360 or 200
			if #text <= limit then
				return text
			end
			local out = {}
			for line in (text .. "\n"):gmatch("(.-)\n") do
				if #line > limit then
					out[#out + 1] = line:sub(1, limit)
					local pos = limit + 1
					while pos <= #line do
						out[#out + 1] = "\226\134\170 " .. line:sub(pos, pos + limit - 1)
						pos = pos + limit
					end
				else
					out[#out + 1] = line
				end
			end
			return table.concat(out, "\n")
		end

		local function rebuild(toBottom)
			pages = paginate(fold(sanitize(full)))
			if toBottom then
				page = #pages
			end
			render(toBottom)
		end
		onWrapChanged = function()
			rebuild(false)
		end
		function item.Set(text)
			full = tostring(text == nil and "" or text)
			page = 1
			rebuild(false)
		end
		function item.Get()
			return full
		end
		function item.Append(text)
			full = full .. tostring(text or "")
			rebuild(true)
		end
		function item.SetPage(n)
			page = tonumber(n) or 1
			render(false)
		end
		function item.GetPages()
			return #pages
		end
		function item.Clear()
			item.Set("")
		end
		if opts.Text then
			item.Set(opts.Text)
		end
		return item
	end

	----------------------------------------------------------------------------
	-- AddStats
	----------------------------------------------------------------------------
	function SectionClass:AddStats(opts)
		opts = opts or {}
		local defs = opts.Items or {}
		local n = math.max(#defs, 1)
		local gap = 10
		local item = customRow(self, {
			Name = opts.Title or "Stats",
			RowName = "Stats",
			NoSearch = true,
			Padding = { 10, 10, 10, 10 },
		})
		local holder = create("Frame", {
			Size = UDim2.new(1, 0, 0, opts.Height or 78),
			BackgroundTransparency = 1,
			Parent = item.Row,
		}, { list(Enum.FillDirection.Horizontal, gap) })

		local tiles = {}
		for i, d in ipairs(defs) do
			local tile = create("Frame", {
				Size = UDim2.new(1 / n, -(gap * (n - 1)) / n, 1, 0),
				Bg = "Input",
				LayoutOrder = i,
				Parent = holder,
			}, { corner(10), stroke("Stroke") })
			newLabel({
				Position = UDim2.fromOffset(14, 10),
				Size = UDim2.new(1, -44, 0, 14),
				Text = string.upper(d.Name or ""),
				Font = FONT_MED,
				TextSize = 10,
				Tc = "Muted",
				TextTruncate = Enum.TextTruncate.AtEnd,
				Parent = tile,
			})
			if d.Icon then
				newIcon(tile, d.Icon, 14, UDim2.new(1, -12, 0, 10), Vector2.new(1, 0), "Dim")
			end
			local value = newLabel({
				Position = UDim2.fromOffset(14, 26),
				Size = UDim2.new(1, -28, 0, 28),
				Text = tostring(d.Value == nil and "-" or d.Value),
				Font = FONT_BOLD,
				TextSize = 22,
				TextTruncate = Enum.TextTruncate.AtEnd,
				Parent = tile,
			})
			local note = newLabel({
				Position = UDim2.fromOffset(14, 56),
				Size = UDim2.new(1, -28, 0, 14),
				Text = d.Note or "",
				TextColor3 = resolveColor(d.NoteColor, Theme.Muted),
				TextSize = 10,
				TextTruncate = Enum.TextTruncate.AtEnd,
				Parent = tile,
			})
			local t = { Id = d.Id or i, Value = value, Note = note, V = value.Text }
			tiles[t.Id] = t
			tiles[i] = t
		end

		function item.Set(id, v, noteText, noteColor)
			local t = tiles[id]
			if not t then
				return
			end
			local sv = tostring(v == nil and "-" or v)
			if t.V ~= sv then
				t.V = sv
				t.Value.Text = sv
				t.Value.TextColor3 = Theme.Accent
				tween(t.Value, 0.7, { TextColor3 = Theme.Text })
			end
			if noteText ~= nil then
				t.Note.Text = tostring(noteText)
				t.Note.TextColor3 = resolveColor(noteColor, Theme.Muted)
			end
		end
		function item.SetAll(map)
			for id, v in pairs(map or {}) do
				if type(v) == "table" then
					item.Set(id, v.Value, v.Note, v.NoteColor)
				else
					item.Set(id, v)
				end
			end
		end
		return item
	end

	----------------------------------------------------------------------------
	-- AddProgress
	----------------------------------------------------------------------------
	function SectionClass:AddProgress(opts)
		opts = opts or {}
		local item = self:_makeRow(opts)
		local min, max = opts.Min or 0, opts.Max or 100
		local value = opts.Default or opts.Value or min
		local label = ""

		local holder = create("Frame", {
			Size = UDim2.fromOffset(opts.Width or 280, 30),
			BackgroundTransparency = 1,
			Parent = item.Controls,
		})
		local track = create("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 0, 0.5, 0),
			Size = UDim2.new(1, -80, 0, 6),
			Bg = "Input",
			Parent = holder,
		}, { corner(3), stroke("Stroke") })
		local fill = create("Frame", {
			Size = UDim2.fromScale(0, 1),
			BackgroundColor3 = Theme.Accent,
			Parent = track,
		}, { corner(3) })
		local text = newLabel({
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, 0, 0.5, 0),
			Size = UDim2.fromOffset(72, 20),
			Text = "",
			Tc = "Muted",
			TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Right,
			Parent = holder,
		})

		local function rel()
			if max == min then
				return 0
			end
			return math.clamp((value - min) / (max - min), 0, 1)
		end
		local function color()
			local r = rel()
			if r >= (opts.DangerAt or 0.95) then
				return Theme.Notes.Red.Text
			end
			if r >= (opts.WarnAt or 0.8) then
				return Theme.Notes.Yellow.Text
			end
			return Theme.Accent
		end
		local function format()
			if label ~= "" then
				return label
			end
			if opts.Format then
				return tostring(opts.Format(value, max))
			end
			if opts.Percent then
				return string.format("%d%%", math.floor(rel() * 100 + 0.5))
			end
			return tostring(value) .. " / " .. tostring(max)
		end
		local function render(animate)
			if animate then
				tween(fill, 0.3, { Size = UDim2.fromScale(rel(), 1), BackgroundColor3 = color() })
			else
				fill.Size = UDim2.fromScale(rel(), 1)
				fill.BackgroundColor3 = color()
			end
			text.Text = format()
		end
		bind(fill, function()
			fill.BackgroundColor3 = color()
		end)
		render(false)

		function item.Set(v, txt)
			value = v
			label = txt or ""
			render(true)
		end
		function item.Get()
			return value
		end
		function item.SetRange(a, b)
			min, max = a, b
			render(true)
		end
		return item
	end

	----------------------------------------------------------------------------
	-- AddStatus
	----------------------------------------------------------------------------
	local function stateColor(s)
		if s == "ok" then
			return Theme.Accent
		elseif s == "warn" then
			return Theme.Notes.Yellow.Text
		elseif s == "error" then
			return Theme.Notes.Red.Text
		end
		return Theme.Dot
	end

	function SectionClass:AddStatus(opts)
		opts = opts or {}
		local o = {}
		for k, v in pairs(opts) do
			o[k] = v
		end
		o.Indent = 46
		local item = self:_makeRow(o)
		item.State = opts.State or (opts.Running and "ok" or "off")

		local dot = create("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 20, 0.5, 0),
			Size = UDim2.fromOffset(8, 8),
			Parent = item.Top,
		}, { corner(4) })
		bind(dot, function()
			dot.BackgroundColor3 = stateColor(item.State)
		end)

		local note
		local function setNote(text, color)
			if note then
				note:Destroy()
				note = nil
			end
			if text and text ~= "" then
				note = makeNote(item.Controls, tostring(text), color)
			end
		end
		setNote(opts.Note, opts.NoteColor)
		local valueLbl = newLabel({
			Size = UDim2.new(0, 0, 1, 0),
			AutomaticSize = Enum.AutomaticSize.X,
			Text = opts.Value ~= nil and tostring(opts.Value) or "",
			Tc = "Muted",
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Right,
			LayoutOrder = 2,
			Parent = item.Controls,
		})

		function item.SetState(s)
			item.State = s
			tween(dot, 0.25, { BackgroundColor3 = stateColor(s) })
		end
		function item.SetRunning(b)
			item.SetState(b and "ok" or "off")
		end
		item.SetNote = setNote
		function item.SetValue(t)
			valueLbl.Text = tostring(t == nil and "" or t)
		end
		return item
	end

	----------------------------------------------------------------------------
	-- AddActions (a compact row of buttons)
	----------------------------------------------------------------------------
	function SectionClass:AddActions(opts)
		opts = opts or {}
		local item = customRow(self, {
			Name = opts.Title or "Actions",
			RowName = "Actions",
			NoSearch = true,
			Padding = { 10, 8, 10, 8 },
			Gap = 0,
		})
		local defs = opts.Buttons or {}
		local n = math.max(#defs, 1)
		local gap = 8
		local holder = create("Frame", {
			Size = UDim2.new(1, 0, 0, opts.Height or 34),
			BackgroundTransparency = 1,
			Parent = item.Row,
		}, { list(Enum.FillDirection.Horizontal, gap) })

		local recs = {}
		for i, d in ipairs(defs) do
			local style = d.Style or "Default"
			local b = create("TextButton", {
				Size = UDim2.new(1 / n, -(gap * (n - 1)) / n, 1, 0),
				Text = "",
				AutoButtonColor = false,
				LayoutOrder = i,
				Parent = holder,
			}, { corner(8), stroke("Stroke") })
			local st = b:FindFirstChildOfClass("UIStroke")
			local inner = create("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.new(0, 0, 1, 0),
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundTransparency = 1,
				Parent = b,
			}, { list(Enum.FillDirection.Horizontal, 6, Enum.VerticalAlignment.Center) })
			local icon
			if d.Icon then
				icon = newIcon(inner, d.Icon, 14)
				icon.Holder.LayoutOrder = 1
			end
			local lbl = newLabel({
				Size = UDim2.new(0, 0, 1, 0),
				AutomaticSize = Enum.AutomaticSize.X,
				Text = d.Text or "",
				Font = FONT_MED,
				TextSize = 12,
				LayoutOrder = 2,
				Parent = inner,
			})
			pressable(b, 0.96)
			local rec = { Btn = b, Label = lbl, Def = d, Enabled = true, Hover = false }

			local function paint(animate)
				local bg, tc, sc
				if style == "Accent" then
					bg, tc, sc = Theme.Accent, Color3.new(1, 1, 1), Theme.Accent
				elseif style == "Danger" then
					bg, tc = Theme.Notes.Red.Bg, Theme.Notes.Red.Text
					sc = Theme.Notes.Red.Text:Lerp(Theme.Notes.Red.Bg, 0.6)
				else
					bg, tc, sc = Theme.Input, Theme.Text, Theme.Stroke
				end
				if rec.Hover and rec.Enabled then
					if style == "Default" then
						bg = Theme.Active
					else
						bg = bg:Lerp(Color3.new(1, 1, 1), 0.12)
					end
				end
				local transp = rec.Enabled and 0 or 0.55
				if animate then
					tween(b, 0.15, { BackgroundColor3 = bg, BackgroundTransparency = transp })
					tween(st, 0.15, { Color = sc })
				else
					b.BackgroundColor3 = bg
					b.BackgroundTransparency = transp
					st.Color = sc
				end
				lbl.TextColor3 = tc
				lbl.TextTransparency = rec.Enabled and 0 or 0.45
				if icon then
					icon:SetColor(tc)
				end
			end
			rec.Paint = paint
			bind(b, function()
				paint(false)
			end)
			b.MouseEnter:Connect(function()
				rec.Hover = true
				paint(true)
			end)
			b.MouseLeave:Connect(function()
				rec.Hover = false
				paint(true)
			end)
			b.MouseButton1Click:Connect(function()
				if rec.Enabled and d.Callback then
					task.spawn(d.Callback)
				end
			end)
			recs[i] = rec
		end

		local function find(key)
			if type(key) == "number" then
				return recs[key]
			end
			for _, r in ipairs(recs) do
				if r.Def.Id == key or r.Def.Text == key then
					return r
				end
			end
			return nil
		end
		function item.SetEnabled(key, on)
			local r = find(key)
			if r then
				r.Enabled = (on ~= false)
				r.Paint(true)
			end
		end
		function item.SetAllEnabled(on)
			for _, r in ipairs(recs) do
				r.Enabled = (on ~= false)
				r.Paint(true)
			end
		end
		function item.SetText(key, text)
			local r = find(key)
			if r then
				r.Label.Text = tostring(text)
			end
		end
		function item.GetButton(key)
			local r = find(key)
			return r and r.Btn or nil
		end
		return item
	end

	----------------------------------------------------------------------------
	-- AddDivider
	----------------------------------------------------------------------------
	function SectionClass:AddDivider(text)
		local item = customRow(self, {
			Name = text or "",
			RowName = "Divider",
			NoSearch = true,
			Padding = { 18, 6, 18, 6 },
		})
		local holder = create("Frame", {
			Size = UDim2.new(1, 0, 0, 16),
			BackgroundTransparency = 1,
			Parent = item.Row,
		})
		create("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 0, 0.5, 0),
			Size = UDim2.new(1, 0, 0, 1),
			Bg = "Stroke",
			Parent = holder,
		})
		if text and text ~= "" then
			local tag = create("Frame", {
				Size = UDim2.new(0, 0, 1, 0),
				AutomaticSize = Enum.AutomaticSize.X,
				Bg = "Card",
				ZIndex = 2,
				Parent = holder,
			}, { padding(0, 0, 8, 0) })
			item.NameLabel = newLabel({
				Size = UDim2.new(0, 0, 1, 0),
				AutomaticSize = Enum.AutomaticSize.X,
				Text = string.upper(text),
				Font = FONT_MED,
				TextSize = 9,
				Tc = "Dim",
				ZIndex = 3,
				Parent = tag,
			})
		end
		return item
	end

	----------------------------------------------------------------------------
	-- AddTextArea
	----------------------------------------------------------------------------
	function SectionClass:AddTextArea(opts)
		opts = opts or {}
		local item = customRow(self, {
			Name = opts.Name,
			Description = opts.Description,
			Id = opts.Id,
			RowName = opts.Name or "TextArea",
			Padding = { 18, 14, 18, 14 },
			Gap = 8,
		})
		item.NameLabel = newLabel({
			Size = UDim2.new(1, 0, 0, 18),
			Text = item.Name,
			Font = FONT_MED,
			TextSize = 13,
			TextTruncate = Enum.TextTruncate.AtEnd,
			LayoutOrder = 1,
			Parent = item.Row,
		})
		item.DescLabel = newLabel({
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Text = item.Desc,
			Tc = "Muted",
			TextSize = 10,
			TextWrapped = true,
			TextYAlignment = Enum.TextYAlignment.Top,
			Visible = item.Desc ~= "",
			LayoutOrder = 2,
			Parent = item.Row,
		})
		item._layout = function()
			item.NameLabel.Text = item.Name
			item.DescLabel.Text = item.Desc
			item.DescLabel.Visible = item.Desc ~= ""
		end

		local height = opts.Height or 96
		local frame = create("Frame", {
			Size = UDim2.new(1, 0, 0, height),
			Bg = "Input",
			ClipsDescendants = true,
			LayoutOrder = 3,
			Parent = item.Row,
		}, { corner(10), stroke("Stroke") })
		local fstroke = frame:FindFirstChildOfClass("UIStroke")
		local scroll = create("ScrollingFrame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			ScrollBarThickness = 4,
			Sc = "StrokeLight",
			CanvasSize = UDim2.new(),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			Parent = frame,
		}, { padding(10, 8, 10, 8) })
		local box = create("TextBox", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, math.max(height - 16, 20)),
			AutomaticSize = Enum.AutomaticSize.Y,
			Text = opts.Default or "",
			PlaceholderText = opts.Placeholder or "",
			Pc = "Dim",
			Tc = "Text",
			Font = FONT_MONO,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextWrapped = true,
			MultiLine = true,
			ClearTextOnFocus = false,
			Parent = scroll,
		})
		if opts.ReadOnly then
			pcall(function()
				box.TextEditable = false
			end)
		end
		box.Focused:Connect(function()
			tween(fstroke, 0.2, { Color = Theme.Accent })
		end)
		box.FocusLost:Connect(function()
			tween(fstroke, 0.2, { Color = Theme.Stroke })
			if opts.Callback and not opts.Live then
				task.spawn(opts.Callback, box.Text)
			end
		end)
		if opts.Live then
			box:GetPropertyChangedSignal("Text"):Connect(function()
				if opts.Callback then
					task.spawn(opts.Callback, box.Text)
				end
			end)
		end

		function item.Set(t, silent)
			box.Text = tostring(t == nil and "" or t)
			if not silent and opts.Callback then
				task.spawn(opts.Callback, box.Text)
			end
		end
		function item.Get()
			return box.Text
		end
		function item.Append(line)
			local cur = box.Text
			if cur ~= "" and cur:sub(-1) ~= "\n" then
				cur = cur .. "\n"
			end
			item.Set(cur .. tostring(line or ""), false)
		end
		if opts.Flag then
			item.Flag = opts.Flag
			item.ConfigType = "value"
			self.Window:_registerFlag(item)
		end
		return item
	end

	----------------------------------------------------------------------------
	-- Window:Confirm
	----------------------------------------------------------------------------
	function WindowClass:Confirm(opts)
		opts = opts or {}
		if self.ConfirmClose then
			self.ConfirmClose(false, true)
		end
		local base = self.BaseScale or 1
		local overlay = create("TextButton", {
			Name = "ConfirmOverlay",
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 1,
			Text = "",
			AutoButtonColor = false,
			ZIndex = 300,
			Parent = self.Gui,
		})
		local card = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(400, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Bg = "Card",
			Parent = overlay,
		}, {
			corner(14),
			stroke("StrokeLight"),
			padding(22, 20, 22, 18),
			list(Enum.FillDirection.Vertical, 10),
		})
		local sc = create("UIScale", { Scale = 0.92 * base, Parent = card })

		local top = create("Frame", {
			Size = UDim2.new(1, 0, 0, 28),
			BackgroundTransparency = 1,
			LayoutOrder = 1,
			Parent = card,
		}, { list(Enum.FillDirection.Horizontal, 10, Enum.VerticalAlignment.Center) })
		local iconBox = create("Frame", {
			Size = UDim2.fromOffset(28, 28),
			BackgroundColor3 = opts.Danger and Theme.Notes.Red.Bg or Theme.Active,
			LayoutOrder = 1,
			Parent = top,
		}, { corner(8) })
		local ic = newIcon(
			iconBox,
			opts.Icon or (opts.Danger and { "triangle-alert", "alert-triangle", "!" } or { "circle-help", "help-circle", "?" }),
			15,
			UDim2.fromScale(0.5, 0.5),
			Vector2.new(0.5, 0.5)
		)
		ic:SetColor(opts.Danger and Theme.Notes.Red.Text or Theme.Accent)
		newLabel({
			Size = UDim2.new(1, -40, 1, 0),
			Text = opts.Title or "Are you sure?",
			Font = FONT_BOLD,
			TextSize = 15,
			TextTruncate = Enum.TextTruncate.AtEnd,
			LayoutOrder = 2,
			Parent = top,
		})
		newLabel({
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Text = opts.Text or "",
			Tc = "Muted",
			TextSize = 12,
			TextWrapped = true,
			TextYAlignment = Enum.TextYAlignment.Top,
			LayoutOrder = 2,
			Parent = card,
		})
		local btnRow = create("Frame", {
			Size = UDim2.new(1, 0, 0, 36),
			BackgroundTransparency = 1,
			LayoutOrder = 3,
			Parent = card,
		}, {
			create("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Right,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = UDim.new(0, 8),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
		})

		local closed = false
		local conn
		local function close(result, instant)
			if closed then
				return
			end
			closed = true
			if conn then
				conn:Disconnect()
			end
			self.ConfirmClose = nil
			if instant then
				overlay:Destroy()
			else
				tween(overlay, 0.15, { BackgroundTransparency = 1 })
				tween(sc, 0.15, { Scale = 0.94 * base })
				task.delay(0.16, function()
					overlay:Destroy()
				end)
			end
			if result then
				if opts.OnConfirm then
					task.spawn(opts.OnConfirm)
				end
			else
				if opts.OnCancel then
					task.spawn(opts.OnCancel)
				end
			end
		end
		self.ConfirmClose = close

		local function dialogButton(text, order, primary)
			local danger = primary and opts.Danger
			local b = create("TextButton", {
				Size = UDim2.fromOffset(104, 34),
				BackgroundColor3 = Theme.Active,
				Text = text,
				Font = FONT_MED,
				TextSize = 12,
				TextColor3 = Theme.Text,
				AutoButtonColor = false,
				LayoutOrder = order,
				Parent = btnRow,
			}, { corner(9), stroke("Stroke") })
			local function paint(hover)
				local bg, tc
				if primary then
					if danger then
						bg, tc = Theme.Notes.Red.Text, Color3.new(1, 1, 1)
					else
						bg, tc = Theme.Accent, Color3.new(1, 1, 1)
					end
					if hover then
						bg = bg:Lerp(Color3.new(1, 1, 1), 0.12)
					end
				else
					bg = hover and Theme.StrokeLight or Theme.Active
					tc = Theme.Text
				end
				tween(b, 0.12, { BackgroundColor3 = bg })
				b.TextColor3 = tc
			end
			paint(false)
			b.MouseEnter:Connect(function()
				paint(true)
			end)
			b.MouseLeave:Connect(function()
				paint(false)
			end)
			pressable(b, 0.95)
			return b
		end
		local cancelBtn = dialogButton(opts.CancelText or "Cancel", 1, false)
		local okBtn = dialogButton(opts.ConfirmText or "Confirm", 2, true)
		cancelBtn.MouseButton1Click:Connect(function()
			close(false)
		end)
		okBtn.MouseButton1Click:Connect(function()
			close(true)
		end)
		overlay.MouseButton1Click:Connect(function()
			close(false)
		end)
		conn = UserInputService.InputBegan:Connect(function(input)
			if input.KeyCode == Enum.KeyCode.Escape then
				close(false)
			elseif input.KeyCode == Enum.KeyCode.Return or input.KeyCode == Enum.KeyCode.KeypadEnter then
				close(true)
			end
		end)
		table.insert(self.Connections, conn)

		tween(overlay, 0.2, { BackgroundTransparency = 0.45 })
		tween(sc, 0.35, { Scale = base }, Enum.EasingStyle.Back)
		return close
	end

	----------------------------------------------------------------------------
	-- Search: the new "content" elements (lists, code blocks...) are not searchable
	----------------------------------------------------------------------------
	local origSearch = WindowClass._search
	function WindowClass:_search(q)
		local results = origSearch(self, q)
		local out = {}
		for _, r in ipairs(results) do
			if not (r.Item and r.Item.NoSearch) then
				out[#out + 1] = r
			end
		end
		return out
	end

	----------------------------------------------------------------------------
	-- Dual-call: every function an element exposes works as item.Set(x) and item:Set(x)
	----------------------------------------------------------------------------
	local function dualWrap(item)
		if type(item) ~= "table" then
			return item
		end
		local names = {}
		for k, v in pairs(item) do
			if type(k) == "string" and type(v) == "function" then
				local c = k:sub(1, 1)
				if c ~= "_" and k ~= "Matches" and k:sub(1, 2) ~= "On" then
					names[#names + 1] = k
				end
			end
		end
		for _, k in ipairs(names) do
			local fn = item[k]
			item[k] = function(a, ...)
				if a == item then
					return fn(...)
				end
				return fn(a, ...)
			end
		end
		return item
	end

	local addNames = {}
	for name, fn in pairs(SectionClass) do
		if type(name) == "string" and name:sub(1, 3) == "Add" and type(fn) == "function" then
			addNames[#addNames + 1] = name
		end
	end
	for _, name in ipairs(addNames) do
		local orig = SectionClass[name]
		SectionClass[name] = function(self, ...)
			return dualWrap(orig(self, ...))
		end
	end
end


-- ============================================================================
-- Themes + Seasonal modes (2.3)
--
--   Library:GetPresets()                    -> sorted list of theme names
--   Library:AddPreset(name, { Accent=..., Background=..., ... })
--   Library:SetTheme("Midnight")            -- Default Midnight Crimson Forest Sunset Mocha
--                                           -- Nord Dracula Cyber Rose Violet Amber Ocean
--
--   Seasonal modes are opt-in by the script owner only:
--   Library:CreateWindow({ ..., Halloween = true })
--   Library:CreateWindow({ ..., Christmas = true })
--   Library:CreateWindow({ ..., Christmas = { Intensity = 1.5, Screen = true } })
--   Library:CreateWindow({ ..., Season = "Halloween" })
--   Window:SetSeason("Christmas" | "Halloween" | nil [, cfg])   -- switch at runtime
--   Window:GetSeason()
--
-- cfg (all optional):  Theme (bool, default true)   apply the season colour preset
--                      Effects (bool, default true) snow / bats / ghosts / lightning / glow
--                      Decor (bool, default true)   hats, garland, ornaments, cobwebs, slime...
--                      Intensity (number, 1)        particle count multiplier
--                      Screen (bool, false)         particles fall over the whole screen
--                      Style ("Subtle" | "Classic" | "Festive")
--                                                   Subtle  = refined, minimal
--                                                   Classic = rich decorations (default)
--                                                   Festive = absolutely everything, everywhere
--
-- Every glyph is editable and may be an emoji/text OR an "rbxassetid://" image:
--   Library.Seasons.Christmas.Glyphs.Tree = "rbxassetid://123"
-- ============================================================================
do
	local TAU = math.pi * 2
	local Seasons = {}
	Library.Seasons = Seasons
	Library.Features.Seasons = true
	Library.Features.Presets = true

	local function C(r, g, b)
		return Color3.fromRGB(r, g, b)
	end

	-- ---- theme presets -------------------------------------------------------
	-- Build a complete, coherent palette from an accent and a background tint.
	local WHITE, BLACK = Color3.new(1, 1, 1), Color3.new(0, 0, 0)
	local function palette(accent, bg, textTint)
		local text = (textTint or WHITE):Lerp(WHITE, 0.82)
		return {
			Accent = accent,
			Background = bg,
			Sidebar = bg:Lerp(WHITE, 0.022),
			Card = bg:Lerp(WHITE, 0.045),
			Input = bg:Lerp(BLACK, 0.28),
			Active = bg:Lerp(accent, 0.2),
			Stroke = bg:Lerp(WHITE, 0.11),
			StrokeLight = bg:Lerp(accent, 0.42),
			Text = text,
			Muted = bg:Lerp(text, 0.62),
			Dim = bg:Lerp(text, 0.38),
			Dot = bg:Lerp(accent, 0.55),
		}
	end

	local P = Library.Presets
	P.Default = {}
	P.Ocean = palette(C(56, 189, 248), C(14, 20, 29))
	P.Midnight = palette(C(129, 140, 248), C(11, 12, 22))
	P.Crimson = palette(C(244, 63, 94), C(20, 11, 14))
	P.Forest = palette(C(74, 222, 128), C(11, 19, 15))
	P.Sunset = palette(C(251, 146, 60), C(22, 14, 14))
	P.Mocha = palette(C(217, 168, 118), C(24, 19, 17))
	P.Nord = palette(C(136, 192, 208), C(30, 34, 42), C(216, 222, 233))
	P.Dracula = palette(C(189, 147, 249), C(26, 27, 38), C(248, 248, 242))
	P.Cyber = palette(C(0, 255, 200), C(8, 10, 16))
	P.Rose = palette(C(244, 114, 182), C(21, 14, 19))
	P.Violet = palette(C(167, 139, 250), C(17, 14, 24))
	P.Amber = palette(C(251, 191, 36), C(21, 18, 11))

	function Library:AddPreset(name, tbl)
		if type(name) == "string" and type(tbl) == "table" then
			Library.Presets[name] = tbl
		end
	end

	function Library:GetPresets(includeSeasons)
		local out = {}
		for k in pairs(Library.Presets) do
			if includeSeasons or not (Seasons[k] ~= nil) then
				out[#out + 1] = k
			end
		end
		table.sort(out, function(a, b)
			if a == "Default" then
				return b ~= "Default"
			elseif b == "Default" then
				return false
			end
			return a < b
		end)
		return out
	end

	P.Halloween = {
		Accent = C(255, 117, 24),
		Background = C(15, 10, 21),
		Sidebar = C(19, 12, 27),
		Card = C(26, 17, 35),
		Input = C(11, 8, 17),
		Active = C(52, 28, 36),
		Stroke = C(58, 36, 70),
		StrokeLight = C(130, 66, 36),
		Text = C(248, 236, 224),
		Muted = C(180, 158, 170),
		Dim = C(122, 102, 134),
		Dot = C(140, 84, 60),
		Notes = {
			Green = { Text = C(132, 204, 22), Bg = C(30, 44, 14) },
			Yellow = { Text = C(251, 146, 60), Bg = C(62, 34, 14) },
			Red = { Text = C(244, 63, 94), Bg = C(64, 18, 34) },
			Gray = { Text = C(172, 150, 178), Bg = C(38, 28, 46) },
			Blue = { Text = C(192, 132, 252), Bg = C(42, 24, 66) },
		},
	}
	P.Christmas = {
		Accent = C(239, 68, 68),
		Background = C(12, 21, 18),
		Sidebar = C(14, 26, 21),
		Card = C(19, 32, 27),
		Input = C(9, 17, 14),
		Active = C(56, 30, 32),
		Stroke = C(34, 58, 48),
		StrokeLight = C(120, 56, 56),
		Text = C(246, 250, 246),
		Muted = C(164, 186, 174),
		Dim = C(100, 128, 114),
		Dot = C(212, 170, 70),
		Notes = {
			Green = { Text = C(74, 222, 128), Bg = C(16, 54, 34) },
			Yellow = { Text = C(250, 204, 21), Bg = C(60, 50, 14) },
			Red = { Text = C(248, 113, 113), Bg = C(64, 22, 24) },
			Gray = { Text = C(172, 188, 180), Bg = C(32, 44, 38) },
			Blue = { Text = C(125, 211, 252), Bg = C(18, 44, 62) },
		},
	}

	Seasons.Halloween = {
		Preset = "Halloween",
		Emoji = "🎃",
		Glyphs = { Bat = "🦇", Ghost = "👻", Ember = "•", Web = "🕸️", Pumpkin = "🎃", Spider = "🕷️", Moon = "🌕", Tomb = "🪦", Candle = "🕯️", Skull = "💀" },
	}
	Seasons.Christmas = {
		Preset = "Christmas",
		Emoji = "🎄",
		Glyphs = { Flake = { "❄", "•", "✦", "❅" }, Tree = "🎄", Gift = "🎁", Snowman = "⛄", Star = "✦", Sleigh = "🛷", Sparkle = "✨", Candy = "🍬", Bell = "🔔" },
	}

	-- ---- helpers ---------------------------------------------------------------
	local function isAsset(g)
		return type(g) == "string" and (g:find("^rbxassetid://") or g:find("^rbxasset://") or g:find("^http")) ~= nil
	end

	local function glyph(parent, g, size, props)
		local obj
		if isAsset(g) then
			obj = create("ImageLabel", {
				BackgroundTransparency = 1,
				Image = g,
				Size = UDim2.fromOffset(size, size),
				Parent = parent,
			})
		else
			obj = create("TextLabel", {
				BackgroundTransparency = 1,
				Text = tostring(g),
				TextSize = size,
				Font = Enum.Font.BuilderSans,
				TextColor3 = Color3.new(1, 1, 1),
				Size = UDim2.fromOffset(size + 8, size + 8),
				Parent = parent,
			})
		end
		for k, v in pairs(props or {}) do
			obj[k] = v
		end
		return obj
	end
	local function setAlpha(obj, a)
		if obj.ClassName == "ImageLabel" then
			obj.ImageTransparency = a
		elseif obj.ClassName == "Frame" then
			obj.BackgroundTransparency = a
		else
			obj.TextTransparency = a
		end
	end
	local function rand(a, b)
		return a + math.random() * (b - a)
	end
	local function pick(t)
		if type(t) == "table" then
			return t[math.random(1, #t)]
		end
		return t
	end
	local function px(win)
		return win.SizePx or Vector2.new(1000, 640)
	end
	local function round(parent, props)
		props.Parent = parent
		return create("Frame", props, { create("UICorner", { CornerRadius = UDim.new(1, 0) }) })
	end

	-- soft glow: stacked translucent discs (no assets needed)
	local function glow(parent, color, size, pos, z, anchor)
		local holder = create("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(size, size),
			Position = pos,
			AnchorPoint = anchor or Vector2.new(0.5, 0.5),
			ZIndex = z,
			Parent = parent,
		})
		local discs = {}
		for i, k in ipairs({ 1, 0.72, 0.46 }) do
			local d = round(holder, {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(k, k),
				BackgroundColor3 = color,
				BackgroundTransparency = ({ 0.93, 0.88, 0.8 })[i],
				ZIndex = z,
			})
			discs[i] = d
		end
		return holder, discs
	end

	local function wash(parent, color, rotation, a0, a1, z, size, pos, anchor)
		return create("Frame", {
			BackgroundColor3 = color,
			Size = size or UDim2.fromScale(1, 1),
			Position = pos or UDim2.new(),
			AnchorPoint = anchor or Vector2.new(0, 0),
			ZIndex = z,
			Parent = parent,
		}, {
			create("UIGradient", {
				Rotation = rotation,
				Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, a0), NumberSequenceKeypoint.new(1, a1) }),
			}),
		})
	end

	local function santaHat(parent, w, pos, rot, z)
		local h = w * 0.82
		local root = create("Frame", {
			Name = "SantaHat",
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(w, h),
			Position = pos,
			Rotation = rot or 0,
			ZIndex = z or 6,
			Parent = parent,
		})
		create("Frame", {
			Position = UDim2.fromOffset(w * 0.1, h * 0.2),
			Size = UDim2.fromOffset(w * 0.8, h * 0.62),
			BackgroundColor3 = C(214, 36, 48),
			ZIndex = z or 6,
			Parent = root,
		}, {
			create("UICorner", { CornerRadius = UDim.new(0.5, 0) }),
			create("UIGradient", {
				Rotation = 90,
				Color = ColorSequence.new(C(240, 70, 80), C(170, 20, 36)),
			}),
		})
		create("Frame", {
			Position = UDim2.fromOffset(0, h * 0.68),
			Size = UDim2.fromOffset(w, h * 0.3),
			BackgroundColor3 = C(250, 250, 252),
			ZIndex = (z or 6) + 1,
			Parent = root,
		}, { create("UICorner", { CornerRadius = UDim.new(1, 0) }) })
		create("Frame", {
			Position = UDim2.fromOffset(w * 0.64, 0),
			Size = UDim2.fromOffset(h * 0.34, h * 0.34),
			BackgroundColor3 = C(250, 250, 252),
			ZIndex = (z or 6) + 1,
			Parent = root,
		}, { create("UICorner", { CornerRadius = UDim.new(1, 0) }) })
		return root
	end

	local function newLayer(parent, name, z, clip)
		return create("Frame", {
			Name = name,
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			ClipsDescendants = clip == true,
			ZIndex = z,
			Active = false,
			Parent = parent,
		})
	end

	-- ---- per-window machinery ------------------------------------------------
	local function fxClear(win)
		if win.FXConn then
			win.FXConn:Disconnect()
			local idx = table.find(win.Connections, win.FXConn)
			if idx then
				table.remove(win.Connections, idx)
			end
			win.FXConn = nil
		end
		for _, o in ipairs(win.FXObjects or {}) do
			pcall(function()
				o:Destroy()
			end)
		end
		win.FXObjects = {}
		win.FXUpdaters = {}
		local st = win.Main and win.Main:FindFirstChildOfClass("UIStroke")
		if st then
			st.Thickness = 1
		end
	end

	local function track(win, inst)
		win.FXObjects[#win.FXObjects + 1] = inst
		return inst
	end

	local function startLoop(win)
		local t = 0
		win.FXConn = RunService.Heartbeat:Connect(function(dt)
			if not win.Gui or not win.Gui.Parent then
				return
			end
			dt = math.min(dt or 0.016, 0.1)
			local vis = win.Visible
			if win.ParticleLayer and win.ParticleLayer.Visible ~= vis then
				win.ParticleLayer.Visible = vis
			end
			if not vis then
				return
			end
			t = t + dt
			for _, fn in ipairs(win.FXUpdaters) do
				fn(dt, t)
			end
		end)
		table.insert(win.Connections, win.FXConn)
	end

	local function addUpdater(win, fn)
		win.FXUpdaters[#win.FXUpdaters + 1] = fn
	end

	local function windowStroke(win, cfg, colorAt, base)
		local stroke = win.Main:FindFirstChildOfClass("UIStroke")
		if stroke and cfg.Effects then
			addUpdater(win, function(_, t)
				stroke.Color = colorAt(t)
				stroke.Thickness = (base or 1.5) + 0.5 * math.sin(t * 2.1)
			end)
		end
	end

	-- ---- Christmas -----------------------------------------------------------
	local function sectionChristmas(win, sec, g)
		if not sec.Card or sec.SeasonDecor then
			return
		end
		local holder = create("Frame", {
			Name = "SeasonDecor",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			LayoutOrder = -100,
			ZIndex = 4,
			Parent = sec.Card,
		})
		sec.SeasonDecor = holder
		if not (win.SeasonCfg and win.SeasonCfg.Full) then
			create("Frame", {
				Position = UDim2.new(0, 22, 0, -4),
				Size = UDim2.new(1, -44, 0, 4),
				BackgroundColor3 = C(246, 249, 255),
				BackgroundTransparency = 0.12,
				ZIndex = 4,
				Parent = holder,
			}, { create("UICorner", { CornerRadius = UDim.new(1, 0) }) })
			return
		end
		-- snow cap with a few drifts
		create("Frame", {
			Position = UDim2.new(0, 18, 0, -8),
			Size = UDim2.new(1, -86, 0, 7),
			BackgroundColor3 = C(246, 249, 255),
			ZIndex = 4,
			Parent = holder,
		}, { create("UICorner", { CornerRadius = UDim.new(1, 0) }) })
		for i = 1, 5 do
			local d = math.random(8, 15)
			round(holder, {
				Position = UDim2.new(rand(0.04, 0.72), 0, 0, -8 - d * 0.4),
				Size = UDim2.fromOffset(d * 2, d),
				BackgroundColor3 = C(246, 249, 255),
				ZIndex = 4,
			})
		end
		-- icicles hanging off the snow
		for i = 1, 6 do
			create("Frame", {
				Position = UDim2.new(rand(0.05, 0.75), 0, 0, -3),
				Size = UDim2.fromOffset(3, math.random(5, 11)),
				BackgroundColor3 = C(200, 226, 250),
				BackgroundTransparency = 0.25,
				ZIndex = 4,
				Parent = holder,
			}, { create("UICorner", { CornerRadius = UDim.new(1, 0) }) })
		end
		if win.SeasonCfg and win.SeasonCfg.Max then
			santaHat(holder, 24, UDim2.new(1, -40, 0, -16), 16, 5)
		end
	end

	local function buildChristmas(win, cfg, S, layers)
		local g = S.Glyphs
		local size = px(win)
		local decor, fx = layers.decor, layers.fx
		local RED, GOLD, GREEN, BLUE = C(239, 68, 68), C(250, 204, 21), C(74, 222, 128), C(96, 165, 250)
		local full = cfg.Full

		if cfg.Decor then
			pcall(function()
				-- colour wash: warm red at the top, evergreen at the bottom
				track(win, wash(decor, RED, 90, full and 0.9 or 0.93, 1, 47, UDim2.new(1, 0, 0.4, 0)))
				track(win, wash(decor, GREEN, 270, full and 0.9 or 0.93, 1, 47, UDim2.new(1, 0, 0.4, 0), UDim2.fromScale(0, 1), Vector2.new(0, 1)))

				local logoBox = win.LogoText and win.LogoText.Parent
				if logoBox then
					track(win, santaHat(logoBox, 28, UDim2.fromOffset(-7, -14), -18, 8))
				end
				if full then
					local avatar = win.AvatarImage and win.AvatarImage.Parent
					if avatar and avatar.Parent then
						track(win, santaHat(avatar.Parent, 30, UDim2.fromOffset(12, 5), -16, 8))
					end
					local header = logoBox and logoBox.Parent
					if header then
						track(win, glyph(header, g.Tree, 22, { Position = UDim2.new(1, -44, 0, 18), ZIndex = 8 }))
					end
					local footer = avatar and avatar.Parent
					if footer then
						track(win, glyph(footer, g.Gift, 20, { Position = UDim2.new(1, -44, 0, 20), ZIndex = 8 }))
					end
					track(win, glyph(decor, g.Snowman, 30, {
						AnchorPoint = Vector2.new(1, 1),
						Position = UDim2.new(1, -14, 1, -2),
						ZIndex = 56,
					}))
					-- candy-cane trim under the top bar
					local sx, step = 256, 12
					local n = math.floor((size.X - sx) / step)
					for i = 0, n - 1 do
						track(win, create("Frame", {
							Position = UDim2.fromOffset(sx + i * step, 64),
							Size = UDim2.fromOffset(step / 2 + 1, 3),
							BackgroundColor3 = (i % 2 == 0) and C(230, 50, 60) or C(250, 250, 252),
							BackgroundTransparency = 0.15,
							ZIndex = 53,
							Parent = decor,
						}))
					end
					-- snow drift along the bottom edge
					local x = -20
					while x < size.X do
						local w = math.random(50, 110)
						track(win, round(decor, {
							Position = UDim2.new(0, x, 1, -rand(4, 9)),
							Size = UDim2.fromOffset(w, math.random(14, 22)),
							BackgroundColor3 = C(246, 249, 255),
							ZIndex = 54,
						}))
						x = x + w * 0.7
					end
				else
					-- frosted top edge + soft snow line at the bottom
					track(win, wash(decor, C(255, 255, 255), 90, 0.9, 1, 53, UDim2.new(1, 0, 0, 30)))
					track(win, wash(decor, C(235, 242, 255), 270, 0.86, 1, 53, UDim2.new(1, 0, 0, 22), UDim2.fromScale(0, 1), Vector2.new(0, 1)))
				end
				-- light garland along the top edge
				local colors = { RED, GOLD, GREEN, BLUE }
				local swags, per = full and 7 or 5, 8
				local hs = full and 26 or 18
				local pts = {}
				for i = 0, swags * per do
					local frac = (i % per) / per
					pts[#pts + 1] = { x = size.X * i / (swags * per), y = 3 + 6 * math.sin(math.pi * frac) }
				end
				for i = 1, #pts - 1 do
					local a, b = pts[i], pts[i + 1]
					local mx, my = (a.x + b.x) / 2, (a.y + b.y) / 2
					local len = math.sqrt((b.x - a.x) ^ 2 + (b.y - a.y) ^ 2)
					track(win, create("Frame", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromOffset(mx, my),
						Size = UDim2.fromOffset(len + 1, full and 2 or 1),
						Rotation = math.deg(math.atan2(b.y - a.y, b.x - a.x)),
						BackgroundColor3 = C(20, 74, 42),
						ZIndex = 55,
						Parent = decor,
					}))
				end
				win.SeasonBulbs = {}
				win.SeasonHalos = {}
				for i = 2, #pts - 1, 2 do
					local p = pts[i]
					local col = colors[math.floor(i / 2) % #colors + 1]
					local halo = track(win, glow(decor, col, hs, UDim2.fromOffset(p.x, p.y + 6), 54))
					local bulb = track(win, create("Frame", {
						AnchorPoint = Vector2.new(0.5, 0),
						Position = UDim2.fromOffset(p.x, p.y),
						Size = full and UDim2.fromOffset(8, 11) or UDim2.fromOffset(6, 6),
						BackgroundColor3 = col,
						ZIndex = 56,
						Parent = decor,
					}, { create("UICorner", { CornerRadius = UDim.new(0.5, 0) }) }))
					win.SeasonBulbs[#win.SeasonBulbs + 1] = bulb
					win.SeasonHalos[#win.SeasonHalos + 1] = halo
				end
				local orn, stars = {}, {}
				if full then
					-- hanging ornaments that sway
					local ocol = { RED, GOLD, BLUE, C(244, 114, 182) }
					for i = 4, #pts - 2, 6 do
						local p = pts[i]
						local len = math.random(14, 26)
						local root = track(win, create("Frame", {
							AnchorPoint = Vector2.new(0.5, 0),
							Position = UDim2.fromOffset(p.x, p.y + 6),
							Size = UDim2.fromOffset(14, len + 14),
							BackgroundTransparency = 1,
							ZIndex = 57,
							Parent = decor,
						}))
						create("Frame", {
							AnchorPoint = Vector2.new(0.5, 0),
							Position = UDim2.new(0.5, 0, 0, 0),
							Size = UDim2.fromOffset(1, len),
							BackgroundColor3 = C(230, 230, 235),
							BackgroundTransparency = 0.3,
							ZIndex = 57,
							Parent = root,
						})
						local ball = round(root, {
							AnchorPoint = Vector2.new(0.5, 0),
							Position = UDim2.new(0.5, 0, 0, len - 1),
							Size = UDim2.fromOffset(14, 14),
							BackgroundColor3 = ocol[(i % #ocol) + 1],
							ZIndex = 57,
						})
						round(ball, { Position = UDim2.fromOffset(3, 2), Size = UDim2.fromOffset(4, 4), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0.35, ZIndex = 58 })
						orn[#orn + 1] = { o = root, ph = rand(0, TAU) }
					end
					-- twinkling stars
					for i = 1, 7 do
						local s = glyph(decor, g.Star, math.random(10, 16), {
							AnchorPoint = Vector2.new(0.5, 0.5),
							Position = UDim2.new(rand(0.04, 0.96), 0, 0, rand(36, 150)),
							TextColor3 = (i % 2 == 0) and GOLD or C(255, 255, 255),
							ZIndex = 52,
						})
						track(win, s)
						stars[i] = { o = s, ph = rand(0, TAU), sp = rand(1.2, 3) }
					end
				end
				if cfg.Effects then
					addUpdater(win, function(_, t)
						for i, b in ipairs(win.SeasonBulbs) do
							local k = 0.5 + 0.5 * math.sin(t * 2.6 + i * 1.7)
							b.BackgroundTransparency = 0.4 * (1 - k)
							local halo = win.SeasonHalos[i]
							if halo then
								halo.Size = UDim2.fromOffset(hs * (0.75 + 0.45 * k), hs * (0.75 + 0.45 * k))
							end
						end
						for _, o in ipairs(orn) do
							o.o.Rotation = math.sin(t * 1.4 + o.ph) * 9
						end
						for _, s in ipairs(stars) do
							setAlpha(s.o, 0.7 - 0.65 * (0.5 + 0.5 * math.sin(t * s.sp + s.ph)))
						end
					end)
				end
				windowStroke(win, cfg, function(t)
					local k = (t * 0.25) % 3
					local a, b
					if k < 1 then
						a, b = RED, GOLD
					elseif k < 2 then
						a, b, k = GOLD, GREEN, k - 1
					else
						a, b, k = GREEN, RED, k - 2
					end
					return a:Lerp(b, k)
				end)
			end)
			for _, page in ipairs(win.Pages) do
				win:_seasonPage(page)
			end
		end

		if cfg.Effects then
			-- three depth layers of snow (small/slow/faint -> big/fast/bright)
			local n = math.floor((cfg.Max and 72 or full and 54 or 42) * cfg.Intensity)
			local flakes = {}
			for i = 1, n do
				local depth = (i % 3) + 1
				local s = 5 + depth * 4 + math.random(0, 3)
				local lbl
				if full then
					lbl = track(win, glyph(fx, pick(g.Flake), s, {
						AnchorPoint = Vector2.new(0.5, 0.5),
						ZIndex = 58 + depth,
						TextColor3 = C(240, 246, 255),
					}))
				else
					-- crisp round flakes: consistent at every resolution, no font dependency
					local d = depth + 1 + math.random(0, 1)
					lbl = track(win, round(fx, {
						AnchorPoint = Vector2.new(0.5, 0.5),
						Size = UDim2.fromOffset(d, d),
						BackgroundColor3 = C(240, 246, 255),
						ZIndex = 58 + depth,
					}))
				end
				setAlpha(lbl, (full and 0.78 or 0.82) - depth * 0.16 + rand(0, 0.1))
				flakes[i] = {
					o = lbl,
					x = math.random(),
					y = math.random(),
					vy = rand(0.04, 0.09) * depth,
					ph = rand(0, TAU),
					fr = rand(0.5, 1.4),
					amp = rand(0.004, 0.012) * depth,
					vr = rand(-50, 50),
					wind = 0.004 * depth,
				}
			end
			-- Santa's sleigh sweeps across now and then
			local sleigh = track(win, glyph(fx, g.Sleigh, 26, { AnchorPoint = Vector2.new(0.5, 0.5), ZIndex = 62 }))
			sleigh.Visible = false
			local sparks = {}
			for i = 1, 6 do
				local sp = track(win, glyph(fx, g.Sparkle, 12, { AnchorPoint = Vector2.new(0.5, 0.5), ZIndex = 61 }))
				sp.Visible = false
				sparks[i] = sp
			end
			local sl = { on = false, x = -0.1, y = 0.2, next = cfg.Max and rand(8, 16) or 1e9 }
			addUpdater(win, function(dt, t)
				for _, f in ipairs(flakes) do
					f.y = f.y + f.vy * dt
					f.x = f.x + f.wind * dt
					if f.y > 1.04 then
						f.y = -0.04
						f.x = math.random()
					end
					if f.x > 1.05 then
						f.x = -0.05
					end
					f.o.Position = UDim2.fromScale(f.x + math.sin(t * f.fr + f.ph) * f.amp, f.y)
					if full then
						f.o.Rotation = (f.o.Rotation + f.vr * dt) % 360
					end
				end
				if not sl.on then
					sl.next = sl.next - dt
					if sl.next <= 0 then
						sl.on, sl.x, sl.y = true, -0.08, rand(0.12, 0.45)
						sleigh.Visible = true
					end
				else
					sl.x = sl.x + 0.12 * dt
					local y = sl.y + math.sin(sl.x * 9) * 0.02
					sleigh.Position = UDim2.fromScale(sl.x, y)
					sleigh.Rotation = math.sin(sl.x * 9) * -8
					for i, sp in ipairs(sparks) do
						sp.Visible = true
						sp.Position = UDim2.fromScale(sl.x - i * 0.03, y + math.sin(t * 6 + i) * 0.015)
						setAlpha(sp, math.clamp(0.25 + i * 0.12, 0, 1))
					end
					if sl.x > 1.1 then
						sl.on, sl.next = false, rand(14, 26)
						sleigh.Visible = false
						for _, sp in ipairs(sparks) do
							sp.Visible = false
						end
					end
				end
			end)
		end
	end

	-- ---- Halloween -----------------------------------------------------------
	local function sectionHalloween(win, sec, g)
		if not sec.Card or sec.SeasonDecor then
			return
		end
		local holder = create("Frame", {
			Name = "SeasonDecor",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			LayoutOrder = -100,
			ZIndex = 4,
			Parent = sec.Card,
		})
		sec.SeasonDecor = holder
		local web = glyph(holder, g.Web, 28, { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -4, 0, -8), Rotation = 90, ZIndex = 5 })
		setAlpha(web, 0.3)
		if not (win.SeasonCfg and win.SeasonCfg.Full) then
			setAlpha(web, 0.55)
			return
		end
		-- little slime drips off the top edge
		for i = 1, (win.SeasonCfg and win.SeasonCfg.Max) and 3 or 0 do
			round(holder, {
				Position = UDim2.new(rand(0.08, 0.7), 0, 0, -3),
				Size = UDim2.fromOffset(math.random(5, 8), math.random(8, 16)),
				BackgroundColor3 = C(112, 190, 20),
				BackgroundTransparency = 0.15,
				ZIndex = 4,
			})
		end
		local n = (sec.Tab and #sec.Tab.Sections) or 1
		if n % 2 == 0 then
			glyph(holder, g.Pumpkin, 18, { Position = UDim2.new(0, 10, 0, -14), Rotation = -12, ZIndex = 5 })
		else
			glyph(holder, g.Candle, 16, { Position = UDim2.new(0, 10, 0, -13), ZIndex = 5 })
		end
	end

	local function buildHalloween(win, cfg, S, layers)
		local g = S.Glyphs
		local size = px(win)
		local decor, fx = layers.decor, layers.fx
		local ORANGE, PURPLE = C(255, 117, 24), C(150, 70, 220)
		local full = cfg.Full

		if cfg.Decor then
			pcall(function()
				-- colour wash: ember-orange at the top, haunted purple at the bottom
				track(win, wash(decor, ORANGE, 90, full and 0.9 or 0.93, 1, 47, UDim2.new(1, 0, 0.4, 0)))
				track(win, wash(decor, PURPLE, 270, full and 0.88 or 0.92, 1, 47, UDim2.new(1, 0, 0.45, 0), UDim2.fromScale(0, 1), Vector2.new(0, 1)))

				local logoBox = win.LogoText and win.LogoText.Parent
				local avatar = win.AvatarImage and win.AvatarImage.Parent
				if logoBox and logoBox.Parent then
					track(win, glyph(logoBox.Parent, g.Pumpkin, 22, { Position = UDim2.fromOffset(44, 6), Rotation = 14, ZIndex = 8 }))
				end
				if full and avatar and avatar.Parent then
					track(win, glyph(avatar.Parent, g.Pumpkin, 20, { Position = UDim2.fromOffset(40, 10), Rotation = 10, ZIndex = 8 }))
				end
				-- pale moon with a halo, tucked into the top-right corner
				local moonHalo = track(win, glow(decor, C(255, 236, 190), 150, UDim2.new(1, -52, 0, 70), 49))
				local moon = track(win, round(decor, {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.new(1, -52, 0, 70),
					Size = UDim2.fromOffset(54, 54),
					BackgroundColor3 = C(255, 240, 205),
					BackgroundTransparency = 0.25,
					ZIndex = 50,
				}))
				for _, c in ipairs({ { 12, 14, 9 }, { 30, 26, 7 }, { 22, 36, 5 } }) do
					round(moon, { Position = UDim2.fromOffset(c[1], c[2]), Size = UDim2.fromOffset(c[3], c[3]), BackgroundColor3 = C(220, 205, 170), BackgroundTransparency = 0.45, ZIndex = 51 })
				end
				-- cobwebs in every corner
				local corners = {
					{ Vector2.new(0, 0), UDim2.fromScale(0, 0), 0 },
					{ Vector2.new(1, 0), UDim2.fromScale(1, 0), 90 },
					{ Vector2.new(1, 1), UDim2.fromScale(1, 1), 180 },
					{ Vector2.new(0, 1), UDim2.fromScale(0, 1), 270 },
				}
				for idx, c in ipairs(corners) do
					if full or idx == 1 or idx == 3 then
						local w = track(win, glyph(decor, g.Web, full and 68 or 56, { AnchorPoint = c[1], Position = c[2], Rotation = c[3], ZIndex = 55 }))
						setAlpha(w, full and 0.38 or 0.55)
					end
				end
				if full then
					-- tombstones + candles along the sidebar bottom
					for i, x in ipairs({ 14, 58, 104, 156, 204 }) do
						local isTomb = i % 2 == 1
						track(win, glyph(decor, isTomb and g.Tomb or g.Candle, isTomb and 22 or 16, {
							AnchorPoint = Vector2.new(0, 1),
							Position = UDim2.new(0, x, 1, isTomb and -76 or -78),
							ZIndex = 53,
						}))
					end
				end
				-- slime dripping from the top edge
				local slime = C(112, 190, 20)
				if full then
					track(win, create("Frame", {
						Size = UDim2.new(1, 0, 0, 5),
						BackgroundColor3 = slime,
						ZIndex = 55,
						Parent = decor,
					}))
				else
					-- clean: a soft ember glow along the top edge instead of slime
					track(win, wash(decor, ORANGE, 90, 0.72, 1, 55, UDim2.new(1, 0, 0, 20)))
					track(win, create("Frame", { Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = ORANGE, BackgroundTransparency = 0.55, ZIndex = 55, Parent = decor }))
				end
				local drips = {}
				local x = 30
				while full and x < size.X - 30 do
					local w = math.random(7, 12)
					local body = track(win, create("Frame", {
						Position = UDim2.fromOffset(x, 3),
						Size = UDim2.fromOffset(w, 12),
						BackgroundColor3 = slime,
						ZIndex = 55,
						Parent = decor,
					}, { create("UICorner", { CornerRadius = UDim.new(1, 0) }) }))
					drips[#drips + 1] = { o = body, base = rand(8, 24), ph = rand(0, TAU), sp = rand(0.5, 1.2) }
					x = x + math.random(46, 130)
				end
				local thread, spider
				if full then
					-- dangling spider
					thread = track(win, create("Frame", {
						Position = UDim2.new(0, size.X * 0.585, 0, 0),
						Size = UDim2.fromOffset(1, 40),
						BackgroundColor3 = C(200, 200, 210),
						BackgroundTransparency = 0.3,
						ZIndex = 55,
						Parent = decor,
					}))
					spider = track(win, glyph(decor, g.Spider, 20, {
						AnchorPoint = Vector2.new(0.5, 0),
						Position = UDim2.new(0, size.X * 0.585, 0, 38),
						ZIndex = 56,
					}))
				end
				-- pairs of eyes that blink in the dark
				local eyes = {}
				for i = 1, full and 4 or 0 do
					local ex, ey = rand(0.3, 0.95), rand(0.55, 0.92)
					local pair = track(win, create("Frame", {
						BackgroundTransparency = 1,
						Position = UDim2.fromScale(ex, ey),
						Size = UDim2.fromOffset(26, 8),
						ZIndex = 51,
						Parent = decor,
					}))
					local col = (i % 2 == 0) and C(255, 220, 60) or C(255, 80, 60)
					round(pair, { Size = UDim2.fromOffset(8, 5), BackgroundColor3 = col, ZIndex = 51 })
					round(pair, { Position = UDim2.fromOffset(16, 0), Size = UDim2.fromOffset(8, 5), BackgroundColor3 = col, ZIndex = 51 })
					eyes[i] = { o = pair, next = rand(2, 9), open = true, t0 = 0 }
					pair.Visible = false
				end
				-- lightning flash
				local flash = track(win, create("Frame", {
					Size = UDim2.fromScale(1, 1),
					BackgroundColor3 = C(235, 225, 255),
					BackgroundTransparency = 1,
					ZIndex = 62,
					Parent = decor,
				}))
				local fl = { next = rand(10, 20), phase = 0 }

				if cfg.Effects then
					addUpdater(win, function(dt, t)
						for _, d in ipairs(drips) do
							local l = d.base + 5 * math.sin(t * d.sp + d.ph)
							d.o.Size = UDim2.fromOffset(d.o.Size.X.Offset, l)
						end
						if thread then
							local len = 34 + 22 * (0.5 + 0.5 * math.sin(t * 0.8))
							thread.Size = UDim2.fromOffset(1, len)
							spider.Position = UDim2.new(0, size.X * 0.585, 0, len - 2)
						end
						for _, e in ipairs(eyes) do
							e.next = e.next - dt
							if e.next <= 0 then
								e.open = not e.open
								e.o.Visible = e.open
								e.next = e.open and rand(1.2, 3) or rand(3, 9)
							end
						end
						-- lightning: two quick flashes, then a long pause
						fl.next = fl.next - dt
						if fl.next <= 0 and fl.phase == 0 then
							fl.phase, fl.t = 1, 0
						end
						if fl.phase > 0 then
							fl.t = fl.t + dt
							local a = 1
							if fl.t < 0.07 then
								a = 0.82
							elseif fl.t < 0.15 then
								a = 1
							elseif fl.t < 0.22 then
								a = 0.86
							elseif fl.t < 0.5 then
								a = 0.86 + (fl.t - 0.22) / 0.28 * 0.14
							else
								fl.phase, fl.next = 0, rand(12, 28)
							end
							flash.BackgroundTransparency = a
						end
						local k = 0.5 + 0.5 * math.sin(t * 0.6)
						moon.BackgroundTransparency = 0.25 + 0.1 * k
					end)
					-- fog banks
					local fogs = {}
					for i = 1, full and 3 or 2 do
						local f = track(win, create("Frame", {
							AnchorPoint = Vector2.new(0, 1),
							Position = UDim2.fromScale(-0.3, 1),
							Size = UDim2.new(1.6, 0, 0, 90 + i * 24),
							BackgroundColor3 = i == 2 and C(170, 110, 200) or C(150, 120, 190),
							ZIndex = 52,
							Parent = decor,
						}, {
							create("UIGradient", {
								Rotation = 90,
								Transparency = NumberSequence.new({
									NumberSequenceKeypoint.new(0, 1),
									NumberSequenceKeypoint.new(1, 0.84 - i * 0.02),
								}),
							}),
						}))
						fogs[i] = { o = f, sp = (i % 2 == 0 and -1 or 1) * (0.006 + i * 0.004), x = -0.1 - i * 0.12 }
					end
					addUpdater(win, function(dt)
						for _, f in ipairs(fogs) do
							f.x = f.x + f.sp * dt
							if f.x > -0.05 then
								f.sp = -math.abs(f.sp)
							elseif f.x < -0.55 then
								f.sp = math.abs(f.sp)
							end
							f.o.Position = UDim2.fromScale(f.x, 1)
						end
					end)
				end
				windowStroke(win, cfg, function(t)
					return ORANGE:Lerp(PURPLE, 0.5 + 0.5 * math.sin(t * 1.3))
				end)
			end)
			for _, page in ipairs(win.Pages) do
				win:_seasonPage(page)
			end
		end

		if cfg.Effects then
			local embers = {}
			for i = 1, math.floor((full and 30 or 24) * cfg.Intensity) do
				local s = math.random(10, 20)
				local ecol = (i % 3 == 0) and C(255, 200, 60) or C(255, 120, 40)
				local o
				if full then
					o = track(win, glyph(fx, g.Ember, s, { AnchorPoint = Vector2.new(0.5, 0.5), ZIndex = 60, TextColor3 = ecol }))
				else
					local d = math.random(2, 4)
					o = track(win, round(fx, { AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(d, d), BackgroundColor3 = ecol, ZIndex = 60 }))
				end
				embers[i] = { o = o, x = math.random(), y = math.random(), vy = -rand(0.04, 0.13), ph = rand(0, TAU), amp = rand(0.004, 0.016) }
			end
			local bats = {}
			for i = 1, math.max(2, math.floor((cfg.Max and 9 or full and 5 or 3) * cfg.Intensity)) do
				local o = track(win, glyph(fx, g.Bat, math.random(16, 28), { AnchorPoint = Vector2.new(0.5, 0.5), ZIndex = 61 }))
				bats[i] = { o = o, x = rand(-0.2, 1.1), y = rand(0.08, 0.7), vx = rand(0.06, 0.18), ph = rand(0, TAU) }
			end
			local ghosts = {}
			for i = 1, math.max(1, math.floor((cfg.Max and 4 or full and 2 or 1) * cfg.Intensity)) do
				local o = track(win, glyph(fx, g.Ghost, math.random(24, 36), { AnchorPoint = Vector2.new(0.5, 0.5), ZIndex = 59 }))
				ghosts[i] = { o = o, x = rand(0.1, 0.9), y = rand(0.2, 1.1), vy = -rand(0.015, 0.04), ph = rand(0, TAU) }
			end
			addUpdater(win, function(dt, t)
				for _, e in ipairs(embers) do
					e.y = e.y + e.vy * dt
					if e.y < -0.05 then
						e.y = 1.05
						e.x = math.random()
					end
					e.o.Position = UDim2.fromScale(e.x + math.sin(t + e.ph) * e.amp, e.y)
					setAlpha(e.o, math.clamp(0.15 + (1 - e.y) * 0.8, 0, 1))
				end
				for _, b in ipairs(bats) do
					b.x = b.x + b.vx * dt
					if b.x > 1.1 then
						b.x = -0.1
						b.y = rand(0.08, 0.7)
					end
					b.o.Position = UDim2.fromScale(b.x, b.y + math.sin(t * 3 + b.ph) * 0.03)
					b.o.Rotation = math.sin(t * 7 + b.ph) * 16
				end
				for _, gh in ipairs(ghosts) do
					gh.y = gh.y + gh.vy * dt
					if gh.y < -0.1 then
						gh.y = 1.1
						gh.x = rand(0.1, 0.9)
					end
					gh.o.Position = UDim2.fromScale(gh.x + math.sin(t * 0.7 + gh.ph) * 0.03, gh.y)
					setAlpha(gh.o, 0.5 + 0.2 * math.sin(t * 1.6 + gh.ph))
				end
			end)
		end
	end

	-- ---- public API ----------------------------------------------------------
	local function normalizeCfg(cfg)
		local out = { Theme = true, Effects = true, Decor = true, Intensity = 1, Screen = false, Style = "Classic" }
		if type(cfg) == "table" then
			for k, v in pairs(cfg) do
				out[k] = v
			end
		end
		out.Intensity = math.clamp(tonumber(out.Intensity) or 1, 0.1, 4)
		local lv = ({ subtle = 1, clean = 1, classic = 2, festive = 3 })[tostring(out.Style):lower()] or 2
		out.Level = lv
		out.Full = lv >= 2 -- rich decorations (garland, ornaments, hats, tombstones...)
		out.Max = lv >= 3 -- everything: hats on every icon, card slime, sleigh, extra particles
		return out
	end

	function WindowClass:_seasonPage(page)
		local name = self.Season
		local S = name and Seasons[name]
		if not S or not self.SeasonCfg or not self.SeasonCfg.Decor then
			return
		end
		pcall(function()
			if name == "Christmas" and self.SeasonCfg.Max and page.NavButton and not page.SeasonHat then
				page.SeasonHat = santaHat(page.NavButton, 14, UDim2.fromOffset(8, 1), -20, 6)
				track(self, page.SeasonHat)
			end
			for _, tab in ipairs(page.Tabs) do
				for _, sec in ipairs(tab.Sections) do
					if not sec.SeasonDecor then
						if name == "Christmas" then
							sectionChristmas(self, sec, S.Glyphs)
						else
							sectionHalloween(self, sec, S.Glyphs)
						end
						if sec.SeasonDecor then
							track(self, sec.SeasonDecor)
						end
					end
				end
			end
		end)
	end

	function WindowClass:GetSeason()
		return self.Season
	end

	function WindowClass:SetSeason(name, cfg)
		if name == false or name == "" or name == "None" or name == "Off" then
			name = nil
		end
		if name ~= nil and not Seasons[name] then
			warn("[ReduceUI] unknown season: " .. tostring(name))
			return false
		end
		local hadTheme = self.SeasonCfg and self.SeasonCfg.Theme and self.Season ~= nil
		fxClear(self)
		for _, page in ipairs(self.Pages) do
			page.SeasonHat = nil
			for _, tab in ipairs(page.Tabs) do
				for _, sec in ipairs(tab.Sections) do
					sec.SeasonDecor = nil
				end
			end
		end
		for _, n in ipairs({ "SeasonFXDecor", "SeasonFXParticles" }) do
			local old = self[n]
			if old then
				old:Destroy()
				self[n] = nil
			end
		end
		self.ParticleLayer = nil
		self.Season = name
		if not name then
			self.SeasonCfg = nil
			if hadTheme then
				Library:SetTheme("Default")
			else
				runBinds()
			end
			return true
		end
		local S = Seasons[name]
		local c = normalizeCfg(cfg)
		self.SeasonCfg = c
		if c.Theme then
			Library:SetTheme(S.Preset)
		end
		local decor = newLayer(self.Main, "SeasonDecor", 50, false)
		self.SeasonFXDecor = decor
		local fx
		if c.Screen then
			fx = newLayer(self.Gui, "SeasonParticles", 1, false)
		else
			fx = newLayer(self.Main, "SeasonParticles", 49, true)
		end
		self.SeasonFXParticles = fx
		self.ParticleLayer = fx
		local layers = { decor = decor, fx = fx }
		self.FXObjects = self.FXObjects or {}
		self.FXUpdaters = self.FXUpdaters or {}
		if name == "Christmas" then
			buildChristmas(self, c, S, layers)
		else
			buildHalloween(self, c, S, layers)
		end
		if #self.FXUpdaters > 0 then
			startLoop(self)
		end
		return true
	end

	-- decorate pages / sections that are created after the season is enabled
	local origAddPage = WindowClass.AddPage
	function WindowClass:AddPage(...)
		local page = origAddPage(self, ...)
		if self.Season then
			self:_seasonPage(page)
		end
		return page
	end
	local origTabAdd = TabClass.AddSection
	function TabClass:AddSection(...)
		local sec = origTabAdd(self, ...)
		local win = self.Page and self.Page.Window
		if win and win.Season then
			win:_seasonPage(self.Page)
		end
		return sec
	end

	-- season emoji in notification titles
	local origNotify = WindowClass.Notify
	function WindowClass:Notify(opts)
		local S = self.Season and Seasons[self.Season]
		if S and self.SeasonCfg and self.SeasonCfg.Full and type(opts) == "table" and not opts.NoSeasonIcon and not isAsset(S.Emoji) then
			local copy = {}
			for k, v in pairs(opts) do
				copy[k] = v
			end
			copy.Title = S.Emoji .. " " .. tostring(opts.Title or "Notice")
			opts = copy
		end
		return origNotify(self, opts)
	end

	-- the owner switches it on in CreateWindow
	local origCreate = Library.CreateWindow
	function Library:CreateWindow(opts)
		local win = origCreate(self, opts)
		opts = opts or {}
		win.SizePx = opts.Size or Vector2.new(1000, 640)
		local name, cfg
		if opts.Season and Seasons[opts.Season] then
			name, cfg = opts.Season, opts.SeasonConfig
		elseif opts.Halloween then
			name, cfg = "Halloween", opts.Halloween
		elseif opts.Christmas then
			name, cfg = "Christmas", opts.Christmas
		end
		if name then
			win:SetSeason(name, type(cfg) == "table" and cfg or opts.SeasonConfig)
		end
		return win
	end
end


return Library
