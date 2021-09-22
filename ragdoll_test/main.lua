--[[
Joints are currently locked up for some reason. Possible upper lower limit issue??



--]]

function love.load()
	--Load our textures, sounds, etc
	love.graphics.setBackgroundColor(0, 0, 0)
	love.graphics.setDefaultFilter("nearest", "nearest")
	gwidth, gheight = 1280, 720
	love.window.setMode(gwidth, gheight, {vsync = 0})

--BEGIN GAME
	--initialize some 'constants' first
	CONST_FPS = 0
	CONST_DEBUG_M = false
	CONST_WORLD_LIMIT = 1200
	LET_CUR_GAME_STATE = "play_state"
	LET_PREV_GAME_STATE = ""
	LET_GAME_PAUSED = false
	LET_MOUSE_X, LET_MOUSE_Y, LET_MOUSE_PX, LET_MOUSE_PY = 0, 0, 0, 0
	LET_MOUSEJOINT = nil

	--Editor Vars
	LET_EDITOR_DEFAULT_TOOL = "editor_tool_select"

	love.physics.setMeter(32)
	world = love.physics.newWorld(0, 9.81*64, true)
	createWalls()
end

function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
	elseif key == "`" then
		if CONST_DEBUG_M then
			CONST_DEBUG_M = false
		else
			CONST_DEBUG_M = true
		end
	elseif key == "f" then
		if LET_GAME_PAUSED then
			LET_GAME_PAUSED = false
		else
			LET_GAME_PAUSED = true
		end
	end
end

function love.update(dt)
	--dt = .002 --slows down time
	--Grabs game FPS
	CONST_FPS = love.timer.getFPS()
	LET_MOUSE_PX, LET_MOUSE_PY = LET_MOUSE_X, LET_MOUSE_Y
	LET_MOUSE_X, LET_MOUSE_Y = love.mouse.getPosition()

	if not LET_GAME_PAUSED then
		world:update(dt) --this puts the world into motion
		ragdoll.Update(dt)
	end
end

function love.draw()
	--Draws to camera
	love.graphics.setColor(1, 1, 1)
	--Displays FPS benchmark
	love.graphics.print(CONST_FPS, 0, 0)

	if LET_GAME_PAUSED then
		--love.graphics.setFont(defaultFontHuge)
		love.graphics.printf("PAUSED", 0, (gheight / 2) * .5, gwidth, "center")
		--love.graphics.setFont(defaultFont)
	end

	drawWalls()
	ragdoll.Draw()

	debugMenuDraw()
	debugDraw()
end

function love.mousepressed(x, y, mButton)
	if not LET_GAME_PAUSED then
		for i,v in ipairs(ragdoll) do
			ragdoll:bodySelect(ragdoll[i])
		end
	end
end

function love.mousereleased(x, y, mButton)
	if LET_GAME_PAUSED then
		ragdoll.Create(x, y)
	elseif not LET_GAME_PAUSED then
		for i,v in ipairs(ragdoll) do
			ragdoll:bodyRelease(ragdoll[i])
		end
	end
end

function love.mousemoved(x, y, dx, dy)
	--probably irrelevant code
	if mouseMoved then
		mouseMoved = false
	else
		mouseMoved = true
	end
end

function switchGameState(newState) --Used for button.lua actions
	if LET_CUR_GAME_STATE ~= newState then
		LET_PREV_GAME_STATE = LET_CUR_GAME_STATE
		LET_CUR_GAME_STATE = newState
	end
end

