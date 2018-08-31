local pl = require "pl.import_into"()
local pretty = pl.pretty
local lapp = pl.lapp
local xml = pl.xml
local path = pl.path
local tablex = pl.tablex

local pcall = pcall
local love_image_newImageData = love.image.newImageData

local TileSize = 16
local MiniTileSize = TileSize/2
local Tileset_CombinedPagesCs = 6
local Tileset_CombinedPagesRs = 24
local Tileset_CombinedPagesW = TileSize*Tileset_CombinedPagesCs
local Tileset_CombinedPagesH = TileSize*Tileset_CombinedPagesRs

local Tileset_WaterAnimsC
local Tileset_WaterAnimsR
local Tileset_WaterAnimsCs
local Tileset_WaterAnimsRs
local Tileset_TileAnimsC
local Tileset_TileAnimsR
local Tileset_TileAnimsCs
local Tileset_TileAnimsRs
local Tileset_GroundTilesC
local Tileset_GroundTilesR
local Tileset_GroundTilesCs
local Tileset_GroundTilesRs
local Tileset_LoTilesX
local Tileset_LoTilesY
local Tileset_HiTilesC
local Tileset_HiTilesR

local Tileset_GroundTileCorners
local Tileset_WaterAnimCornersBase
local Tileset_WaterAnimCorners

local Tileset_TerrainCollectionType
local Tileset_TerrainType
local Tileset_Terrains
local Tileset_TileTerrains

local TerrainGranularity

local Tileset_WaterAnimsX
local Tileset_WaterAnimsY
local Tileset_WaterAnimsW
local Tileset_WaterAnimsH
local Tileset_TileAnimsX
local Tileset_TileAnimsY
local Tileset_TileAnimsW
local Tileset_TileAnimsH
local Tileset_GroundTilesX
local Tileset_GroundTilesY
local Tileset_GroundTilesW
local Tileset_GroundTilesH
local Tileset_HiTilesX
local Tileset_HiTilesY
local TilesetN
local TilesetW
local TilesetH

local XML_Tile, XML_Animation, XML_Frame = xml.tags('tile, animation, frame')
local XML_Terrain

local TilesetXML
local Tileset_TerrainsXML

local XML_WangEdgeColor, XML_WangCornerColor, XML_WangTile = xml.tags('wangedgecolor, wangcornercolor, wangtile')

local WangColors = {
	"#000000", "#0000AA", "#00AA00", "#00AAAA", "#AA0000", "#AA00AA", "#AA5500", "#AAAAAA",
	"#555555", "#5555FF", "#55FF55", "#55FFFF", "#FF5555", "#FF55FF", "#FFFF55"
}

