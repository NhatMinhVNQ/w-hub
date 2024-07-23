--[[
 .____                  ________ ___.    _____                           __                
 |    |    __ _______   \_____  \\_ |___/ ____\_ __  ______ ____ _____ _/  |_  ___________ 
 |    |   |  |  \__  \   /   |   \| __ \   __\  |  \/  ___// ___\\__  \\   __\/  _ \_  __ \
 |    |___|  |  // __ \_/    |    \ \_\ \  | |  |  /\___ \\  \___ / __ \|  | (  <_> )  | \/
 |_______ \____/(____  /\_______  /___  /__| |____//____  >\___  >____  /__|  \____/|__|   
         \/          \/         \/    \/                \/     \/     \/                   
          \_Welcome to LuaObfuscator.com   (Alpha 0.10.6) ~  Much Love, Ferib 

]]--

local StrToNumber = tonumber;
local Byte = string.byte;
local Char = string.char;
local Sub = string.sub;
local Subg = string.gsub;
local Rep = string.rep;
local Concat = table.concat;
local Insert = table.insert;
local LDExp = math.ldexp;
local GetFEnv = getfenv or function()
	return _ENV;
end;
local Setmetatable = setmetatable;
local PCall = pcall;
local Select = select;
local Unpack = unpack or table.unpack;
local ToNumber = tonumber;
local function VMCall(ByteString, vmenv, ...)
	local DIP = 1;
	local repeatNext;
	ByteString = Subg(Sub(ByteString, 5), "..", function(byte)
		if (Byte(byte, 2) == 79) then
			local FlatIdent_7126A = 0;
			while true do
				if (FlatIdent_7126A == 0) then
					repeatNext = StrToNumber(Sub(byte, 1, 1));
					return "";
				end
			end
		else
			local a = Char(StrToNumber(byte, 16));
			if repeatNext then
				local b = Rep(a, repeatNext);
				repeatNext = nil;
				return b;
			else
				return a;
			end
		end
	end);
	local function gBit(Bit, Start, End)
		if End then
			local FlatIdent_12703 = 0;
			local Res;
			while true do
				if (FlatIdent_12703 == 0) then
					Res = (Bit / (2 ^ (Start - 1))) % (2 ^ (((End - 1) - (Start - 1)) + 1));
					return Res - (Res % 1);
				end
			end
		else
			local Plc = 2 ^ (Start - 1);
			return (((Bit % (Plc + Plc)) >= Plc) and 1) or 0;
		end
	end
	local function gBits8()
		local FlatIdent_2BD95 = 0;
		local a;
		while true do
			if (FlatIdent_2BD95 == 1) then
				return a;
			end
			if (FlatIdent_2BD95 == 0) then
				a = Byte(ByteString, DIP, DIP);
				DIP = DIP + 1;
				FlatIdent_2BD95 = 1;
			end
		end
	end
	local function gBits16()
		local a, b = Byte(ByteString, DIP, DIP + 2);
		DIP = DIP + 2;
		return (b * 256) + a;
	end
	local function gBits32()
		local FlatIdent_324DE = 0;
		local a;
		local b;
		local c;
		local d;
		while true do
			if (FlatIdent_324DE == 1) then
				return (d * 16777216) + (c * 65536) + (b * 256) + a;
			end
			if (0 == FlatIdent_324DE) then
				a, b, c, d = Byte(ByteString, DIP, DIP + 3);
				DIP = DIP + 4;
				FlatIdent_324DE = 1;
			end
		end
	end
	local function gFloat()
		local Left = gBits32();
		local Right = gBits32();
		local IsNormal = 1;
		local Mantissa = (gBit(Right, 1, 20) * (2 ^ 32)) + Left;
		local Exponent = gBit(Right, 21, 31);
		local Sign = ((gBit(Right, 32) == 1) and -1) or 1;
		if (Exponent == 0) then
			if (Mantissa == 0) then
				return Sign * 0;
			else
				local FlatIdent_7909D = 0;
				while true do
					if (FlatIdent_7909D == 0) then
						Exponent = 1;
						IsNormal = 0;
						break;
					end
				end
			end
		elseif (Exponent == 2047) then
			return ((Mantissa == 0) and (Sign * (1 / 0))) or (Sign * NaN);
		end
		return LDExp(Sign, Exponent - 1023) * (IsNormal + (Mantissa / (2 ^ 52)));
	end
	local function gString(Len)
		local Str;
		if not Len then
			local FlatIdent_60EA1 = 0;
			while true do
				if (FlatIdent_60EA1 == 0) then
					Len = gBits32();
					if (Len == 0) then
						return "";
					end
					break;
				end
			end
		end
		Str = Sub(ByteString, DIP, (DIP + Len) - 1);
		DIP = DIP + Len;
		local FStr = {};
		for Idx = 1, #Str do
			FStr[Idx] = Char(Byte(Sub(Str, Idx, Idx)));
		end
		return Concat(FStr);
	end
	local gInt = gBits32;
	local function _R(...)
		return {...}, Select("#", ...);
	end
	local function Deserialize()
		local Instrs = {};
		local Functions = {};
		local Lines = {};
		local Chunk = {Instrs,Functions,nil,Lines};
		local ConstCount = gBits32();
		local Consts = {};
		for Idx = 1, ConstCount do
			local Type = gBits8();
			local Cons;
			if (Type == 1) then
				Cons = gBits8() ~= 0;
			elseif (Type == 2) then
				Cons = gFloat();
			elseif (Type == 3) then
				Cons = gString();
			end
			Consts[Idx] = Cons;
		end
		Chunk[3] = gBits8();
		for Idx = 1, gBits32() do
			local FlatIdent_64E40 = 0;
			local Descriptor;
			while true do
				if (FlatIdent_64E40 == 0) then
					Descriptor = gBits8();
					if (gBit(Descriptor, 1, 1) == 0) then
						local Type = gBit(Descriptor, 2, 3);
						local Mask = gBit(Descriptor, 4, 6);
						local Inst = {gBits16(),gBits16(),nil,nil};
						if (Type == 0) then
							local FlatIdent_31A5A = 0;
							while true do
								if (FlatIdent_31A5A == 0) then
									Inst[3] = gBits16();
									Inst[4] = gBits16();
									break;
								end
							end
						elseif (Type == 1) then
							Inst[3] = gBits32();
						elseif (Type == 2) then
							Inst[3] = gBits32() - (2 ^ 16);
						elseif (Type == 3) then
							local FlatIdent_8B523 = 0;
							while true do
								if (FlatIdent_8B523 == 0) then
									Inst[3] = gBits32() - (2 ^ 16);
									Inst[4] = gBits16();
									break;
								end
							end
						end
						if (gBit(Mask, 1, 1) == 1) then
							Inst[2] = Consts[Inst[2]];
						end
						if (gBit(Mask, 2, 2) == 1) then
							Inst[3] = Consts[Inst[3]];
						end
						if (gBit(Mask, 3, 3) == 1) then
							Inst[4] = Consts[Inst[4]];
						end
						Instrs[Idx] = Inst;
					end
					break;
				end
			end
		end
		for Idx = 1, gBits32() do
			Functions[Idx - 1] = Deserialize();
		end
		return Chunk;
	end
	local function Wrap(Chunk, Upvalues, Env)
		local Instr = Chunk[1];
		local Proto = Chunk[2];
		local Params = Chunk[3];
		return function(...)
			local Instr = Instr;
			local Proto = Proto;
			local Params = Params;
			local _R = _R;
			local VIP = 1;
			local Top = -1;
			local Vararg = {};
			local Args = {...};
			local PCount = Select("#", ...) - 1;
			local Lupvals = {};
			local Stk = {};
			for Idx = 0, PCount do
				if (Idx >= Params) then
					Vararg[Idx - Params] = Args[Idx + 1];
				else
					Stk[Idx] = Args[Idx + 1];
				end
			end
			local Varargsz = (PCount - Params) + 1;
			local Inst;
			local Enum;
			while true do
				Inst = Instr[VIP];
				Enum = Inst[1];
				if (Enum <= 19) then
					if (Enum <= 9) then
						if (Enum <= 4) then
							if (Enum <= 1) then
								if (Enum > 0) then
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								else
									Stk[Inst[2]] = Inst[3];
								end
							elseif (Enum <= 2) then
								Stk[Inst[2]]();
							elseif (Enum > 3) then
								local A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
							else
								Stk[Inst[2]] = Stk[Inst[3]];
							end
						elseif (Enum <= 6) then
							if (Enum > 5) then
								local A = Inst[2];
								local T = Stk[A];
								for Idx = A + 1, Inst[3] do
									Insert(T, Stk[Idx]);
								end
							else
								local FlatIdent_5477B = 0;
								local A;
								while true do
									if (FlatIdent_5477B == 6) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										VIP = Inst[3];
										break;
									end
									if (FlatIdent_5477B == 0) then
										A = nil;
										Stk[Inst[2]] = {};
										VIP = VIP + 1;
										FlatIdent_5477B = 1;
									end
									if (FlatIdent_5477B == 4) then
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A](Stk[A + 1]);
										FlatIdent_5477B = 5;
									end
									if (FlatIdent_5477B == 1) then
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										FlatIdent_5477B = 2;
									end
									if (FlatIdent_5477B == 2) then
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										FlatIdent_5477B = 3;
									end
									if (5 == FlatIdent_5477B) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										FlatIdent_5477B = 6;
									end
									if (FlatIdent_5477B == 3) then
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										FlatIdent_5477B = 4;
									end
								end
							end
						elseif (Enum <= 7) then
							local FlatIdent_45D37 = 0;
							local A;
							while true do
								if (FlatIdent_45D37 == 0) then
									A = Inst[2];
									Stk[A](Stk[A + 1]);
									break;
								end
							end
						elseif (Enum == 8) then
							local A;
							Stk[Inst[2]] = {};
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A](Stk[A + 1]);
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = {};
						else
							local Edx;
							local Results, Limit;
							local B;
							local A;
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							B = Stk[Inst[3]];
							Stk[A + 1] = B;
							Stk[A] = B[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3] ~= 0;
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
							Top = (Limit + A) - 1;
							Edx = 0;
							for Idx = A, Top do
								Edx = Edx + 1;
								Stk[Idx] = Results[Edx];
							end
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]]();
							VIP = VIP + 1;
							Inst = Instr[VIP];
							do
								return;
							end
						end
					elseif (Enum <= 14) then
						if (Enum <= 11) then
							if (Enum > 10) then
								local A = Inst[2];
								local Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
								Top = (Limit + A) - 1;
								local Edx = 0;
								for Idx = A, Top do
									local FlatIdent_5ED46 = 0;
									while true do
										if (FlatIdent_5ED46 == 0) then
											Edx = Edx + 1;
											Stk[Idx] = Results[Edx];
											break;
										end
									end
								end
							else
								local FlatIdent_61585 = 0;
								while true do
									if (FlatIdent_61585 == 1) then
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_61585 = 2;
									end
									if (FlatIdent_61585 == 2) then
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_61585 = 3;
									end
									if (FlatIdent_61585 == 3) then
										Stk[Inst[2]]();
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_61585 = 4;
									end
									if (FlatIdent_61585 == 4) then
										do
											return;
										end
										break;
									end
									if (FlatIdent_61585 == 0) then
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_61585 = 1;
									end
								end
							end
						elseif (Enum <= 12) then
							Stk[Inst[2]] = Inst[3] ~= 0;
						elseif (Enum == 13) then
							VIP = Inst[3];
						else
							local Edx;
							local Results, Limit;
							local B;
							local A;
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							B = Stk[Inst[3]];
							Stk[A + 1] = B;
							Stk[A] = B[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
							Top = (Limit + A) - 1;
							Edx = 0;
							for Idx = A, Top do
								Edx = Edx + 1;
								Stk[Idx] = Results[Edx];
							end
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]]();
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							VIP = Inst[3];
						end
					elseif (Enum <= 16) then
						if (Enum == 15) then
							local FlatIdent_6053C = 0;
							local A;
							while true do
								if (FlatIdent_6053C == 5) then
									Stk[Inst[2]] = Env[Inst[3]];
									break;
								end
								if (FlatIdent_6053C == 2) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = {};
									FlatIdent_6053C = 3;
								end
								if (FlatIdent_6053C == 3) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									FlatIdent_6053C = 4;
								end
								if (FlatIdent_6053C == 0) then
									A = nil;
									Stk[Inst[2]] = {};
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									FlatIdent_6053C = 1;
								end
								if (FlatIdent_6053C == 1) then
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									FlatIdent_6053C = 2;
								end
								if (FlatIdent_6053C == 4) then
									Stk[A] = Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_6053C = 5;
								end
							end
						else
							Stk[Inst[2]] = Env[Inst[3]];
						end
					elseif (Enum <= 17) then
						for Idx = Inst[2], Inst[3] do
							Stk[Idx] = nil;
						end
					elseif (Enum > 18) then
						local FlatIdent_1CA5D = 0;
						while true do
							if (FlatIdent_1CA5D == 0) then
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_1CA5D = 1;
							end
							if (FlatIdent_1CA5D == 4) then
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_1CA5D = 5;
							end
							if (FlatIdent_1CA5D == 2) then
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_1CA5D = 3;
							end
							if (FlatIdent_1CA5D == 5) then
								Stk[Inst[2]][Inst[3]] = Inst[4];
								break;
							end
							if (FlatIdent_1CA5D == 1) then
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_1CA5D = 2;
							end
							if (FlatIdent_1CA5D == 3) then
								Stk[Inst[2]] = {};
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_1CA5D = 4;
							end
						end
					else
						local A = Inst[2];
						Stk[A] = Stk[A](Stk[A + 1]);
					end
				elseif (Enum <= 29) then
					if (Enum <= 24) then
						if (Enum <= 21) then
							if (Enum == 20) then
								local FlatIdent_81225 = 0;
								local A;
								while true do
									if (FlatIdent_81225 == 0) then
										A = Inst[2];
										Stk[A](Unpack(Stk, A + 1, Inst[3]));
										break;
									end
								end
							else
								Stk[Inst[2]][Inst[3]] = Inst[4];
							end
						elseif (Enum <= 22) then
							if (Inst[2] == Stk[Inst[4]]) then
								VIP = VIP + 1;
							else
								VIP = Inst[3];
							end
						elseif (Enum > 23) then
							local FlatIdent_68856 = 0;
							local A;
							while true do
								if (FlatIdent_68856 == 0) then
									A = nil;
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									FlatIdent_68856 = 1;
								end
								if (FlatIdent_68856 == 6) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									break;
								end
								if (4 == FlatIdent_68856) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									FlatIdent_68856 = 5;
								end
								if (FlatIdent_68856 == 2) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									FlatIdent_68856 = 3;
								end
								if (FlatIdent_68856 == 1) then
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									FlatIdent_68856 = 2;
								end
								if (FlatIdent_68856 == 5) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = {};
									FlatIdent_68856 = 6;
								end
								if (FlatIdent_68856 == 3) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									FlatIdent_68856 = 4;
								end
							end
						else
							local FlatIdent_12544 = 0;
							local A;
							local B;
							while true do
								if (FlatIdent_12544 == 0) then
									A = Inst[2];
									B = Stk[Inst[3]];
									FlatIdent_12544 = 1;
								end
								if (FlatIdent_12544 == 1) then
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									break;
								end
							end
						end
					elseif (Enum <= 26) then
						if (Enum > 25) then
							Stk[Inst[2]] = Wrap(Proto[Inst[3]], nil, Env);
						else
							local B;
							local A;
							A = Inst[2];
							B = Stk[Inst[3]];
							Stk[A + 1] = B;
							Stk[A] = B[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							B = Stk[Inst[3]];
							Stk[A + 1] = B;
							Stk[A] = B[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A](Stk[A + 1]);
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A](Stk[A + 1]);
							VIP = VIP + 1;
							Inst = Instr[VIP];
							VIP = Inst[3];
						end
					elseif (Enum <= 27) then
						local FlatIdent_74348 = 0;
						local A;
						while true do
							if (FlatIdent_74348 == 0) then
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								break;
							end
						end
					elseif (Enum == 28) then
						do
							return;
						end
					else
						local B;
						local T;
						local A;
						Stk[Inst[2]] = Stk[Inst[3]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Env[Inst[3]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Stk[Inst[3]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = {};
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Inst[3];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						A = Inst[2];
						T = Stk[A];
						B = Inst[3];
						for Idx = 1, B do
							T[Idx] = Stk[A + Idx];
						end
					end
				elseif (Enum <= 34) then
					if (Enum <= 31) then
						if (Enum == 30) then
							local A;
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
						elseif (Stk[Inst[2]] == Inst[4]) then
							VIP = VIP + 1;
						else
							VIP = Inst[3];
						end
					elseif (Enum <= 32) then
						Stk[Inst[2]] = {};
					elseif (Enum == 33) then
						local FlatIdent_5D802 = 0;
						local Edx;
						local Results;
						local Limit;
						local B;
						local A;
						while true do
							if (FlatIdent_5D802 == 3) then
								Top = (Limit + A) - 1;
								Edx = 0;
								for Idx = A, Top do
									local FlatIdent_3B868 = 0;
									while true do
										if (FlatIdent_3B868 == 0) then
											Edx = Edx + 1;
											Stk[Idx] = Results[Edx];
											break;
										end
									end
								end
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								FlatIdent_5D802 = 4;
							end
							if (1 == FlatIdent_5D802) then
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								FlatIdent_5D802 = 2;
							end
							if (FlatIdent_5D802 == 6) then
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_5D802 = 7;
							end
							if (FlatIdent_5D802 == 0) then
								Edx = nil;
								Results, Limit = nil;
								B = nil;
								A = nil;
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								FlatIdent_5D802 = 1;
							end
							if (FlatIdent_5D802 == 5) then
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_5D802 = 6;
							end
							if (FlatIdent_5D802 == 7) then
								Stk[Inst[2]] = Inst[3];
								break;
							end
							if (FlatIdent_5D802 == 2) then
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
								FlatIdent_5D802 = 3;
							end
							if (FlatIdent_5D802 == 4) then
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]]();
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_5D802 = 5;
							end
						end
					else
						Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
					end
				elseif (Enum <= 36) then
					if (Enum == 35) then
						local FlatIdent_D14D = 0;
						local A;
						while true do
							if (FlatIdent_D14D == 3) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								FlatIdent_D14D = 4;
							end
							if (0 == FlatIdent_D14D) then
								A = nil;
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_D14D = 1;
							end
							if (2 == FlatIdent_D14D) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								FlatIdent_D14D = 3;
							end
							if (FlatIdent_D14D == 5) then
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								break;
							end
							if (FlatIdent_D14D == 1) then
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								FlatIdent_D14D = 2;
							end
							if (FlatIdent_D14D == 4) then
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A](Stk[A + 1]);
								VIP = VIP + 1;
								FlatIdent_D14D = 5;
							end
						end
					else
						Stk[Inst[2]] = {};
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = {};
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]][Inst[3]] = Inst[4];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]][Inst[3]] = Inst[4];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = {};
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]][Inst[3]] = Inst[4];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]][Inst[3]] = Inst[4];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]][Inst[3]] = Inst[4];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]][Inst[3]] = Inst[4];
					end
				elseif (Enum <= 37) then
					local A;
					Stk[Inst[2]] = {};
					VIP = VIP + 1;
					Inst = Instr[VIP];
					Stk[Inst[2]][Inst[3]] = Inst[4];
					VIP = VIP + 1;
					Inst = Instr[VIP];
					Stk[Inst[2]][Inst[3]] = Inst[4];
					VIP = VIP + 1;
					Inst = Instr[VIP];
					Stk[Inst[2]][Inst[3]] = Inst[4];
					VIP = VIP + 1;
					Inst = Instr[VIP];
					A = Inst[2];
					Stk[A](Stk[A + 1]);
					VIP = VIP + 1;
					Inst = Instr[VIP];
					Stk[Inst[2]] = Env[Inst[3]];
					VIP = VIP + 1;
					Inst = Instr[VIP];
					Stk[Inst[2]][Inst[3]] = Inst[4];
					VIP = VIP + 1;
					Inst = Instr[VIP];
					Stk[Inst[2]] = Inst[3];
					VIP = VIP + 1;
					Inst = Instr[VIP];
					VIP = Inst[3];
				elseif (Enum == 38) then
					Env[Inst[3]] = Stk[Inst[2]];
				else
					local A = Inst[2];
					local T = Stk[A];
					local B = Inst[3];
					for Idx = 1, B do
						T[Idx] = Stk[A + Idx];
					end
				end
				VIP = VIP + 1;
			end
		end;
	end
	return Wrap(Deserialize(), {}, vmenv)(...);
