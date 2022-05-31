## `Rose: A single-function ECS implementation.`
<br>

To import it on your project:
-   copy [`rose.lua`](../rose.lua) into your project
-   write `local rose = require "rose"`

Usage:
```
local rose = require "rose"
rose(entities, systems, process, etcetera)
```

### `rose (entities: []table, systems: []System, process: ?string, arguments: ?...)`
-   `entities:` A contiguous array of entities.
-   `systems:` A contiguous array of systems.
-   `process:` What kind of process to effect.
-   `arguments:` Arguments for said process.