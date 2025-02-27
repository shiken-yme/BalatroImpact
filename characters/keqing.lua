SMODS.Joker {
    key = "keqing",
    loc_txt = {
        name = "Keqing",
        text = {
            "Retrigger first and", "last scoring card", "if played hand is",
            "not {C:attention}High Card{}", "{C:inactive}Creates a Lightning{}",
            "{C:inactive}Stiletto when Blind{}", "{C:inactive}is selected{}"
        }
    },
    config = {extra = {repetitions = 1}},
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = false,
    rarity = 'Impact_5Star',
    atlas = "GenshinJokers",
    pos = {x = 1, y = 0},
    cost = 10,
    calculate = function(self, card, context)
        -- draw stiletto on blind selected, if there is room
        if context.setting_blind and #G.consumeables.cards +
            G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
            G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
            G.E_MANAGER:add_event(Event({
                trigger = 'before',
                delay = 0.0,
                func = function()
                    local card = create_card('ESkill', G.consumeables, nil, nil,
                                             nil, nil, 'c_Impact_KQSkill', nil)
                    card:add_to_deck()
                    G.consumeables:emplace(card)
                    G.GAME.consumeable_buffer = 0
                    return true
                end
            }))
            card_eval_status_text(context.blueprint_card or card, 'extra', nil,
                                  nil, nil,
                                  {message = 'Incoming!', colour = G.C.PURPLE})
        end

        -- primary scoring mechanics
        local SkillCards = SMODS.find_card('c_Impact_KQSkill')
        if context.before then
            SkillCards = SMODS.find_card('c_Impact_KQSkill')
            if #SkillCards > 0 then
                for i = 1, #SkillCards, 1 do
                    card.ability.extra.repetitions = card.ability.extra
                                                         .repetitions + 1
                    SMODS.calculate_effect({
                        message = "+1 Retrigger",
                        colour = G.C.PURPLE,
                        card = context.blueprint_card or card
                    }, SkillCards[i])
                end
            end
        end
        if context.cardarea == G.play and context.repetition and
            not context.repetition_only and context.scoring_name ~= 'High Card' then

            if context.other_card == context.scoring_hand[1] then
                return {
                    message = "Don't Blink!",
                    colour = G.C.PURPLE,
                    repetitions = card.ability.extra.repetitions,
                    card = card
                }
            end
            if context.other_card == context.scoring_hand[#context.scoring_hand] then
                return {
                    message = "Speed of Light!",
                    colour = G.C.PURPLE,
                    repetitions = card.ability.extra.repetitions,
                    card = card
                }
            end
        end
        if context.after and context.cardarea == G.jokers then
            card.ability.extra.repetitions = 1
        end
    end
}

SMODS.Consumable {
    key = "KQSkill",
    set = "ESkill",
    atlas = "GenshinSkills",
    pos = {x = 0, y = 0},
    cost = 0,
    loc_txt = {
        name = "Lightning Stiletto",
        text = {
            "Draws two random", "{C:attention}Diamonds{} to hand",
            "{C:inactive}If held, copies{}", "{C:inactive}Keqing's ability{}"
        }
    },
    unlocked = true,
    discovered = true,
    use = function(self, card, area, copier)
        local DiamondIsUnbreakable = {}
        for _, k in ipairs(G.deck.cards) do
            if k:is_suit('Diamonds') then
                table.insert(DiamondIsUnbreakable, k)
            end
        end
        local j = #DiamondIsUnbreakable or 0
        if j > 0 then
            for i = 1, 2, 1 do
                if j == 0 then
                    SMODS.calculate_effect({
                        message = "No Diamonds?",
                        colour = G.C.PURPLE,
                        card = card
                    }, card)
                    break
                end
                sendDebugMessage(inspect(DiamondIsUnbreakable), "KQLOVE")
                local selection = pseudorandom_element(DiamondIsUnbreakable,
                                                       pseudoseed('KQSkill'))
                draw_card(G.deck, G.hand, nil, 'up', false, selection)
                DiamondIsUnbreakable = {}
                for _, k in ipairs(G.deck.cards) do
                    if k:is_suit('Diamonds') and k ~= selection then
                        table.insert(DiamondIsUnbreakable, k)
                    end
                end
                j = j - 1
            end
        else
            SMODS.calculate_effect({
                message = "No Diamonds?",
                colour = G.C.PURPLE,
                card = card
            }, card)
        end
        return true
    end,
    can_use = function(self, card)
        if G.STATE == G.STATES.SELECTING_HAND or G.STATE == G.STATES.TAROT_PACK or
            G.STATE == G.STATES.SPECTRAL_PACK then
            return true
        else
            return false
        end
    end
}
