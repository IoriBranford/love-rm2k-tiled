local pl = require "pl.import_into"()
local xml = pl.xml
local tablex = pl.tablex

local pcall = pcall
local love_image_newImageData = love.image.newImageData

local TileSize = 16
local MiniTileSize = TileSize/2

local Tileset_WaterAnimsC = 12	--TG2: 18
local Tileset_WaterAnimsR = 1	--TG2: 2
local Tileset_WaterAnimsCs = 12	-- TG2:6
local Tileset_WaterAnimsRs = 8	-- TG2:46
local Tileset_WaterAnimsX = TileSize*Tileset_WaterAnimsC
local Tileset_WaterAnimsY = TileSize*Tileset_WaterAnimsR
local Tileset_WaterAnimsW = TileSize*Tileset_WaterAnimsCs
local Tileset_WaterAnimsH = TileSize*Tileset_WaterAnimsRs

local Tileset_TileAnimsC = 12 	-- TG2: 18
local Tileset_TileAnimsR = 0
local Tileset_TileAnimsCs = 12	-- TG2: 6
local Tileset_TileAnimsRs = 1	-- TG2: 2
local Tileset_TileAnimsX = TileSize*Tileset_TileAnimsC
local Tileset_TileAnimsY = TileSize*Tileset_TileAnimsR
local Tileset_TileAnimsW = TileSize*Tileset_TileAnimsCs
local Tileset_TileAnimsH = TileSize*Tileset_TileAnimsRs

local Tileset_LandTilesC = 12	-- TG2: 6
local Tileset_LandTilesR = 9	-- TG2: 0
local Tileset_LandTilesCs = 12
local Tileset_LandTilesRs = 15	-- TG2: 48
local Tileset_LandTilesX = TileSize*Tileset_LandTilesC
local Tileset_LandTilesY = TileSize*Tileset_LandTilesR
local Tileset_LandTilesW = TileSize*Tileset_LandTilesCs
local Tileset_LandTilesH = TileSize*Tileset_LandTilesRs

local Tileset_LoTilesX = TileSize*0
local Tileset_LoTilesY = TileSize*0
local Tileset_HiTilesC = 6	-- TG2: 0
local Tileset_HiTilesR = 0	-- TG2: 24
local Tileset_HiTilesX = TileSize*Tileset_HiTilesC
local Tileset_HiTilesY = TileSize*Tileset_HiTilesR
local Tileset_CombinedPagesCs = 6
local Tileset_CombinedPagesRs = 24
local Tileset_CombinedPagesW = TileSize*Tileset_CombinedPagesCs
local Tileset_CombinedPagesH = TileSize*Tileset_CombinedPagesRs

local TilesetCs = 2*Tileset_CombinedPagesCs + Tileset_LandTilesCs -- TG2: Tileset_CombinedPagesCs + Tileset_LandTilesCs + Tileset_TileAnimsCs
local TilesetRs = Tileset_CombinedPagesRs --TG2: Tileset_LandTilesRs
local TilesetN = TilesetCs*TilesetRs
local TilesetW = TileSize*TilesetCs
local TilesetH = TileSize*TilesetRs

local Tileset_WaterAnimsT = Tileset_WaterAnimsR*TilesetCs+Tileset_WaterAnimsC

--Terrain granularity 2
local Tileset_LandTileCorners = {
	'ia','he','ve','ct', 'he','he','ct','ct', 'he','ia','ct','ve',
	've','ct','ve','ct', 'ct','ct','ct','ct', 'ct','ve','ct','ve',
	've','ct','ia','he', 'ct','ct','he','he', 'ct','ve','he','ia',
	'xa','ct','ct','ct', 'ct','xa','ct','ct', 'ct','ct','xa','ct',
	'ct','ct','ct','xa', 'xa','ct','ct','xa', 'ct','xa','xa','ct'
}

