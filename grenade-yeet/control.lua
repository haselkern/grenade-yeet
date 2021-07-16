local util = require("util")

local yeetable = {
    ["grenade"] = true,
    ["cluster-grenade"] = true,
    ["cliff-explosives"] = true,
}

-- Process a single inserter.
-- surface is required for spawning new things.
function process_inserter(surface, inserter)
    local held = inserter.held_stack

    -- Only do stuff if the inserter is holding something and has no place to put items.
    if held.valid_for_read and inserter.drop_target == nil then
        local held_position = inserter.held_stack_position

        -- Make sure we can yeet the item
        if yeetable[held.name] then

            -- Find out if and in what direction the inserter should yeet
            local yeet_x, yeet_y = 0, 0

            if inserter.direction == defines.direction.north and held_position.y >= inserter.position.y then
                -- Inserter yeets from north to south
                yeet_y = 1
            elseif inserter.direction == defines.direction.south and held_position.y <= inserter.position.y then
                -- Inserter yeets from south to north
                yeet_y = -1
            elseif inserter.direction == defines.direction.east and held_position.x <= inserter.position.x then
                -- Inserter yeets from east to west
                yeet_x = -1
            elseif inserter.direction == defines.direction.west and held_position.x >= inserter.position.x then
                -- Inserter yeets from west to east
                yeet_x = 1
            end


            if yeet_x ~= 0 or yeet_y ~= 0 then

                -- throw distance is a product of rotation speed, arm length and a constant.
                local arm_length = util.distance(inserter.position, held_position)
                local throw_distance = inserter.prototype.inserter_rotation_speed * arm_length * 250
                local speed = 0.3

                -- Multiply by throw_distance is safe, since yeet_x/y is a unit vec
                yeet_x = yeet_x * throw_distance
                yeet_y = yeet_y * throw_distance

                -- Spawn an entity for each thing in the inserter's hand
                local stack_size = held.count
                while held.count > 0 do
                    -- Create an offset in a stack of things.
                    local offset_x, offset_y = util.target_offset(held.count, stack_size, 2)

                    surface.create_entity {
                        name = held.name,
                        position = held_position,
                        target = {
                            held_position.x + yeet_x + offset_x,
                            held_position.y + yeet_y + offset_y
                        },
                        speed = speed,
                    }

                    held.count = held.count - 1
                end

                -- We have spawned everything, clear the inserter's hand
                held.clear()
            end
        end
    end
end

-- Process a surface.
-- This will look for all inserters and process them.
function process_surface(surface)
    local inserters = surface.find_entities_filtered {type = "inserter"}
    for _, inserter in pairs(inserters) do
        process_inserter(surface, inserter)
    end
end

-- Process all surfaces each tick
script.on_event(defines.events.on_tick,
    function(event)
        for _, surface in pairs(game.surfaces) do
            process_surface(surface)
        end
    end
)
