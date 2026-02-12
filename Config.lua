-- UILabels - Configuration UI
-- Creates the configuration interface using pfUI API

UILabels = UILabels or {}
UILabels.Config = {}

-- Main config frame
UILabels.Config.frame = nil
UILabels.Config.isOpen = false
UILabels.Config.selectedLabelID = nil

-- Toggle config UI
function UILabels.Config:Toggle()
    if self.isOpen then
        self:Hide()
    else
        self:Show()
    end
end

-- Show config UI
function UILabels.Config:Show()
    if not self.frame then
        local success, err = pcall(function()
            self:CreateUI()
        end)
        
        if not success then
            UILabels.Utils:Print("Error creating UI: " .. tostring(err))
            return
        end
    end
    
    self.frame:Show()
    self:RefreshLabelList()
    self.isOpen = true
end

-- Hide config UI
function UILabels.Config:Hide()
    if self.frame then
        -- Clear focus from all input fields
        if self.editorPanel then
            if self.editorPanel.textInput then
                self.editorPanel.textInput:ClearFocus()
            end
            if self.editorPanel.xInput then
                self.editorPanel.xInput:ClearFocus()
            end
            if self.editorPanel.yInput then
                self.editorPanel.yInput:ClearFocus()
            end
            if self.editorPanel.sizeInput then
                self.editorPanel.sizeInput:ClearFocus()
            end
        end
        
        self.frame:Hide()
    end
    self.isOpen = false
end

-- Create the UI using pfUI
function UILabels.Config:CreateUI()
    -- Main frame
    local frame = CreateFrame("Frame", "UILabelsConfigFrame", UIParent)
    frame:SetWidth(600)
    frame:SetHeight(450)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    frame:SetFrameStrata("DIALOG")
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    
    -- Apply pfUI backdrop
    pfUI.api.CreateBackdrop(frame, nil, true)
    
    -- Make draggable
    frame:SetScript("OnDragStart", function()
        this:StartMoving()
    end)
    frame:SetScript("OnDragStop", function()
        this:StopMovingOrSizing()
    end)
    
    -- Title
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", frame, "TOP", 0, -15)
    title:SetText("UILabels Configuration")
    title:SetTextColor(1, 1, 1)
    
    -- Close button
    local closeBtn = CreateFrame("Button", nil, frame)
    closeBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -10, -10)
    closeBtn:SetWidth(20)
    closeBtn:SetHeight(20)
    pfUI.api.SkinCloseButton(closeBtn)
    closeBtn:SetScript("OnClick", function()
        UILabels.Config:Hide()
    end)
    
    -- Create panels
    self:CreateLabelListPanel(frame)
    self:CreateEditorPanel(frame)
    self:CreateButtonPanel(frame)
    
    -- Register with ESC key handler
    table.insert(UISpecialFrames, "UILabelsConfigFrame")
    
    self.frame = frame
    frame:Hide()
end

