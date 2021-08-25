local util = require("util")
remote.add_interface("yeet-interface", {
    list = function()
      for num, obj in pairs(global.yeeters) do
        game.player.print(num .."--".. obj.name.."--"..obj.type)
      end
    end
  }
)

local yeetable = {
    ["grenade"] = true,
    ["cluster-grenade"] = true,
    ["cliff-explosives"] = true,
}

function remove_yeeter(inserter)
    if global.yeeters[inserter.unit_number] ~= nil then
      log("Removing "..inserter.unit_number.." from yeeters")
      global.yeeters[inserter.unit_number] = nil
    end
end

function handle_possible_yeeter(inserter)
  if (not global.yeeters) then
    global.yeeters = {}
  end

  if next(inserter.surface.find_entities_filtered {position = inserter.drop_position}) == nil then
    if global.yeeters[inserter.unit_number] == nil then
      log("Adding "..inserter.unit_number.." to yeeters")
      global.yeeters[inserter.unit_number] = inserter
    end
      remove_yeeter(inserter)
  else
  end
end


-- Changes to  entities can both be inserters and give/remove drop targets
-- so we just process all the inserters in the long inserter range
function find_yeeters(surface, position)
    local near_inserters = surface.find_entities_filtered {
      position = position,
      radius=2,
      type = "inserter"
    }
    for _, inserter in pairs(near_inserters) do
      log("processing inserter:"..inserter.unit_number)
      handle_possible_yeeter(inserter)
    end
end


-- Entities still exist as potential drop targets on the
-- tick they are mined/destroyed so we wait a tick to process
function find_next_tick(position)
  if global.yeet_searches == nil then
    global.yeet_searches = {}
  end
  table.insert(global.yeet_searches, position)
end



function handle_entity_removal(entity)
    if entity.unit_number ~= nil then
      if entity.type == "inserter" then
        remove_yeeter(entity)
      end
      find_next_tick(entity.position)
    end
end


-- Process a single inserter.
-- surface is required for spawning new things.
function process_inserter(inserter)
    if not inserter.valid then
      return
    end
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

script.on_event(defines.events.on_built_entity,
  function(event)
    find_yeeters(event.created_entity.surface, event.created_entity.position)
  end
)
script.on_event(defines.events.on_entity_died,
  function(event) handle_entity_removal(event.entity) end
)

script.on_event(defines.events.on_player_mined_entity,
  function(event) handle_entity_removal(event.entity) end
)

script.on_event(defines.events.on_player_rotated_entity,
  function(event)
    if event.entity.unit_number ~= nil and  event.entity.type == "inserter" then
      -- Rotating can only affect this inserters yeeter elligibility
      handle_possible_yeeter(event.entity)
    end
  end
)
script.on_event(defines.events.on_tick,
  function(event)
    if global.yeet_searches == nil then
      global.yeet_searches = {}
    end

    for _, position in pairs(global.yeet_searches) do
      log("doing search on"..position.x.." "..position.y)
      find_yeeters(game.surfaces[1], position)
    end
    global.yeet_searches = {}

    if global.yeeters == nil then
      global.yeeters = {}
    end
    for num, inserter in pairs(global.yeeters) do
      process_inserter(inserter)
    end
  end
)

script.on_configuration_changed(
  function()
    if global.yeeters == nil then
      global.yeeters = {}
    end
    inserters = game.surfaces[1].find_entities_filtered {type = "inserter"}
    for _, inserter in pairs(inserters) do
      handle_possible_yeeter(inserter)
    end
  end
)
