----
SMODS.Atlas{
    key = "Relic_HoloX",
    path = "Relics/Relic_HoloX.png",
    px = 71,
    py = 95
}

Holo.Relic_Joker{ -- La+ Darknesss
    member = "Laplus",
    key = "Relic_Laplus",
    loc_txt = {
        name = "X of the Commander Chief",
        text = {
            'Played card with rank of {C:attention}10',
            'are retriggered {C:attention}#1#{} times.',
            '{C:attention}+1{} retrigger per {V:1}#2#{} used.'
        }
    },
    config = { extra = {
        retriggers = 2,
        upgrade_args = {
            scale_var = 'retriggers',
        }
    }},
    loc_vars = function(self, info_queue, card)
        local x_unlock = G.P_CENTERS.c_planet_x.unlocked
        if x_unlock then
            info_queue[#info_queue+1] = G.P_CENTERS.c_planet_x
        end
        local local_x = localize({key='c_planet_x', set='Planet', type='name_text'})
        return {
            vars = {
                card.ability.extra.retriggers,
                x_unlock and local_x or '?????',
                colours= {x_unlock and G.C.SECONDARY_SET.Planet or G.C.UI.TEXT_DARK}
            }
        }
    end,

    atlas = 'Relic_HoloX',
    pos      = { x = 0, y = 0 },
    soul_pos = { x = 0, y = 1 },

    calculate = function(self, card, context)
        holo_card_upgrade_by_consumeable(card, context, 'c_planet_x')
        if context.repetition and context.cardarea==G.play then
            if context.other_card:get_id()==10 then
                return{
                    repetitions = card.ability.extra.retriggers,
                    colour=Holo.C.Laplus
                }
            end
        end
    end
}

Holo.Relic_Joker{ -- Takane Lui
    member = "Lui",
    key = "Relic_Lui",
    loc_txt = {
        name = "X of the Sage Hawk",
        text = {
            'Create a {C:tarot}Hermit{} card every {C:attention}#3# {C:inactive}[#4#]{} times',
            'a playing card with rank of {C:attention}10{} scores.',
            '{C:inactive}(Must have room)',
            'Gain X#2# mult per {C:tarot}The Hermit{} card used.',
            '{C:inactive}(Currently {X:mult,C:white}X#1#{C:inactive} Mult)'
        }
        ,boxes={3,2}
    },
    config = { extra = {
        Xmult = 1, Xmult_mod = 0.25,
        count_args = {
            down = 5,
            init = 5
        },
        upgrade_args = {
            scale_var = 'Xmult',
            --message = 'Haha!'
        }
    }},
    loc_vars = function(self, info_queue, card)
        local cae = card.ability.extra
        info_queue[#info_queue+1] = G.P_CENTERS.c_hermit
        return {
            vars = {
                cae.Xmult,
                cae.Xmult_mod,
                cae.count_args.init,
                cae.count_args.down,
            }
        }
    end,

    atlas = 'Relic_HoloX',
    pos      = { x = 1, y = 0 },
    soul_pos = { x = 1, y = 1 },

    calculate = function(self, card, context)
        local cae = card.ability.extra
        holo_card_upgrade_by_consumeable(card, context, 'c_hermit')
        if context.individual and context.cardarea==G.play then
            if context.other_card:get_id()==10 and not context.blueprint then
                if holo_card_counting(card, context) then
                    if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                        G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                        return {
                            func = function()
                                G.GAME.consumeable_buffer = G.GAME.consumeable_buffer - 1
                                SMODS.add_card({ key = 'c_hermit', area = G.consumeables})
                            end,
                            card = card,
                        }
                    end
                end
            end
        elseif context.joker_main then
            return{
                Xmult = cae.Xmult,
                colour = Holo.C.Lui,
            }
        end
    end
}

SMODS.Atlas{ -- Hakui Koyori: Potion Sprites
    key = "Sticker_Potions",
    path = "textures/Sticker_Potions.png",
    px = 71,
    py = 95
}
local Koyori_Potion = SMODS.Sticker:extend{
    member = "Koyori",
    atlas="hololive_Sticker_Potions",
    hide_badge=true,
    should_apply = function(self, card, center, area, bypass_roll)
        for _, pc in ipairs({'red','cyan','pink','green','gold','blue'}) do
            if card.ability['hololive_potion_'..pc] then
                return false
            end
        end
        return ((area==G.hand)or bypass_roll)and(card and card.playing_card and card:get_id()==10)
    end,
    calculate = function(self, card, context)
        if context.before and context.cardarea==G.play then
            if self.key == 'hololive_potion_cyan' then
                card.ability.has_given_chips=false
            elseif self.key == 'hololive_potion_green' then
                G.GAME.probabilities.normal = G.GAME.probabilities.normal * 5.4
                card.potion_trigger=true
                return{message='Chance!',colour=G.C.GREEN}
            elseif self.key == 'hololive_potion_gold' then
                card.potion_trigger=true
                return{dollars=10,colour=G.C.GOLD}
            elseif self.key == 'hololive_potion_blue' then
                card.potion_trigger=true
                return{level_up=1,colour=HEX('217eb7')}
            end
        elseif context.repetition and context.cardarea==G.play then
            if self.key == 'hololive_potion_pink' then
                card.potion_trigger=true
                return{repetitions=2,colour=HEX('e97896')}
            end
        elseif context.main_scoring and context.cardarea==G.play then
            if self.key == 'hololive_potion_red' then
                card.potion_trigger=true
                return{mult=10,colour=G.C.RED}
            elseif self.key == 'hololive_potion_cyan' and not card.ability.has_given_chips then
                card.ability.has_given_chips=true
                card.potion_trigger=true
                return{chips=54,colour=G.C.CHIPS}
            end
        elseif context.after and context.cardarea==G.play then
            if self.key == 'hololive_potion_green' then
                G.GAME.probabilities.normal = G.GAME.probabilities.normal / 5.4
            end
            card.potion_trigger=false
            local pc = self.key
            G.E_MANAGER:add_event(Event({
                func = function()
                    card:remove_sticker(pc)
                    return true
                end
            }))
        end
    end
}
Koyori_Potion{ -- Hakui Koyori: Red Flask
    key='potion_red',
    loc_txt={
        name='Red flask',
        text={
            '{C:mult}+10{} mult',
            'when scored.'
        }
    },
    pos={x=0,y=0},
}
Koyori_Potion{ -- Hakui Koyori: Cyan Flask
    key='potion_cyan',
    loc_txt={
        name='Cyan flask',
        text={
            '{C:chips}+54{} chips',
            'when played.'
        }
    },
    pos={x=0,y=1},
}
Koyori_Potion{ -- Hakui Koyori: Pink Testtube
    key='potion_pink',
    loc_txt={
        name='Pink testtube',
        text={
            'Retriggered {V:1}twice',
            'when played.'
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { colours = {HEX('e97896')}}}
    end,
    pos={x=1,y=0},
}
Koyori_Potion{ -- Hakui Koyori: Green Testtube
    key='potion_green',
    loc_txt={
        name='Green testtube',
        text={
            'Probability {C:green}X5.4',
            'while played.'
        }
    },
    pos={x=2,y=0},
}
Koyori_Potion{ -- Hakui Koyori: Gold Testtube
    key='potion_gold',
    loc_txt={
        name='Gold testtube',
        text={
            'Earn {C:gold}$10',
            'when played.'
        }
    },
    pos={x=1,y=1},
}
Koyori_Potion{ -- Hakui Koyori: Blue Testtube
    key='potion_blue',
    loc_txt={
        name='Blue testtube',
        text={
            'Level up played',
            '{V:1}poker hand',
            'when played.'
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { colours = {HEX('217eb7')}}}
    end,
    pos={x=2,y=1},
}

Holo.Relic_Joker{ -- Hakui Koyori
    member = "Koyori",
    key = "Relic_Koyori",
    loc_txt = {
        name = "X of the Chemist Coyote",
        text = {
            'Cards with rank of {C:attention}10{} receive random',
            '{C:dark_edition}chemical effects{} when drawn to hand.',
            'Gain {X:mult,C:white}X#2#{} mult every time a chemical effect',
            'is triggered. {C:inactive}(Currently {X:mult,C:white}X#1#{C:inactive} Mult)',
            'Chemical effects are cleared at {C:attention}end of round{}.'
        }
        ,boxes={2,2,1}
    },
    config = { extra = {
        Xmult = 2, Xmult_mod = 0.2,
        upgrade_args = {
            scale_var = 'Xmult',
        },
        Potion_Rack = {
            red  = 3,
            cyan = 3,
            pink = 2,
            green= 1,
            gold = 2,
            blue = 1
        }
    }},
    loc_vars = function(self, info_queue, card)
        local cae = card.ability.extra
        return {
            vars = {
                cae.Xmult,
                cae.Xmult_mod,
            }
        }
    end,

    atlas = 'Relic_HoloX',
    pos      = { x = 2, y = 0 },
    soul_pos = { x = 2, y = 1 },

    calculate = function(self, card, context)
        local cae = card.ability.extra
        if context.draw_from_deck_to_hand and G.GAME.facing_blind then
            if context.card_drawn:get_id()==10 and not context.blueprint then
                local _potion_type = Holo.pseudorandom_weighted_element(cae.Potion_Rack, 'Koyo')
                G.E_MANAGER:add_event(Event({
                    func = function()
                        context.card_drawn:add_sticker('hololive_potion_'.._potion_type)
                        return true
                    end
                }))
            end
        elseif context.before then
            for _,v in ipairs(context.full_hand)do
                if v.potion_trigger then -- Green, Gold, Blue
                    holo_card_upgrade(card)
                    v.potion_trigger=false
                end
            end
        elseif (context.individual or context.repetition) and context.cardarea==G.play then
            if context.other_card.potion_trigger then -- Red, Cyan, Pink
                holo_card_upgrade(card)
                context.other_card.potion_trigger=false
            end
        elseif context.end_of_round and context.cardarea==G.jokers then
            for _,v in ipairs(G.playing_cards)do
                for _,pc in ipairs({'red','cyan','pink','green','gold','blue'})do
                    v:remove_sticker('hololive_potion_'..pc)
                end
            end
        elseif context.joker_main then
            return{
                Xmult = cae.Xmult,
                colour = Holo.C.Koyori,
            }
        end
    end
}

Holo.Relic_Joker{ -- Sakamata Chloe
    member = "Chloe",
    key = "Relic_Chloe",
    loc_txt = {
        name = "X of the Cleaner Orca",
        text = {
            'Discarded cards with ranks {C:attention}other than 10',
            'have {C:green}#5# in #6#{} chance to get {C:red}cleaned away{}.',
            'Create a {C:dark_edition}Negative {C:tarot}Magician{} every {C:attention}#4# {C:inactive}[#3#]{} discards.',
            'Gain {X:mult,C:white}X#2#{} mult per discard with no card',
            'needed to be cleaned. {C:inactive}(Currently {X:mult,C:white}X#1#{C:inactive} Mult)'
        }
        ,boxes={2,1,2}
    },
    config = { extra = {
        Xmult=5, Xmult_mod=0.5,
        odds=5,
        upgrade_args = {
            scale_var = 'Xmult',
        },
        count_args = {
            down = 5, init = 5
        }
    }},
    loc_vars = function(self, info_queue, card)
        local cae = card.ability.extra
        info_queue[#info_queue+1] = G.P_CENTERS.c_magician
        return {
            vars = {
                cae.Xmult, cae.Xmult_mod,
                cae.count_args.down,
                cae.count_args.init,
                Holo.prob_norm(), cae.odds,
            }
        }
    end,

    atlas = 'Relic_HoloX',
    pos      = { x = 3, y = 0 },
    soul_pos = { x = 3, y = 1 },

    calculate = function(self, card, context)
        local cae = card.ability.extra
        if context.pre_discard then
            if Holo.series_and(context.full_hand, function(v)return(v:get_id()==10)end)then
                holo_card_upgrade(card)
            end
            if holo_card_counting(card, context) then
                SMODS.add_card({ key = 'c_magician', area = G.consumeables, edition = 'e_negative' })
            end
        elseif context.discard then
            if context.other_card:get_id()~=10 then
                if Holo.chance('Chloe', cae.odds) then
                    return{remove=true,message='Baku!',colour=Holo.C.Chloe}
                end
            end
        elseif context.joker_main then
            return{Xmult=cae.Xmult,colour=Holo.C.Chloe}
        end
    end
}

Holo.Relic_Joker{ -- Kazama Iroha
    member = "Iroha",
    key = "Relic_Iroha",
    loc_txt = {
        name = "X of the Bodyguard Samurai",
        text = {
            'Played cards with ranks {C:attention}other than 10',
            'have {C:green}#5# in #6#{} chance to get {C:red}slashed{} after scoring.',
            'Create a {C:dark_edition}Negative {C:tarot}Star{} every {C:attention}#4# {C:inactive}[#3#]{} played hand.',
            'Gain {X:mult,C:white}X#2#{} mult per played hand with no card',
            'needed to be slashed. {C:inactive}(Currently {X:mult,C:white}X#1#{C:inactive} Mult)'
        }
        ,boxes={2,1,2}
    },
    config = { extra = {
        Xmult=5, Xmult_mod=0.5,
        odds=5,
        upgrade_args = {
            scale_var = 'Xmult',
        },
        count_args = {
            down = 5, init = 5
        }
    }},
    loc_vars = function(self, info_queue, card)
        local cae = card.ability.extra
        info_queue[#info_queue+1] = G.P_CENTERS.c_star
        return {
            vars = {
                cae.Xmult, cae.Xmult_mod,
                cae.count_args.down,
                cae.count_args.init,
                Holo.prob_norm(), cae.odds,
            }
        }
    end,

    atlas = 'Relic_HoloX',
    pos      = { x = 4, y = 0 },
    soul_pos = { x = 4, y = 1 },

    calculate = function(self, card, context)
        local cae = card.ability.extra
        if context.before then
            if Holo.series_and(context.scoring_hand, function(v)return(v:get_id()==10)end)then
                holo_card_upgrade(card)
            end
            if holo_card_counting(card, context) then
                SMODS.add_card({ key = 'c_star', area = G.consumeables, edition = 'e_negative' })
            end
        elseif context.destroy_card and context.cardarea == G.play then
            if context.destroy_card:get_id()~=10 then
                if Holo.chance('Iroha', cae.odds) then
                    return{remove=true,message='Sha-kin!',colour=Holo.C.Iroha}
                end
            end
        elseif context.joker_main then
            return{Xmult=cae.Xmult,colour=Holo.C.Iroha}
        end
    end
}

----