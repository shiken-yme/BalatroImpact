SMODS.current_mod.optional_features = {retrigger_joker = true}

SMODS.Atlas {
    key = "GenshinJokers",
    path = "GenshinJokers.png",
    px = 436,
    py = 736
}

SMODS.Atlas {
    key = "GenshinSkills",
    path = "ElementalSkills.png",
    px = 436,
    py = 736
}

--                 Define all custom infra here

-- Rarity for 5-Stars (and eventually 4-Stars)
SMODS.Rarity {
    key = "5Star",
    loc_txt = {name = "5-Star"},
    badge_colour = HEX('ff8afd'),
    pools = {["Joker"] = false},
    default_weight = 0
}

-- Define consumable type for Elemental Skills like Lightning Stiletto
SMODS.ConsumableType {
    key = "ESkill",
    primary_colour = HEX('bb8de3'),
    secondary_colour = HEX('8362a1'),
    collection_rows = {1, 1},
    shop_rate = 0,
    loc_txt = {
        name = 'Elemental Skill',
        collection = 'Elemental Skills',
        undiscovered = {
            name = 'Undiscovered Skill',
            text = {
                'Discover more Genshin', 'characters to uncover',
                'their unique abilities'
            }
        }
    }
}

-- List of all 5-Star Characters... maybe make global if need be, local for now
local FiveStars = {"j_Impact_keqing", "j_Impact_keqing"}

-- Intertwined Fate
SMODS.Joker {
    key = "intertwined",
    loc_txt = {
        name = "Intertwined Fate",
        text = {
            "Sell this card to", "obtain a random",
            "{C:attention}5-Star{} Genshin", "character"
        }
    },
    config = {extra = {repetitions = 1}},
    unlocked = true,
    discovered = true,
    blueprint_compat = false,
    eternal_compat = false,
    perishable_compat = true,
    rarity = 3,
    atlas = "GenshinJokers",
    pos = {x = 0, y = 0},
    cost = 10,
    calculate = function(self, card, context)
        if context.selling_self and not context.blueprint then
            local CharCenters = {}
            for _, k in ipairs(FiveStars) do
                if not (next(find_joker(G.P_CENTERS[k].name))) then
                    table.insert(CharCenters, k)
                end
            end
            local char = pseudorandom_element(CharCenters,
                                              pseudoseed('intertwined'))
            G.E_MANAGER:add_event(Event({
                trigger = "after",
                delay = 2,
                func = function()
                    local cardAdd = create_card('Joker', G.jokers, nil, nil,
                                                nil, nil, char, nil)
                    cardAdd:add_to_deck()
                    G.jokers:emplace(cardAdd)
                    cardAdd:start_materialize()
                    G.GAME.joker_buffer = 0
                    return true
                end
            }))
        end
    end
}

-- load character jokers and their components (i.e. elemental skill jonklers and consumables)
local subdir = "characters"
local characters = NFS.getDirectoryItems(SMODS.current_mod.path .. subdir)
for _, filename in pairs(characters) do
    assert(SMODS.load_file(subdir .. "/" .. filename))()
end
