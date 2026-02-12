-- UILabels - Default Configuration
-- Contains default settings and templates

UILabels = UILabels or {}
UILabels.Defaults = {}

-- Current addon version
UILabels.Defaults.VERSION = "1.0.0"

-- Default font path with pfUI fallback
UILabels.Defaults.FONT_PATH = "Interface\\AddOns\\pfUI\\fonts\\Myriad-Pro.ttf"
UILabels.Defaults.FALLBACK_FONT = "Fonts\\FRIZQT__.ttf"

-- Default label template
UILabels.Defaults.LabelTemplate = {
    id = 0,
    text = "Label",
    x = 0,
    y = 100,
    fontSize = 12,
    fontPath = nil,  -- nil uses global default
    color = {r = 1, g = 1, b = 0},  -- Yellow
    outline = "OUTLINE",
    visible = true,
    anchor = "BOTTOM",
    relativePoint = "BOTTOM",
}

-- Default global settings
UILabels.Defaults.GlobalSettings = {
    defaultFont = UILabels.Defaults.FONT_PATH,
    defaultColor = {r = 1, g = 1, b = 0},
    defaultFontSize = 12,
    defaultOutline = "OUTLINE",
    frameStrata = "HIGH",
    editMode = false,
}
-- Preset configurations
UILabels.Defaults.Presets = {
    ["Default"] = {
        { text = "Hello World", x = 0, y = 0, fontSize = 14, anchor = "CENTER", relativePoint = "CENTER" }
    }
}

-- Default account-wide database
UILabels.Defaults.DB = {
    version = UILabels.Defaults.VERSION,
    labels = {},
    globalSettings = UILabels.Defaults.GlobalSettings,
    profiles = {
        ["Default"] = {
            labels = {},
        },
    },
    activeProfile = "Default",
    firstRun = true,
}

-- Default per-character database
UILabels.Defaults.CharDB = {
    enabledLabels = {},  -- Empty means all enabled
    overrides = {},
}

-- Function to create a new label with defaults
function UILabels.Defaults:CreateLabel(overrides)
    local label = UILabels.Utils:DeepCopy(self.LabelTemplate)
    
    if overrides then
        for k, v in pairs(overrides) do
            if type(v) == "table" and type(label[k]) == "table" then
                for k2, v2 in pairs(v) do
                    label[k][k2] = v2
                end
            else
                label[k] = v
            end
        end
    end
    
    return label
end

-- Function to get next available label ID
function UILabels.Defaults:GetNextLabelID(labels)
    local maxID = 0
    for id, _ in pairs(labels) do
        if id > maxID then
            maxID = id
        end
    end
    return maxID + 1
end