-- Create label list panel (left side)
function UILabels.Config:CreateLabelListPanel(parent)
    local panel = CreateFrame("Frame", nil, parent)
    panel:SetPoint("TOPLEFT", parent, "TOPLEFT", 15, -45)
    panel:SetWidth(200)
    panel:SetHeight(340)
    
    -- Apply pfUI backdrop
    pfUI.api.CreateBackdrop(panel, nil, true)
    
    -- Title
    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOP", panel, "TOP", 0, -10)
    title:SetText("Labels")
    title:SetTextColor(1, 1, 1)
    
    -- Create scroll frame
    local scrollFrame = CreateFrame("ScrollFrame", nil, panel)
    scrollFrame:SetPoint("TOPLEFT", panel, "TOPLEFT", 10, -35)
    scrollFrame:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -25, 45)
    
    -- Create scroll child (content container)
    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetWidth(165)
    scrollChild:SetHeight(1) -- Will be resized based on content
    scrollFrame:SetScrollChild(scrollChild)
    
    -- Create scrollbar with a name
    local scrollBar = CreateFrame("Slider", "UILabelsScrollBar", scrollFrame)
    scrollBar:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -5, -35)
    scrollBar:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -5, 45)
    scrollBar:SetWidth(16)
    scrollBar:SetOrientation("VERTICAL")
    scrollBar:SetMinMaxValues(0, 1)
    scrollBar:SetValue(0)
    scrollBar:SetValueStep(1)
    
    -- Create scrollbar textures manually (pfUI style)
    scrollBar:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 8, edgeSize = 8,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    scrollBar:SetBackdropColor(0, 0, 0, 0.75)
    scrollBar:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
    
    -- Thumb texture
    local thumb = scrollBar:CreateTexture(nil, "OVERLAY")
    thumb:SetWidth(16)
    thumb:SetHeight(24)
    thumb:SetTexture(0.3, 0.3, 0.3, 1)
    scrollBar:SetThumbTexture(thumb)
    
    -- Link scrollbar to scrollframe
    scrollBar:SetScript("OnValueChanged", function()
        scrollFrame:SetVerticalScroll(this:GetValue())
    end)
    
    -- Enable mousewheel scrolling
    scrollFrame:EnableMouseWheel(true)
    scrollFrame:SetScript("OnMouseWheel", function()
        local current = scrollBar:GetValue()
        local min, max = scrollBar:GetMinMaxValues()
        
        if arg1 > 0 then
            -- Scroll up
            scrollBar:SetValue(math.max(min, current - 23))
        else
            -- Scroll down
            scrollBar:SetValue(math.min(max, current + 23))
        end
    end)
    
    panel.scroll = scrollChild
    panel.scrollFrame = scrollFrame
    panel.scrollBar = scrollBar
    panel.buttons = {}
    
    -- Add New button
    local addBtn = CreateFrame("Button", nil, panel)
    addBtn:SetPoint("BOTTOM", panel, "BOTTOM", 0, 10)
    addBtn:SetWidth(180)
    addBtn:SetHeight(20)
    pfUI.api.SkinButton(addBtn)
    
    local addBtnText = addBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    addBtnText:SetPoint("CENTER", addBtn, "CENTER", 0, 0)
    addBtnText:SetText("Add New Label")
    
    addBtn:SetScript("OnClick", function()
        local newID = UILabels.Database:CreateNewLabel()
        UILabels.Labels:RefreshAllLabels()
        UILabels.Config:RefreshLabelList()
        UILabels.Config:SelectLabel(newID)
    end)
    
    self.labelListPanel = panel
end

-- Refresh label list
function UILabels.Config:RefreshLabelList()
    local panel = self.labelListPanel
    if not panel then return end
    
    -- Clear existing buttons
    for _, btn in pairs(panel.buttons) do
        btn:Hide()
    end
    panel.buttons = {}
    
    -- Create buttons for each label
    local labels = UILabels.Database:GetAllLabels()
    local yOffset = 0
    local index = 1
    
    for labelID, config in pairs(labels) do
        local btn = self:CreateLabelButton(panel.scroll, labelID, config, yOffset)
        panel.buttons[labelID] = btn
        yOffset = yOffset - 23
        index = index + 1
    end
    
    -- Update scroll child height based on content
    local totalHeight = (index - 1) * 23
    panel.scroll:SetHeight(math.max(totalHeight, 1))
    
    -- Update scrollbar range
    local scrollFrameHeight = panel.scrollFrame:GetHeight()
    local maxScroll = math.max(0, totalHeight - scrollFrameHeight)
    panel.scrollBar:SetMinMaxValues(0, maxScroll)
    
    -- Show/hide scrollbar based on need
    if maxScroll > 0 then
        panel.scrollBar:Show()
    else
        panel.scrollBar:Hide()
        panel.scrollFrame:SetVerticalScroll(0)
    end
end

-- Create a label list button
function UILabels.Config:CreateLabelButton(parent, labelID, config, yOffset)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, yOffset)
    btn:SetWidth(180)
    btn:SetHeight(20)
    pfUI.api.SkinButton(btn)
    
    local btnText = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    btnText:SetPoint("CENTER", btn, "CENTER", 0, 0)
    
    local displayText = tostring(labelID) .. ": " .. tostring(config.text or "")
    if string.len(displayText) > 24 then
        displayText = string.sub(displayText, 1, 24) .. "..."
    end
    btnText:SetText(displayText)
    
    btn:SetScript("OnClick", function()
        UILabels.Config:SelectLabel(labelID)
    end)
    
    return btn
end

