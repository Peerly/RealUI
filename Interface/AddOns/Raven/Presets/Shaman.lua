-- Shaman
local L = LibStub("AceLocale-3.0"):GetLocale("Raven")
local BUFF = true
local DEBUFF = false
local p = Raven.ColorPalette

Raven.classSpells.SHAMAN = {
	{ "Ancestral Guidance", BUFF, p.Blue1, cooldown = true, id = 108281 },
	{ "Ancestral Swiftness", BUFF, p.Blue2, cooldown = true, id = 16188 },
	{ "Ascendance", nil, p.Purple3, cooldown = true, id = 114049 },
	{ "Astral Recall", nil, p.Purple2, cooldown = true, school = "Nature", id = 556 },
	{ "Astral Shift", BUFF, p.Purple1, cooldown = true, id = 108271 },
	{ "Bind Elemental", DEBUFF, p.Pink, school = "Nature", id = 76780 },
	{ "Bloodlust", BUFF, p.Red1, cooldown = true, school = "Nature", id = 2825 },
	{ "Burning Wrath", BUFF, p.Red2, id = 77747 },
	{ "Call of the Elements", nil, p.Green3, cooldown = true, id = 108285 },
	{ "Capacitor Totem", nil, p.Blue3, cooldown = true, id = 108269 },
	{ "Chain Heal", nil, p.Green2, school = "Nature", id = 1064 },
	{ "Chain Lightning", nil, p.Blue1, cooldown = true, school = "Nature", id = 421 },
	{ "Cleanse Spirit", nil, p.Gray, cooldown = true, school = "Nature", id = 51886 },
	{ "Clearcasting", BUFF, p.Blue2, id = 16246 },
	{ "Conductivity", BUFF, p.Blue2, id = 108282 },
	{ "Earth Elemental Totem", nil, p.Brown2, cooldown = true, shared = L["Earth/Fire Elementals"], school = "Nature", id = 2062 },
	{ "Earth Shield", BUFF, p.Brown3, id = 974 },
	{ "Earth Shock", DEBUFF, p.Yellow3, cooldown = true, shared = L["Shocks"], school = "Nature", id = 8042 },
	{ "Earthbind", DEBUFF, p.Gray, id = 3600 }, -- from earthbind totem
	{ "Earthbind Totem", nil, p.Gray, cooldown = true, school = "Nature", id = 2484 },
	{ "Earthgrab", DEBUFF, p.Brown3, id = 64695 }, -- from earthgrab totem
	{ "Earthgrab Totem", nil, p.Brown3, cooldown = true, school = "Nature", id = 51485 },
	{ "Earthliving", BUFF, p.Purple2, school = "Nature", id = 51945 },
	{ "Earthliving Weapon", BUFF, p.Green1, school = "Nature", id = 51730 },
	{ "Earthquake", DEBUFF, p.Gray, cooldown = true, school = "Nature", id = 61882 },
	{ "Echo of the Elements", BUFF, p.Orange2, id = 108283 },
	{ "Elemental Blast", BUFF, p.Purple1, cooldown = true, school = "Nature", id = 117014 },
	{ "Elemental Mastery", BUFF, p.Purple3, cooldown = true, school = "Nature", id = 16166 },
	{ "Elemental Oath", BUFF, p.Blue3, id = 51470 },
	{ "Far Sight", BUFF, p.Orange2, school = "Nature", id = 6196 },
	{ "Feral Spirit", nil, p.Cyan, cooldown = true, school = "Nature", id = 51533 },
	{ "Fire Elemental Totem", nil, p.Orange3, cooldown = true, shared = L["Earth/Fire Elementals"], id = 2894 },
	{ "Fire Nova", nil, p.Orange2, cooldown = true, school = "Fire", id = 1535 },
	{ "Flame Shock", DEBUFF, p.Red3, cooldown = true, shared = L["Shocks"], school = "Fire", id = 8050 },
	{ "Flametongue Weapon", BUFF, p.Orange3, school = "Fire", lockout = true, id = 8024 },
	{ "Flurry", BUFF, p.Red2, id = 16282 },
	{ "Freeze", DEBUFF, p.Blue1, id = 63685 },
	{ "Frost Shock", DEBUFF, p.Cyan, cooldown = true, shared = L["Shocks"], school = "Frost", id = 8056 },
	{ "Frostbrand Attack", BUFF, p.Cyan, school = "Frost", id = 54609 },
	{ "Frostbrand Weapon", BUFF, p.Cyan, school = "Frost", lockout = true, id = 8033 },
	{ "Ghost Wolf", BUFF, p.Purple3, school = "Nature", id = 2645 },
	{ "Grace of Air", BUFF, p.Cyan, id = 116956 },
	{ "Grounding Totem", nil, p.Purple2, cooldown = true, school = "Nature", id = 8177 },
	{ "Grounding Totem Effect", BUFF, p.Purple2, id = 8178 },
	{ "Healing Rain", BUFF, p.Blue1, cooldown = true, school = "Nature", id = 73920 },
	{ "Healing Stream", BUFF, p.Blue3, id = 65994 }, -- from healing stream totem
	{ "Healing Stream Totem", nil, p.Blue3, cooldown = true, id = 5394 },
	{ "Healing Tide Totem", nil, p.Green2, cooldown = true, id = 108280 },
	{ "Heroism", BUFF, p.Orange2, cooldown = true, school = "Nature", id = 32182 },
	{ "Hex", DEBUFF, p.Green2, cooldown = true, school = "Nature", id = 51514 },
	{ "Lava Burst", nil, p.Red3, cooldown = true, school = "Fire", id = 51505 },
	{ "Lava Lash", nil, p.Red2, cooldown = true, school = "Fire", id = 60103 },
	{ "Lightning Bolt", nil, p.Blue1, school = "Nature", lockout = true, id = 403 },
	{ "Lightning Shield", BUFF, p.Blue2, school = "Nature", id = 324 },
	{ "Maelstrom Weapon", BUFF, p.Purple3, id = 51530 },
	{ "Magma Totem", nil, p.Red3, id = 8190 },
	{ "Mana Tide", BUFF, p.Blue3, school = "Nature", id = 16191 },
	{ "Mana Tide Totem", nil, p.Blue3, cooldown = true, id = 16190 },
	{ "Nature's Guardian", BUFF, p.Blue1, id = 30884 },
	{ "Primal Strike", nil, p.Brown1, cooldown = true, id = 73899 },
	{ "Primal Wisdom", BUFF, p.Pink, id = 51522 },
	{ "Purge", nil, p.Purple1, school = "Nature", id = 370 },
	{ "Purify Spirit", nil, p.Purple1, cooldown = true, school = "Nature", id = 77130 },
	{ "Reincarnation", nil, p.Purple2, cooldown = true, school = "Nature", id = 20608 },
	{ "Riptide", BUFF, p.Blue2, cooldown = true, school = "Nature", id = 61295 },
	{ "Rockbiter Weapon", BUFF, p.Brown2, school = "Nature", id = 8017 },
	{ "Rolling Thunder", BUFF, p.Gray, id = 88764 },
	{ "Searing Flames", DEBUFF, p.Orange3, id = 77657 },
	{ "Searing Totem", nil, p.Orange3, id = 3599 },
	{ "Shamanistic Rage", BUFF, p.Red1, cooldown = true, id = 30823 },
	{ "Spiritwalker's Grace", BUFF, p.Green3, cooldown = true, school = "Nature", id = 79206 },
	{ "Spirit Link Totem", BUFF, p.Green2, cooldown = true, id = 98008 },
	{ "Spirit Walk", BUFF, p.Yellow2, cooldown = true, id = 58875 },
	{ "Static Charge", DEBUFF, p.Blue3, id = 118905 }, -- from capacitor totem
	{ "Stone Bulwark", BUFF, p.Brown1, school = "Nature", id = 114893 }, -- from stone bulwark totem
	{ "Stone Bulwark Totem", nil, p.Brown1, cooldown = true, id = 108270 },
	{ "Stormblast", DEBUFF, p.Purple3, cooldown = true, id = 115356 },
	{ "Stormlash", BUFF, p.Purple2, school = "Nature", id = 120687 }, -- from stormlash totem
	{ "Stormlash Totem", nil, p.Purple2, cooldown = true, id = 120668 },
	{ "Stormstrike", BUFF, p.Blue1, cooldown = true, id = 17364 },
	{ "Thunderstorm", nil, p.Blue3, cooldown = true, school = "Nature", id = 51490 },
	{ "Tidal Waves", BUFF, p.Cyan, id = 51564 },
	{ "Totemic Projection", nil, p.Blue2, cooldown = true, id = 108287 },
	{ "Tremor Totem", nil, p.Yellow3, cooldown = true, id = 8143 },
	{ "Unleash Earth", DEBUFF, p.Brown3, cooldown = true, school = "Nature", id = 73684 },
	{ "Unleash Elements", nil, p.Pink, cooldown = true, id = 73680 },
	{ "Unleash Flame", BUFF, p.Red3, cooldown = true, school = "Fire", id = 73683 },
	{ "Unleash Frost", DEBUFF, p.Blue3, cooldown = true, school = "Frost", id = 73682 },
	{ "Unleash Life", BUFF, p.Green3, cooldown = true, school = "Nature", id = 73685 },
	{ "Unleash Wind", BUFF, p.Gray, cooldown = true, id = 73681 },
	{ "Unleashed Rage", BUFF, p.Orange1, id = 30809 },
	{ "Water Shield", BUFF, p.Blue3, school = "Nature", id = 52127 },
	{ "Water Walking", BUFF, p.Gray, school = "Nature", id = 546 },
	{ "Wind Shear", nil, p.Gray, cooldown = true, school = "Nature", id = 57994 },
	{ "Windfury Weapon", BUFF, p.Gray, school = "Nature", id = 8232 },
	{ "Windwalk", BUFF, p.Gray, school = "Nature", id = 76557 },
	{ "Windwalk Totem", nil, p.Gray, cooldown = true, id = 108273 },
	-- Totem tracker colors
	{ L["Fire Totem"], nil, p.Red2 },
	{ L["Water Totem"], nil, p.Blue1 },
	{ L["Earth Totem"], nil, p.Brown3 },
	{ L["Air Totem"], nil, p.Purple3 },
}

Raven.classConditions.SHAMAN = {
	["Weapon Buff Missing"] = {
		tests = {
			["Player Status"] = { enable = true, isResting = false, isMounted = false, isFishing = false },
			["Spell Ready"] = { enable = true, spell = 8017, }, -- "Rockbiter Weapon"
			["Buff Type"] = { enable = true, unit = "player", toggle = true, hasBuff = "Mainhand" },
		},	
	},
	["Shield Missing"] = {
		tests = {
			["Player Status"] = { enable = true, inCombat = true },
			["Spell Ready"] = { enable = true, spell = 324, }, -- "Lightning Shield"
			["Any Buffs"] = { enable = true, toggle = true, unit = "player",
				auras = { 52127, 324, 974 }, }, -- "Water Shield", "Lightning Shield", "Earth Shield"
		},	
	},
}
