require("vaspritebatch")
-- example usage of augmented spritebatch


function love.load()
	texture = love.graphics.newImage("tex.png")
	spritebatch = VASpriteBatch:new(texture,10,"dynamic")
	spritebatch:init()
	
	-- create some quads
	quads = {	love.graphics.newQuad(0,0,64,64,texture:getWidth(),texture:getHeight()),
				love.graphics.newQuad(64,0,64,64,texture:getWidth(),texture:getHeight()),
				love.graphics.newQuad(0,64,64,64,texture:getWidth(),texture:getHeight()),
				love.graphics.newQuad(64,64,64,64,texture:getWidth(),texture:getHeight())
			}
	
	-- {quad number, x, y, r, sx, sy, ox, oy}
	sprite_variables = {
		{1, 64,64, 0, 2,2, 32,32},
		{2, 128,128, 1.57/2, 2,2, 32,32},
		{3, 256,256, 0, 3,3, 32,32},
		{4, 284,284, 0, 1,1, 32,32},
	}
	
	-- create some sprites from table above
	sprites = {}
	for i,v in ipairs(sprite_variables) do
		sprites[i] = spritebatch:add(quads[v[1]], v[2], v[3], v[4], v[5], v[6], v[7], v[8])
	end
	
	-- changing sprite color after they have been added to spritebatch, easy
	spritebatch:setSpriteColor(1,255,0,0,255)
	spritebatch:setSpriteColor(2,255,0,255,255)
	spritebatch:setSpriteColor(3,255,255,255,128)
	spritebatch:setSpriteColor(4,255,255,0,255)
end

function love.draw()
	love.graphics.draw(spritebatch:getSpriteBatch())
	for i,v in ipairs(sprite_variables) do
		love.graphics.circle("fill",v[2],v[3],1,4)
	end
end

phase = 0
local sin = math.sin
function love.update(dt)
	phase = phase + dt
	if phase >= 1 then
		phase = 0
		spritebatch:swapSpriteGeometry(1,2)
		spritebatch:swapSpriteGeometry(3,4)
	end
end