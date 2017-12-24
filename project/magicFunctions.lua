function computeMaxMana(u)
	local p,r = u.sumPower, u.sumResolve
	local c = getClassManaBonus(u.class)
	
	return 4 + c + math.floor((p+r)*0.25)
end

function computeManaRegen(u)
	local p,r = u.sumPower, u.sumResolve
	
	return -0.5 + math.floor(0.5 * math.sqrt(1 + 8*(p+r)))
end
