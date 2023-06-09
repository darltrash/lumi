## `Slam: A simple spheroid-to-mesh collision resolution.`

<br>

To import it on your project:
-   copy [`vec3.lua`](../vec3.lua) into your project
-   copy [`slam.lua`](../slam.lua) into the same folder
-   write `local slam = require "slam"`

*Usage:*
```lua
local slam = require "slam"

-- Example 1: Using a list of triangles
local new_position, new_velocity, planes = slam(position, velocity, radius, level_triangles)


-- Example 2: Implementing a query function
local function query(min, max)
    return get_list_of_triangles(min, max)
end

local new_position, new_velocity, planes = slam(position, velocity, radius, query)

-- I personally recommend pairing this library up with 
-- some custom spatial hashing algorithm, maybe something
-- like octrees or just regular old spatial hashing
```

<br>

### What it does:
- Handle simple spheroid-to-mesh collision resolution (in that order)
- Do sweeping collision resolution, and give you a list of colliding planes so you can expand upon it
- Handle scaled spheres (called spheroids thorough this document)

### What it doesn't do:
- Handle complex physics, such as gravity, friction, etc (you can implement it if you want)
- Handle a "world state", aka. it doesn't hold a list of triangles nor spheroids
- Spatial hashing, the way you store the triangles is your problem, Slam does not dictate how you should engineer your software

### What it can't do:
- Handle sheared and rotated spheroids, it can only handle scaled spheres (fine for most games tbh)
- Mesh-to-spheroid collision resolution, or basically anything that isnt Spheroid-to-mesh collision resolution

<br>

### Methods/functions:
-   `slam.check(position, velocity, radius, query, substeps?, data?) -> new_position, new_velocity, planes`: <br>
    - `position`: Current position, a `vec3`
    - `velocity`: Current velocity, a `vec3`
    - `radius`: Spheroid radius, a `vec3` or a `number` in the case of perfect spheres
    - `query` can be either:
      - A function like `(min, max, velocity, data?) -> triangles, ids?`
        - `min`: The origin point of a box for indexing, a `vec3`
        - `max`: The ending point of a box for indexing, a `vec3`
        - `velocity`: The spheroid's transformed velocity, a `vec3`
        - `data` optional data passed by `slam.check` 
        - `⤵️triangles`: A list of triangles in `{vec3, vec3, vec3}` format
        - `⤵️ids`: an ID for each triangle, any type
      - Or just a list of triangles in `{vec3, vec3, vec3}` format
    - `substeps`: Amount of intermediary steps, default is 1, an `integer`.
    - `data`: Any data to pass to the query function (if it's even a function...)
    - `⤵️new_position`: The next position according to velocity, with the collision response applied, a `vec3`
    - `⤵️new_velocity`: The difference between the input position and `new_position`, a `vec3`
    - `⤵️planes`: A list of planes like:
      - `normal`: Plane normal, a `vec3`
      - `position`: Plane position, a `vec3`
      - `near`: How close is it to the sphere, a `number` from 0 to 1
      - `id`: The plane's ID

An alternative form for `slam.check` can be just `slam`, for convenience. ;)

<br>

### Thanks to:
- Kasper Fauerby for their absolutely fantastic paper, [Improved Collision detection and Response](https://www.peroxide.dk/papers/collision/collision.pdf)
- Jeff Linahan for implementing crucial improvements to Fauerby's paper, in their own paper, [Improving the Numerical Robustness of Sphere
Swept Collision Detection](https://arxiv.org/pdf/1211.0059.pdf)
- And specially, [Excessive](https://github.com/excessive/), for having implemented the [first version of what's implemented in Slam](https://github.com/excessive/cpcl)