-- Create editor panel (right side)
function UILabels.Config:CreateEditorPanel(parent)
    local panel = CreateFrame("Frame", nil, parent)
    panel:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -15, -45)
    panel:SetWidth(350)
    panel:SetHeight(340)
    panel:SetFrameStrata("DIALOG")
    panel:SetFrameLevel(5)
    
    -- Apply pfUI backdrop
    pfUI.api.CreateBackdrop(panel, nil, true)
    
    -- Title
    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOP", panel, "TOP", 0, -10)
    title:SetText("Edit Label")
    title:SetTextColor(1, 1, 1)
    panel.title = title
    
    -- Text input
    local textLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    textLabel:SetPoint("TOPLEFT", panel, "TOPLEFT", 15, -40)
    textLabel:SetText("Text:")
    textLabel:SetTextColor(1, 1, 1)
    
    local textInput = pfUI.api.CreateTextBox(panel)
    textInput:SetParent(panel)
    textInput:SetFrameStrata("DIALOG")
    textInput:SetFrameLevel(6)
    textInput:SetPoint("TOPLEFT", panel, "TOPLEFT", 15, -55)
    textInput:SetWidth(310)
    textInput:SetHeight(20)
    panel.textInput = textInput
    
    -- X Position
    local xLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    xLabel:SetPoint("TOPLEFT", panel, "TOPLEFT", 15, -90)
    xLabel:SetText("X Position:")
    xLabel:SetTextColor(1, 1, 1)
    
    local xInput = pfUI.api.CreateTextBox(panel)
    xInput:SetParent(panel)
    xInput:SetFrameStrata("DIALOG")
    xInput:SetFrameLevel(6)
    xInput:SetPoint("TOPLEFT", panel, "TOPLEFT", 100, -90)
    xInput:SetWidth(80)
    xInput:SetHeight(20)
    panel.xInput = xInput
    
    -- Y Position
    local yLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    yLabel:SetPoint("TOPLEFT", panel, "TOPLEFT", 15, -120)
    yLabel:SetText("Y Position:")
    yLabel:SetTextColor(1, 1, 1)
    
    local yInput = pfUI.api.CreateTextBox(panel)
    yInput:SetParent(panel)
    yInput:SetFrameStrata("DIALOG")
    yInput:SetFrameLevel(6)
    yInput:SetPoint("TOPLEFT", panel, "TOPLEFT", 100, -120)
    yInput:SetWidth(80)
    yInput:SetHeight(20)
    panel.yInput = yInput
    
    -- Font Size
    local sizeLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    sizeLabel:SetPoint("TOPLEFT", panel, "TOPLEFT", 15, -150)
    sizeLabel:SetText("Font Size:")
    sizeLabel:SetTextColor(1, 1, 1)
    
    local sizeInput = pfUI.api.CreateTextBox(panel)
    sizeInput:SetParent(panel)
    sizeInput:SetFrameStrata("DIALOG")
    sizeInput:SetFrameLevel(6)
    sizeInput:SetPoint("TOPLEFT", panel, "TOPLEFT", 100, -150)
    sizeInput:SetWidth(80)
    sizeInput:SetHeight(20)
    panel.sizeInput = sizeInput
    
    -- Anchor Point Dropdown
    local anchorLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    anchorLabel:SetPoint("TOPLEFT", panel, "TOPLEFT", 15, -180)
    anchorLabel:SetText("Anchor:")
    anchorLabel:SetTextColor(1, 1, 1)
    
    -- Create dropdown button
    local anchorDropdown = CreateFrame("Button", nil, panel)
    anchorDropdown:SetPoint("TOPLEFT", panel, "TOPLEFT", 100, -180)
    anchorDropdown:SetWidth(120)
    anchorDropdown:SetHeight(20)
    anchorDropdown:SetFrameStrata("DIALOG")
    anchorDropdown:SetFrameLevel(6)
    pfUI.api.SkinButton(anchorDropdown)
    
    local anchorText = anchorDropdown:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    anchorText:SetPoint("CENTER", anchorDropdown, "CENTER", 0, 0)
    anchorText:SetText("BOTTOM")
    anchorDropdown.text = anchorText
    
    -- Create dropdown menu
    local anchorMenu = CreateFrame("Frame", nil, anchorDropdown)
    anchorMenu:SetPoint("TOP", anchorDropdown, "BOTTOM", 0, -2)
    anchorMenu:SetWidth(120)
    anchorMenu:SetHeight(180)
    anchorMenu:SetFrameStrata("FULLSCREEN")
    anchorMenu:SetFrameLevel(10)
    pfUI.api.CreateBackdrop(anchorMenu, nil, true)
    anchorMenu:Hide()
    
    local anchorOptions = {
        "TOPLEFT", "TOP", "TOPRIGHT",
        "LEFT", "CENTER", "RIGHT",
        "BOTTOMLEFT", "BOTTOM", "BOTTOMRIGHT"
    }
    
    local anchorButtons = {}
    for i, option in ipairs(anchorOptions) do
        local btn = CreateFrame("Button", nil, anchorMenu)
        btn:SetPoint("TOPLEFT", anchorMenu, "TOPLEFT", 5, -5 - ((i-1) * 20))
        btn:SetWidth(110)
        btn:SetHeight(18)
        pfUI.api.SkinButton(btn)
        
        local btnText = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        btnText:SetPoint("CENTER", btn, "CENTER", 0, 0)
        btnText:SetText(option)
        
        btn:SetScript("OnClick", function()
            anchorDropdown.text:SetText(option)
            anchorDropdown.selectedValue = option
            anchorMenu:Hide()
        end)
        
        anchorButtons[i] = btn
    end
    
    anchorDropdown:SetScript("OnClick", function()
        if anchorMenu:IsVisible() then
            anchorMenu:Hide()
        else
            anchorMenu:Show()
        end
    end)
    
    -- Click outside to close
    anchorMenu:EnableMouse(true)
    
    panel.anchorDropdown = anchorDropdown
    
    -- Visible checkbox
    local visibleCheck = CreateFrame("CheckButton", nil, panel)
    visibleCheck:SetPoint("TOPLEFT", panel, "TOPLEFT", 15, -210)
    visibleCheck:SetWidth(20)
    visibleCheck:SetHeight(20)
    visibleCheck:SetFrameStrata("DIALOG")
    visibleCheck:SetFrameLevel(6)
    pfUI.api.SkinCheckbox(visibleCheck)
    
    local visibleLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    visibleLabel:SetPoint("LEFT", visibleCheck, "RIGHT", 5, 0)
    visibleLabel:SetText("Visible")
    visibleLabel:SetTextColor(1, 1, 1)
    panel.visibleCheck = visibleCheck
    
    -- Save button
    local saveBtn = CreateFrame("Button", nil, panel)
    saveBtn:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 15, 15)
    saveBtn:SetWidth(160)
    saveBtn:SetHeight(25)
    saveBtn:SetFrameStrata("DIALOG")
    saveBtn:SetFrameLevel(6)
    pfUI.api.SkinButton(saveBtn)
    
    local saveBtnText = saveBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    saveBtnText:SetPoint("CENTER", saveBtn, "CENTER", 0, 0)
    saveBtnText:SetText("Save Changes")
    
    saveBtn:SetScript("OnClick", function()
        UILabels.Config:SaveCurrentLabel()
    end)
    
    -- Delete button
    local delBtn = CreateFrame("Button", nil, panel)
    delBtn:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -15, 15)
    delBtn:SetWidth(160)
    delBtn:SetHeight(25)
    delBtn:SetFrameStrata("DIALOG")
    delBtn:SetFrameLevel(6)
    pfUI.api.SkinButton(delBtn)
    
    local delBtnText = delBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    delBtnText:SetPoint("CENTER", delBtn, "CENTER", 0, 0)
    delBtnText:SetText("Delete Label")
    
    delBtn:SetScript("OnClick", function()
        UILabels.Config:DeleteCurrentLabel()
    end)
    
    self.editorPanel = panel
