-- mesh-augmented spritebatch for love2d by mkdxdx
-- main purpose is to give ability to change properties of already created sprites, mainly color, 
-- but you can change any sprite attribute you want by using getVertex/setVertex functions

-- licensing: code can be used however you want

VASpriteBatch = {}
VASpriteBatch.__index = VASpriteBatch
VASpriteBatch.ident = "c_vaspritebatch"
VASpriteBatch.use_mesh = true
VASpriteBatch.use_autorefresh = true
VASpriteBatch.ar_position = true
VASpriteBatch.ar_texcoord = true
VASpriteBatch.ar_color = true
VASpriteBatch.use_recycle = true -- if recycle enabled
-- spritebatch is going to attempt to use old and unused sprites instead of adding new ones
-- and is going to track every usage of sprites
-- to make this feature faster - user has to explicitly use function releaseSprite(id)
-- so that spritebatch will mark unused sprites and then use them on next call of add()

-- unused sprite is marked with each vertex having X/Y:0/0 and U/V:0/0
-- i can use separate id table to track unused sprites
-- or i can use custom vertex attributes to track unused vertices but that is a huge excess
function VASpriteBatch:new(texture,buffer_size,hint)
	local self = setmetatable({},VASpriteBatch)
	self.sprite_added = false
	self.sb = love.graphics.newSpriteBatch(texture,buffer_size,hint)
	self.mesh = love.graphics.newMesh(4*self.sb:getBufferSize(),"fan",hint)
	self.released_stack = {}
	return self
end

