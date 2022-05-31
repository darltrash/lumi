## `Acorn: A simple OOP library.`

> NOTE: This library does not support inheritance, see [below](#no-inheritance)

<br>

To import it on your project:
-   copy [`acorn.lua`](../acorn.lua) into your project
-   write `local acorn = require "acorn"`

*Usage:*
```lua
local acorn = require "acorn"

local dog = acorn.class {
    woofness = 2,

    woof = function (self)
        for x=1, self.woofness do
            print("woof!")
        end
    end
}

local fluffball = dog()
fluffball:woof() -- Will say woof 2 times

local loud_boi = dog()
loud_boi.woofness = 5
loud_boi:woof() -- WIll say woof 5 times
```

<br>

### No inheritance???
Yup, no inheritance. This is an intentional design choice and it's like that because it's a very opinionated library written for my own projects. I have noticed that reducing how much inheritance I add to my designs tends to allow me to write simpler and more efficient code.

If you want a neato little library with OOP + Inheritance, you can check [kikito's fantastic middleclass](https://github.com/kikito/middleclass)!

<br>

### Constructors
```lua
local dog = acorn.class {
    woofness = 2,
    name = "none",

    new = function(self, name)
        self.name = name
    end,

    say_hello = function(self)
        print("woof! my name is: " .. self.name)
    end
}

local dog_1 = dog("Puddles")
dog_1:say_hello() -- "woof! my name is: Puddles"

local dog_2 = dog.new("Bingo")
dog_2:say_hello() -- "woof! my name is: Bingo"

local dog_3 = dog()
dog_3:say_hello() -- "woof! my name is: none"

local dog_4 = dog:new("Gabungi")
dog_4:say_hello() -- "woof my name is: Gabungi"
```

<br>

### Operator overloads? Metamethods?
```lua
local dog = acorn.class {
    woofness = 2,

    woof = function (self)
        for x=1, self.woofness do
            print("woof!")
        end
    end,

    __tostring = function (self)
        return string.rep("woof! ", self.woofness)
    end
}

local doggie = dog()
print(doggie)
```

In this example, I replace the `__tostring` metamethod for a custom one which returns N amount of `woof!`s dependant of the `woofiness`. *(cant believe i'm actually writing this...)*

<br>

### A replacement for the traditional `type()`
```lua
-- Type name overloads!

local dog = acorn.class {
    __type = "Dog"
}

local doggie = dog()
print(acorn.type(doggie)) -- Dog
print(acorn.type(dog)) -- Class
```

```lua
-- ... And it's defaults, too!

local whatever = acorn.class {}

local chair = whatever()
print(acorn.type(chair)) -- Instance
print(acorn.type(dog)) -- Class
```

```lua
-- It also supports vanilla types

print(acorn.type(3)) -- number
print(acorn.type(true)) -- boolean
print(acorn.type({})) -- table
print(acorn.type("")) -- string
print(acorn.type(nil)) -- nil
```