end

-- Create button panel (bottom)
function UILabels.Config:CreateButtonPanel(parent)
    -- Edit Mode Toggle - COMMENTED OUT FOR NOW
    --[[
    local editBtn = CreateFrame("Button", nil, parent)
    editBtn:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 15, 15)
    editBtn:SetWidth(180)
    editBtn:SetHeight(25)
    pfUI.api.SkinButton(editBtn)
    
    local editBtnText = editBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    editBtnText:SetPoint("CENTER", editBtn, "CENTER", 0, 0)
    editBtnText:SetText("Toggle Edit Mode")
    
    editBtn:SetScript("OnClick", function()
        UILabels.Labels:ToggleEditMode()
    end)
    ]]--
    
    -- Reset button
    local resetBtn = CreateFrame("Button", nil, parent)
    resetBtn:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 15, 15)  -- Changed from BOTTOM to BOTTOMLEFT
    resetBtn:SetWidth(180)
    resetBtn:SetHeight(25)
    pfUI.api.SkinButton(resetBtn)
    
    local resetBtnText = resetBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    resetBtnText:SetPoint("CENTER", resetBtn, "CENTER", 0, 0)
    resetBtnText:SetText("Reset All")
    
    resetBtn:SetScript("OnClick", function()
        UILabels.Database:ResetToDefaults()
        UILabels.Labels:RefreshAllLabels()
        UILabels.Config:RefreshLabelList()
        UILabels.Utils:Print("All labels reset to defaults")
    end)
    
    -- Reload button
    local reloadBtn = CreateFrame("Button", nil, parent)
    reloadBtn:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -15, 15)
    reloadBtn:SetWidth(180)
    reloadBtn:SetHeight(25)
    pfUI.api.SkinButton(reloadBtn)
    
    local reloadBtnText = reloadBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    reloadBtnText:SetPoint("CENTER", reloadBtn, "CENTER", 0, 0)
    reloadBtnText:SetText("Reload Labels")
    
    reloadBtn:SetScript("OnClick", function()
        UILabels.Labels:RefreshAllLabels()
        UILabels.Utils:Print("Labels reloaded")
    end)
