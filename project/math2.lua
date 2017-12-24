function clamp(val, a, b)
	lo = math.min(a,b)
	hi = math.max(a,b)
	return math.max(math.min(val,hi),lo)
end

function lerp(a,b,t)
	t = clamp(t,0,1)
	return (1-t)*a + t*b
end

function smoothstep(a,b,t)
	t = clamp(t,0,1)
	t = t*t*(3-2*t)
	return lerp(a,b,t)
end

function smoothnormal(a,b,t,k)
	if t < k then
		t = 0.5 * smoothstep(0,1,t/k)
	elseif t > 1-k then
		t = 1 - 0.5 * smoothstep(0,1,(1-t)/k)
	else
		t = 0.5
	end
	
	return lerp(a,b,t)
end

function round(a)
	b = math.floor(a)
	if a-b < 0.5 then
		return b
	else
		return b + 1
	end
end