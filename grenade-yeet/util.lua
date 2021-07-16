local M = {}

-- distance will return the distance between two points a and b.
-- a and b must have x and y set.
function M.distance(a, b)
    return math.sqrt(M.distance_sq(a, b))
end

-- distance will return the squared distance between two points a and b.
-- a and b must have x and y set.
function M.distance_sq(a, b)
    local dx = a.x - b.x
    local dy = a.y - b.y
    return (dx * dx) + (dy * dy)
end

-- Returns a 2-tuple that contains the x,y offset for a target, because
-- we want to create some spread in a stack of thrown things.
-- Accepts parameter i as the 1-based index in a stack of n things.
-- space is the space that should be between the things.
function M.target_offset(i, n, space)
    -- Create a square grid pattern that will fit all things.
    local grid_size = math.ceil(math.sqrt(n))
    
    -- Find position for i in this grid
    local row = math.ceil(i/grid_size)
    local col = ((i - 1) % grid_size) + 1

    -- Shift the grid that row and col live in so that the center of it
    -- is 0,0.
    local shift = (grid_size+1)/2
    row = row - shift
    col = col - shift

    -- Spacing so far is 1, so we can multiply by the target space.
    row = row * space
    col = col * space

    return col, row
end

return M