function debugMenuDraw()
	if CONST_DEBUG_M then
		local CONST_DEBUG_X = 12
		local CONST_DEBUG_Y = 12
		local CONST_DEBUG_W = 250
		local CONST_DEBUG_H = 200
		love.graphics.setColor(0, 1, 0, .25)
		love.graphics.rectangle("fill", CONST_DEBUG_X, CONST_DEBUG_Y, CONST_DEBUG_W, CONST_DEBUG_H)
		love.graphics.setColor(1, 1, 1)
		love.graphics.printf("DEBUG MENU", CONST_DEBUG_X, CONST_DEBUG_Y, CONST_DEBUG_W, "center")
		--love.graphics.printf("# Players: " .. #player, CONST_DEBUG_X, CONST_DEBUG_Y * 3, CONST_DEBUG_W, "left")
		--love.graphics.printf("Player State: " .. player[1].state, CONST_DEBUG_X, CONST_DEBUG_Y * 4.5, CONST_DEBUG_W, "left")
		--love.graphics.printf("Player Frame: " .. math.floor(player[1].current_frame), CONST_DEBUG_X, CONST_DEBUG_Y * 6, CONST_DEBUG_W, "left")
		--love.graphics.printf("#Blocks: " .. #block, CONST_DEBUG_X, CONST_DEBUG_Y * 7.5, CONST_DEBUG_W, "left")
		--love.graphics.printf("#Enemies: " .. #block, CONST_DEBUG_X, CONST_DEBUG_Y * 9, CONST_DEBUG_W, "left")
		--love.graphics.printf("Game State: " .. LET_CUR_GAME_STATE, CONST_DEBUG_X, CONST_DEBUG_Y * 11.5, CONST_DEBUG_W, "left")
		--love.graphics.printf("Previous Game State: " .. LET_PREV_GAME_STATE, CONST_DEBUG_X, CONST_DEBUG_Y * 13, CONST_DEBUG_W, "left")
	end
end

function debugDraw()
	if CONST_DEBUG_M then
		for i,v in ipairs(ragdoll) do
			--Ragdoll Hitbox
			love.graphics.setColor(1, 0, 1)
			love.graphics.circle("line", v.bones.headBody:getX(), v.bones.headBody:getY(), v.bones.headShape:getRadius())
			love.graphics.polygon("line", v.bones.bodyBody:getWorldPoints(v.bones.bodyShape:getPoints()))
			love.graphics.polygon("line", v.bones.rThighBody:getWorldPoints(v.bones.rThighShape:getPoints()))
			love.graphics.polygon("line", v.bones.rShinBody:getWorldPoints(v.bones.rShinShape:getPoints()))
			love.graphics.polygon("line", v.bones.lThighBody:getWorldPoints(v.bones.lThighShape:getPoints()))
			love.graphics.polygon("line", v.bones.lShinBody:getWorldPoints(v.bones.lShinShape:getPoints()))
		end
	end
end

function createWalls()
	walls = {}

	walls.ground = {}
	walls.ground.body = love.physics.newBody(world, gwidth/2, gheight - 32, "static")
	walls.ground.shape = love.physics.newRectangleShape(gwidth, 16)
	walls.ground.fixture = love.physics.newFixture(walls.ground.body, walls.ground.shape, 2)

	walls.right = {}
	walls.right.body = love.physics.newBody(world, 32, gheight/2, "static")
	walls.right.shape = love.physics.newRectangleShape(16, gheight)
	walls.right.fixture = love.physics.newFixture(walls.right.body, walls.right.shape, 2)

	walls.left = {}
	walls.left.body = love.physics.newBody(world, gwidth - 32, gheight/2, "static")
	walls.left.shape = love.physics.newRectangleShape(16, gheight)
	walls.left.fixture = love.physics.newFixture(walls.left.body, walls.left.shape, 2)

	walls.ceiling = {}
	walls.ceiling.body = love.physics.newBody(world, gwidth/2, 32, "static")
	walls.ceiling.shape = love.physics.newRectangleShape(gwidth, 16)
	walls.ceiling.fixture = love.physics.newFixture(walls.ceiling.body, walls.ceiling.shape, 2)
end

function drawWalls()
	love.graphics.setColor(1, 1, 1)
	love.graphics.polygon("line", walls.ground.body:getWorldPoints(walls.ground.shape:getPoints()))
	love.graphics.polygon("line", walls.right.body:getWorldPoints(walls.right.shape:getPoints()))
	love.graphics.polygon("line", walls.left.body:getWorldPoints(walls.left.shape:getPoints()))
	love.graphics.polygon("line", walls.ceiling.body:getWorldPoints(walls.ceiling.shape:getPoints()))
end

ragdoll = {}
function ragdoll.Create(x, y)
	table.insert(ragdoll, {x = x, y = y, width = 32, height = 64, partGrabbed = nil, highlight = false})

	--Create a table to store our bones in a specific order
	ragdoll[#ragdoll].bones = {}

	--START BONES--
	--Head
	ragdoll[#ragdoll].bones.headBody = love.physics.newBody(world, ragdoll[#ragdoll].x, ragdoll[#ragdoll].y + (16+8), "dynamic")
	ragdoll[#ragdoll].bones.headBody:setMass(8.23)
	ragdoll[#ragdoll].bones.headShape = love.physics.newCircleShape(16)
	ragdoll[#ragdoll].bones.headFixture = love.physics.newFixture(ragdoll[#ragdoll].bones.headBody, ragdoll[#ragdoll].bones.headShape)
	ragdoll[#ragdoll].bones.headFixture:setDensity(1.0)
	ragdoll[#ragdoll].bones.headFixture:setFriction(0.4)
	ragdoll[#ragdoll].bones.headFixture:setRestitution(0.3)
	--Torso
	ragdoll[#ragdoll].bones.bodyBody = love.physics.newBody(world, ragdoll[#ragdoll].x, ragdoll[#ragdoll].y + 64, "dynamic")
	ragdoll[#ragdoll].bones.bodyBody:setMass(54.15)
	ragdoll[#ragdoll].bones.bodyShape = love.physics.newRectangleShape(ragdoll[#ragdoll].width / 2, ragdoll[#ragdoll].height * .65)--41.6u height
	ragdoll[#ragdoll].bones.bodyFixture = love.physics.newFixture(ragdoll[#ragdoll].bones.bodyBody, ragdoll[#ragdoll].bones.bodyShape)
	ragdoll[#ragdoll].bones.bodyFixture:setDensity(1.0)
	ragdoll[#ragdoll].bones.bodyFixture:setFriction(0.4)
	ragdoll[#ragdoll].bones.bodyFixture:setRestitution(0.1)
	--Right Thigh
	ragdoll[#ragdoll].bones.rThighBody = love.physics.newBody(world, ragdoll[#ragdoll].x + 4, ragdoll[#ragdoll].y + 83.2, "dynamic")
	ragdoll[#ragdoll].bones.rThighBody:setMass(11.125)
	ragdoll[#ragdoll].bones.rThighShape = love.physics.newRectangleShape(ragdoll[#ragdoll].width / 4, ragdoll[#ragdoll].height * .3)--19.2u height
	ragdoll[#ragdoll].bones.rThighFixture = love.physics.newFixture(ragdoll[#ragdoll].bones.rThighBody, ragdoll[#ragdoll].bones.rThighShape)
	ragdoll[#ragdoll].bones.rThighFixture:setDensity(1.0)
	ragdoll[#ragdoll].bones.rThighFixture:setFriction(0.4)
	ragdoll[#ragdoll].bones.rThighFixture:setRestitution(0.1)
	--Right Shin
	ragdoll[#ragdoll].bones.rShinBody = love.physics.newBody(world, ragdoll[#ragdoll].x + 4, ragdoll[#ragdoll].y + 108.8, "dynamic")
	ragdoll[#ragdoll].bones.rShinBody:setMass(5.05)
	ragdoll[#ragdoll].bones.rShinShape = love.physics.newRectangleShape(ragdoll[#ragdoll].width / 4, ragdoll[#ragdoll].height * .4)--25.6u height
	ragdoll[#ragdoll].bones.rShinFixture = love.physics.newFixture(ragdoll[#ragdoll].bones.rShinBody, ragdoll[#ragdoll].bones.rShinShape)
	ragdoll[#ragdoll].bones.rShinFixture:setDensity(1.0)
	ragdoll[#ragdoll].bones.rShinFixture:setFriction(0.4)
	ragdoll[#ragdoll].bones.rShinFixture:setRestitution(0.1)
	--Left Thigh
	ragdoll[#ragdoll].bones.lThighBody = love.physics.newBody(world, ragdoll[#ragdoll].x - 4, ragdoll[#ragdoll].y + 83.2, "dynamic")
	ragdoll[#ragdoll].bones.lThighBody:setMass(11.125)
	ragdoll[#ragdoll].bones.lThighShape = love.physics.newRectangleShape(ragdoll[#ragdoll].width / 4, ragdoll[#ragdoll].height * .3)--19.2u height
	ragdoll[#ragdoll].bones.lThighFixture = love.physics.newFixture(ragdoll[#ragdoll].bones.lThighBody, ragdoll[#ragdoll].bones.lThighShape)
	ragdoll[#ragdoll].bones.lThighFixture:setDensity(1.0)
	ragdoll[#ragdoll].bones.lThighFixture:setFriction(0.4)
	ragdoll[#ragdoll].bones.lThighFixture:setRestitution(0.1)
	--Left Shin
	ragdoll[#ragdoll].bones.lShinBody = love.physics.newBody(world, ragdoll[#ragdoll].x - 4, ragdoll[#ragdoll].y + 108.8, "dynamic")
	ragdoll[#ragdoll].bones.lShinBody:setMass(5.05)
	ragdoll[#ragdoll].bones.lShinShape = love.physics.newRectangleShape(ragdoll[#ragdoll].width / 4, ragdoll[#ragdoll].height * .4)--25.6u height
	ragdoll[#ragdoll].bones.lShinFixture = love.physics.newFixture(ragdoll[#ragdoll].bones.lShinBody, ragdoll[#ragdoll].bones.lShinShape)
	ragdoll[#ragdoll].bones.lShinFixture:setDensity(1.0)
	ragdoll[#ragdoll].bones.lShinFixture:setFriction(0.4)
	ragdoll[#ragdoll].bones.lShinFixture:setRestitution(0.1)

	--Local vars for joints/bones/ai
	local upperLimit = 0
	local lowerlimit = 0
	ragdoll.standingHeight = ragdoll[#ragdoll].y + 108.8

	--START JOINTS--
	--Create a table to store our joints
	ragdoll[#ragdoll].joints = {}
	--Head to Torso Joint
	lowerlimit = -40 / (180/math.pi)
	upperLimit = 40 / (180/math.pi)
	ragdoll[#ragdoll].joints.neckJoint = love.physics.newRevoluteJoint(ragdoll[#ragdoll].bones.bodyBody, ragdoll[#ragdoll].bones.headBody, ragdoll[#ragdoll].x, ragdoll[#ragdoll].y + ragdoll[#ragdoll].bones.headShape:getRadius() + 8, false)
	ragdoll[#ragdoll].joints.neckJoint:setLimits(lowerlimit, upperLimit)
	ragdoll[#ragdoll].joints.neckJoint:setLimitsEnabled(true)
	--Right Upper Leg to Torso Joint
	lowerlimit = -45 / (180/math.pi)
	upperLimit = 25 / (180/math.pi)
	ragdoll[#ragdoll].joints.rThighJoint = love.physics.newRevoluteJoint(ragdoll[#ragdoll].bones.rThighBody, ragdoll[#ragdoll].bones.bodyBody, ragdoll[#ragdoll].x + 4, ragdoll[#ragdoll].y + 83.2, false)
	ragdoll[#ragdoll].joints.rThighJoint:setLimits(lowerlimit, upperLimit)
	ragdoll[#ragdoll].joints.rThighJoint:setLimitsEnabled(true)
	--Right Lower Leg to Upper Leg Joint
	lowerlimit = -115 / (180/math.pi)
	upperLimit = 25 / (180/math.pi)
	ragdoll[#ragdoll].joints.rShinJoint = love.physics.newRevoluteJoint(ragdoll[#ragdoll].bones.rShinBody, ragdoll[#ragdoll].bones.rThighBody, ragdoll[#ragdoll].x + 4, ragdoll[#ragdoll].y + 108.8, false)
	ragdoll[#ragdoll].joints.rShinJoint:setLimits(lowerlimit, upperLimit)
	ragdoll[#ragdoll].joints.rShinJoint:setLimitsEnabled(true)
	--Left Upper Leg to Torso Joint
	lowerlimit = -25 / (180/math.pi)
	upperLimit = 45 / (180/math.pi)
	ragdoll[#ragdoll].joints.lThighJoint = love.physics.newRevoluteJoint(ragdoll[#ragdoll].bones.lThighBody, ragdoll[#ragdoll].bones.bodyBody, ragdoll[#ragdoll].x - 4, ragdoll[#ragdoll].y + 83.2, false)
	ragdoll[#ragdoll].joints.lThighJoint:setLimits(lowerlimit, upperLimit)
	ragdoll[#ragdoll].joints.lThighJoint:setLimitsEnabled(true)
	--Left Lower Leg to Upper Leg Joint
	lowerlimit = -25 / (180/math.pi)
	upperLimit = 115 / (180/math.pi)
	ragdoll[#ragdoll].joints.lShinJoint = love.physics.newRevoluteJoint(ragdoll[#ragdoll].bones.lShinBody, ragdoll[#ragdoll].bones.lThighBody, ragdoll[#ragdoll].x - 4, ragdoll[#ragdoll].y + 108.8, false)
	ragdoll[#ragdoll].joints.lShinJoint:setLimits(lowerlimit, upperLimit)
	ragdoll[#ragdoll].joints.lShinJoint:setLimitsEnabled(true)
end

function ragdoll.Update(dt)
	for i,v in ipairs(ragdoll) do
		--Check if we are hovering over a ragdoll
		if v.highlight then
			--if we do NOT have a mousejoint then create a new one
			if LET_MOUSEJOINT == nil then
				LET_MOUSEJOINT = love.physics.newMouseJoint(v.bones.headBody, v.bones.headBody:getX(), v.bones.headBody:getY())
			--if we DO have a mousejoint then set the cursor as a target for the body position
			elseif LET_MOUSEJOINT ~= nil then
				LET_MOUSEJOINT:setTarget(love.mouse.getPosition())
			end

			--Sets body position to mouse cursor
			--v.bones.headBody:setPosition(love.mouse.getPosition())
		end
	end
end

function ragdoll.Draw()
	for i,v in ipairs(ragdoll) do
		--Changes color if hovering over ragdoll
		if v.highlight then
			love.graphics.setColor(1, 1, 1)
		else
			love.graphics.setColor(.8, .8, .8, .95)
		end

		--Renders out each piece of our ragdoll
		love.graphics.circle("fill", v.bones.headBody:getX(), v.bones.headBody:getY(), v.bones.headShape:getRadius())
		love.graphics.polygon("fill", v.bones.bodyBody:getWorldPoints(v.bones.bodyShape:getPoints()))
		love.graphics.polygon("fill", v.bones.rThighBody:getWorldPoints(v.bones.rThighShape:getPoints()))
		love.graphics.polygon("fill", v.bones.rShinBody:getWorldPoints(v.bones.rShinShape:getPoints()))
		love.graphics.polygon("fill", v.bones.lThighBody:getWorldPoints(v.bones.lThighShape:getPoints()))
		love.graphics.polygon("fill", v.bones.lShinBody:getWorldPoints(v.bones.lShinShape:getPoints()))
	end
end


function ragdoll:bodySelect(self)
	if self.bones.headShape:testPoint(self.bones.headBody:getX(), self.bones.headBody:getY(), 0, love.mouse.getPosition()) then
		self.highlight = true
	end
end

function ragdoll:bodyRelease(self)
	if self.highlight then
		self.highlight = false
		--Destroys created mousejoint and declares it nil to free up room for a new grab joint
		LET_MOUSEJOINT:destroy()
		LET_MOUSEJOINT = nil

		--Sets linear velocity to shoot ragdoll out after grab release
		--self.bones.headBody:setLinearVelocity((LET_MOUSE_X-LET_MOUSE_PX) * 200, (LET_MOUSE_Y-LET_MOUSE_PY) * 200)
	end
end