end

-- Select a label for editing
function UILabels.Config:SelectLabel(labelID)
    self.selectedLabelID = labelID
    
    local config = UILabels.Database:GetLabel(labelID)
    if not config then return end
    
    local panel = self.editorPanel
    
    -- Update title
    panel.title:SetText("Edit Label #" .. labelID)
    
    -- Populate fields
    panel.textInput:SetText(config.text or "")
    panel.xInput:SetText(tostring(config.x or 0))
    panel.yInput:SetText(tostring(config.y or 0))
    panel.sizeInput:SetText(tostring(config.fontSize or 12))
    panel.visibleCheck:SetChecked(config.visible ~= false)
    
    -- Set anchor dropdown
    local anchor = config.anchor or "BOTTOM"
    panel.anchorDropdown.text:SetText(anchor)
    panel.anchorDropdown.selectedValue = anchor
end

-- Save current label
function UILabels.Config:SaveCurrentLabel()
    if not self.selectedLabelID then
        UILabels.Utils:Print("No label selected")
        return
    end
    
    local panel = self.editorPanel
    local config = UILabels.Database:GetLabel(self.selectedLabelID)
    
    if not config then return end
    
    -- Get values from inputs
    config.text = panel.textInput:GetText()
    config.x = tonumber(panel.xInput:GetText()) or 0
    config.y = tonumber(panel.yInput:GetText()) or 0
    config.fontSize = tonumber(panel.sizeInput:GetText()) or 12
    config.visible = panel.visibleCheck:GetChecked()
    config.anchor = panel.anchorDropdown.selectedValue or "BOTTOM"
    config.relativePoint = config.anchor  -- Same as anchor for simplicity
    
    -- Save to database
    UILabels.Database:SetLabel(self.selectedLabelID, config)
    
    -- Update the label
    UILabels.Labels:UpdateLabel(self.selectedLabelID, config)
    
    -- Refresh list
    self:RefreshLabelList()
    
    UILabels.Utils:Print("Label #" .. self.selectedLabelID .. " saved")
end

-- Delete current label
function UILabels.Config:DeleteCurrentLabel()
    if not self.selectedLabelID then
        UILabels.Utils:Print("No label selected")
        return
    end
    
    -- Delete from database
    UILabels.Database:DeleteLabel(self.selectedLabelID)
    
    -- Destroy the frame
    UILabels.Labels:DestroyLabel(self.selectedLabelID)
    
    -- Clear selection
    self.selectedLabelID = nil
    
    -- Refresh list
    self:RefreshLabelList()
    
    -- Clear editor
    local panel = self.editorPanel
    panel.title:SetText("Edit Label")
    panel.textInput:SetText("")
    panel.xInput:SetText("")
    panel.yInput:SetText("")
    panel.sizeInput:SetText("")
    panel.visibleCheck:SetChecked(false)
    panel.anchorDropdown.text:SetText("BOTTOM")
    panel.anchorDropdown.selectedValue = "BOTTOM"
    
    UILabels.Utils:Print("Label deleted")
end