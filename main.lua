require("vaspritebatch")
-- example usage of augmented spritebatch
local sin,cos,pi = math.sin,math.cos,math.pi

function love.load()
	sprite_count = 14
	texture = love.graphics.newImage("tex.png")
	spritebatch = VASpriteBatch:new(texture,sprite_count,"dynamic")

	
	-- create some quads
	quads = {	love.graphics.newQuad(0,0,64,64,texture:getWidth(),texture:getHeight()),
				love.graphics.newQuad(64,0,64,64,texture:getWidth(),texture:getHeight()),
				love.graphics.newQuad(0,64,64,64,texture:getWidth(),texture:getHeight()),
				love.graphics.newQuad(64,64,64,64,texture:getWidth(),texture:getHeight())
			}
	

	
	-- lets create a circle of sprites floating around and changing colors
	-- two sprites in the center are going to change themselves in draw order
	centerx,centery = love.graphics:getWidth()/2,love.graphics.getHeight()/2
	radius = 256
	starting_angle = 0	
	sprites = {}
	quad_index = 1
	for i=1,sprite_count-2 do
		local angle = (pi*2)*(i/(sprite_count-2))
		local sx,sy = centerx+sin(angle)*radius,centery+cos(angle)*radius
		sprites[i] = spritebatch:add(quads[quad_index],sx,sy,angle,1,1,32,32)
		quad_index = quad_index + 1
		if quad_index > #quads then quad_index = 1 end
	end
	
	sprites[#sprites+1] = spritebatch:add(quads[1],centerx-48,centery,0,3,3,32,32)
	sprites[#sprites+1] = spritebatch:add(quads[4],centerx+48,centery,1.57/2,2,2,32,32)
	
end

function love.draw()
	-- draw the thing almost as vanilla spritebatch
	love.graphics.print("Changing drawing order:",centerx-64,centery-128)
	love.graphics.print("Changing existing sprite colors:")
	love.graphics.draw(spritebatch:getSpriteBatch())
end

phase = 0
local sin = math.sin
-- sprites are going to change colors 
-- and warp around to show main features of a helper class
function love.update(dt)
	phase = phase + dt
	if phase >= 1 then
		phase = 0
		for i=1,sprite_count-2 do
			local r,g,b = math.random()*255,math.random()*255,math.random()*255
			spritebatch:setSpriteColor(sprites[i],r,g,b,255)
			
			for j=1,4 do
				local vind = (i-1)*4+j
				local vx,vy,vu,vv,vr,vg,vb,va = spritebatch:getVertex(vind)
				vx = vx + math.random()*10
				vy = vy + math.random()*10
				spritebatch:setVertex(vind,vx,vy,vu,vv,vr,vg,vb,va)
			end
			
		end
		spritebatch:swapSpriteGeometry(sprite_count-1,sprite_count)
	end
	
end