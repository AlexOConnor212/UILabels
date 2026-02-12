-- UILabels - Label Management
-- Creates, updates, and manages label frames

UILabels = UILabels or {}
UILabels.Labels = {}

-- Storage for created label frames
UILabels.Labels.frames = {}
UILabels.Labels.editMode = false

-- Create a single label frame
function UILabels.Labels:CreateLabel(labelID, config)
    -- Destroy existing if present
    if self.frames[labelID] then
        self:DestroyLabel(labelID)
    end
    
    -- Create parent frame
    local parent = CreateFrame("Frame", "UILabels_Label_" .. labelID, UIParent)
    parent:SetFrameStrata(UILabelsDB.globalSettings.frameStrata or "HIGH")
    parent:SetFrameLevel(100)
    parent:SetWidth(1)
    parent:SetHeight(1)
    parent:SetPoint(config.anchor or "BOTTOM", UIParent, config.relativePoint or "BOTTOM", config.x, config.y)
    
    -- Create font string
    local fontString = parent:CreateFontString(nil, "OVERLAY")
    fontString:SetPoint(config.anchor or "BOTTOM", UIParent, config.relativePoint or "BOTTOM", config.x, config.y)
    
    -- Set font
    local fontPath = config.fontPath or UILabelsDB.globalSettings.defaultFont or UILabels.Utils:GetBestFontPath()
    local fontSize = config.fontSize or UILabelsDB.globalSettings.defaultFontSize or 12
    local outline = config.outline or UILabelsDB.globalSettings.defaultOutline or "OUTLINE"
    
    local success = fontString:SetFont(fontPath, fontSize, outline)
    if not success then
        -- Fallback to default font
        fontString:SetFont(UILabels.Defaults.FALLBACK_FONT, fontSize, outline)
        UILabels.Utils:Debug("Font failed for label " .. labelID .. ", using fallback")
    end
    
    -- Set text and color
    fontString:SetText(config.text or "")
    
    local color = config.color or UILabelsDB.globalSettings.defaultColor or {r=1, g=1, b=0}
    fontString:SetTextColor(color.r, color.g, color.b)
    
    -- Set visibility
    if config.visible == false then
        parent:Hide()
    else
        parent:Show()
    end
    
    -- Store references
    parent.fontString = fontString
    parent.config = config
    parent.labelID = labelID
    
    -- Make draggable if in edit mode
    if self.editMode then
        self:MakeDraggable(parent)
    end
    
    self.frames[labelID] = parent
    
    return parent
end

-- Create all labels from database
function UILabels.Labels:CreateAllLabels()
    local labels = UILabels.Database:GetAllLabels()
    
    for labelID, config in pairs(labels) do
        self:CreateLabel(labelID, config)
    end
    
    UILabels.Utils:Debug("Created " .. self:GetLabelCount() .. " labels")
end

-- Update an existing label
function UILabels.Labels:UpdateLabel(labelID, config)
    local frame = self.frames[labelID]
    
    if not frame then
        -- Label doesn't exist, create it
        self:CreateLabel(labelID, config)
        return
    end
    
    local fontString = frame.fontString
    
    -- Update position
    fontString:ClearAllPoints()
    fontString:SetPoint(config.anchor or "BOTTOM", UIParent, config.relativePoint or "BOTTOM", config.x, config.y)
    
    -- Update font
    local fontPath = config.fontPath or UILabelsDB.globalSettings.defaultFont or UILabels.Utils:GetBestFontPath()
    local fontSize = config.fontSize or 12
    local outline = config.outline or "OUTLINE"
    
    fontString:SetFont(fontPath, fontSize, outline)
    
    -- Update text and color
    fontString:SetText(config.text or "")
    
    local color = config.color or {r=1, g=1, b=0}
    fontString:SetTextColor(color.r, color.g, color.b)
    
    -- Update visibility
    if config.visible == false then
        frame:Hide()
    else
        frame:Show()
    end
    
    -- Update stored config
    frame.config = config
end

-- Destroy a label
function UILabels.Labels:DestroyLabel(labelID)
    local frame = self.frames[labelID]
    
    if frame then
        frame:Hide()
        frame.fontString = nil
        frame:SetScript("OnMouseDown", nil)
        frame:SetScript("OnMouseUp", nil)
        frame:SetScript("OnDragStart", nil)
        frame:SetScript("OnDragStop", nil)
        frame = nil
        self.frames[labelID] = nil
    end
end

-- Refresh all labels (destroy and recreate)
function UILabels.Labels:RefreshAllLabels()
    -- Destroy all
    for labelID, _ in pairs(self.frames) do
        self:DestroyLabel(labelID)
    end
    
    -- Recreate all
    self:CreateAllLabels()
    
    UILabels.Utils:Debug("Labels refreshed")
end

-- Show all labels
function UILabels.Labels:ShowAllLabels()
    for _, frame in pairs(self.frames) do
        frame:Show()
    end
end

