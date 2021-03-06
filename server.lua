socket = require "socket"
require "utils"

server = socket.bind("*", 5005)

connections = {}

ID = 0

SYNC = {}

SYNC.square1 = {x=50,y=50,w=100,h=100,vx=0,vy=0}
SYNC.square2 = {x=300,y=50,w=100,h=100,vx=0,vy=20}

server:settimeout(0)

function send(client, ...)
	local args = {...}
	local s = ""
	for i = 1,#args do
		s = s .. args[i]..";"
	end
	s = s .. "~timestamp="..socket.gettime()
	client:send(s.."\r\n")
end

previous_time = socket.gettime()

while true do
	socket.select(nil,nil,0.01)
	
	current_time = socket.gettime()
	dt = (current_time - previous_time)
	
	previous_time = current_time
	client = server:accept()
	
	if dt > 0.02 then
		print("DT TOO LARGE "..dt)
	end

	
	print("dt = "..dt)
	
	for k,v in pairs(SYNC) do
		v.x = v.x + (v.vx * dt)
		v.y = v.y + (v.vy * dt)
	end
	
	if client then
		print("got a client!")
		table.insert(connections, client)
		client:settimeout(0)
		ID = ID + 1
		send(client, "CONNECT", "id="..ID)
		
		for k,v in pairs(SYNC) do
			send(client, "ADD_OBJ", "UUID="..k,
				"x="..v.x,
				"y="..v.y,
				"w="..v.w,
				"h="..v.h,
				"vx="..v.vx,
				"vy="..v.vy)
		end
	end
		
	for _,client in ipairs(connections) do
		msg,err = client:receive()
		if msg then
			print("Got message of "..msg)
			parts = split(msg, ";")
			opcode = parts[1]
			
			args = {}
			
			for _,v in ipairs(parts) do
				key, value = v:match("^([^=]+)=(.*)")
				if key then
					args[key] = tonumber(value) or value
				end
			end
			
			--This will have to be changed to make sure that only certain things can be updated
			if opcode == "UPDATE_SYNC" then
				print("Updating...")
				SYNC[args.UUID][args.key]=args.value
				
				for i = 1,#connections do
					send(connections[i], "SYNC", "UUID="..args.UUID,
						args.key.."="..args.value)
				end
			end
		elseif err == "closed" then
			for i = #connections,1,-1 do
				if connections[i] == client then table.remove(connections, i) end
			end
		end	
	end
	
	
end