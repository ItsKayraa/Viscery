--[[

VISCERY - 1.0
Hey! I see you're using Viscery. I don't think you could do anything without knowing the API...

Check out Viscery API!

Link: 

]]




local VISCERY_CONFIGURATION = {
    UIConfig = {
        AutoAnchorPoint = {
            Enabled = true,
            Position = Vector2.new(0.5, 0.5) -- Recommending to set the anchor point 0.5 so you don't get the middle point of the UI to be top left. But keep in mind that you would need to set the position of background frame to 0.5, 0.5 if you set this.
        },
        DefaultPosition = UDim2.new(0.5, 0, 0.5, 0),
        DefaultSize = UDim2.new(0.5, 0.5, 0.5, 0.5),

        DefaultBackgroundColor = Color3.fromRGB(189, 225, 236),
        DefaultTextColor = Color3.fromRGB(3, 0, 32),
        DefaultImageColor = Color3.new(1, 1, 1),

        DefaultBorderThickness = 2,
        DefaultBorderColor = Color3.fromRGB(0, 0, 0),
        DefaultBorderRadius = 16,

        DefaultImageId = "rbxassetid://9762988755", -- <- Placeholder image id | https://create.roblox.com/store/asset/9762988767/placeholder
        DefaultText = "Text",
        DefaultPlaceholderText = "Type here..."
    },

    AddonConfig = {
        logEnabled = true,
        logV = "number", -- This can be "string", but Roblox doesn't tags numbers so I would recommend to keep it like this.
        logCodes = {
            viscery = {0, "VISCERY"},
            visceryFail = {1, "FAIL"},

            visc = {2, "VISC"},
            linkSignal = {3, "LINKSIGNAL"},
            writeParent = {4, "WRITEPARENT"},
            writeDisplay = {5, "WRITEDISPLAY"},
            
            partDoesntExists = {6, "PARTDOESNTEXISTS"},
            parentDoesntExists = {7, "PARENTDOESNTEXISTS"},
        },
        supportsTableColors = true, -- For color tables like {r, g, b}
    }
}

local function getLogId(logType)
    local id = VISCERY_CONFIGURATION.AddonConfig.logCodes[logType][1]
    if VISCERY_CONFIGURATION.AddonConfig.logV ~= "number" then id = VISCERY_CONFIGURATION.AddonConfig.logCodes[logType][2] end
    return "["..id.."]"
end

local function logDebug(logType)
    if VISCERY_CONFIGURATION.AddonConfig.logEnabled then
        print(getLogId("viscery")..getLogId(logType))
    end
end

local function parseColor(colorProp)
    if VISCERY_CONFIGURATION.AddonConfig.supportsTableColors and typeof(colorProp) == "table"
and colorProp.R
and colorProp.G
and colorProp.B then
        return Color3.fromRGB(colorProp.R, colorProp.G, colorProp.B)
    end

    return colorProp
end

local function createCorner(parent, radius)
    local corner = Instance.new("UICorner")
    f(corner)

    corner.Parent = parent
    corner.CornerRadius = UDim.new(0, radius) or UDim.new(0, VISCERY_CONFIGURATION.UIConfig.DefaultBorderRadius)
end

local function clearDisplay(disp)
    for _, part in ipairs(f(disp):GetChildren()) do
        part:Destroy()
    end
end

local function createBorder(parent, thickness, color, borderMode)
    if not thickness then return end
    local border = Instance.new("UIStroke")
    f(border)

    border.Parent = parent
    border.Thickness = thickness or VISCERY_CONFIGURATION.UIConfig.DefaultBorderThickness
    border.ApplyStrokeMode = borderMode
    border.Color = parseColor(color) or VISCERY_CONFIGURATION.UIConfig.DefaultBorderColor
end

local ignored = {
    BorderThickness = true,
    BorderColor = true,
    BorderRadius = true,
    TextBorderThickness = true,
    TextBorderColor = true,
    BackgroundColor = true,
    Size = true,
    Position = true,
    Children = true,
}

local function applyCommon(instance, props)
    createBorder(instance, props.BorderThickness, props.BorderColor, Enum.ApplyStrokeMode.Border)
    createCorner(instance, props.BorderRadius)

    instance.BackgroundColor3 = parseColor(props.BackgroundColor) or VISCERY_CONFIGURATION.UIConfig.DefaultBackgroundColor
    instance.Position = props.Position or VISCERY_CONFIGURATION.UIConfig.DefaultPosition
    instance.Size = props.Size or VISCERY_CONFIGURATION.UIConfig.DefaultSize

    for property, value in pairs(props) do
        if not ignored[property] and instance[property] ~= nil then
            instance[property] = value
        end
    end

    if VISCERY_CONFIGURATION.UIConfig.AutoAnchorPoint.Enabled then
        instance.AnchorPoint = VISCERY_CONFIGURATION.UIConfig.AutoAnchorPoint.Position
    end
