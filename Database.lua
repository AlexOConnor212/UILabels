-- UILabels - Database Management
-- Handles SavedVariables initialization, validation, and migration

UILabels = UILabels or {}
UILabels.Database = {}

-- Initialize the database
function UILabels.Database:Initialize()
    -- Initialize account-wide database
    if not UILabelsDB then
        UILabelsDB = UILabels.Utils:DeepCopy(UILabels.Defaults.DB)
        UILabels.Utils:Print("Database initialized with defaults")
    end
    
    -- Initialize per-character database
    if not UILabelsCharDB then
        UILabelsCharDB = UILabels.Utils:DeepCopy(UILabels.Defaults.CharDB)
    end
    
    -- Validate and migrate
    self:Validate()
    self:Migrate()
    
    -- Load active profile
    self:LoadProfile(UILabelsDB.activeProfile)
    
    -- First run setup
    if UILabelsDB.firstRun then
        self:FirstRunSetup()
    end
end

-- Validate database structure
function UILabels.Database:Validate()
    UILabels.Utils:Debug("Validating database...")
    
    -- Ensure required fields exist
    UILabelsDB.version = UILabelsDB.version or UILabels.Defaults.VERSION
    UILabelsDB.labels = UILabelsDB.labels or {}
    UILabelsDB.globalSettings = UILabelsDB.globalSettings or UILabels.Utils:DeepCopy(UILabels.Defaults.GlobalSettings)
    UILabelsDB.profiles = UILabelsDB.profiles or {["Default"] = {labels = {}}}
    UILabelsDB.activeProfile = UILabelsDB.activeProfile or "Default"
    
    -- Validate each label
    for id, label in pairs(UILabelsDB.labels) do
        if type(label) ~= "table" then
            UILabels.Utils:Print("Warning: Invalid label " .. id .. " - removing")
            UILabelsDB.labels[id] = nil
        else
            -- Ensure required fields
            label.id = label.id or id
            label.text = label.text or "Label"
            label.x = label.x or 0
            label.y = label.y or 100
            label.fontSize = label.fontSize or 12
            label.color = label.color or {r=1, g=1, b=0}
            label.visible = (label.visible ~= false)  -- Default to true
        end
    end
end

-- Migrate database between versions
function UILabels.Database:Migrate()
    local currentVersion = UILabelsDB.version
    local targetVersion = UILabels.Defaults.VERSION
    
    if currentVersion == targetVersion then
        return
    end
    
    UILabels.Utils:Print("Migrating database from " .. currentVersion .. " to " .. targetVersion)
    
    -- Add version-specific migrations here
    -- Example:
    -- if currentVersion == "0.9.0" then
    --     self:MigrateFrom_0_9_0()
    -- end
    
    UILabelsDB.version = targetVersion
end

-- First run setup - load default presets
function UILabels.Database:FirstRunSetup()
    UILabels.Utils:Debug("Running first-run setup...")
    
    -- Load "Default" preset
    local preset = UILabels.Defaults.Presets["Default"]
    if preset then
        for _, labelConfig in ipairs(preset) do
            local newID = self:GetNextLabelID()
            local label = UILabels.Defaults:CreateLabel(labelConfig)
            UILabelsDB.labels[newID] = label
        end
    end
    
    UILabels.Utils:Print("Created default label")
end

-- Get label data
function UILabels.Database:GetLabel(labelID)
    return UILabelsDB.labels[labelID]
end

-- Set label data
function UILabels.Database:SetLabel(labelID, data)
    UILabelsDB.labels[labelID] = data
end

-- Delete label
function UILabels.Database:DeleteLabel(labelID)
    UILabelsDB.labels[labelID] = nil
end

-- Get all labels
function UILabels.Database:GetAllLabels()
    return UILabelsDB.labels
end

-- Create new label
function UILabels.Database:CreateNewLabel()
    local newID = UILabels.Defaults:GetNextLabelID(UILabelsDB.labels)
    local newLabel = UILabels.Defaults:CreateLabel({
        id = newID,
        text = "New Label",
    })
    
    UILabelsDB.labels[newID] = newLabel
    return newID, newLabel
end

-- Reset to defaults
function UILabels.Database:ResetToDefaults()
    UILabelsDB.labels = {}
    UILabelsDB.globalSettings = UILabels.Utils:DeepCopy(UILabels.Defaults.GlobalSettings)
    UILabelsDB.firstRun = true
    self:FirstRunSetup()
    UILabels.Utils:Print("Database reset to defaults")
end

-- Profile management
function UILabels.Database:SaveProfile(profileName)
    profileName = profileName or UILabelsDB.activeProfile
    
    UILabelsDB.profiles[profileName] = {
        labels = UILabels.Utils:DeepCopy(UILabelsDB.labels),
        globalSettings = UILabels.Utils:DeepCopy(UILabelsDB.globalSettings),
    }
    
    UILabels.Utils:Print("Profile '" .. profileName .. "' saved")
end

function UILabels.Database:LoadProfile(profileName)
    if not UILabelsDB.profiles[profileName] then
        UILabels.Utils:Print("Profile '" .. profileName .. "' not found")
        return false
    end
    
    local profile = UILabelsDB.profiles[profileName]
    UILabelsDB.labels = UILabels.Utils:DeepCopy(profile.labels)
    UILabelsDB.globalSettings = UILabels.Utils:DeepCopy(profile.globalSettings or UILabels.Defaults.GlobalSettings)
    UILabelsDB.activeProfile = profileName
    
    UILabels.Utils:Print("Profile '" .. profileName .. "' loaded")
    return true
end

function UILabels.Database:DeleteProfile(profileName)
    if profileName == "Default" then
        UILabels.Utils:Print("Cannot delete Default profile")
        return false
    end
    
    if profileName == UILabelsDB.activeProfile then
        UILabels.Utils:Print("Cannot delete active profile")
        return false
    end
    
    UILabelsDB.profiles[profileName] = nil
    UILabels.Utils:Print("Profile '" .. profileName .. "' deleted")
    return true
end

function UILabels.Database:GetProfileNames()
    local names = {}
    for name, _ in pairs(UILabelsDB.profiles) do
        table.insert(names, name)
    end
    table.sort(names)
    return names
end