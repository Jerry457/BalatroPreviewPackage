--- STEAMODDED HEADER
--- MOD_NAME: PreviewPackage
--- MOD_ID: PreviewPackage
--- MOD_AUTHOR: [Jerry]
--- MOD_DESCRIPTION: Real time preview of package content
----------------------------------------------
------------MOD CODE -------------------------

local function predicte_pseudrandom(predicte_fn, ...)
    local ante = G.GAME.round_resets.ante
    local used_jokers = copy_table(G.GAME.used_jokers)
    local banned_keys = copy_table(G.GAME.banned_keys)
    local pool = copy_table(G.ARGS.TEMP_POOL)
    local pool_flags = copy_table(G.GAME.pool_flags)
    local random_data = copy_table(G.GAME.pseudorandom)

    -- local hands_played = G.GAME.current_round.hands_played
    -- local hands_left = G.GAME.current_round.hands_left
    local hand_data = copy_table(G.GAME.hands)

    predicte_fn(...)

    G.GAME.round_resets.ante = ante
    G.GAME.used_jokers = used_jokers
    G.GAME.pool_flags = pool_flags
    G.GAME.banned_keys = banned_keys
    G.ARGS.TEMP_POOL = pool
    G.GAME.pseudorandom = random_data
    -- G.GAME.current_round.hands_played = hands_played
    -- G.GAME.current_round.hands_left = hands_left
    G.GAME.hands = hand_data
end

local function predicte_cards(booster_pack, create_card_fn)
    local pack_size = booster_pack.ability.extra or G.GAME.pack_size
    booster_pack.prediction_cards = {}

    for i = 1, pack_size do
        local card = create_card_fn(i)
        card.T.x = booster_pack.T.x - (pack_size / 2 - 0.5) * card.T.w + (i - 1) * card.T.w
        card.T.y = booster_pack.T.y - card.T.h - 0.5
        card:start_materialize({G.C.WHITE, G.C.WHITE}, nil, 1.5 * G.SETTINGS.GAMESPEED)

        booster_pack.prediction_cards[i] = card
    end
end

local function predicte_arcana_pack()
    if G.GAME.used_vouchers.v_omen_globe and pseudorandom("omen_globe") > 0.8 then
        return create_card("Spectral", G.pack_cards, nil, nil, true, true, nil, "ar2")
    else
        return create_card("Tarot", G.pack_cards, nil, nil, true, true, nil, "ar1")
    end
end

local function predicte_standard_pack()
    local card = create_card((pseudorandom(pseudoseed("stdset" .. G.GAME.round_resets.ante)) > 0.6) and "Enhanced" or "Base", G.pack_cards, nil, nil, nil, true, nil, "sta")
    local edition_rate = 2
    local edition = poll_edition("standard_edition" .. G.GAME.round_resets.ante, edition_rate, true)
    card:set_edition(edition)
    local seal_rate = 10
    local seal_poll = pseudorandom(pseudoseed("stdseal" .. G.GAME.round_resets.ante))
    if seal_poll > 1 - 0.02*seal_rate then
        local seal_type = pseudorandom(pseudoseed("stdsealtype" .. G.GAME.round_resets.ante))
        if seal_type > 0.75 then card:set_seal("Red")
        elseif seal_type > 0.5 then card:set_seal("Blue")
        elseif seal_type > 0.25 then card:set_seal("Gold")
        else card:set_seal("Purple")
        end
    end

    return card
end

local function predicte_celestial_pack(i)
    if G.GAME.used_vouchers.v_telescope and i == 1 then
        local _planet, _hand, _tally = nil, nil, 0
        for k, v in ipairs(G.handlist) do
            if G.GAME.hands[v].visible and G.GAME.hands[v].played > _tally then
                _hand = v
                _tally = G.GAME.hands[v].played
            end
        end
        if _hand then
            for k, v in pairs(G.P_CENTER_POOLS.Planet) do
                if v.config.hand_type == _hand then
                    _planet = v.key
                end
            end
        end
        return create_card("Planet", G.pack_cards, nil, nil, true, true, _planet, "pl1")
    else
        return create_card("Planet", G.pack_cards, nil, nil, true, true, nil, "pl1")
    end
end

local function predicte_spectral_pack()
    return create_card("Spectral", G.pack_cards, nil, nil, true, true, nil, "spe")
end

local function predicte_buffoon_pack()
    return create_card("Joker", G.pack_cards, nil, nil, true, true, nil, "buf")
end

local function predicte_alchemical_pack()
    return create_card("Alchemical", G.pack_cards, nil, nil, true, true, nil, "alc")
end

local function predicte_oddity_pack()
    return create_card("Oddity", G.pack_cards, nil, nil, true, true, nil, "odd")
end

local function predicte_colour_pack()
    return create_card("Colour", G.pack_cards, nil, nil, true, true, nil, "col")
end

local function predicte_megafilm_pack()
    return create_card("Cine", G.pack_cards, nil, nil, true, true, nil, "film")
end

local function predicte_film_pack()
    return create_card("Cine_Quest", G.pack_cards, nil, nil, true, true, nil, "film")
