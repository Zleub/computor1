--          `--::-.`
--      ./shddddddddhs+.
--    :yddddddddddddddddy:
--  `sdddddddddddddddddddds`
--  ydddh+sdddddddddy+ydddds  computorv1:computer1
-- /ddddy:oddddddddds:sddddd/ By adebray - adebray
-- sdddddddddddddddddddddddds
-- sdddddddddddddddddddddddds Created: 2015-03-19 10:56:17
-- :ddddddddddhyyddddddddddd: Modified: 2015-04-20 12:54:45
--  odddddddd/`:-`sdddddddds
--   +ddddddh`+dh +dddddddo
--    -sdddddh///sdddddds-
--      .+ydddddddddhs/.
--          .-::::-`

if not arg[1] then print('Usage: lua computorv1 [exp]') return end
print("arg[1]: "..arg[1])

nbr = "[-%d%.]+"
exp = "X^"..nbr

getE = function(self)
	local E = string.match(self.Member, "X^("..nbr..")")
	if not E then
		return "0"
	elseif E == "0" then
		self.Member = string.match(self.Member, "("..nbr..")")
	end
	return E
end

getN = function(self)
	return string.match(self.Member, nbr)
end

Sort = function(a, b)
	if a.Exposant <= b.Exposant then
		return true
	else
		return false
	end
end

getD = function(self)
	table.sort(self, Sort)
	-- print(inspect(self))
	for k, _m in ipairs(self) do
		if not self.c then
			self.c = _m.Member
		elseif not self.b then
			self.b = _m.Member
		elseif not self.a then
			self.a = _m.Member
		end
	end
	if not self.a then return end
	return self.b * self.b - (4 * (self.a  * self.c))
end

Merge = function (self, m)
	for k, _m in ipairs(self) do
		if m.Exposant == _m.Exposant then
			_m.Member = _m.Member - m.Member
			m.Member = 0
		end
	end
	if m.Member ~= 0 then
		print("Polynomial degree: "..#self )
		print("The polynomial degree is stricly greater than 2, I can't solve.")
		os.exit()
	end
end

toInt = function (self)
	self.Exposant = tonumber(self:getExposant())
	self.Member = tonumber(self:getNumber())
end

function sqrt(n)
	local a = n
	local  x = 1

	for i = 0,n do
		x = 0.5 * ( x + a / x )
	end
	return x
end

List = {
	New = function ()
		local t = {
			Merge = Merge,
			getDelta = getD,
			getSigne = getS
		}
	return t
	end
}

Members = {
	_List = {
		Print = function (self)
			io.write("Reduced form: ")
			for k, m in ipairs(self) do
				io.write(m.Member.." * X^"..m.Exposant.." "..m.Operand.." ")
			end
			print("")
		end
	},
	List1 = List.New(),
	List2 = List.New(),
	New = function (self, str, op)
		local m = {
			Member = str,
			Operand = op,
			getExposant = getE,
			getNumber = getN,
			toInt = toInt
		}
		table.insert(self._List, m)
		if self._change then
			table.insert(self.List2, m)
		else
			table.insert(self.List1, m)
		end
		if op == "=" then
			self._change = 1
		end
	end,
	Reduce = function (self)
		local littleone
		local bigone
		if #self.List1 >= #self.List2 then
			littleone = self.List2
			bigone = self.List1
		else
			littleone = self.List1
			bigone = self.List2
		end
		if #bigone - 1 >= 3 then
			print("Polynomial degree: "..#bigone -1 )
			print("The polynomial degree is stricly greater than 2, I can't solve.")
			os.exit()
		end
		for k,m in ipairs(littleone) do
			-- local e = m:getExposant()
			bigone:Merge(m)
		end
		return bigone
	end,
	First = function (bigone)
		print("Polynomial degree: 1")
		local d = bigone:getDelta()
		-- print(inspect(bigone))
		if bigone.b == 0 and bigone.c == 0 then
			print("The solution is everything.")
			return ;
		elseif bigone.b == 0 then
			print("There is no solution. Dividing by 0.")
			return ;
		elseif #bigone == 1 then
			if bigone[1].Member ~= 0 then
				print("There is no solution.")
			else
				print("The solution is !! : "..bigone[1].Member)
			end
			return
		end
		print("The solution is: "..-bigone.c / bigone.b)
	end,
	Second = function (bigone)
		print("Polynomial degree: 2")
		local d = bigone:getDelta()
		if bigone.a == 0 then
		print("There is no solution. Dividing by 0.")
			return ;
		end
		if d > 0 then
			print("Discriminant is strictly positive, the two solutions are:")
			print( (-bigone.b + sqrt(d)) / (2 * bigone.a))
			print( (-bigone.b - sqrt(d)) / (2 * bigone.a))
		elseif d == 0 then
			print("Discriminant is strictly 0. The solution is:")
			print(-(bigone.b / 2 * bigone.a))
		else
			local tmp1 = -bigone.b
			local tmp2 = 2 * bigone.a
			d = -d

			print("Discriminant is strictly negative.")
			print(tmp1.."/".. tmp2.." + i√("..d..") / "..tmp2)
			print(tmp1.."/".. tmp2.." - i√("..d..") / "..tmp2)
		end
	end,
	Resolve = function (self, bigone)
		local d = bigone:getDelta()
		if bigone.a then
			self.Second(bigone)
		else
			self.First(bigone)
		end
	end

}

e = {}
for f,o in string.gmatch(arg[1], "("..nbr.." [%+%-%*/] "..exp..") ?([%+%-%*/=]?)") do
	Members:New(f, o)
	Members._List[#Members._List]:toInt()
	if #Members._List > 1 and Members._List[#Members._List - 1].Operand == "-" then
		Members._List[#Members._List - 1].Operand = "+"
		Members._List[#Members._List].Member = Members._List[#Members._List].Member * -1
	end
end

mainList = Members:Reduce()
Members._List:Print()
Members:Resolve(mainList)
