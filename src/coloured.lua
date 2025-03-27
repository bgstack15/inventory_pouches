


inventory_pouches.dye_color_pairs = {}

if minetest.get_modpath("mcl_dyes") and minetest.get_modpath("mcl_colors") and minetest.get_modpath("mcl_signs") then
inventory_pouches.dye_color_pairs = {
{"mcl_dyes:black",mcl_colors.BLACK},
{"mcl_dyes:blue",mcl_colors.BLUE},
{"mcl_dyes:brown","#57392b"},
{"mcl_dyes:cyan",mcl_dyes.colors["cyan"].rgb},
{"mcl_dyes:green",mcl_colors.GREEN},
{"mcl_dyes:dark_green",mcl_colors.DARK_GREEN},
{"mcl_dyes:grey",mcl_colors.GRAY},
{"mcl_dyes:dark_grey",mcl_colors.DARK_GRAY},
{"mcl_dyes:lightblue",mcl_dyes.colors["light_blue"].rgb},
{"mcl_dyes:magenta",mcl_colors.LIGHT_PURPLE},
{"mcl_dyes:orange",mcl_dyes.colors["orange"].rgb},
{"mcl_dyes:pink",mcl_dyes.colors["pink"].rgb},
{"mcl_dyes:red",mcl_dyes.colors["red"].rgb},
{"mcl_dyes:violet",mcl_colors.DARK_PURPLE},
{"mcl_dyes:white",mcl_colors.WHITE},
{"mcl_dyes:yellow",mcl_colors.YELLOW},
}
elseif minetest.get_modpath("dye") then
    -- made with color_helper.py
    inventory_pouches.dye_color_pairs = {
        {"dye:dark_grey","#494949"},
        {"dye:red","#c91818"},
        {"dye:grey","#9c9c9c"},
        {"dye:white","#eeeeee"},
        {"dye:green","#67eb1c"},
        {"dye:dark_green","#2b7b00"},
        {"dye:brown","#6c3800"},
        {"dye:pink","#ffa5a5"},
        {"dye:black","#292929"},
        {"dye:violet","#480680"},
        {"dye:orange","#e0601a"},
        {"dye:magenta","#d80481"},
        {"dye:yellow","#fcf611"},
        {"dye:cyan","#00959d"},
        {"dye:blue","#00519d"},
    }
end


-- This function is called after the pouch is crafted with a dye.
local function craft_colored_pouch(itemstack, player, old_craft_grid, craft_inv)
    local pouch, dye, dye_stack_index

    -- Find the pouch and dye in the crafting grid
    for i, item in ipairs(old_craft_grid) do
        minetest.log("action", "Searching craft grid data: Index: "..i.." Data: "..dump(item))
        if item:get_name() == "inventory_pouches:pouch" then
            minetest.log("action","Found inventory pouch")
            pouch = item
        elseif string.find(item:get_name(), "^mcl_dyes:") or string.find(item:get_name(), "^dye:") then
            minetest.log("action", "Found Dye")
            dye = item
            dye_stack_index = i
        end
    end

    -- If a pouch and dye are found
    if pouch and dye then
        local meta = pouch:get_meta()
        local id = meta:get_string("id")
        minetest.log("action","ID found for pouch: "..id)

        -- Extract dye name from item name
        local dye_name_match = dye:get_name():match(":([%w_]+)$")
        if not dye_name_match then
            minetest.log("error", "Dye name pattern match failed for dye: " .. dye:get_name())
            return itemstack
        end

        -- Handle Unified Dyes
        if minetest.get_modpath("unifieddyes") then
            local color_idx = unifieddyes.getpaletteidx("dye:" .. dye_name_match, "extended")
            meta:set_int("palette_index", color_idx)

        -- Handle Minecraft-like and minetest_game
        elseif minetest.get_modpath("mcl_dyes") or minetest.get_modpath("dye") then
            for _, dye_entry in ipairs(inventory_pouches.dye_color_pairs) do
                local entry_dye_name, color_string = unpack(dye_entry)
                if dye_name_match == entry_dye_name:match(":([%w_]+)$") then
                    meta:set_string("color", color_string)
                    break
                end
            end
        end

        -- Ensure the ID is maintained
        meta:set_string("id", id)
        minetest.log("action","ID maintained for inventory pouch ".. id)

        -- Remove the used dye from the crafting grid
        if dye:get_count() > 1 then
            dye:take_item()
            craft_inv:set_stack("craft", dye_stack_index, dye)
        else
            craft_inv:set_stack("craft", dye_stack_index, ItemStack(nil))
        end

        -- Return the modified pouch preserving the ID
        return pouch
    end

    -- If no pouch or no dye, return the original itemstack
    minetest.log("action", "Returning original itemstack")
    return itemstack
end

minetest.register_on_craft(craft_colored_pouch)



-- Register crafting recipes for colored pouches
-- Handle Minecraft-like and minetest_game
if minetest.get_modpath("mcl_dyes") or minetest.get_modpath("dye") then
    for _, entry in ipairs(inventory_pouches.dye_color_pairs) do
        local dye_name, _ = unpack(entry)
        craft_def = {
            type = "shapeless",
            output = "inventory_pouches:pouch",
            recipe = {"inventory_pouches:pouch", dye_name},
            replacements = {{dye_name, dye_name}}
        }
        if minetest.get_modpath("unifieddyes") then
          -- Change properties of craftitem
        end
      minetest.register_craft(craft_def)
    end
end

if minetest.get_modpath("unifieddyes") then
    unifieddyes.register_color_craft({
        output = "inventory_pouches:pouch",
        palette = "extended",
        neutral_node = "inventory_pouches:pouch",
        recipe = {
            {"", "NEUTRAL_NODE", ""},
            {"", "MAIN_DYE", ""},
            {"", "", ""},
        },
    })
end
