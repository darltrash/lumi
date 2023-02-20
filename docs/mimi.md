## `Mimi: A very simple INI-like setup language`
<br>

To import it on your project:
-   copy [`mimi.lua`](../mimi.lua) into your project
-   write `local mimi = require "mimi"`

*Usage:*
```lua
local mimi = require "mimi"
local data = mimi.load "whatever.mi"
```

<br>

### So, about the syntax
The syntax is designed to be the mid-point between INI and TOML; simple like INI, but standarized and solid as TOML.

It has simplicity as it's main priority (both from the parsing standpoint and the user experience standpoint.)

It was born from the consideration that INI tends to be very unstable in my experience, and TOML tends to be overkill for most of what I do, So I made my own and it looks like this:

*Preview:*
```yaml
# Comments be crazy yo.

[Section]
is_cool: yes
name: "Cool thing!"
url: https://github.com/

[Section.subsection]
"Weird label": and weird contents!

[Top_best_foods]
1: Number indexes
2: uhh
3: pizzer.
```

*Syntax:*
```yaml
# Comment

[Section]
    # Tabs are not required, but they make things nice

    number: 300      # Same number syntax as Lua
    string: "great"  # Only '"' allowed, for now :)
    string2: We ird! # Gets trailing space removed
    boolean: yes     # True and false become yes and no
    "speci@l!": 0xff # '"' for unconventional key names

[Section.SubSection]
    # You create subsections like so

[Section.SubSection.SubSubSubSections]
    # And so on! 
```

<br>

### Function descriptions:
-   `mimi.decode(input, template) -> table?, err?`: <br>
    Attempts to decode the `input` as in mimi format, defaulting to the values present in `template` (optional). Returns decoded data and a possible error message.

-   `mimi.load(file, template) -> table?, err?`: <br>
    Does the same as `mimi.decode` except it reads from a file this time, Has Löve support.

-   `mimi.encode(table) -> output?, err?`: <br>
    Attempts to encode the `table` into mimi format. Returns encoded data and a possible error message.

-   `mimi.write(file, table) -> nil, err?`: <br>
    Does the same as `mimi.encode` except it writes into a file this time, Has Löve support.
