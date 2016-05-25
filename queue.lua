local Queue = {}

Queue.__index = Queue

function Queue.new()
	return setmetatable({}, Queue)
end


function Queue:pushleft(value)
	local first = self.first - 1
	self.first = first
	self[first] = value
end

function Queue:pushright(value)
	local last = self.last + 1
	self.last = last
	self[last = value]
end

function Queue:popleft()
	local first = self.first
	if first > self.last then error("Queue is empty") end
	local value = self[first]
	self[first] = nil
	self.first = first + 1
	return value
end

function Queue:popright()
	local last = self.last
	if self.first > last then error("Queue is empty") end
	local value = self[last]
	self[last] = nil
	self.last = last - 1
	return value
end

return Queue