-- Hide all labels
function UILabels.Labels:HideAllLabels()
    for _, frame in pairs(self.frames) do
        frame:Hide()
    end
end

-- Get label count
function UILabels.Labels:GetLabelCount()
    local count = 0
    for _ in pairs(self.frames) do
        count = count + 1
    end
    return count
end

-- Toggle edit mode
function UILabels.Labels:ToggleEditMode()
    self.editMode = not self.editMode
    
    if self.editMode then
        UILabels.Utils:Print("Edit mode |cff00ff00ENABLED|r - Drag labels to reposition")
        
        -- Make all labels draggable
        for _, frame in pairs(self.frames) do
            self:MakeDraggable(frame)
        end
    else
        UILabels.Utils:Print("Edit mode |cffff0000DISABLED|r - Positions saved")
        
        -- Remove draggable functionality
        for _, frame in pairs(self.frames) do
            self:MakeNonDraggable(frame)
        end
    end
end

-- Enable edit mode
function UILabels.Labels:EnableEditMode()
    if not self.editMode then
        self:ToggleEditMode()
    end
end

-- Disable edit mode
function UILabels.Labels:DisableEditMode()
    if self.editMode then
        self:ToggleEditMode()
    end
end

-- Make a label draggable
function UILabels.Labels:MakeDraggable(frame)
    local fontString = frame.fontString
    local config = frame.config
    
    -- Get text width
    local textWidth = fontString:GetStringWidth()
    
    -- Estimate height based on font size
    local fontSize = config.fontSize or 12
    local textHeight = fontSize + 4
    
    -- Set frame size
    local frameWidth = textWidth + 8
    local frameHeight = textHeight + 8
    
    -- Calculate offset needed to keep text in same visual position
    -- The frame anchor is at the bottom, but we want the fontstring centered
    -- So we need to offset by half the frame height
    local anchor = config.anchor or "BOTTOM"
    local relativePoint = config.relativePoint or config.anchor or "BOTTOM"
    
    -- Calculate Y offset based on anchor point
    local yOffset = 0
    if anchor == "BOTTOM" or anchor == "BOTTOMLEFT" or anchor == "BOTTOMRIGHT" then
        yOffset = frameHeight / 2
    elseif anchor == "TOP" or anchor == "TOPLEFT" or anchor == "TOPRIGHT" then
        yOffset = -frameHeight / 2
    end
    
    frame:SetWidth(frameWidth)
    frame:SetHeight(frameHeight)
    
    -- Position frame with offset to keep text in same spot
    frame:ClearAllPoints()
    frame:SetPoint(anchor, UIParent, relativePoint, config.x, config.y - yOffset)
    
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    
    -- Create visual indicator background
    if not frame.editBorder then
        frame.editBorder = frame:CreateTexture(nil, "BACKGROUND")
        frame.editBorder:SetTexture(0, 1, 0, 0.3)
        frame.editBorder:SetAllPoints(frame)
    end
    frame.editBorder:Show()
    
    -- Center the fontstring in the frame
    fontString:ClearAllPoints()
    fontString:SetPoint("CENTER", frame, "CENTER", 0, 0)
    
    -- Store the offset for later use
    frame.editModeYOffset = yOffset
    
    frame:SetScript("OnDragStart", function()
        this:StartMoving()
    end)
    
    frame:SetScript("OnDragStop", function()
        this:StopMovingOrSizing()
        
        -- Get position of the frame
        local _, _, _, x, y = this:GetPoint(1)
        
        -- Add back the offset to get the actual fontstring position
        local actualY = y + (this.editModeYOffset or 0)
        
        -- Store the position
        this.config.x = math.floor(x + 0.5)
        this.config.y = math.floor(actualY + 0.5)
        
        -- Save to database
        UILabels.Database:SetLabel(this.labelID, this.config)
        
        UILabels.Utils:Print("Label #" .. this.labelID .. " moved to " .. this.config.x .. ", " .. this.config.y)
    end)
end

-- Make a label non-draggable
function UILabels.Labels:MakeNonDraggable(frame)
    frame:EnableMouse(false)
    frame:SetMovable(false)
    frame:RegisterForDrag()
    
    if frame.editBorder then
        frame.editBorder:Hide()
    end
    
    -- Get config (already saved by OnDragStop)
    local config = frame.config
    
    -- Reset frame to minimal size
    frame:SetWidth(1)
    frame:SetHeight(1)
    
    -- Reposition frame using saved coordinates
    frame:ClearAllPoints()
    frame:SetPoint(config.anchor or "BOTTOM", UIParent, config.relativePoint or "BOTTOM", config.x, config.y)
    
    -- Reposition fontstring to its proper anchor
    frame.fontString:ClearAllPoints()
    frame.fontString:SetPoint(config.anchor or "BOTTOM", UIParent, config.relativePoint or "BOTTOM", config.x, config.y)
    
    frame:SetScript("OnDragStart", nil)
    frame:SetScript("OnDragStop", nil)
end