-- UILabels - Core
-- Main addon initialization and event handling

UILabels = UILabels or {}
UILabels.Core = {}

-- Addon frame for event handling
local eventFrame = CreateFrame("Frame")

-- Event handlers
function UILabels.Core:OnAddonLoaded(addon)
    if addon ~= "UILabels" then return end
    
    -- Initialize database
    UILabels.Database:Initialize()
    
    -- Register slash commands
    self:RegisterSlashCommands()
    
    UILabels.Utils:Debug("Addon loaded")
end

function UILabels.Core:OnPlayerEnteringWorld()
    -- Create all labels
    UILabels.Labels:CreateAllLabels()
    
    UILabels.Utils:Debug("Player entering world - labels created")
end

function UILabels.Core:OnPlayerLogout()
    -- Save current profile
    UILabels.Database:SaveProfile()
    
    UILabels.Utils:Debug("Player logout - profile saved")
end

-- Register events
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("PLAYER_LOGOUT")

eventFrame:SetScript("OnEvent", function()
    if event == "ADDON_LOADED" then
        UILabels.Core:OnAddonLoaded(arg1)
    elseif event == "PLAYER_ENTERING_WORLD" then
        UILabels.Core:OnPlayerEnteringWorld()
    elseif event == "PLAYER_LOGOUT" then
        UILabels.Core:OnPlayerLogout()
    end
end)

-- Slash command handlers
function UILabels.Core:RegisterSlashCommands()
    SLASH_UILABELS1 = "/uilabels"
    SLASH_UILABELS2 = "/uil"
    
    SlashCmdList["UILABELS"] = function(msg)
        msg = string.lower(msg or "")
        
        if msg == "" or msg == "config" or msg == "cfg" then
            -- Safety check
            if UILabels.Config and UILabels.Config.Toggle then
                UILabels.Config:Toggle()
            else
                UILabels.Utils:Print("Config UI not loaded yet")
            end
        elseif msg == "show" then
            UILabels.Labels:ShowAllLabels()
            UILabels.Utils:Print("All labels shown")
        elseif msg == "hide" then
            UILabels.Labels:HideAllLabels()
            UILabels.Utils:Print("All labels hidden")
        -- elseif msg == "edit" then
        --     UILabels.Labels:ToggleEditMode()
        elseif msg == "reset" then
            UILabels.Database:ResetToDefaults()
            UILabels.Labels:RefreshAllLabels()
            UILabels.Utils:Print("Reset to defaults")
        elseif msg == "reload" or msg == "refresh" then
            UILabels.Labels:RefreshAllLabels()
            UILabels.Utils:Print("Labels refreshed")
        elseif msg == "help" then
            self:ShowHelp()
        else
            UILabels.Utils:Print("Unknown command. Type /uilabels help for commands")
        end
    end
end

function UILabels.Core:ShowHelp()
    UILabels.Utils:Print("Available commands:")
    DEFAULT_CHAT_FRAME:AddMessage("  /uilabels - Open configuration UI")
    DEFAULT_CHAT_FRAME:AddMessage("  /uilabels show - Show all labels")
    DEFAULT_CHAT_FRAME:AddMessage("  /uilabels hide - Hide all labels")
    DEFAULT_CHAT_FRAME:AddMessage("  /uilabels edit - Toggle edit mode (drag labels)")
    DEFAULT_CHAT_FRAME:AddMessage("  /uilabels reset - Reset to defaults")
    DEFAULT_CHAT_FRAME:AddMessage("  /uilabels reload - Refresh all labels")
    DEFAULT_CHAT_FRAME:AddMessage("  /uilabels help - Show this help")
end