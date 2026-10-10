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
	Halloween = {
		Accent = Color3.fromRGB(255, 140, 40),
		Background = Color3.fromRGB(8, 6, 10),
		Sidebar = Color3.fromRGB(12, 8, 14),
		Card = Color3.fromRGB(18, 14, 20),
		Input = Color3.fromRGB(11, 8, 13),
		Active = Color3.fromRGB(55, 30, 12),
		Stroke = Color3.fromRGB(48, 32, 18),
		StrokeLight = Color3.fromRGB(120, 65, 25),
		Text = Color3.fromRGB(255, 248, 240),
		Muted = Color3.fromRGB(175, 155, 135),
		Dim = Color3.fromRGB(120, 100, 85),
		Dot = Color3.fromRGB(110, 70, 35),
		Notes = {
			Green = { Text = Color3.fromRGB(255, 140, 40), Bg = Color3.fromRGB(50, 28, 10) },
			Yellow = { Text = Color3.fromRGB(255, 200, 60), Bg = Color3.fromRGB(55, 40, 10) },
			Red = { Text = Color3.fromRGB(255, 80, 70), Bg = Color3.fromRGB(55, 18, 18) },
			Gray = { Text = Color3.fromRGB(170, 150, 135), Bg = Color3.fromRGB(30, 26, 28) },
			Blue = { Text = Color3.fromRGB(160, 140, 255), Bg = Color3.fromRGB(26, 20, 50) },
		},
	},
	Christmas = {
		Accent = Color3.fromRGB(230, 50, 50),
		Background = Color3.fromRGB(6, 10, 12),
		Sidebar = Color3.fromRGB(8, 14, 12),
		Card = Color3.fromRGB(14, 20, 18),
		Input = Color3.fromRGB(9, 13, 12),
		Active = Color3.fromRGB(25, 55, 35),
		Stroke = Color3.fromRGB(28, 45, 38),
		StrokeLight = Color3.fromRGB(50, 110, 70),
		Text = Color3.fromRGB(250, 252, 250),
		Muted = Color3.fromRGB(150, 175, 160),
		Dim = Color3.fromRGB(100, 120, 110),
		Dot = Color3.fromRGB(60, 120, 80),
		Notes = {
			Green = { Text = Color3.fromRGB(50, 220, 110), Bg = Color3.fromRGB(12, 48, 28) },
			Yellow = { Text = Color3.fromRGB(255, 215, 50), Bg = Color3.fromRGB(50, 42, 10) },
			Red = { Text = Color3.fromRGB(255, 90, 90), Bg = Color3.fromRGB(55, 18, 18) },
			Gray = { Text = Color3.fromRGB(155, 170, 160), Bg = Color3.fromRGB(28, 32, 30) },
			Blue = { Text = Color3.fromRGB(140, 220, 255), Bg = Color3.fromRGB(14, 30, 48) },
		},
	},
}
local DefaultTheme = {}
for k, v in pairs(Theme) do
	if k ~= "Notes" then
		DefaultTheme[k] = v
	end
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

-- High-quality seasonal decorations (procedural + curated assets)
local SEASONAL_IMAGES = {
	-- Curated public assets (thumbnail endpoint for reliable UI load)
	Bat = "rbxthumb://type=Asset&id=13915312936&w=150&h=150",
	Moon = "rbxthumb://type=Asset&id=5758643056&w=150&h=150",
	Pumpkin = "rbxthumb://type=Asset&id=5634829236&w=150&h=150",
	Web = "rbxthumb://type=Asset&id=18912486432&w=420&h=420",
	Snowflake = "rbxthumb://type=Asset&id=6034320993&w=150&h=150",
	Tree = "rbxthumb://type=Asset&id=15171016920&w=150&h=150",
	SantaHat = "rbxthumb://type=Asset&id=15224275868&w=150&h=150",
}