local Tileset_WaterAnimCorners = {}
for e = 1,2 do
	local landcorners = Tileset_LandTileCorners
	local watercorners = Tileset_WaterAnimCorners
	for i = 4, #Tileset_LandTileCorners, 4 do
		for f = 1,3 do
			for j = -3,0 do
				local corner = landcorners[i+j]
				if corner ~= 'ct' then
					corner = e..corner
				end

				watercorners[#watercorners+1] = corner..f
			end
		end
	end
end

local Tileset_TileAnimFramesBase = {
	0, 125,
	3, 125,
	6, 125,
	9, 125
}

local Tileset_WaterAnimFramesBase = {
	0, 125,
	1, 125,
	2, 125,
	1, 125
}

--Terrain granularity 1
--[[
local Tileset_LandTileCorners = {
	'du','du','du','du', 'ct','ct','ct','ct', 'xa','ct','ct','ct', 'ct','xa','ct','ct',
	'xa','xa','ct','ct', 'ct','ct','ct','xa', 'xa','ct','ct','xa', 'ct','xa','ct','xa',
	'xa','xa','ct','xa', 'ct','ct','xa','ct', 'xa','ct','xa','ct', 'ct','xa','xa','ct',
	'xa','xa','xa','ct', 'ct','ct','xa','xa', 'xa','ct','xa','xa', 'ct','xa','xa','xa',
	'xa','xa','xa','xa', 've','ct','ve','ct', 've','xa','ve','ct', 've','ct','ve','xa',
	've','xa','ve','xa', 'he','he','ct','ct', 'he','he','ct','xa', 'he','he','xa','ct',
	'he','he','xa','xa', 'ct','ve','ct','ve', 'ct','ve','xa','ve', 'xa','ve','ct','ve',
	'xa','ve','xa','ve', 'ct','ct','he','he', 'xa','ct','he','he', 'ct','xa','he','he',
	'xa','xa','he','he', 've','ve','ve','ve', 'he','he','he','he', 'ia','he','ve','ct',
	'ia','he','ve','xa', 'he','ia','ct','ve', 'he','ia','xa','ve', 'ct','ve','he','ia',
	'xa','ve','he','ia', 've','ct','ia','he', 've','xa','ia','he', 'sh','sh','ve','ve',
	'sh','he','sh','he', 've','ve','sh','sh', 'he','sh','he','sh', 'sh','sh','sh','sh'
}

local Tileset_WaterAnimCorners = {
	'ct1','ct1','ct1','ct1', 'ct2','ct2','ct2','ct2', 'ct3','ct3','ct3','ct3',
	'ct1','ct1','ct1','ct1', 'ct2','ct2','ct2','ct2', 'ct3','ct3','ct3','ct3',
	'1ia1','1ia1','1ia1','1ia1', '1ia2','1ia2','1ia2','1ia2', '1ia3','1ia3','1ia3','1ia3',
	'2ia1','2ia1','2ia1','2ia1', '2ia2','2ia2','2ia2','2ia2', '2ia3','2ia3','2ia3','2ia3',
}
for e = 1,2 do
	local landcorners = Tileset_LandTileCorners
	local watercorners = Tileset_WaterAnimCorners
	for i = 12, #Tileset_LandTileCorners-4, 4 do
		for f = 1,3 do
			for j = -3,0 do
				local corner = landcorners[i+j]
				if corner == 'sh' then
					corner = 'ia'
				end
				if corner ~= 'ct' then
					corner = e..corner
				end

				watercorners[#watercorners+1] = corner..f
			end
		end
	end
end

local Tileset_TileAnimFramesBase = {
	TilesetCs*0 + 0, 125,
	TilesetCs*0 + 3, 125,
	TilesetCs*1 + 0, 125,
	TilesetCs*1 + 3, 125
}

local Tileset_WaterAnimFramesBase = {
	0, 125,
	2, 125,
	4, 125,
	2, 125
}
]]

local XML_Tile, XML_Animation, XML_Frame = xml.tags('tile, animation, frame')
local XML_Terrain = xml.tags('terrain')

local TilesetXML = xml.elem("tileset", {
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

local function BuildTilesXML(framesbase, stride, c1, r1, cs, rs)
	local frames = {}
	for id1 = r1*TilesetCs + c1, (r1+rs-1)*TilesetCs + c1, TilesetCs do
		for id = id1, id1 + cs - stride, stride do
			for f = 2, #framesbase, 2 do
				local tileid = id + framesbase[f-1]
				local duration = framesbase[f]
				frames[#frames+1] = XML_Frame({tileid=tileid, duration=duration})
			end
			TilesetXML:add_child(XML_Tile({id=id, XML_Animation(frames)}))
			tablex.clear(frames)
		end
		id1 = id1 + TilesetCs
	end
end

BuildTilesXML(Tileset_TileAnimFramesBase, 1,
	Tileset_TileAnimsC, Tileset_TileAnimsR,
	Tileset_TileAnimsCs*2/#Tileset_TileAnimFramesBase, Tileset_TileAnimsRs)
BuildTilesXML(Tileset_WaterAnimFramesBase, 3,
	Tileset_WaterAnimsC, Tileset_WaterAnimsR,
	Tileset_WaterAnimsCs, Tileset_WaterAnimsRs)

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
	'1ia1-nw','1ia1-ne','1ia2-nw','1ia2-ne','1ia3-nw','1ia3-ne','2ia1-nw','2ia1-ne','2ia2-nw','2ia2-ne','2ia3-nw','2ia3-ne',
	'1ia1-sw','1ia1-se','1ia2-sw','1ia2-se','1ia3-sw','1ia3-se','2ia1-sw','2ia1-se','2ia2-sw','2ia2-se','2ia3-sw','2ia3-se',
	'1ve1-nw','1ve1-ne','1ve2-nw','1ve2-ne','1ve3-nw','1ve3-ne','2ve1-nw','2ve1-ne','2ve2-nw','2ve2-ne','2ve3-nw','2ve3-ne',
	'1ve1-sw','1ve1-se','1ve2-sw','1ve2-se','1ve3-sw','1ve3-se','2ve1-sw','2ve1-se','2ve2-sw','2ve2-se','2ve3-sw','2ve3-se',
	'1he1-nw','1he1-ne','1he2-nw','1he2-ne','1he3-nw','1he3-ne','2he1-nw','2he1-ne','2he2-nw','2he2-ne','2he3-nw','2he3-ne',
	'1he1-sw','1he1-se','1he2-sw','1he2-se','1he3-sw','1he3-se','2he1-sw','2he1-se','2he2-sw','2he2-se','2he3-sw','2he3-se',
	'1xa1-nw','1xa1-ne','1xa2-nw','1xa2-ne','1xa3-nw','1xa3-ne','2xa1-nw','2xa1-ne','2xa2-nw','2xa2-ne','2xa3-nw','2xa3-ne',
	'1xa1-sw','1xa1-se','1xa2-sw','1xa2-se','1xa3-sw','1xa3-se','2xa1-sw','2xa1-se','2xa2-sw','2xa2-se','2xa3-sw','2xa3-se',
	'ct1-nw','ct1-ne','ct2-nw','ct2-ne','ct3-nw','ct3-ne','','','','','','',
	'ct1-sw','ct1-se','ct2-sw','ct2-se','ct3-sw','ct3-se'
	--'xa1-nw','xa1-ne','xa2-nw','xa2-ne','xa3-nw','xa3-ne',
	--'xa1-sw','xa1-se','xa2-sw','xa2-se','xa3-sw','xa3-se',
	--'ia1-nw','ia1-ne','ia2-nw','ia2-ne','ia3-nw','ia3-ne',
	--'ia1-sw','ia1-se','ia2-sw','ia2-se','ia3-sw','ia3-se',
	--'dp1-nw','dp1-ne','dp2-nw','dp2-ne','dp3-nw','dp3-ne',
	--'dp1-sw','dp1-se','dp2-sw','dp2-se','dp3-sw','dp3-se'
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

local RM2k_LandBlockXY = {
	0*TileSize,8*TileSize,3*TileSize,8*TileSize,
	0*TileSize,12*TileSize,3*TileSize,12*TileSize,
	6*TileSize,0*TileSize,9*TileSize,0*TileSize,
	6*TileSize,4*TileSize,9*TileSize,4*TileSize,
	6*TileSize,8*TileSize,9*TileSize,8*TileSize,
	6*TileSize,12*TileSize,9*TileSize,12*TileSize
}

local RM2k_LandBlockMTXY = {
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

local function buildTilesFromBlock(block, minitilexys, tilecorners)
	local minitiles = cutoutDict(block, minitilexys, MiniTileSize, MiniTileSize)
	local blocktiles = {}
	for i = 4, #tilecorners, 4 do
		local nw, ne, sw, se =
			tilecorners[i-3]..'-nw', tilecorners[i-2]..'-ne',
			tilecorners[i-1]..'-sw', tilecorners[i-0]..'-se'
		assert(minitiles[nw], nw)
		assert(minitiles[ne], ne)
		assert(minitiles[sw], sw)
		assert(minitiles[se], se)
		nw, ne, sw, se = minitiles[nw], minitiles[ne], minitiles[sw], minitiles[se]

		local blocktile = love_image_newImageData(TileSize, TileSize)
		blocktile:paste(nw, MTS*0, MTS*0, 0, 0, MiniTileSize, MiniTileSize)
		blocktile:paste(ne, MTS*1, MTS*0, 0, 0, MiniTileSize, MiniTileSize)
		blocktile:paste(sw, MTS*0, MTS*1, 0, 0, MiniTileSize, MiniTileSize)
		blocktile:paste(se, MTS*1, MTS*1, 0, 0, MiniTileSize, MiniTileSize)
		blocktiles[#blocktiles+1] = blocktile
	end
	return blocktiles
end

--- Function equivalent to basename in POSIX systems
--- Copyright 2011-2014, Gianluca Fiore © <forod.g@gmail.com>
--@param str the path string
local function basename(str)
	local name = string.gsub(str, "(.*/)(.*)", "%2")
	return name
end

local function buildTileset(chipsetfile)
	if love.filesystem.isDirectory(chipsetfile) then
		local files = love.filesystem.getDirectoryItems(chipsetfile)
		for i = 1, #files do
			buildTileset(chipsetfile..'/'..files[i])
		end
		return
	end

	local isimage, chipsetdata = pcall(love_image_newImageData, chipsetfile)
	if not isimage then
		print(chipsetdata)
		return
	end

	local wateranims = buildTilesFromBlock(chipsetdata, RM2k_WaterAnimBlockMTXY, Tileset_WaterAnimCorners)
	wateranims = combineCutouts(wateranims, Tileset_WaterAnimsCs, Tileset_WaterAnimsRs)

	local tileanims = cutout(chipsetdata, RM2k_TileAnimsXY, TileSize, TileSize)
	tileanims = combineCutouts(tileanims, Tileset_TileAnimsCs, Tileset_TileAnimsRs)

	local in_landblocks = cutout(chipsetdata, RM2k_LandBlockXY, RM2k_BlockW, RM2k_BlockH)
	local landtiles = {}
	for i=1, #in_landblocks do
		local tiles = buildTilesFromBlock(in_landblocks[i], RM2k_LandBlockMTXY, Tileset_LandTileCorners)
		landtiles[#landtiles+1] = combineCutouts(tiles, 1, Tileset_LandTilesRs)
	end
	landtiles = combineCutouts(landtiles, Tileset_LandTilesCs, 1)

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
	tileset:paste(landtiles, Tileset_LandTilesX, Tileset_LandTilesY, 0, 0, Tileset_LandTilesW, Tileset_LandTilesH)
	tileset:paste(wateranims, Tileset_WaterAnimsX, Tileset_WaterAnimsY, 0, 0, Tileset_WaterAnimsW, Tileset_WaterAnimsH)
	tileset:paste(tileanims, Tileset_TileAnimsX, Tileset_TileAnimsY, 0, 0, Tileset_TileAnimsW, Tileset_TileAnimsH)

	local tilesetname = basename(chipsetfile)
	local imagefile = tilesetname..".png"
	tileset:encode("png", imagefile)

	local tilesetxml = TilesetXML:subst({tilesetname=tilesetname, imagefile=imagefile})

	tilesetxml = xml.tostring(tilesetxml, '', ' ', nil, '<?xml version="1.0" encoding="UTF-8"?>')
	local xmlfile = tilesetname..".tsx"
	love.filesystem.write(xmlfile, tilesetxml)
end

function love.run()
	assert(#arg >= 2, "Usage: love <rm2k-tiled-path> <chipsetfile> [chipsetfile, chipsetfile, ...]")
	for i=2, #arg do
		buildTileset(arg[i])
	end

	love.system.openURL(love.filesystem.getSaveDirectory())
end
