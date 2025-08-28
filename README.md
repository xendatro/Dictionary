# Table Class Documentation

## Overview

The `Table` class creates reactive, observable table wrappers that automatically emit change events when modified. It provides a powerful way to implement reactive programming patterns by monitoring table modifications and propagating change notifications through nested table hierarchies.

**Key Features:**
- Automatic change detection and event emission
- Recursive wrapping of nested tables
- Change event bubbling from child to parent tables
- Access to the original unwrapped table via `Raw` property
- Automatic cleanup and memory management

**Use Cases:**
- Reactive UI updates based on data changes
- State management systems
- Data binding implementations
- Observer pattern implementations

## API

### Constructor

#### `Table.new<T>(table: T): T & Table<T>`
Creates a new reactive table wrapper around the provided table.

**Parameters:**
- `table: T` - The table to wrap and make reactive

**Returns:**
- `T & Table<T>` - The original table with added reactive functionality

**Example:**
```lua
local data = { name = "John", age = 25 }
local reactiveData = Table.new(data)
```

### Properties

#### `Changed: Signal`
A signal that fires whenever the table or any of its nested tables are modified.

**Example:**
```lua
reactiveData.Changed:Connect(function()
    print("Table was modified!")
end)
```

#### `Raw: T`
Direct access to the original unwrapped table without reactive behavior.

**Example:**
```lua
local originalTable = reactiveData.Raw
```

### Methods

#### `Destroy(): nil`
Cleans up the table instance by destroying the change signal and clearing references.

**Example:**
```lua
reactiveData:Destroy()
```

### Behavior

#### Nested Table Handling
When a table is assigned as a value, it's automatically wrapped in a new `Table` instance. Changes to nested tables bubble up to parent tables.

```lua
local data = Table.new({})
data.user = { name = "Alice" } -- Automatically becomes a reactive table
data.user.name = "Bob" -- Triggers change event on both data.user and data
```

#### Change Detection
The `Changed` event only fires when values actually change. Setting a property to its current value won't trigger the event.

```lua
data.name = "John"  -- Fires Changed event
data.name = "John"  -- No event fired (same value)
```

## Usage Examples

### Basic Reactive Data
```lua
-- Create a reactive player data table
local playerData = Table.new({
    health = 100,
    score = 0,
    level = 1
})

-- Listen for any changes
playerData.Changed:Connect(function()
    print("Player data updated!")
    updateUI()
end)

-- Modify data (triggers change event)
playerData.health = 75
playerData.score = 150
```

### UI Data Binding
```lua
-- Reactive form data
local formData = Table.new({
    username = "",
    email = "",
    isValid = false
})

-- Update UI whenever form data changes
formData.Changed:Connect(function()
    validateForm(formData.Raw)
    updateFormDisplay(formData.Raw)
end)

-- User input triggers automatic UI updates
formData.username = "john_doe"
formData.email = "john@example.com"
```

### Nested Configuration System
```lua
-- Game settings with nested structure
local gameSettings = Table.new({
    graphics = {
        quality = "High",
        vsync = true,
        resolution = { width = 1920, height = 1080 }
    },
    audio = {
        masterVolume = 0.8,
        sfxVolume = 0.6,
        musicVolume = 0.4
    }
})

-- Listen for any setting changes (including nested ones)
gameSettings.Changed:Connect(function()
    saveSettingsToFile(gameSettings.Raw)
    applyGameSettings()
end)

-- All of these trigger the change event
gameSettings.graphics.quality = "Medium"
gameSettings.audio.masterVolume = 0.5
gameSettings.graphics.resolution.width = 1280
```

### Inventory Management System
```lua
-- Player inventory with reactive updates
local inventory = Table.new({
    items = {},
    capacity = 20,
    weight = 0
})

-- Auto-update inventory UI
inventory.Changed:Connect(function()
    refreshInventoryDisplay()
    checkWeightLimits()
    updateCapacityBar()
end)

-- Adding items triggers automatic updates
inventory.items[1] = { name = "Sword", weight = 5, quantity = 1 }
inventory.items[2] = { name = "Potion", weight = 0.5, quantity = 10 }
inventory.weight = 10
```

### State Management Pattern
```lua
-- Application state store
local appState = Table.new({
    currentPage = "menu",
    user = {
        loggedIn = false,
        profile = {}
    },
    notifications = {}
})

-- Global state change handler
appState.Changed:Connect(function()
    -- Log state changes for debugging
    print("State changed:", game:GetService("HttpService"):JSONEncode(appState.Raw))
    
    -- Trigger re-renders or updates
    updateApplication()
end)

-- State mutations
appState.currentPage = "game"
appState.user.loggedIn = true
appState.user.profile = { username = "Player1", level = 5 }
```

### Shopping Cart Example
```lua
-- E-commerce cart with automatic calculations
local shoppingCart = Table.new({
    items = {},
    subtotal = 0,
    tax = 0,
    total = 0
})

-- Recalculate totals on any change
shoppingCart.Changed:Connect(function()
    local subtotal = 0
    for _, item in pairs(shoppingCart.items) do
        subtotal = subtotal + (item.price * item.quantity)
    end
    
    shoppingCart.subtotal = subtotal
    shoppingCart.tax = subtotal * 0.08
    shoppingCart.total = shoppingCart.subtotal + shoppingCart.tax
    
    updateCartDisplay()
end)

-- Adding items automatically triggers recalculation
shoppingCart.items["laptop"] = { price = 999.99, quantity = 1 }
shoppingCart.items["mouse"] = { price = 29.99, quantity = 2 }
```

### Cleanup Example
```lua
-- Always clean up when done
local tempData = Table.new({ status = "processing" })

tempData.Changed:Connect(function()
    if tempData.status == "complete" then
        -- Clean up the reactive table
        tempData:Destroy()
    end
end)

-- This will trigger cleanup
tempData.status = "complete"
```