local function BuildTerrainsXML(typ, c1, r1, cs, rs, cstride, rstride)
	local terrain = {}
	local color = { tile = -1 }

	for id1 = r1*TilesetCs + c1, (r1+rs-rstride)*TilesetCs + c1, rstride*TilesetCs do
		for id = id1, id1 + cs - cstride, cstride do
			terrain.name=typ..id
			terrain.tile=id

			if Tileset_TerrainType == "wangset" then
				for i = 0, 1 do
					color.probability = i == 0 and 1/16 or 1
					color.color = string.format("#%06x", bit.lshift(0x80, i*8))
					terrain[#terrain + 1] = XML_WangEdgeColor(color)
					terrain[#terrain + 1] = XML_WangCornerColor(color)
				end
			end

			local terrainxml = XML_Terrain(terrain)
			Tileset_Terrains[#Tileset_Terrains + 1] = terrainxml
			Tileset_TerrainsXML:add_child(terrainxml)
			tablex.clear(terrain)
		end
	end
end

local function BuildTilesXML(c1, r1, cs, rs, cstride, rstride, tilecorners, framesbase)
	local frames = {}
	local tile = {}
	local frame = {}
	local wangtile = {}
	local i = 4
	for id1 = r1*TilesetCs + c1, (r1+rs-rstride)*TilesetCs + c1, rstride*TilesetCs do
		for id = id1, id1 + cs - cstride, cstride do
			tile.id = id
			tile.probability = nil

			if tilecorners and i <= #tilecorners then
				local se = tilecorners[i]

				if se == 'du' then
					tile.probability = 0
				end

				i = i + 4
				if i > #tilecorners then
					i = 4
				end
			end

			local terrain = Tileset_TileTerrains[id]
			if Tileset_TerrainType == "terrain" then
				tile.terrain = terrain
			elseif Tileset_TerrainType == "wangset" and terrain then
				local wangset, wangid = terrain:match("(%x),(0x%x%x%x%x%x%x%x%x)")
				terrain = Tileset_Terrains[tonumber(wangset, 16)+1]

				wangtile.tileid = id
				wangtile.wangid = wangid
				terrain[#terrain + 1] = XML_WangTile(wangtile)
			end

			if framesbase then
				for f = 2, #framesbase, 2 do
					frame.tileid = id + framesbase[f-1]
					frame.duration = framesbase[f]
					frames[#frames+1] = XML_Frame(frame)
				end
			end

			if #frames > 0 or tile.terrain or tile.probability then
				local tileelem = XML_Tile(tile)
				if #frames > 0 then
					tileelem:add_child(XML_Animation(frames))
				end
				TilesetXML:add_child(tileelem)
			end

			tablex.clear(frames)
		end
	end
end

local function Init_Common()
	Tileset_WaterAnimCorners = {}

	local shorecorners = Tileset_WaterAnimCornersBase

	local watercorners = Tileset_WaterAnimCorners
	for i = 4, #shorecorners, 4 do
		for e = 1,2 do
			for f = 1,3 do
				for j = -3,0 do
					local corner = shorecorners[i+j]
					if corner == 'ct' then
						corner = 'W'..corner
					else
						corner = e..corner
					end

					watercorners[#watercorners+1] = corner..f
				end
			end
		end
	end

	Tileset_WaterAnimsX = TileSize*Tileset_WaterAnimsC
	Tileset_WaterAnimsY = TileSize*Tileset_WaterAnimsR
	Tileset_WaterAnimsW = TileSize*Tileset_WaterAnimsCs
	Tileset_WaterAnimsH = TileSize*Tileset_WaterAnimsRs
	Tileset_TileAnimsX = TileSize*Tileset_TileAnimsC
	Tileset_TileAnimsY = TileSize*Tileset_TileAnimsR
	Tileset_TileAnimsW = TileSize*Tileset_TileAnimsCs
	Tileset_TileAnimsH = TileSize*Tileset_TileAnimsRs
	Tileset_GroundTilesX = TileSize*Tileset_GroundTilesC
	Tileset_GroundTilesY = TileSize*Tileset_GroundTilesR
	Tileset_GroundTilesW = TileSize*Tileset_GroundTilesCs
	Tileset_GroundTilesH = TileSize*Tileset_GroundTilesRs
	Tileset_HiTilesX = TileSize*Tileset_HiTilesC
	Tileset_HiTilesY = TileSize*Tileset_HiTilesR
	TilesetN = TilesetCs*TilesetRs
	TilesetW = TileSize*TilesetCs
	TilesetH = TileSize*TilesetRs

	Tileset_Terrains = {}
	Tileset_TileTerrains = {}

	TilesetXML = xml.elem("tileset", {
		name = "$tilesetname",
		tilewidth = TileSize,
		tileheight = TileSize,
		tilecount = TilesetN,
		columns = TilesetCs,
		xml.elem("image", {
			source = "$imagefile",
			width = TilesetW,
			height = TilesetH
		})
	})

	Tileset_TerrainsXML = xml.elem(Tileset_TerrainCollectionType)
	TilesetXML:add_child(Tileset_TerrainsXML)

	XML_Terrain = xml.tags(Tileset_TerrainType)
end

--[[ Minitile codes
	du	dummy
	ct	center
	xa	external angle
	ia	internal angle
	he	horizontal edge
	ve	vertical edge
	sh	showcase (unused)

	Prefixes
	#	shore index
	W	shallow water
	D	deep water

	Suffixes
	#	animation frame
]]

--[[ Terrain granularity 2, using terrains
	LLLLLLHHHHHHWwwXxxGGGGGGGG
	LLLLLLHHHHHHWwwXxxGGGGGGGG
	LLLLLLHHHHHHWwwXxxGGGGGGGG
	LLLLLLHHHHHHWwwXxxGGGGGGGG
	LLLLLLHHHHHHWwwXxxGGGGGGGG
	LLLLLLHHHHHHWwwXxxGGGGGGGG
	LLLLLLHHHHHHWwwXxxGGGGGGGG
	LLLLLLHHHHHHWwwXxxGGGGGGGG
	LLLLLLHHHHHHWwwXxxGGGGGGGG
	LLLLLLHHHHHHWwwXxxGGGGGGGG
	LLLLLLHHHHHHWwwXxxGGGGGGGG
	LLLLLLHHHHHHWwwXxxGGGGGGGG
	LLLLLLHHHHHHWwwXxxGGGGGGGG
	LLLLLLHHHHHHWwwXxxGGGGGGGG
	LLLLLLHHHHHHWwwXxxGGGGGGGG
	LLLLLLHHHHHH      GGGGGGGG
	LLLLLLHHHHHH      GGGGGGGG
	LLLLLLHHHHHH      GGGGGGGG
	LLLLLLHHHHHH      GGGGGGGG
	LLLLLLHHHHHH      GGGGGGGG
	LLLLLLHHHHHH      GGGGGGGG
	LLLLLLHHHHHH      GGGGGGGG
	LLLLLLHHHHHHABCabcGGGGGGGG
	LLLLLLHHHHHHabcabcGGGGGGGG
--]]

local function BuildTileTerrain(t, t0, tcorner, tilecorners, c1, r1, cs, rs, cstride, rstride)
	local i = 4
	for id1 = r1*TilesetCs + c1, (r1+rs-rstride)*TilesetCs + c1, rstride*TilesetCs do
		for id = id1, id1 + cs - cstride, cstride do
			local nw, ne, sw, se =
				tilecorners[i-3], tilecorners[i-2],
				tilecorners[i-1], tilecorners[i-0]

			local terrain = "%s,%s,%s,%s"
			terrain = terrain:format(
				(nw == tcorner) and t or (nw ~= 'du') and t0 or '',
				(ne == tcorner) and t or (ne ~= 'du') and t0 or '',
				(sw == tcorner) and t or (sw ~= 'du') and t0 or '',
				(se == tcorner) and t or (se ~= 'du') and t0 or '')

			Tileset_TileTerrains[id] = terrain

			i = i + 4
			if i > #tilecorners then
				return
			end
		end
	end
end

local function Init_Granularity2()
	Tileset_LoTilesX = TileSize*0
	Tileset_LoTilesY = TileSize*0
	Tileset_HiTilesC = 6
	Tileset_HiTilesR = 0

	Tileset_WaterAnimsC = 12
	Tileset_WaterAnimsR = 0
	Tileset_WaterAnimsCs = 6
	Tileset_WaterAnimsRs = 15

	Tileset_TileAnimsC = 12
	Tileset_TileAnimsR = 22
	Tileset_TileAnimsCs = 6
	Tileset_TileAnimsRs = 2

	Tileset_GroundTilesC = 18
	Tileset_GroundTilesR = 0
	Tileset_GroundTilesCs = 8
	Tileset_GroundTilesRs = 24

	TilesetCs = 2*Tileset_CombinedPagesCs + Tileset_GroundTilesCs + Tileset_WaterAnimsCs
	TilesetRs = Tileset_CombinedPagesRs

	Tileset_GroundTileCorners = {
		'ct','ct','ct','ct', 'du','du','du','du',
		'ia','he','ve','ct', 'he','he','ct','ct',
		'he','ia','ct','ve', 've','ct','ve','ct', 'ct','ve','ct','ve',
		've','ct','ia','he', 'ct','ct','he','he', 'ct','ve','he','ia',
		'xa','ct','ct','ct', 'ct','xa','ct','ct', 'ct','ct','xa','ct',
		'ct','ct','ct','xa', 'xa','ct','ct','xa', 'ct','xa','xa','ct',
	}

	Tileset_WaterAnimCornersBase = {
		'ct', 'ct', 'ct', 'ct',
		'ia','','','',
		'','ia','','',
		'','','ia','',
		'','','','ia',
		'','ia','ia','',
		'ia','','','ia',
		'he','he','','',
		'','','he','he',
		've','','ve','',
		'','ve','','ve',
		'xa','he','ve','',
		'he','xa','','ve',
		've','','xa','he',
		'','ve','he','xa',
	}

	local Tileset_TileAnimFramesBase = {
		TilesetCs*0 + 0, 125,
		TilesetCs*0 + 3, 125,
		TilesetCs*1 + 0, 125,
		TilesetCs*1 + 3, 125
	}

	local Tileset_WaterAnimFramesBase = {
		0, 125,
		1, 125,
		2, 125,
		1, 125
	}

	Tileset_TerrainCollectionType = "terraintypes"
	Tileset_TerrainType = "terrain"

	Init_Common()

	BuildTileTerrain(0, 0, 'ct', Tileset_GroundTileCorners,
		Tileset_GroundTilesC, Tileset_GroundTilesR,
		1, 1,
		1, 1)
	BuildTerrainsXML("Ground", Tileset_GroundTilesC, Tileset_GroundTilesR, 1,1,1,1)

	for t = 1, 11 do
		local terrainr = Tileset_GroundTilesR+(2*t)
		BuildTileTerrain(t, 0, 'ct', Tileset_GroundTileCorners,
			Tileset_GroundTilesC, terrainr,
			Tileset_GroundTilesCs, 2,
			1, 1)

		BuildTerrainsXML("Ground", Tileset_GroundTilesC, terrainr, 1,1,1,1)
	end

	for t = 12, 13 do
		local terrainc = Tileset_WaterAnimsC+((t-12)*3)
		BuildTileTerrain('', t, '', Tileset_WaterAnimCornersBase,
			terrainc, Tileset_WaterAnimsR,
			Tileset_WaterAnimsCs/2, Tileset_WaterAnimsRs,
			3, 1)

		BuildTerrainsXML("Water", terrainc, Tileset_WaterAnimsR, 1,1,1,1)
	end

	BuildTilesXML(
		Tileset_GroundTilesC, Tileset_GroundTilesR,
		Tileset_GroundTilesCs, Tileset_GroundTilesRs,
		1, 1,
		Tileset_GroundTileCorners)
	BuildTilesXML(
		Tileset_WaterAnimsC, Tileset_WaterAnimsR,
		Tileset_WaterAnimsCs, Tileset_WaterAnimsRs,
		3, 1,
		Tileset_WaterAnimCornersBase,
		Tileset_WaterAnimFramesBase)
	BuildTilesXML(
		Tileset_TileAnimsC, Tileset_TileAnimsR,
		3, 1,
		1, 1,
		nil,
		Tileset_TileAnimFramesBase)
end

--[[ Terrain granularity 1, using Wang tiles
	LLLLLLHHHHHHAWwwXxxWwwXxxGGGGGGGGGGGGGGGGGGGGGGGG
	LLLLLLHHHHHHBWwwXxxWwwXxxGGGGGGGGGGGGGGGGGGGGGGGG
	LLLLLLHHHHHHCWwwXxxWwwXxxGGGGGGGGGGGGGGGGGGGGGGGG
	LLLLLLHHHHHHaWwwXxxWwwXxxGGGGGGGGGGGGGGGGGGGGGGGG
	LLLLLLHHHHHHbWwwXxxWwwXxxGGGGGGGGGGGGGGGGGGGGGGGG
	LLLLLLHHHHHHcWwwXxxWwwXxxGGGGGGGGGGGGGGGGGGGGGGGG
	LLLLLLHHHHHHaWwwXxxWwwXxxGGGGGGGGGGGGGGGGGGGGGGGG
	LLLLLLHHHHHHbWwwXxxWwwXxxGGGGGGGGGGGGGGGGGGGGGGGG
	LLLLLLHHHHHHcWwwXxxWwwXxxGGGGGGGGGGGGGGGGGGGGGGGG
	LLLLLLHHHHHHaWwwXxxWwwXxxGGGGGGGGGGGGGGGGGGGGGGGG
	LLLLLLHHHHHHbWwwXxxWwwXxxGGGGGGGGGGGGGGGGGGGGGGGG
	LLLLLLHHHHHHcWwwXxxWwwXxxGGGGGGGGGGGGGGGGGGGGGGGG
	LLLLLLHHHHHH WwwXxxWwwXxxGGGGGGGGGGGGGGGGGGGGGGGG
	LLLLLLHHHHHH WwwXxxWwwXxxGGGGGGGGGGGGGGGGGGGGGGGG
	LLLLLLHHHHHH WwwXxxWwwXxxGGGGGGGGGGGGGGGGGGGGGGGG
	LLLLLLHHHHHH WwwXxxWwwXxxGGGGGGGGGGGGGGGGGGGGGGGG
	LLLLLLHHHHHH WwwXxxWwwXxxGGGGGGGGGGGGGGGGGGGGGGGG
	LLLLLLHHHHHH WwwXxxWwwXxxGGGGGGGGGGGGGGGGGGGGGGGG
	LLLLLLHHHHHH WwwXxxWwwXxxGGGGGGGGGGGGGGGGGGGGGGGG
	LLLLLLHHHHHH WwwXxxWwwXxxGGGGGGGGGGGGGGGGGGGGGGGG
	LLLLLLHHHHHH WwwXxxWwwXxxGGGGGGGGGGGGGGGGGGGGGGGG
	LLLLLLHHHHHH WwwXxxWwwXxxGGGGGGGGGGGGGGGGGGGGGGGG
	LLLLLLHHHHHH WwwXxxWwwXxxGGGGGGGGGGGGGGGGGGGGGGGG
	LLLLLLHHHHHH WwwXxxWwwXxxGGGGGGGGGGGGGGGGGGGGGGGG
--]]

local function GetGroundWangColors(corner, minitile, outcolor, incolor)
	if minitile == 'ct' then
		return incolor, incolor
	elseif minitile == 'xa' then
		return incolor, outcolor
	elseif minitile == 'ia' then
		return outcolor, outcolor
	end
	if corner == 'ne' or corner == 'sw' then
		if minitile == 'he' then
			return outcolor, outcolor
		elseif minitile == 've' then
			return incolor, outcolor
		end
	end
	if corner == 'se' or corner == 'nw' then
		if minitile == 'he' then
			return incolor, outcolor
		elseif minitile == 've' then
			return outcolor, outcolor
		end
	end
	return outcolor, outcolor
end

local function GetWaterWangColors(corner, minitile, outcolor, incolor)
	if minitile == 'ct' or minitile == 'xa' then
		return incolor, incolor
	elseif minitile == 'ia' then
		return outcolor, incolor
	end
	if corner == 'ne' or corner == 'sw' then
		if minitile == 'he' then
			return incolor, incolor
		elseif minitile == 've' then
			return outcolor, incolor
		end
	end
	if corner == 'se' or corner == 'nw' then
		if minitile == 'he' then
			return outcolor, incolor
		elseif minitile == 've' then
			return incolor, incolor
		end
	end
	return outcolor, outcolor
end

local function BuildWangTiles(t, outcolor, incolor, getwangcolors, tilecorners, c1, r1, cs, rs, cstride, rstride)
	local i = 4
	local color_n, color_ne, color_e, color_se, color_s, color_sw, color_w, color_nw
	for id1 = r1*TilesetCs + c1, (r1+rs-rstride)*TilesetCs + c1, rstride*TilesetCs do
		for id = id1, id1 + cs - cstride, cstride do
			local nw, ne, sw, se =
			tilecorners[i-3], tilecorners[i-2],
			tilecorners[i-1], tilecorners[i-0]

			color_n, color_ne = getwangcolors('ne', ne, outcolor, incolor)
			color_e, color_se = getwangcolors('se', se, outcolor, incolor)
			color_s, color_sw = getwangcolors('sw', sw, outcolor, incolor)
			color_w, color_nw = getwangcolors('nw', nw, outcolor, incolor)

			Tileset_TileTerrains[id] = string.format(
					"%x,0x%x%x%x%x%x%x%x%x",
					t, color_nw, color_w, color_sw, color_s,
					color_se, color_e, color_ne, color_n)

			i = i + 4
			if i > #tilecorners then
				return
			end
		end
	end
end

local function Init_Granularity1()
	Tileset_LoTilesX = TileSize*0
	Tileset_LoTilesY = TileSize*0
	Tileset_HiTilesC = 6
	Tileset_HiTilesR = 0

	Tileset_WaterAnimsC = 13
	Tileset_WaterAnimsR = 0
	Tileset_WaterAnimsCs = 12
	Tileset_WaterAnimsRs = 24

	Tileset_TileAnimsC = 12
	Tileset_TileAnimsR = 0
	Tileset_TileAnimsCs = 1
	Tileset_TileAnimsRs = 12

	Tileset_GroundTilesC = 25
	Tileset_GroundTilesR = 0
	Tileset_GroundTilesCs = 24
	Tileset_GroundTilesRs = 24

	TilesetCs = 2*Tileset_CombinedPagesCs + Tileset_TileAnimsCs + Tileset_WaterAnimsCs + Tileset_GroundTilesCs
	TilesetRs = Tileset_GroundTilesRs

	Tileset_GroundTileCorners = {
		'ct','ct','ct','ct', 'du','du','du','du', 'xa','ct','ct','ct', 'ct','xa','ct','ct',
		'xa','xa','ct','ct', 'ct','ct','ct','xa', 'xa','ct','ct','xa', 'ct','xa','ct','xa',
		'xa','xa','ct','xa', 'ct','ct','xa','ct', 'xa','ct','xa','ct', 'ct','xa','xa','ct',
		'xa','xa','xa','ct', 'ct','ct','xa','xa', 'xa','ct','xa','xa', 'ct','xa','xa','xa',
		'xa','xa','xa','xa', 've','ct','ve','ct', 've','xa','ve','ct', 've','ct','ve','xa',
		've','xa','ve','xa', 'he','he','ct','ct', 'he','he','ct','xa', 'he','he','xa','ct',
		'he','he','xa','xa', 'ct','ve','ct','ve', 'ct','ve','xa','ve', 'xa','ve','ct','ve',
		'xa','ve','xa','ve', 'ct','ct','he','he', 'xa','ct','he','he', 'ct','xa','he','he',
		'xa','xa','he','he', 've','ve','ve','ve', 'he','he','he','he', 'ia','he','ve','ct',
		'ia','he','ve','xa', 'he','ia','ct','ve', 'he','ia','xa','ve', 'ct','ve','he','ia',
		'xa','ve','he','ia', 've','ct','ia','he', 've','xa','ia','he', 'ia','ia','ve','ve',
		'ia','he','ia','he', 've','ve','ia','ia', 'he','ia','he','ia', 'ia','ia','ia','ia',
	}

	Tileset_WaterAnimCornersBase = {
		'ct','ct','ct','ct',
		'ia','','','', '','ia','','',
		'ia','ia','','', '','','','ia', 'ia','','','ia', '','ia','','ia',
		'ia','ia','','ia', '','','ia','', 'ia','','ia','', '','ia','ia','',
		'ia','ia','ia','', '','','ia','ia', 'ia','','ia','ia', '','ia','ia','ia',
		'ia','ia','ia','ia',
		've','','ve','', 've','ia','ve','', 've','','ve','ia',
		've','ia','ve','ia', 'he','he','','', 'he','he','','ia', 'he','he','ia','',
		'he','he','ia','ia', '','ve','','ve', '','ve','ia','ve', 'ia','ve','','ve',
		'ia','ve','ia','ve', '','','he','he', 'ia','','he','he', '','ia','he','he',
		'ia','ia','he','he', 've','ve','ve','ve', 'he','he','he','he',
		'xa','he','ve','',
		'xa','he','ve','ia', 'he','xa','','ve', 'he','xa','ia','ve', '','ve','he','xa',
		'ia','ve','he','xa', 've','','xa','he', 've','ia','xa','he', 'xa','xa','ve','ve',
		'xa','he','xa','he', 've','ve','xa','xa', 'he','xa','he','xa', 'xa','xa','xa','xa',
	}

	local Tileset_TileAnimFramesBase = {
		TilesetCs*0 + 0, 125,
		TilesetCs*3 + 0, 125,
		TilesetCs*6 + 0, 125,
		TilesetCs*9 + 0, 125
	}

	local Tileset_WaterAnimFramesBase = {
		0, 125,
		1, 125,
		2, 125,
		1, 125
	}

	Tileset_TerrainCollectionType = "wangsets"
	Tileset_TerrainType = "wangset"

	Init_Common()

	for t = 0, 11 do
		BuildWangTiles(t, 1, 2, GetGroundWangColors,
			Tileset_GroundTileCorners,
			Tileset_GroundTilesC, Tileset_GroundTilesR+(2*t),
			Tileset_GroundTilesCs, 2,
			1, 1)
		BuildTerrainsXML("Ground", Tileset_GroundTilesC, Tileset_GroundTilesR+(2*t), 1,1,1,1)
	end

	for t = 12, 13 do
		BuildWangTiles(t, 1, 2, GetWaterWangColors,
			Tileset_WaterAnimCornersBase,
			Tileset_WaterAnimsC+((t-12)*3), Tileset_WaterAnimsR,
			Tileset_WaterAnimsCs, Tileset_WaterAnimsRs,
			Tileset_WaterAnimsCs/2, 1)
		BuildTerrainsXML("Water", Tileset_WaterAnimsC+((t-12)*3), Tileset_WaterAnimsR, 1,1,1,1)
	end

	BuildTilesXML(
		Tileset_GroundTilesC, Tileset_GroundTilesR,
		Tileset_GroundTilesCs, Tileset_GroundTilesRs,
		1, 1,
		Tileset_GroundTileCorners)
	BuildTilesXML(
		Tileset_WaterAnimsC, Tileset_WaterAnimsR,
		Tileset_WaterAnimsCs, Tileset_WaterAnimsRs,
		3, 1,
		Tileset_WaterAnimCorners,
		Tileset_WaterAnimFramesBase)
	BuildTilesXML(
		Tileset_TileAnimsC, Tileset_TileAnimsR,
		Tileset_TileAnimsCs, Tileset_TileAnimsRs/4,
		1, 1,
		nil,
		Tileset_TileAnimFramesBase)
end

local RM2k_BlockW = TileSize*3
local RM2k_BlockH = TileSize*4
local RM2k_PageW = TileSize*6
local RM2k_PageH = TileSize*8

local RM2k_AnimPageXY = { 0, 0 }

local RM2k_TileAnimBlockXY = {
	3*TileSize,4*TileSize
}

local MTS = MiniTileSize

local RM2k_WaterAnimBlockMTXY = {
	'1ia1-se','1ia1-sw','1ia2-se','1ia2-sw','1ia3-se','1ia3-sw','2ia1-se','2ia1-sw','2ia2-se','2ia2-sw','2ia3-se','2ia3-sw',
	'1ia1-ne','1ia1-nw','1ia2-ne','1ia2-nw','1ia3-ne','1ia3-nw','2ia1-ne','2ia1-nw','2ia2-ne','2ia2-nw','2ia3-ne','2ia3-nw',
	'1ve1-ne','1ve1-nw','1ve2-ne','1ve2-nw','1ve3-ne','1ve3-nw','2ve1-ne','2ve1-nw','2ve2-ne','2ve2-nw','2ve3-ne','2ve3-nw',
	'1ve1-se','1ve1-sw','1ve2-se','1ve2-sw','1ve3-se','1ve3-sw','2ve1-se','2ve1-sw','2ve2-se','2ve2-sw','2ve3-se','2ve3-sw',
	'1he1-sw','1he1-se','1he2-sw','1he2-se','1he3-sw','1he3-se','2he1-sw','2he1-se','2he2-sw','2he2-se','2he3-sw','2he3-se',
	'1he1-nw','1he1-ne','1he2-nw','1he2-ne','1he3-nw','1he3-ne','2he1-nw','2he1-ne','2he2-nw','2he2-ne','2he3-nw','2he3-ne',
	'1xa1-se','1xa1-sw','1xa2-se','1xa2-sw','1xa3-se','1xa3-sw','2xa1-se','2xa1-sw','2xa2-se','2xa2-sw','2xa3-se','2xa3-sw',
	'1xa1-ne','1xa1-nw','1xa2-ne','1xa2-nw','1xa3-ne','1xa3-nw','2xa1-ne','2xa1-nw','2xa2-ne','2xa2-nw','2xa3-ne','2xa3-nw',
	'Wct1-nw','Wct1-ne','Wct2-nw','Wct2-ne','Wct3-nw','Wct3-ne','','','','','','',
	'Wct1-sw','Wct1-se','Wct2-sw','Wct2-se','Wct3-sw','Wct3-se',--'','','','','','',
	--'Wia1-nw','Wia1-ne','Wia2-nw','Wia2-ne','Wia3-nw','Wia3-ne',
	--'Wia1-sw','Wia1-se','Wia2-sw','Wia2-se','Wia3-sw','Wia3-se',
	--'Dia1-nw','Dia1-ne','Dia2-nw','Dia2-ne','Dia3-nw','Dia3-ne',
	--'Dia1-sw','Dia1-se','Dia2-sw','Dia2-se','Dia3-sw','Dia3-se',
	--'Dct1-nw','Dct1-ne','Dct2-nw','Dct2-ne','Dct3-nw','Dct3-ne',
	--'Dct1-sw','Dct1-se','Dct2-sw','Dct2-se','Dct3-sw','Dct3-se'
}
for y = 0,7 do
	for x = 0,11 do
		RM2k_WaterAnimBlockMTXY[RM2k_WaterAnimBlockMTXY[y*12+x+1]] = {x*MTS,MTS*y}
	end
end
for y = 8,9 do
	for x = 0,5 do
		RM2k_WaterAnimBlockMTXY[RM2k_WaterAnimBlockMTXY[y*12+x+1]] = {x*MTS,MTS*y}
	end
end

local RM2k_TileAnimsXY = {}
for y = 4,7 do
	for x = 3,5 do
		RM2k_TileAnimsXY[#RM2k_TileAnimsXY+1] = x*TileSize
		RM2k_TileAnimsXY[#RM2k_TileAnimsXY+1] = y*TileSize
	end
end

local RM2k_GroundBlockXY = {
	0*TileSize,8*TileSize,3*TileSize,8*TileSize,
	0*TileSize,12*TileSize,3*TileSize,12*TileSize,
	6*TileSize,0*TileSize,9*TileSize,0*TileSize,
	6*TileSize,4*TileSize,9*TileSize,4*TileSize,
	6*TileSize,8*TileSize,9*TileSize,8*TileSize,
	6*TileSize,12*TileSize,9*TileSize,12*TileSize
}

local RM2k_GroundBlockMTXY = {
	['sh-nw']={0*MTS,MTS*0},['sh-ne']={1*MTS,MTS*0},['du-nw']={2*MTS,MTS*0},['du-ne']={3*MTS,MTS*0},['xa-nw']={4*MTS,MTS*0},['xa-ne']={5*MTS,MTS*0},
	['sh-sw']={0*MTS,MTS*1},['sh-se']={1*MTS,MTS*1},['du-sw']={2*MTS,MTS*1},['du-se']={3*MTS,MTS*1},['xa-sw']={4*MTS,MTS*1},['xa-se']={5*MTS,MTS*1},
	['ia-nw']={0*MTS,MTS*2},                        ['he-nw']={2*MTS,MTS*2},['he-ne']={3*MTS,MTS*2},                        ['ia-ne']={5*MTS,MTS*2},
	['ve-nw']={0*MTS,MTS*4},                        ['ct-nw']={2*MTS,MTS*4},['ct-ne']={3*MTS,MTS*4},                        ['ve-ne']={5*MTS,MTS*4},
	['ve-sw']={0*MTS,MTS*5},                        ['ct-sw']={2*MTS,MTS*5},['ct-se']={3*MTS,MTS*5},                        ['ve-se']={5*MTS,MTS*5},
	['ia-sw']={0*MTS,MTS*7},                        ['he-sw']={2*MTS,MTS*7},['he-se']={3*MTS,MTS*7},                        ['ia-se']={5*MTS,MTS*7}
}

local RM2k_LoTilePageXY = {
	12*TileSize,0*TileSize,
	12*TileSize,8*TileSize,
	18*TileSize,0*TileSize
}

local RM2k_HiTilePageXY = {
	18*TileSize,8*TileSize,
	24*TileSize,0*TileSize,
	24*TileSize,8*TileSize
}

--[[
local Base64_Alphabet='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

local function Base64_enc(data)
    return ((data:gsub('.', function(x)
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return Base64_Alphabet:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end
]]

local function cutout(imagedata, xys, w, h)
	local cutouts = {}
	for i = 2, #xys, 2 do
		local x, y = xys[i-1], xys[i]
		local cutout = love_image_newImageData(w,h)
		cutout:paste(imagedata, 0, 0, x, y, w, h)
		cutouts[#cutouts+1] = cutout
	end
	return cutouts
end

local function combineCutouts(cutouts, cols, rows)
	local cutoutw, cutouth = cutouts[1]:getWidth(), cutouts[1]:getHeight()
	local combinedimages = love_image_newImageData(cutoutw*cols, cutouth*rows)
	local combinedw = combinedimages:getWidth()
	local x, y = 0, 0
	for i=1, #cutouts do
		local image = cutouts[i]
		combinedimages:paste(image, x, y, 0, 0, imagew, imageh)
		x = x + cutoutw
		if x >= combinedw then
			x = 0
			y = y + cutouth
		end
	end
	return combinedimages
end

local function cutoutDict(imagedata, xydict, w, h)
	local cutouts = {}
	for key, pos in pairs(xydict) do
		local x, y = pos[1], pos[2]
		local cutout = love_image_newImageData(w,h)
		cutout:paste(imagedata, 0, 0, x, y, w, h)
		cutouts[key] = cutout
	end
	return cutouts
end

local function buildTilesFromBlocks(blocks, minitilexys, tilecorners)
	local tiles = {}
	for i = 1, #blocks do
		local block = blocks[i]
		local minitiles = cutoutDict(block, minitilexys, MiniTileSize, MiniTileSize)
		for i = 4, #tilecorners, 4 do
			local nw, ne, sw, se =
			tilecorners[i-3]..'-nw', tilecorners[i-2]..'-ne',
			tilecorners[i-1]..'-sw', tilecorners[i-0]..'-se'
			nw, ne, sw, se = minitiles[nw], minitiles[ne], minitiles[sw], minitiles[se]

			local blocktile = love_image_newImageData(TileSize, TileSize)
			if nw then blocktile:paste(nw, MTS*0, MTS*0, 0, 0, MiniTileSize, MiniTileSize) end
			if ne then blocktile:paste(ne, MTS*1, MTS*0, 0, 0, MiniTileSize, MiniTileSize) end
			if sw then blocktile:paste(sw, MTS*0, MTS*1, 0, 0, MiniTileSize, MiniTileSize) end
			if se then blocktile:paste(se, MTS*1, MTS*1, 0, 0, MiniTileSize, MiniTileSize) end
			tiles[#tiles+1] = blocktile
		end
	end
	return tiles
end

local function buildTileset(chipsetfile)
	if love.filesystem.isDirectory(chipsetfile) then
		local files = love.filesystem.getDirectoryItems(chipsetfile)
		for i = 1, #files do
			buildTileset(path.join(chipsetfile, files[i]))
		end
		return
	end

	local isimage, chipsetdata = pcall(love_image_newImageData, chipsetfile)
	if not isimage then
		print(chipsetdata)
		return
	end

	local wateranims = buildTilesFromBlocks({chipsetdata}, RM2k_WaterAnimBlockMTXY, Tileset_WaterAnimCorners)
	wateranims = combineCutouts(wateranims, Tileset_WaterAnimsCs, Tileset_WaterAnimsRs)

	local tileanims = cutout(chipsetdata, RM2k_TileAnimsXY, TileSize, TileSize)
	tileanims = combineCutouts(tileanims, Tileset_TileAnimsCs, Tileset_TileAnimsRs)

	local in_landblocks = cutout(chipsetdata, RM2k_GroundBlockXY, RM2k_BlockW, RM2k_BlockH)
	local landtiles = buildTilesFromBlocks(in_landblocks, RM2k_GroundBlockMTXY, Tileset_GroundTileCorners)
	landtiles = combineCutouts(landtiles, Tileset_GroundTilesCs, Tileset_GroundTilesRs)

	local in_lotilepages = cutout(chipsetdata, RM2k_LoTilePageXY, RM2k_PageW, RM2k_PageH)
	local in_hitilepages = cutout(chipsetdata, RM2k_HiTilePageXY, RM2k_PageW, RM2k_PageH)
	local lotiles = combineCutouts(in_lotilepages, 1, 3)
	local hitiles = combineCutouts(in_hitilepages, 1, 3)
	local tr, tg, tb, _ = hitiles:getPixel(0, 0)
	hitiles:mapPixel(function(_,_,r,g,b,a)
		if r==tr and g==tg and b==tb then
			return 0,0,0,0
		end
		return r,g,b,a
	end)

	local tileset = love_image_newImageData(TilesetW, TilesetH)
	tileset:paste(lotiles, Tileset_LoTilesX, Tileset_LoTilesY, 0, 0, Tileset_CombinedPagesW, Tileset_CombinedPagesH)
	tileset:paste(hitiles, Tileset_HiTilesX, Tileset_HiTilesY, 0, 0, Tileset_CombinedPagesW, Tileset_CombinedPagesH)
	tileset:paste(landtiles, Tileset_GroundTilesX, Tileset_GroundTilesY, 0, 0, Tileset_GroundTilesW, Tileset_GroundTilesH)
	tileset:paste(wateranims, Tileset_WaterAnimsX, Tileset_WaterAnimsY, 0, 0, Tileset_WaterAnimsW, Tileset_WaterAnimsH)
	tileset:paste(tileanims, Tileset_TileAnimsX, Tileset_TileAnimsY, 0, 0, Tileset_TileAnimsW, Tileset_TileAnimsH)

	local tilesetname = path.basename(chipsetfile):gsub(path.extension(chipsetfile), '')
	local imagefile = tilesetname..".png"
	tileset:encode("png", imagefile)

	local tilesetxml = TilesetXML:subst({tilesetname=tilesetname, imagefile=imagefile})

	tilesetxml = xml.tostring(tilesetxml, '', ' ', nil, '<?xml version="1.0" encoding="UTF-8"?>')
	local xmlfile = tilesetname..".tsx"
	love.filesystem.write(xmlfile, tilesetxml)
end

function love.run()
	local args = lapp [[
Convert RM2k chipset to Tiled tileset
	-g,--granularity (default 2) Tileset granularity
	<files...> (string) Image files or directories of image files
	]]

	TerrainGranularity = args.granularity
	if TerrainGranularity == 1 then
		Init_Granularity1()
	else
		Init_Granularity2()
	end

	assert(#args.files >= 2, "Usage: love <rm2k-tiled-path> <chipsetfile> [chipsetfile, chipsetfile, ...]")
	for i=2, #args.files do
		buildTileset(args.files[i])
	end

	love.system.openURL(love.filesystem.getSaveDirectory())
end
