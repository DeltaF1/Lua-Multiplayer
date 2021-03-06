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
	
	TIME = socket.gettime()
end

function love.draw()
	for k,v in pairs(SYNC) do
		love.graphics.rectangle("fill", v.x, v.y, v.w, v.h)
	end
end

function insertSort(arr)
	for i = 2,(#arr-1) do
		x = arr[i]
		j = i - 1
		while j >= 0 and arr[j].timestamp < x.timestamp do -- we need to iterate back to front later!
			arr[j+1] = arr[j]
			j = j - 1
		end
		arr[j+1] = x
	end
end

function love.update(dt)
	TIME = TIME + dt
	for k,v in pairs(SYNC) do
		v.x = v.x + (v.vx * dt)
		v.y = v.y + (v.vy * dt)
	end
	
	msg,err = client:receive()
	
	if not msg and err == "closed" then love.quit() end
	if msg then
		print("Got msg of "..msg)
		local packet = processServerMessage(msg)
		
		if packet.opcode == "CONNECT" then
			ID = packet.id
		end
	end
	
	insertSort(packets)
	
	for i = #packets,1,-1 do
		local packet = packets[i]
		
		local dif = TIME - packet.timestamp
		
		if dif >= 0.1 or packet.opcode == "CONNECT" then
			handlePacket(packet)
			table.remove(packets, i)
		end
	end
	
	-- sort (packets)
	
	-- for all packets
	-- if timestamp >= TIME - 10 ms
	--  handlePacket()
	--  remove packet from packets
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
	
	args.opcode = opcode
	args.obj_args = obj_args
	table.insert(packets, args)
	
	return args
end

function handlePacket(packet)
	
	
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
		client:send("UPDATE_SYNC;UUID=square"..ID..";key=vy;value=-10".."\r\n")
	end
end