end

local function applyTextCommon(instance, props)
    createBorder(
        instance,
        props.TextBorderThickness,
        props.TextBorderColor,
        Enum.ApplyStrokeMode.Contextual
    )

    instance.Text = props.Text or VISCERY_CONFIGURATION.UIConfig.DefaultText
    instance.TextColor3 = parseColor(props.TextColor) or parseColor(VISCERY_CONFIGURATION.UIConfig.DefaultTextColor)
    instance.Font = props.Font or Enum.Font.SourceSans
end

local function applyImageCommon(instance, props)
    instance.Image = props.Image or VISCERY_CONFIGURATION.UIConfig.DefaultImageId
    instance.ImageColor3 = parseColor(props.ImageColor) or VISCERY_CONFIGURATION.UIConfig.DefaultImageColor
end

-- Functions for each className
local viscClasses = {
    ["Frame"] = function(props)
        local frame = Instance.new("Frame")

        applyCommon(frame, props)

        return frame
    end,

    ["TextLabel"] = function(props)
        local label = Instance.new("TextLabel")

        applyCommon(label, props)
        applyTextCommon(label, props)

        return label
    end,

    ["TextButton"] = function(props)
        local button = Instance.new("TextButton")

        applyCommon(button, props)
        applyTextCommon(button, props)

        return button
    end,

    ["TextBox"] = function(props)
        local box = Instance.new("TextBox")

        applyCommon(box, props)
        applyTextCommon(box, props)

        box.PlaceholderText = props.PlaceholderText or VISCERY_CONFIGURATION.UIConfig.DefaultPlaceholderText
        box.PlaceholderColor3 = parseColor(props.PlaceholderTextColor) or Color3.fromRGB(150, 150, 150)

        return box
    end,

    ["ImageLabel"] = function(props)
        local label = Instance.new("ImageLabel")

        applyCommon(label, props)
        applyImageCommon(label, props)

        return label
    end,

    ["ImageButton"] = function(props)
        local button = Instance.new("ImageButton")

        applyCommon(button, props)
        applyImageCommon(button, props)

        return button
    end,
}

-- Visc Creator
local function visc(className)
    logDebug("visc")
    
    if viscClasses[className] then return viscClasses[className] end

    return function(props)
        local instance = Instance.new(className)

        for k, v in pairs(props) do
            instance[k] = v
        end

        return instance
    end
end

local function display(props)
    logDebug("writeDisplay")
    if not props.Parent and props.Face then logDebug("visceryFail") return end

    local destPart = f(props.Parent)
    if not destPart then logDebug("partDoesntExists") return end
    clearDisplay(props.Parent)

    local Gui = Instance.new("SurfaceGui")
    f(Gui)

    Gui.Parent = destPart
    Gui.Face = Enum.NormalId[props.Face]

    return Gui
end 

local function writeParent(props)
    logDebug("writeParent")
    if not props.Display or not props.Item then logDebug("parentDoesntExists") return end

    if not workspace:GetDescendants()[props.Item] then
        f(props.Item)
    end

    props.Item.Parent = props.Display
end

--The visc you gave must have the RBXSignalEvent called "MouseButton1Click" e.g. TextButton, ImageButton, ...
local function clickTrigger(props)
    logDebug("linkSignal")
    if not props.Button or not props.Event() then logDebug("visceryFail") return end -- check if the user gave event and name

    props.Button.MouseButton1Click:Connect(props.Event()) -- connect it considering it has the RBXSignalEvent "MouseButton1Click"
    return props.Button
end

-- For signals

local function signalledVisc(viscItems)
    return visc(viscItems.className)(viscItems.props)
end

local function signalledDisplay(displayItems)
    return display(displayItems)
end

local function signalledWriteParent(parentItems)
    return writeParent(parentItems)
end

local function signalledClickTrigger(clickItems)
    return clickTrigger(clickItems)
end

-- Signal Events

signalReceived("visc", function()
    return signalledVisc
end)

signalReceived("display", function()
    return signalledDisplay
end)

signalReceived("writeParent", function()
    return signalledWriteParent
end)

signalReceived("clickTrigger", function()
    return signalledClickTrigger
end)
