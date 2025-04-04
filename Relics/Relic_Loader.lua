----

SMODS.Rarity{
    key = "Relic",
    loc_txt = { name = 'Relic' },
    default_weight = 0,
    badge_colour = HEX("33C9FE"),
    pools = {["Joker"] = true},
    get_weight = function(self, weight, object_type)
        return 0
    end,
}

SMODS.Atlas{
    key = "Relic_hololive",
    path = "Relics/Relic_hololive.png",
    px = 71,
    py = 95
}

Holo.Relic_Joker = SMODS.Joker:extend{
    unlocked = false,
    unlock_condition = {type = '', extra = '', hidden = true},

    rarity = "hololive_Relic",
    cost = 20,
    blueprint_compat = true,

    atlas = 'Relic_hololive',
    pos = { x = 0, y = 0 },
    soul_pos = { x = 0, y = 1 },
}

Holo.Relic_unlock_text = {"{E:1,s:1.3}?????",}

function Holo._Relic_Joker(t)
    if t.member == nil then
        SMODS.Joker:__call(t)
        return t
    end

    _t.set_badges = function(_self, card, badges)
        local _branch = self.Members[t.member].branch
        badges[#badges+1] = create_badge(_branch, G.C.WHITE, self.C[_branch], 1.2 )
        for _,gen_key in ipairs(self.Members[t.member].gen)do
            if self.C[gen_key] then
                badges[#badges+1] = create_badge(localize('k_hololive_'..gen_key), self.C[gen_key].back, self.C[gen_key].text, 1.2 )
            else
                badges[#badges+1] = create_badge(localize('k_hololive_'..gen_key), G.C.WHITE, self.C.Hololive , 1.2 )
            end
        end
    end

end

relic_files = {
    "JP0",
    "JP2",

    "JP3",
    "ID1",

    "EN1",
    "EN2",

    "EN3",
    "EN4",
}
for _,file in ipairs(relic_files) do assert(SMODS.load_file("Relics/Relic_"..file..".lua"))()end



----