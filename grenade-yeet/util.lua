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

return M