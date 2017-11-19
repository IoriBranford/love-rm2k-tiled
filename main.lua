local TileSize = 16
local MiniTileSize = TileSize/2

local RPGM2k_BlockW = TileSize*3
local RPGM2k_BlockH = TileSize*4
local RPGM2k_PageW = TileSize*6
local RPGM2k_PageH = TileSize*8

local Tileset_LoTilesX = TileSize*0
local Tileset_LoTilesY = TileSize*0
local Tileset_HiTilesX = TileSize*0
local Tileset_HiTilesY = TileSize*24
local Tileset_CombinedPagesW = TileSize*6
local Tileset_CombinedPagesH = TileSize*24

local Tileset_LandTilesX = TileSize*6
local Tileset_LandTilesY = TileSize*0
local Tileset_LandTilesW = TileSize*12
local Tileset_LandTilesH = TileSize*48

local Tileset_WaterTilesX = TileSize*18
local Tileset_WaterTilesY = TileSize*0
local Tileset_WaterTilesW = TileSize*3
local Tileset_WaterTilesH = TileSize*48

local Tileset_AnimTilesX = TileSize*0
local Tileset_AnimTilesY = TileSize*48
local Tileset_AnimTilesW = TileSize*12
local Tileset_AnimTilesH = TileSize*1

local TilesetW = Tileset_CombinedPagesW + Tileset_LandTilesW + Tileset_WaterTilesW
local TilesetH = Tileset_LandTilesH + TileSize

local RPGM2k_WaterBlockMT = {
	'ia-nw1','ia-ne1','ia-nw2','ia-ne2','ia-nw3','ia-ne3',
	'ia-sw1','ia-se1','ia-sw2','ia-se2','ia-sw3','ia-se3',
	've-nw1','ve-ne1','ve-nw2','ve-ne2','ve-nw3','ve-ne3',
	've-sw1','ve-se1','ve-sw2','ve-se2','ve-sw3','ve-se3',
	'he-nw1','he-ne1','he-nw2','he-ne2','he-nw3','he-ne3',
	'he-sw1','he-se1','he-sw2','he-se2','he-sw3','he-se3',
	'xa-nw1','xa-ne1','xa-nw2','xa-ne2','xa-nw3','xa-ne3',
	'xa-sw1','xa-se1','xa-sw2','xa-se2','xa-sw3','xa-se3'
}

local MTS = MiniTileSize
local RPGM2k_LandBlockMTXY = {
	['sh-nw']={0*MTS,MTS*0},['sh-ne']={1*MTS,MTS*0},['du-nw']={2*MTS,MTS*0},['du-ne']={3*MTS,MTS*0},['xa-nw']={4*MTS,MTS*0},['xa-ne']={5*MTS,MTS*0},
	['sh-sw']={0*MTS,MTS*1},['sh-se']={1*MTS,MTS*1},['du-sw']={2*MTS,MTS*1},['du-se']={3*MTS,MTS*1},['xa-sw']={4*MTS,MTS*1},['xa-se']={5*MTS,MTS*1},
	['ia-nw']={0*MTS,MTS*2},                        ['he-nw']={2*MTS,MTS*2},['he-ne']={3*MTS,MTS*2},                        ['ia-ne']={5*MTS,MTS*2},
	['ve-nw']={0*MTS,MTS*4},                        ['ct-nw']={2*MTS,MTS*4},['ct-ne']={3*MTS,MTS*4},                        ['ve-ne']={5*MTS,MTS*4},
	['ve-sw']={0*MTS,MTS*5},                        ['ct-sw']={2*MTS,MTS*5},['ct-se']={3*MTS,MTS*5},                        ['ve-se']={5*MTS,MTS*5},
	['ia-sw']={0*MTS,MTS*7},                        ['he-sw']={2*MTS,MTS*7},['he-se']={3*MTS,MTS*7},                        ['ia-se']={5*MTS,MTS*7}
}