local function fxImg(parent, image, size, pos, anchor, trans, z, color, rot)
	local s = typeof(size) == "number" and UDim2.fromOffset(size, size) or size
	return create("ImageLabel", {
		BackgroundTransparency = 1,
		Image = image,
		Size = s,
		Position = pos or UDim2.new(),
		AnchorPoint = anchor or Vector2.new(0, 0),
		ImageTransparency = trans or 0.15,
		ImageColor3 = color or Color3.new(1, 1, 1),
		Rotation = rot or 0,
		ScaleType = Enum.ScaleType.Fit,
		ZIndex = z or 1,
		Parent = parent,
	})
end

local function softCircle(parent, size, pos, color, trans, z)
	return create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = pos,
		Size = UDim2.fromOffset(size, size),
		BackgroundColor3 = color,
		BackgroundTransparency = trans,
		ZIndex = z or 0,
		Parent = parent,
	}, { corner(math.ceil(size / 2)) })
end

-- Simple bat silhouette built from frames (always works, no asset dependency)
local function makeBatSilhouette(parent, size, pos, trans)
	local holder = create("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(size, size * 0.55),
		Position = pos,
		ZIndex = 2,
		Parent = parent,
	})
	local body = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.55),
		Size = UDim2.fromOffset(size * 0.28, size * 0.22),
		BackgroundColor3 = Color3.fromRGB(18, 14, 20),
		BackgroundTransparency = trans,
		ZIndex = 3,
		Parent = holder,
	}, { corner(size * 0.12) })
	-- left wing
	local lw = create("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.fromScale(0.42, 0.45),
		Size = UDim2.fromOffset(size * 0.42, size * 0.28),
		BackgroundColor3 = Color3.fromRGB(18, 14, 20),
		BackgroundTransparency = trans,
		Rotation = -18,
		ZIndex = 2,
		Parent = holder,
	}, { corner(4) })
	-- right wing
	local rw = create("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.fromScale(0.58, 0.45),
		Size = UDim2.fromOffset(size * 0.42, size * 0.28),
		BackgroundColor3 = Color3.fromRGB(18, 14, 20),
		BackgroundTransparency = trans,
		Rotation = 18,
		ZIndex = 2,
		Parent = holder,
	}, { corner(4) })
	-- head
	create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.28),
		Size = UDim2.fromOffset(size * 0.18, size * 0.16),
		BackgroundColor3 = Color3.fromRGB(18, 14, 20),
		BackgroundTransparency = trans,
		ZIndex = 3,
		Parent = holder,
	}, { corner(size * 0.08) })
	return holder, lw, rw
end

