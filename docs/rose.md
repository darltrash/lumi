## `Rose: A single-function ECS implementation.`
<br>

To import it on your project:
-   copy [`rose.lua`](../rose.lua) into your project
-   write `local rose = require "rose"`

*Usage:*
```lua
local rose = require "rose"
rose(entities, systems, process, etcetera)
```

<br>

### How does ECS work?
Imagine you have a bunch of tables with all sorts of data, and you want all of them to act in a certain way depending on what data they contain, like the **Entities** of a game.

ECS works in a similar manner, a bunch of "systems" detect if said items fit a certain criteria, then do a set of operations on them if they do.

Those data items are named **Entities** by ECS.

<br>

### Let's make a system
```lua
local system_screams = {
    filter = function(self, item)
        if item.has_mouth then
            return true
        end
    end,

    operate = function(self, item, what)
        print("I have a mouth and i must scream about " .. what .. "!")
    end
}
```
This system has a `filter` "method" which allows us to know if an item's `has_mouth` property is not `nil`.

If said check is `true`, the rest of the functions should run taking `what` as an argument.

<br>

### Let's test it out with rose!
```lua
local systems = { system_screams }
local entities = {
    { has_mouth = true }
}

rose(entities, systems, "operate", "cheese")
```
In this example, `rose` will go through all the systems available and checks if the entities fit their descriptions through `filter`.

if `filter` returns non-`nil` and the function `operate` exists on the system, it will run over the entities.

<br>