local Tileset_LandTileCorners = {
	'du', 'du', 'du', 'du',
	'ct', 'ct', 'ct', 'ct',
	'xa', 'ct', 'ct', 'ct',
	'ct', 'xa', 'ct', 'ct',
	'xa', 'xa', 'ct', 'ct',
	'ct', 'ct', 'ct', 'xa',
	'xa', 'ct', 'ct', 'xa',
	'ct', 'xa', 'ct', 'xa',
	'xa', 'xa', 'ct', 'xa',
	'ct', 'ct', 'xa', 'ct',
	'xa', 'ct', 'xa', 'ct',
	'ct', 'xa', 'xa', 'ct',
	'xa', 'xa', 'xa', 'ct',
	'ct', 'ct', 'xa', 'xa',
	'xa', 'ct', 'xa', 'xa',
	'ct', 'xa', 'xa', 'xa',
	'xa', 'xa', 'xa', 'xa',
	've', 'ct', 've', 'ct',
	've', 'xa', 've', 'ct',
	've', 'ct', 've', 'xa',
	've', 'xa', 've', 'xa',
	'he', 'he', 'ct', 'ct',
	'he', 'he', 'ct', 'xa',
	'he', 'he', 'xa', 'ct',
	'he', 'he', 'xa', 'xa',
	'ct', 've', 'ct', 've',
	'ct', 've', 'xa', 've',
	'xa', 've', 'ct', 've',
	'xa', 've', 'xa', 've',
	'ct', 'ct', 'he', 'he',
	'xa', 'ct', 'he', 'he',
	'ct', 'xa', 'he', 'he',
	'xa', 'xa', 'he', 'he',
	've', 've', 've', 've',
	'he', 'he', 'he', 'he',
	'ia', 'he', 've', 'ct',
	'ia', 'he', 've', 'xa',
	'he', 'ia', 'ct', 've',
	'he', 'ia', 'xa', 've',
	'ct', 've', 'he', 'ia',
	'xa', 've', 'he', 'ia',
	've', 'ct', 'ia', 'he',
	've', 'xa', 'ia', 'he',
	'sh', 'sh', 've', 've',
	'sh', 'he', 'sh', 'he',
	've', 've', 'sh', 'sh',
	'he', 'sh', 'he', 'sh',
	'sh', 'sh', 'sh', 'sh'
}

local RPGM2k_WaterBlockXY = {
	0*TileSize,0*TileSize,3*TileSize,0*TileSize,
	0*TileSize,4*TileSize
}

local RPGM2k_AnimBlockXY = {
	3*TileSize,4*TileSize
}

local RPGM2k_AnimTilesXY = {
	0*TileSize,0*TileSize,
	0*TileSize,1*TileSize,
	0*TileSize,2*TileSize,
	0*TileSize,3*TileSize,
	1*TileSize,0*TileSize,
	1*TileSize,1*TileSize,
	1*TileSize,2*TileSize,
	1*TileSize,3*TileSize,
	2*TileSize,0*TileSize,
	2*TileSize,1*TileSize,
	2*TileSize,2*TileSize,
	2*TileSize,3*TileSize
}

local RPGM2k_LandBlockXY = {
	0*TileSize,8*TileSize,3*TileSize,8*TileSize,
	0*TileSize,12*TileSize,3*TileSize,12*TileSize,
	6*TileSize,0*TileSize,9*TileSize,0*TileSize,
	6*TileSize,4*TileSize,9*TileSize,4*TileSize,
	6*TileSize,8*TileSize,9*TileSize,8*TileSize,
	6*TileSize,12*TileSize,9*TileSize,12*TileSize
}

local RPGM2k_LoTilePageXY = {
	12*TileSize,0*TileSize,
	12*TileSize,8*TileSize,
	18*TileSize,0*TileSize
}

