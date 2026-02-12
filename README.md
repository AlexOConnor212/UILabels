# UILabels - Custom Action Bar Labels for WoW 1.12

A lightweight addon for Turtle WoW that lets you create and position custom text labels anywhere on your screen - perfect for labeling keybinds, action bars, or adding custom UI text.

## Features

- **Create unlimited custom labels** with personalized text
- **Flexible positioning** with 9 anchor points (TOP, CENTER, BOTTOM, etc.)
- **pfUI integration** - matches your pfUI theme automatically
- **Persistent storage** - labels saved between sessions
- **Easy configuration UI** - simple point-and-click interface
- **Scrollable label list** - manage as many labels as you need

## Installation

1. Download the UILabels folder
2. Place it in `World of Warcraft/Interface/AddOns/`
3. Restart WoW or `/reload`
4. You'll see a "Hello World" label in the center of your screen

## Usage

### Opening the Configuration UI
```
/uilabels
/uil
```

### Commands

- `/uilabels` or `/uilabels config` - Open configuration UI
- `/uilabels show` - Show all labels
- `/uilabels hide` - Hide all labels
- `/uilabels reset` - Reset all labels to default
- `/uilabels reload` - Refresh/reload all labels
- `/uilabels help` - Show command list

### Creating a Label

1. Open the config UI with `/uilabels`
2. Click **"Add New Label"** at the bottom of the label list
3. Edit the label properties:
   - **Text**: What the label says
   - **X Position**: Horizontal offset from anchor
   - **Y Position**: Vertical offset from anchor
   - **Font Size**: Text size (default: 12)
   - **Anchor**: Where the label is anchored (BOTTOM, CENTER, TOP, etc.)
   - **Visible**: Toggle label visibility
4. Click **"Save Changes"**

### Positioning Labels

Labels use anchor points relative to your screen:

- **BOTTOM** - Anchored to bottom center (good for action bars)
- **CENTER** - Anchored to screen center
- **TOP** - Anchored to top center
- **TOPLEFT/TOPRIGHT** - Corner anchors
- **BOTTOMLEFT/BOTTOMRIGHT** - Corner anchors
- **LEFT/RIGHT** - Side anchors

**X Position**: Negative = left, Positive = right  
**Y Position**: Negative = down, Positive = up

### Example Positions
```
Action bar keybind labels (BOTTOM anchor):
- Label "1" at X: -140, Y: 75
- Label "2" at X: -100, Y: 75
- Label "3" at X: -60, Y: 75

Modifier labels (BOTTOM anchor):
- Label "Alt" at X: -140, Y: 105
- Label "Shift" at X: -100, Y: 105
```

### Editing Labels

1. Click on a label in the list
2. Edit the fields in the editor panel
3. Click **"Save Changes"**

### Deleting Labels

1. Select the label you want to delete
2. Click **"Delete Label"**

## Font Customization

UILabels automatically uses your pfUI font if available. If pfUI is not installed, it falls back to the default Blizzard font.

Default font: `Interface\AddOns\pfUI\fonts\Myriad-Pro.ttf`  
Fallback font: `Fonts\FRIZQT__.ttf`

## File Structure
```
UILabels/
├── UILabels.toc          # Addon metadata
├── Defaults.lua          # Default configurations
├── Utils.lua             # Helper functions
├── Database.lua          # SavedVariables management
├── Labels.lua            # Label frame creation
├── Config.lua            # Configuration UI
└── Core.lua              # Event handling & slash commands
```

## SavedVariables

Your labels are saved in:
```
WTF/Account/[ACCOUNT]/SavedVariables/UILabels.lua
```

Settings are saved per-account, not per-character.

## Dependencies

- **Optional**: pfUI (for theming, not required)

## Known Issues

- Edit mode (drag-to-reposition) is currently disabled - use X/Y position fields instead

## Compatibility

- **WoW Version**: 1.12 (Vanilla)
- **Tested on**: Turtle WoW
- **Works with**: pfUI, vanilla UI

## Support

If you encounter issues:
1. Try `/uilabels reset` to reset to defaults
2. Try `/uilabels reload` to refresh labels
3. Check `/uilabels help` for available commands