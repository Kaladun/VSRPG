Queue = {}

function Queue.new(queue)
	return {first = 1, last = 0}
end

function Queue.push(queue, value)
	local last = queue.last + 1
	queue.last = last
	queue[last] = value
end

function Queue.pop(queue)
	local first = queue.first
	if first > queue.last then error("queue is empty") end
	local value = queue[first]
	queue[first] = nil        -- to allow garbage collection
	queue.first = first + 1
	return value
end

function Queue.length(queue)
	return queue.last - queue.first + 1
end