end
return VMCall("LOL!4B3O00028O00027O0040026O00F03F03083O006175746F46697368026O000840030A3O004D616B654E6F7469666903053O005469746C6503093O00576F726C642048756203043O005465787403273O004C6F6164696E6720536372697074203A20556C74696D61746520546F77657220446566656E736503043O0054696D65026O00244003023O005F472O01030A3O004D616B6557696E646F772O033O0048756203093O00574F524C442048554203093O00416E696D6174696F6E03103O006279203A206E68E1BAAD74206D696E682O033O004B657903093O004B657953797374656D030A3O004B65792053797374656D030B3O004465736372697074696F6E03273O004B65792046722O6520446973636F72643A20646973636F72642E2O672F70734538455561396B6703073O004B65794C696E6B03153O00646973636F72642E2O672F70734538455561396B6703043O004B657973030F3O00776F726C645F39313834373430313403063O004E6F74696669030D3O004E6F74696669636174696F6E73030A3O00436F2O726563744B657903153O0052752O6E696E6720746865205363726970743O2E030C3O00496E636F2O726563746B657903143O00546865206B657920697320696E636F2O72656374030B3O00436F70794B65794C696E6B03133O00436F7069656420746F20436C6970626F617264030E3O004D696E696D697A6542752O746F6E03053O00496D61676503183O00726278612O73657469643A2O2F312O37342O37352O37353903043O0053697A65026O00444003053O00436F6C6F7203063O00436F6C6F723303073O0066726F6D52474203063O00436F726E657203063O005374726F6B650100030B3O005374726F6B65436F6C6F72025O00E06F40030B3O004E68E1BAAD74204D696E6803183O0057656C636F6D652053637269707420576F726C6420487562026O001440030A3O00412O6453656374696F6E031D3O00646973636F72642E636F6D2F696E766974652F70734538455561396B6703093O00412O64546F2O676C6503043O004E616D6503093O004175746F204669736803073O0044656661756C7403083O0043612O6C6261636B03093O00412O6442752O746F6E03083O00416E74692041666B030A3O006C6F6164737472696E6703043O0067616D6503073O00482O7470476574034C3O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F4E6861744D696E68564E512F67616D656C6F2O6765722F6D61696E2F6E6861746D696E68647A2E6C7561034A3O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F4E6861744D696E68564E512F67616D656C6F2O6765722F6D61696E2F6E6861746D696E682E6C756103403O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F5245447A4855422F4C69627261727956322F6D61696E2F7265647A4C696203073O004D616B6554616203133O00E289AB20496E666F726D6174696F6E20E289AA030C3O00E289AB204D61696E20E289AA030C3O00E289AB204D69736320E289AA026O00104003123O0066622E636F6D2F6E6861746D696E68766E7A030D3O00574F524B494E47203A20E29C8503123O004F776E65723A204E68E1BAAD74204D696E6800C63O00124O00014O0011000100053O00261F3O00170001000200040D3O0017000100122O000600013O00261F0006000B0001000300040D3O000B000100021A00075O001226000700043O00124O00053O00040D3O0017000100261F000600050001000100040D3O00050001001210000700064O002500083O000300302O00080007000800302O00080009000A00302O0008000B000C4O00070002000100122O0007000D3O00302O00070004000E00122O000600033O00044O0005000100261F3O00580001000300040D3O0058000100122O000600013O00261F0006004D0001000100040D3O004D00010012100007000F4O002400083O00024O00093O000200302O00090007001100302O00090012001300102O0008001000094O00093O000600302O00090015000E00302O00090007001600302O00090017001800302O00090019001A2O0020000A00013O00122O000B001C4O0027000A000100010010220009001B000A2O0008000A3O000400302O000A001E000E00302O000A001F002000302O000A0021002200302O000A0023002400102O0009001D000A00102O0008001400094O00070002000100122O000700256O00083O00060030150008002600272O0020000900023O00122O000A00293O00122O000B00294O002700090002000100102200080028000900121E0009002B3O00202O00090009002C00122O000A000C3O00122O000B000C3O00122O000C000C6O0009000C000200102O0008002A000900302O0008002D000E00302O0008002E002F00122O0009002B3O00200100090009002C001223000A00313O00122O000B00013O00122O000C00016O0009000C000200102O0008003000094O00070002000100122O000600033O00261F0006001A0001000300040D3O001A0001001210000700064O000500083O000300302O00080007003200302O00080009003300302O0008000B00344O00070002000100124O00023O00044O0058000100040D3O001A000100261F3O00720001003400040D3O00720001001210000600354O0003000700014O0020000800013O00122O000900364O00270008000100012O001B0006000800022O0013000400063O00122O000600376O000700026O00083O000300302O00080038003900302O0008003A002F00021A000900013O0010180008003B00094O0006000800024O000500063O00122O0006003C6O000700026O00083O000200302O00080038003D00021A000900023O0010220008003B00092O001400060008000100040D3O00C5000100261F3O00920001000100040D3O0092000100122O000600013O00261F000600860001000100040D3O008600010012100007003E3O0012210008003F3O00202O00080008004000122O000A00416O0008000A6O00073O00024O00070001000100122O0007003E3O00122O0008003F3O00202O00080008004000122O000A00424O000B0008000A4O000400073O00022O000200070001000100122O000600033O00261F000600750001000300040D3O007500010012100007003E3O00120E0008003F3O00202O00080008004000122O000A00436O0008000A6O00073O00024O00070001000100124O00033O00044O0092000100040D3O0075000100261F3O00A40001000500040D3O00A40001001210000600444O000F00073O000100302O0007003800454O0006000200024O000100063O00122O000600446O00073O000100302O0007003800464O0006000200024O000200063O00122O000600444O002000073O00010030150007003800472O00120006000200022O0003000300063O00124O00483O00261F3O00020001004800040D3O0002000100122O000600013O000E16000300B20001000600040D3O00B20001001210000700354O0003000800014O0020000900013O00122O000A00494O00270009000100012O001B0007000900022O0003000400073O00124O00343O00040D3O0002000100261F000600A70001000100040D3O00A70001001210000700354O0003000800014O0020000900013O00122O000A004A4O00270009000100012O001B0007000900022O001D000400073O00122O000700356O000800016O000900013O00122O000A004B6O0009000100012O001B0007000900022O0003000400073O00122O000600033O00040D3O00A7000100040D3O000200012O001C3O00013O00033O000D3O0003023O005F4703083O006175746F466973682O0103043O0067616D65030A3O004765745365727669636503113O005265706C69636174656453746F7261676503073O004D6F64756C6573030A3O00476C6F62616C496E6974030C3O0052656D6F74654576656E7473030F3O00506C61796572436174636846697368030A3O004669726553657276657203043O0077616974029O00133O0012103O00013O0020015O000200261F3O00120001000300040D3O001200010012103O00043O0020195O000500122O000200068O0002000200206O000700206O000800206O000900206O000A00206O000B6O0002000100124O000C3O00122O0001000D8O0002000100046O00012O001C3O00017O00023O0003023O005F4703083O006175746F4669736801053O00120A000100013O00102O000100023O00122O000100026O0001000100016O00017O00043O00030A3O006C6F6164737472696E6703043O0067616D6503073O00482O747047657403473O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F4E6861744D696E68564E512F772D6875622F6D61696E2F416E746925323041666B2E6C756100093O0012093O00013O00122O000100023O00202O00010001000300122O000300046O000400016O000100049O0000026O000100016O00017O00", GetFEnv(), ...);