local sin,cos = math.sin,math.cos
local rem = table.remove
function VASpriteBatch:add(quad, x, y, r, sx, sy, ox, oy, kx, ky)
	local id 
	if self.use_recycle == true and #self.released_stack>0 then
		id = self.released_stack[#self.released_stack]
		rem(self.released_stack,#self.released_stack)
		self:set(id,quad,x,y,r,sx,sy,ox,oy,kx,ky)
	else
		id = self.sb:add(quad, x, y, r, sx, sy, ox, oy, kx, ky)
	end
	if self.use_mesh == true then
		self.sprite_added = true
		self:updateSpriteVertexData(true,id, quad, x, y, r, sx, sy, ox, oy, kx, ky)
	end
	return id
end


function VASpriteBatch:set(id,quad,x,y,r,sx,sy,ox,oy,kx,ky)	
	self.sb:set(id,quad,x,y,r,sx,sy,ox,oy,kx,ky) 
	if self.use_mesh == true then
		self:updateSpriteVertexData(false, id, quad, x, y, r, sx, sy, ox, oy, kx, ky)
	end
end

-- this function will mark sprite id as released for later usage
-- after at least one released sprite is present, next call of Add will use previously
-- released id and return it on call
function VASpriteBatch:releaseSprite(id)
	-- set all vertices XYUV 0/0/0/0
	local vind = (id-1)*4
	for i=1,4 do
		self:setVertex(vind+i, 0,0, 0,0, 255,255,255,255)
	end
	self.released_stack[#self.released_stack+1] = id
end

-- the magic function
-- on every add or set call, it's going to update spritebatch mesh so that 
-- vertex color and sprite transformation data can be changed independently
function VASpriteBatch:updateSpriteVertexData(isNew,id,quad,x,y,r,sx,sy,ox,oy,kx,ky)
	-- if we use separate vertex array (an by default we do)
	-- at the same time the sprite is created, we create
	-- vertex array which resembles our new sprite
	-- and we need co calculate each vertex data from sprite creation parameters
	-- for later transformations
	local qx,qy,qw,qh = quad:getViewport()
	local texw, texh = self.sb:getTexture():getWidth(), self.sb:getTexture():getHeight()
	-- calculate vertex position
	-- should include rotation, skew and offset
	local ox = ox or 0
	local oy = oy or 0
	local r = r or 0
	local sx = sx or 1
	local sy = sy or 1
	local vx = x - ox*sx
	local vy = y - oy*sy
	-- calculate vertex coordinates
	local tlx,tly = (vx),(vy)
	local blx,bly = (vx),(vy+qh*sy)
	local trx,try = (vx+qw*sx),(vy)
	local brx,bry = (vx+qw*sx),(vy+qh*sy)
	-- apply rotation
	local ntlx,ntly = x + (tlx - x)*cos(r) - (tly - y)*sin(r), y + (tlx - x)*sin(r) + (tly - y)*cos(r)
	local nblx,nbly = x + (blx - x)*cos(r) - (bly - y)*sin(r), y + (blx - x)*sin(r) + (bly - y)*cos(r)
	local ntrx,ntry = x + (trx - x)*cos(r) - (try - y)*sin(r), y + (trx - x)*sin(r) + (try - y)*cos(r)
	local nbrx,nbry = x + (brx - x)*cos(r) - (bry - y)*sin(r), y + (brx - x)*sin(r) + (bry - y)*cos(r)
	-- calculate vertex texture coordinates
	-- should include texture size and quad viewport size		
	local qx_n,qy_n = qx/texw,qy/texh
	local qw_n,qh_n = qw/texw,qh/texh
	-- add vertices for later transformations
	--[[ Sprite vertex numbers are as follows:
		  1-----3
		  |   / |
		  |  /  |
		  | /   |
		  2-----4 ]]--

	-- on each set or add sprite we add or recalculate vertices for our internal mesh
	-- for later attribute attachment	
	
	local vi = (id-1)*4
	
	-- top left vertex
	local ov_x,ov_y,ov_u,ov_v,ov_r,ov_g,ov_b,ov_a = self:getVertex(vi+1)
	if isNew == true then 
		ov_r,ov_g,ov_b,ov_a = 255,255,255,255
	end
	self:setVertex(vi+1, ntlx,ntly, qx_n, qy_n, 		ov_r,ov_g,ov_b,ov_a)
	
	-- bottom left
	ov_x,ov_y,ov_u,ov_v,ov_r,ov_g,ov_b,ov_a = self:getVertex(vi+2)
	if isNew == true then 
		ov_r,ov_g,ov_b,ov_a = 255,255,255,255
	end
	self:setVertex(vi+2, nblx,nbly,	qx_n,qy_n+qh_n, 	ov_r,ov_g,ov_b,ov_a)
	
	-- top right
	ov_x,ov_y,ov_u,ov_v,ov_r,ov_g,ov_b,ov_a = self:getVertex(vi+3)
	if isNew == true then 
		ov_r,ov_g,ov_b,ov_a = 255,255,255,255
	end
	self:setVertex(vi+3, ntrx,ntry, qx_n+qw_n,qy_n, 	ov_r,ov_g,ov_b,ov_a)
	
	-- bottom right
	ov_x,ov_y,ov_u,ov_v,ov_r,ov_g,ov_b,ov_a = self:getVertex(vi+4)
	if isNew == true then 
		ov_r,ov_g,ov_b,ov_a = 255,255,255,255
	end
	self:setVertex(vi+4, nbrx,nbry,	qx_n+qw_n,qy_n+qh_n,ov_r,ov_g,ov_b,ov_a)
	

end

function VASpriteBatch:swapSpriteGeometry(id1,id2)
	local vi_1 = ((id1-1)*4)
	local vi_2 = ((id2-1)*4)
	for i=1,4 do
		local v1_x,v1_y,v1_u,v1_v,v1_r,v1_g,v1_b,v1_a = self:getVertex(vi_1+i)
		local v2_x,v2_y,v2_u,v2_v,v2_r,v2_g,v2_b,v2_a = self:getVertex(vi_2+i)
		self:setVertex(vi_1+i,v2_x,v2_y,v2_u,v2_v,v2_r,v2_g,v2_b,v2_a)
		self:setVertex(vi_2+i,v1_x,v1_y,v1_u,v1_v,v1_r,v1_g,v1_b,v1_a)
	end
end

function VASpriteBatch:setSpriteColor(id,r,g,b,a)
	local vi = (id-1)*4
	
	if type(r) == "table" then -- i use comparison first because if i use comparison in the loop, string comparison is a bit slower
		for i=1,4 do
			local v_x,v_y,v_u,v_v,v_r,v_g,v_b,v_a = self:getVertex(vi+i)
			self:setVertex(vi+i,v_x,v_y,v_u,v_v,(r[1] or v_r),(r[2] or v_g),(r[3] or v_b),(r[4] or v_a))
		end
	else
		for i=1,4 do
			local v_x,v_y,v_u,v_v,v_r,v_g,v_b,v_a = self:getVertex(vi+i)
			self:setVertex(vi+i,v_x,v_y,v_u,v_v,(r or v_r),(g or v_g),(b or v_b),(a or v_a))
		end
	end
end

-- this function returns spritebatch to draw in love.draw
-- and to reduce attachAttributes call count to one before actual drawcall
-- i use lazy autorefresh of each mesh attribute before that drawcall, 
-- not after attribute has been modified
function VASpriteBatch:getSpriteBatch() 
	if self.use_autorefresh == true then
		self:refreshAttributes()
	end
	return self.sb 
end

function VASpriteBatch:clear() self.sb:clear() end
function VASpriteBatch:setTexture(t) self.sb:setTexture(t) end
function VASpriteBatch:flush() self.sb:flush() end
function VASpriteBatch:getBufferSize() return self.sb:getBufferSize() end
function VASpriteBatch:setBufferSize(bs) self.sb:setBufferSize(bs) end
function VASpriteBatch:getTexture()	return self.sb:getTexture() end
function VASpriteBatch:attachAttribute(name,mesh) self.sb:attachAttribute(name,mesh or self.mesh) end
function VASpriteBatch:refreshAttributes() 
	if self.ar_position == true then self:attachAttribute("VertexPosition") end
	if self.ar_texcoord == true then self:attachAttribute("VertexTexCoord") end
	if self.ar_color == true then self:attachAttribute("VertexColor") end
end
function VASpriteBatch:getCount() return self.sb:getCount() end
function VASpriteBatch:getMesh() return self.mesh end
function VASpriteBatch:getVertex(index) return self.mesh:getVertex(index) end
function VASpriteBatch:setVertex(index,x,y,u,v,r,g,b,a)	self.mesh:setVertex(index,x,y,u,v,r,g,b,a) end
function VASpriteBatch:getFreeSpriteCount() return #self.released_stack end
function VASpriteBatch:setColor(r,g,b,a) self.sb:setColor(r,g,b,a) end
function VASpriteBatch:setMeshUsage(mu) self.use_mesh = mu end
function VASpriteBatch:setAutorefresh(ar) self.use_autorefresh = ar end