end

local function predicte_fortune_pack()
    if pseudorandom("fortune-pack-tarot") < 0.75 then
        if pseudorandom("fortune-pack-spectral") < 0.95 then
            return create_pack_card("Fortune", "TarotPlanet", G.pack_cards, nil, nil, true, true, nil, "fort")
        else
            return create_pack_card("Fortune", "Spectral", G.pack_cards, nil, nil, true, true, nil, "fort")
        end
    else
        return create_pack_card("Fortune", "Joker", G.pack_cards, nil, nil, true, true, nil, "fort")
    end
end

local function predicte_suits_pack()
    if pseudorandom("fortune-pack-tarot") < 0.75 then
        if pseudorandom("fortune-pack-spectral") < 0.95 then
            return create_pack_card("Suits", "TarotPlanet", G.pack_cards, nil, nil, true, true, nil, "fort")
        else
            return create_pack_card("Suits", "Spectral", G.pack_cards, nil, nil, true, true, nil, "fort")
        end
    else
        return create_pack_card("Suits", "Joker", G.pack_cards, nil, nil, true, true, nil, "fort")
    end
end

local function predicte_bonus_pack()
    if pseudorandom("fortune-pack-tarot") < 0.75 then
        if pseudorandom("fortune-pack-spectral") < 0.95 then
            return create_pack_card("Bonus", "TarotPlanet", G.pack_cards, nil, nil, true, true, nil, "fort")
        else
            return create_pack_card("Bonus", "Spectral", G.pack_cards, nil, nil, true, true, nil, "fort")
        end
    else
        local card = create_card("Enhanced", G.pack_cards, nil, nil, nil, true, nil, "sta")
                            local edition_rate = 2
                            local edition = poll_edition("standard_edition" .. G.GAME.round_resets.ante, edition_rate, true)
                            card:set_edition(edition)
                            local seal_rate = 10
                            local seal_poll = pseudorandom(pseudoseed("stdseal" .. G.GAME.round_resets.ante))
                            if seal_poll > 1 - 0.02*seal_rate then
                                local seal_type = pseudorandom(pseudoseed("stdsealtype" .. G.GAME.round_resets.ante))
                                if seal_type > 0.75 then card:set_seal("Red")
                                elseif seal_type > 0.5 then card:set_seal("Blue")
                                elseif seal_type > 0.25 then card:set_seal("Gold")
                                else card:set_seal("Purple")
                                end
                            end
        return card
    end

end

function Card:remove_prediction_card()
    for k, card in pairs(self.prediction_cards or {}) do
        card:remove()
        self.prediction_cards[k] = nil
    end
end

local remove = Card.remove
function Card:remove(...)
    self:remove_prediction_card()
    return remove(self, ...)
end

local _click = Card.click
function Card:click(...)
    if self.area and self.area.config and self.area.config.type == "shop" then
        if self.highlighted then -- dis_highlighted
            self:remove_prediction_card()
        elseif self.ability.name:find("Arcana") then
            predicte_pseudrandom(predicte_cards, self, predicte_arcana_pack)
        elseif self.ability.name:find("Celestial") then
            predicte_pseudrandom(predicte_cards, self, predicte_celestial_pack)
        elseif self.ability.name:find("Standard") then
            predicte_pseudrandom(predicte_cards, self, predicte_standard_pack)
        elseif self.ability.name:find("Spectral") then
            predicte_pseudrandom(predicte_cards, self, predicte_spectral_pack)
        elseif self.ability.name:find("Buffoon") then
            predicte_pseudrandom(predicte_cards, self, predicte_buffoon_pack)
        elseif self.ability.name:find("Alchemy") then
            predicte_pseudrandom(predicte_cards, self, predicte_alchemical_pack)
        elseif self.ability.name:find("Oddity") then
            predicte_pseudrandom(predicte_cards, self, predicte_oddity_pack)
        elseif self.ability.name:find("Colour") then
            predicte_pseudrandom(predicte_cards, self, predicte_colour_pack)
        elseif self.ability.name:find("Film") and self.ability.name:find("Mega") then
            predicte_pseudrandom(predicte_cards, self, predicte_megafilm_pack)
        elseif self.ability.name:find("Film") then
            predicte_pseudrandom(predicte_cards, self, predicte_film_pack)
        elseif self.ability.name:find("Fortune") then
            -- predicte_pseudrandom(predicte_cards, self, predicte_fortune_pack)
        elseif self.ability.name:find("Suits") then
            predicte_pseudrandom(predicte_cards, self, predicte_suits_pack)
        elseif self.ability.name:find("Bonus") then
            predicte_pseudrandom(predicte_cards, self, predicte_bonus_pack)
        end
    end

    return _click(self, ...)
end

local _highlight = Card.highlight
function Card:highlight(is_higlighted, ...)
    if not is_higlighted then -- dis_highlighted
        self:remove_prediction_card()
    end
    return _highlight(self, is_higlighted, ...)
end
----------------------------------------------
------------MOD CODE END----------------------