local RPGM2k_HiTilePageXY = {
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
	for i = 1, #xys/2 do
		local x, y = xys[2*i-1], xys[2*i]
		local cutout = love.image.newImageData(w,h)
		cutout:paste(imagedata, 0, 0, x, y, w, h)
		cutouts[#cutouts+1] = cutout
	end
	return cutouts
end

local function combineCutouts(cutouts, cols, rows)
	local cutoutw, cutouth = cutouts[1]:getWidth(), cutouts[1]:getHeight()
	local combinedimages = love.image.newImageData(cutoutw*cols, cutouth*rows)
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
		local cutout = love.image.newImageData(w,h)
		cutout:paste(imagedata, 0, 0, x, y, w, h)
		cutouts[key] = cutout
	end
	return cutouts
end

local function buildTilesFromBlock(block, minitilexys, tilecorners)
	local minitiles = cutoutDict(block, minitilexys, MiniTileSize, MiniTileSize)
	local blocktiles = {}
	for i = 1, #tilecorners/4 do
		local nw, ne, sw, se =
			tilecorners[4*i-3]..'-nw', tilecorners[4*i-2]..'-ne',
			tilecorners[4*i-1]..'-sw', tilecorners[4*i-0]..'-se'
		--print(nw, ne, sw, se)
		nw, ne, sw, se = minitiles[nw], minitiles[ne], minitiles[sw], minitiles[se]

		local blocktile = love.image.newImageData(TileSize, TileSize)
		blocktile:paste(nw, MTS*0, MTS*0, 0, 0, MiniTileSize, MiniTileSize)
		blocktile:paste(ne, MTS*1, MTS*0, 0, 0, MiniTileSize, MiniTileSize)
		blocktile:paste(sw, MTS*0, MTS*1, 0, 0, MiniTileSize, MiniTileSize)
		blocktile:paste(se, MTS*1, MTS*1, 0, 0, MiniTileSize, MiniTileSize)
		blocktiles[#blocktiles+1] = blocktile
	end
	return blocktiles
end

local function dbg_save(imagedatas, prefix)
	for i=1,#imagedatas do
		local imagefile = prefix..i..".png"
		imagedatas[i]:encode("png", imagefile)
	end
end

--- Function equivalent to basename in POSIX systems
--- Copyright 2011-2014, Gianluca Fiore © <forod.g@gmail.com>
--@param str the path string
local function basename(str)
	local name = string.gsub(str, "(.*/)(.*)", "%2")
	return name
end

function love.run()
	local chipsetfile = arg[2]
	assert(chipsetfile, "Usage: rpgm2k-tiled <chipsetfile>")
	local chipsetdata = love.image.newImageData(chipsetfile)
	assert(chipsetdata, "Couldn't load chipsetdata "..chipsetfile)

	local in_waterblocks = cutout(chipsetdata, RPGM2k_WaterBlockXY, RPGM2k_BlockW, RPGM2k_BlockH)
	local in_landblocks = cutout(chipsetdata, RPGM2k_LandBlockXY, RPGM2k_BlockW, RPGM2k_BlockH)
	local in_lotilepages = cutout(chipsetdata, RPGM2k_LoTilePageXY, RPGM2k_PageW, RPGM2k_PageH)
	local in_hitilepages = cutout(chipsetdata, RPGM2k_HiTilePageXY, RPGM2k_PageW, RPGM2k_PageH)
	local in_animblock = cutout(chipsetdata, RPGM2k_AnimBlockXY, RPGM2k_BlockW, RPGM2k_BlockH)[1]

	local landtiles = {}
	for i=1, #in_landblocks do
		local tiles = buildTilesFromBlock(in_landblocks[i], RPGM2k_LandBlockMTXY, Tileset_LandTileCorners)
		landtiles[#landtiles+1] = combineCutouts(tiles, 1, 48)
	end
	landtiles = combineCutouts(landtiles, 12, 1)

	local animtiles = cutout(in_animblock, RPGM2k_AnimTilesXY, TileSize, TileSize)
	animtiles = combineCutouts(animtiles, 12, 1)

	local lotiles = combineCutouts(in_lotilepages, 1, 3)
	local hitiles = combineCutouts(in_hitilepages, 1, 3)
	local tr, tg, tb, _ = hitiles:getPixel(0, 0)
	hitiles:mapPixel(function(_,_,r,g,b,a)
		if r==tr and g==tg and b==tb then
			return 0,0,0,0
		end
		return r,g,b,a
	end)

	local tileset = love.image.newImageData(TilesetW, TilesetH)
	tileset:paste(lotiles, Tileset_LoTilesX, Tileset_LoTilesY, 0, 0, Tileset_CombinedPagesW, Tileset_CombinedPagesH)
	tileset:paste(hitiles, Tileset_HiTilesX, Tileset_HiTilesY, 0, 0, Tileset_CombinedPagesW, Tileset_CombinedPagesH)
	tileset:paste(landtiles, Tileset_LandTilesX, Tileset_LandTilesY, 0, 0, Tileset_LandTilesW, Tileset_LandTilesH)
	tileset:paste(animtiles, Tileset_AnimTilesX, Tileset_AnimTilesY, 0, 0, Tileset_AnimTilesW, Tileset_AnimTilesH)

	local chipsetname = basename(chipsetfile)
	tileset:encode("png", chipsetname..".png")
end
