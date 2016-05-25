socket = require "socket"
require "utils"
--Queue = require "queue"

function love.load(arg)
	port = tonumber(arg[3]) or 5005
	print("Opening on port "..port)
	client = socket.connect("localhost", port)
	client:settimeout(0)
	SYNC = {}
	packets = {}
	
	
end

function love.draw()
	for k,v in pairs(SYNC) do
		love.graphics.rectangle("fill", v.x, v.y, v.w, v.h)
	end
end

function love.update(dt)
	for k,v in pairs(SYNC) do
		v.x = v.x + (v.vx * dt)
		v.y = v.y + (v.vy * dt)
	end
	
	msg,err = client:receive()
	
	if not msg and err == "closed" then love.quit() end
	if msg then
		print("Got msg of "..msg)
		processServerMessage(msg)
	end
	
end

function processServerMessage(msg)
	parts = split(msg, ";")
	
	args = {}
	
	obj_args = {}
	
	for _,v in ipairs(parts) do
		key, value = v:match("^([^=]+)=(.*)")
		if key then
			args[key:gsub("~","")] = tonumber(value) or value
			if not key:find("~") then
				obj_args[key] = tonumber(value) or value
			end
		end
	end
	
	opcode = parts[1]
	
	if opcode == "ADD_OBJ" then
		SYNC[args.UUID] = {}
		for k,v in pairs(obj_args) do
			SYNC[args.UUID][k]=v
		end
	elseif opcode == "SYNC" then
		for k,v in pairs(obj_args) do
			SYNC[args.UUID][k]=v
		end
	end
end

function love.keypressed(key)
	if key == "2" then
		print("Sending message!")
		client:send("UPDATE_SYNC;UUID=square2;key=vy;value=-10".."\r\n")
	end
end