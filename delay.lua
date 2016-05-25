socket = require "socket"

server = socket.bind("*", 5006)

server:settimeout(0)

connections = {}

while true do
	client = server:accept()
	
	if client then
		print("Got client!")
		table.insert(connections, {client, socket.connect("localhost", 5005)})
		print("client = "..tostring(connections[#connections][1]))
		print("outConnection = "..tostring(connections[#connections][2]))
		client:settimeout(0)
	end
	
	for i, connection in ipairs(connections) do
		CLOSE = false
		local clientMsg, err = connection[1]:receive()
		socket.select(nil,nil,1)
		if clientMsg then
			connection[2]:send(clientMsg)
		elseif err == "closed" then
			connection[2]:close()
			CLOSE = true
		end
	end
	
	--socket.select(nil,nil,(math.random()*10)+1)
	
	for i,connection in ipairs(connections) do
		local serverMsg, err = connection[2]:receive()
		socket.select(nil,nil,1)
		if serverMsg then
			connection[1]:send(serverMsg)
		elseif err == "closed" then
			connection[1]:close()
			CLOSE = true
		end
	end
end