local function spawnHalloweenEffects(parent, connections)
	local layer = create("Frame", {
		Name = "SeasonalFX",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ZIndex = 0,
		ClipsDescendants = true,
		Parent = parent,
	})

	-- deep night overlay
	create("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.fromRGB(4, 2, 8),
		BackgroundTransparency = 0.72,
		ZIndex = 0,
		Parent = layer,
	})

	-- large ambient orange glows (screenshot-style atmosphere)
	local glowSpots = {
		{ 0.15, 0.2, 160, 0.93 }, { 0.45, 0.35, 200, 0.95 },
		{ 0.75, 0.15, 140, 0.92 }, { 0.85, 0.7, 180, 0.94 },
		{ 0.25, 0.75, 150, 0.93 }, { 0.55, 0.55, 120, 0.95 },
	}
	for i, g in ipairs(glowSpots) do
		local orb = softCircle(layer, g[3], UDim2.new(g[1], 0, g[2], 0), Color3.fromRGB(255, 120, 30), g[4], 0)
		task.spawn(function()
			local phase = i * 0.9
			while orb.Parent do
				local t = os.clock() + phase
				orb.BackgroundTransparency = g[4] - 0.02 + math.sin(t * 0.5) * 0.025
				task.wait(0.1)
			end
		end)
	end

	-- bright moon with glow
	local moonGlow = softCircle(layer, 110, UDim2.new(0.82, 0, 0.1, 0), Color3.fromRGB(255, 230, 180), 0.88, 0)
	local moon = softCircle(layer, 70, UDim2.new(0.82, 0, 0.1, 0), Color3.fromRGB(255, 250, 230), 0.05, 1)
	-- crater / crescent cut
	create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.855, 0, 0.085, 0),
		Size = UDim2.fromOffset(48, 48),
		BackgroundColor3 = Color3.fromRGB(8, 6, 10),
		BackgroundTransparency = 0.35,
		ZIndex = 2,
		Parent = layer,
	}, { corner(24) })
	task.spawn(function()
		while moonGlow.Parent do
			local t = os.clock()
			moonGlow.BackgroundTransparency = 0.86 + math.sin(t * 0.4) * 0.03
			task.wait(0.12)
		end
	end)

	-- dense bat flock (procedural silhouettes — always visible)
	local batData = {
		{ 0.05, 0.06, 34 }, { 0.14, 0.03, 26 }, { 0.24, 0.08, 30 },
		{ 0.36, 0.02, 22 }, { 0.48, 0.07, 36 }, { 0.58, 0.04, 24 },
		{ 0.68, 0.09, 28 }, { 0.9, 0.05, 32 }, { 0.1, 0.15, 20 },
		{ 0.3, 0.14, 18 }, { 0.52, 0.16, 22 }, { 0.75, 0.13, 26 },
		{ 0.92, 0.18, 20 }, { 0.42, 0.11, 16 }, { 0.18, 0.2, 18 },
	}
	for i, b in ipairs(batData) do
		local holder, lw, rw = makeBatSilhouette(layer, b[3], UDim2.new(b[1], 0, b[2], 0), 0.12 + (i % 4) * 0.04)
		task.spawn(function()
			local bx, by = b[1], b[2]
			local phase = i * 0.55
			local speed = 0.35 + (i % 5) * 0.07
			while holder.Parent do
				local t = os.clock() + phase
				holder.Position = UDim2.new(bx + math.sin(t * speed) * 0.03, 0, by + math.sin(t * (speed + 0.15)) * 0.018, 0)
				holder.Rotation = math.sin(t * 1.1) * 10
				-- wing flap
				if lw and rw then
					lw.Rotation = -18 + math.sin(t * 4.5) * 14
					rw.Rotation = 18 - math.sin(t * 4.5) * 14
				end
				task.wait(0.033)
			end
		end)
	end

	-- corner spider webs (image + radial line fallback)
	local function addWeb(anchor, pos, rot, size)
		local web = fxImg(layer, SEASONAL_IMAGES.Web, size, pos, anchor, 0.5, 1, Color3.fromRGB(210, 200, 190), rot)
		-- extra radial threads for density if image is sparse
		local threads = create("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(size * 0.7, size * 0.7),
			AnchorPoint = anchor,
			Position = pos,
			Rotation = rot,
			ZIndex = 1,
			Parent = layer,
		})
		for a = 0, 5 do
			local ang = a * 30 - 15
			create("Frame", {
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.new(0.48, 0, 0, 1),
				BackgroundColor3 = Color3.fromRGB(180, 170, 160),
				BackgroundTransparency = 0.7,
				Rotation = ang,
				ZIndex = 1,
				Parent = threads,
			})
		end
		return web
	end
	addWeb(Vector2.new(0, 0), UDim2.fromOffset(-8, -8), -10, 130)
	addWeb(Vector2.new(1, 0), UDim2.new(1, 8, 0, -6), 12, 120)
	addWeb(Vector2.new(0, 1), UDim2.new(0, -10, 1, 6), 18, 110)

	-- glowing jack-o-lanterns bottom-left
	for i = 1, 4 do
		local px = 0.02 + (i - 1) * 0.06
		local py = 0.87 + (i % 2) * 0.025
		local glow = softCircle(layer, 36 + i * 4, UDim2.new(px + 0.02, 0, py + 0.02, 0), Color3.fromRGB(255, 140, 30), 0.75, 1)
		local pk = fxImg(layer, SEASONAL_IMAGES.Pumpkin, 26 + i * 5, UDim2.new(px, 0, py, 0), nil, 0.05, 3, Color3.fromRGB(255, 200, 100))
		task.spawn(function()
			local phase = i * 1.3
			while pk.Parent do
				local t = os.clock() + phase
				pk.Rotation = math.sin(t * 0.6) * 6
				glow.BackgroundTransparency = 0.7 + math.sin(t * 1.2) * 0.08
				task.wait(0.06)
			end
		end)
	end

	-- floating orange ember particles
	for i = 1, 14 do
		local ember = softCircle(
			layer,
			3 + math.random(0, 4),
			UDim2.new(math.random() * 0.9 + 0.05, 0, math.random() * 0.7 + 0.15, 0),
			Color3.fromRGB(255, 150 + math.random(0, 60), 40),
			0.25 + math.random() * 0.35,
			2
		)
		task.spawn(function()
			local x = ember.Position.X.Scale
			local y = ember.Position.Y.Scale
			local phase = math.random() * 8
			while ember.Parent do
				local t = os.clock() + phase
				y = y - 0.004
				if y < -0.05 then
					y = 0.95
					x = math.random() * 0.9 + 0.05
				end
				ember.Position = UDim2.new(x + math.sin(t * 0.8) * 0.012, 0, y, 0)
				ember.BackgroundTransparency = 0.2 + math.abs(math.sin(t * 2)) * 0.4
				task.wait(0.05)
			end
		end)
	end

	return layer
