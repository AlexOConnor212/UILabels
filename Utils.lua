-- UILabels - Utility Functions
-- Helper functions used throughout the addon

UILabels = UILabels or {}
UILabels.Utils = {}

-- Deep copy a table
function UILabels.Utils:DeepCopy(orig)
    local orig_type = type(orig)
    local copy
    
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[self:DeepCopy(orig_key)] = self:DeepCopy(orig_value)
        end
        setmetatable(copy, self:DeepCopy(getmetatable(orig)))
    else
        copy = orig
    end
    
    return copy
end

-- Check if pfUI is loaded
function UILabels.Utils:IsPfUILoaded()
    return pfUI ~= nil
end

-- Check if a font file exists
function UILabels.Utils:FontExists(path)
    -- Try to create a temporary font string with the font
    local test = UIParent:CreateFontString()
    local success = test:SetFont(path, 10)
    test:Hide()
    return success
end

-- Get the best available font path
function UILabels.Utils:GetBestFontPath()
    -- Try pfUI font first
    if self:FontExists(UILabels.Defaults.FONT_PATH) then
        return UILabels.Defaults.FONT_PATH
    end
    
    -- Fall back to Blizzard font
    return UILabels.Defaults.FALLBACK_FONT
end

-- Clamp position to screen bounds
function UILabels.Utils:ClampPosition(x, y, frameWidth, frameHeight)
    local screenWidth = GetScreenWidth()
    local screenHeight = GetScreenHeight()
    
    frameWidth = frameWidth or 100
    frameHeight = frameHeight or 20
    
    -- Clamp X
    local minX = -screenWidth/2 + frameWidth/2
    local maxX = screenWidth/2 - frameWidth/2
    x = math.max(minX, math.min(maxX, x))
    
    -- Clamp Y
    local minY = -screenHeight/2 + frameHeight/2
    local maxY = screenHeight/2 - frameHeight/2
    y = math.max(minY, math.min(maxY, y))
    
    return x, y
end

-- Print message to chat
function UILabels.Utils:Print(message)
    DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99UILabels:|r " .. message)
end

-- Debug print (only if debug mode enabled)
function UILabels.Utils:Debug(message)
    if UILabelsDB and UILabelsDB.debug then
        self:Print("|cffff9933[DEBUG]|r " .. message)
    end
end

-- Serialize a table to string (simple version)
function UILabels.Utils:Serialize(tbl, indent)
    indent = indent or 0
    local result = "{\n"
    local indentStr = string.rep("  ", indent + 1)
    
    for k, v in pairs(tbl) do
        result = result .. indentStr
        
        -- Key
        if type(k) == "string" then
            result = result .. '["' .. k .. '"] = '
        else
            result = result .. "[" .. k .. "] = "
        end
        
        -- Value
        if type(v) == "table" then
            result = result .. self:Serialize(v, indent + 1)
        elseif type(v) == "string" then
            result = result .. '"' .. v .. '"'
        else
            result = result .. tostring(v)
        end
        
        result = result .. ",\n"
    end
    
    result = result .. string.rep("  ", indent) .. "}"
    return result
end

-- RGB to Hex color conversion
function UILabels.Utils:RGBToHex(r, g, b)
    return string.format("%02x%02x%02x", r * 255, g * 255, b * 255)
end

-- Hex to RGB color conversion
function UILabels.Utils:HexToRGB(hex)
    hex = hex:gsub("#", "")
    return tonumber("0x" .. hex:sub(1,2)) / 255,
           tonumber("0x" .. hex:sub(3,4)) / 255,
           tonumber("0x" .. hex:sub(5,6)) / 255
end

-- Get screen resolution info
function UILabels.Utils:GetScreenInfo()
    return {
        width = GetScreenWidth(),
        height = GetScreenHeight(),
        scale = UIParent:GetEffectiveScale(),
    }
end