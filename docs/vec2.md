## vec2.lua: A simple 2D vector library
<br>

To import it on your project:
-   copy [`vec2.lua`](../vec2.lua) into your project
-   write `local vec2 = require "vec2"`

*Usage:*
```lua
local vec2 = require "vec2"
local position = vec2(10, 20)
```

<br>

### Mathy stuff!
```lua
-- All vector-to-vector math operations supported! 
local a = vec2(5, 0) + vec2(0, 5) -- 5,  5
local b = vec2(5, 0) - vec2(0, 5) -- 5, -5
local c = vec2(5, 5) * vec2(1, 1) -- 5,  5
local d = vec2(5, 5) / vec2(5, 5) -- 1,  1
    -- ^ and % also supported

-- number-to-vector also supported!
local half = vec2(10, 10) / 2     -- 5, 5

print(half, half.x, half.y) -- vec2(5, 5), 5, 5
```

<br>

### Lots of math! (and other things)
-   `vec2.is_vector(whatever) -> boolean`: <br>
    Returns `true` if `whatever` is a vector.

-   `vec2.copy(vector) -> vector`: <br>
    Creates a copy of the input vector, then returns it.

-   `vec2.from_angle(angle, magnitude) -> vector`: <br>
    Creates a vector pointing to an angle with a certain magnitude, then returns it.

-   `vec2.from_table(table) -> vector`: <br>
    Creates a vector using the `x` and `y` values from the input table, then returns it.

-   `vec2.from_array(array) -> vector`: <br>
    Creates a vector using the first and second value from the input array, then returns it.

-   `vec2.to_array(vector) -> array`: <br>
    Creates an array containing the `x` and `y` values, then returns it.

-   `vec2.to_angle(vector) -> angle`: <br>
    Gets the angle of the input vector.

-   `vec2.rotate(vector, angle) -> vector`: <br>
    Rotates the input vector by an angle, then returns it.

-   `vec2.unpack(vector) -> x, y`: <br>
    Returns the `x` and `y` values from the input vector.

-   `vec2.magnitude(vector) -> magnitude`: <br>
    Returns the magnitude from the input vector.

-   `vec2.normalize(vector) -> vector`: <br>
    Returns a normalized version of the input vector.
    
-   `vec2.dist(vector, vector) -> distance`: <br>
    Returns the distance from the input vectors.

-   `vec2.dot(vector, vector) -> product`: <br>
    Returns the dot product from the input vectors.

-   `vec2.sign(vector) -> vector`: <br>
    Returns the sign value from the input vector.

-   `vec2.clamp(vector, min, max) -> vector`: <br>
    Returns the clamped version of the input vector. <br>
    **Note:** `min`, `max` can be either `vec2`s or `number`s

-   `vec2.lerp(vector, into, alpha) -> vector`: <br>
    Returns the lerped version of the input vector. <br>
    **Note:** `into` can be either a `vec2` or a `number`

-   `vec2.round(vector, factor) -> vector`: <br>
    Returns the rounded version of the input vector by the factor. <br>
    **Note:** `factor` can be either a `vec2` or a`number`

<br>

### Choose your weapon!
```lua
-- There's two ways to instance a vector
local pos_a = vec2(10, 20)
local pos_b = vec2.new(20, 40)

-- ... and two ways to play with them! 
local pos_half_1 = pos_a:lerp(pos_b, 0.5)
local pos_half_2 = vec2.lerp(pos_a, pos_b, 0.5)
```