----

SMODS.Atlas{
    key = "Fubuki_MFG",
    path = "Fubuki_MFG.png",
    px = 71,
    py = 95
}
SMODS.Joker{
    key = "Fubuki_MFG",
    loc_txt = {
        name = "Medical Fee Gamble",
        text = {
            'Every shop item has a',
            '{C:green}#1# in 6{} chance to be {C:attention}free{},',
            'otherwise the price',
            'would be {C:attention}doubled{}.',
            '{C:inactive,s:0.6}(Due to coding constaint,',
            '{C:inactive,s:0.6}this joker doesn\'t work on',
            '{C:inactive,s:0.6}booster packs, vouchers, or rerolls.)'
        }
    },
    config = { extra = {} },
    rarity = 2,
    cost = 8,
    atlas = 'Fubuki_MFG',
    pos = { x = 0, y = 0 },
    loc_vars = function(self, info_queue, card)
        return { vars = { math.min(G.GAME.probabilities.normal * 2 , 6 ) , } }
    end,
    calculate = function(self, card, context)
        if context.buying_card then
            if pseudorandom('fubuki') < G.GAME.probabilities.normal / 3 then
                context.card.cost = 0
                return {
                    message = 'Free!',
                    colour = G.C.MONEY,
                    card = card
                }
            else
                context.card.cost = context.card.cost * 2
                return {
                    message = 'Doubled!',
                    colour = G.C.MONEY,
                    card = card
                }
            end
        end
    end
}

----