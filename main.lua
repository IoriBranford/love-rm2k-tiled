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
	'oc-nw1','oc-ne1','oc-nw2','oc-ne2','oc-nw3','oc-ne3',
	'oc-sw1','oc-se1','oc-sw2','oc-se2','oc-sw3','oc-se3',
	've-nw1','ve-ne1','ve-nw2','ve-ne2','ve-nw3','ve-ne3',
	've-sw1','ve-se1','ve-sw2','ve-se2','ve-sw3','ve-se3',
	'he-nw1','he-ne1','he-nw2','he-ne2','he-nw3','he-ne3',
	'he-sw1','he-se1','he-sw2','he-se2','he-sw3','he-se3',
	'ic-nw1','ic-ne1','ic-nw2','ic-ne2','ic-nw3','ic-ne3',
	'ic-sw1','ic-se1','ic-sw2','ic-se2','ic-sw3','ic-se3'
}

local RPGM2k_LandBlockMT = {
	'sh-nw','sh-ne','du-nw','du-ne','ic-nw','ic-ne',
	'sh-sw','sh-se','du-sw','du-se','ic-sw','ic-se',
	'oc-nw',''     ,'he-nw','he-ne',''     ,'oc-se',
	''     ,''     ,''     ,''     ,''     ,''     ,
	've-nw',''     ,'ct-nw','ct-ne',''     ,'ve-ne',
	've-sw',''     ,'ct-sw','ct-se',''     ,'ve-se',
	''     ,''     ,''     ,''     ,''     ,''     ,
	'oc-sw',''     ,'he-sw','he-se',''     ,'oc-se',
}

local RPGM2k_WaterBlockXY = {
	0*TileSize,0*TileSize,3*TileSize,0*TileSize,
	0*TileSize,4*TileSize
}

local RPGM2k_AnimBlockXY = {
	3*TileSize,4*TileSize
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

local function combinePages(pages)
	local combinedpages = love.image.newImageData(Tileset_CombinedPagesW, Tileset_CombinedPagesH)
	local x, y = 0, 0
	for i=1, #pages do
		local page = pages[i]
		combinedpages:paste(page, x, y, 0, 0, page:getWidth(), page:getHeight())
		y = y + RPGM2k_PageH
	end
	return combinedpages
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
	local in_animblocks = cutout(chipsetdata, RPGM2k_AnimBlockXY, RPGM2k_BlockW, RPGM2k_BlockH)
	local in_landblocks = cutout(chipsetdata, RPGM2k_LandBlockXY, RPGM2k_BlockW, RPGM2k_BlockH)

	local lotiles = combinePages(cutout(chipsetdata, RPGM2k_LoTilePageXY, RPGM2k_PageW, RPGM2k_PageH))
	local hitiles = combinePages(cutout(chipsetdata, RPGM2k_HiTilePageXY, RPGM2k_PageW, RPGM2k_PageH))

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

	local chipsetname = basename(chipsetfile)
	tileset:encode("png", chipsetname..".png")
end