end

local function spawnChristmasEffects(parent, connections)
	local layer = create("Frame", {
		Name = "SeasonalFX",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ZIndex = 0,
		ClipsDescendants = true,
		Parent = parent,
	})

	-- cool winter overlay
	create("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.fromRGB(2, 8, 12),
		BackgroundTransparency = 0.78,
		ZIndex = 0,
		Parent = layer,
	})

	-- festive colored glows
	local glows = {
		{ 0.12, 0.2, Color3.fromRGB(230, 40, 40), 160 },
		{ 0.4, 0.4, Color3.fromRGB(30, 180, 80), 180 },
		{ 0.7, 0.18, Color3.fromRGB(255, 200, 40), 140 },
		{ 0.88, 0.65, Color3.fromRGB(230, 40, 40), 150 },
		{ 0.25, 0.72, Color3.fromRGB(30, 180, 80), 130 },
	}
	for i, g in ipairs(glows) do
		local orb = softCircle(layer, g[4], UDim2.new(g[1], 0, g[2], 0), g[3], 0.93, 0)
		task.spawn(function()
			local phase = i * 0.8
			while orb.Parent do
				local t = os.clock() + phase
				orb.BackgroundTransparency = 0.91 + math.sin(t * 0.55) * 0.03
				task.wait(0.1)
			end
		end)
	end

	-- string lights along top edge
	local lightColors = {
		Color3.fromRGB(255, 60, 60),
		Color3.fromRGB(50, 220, 90),
		Color3.fromRGB(255, 210, 40),
		Color3.fromRGB(80, 180, 255),
		Color3.fromRGB(255, 120, 200),
	}
	for i = 1, 22 do
		local c = lightColors[((i - 1) % #lightColors) + 1]
		local bulb = softCircle(layer, 7, UDim2.new(0.04 + (i - 1) * 0.043, 0, 0.02 + math.sin(i * 0.7) * 0.008, 0), c, 0.15, 3)
		local halo = softCircle(layer, 16, bulb.Position, c, 0.85, 2)
		halo.AnchorPoint = Vector2.new(0.5, 0.5)
		task.spawn(function()
			local phase = i * 0.35
			while bulb.Parent do
				local t = os.clock() + phase
				local pulse = 0.08 + math.abs(math.sin(t * 2.2)) * 0.25
				bulb.BackgroundTransparency = pulse
				halo.BackgroundTransparency = 0.78 + pulse * 0.15
				task.wait(0.08)
			end
		end)
	end
	-- light wire
	create("Frame", {
		Position = UDim2.new(0.03, 0, 0.018, 0),
		Size = UDim2.new(0.94, 0, 0, 1),
		BackgroundColor3 = Color3.fromRGB(60, 50, 40),
		BackgroundTransparency = 0.55,
		ZIndex = 1,
		Parent = layer,
	})

	-- dense falling snow
	for i = 1, 48 do
		local sz = 2 + math.random(0, 6)
		local isBig = i % 6 == 0
		local flake
		if isBig then
			flake = fxImg(
				layer,
				SEASONAL_IMAGES.Snowflake,
				10 + math.random(0, 10),
				UDim2.new(math.random() * 1.05 - 0.02, 0, -0.15 - math.random() * 0.5, 0),
				Vector2.new(0.5, 0.5),
				0.15 + math.random() * 0.35,
				2,
				Color3.fromRGB(255, 255, 255)
			)
		else
			flake = softCircle(
				layer,
				sz,
				UDim2.new(math.random() * 1.05 - 0.02, 0, -0.15 - math.random() * 0.5, 0),
				Color3.fromRGB(255, 255, 255),
				0.1 + math.random() * 0.4,
				2
			)
		end
		task.spawn(function()
			local x = flake.Position.X.Scale
			local speed = 0.028 + math.random() * 0.075
			local sway = 0.25 + math.random() * 0.55
			local phase = math.random() * 14
			while flake.Parent do
				local t = os.clock() + phase
				local y = flake.Position.Y.Scale + speed * 0.016
				if y > 1.15 then
					y = -0.1
					x = math.random() * 1.05 - 0.02
				end
				flake.Position = UDim2.new(x + math.sin(t * sway) * 0.012, 0, y, 0)
				if isBig then
					flake.Rotation = t * 22
				end
				task.wait(0.033)
			end
		end)
	end

	-- santa hats, trees, gifts in corners (larger, more present)
	local decos = {
		{ SEASONAL_IMAGES.SantaHat, 0.02, 0.04, 42, Color3.fromRGB(255, 255, 255), -8 },
		{ SEASONAL_IMAGES.Tree, 0.09, 0.015, 38, Color3.fromRGB(180, 255, 180), 5 },
		{ SEASONAL_IMAGES.Snowflake, 0.78, 0.025, 26, Color3.fromRGB(255, 255, 255), 0 },
		{ SEASONAL_IMAGES.Tree, 0.88, 0.02, 36, Color3.fromRGB(160, 255, 160), -5 },
		{ SEASONAL_IMAGES.SantaHat, 0.02, 0.86, 40, Color3.fromRGB(255, 255, 255), 8 },
		{ SEASONAL_IMAGES.Tree, 0.9, 0.85, 40, Color3.fromRGB(170, 255, 170), -6 },
		{ SEASONAL_IMAGES.SantaHat, 0.92, 0.08, 34, Color3.fromRGB(255, 255, 255), 12 },
	}
	for i, d in ipairs(decos) do
		local el = fxImg(layer, d[1], d[4], UDim2.new(d[2], 0, d[3], 0), nil, 0.05, 3, d[5], d[6])
		-- soft glow under decoration
		softCircle(layer, d[4] + 10, UDim2.new(d[2] + 0.015, 0, d[3] + 0.02, 0), Color3.fromRGB(255, 200, 150), 0.9, 1)
		task.spawn(function()
			local phase = i * 0.9
			while el.Parent do
				local t = os.clock() + phase
				el.Rotation = d[6] + math.sin(t * 0.7) * 7
				el.ImageTransparency = 0.03 + math.sin(t * 0.45) * 0.04
				task.wait(0.07)
			end
		end)
	end

	-- floating gift sparkles
	for i = 1, 12 do
		local sp = softCircle(
			layer,
			3 + math.random(0, 3),
			UDim2.new(math.random() * 0.9 + 0.05, 0, math.random() * 0.6 + 0.2, 0),
			lightColors[((i - 1) % #lightColors) + 1],
			0.3,
			2
		)
		task.spawn(function()
			local x = sp.Position.X.Scale
			local y = sp.Position.Y.Scale
			local phase = math.random() * 6
			while sp.Parent do
				local t = os.clock() + phase
				sp.Position = UDim2.new(x + math.sin(t * 0.6) * 0.02, 0, y + math.cos(t * 0.5) * 0.015, 0)
				sp.BackgroundTransparency = 0.2 + math.abs(math.sin(t * 2.5)) * 0.5
				task.wait(0.06)
			end
		end)
	end

	return layer
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
	self.Season = nil

	local size = opts.Size or Vector2.new(1000, 640)
	local lp = Players.LocalPlayer
	local userOpts = opts.User or {}

	-- Seasonal themes (opt-in by script owner)
	if opts.Halloween == true then
		self.Season = "Halloween"
		Library:SetTheme("Halloween")
	elseif opts.Christmas == true then
		self.Season = "Christmas"
		Library:SetTheme("Christmas")
	end

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

	if self.Season == "Halloween" then
		spawnHalloweenEffects(main, self.Connections)
	elseif self.Season == "Christmas" then
		spawnChristmasEffects(main, self.Connections)
	end

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
	local logoText = opts.Logo or "R"
	if opts.Logo == nil and opts.LogoIcon == nil then
		if self.Season == "Halloween" then
			logoText = "R"
		elseif self.Season == "Christmas" then
			logoText = "R"
		end
	end
	self.LogoText = newLabel({
		Size = UDim2.fromScale(1, 1),
		Text = logoText,
		Font = FONT_BOLD,
		TextSize = 18,
		TextXAlignment = Enum.TextXAlignment.Center,
		Parent = logoBox,
	})
	self.LogoIcon = newIcon(logoBox, opts.LogoIcon, 22, UDim2.fromScale(0.5, 0.5), Vector2.new(0.5, 0.5), "Text")
	self.LogoIcon:SetShown(opts.LogoIcon ~= nil)
	self.LogoText.Visible = opts.LogoIcon == nil
	-- seasonal logo box tint
	if self.Season == "Halloween" then
		bind(logoBox, function()
			logoBox.BackgroundColor3 = Theme.Accent:Lerp(Theme.Card, 0.55)
		end)
	elseif self.Season == "Christmas" then
		bind(logoBox, function()
			logoBox.BackgroundColor3 = Theme.Accent:Lerp(Theme.Card, 0.6)
		end)
	end
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
	local toastStroke = toast:FindFirstChildOfClass("UIStroke")
	local sc = create("UIScale", { Scale = 0.9, Parent = toast })
	if self.IsCanvas then
		toast.GroupTransparency = 1
	else
		toast.BackgroundTransparency = 1
		if toastStroke then
			toastStroke.Transparency = 1
		end
	end
	local titleLbl = newLabel({
		Size = UDim2.new(1, 0, 0, 16),
		Text = opts.Title or "Notice",
		Font = FONT_MED,
		TextSize = 13,
		TextColor3 = accent,
		LayoutOrder = 1,
		Parent = toast,
	})
	local bodyLbl = newLabel({
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
	if not self.IsCanvas then
		titleLbl.TextTransparency = 1
		bodyLbl.TextTransparency = 1
	end
	create("Frame", {
		Size = UDim2.new(1, 0, 0, 8),
		BackgroundTransparency = 1,
		LayoutOrder = 3,
		Parent = toast,
	})
	local duration = opts.Duration or 4
	if self.IsCanvas then
		tween(toast, 0.3, { GroupTransparency = 0 })
	else
		tween(toast, 0.3, { BackgroundTransparency = 0 })
		if toastStroke then
			tween(toastStroke, 0.3, { Transparency = 0 })
		end
		tween(titleLbl, 0.3, { TextTransparency = 0 })
		tween(bodyLbl, 0.3, { TextTransparency = 0 })
	end
	tween(sc, 0.4, { Scale = 1 }, Enum.EasingStyle.Back)
	task.delay(duration, function()
		if not toast.Parent then
			return
		end
		if self.IsCanvas then
			tween(toast, 0.22, { GroupTransparency = 1 })
		else
			tween(toast, 0.22, { BackgroundTransparency = 1 })
			tween(titleLbl, 0.22, { TextTransparency = 1 })
			tween(bodyLbl, 0.22, { TextTransparency = 1 })
		end
		if toastStroke then
			tween(toastStroke, 0.18, { Transparency = 1 })
		end
		tween(sc, 0.22, { Scale = 0.9 })
		task.delay(0.24, function()
			if toast.Parent then
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

return Library
