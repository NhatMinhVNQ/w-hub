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
			repeatNext = StrToNumber(Sub(byte, 1, 1));
			return "";
		else
			local FlatIdent_7126A = 0;
			local a;
			while true do
				if (FlatIdent_7126A == 0) then
					a = Char(StrToNumber(byte, 16));
					if repeatNext then
						local FlatIdent_12703 = 0;
						local b;
						while true do
							if (FlatIdent_12703 == 0) then
								b = Rep(a, repeatNext);
								repeatNext = nil;
								FlatIdent_12703 = 1;
							end
							if (FlatIdent_12703 == 1) then
								return b;
							end
						end
					else
						return a;
					end
					break;
				end
			end
		end
	end);
	local function gBit(Bit, Start, End)
		if End then
			local FlatIdent_475BC = 0;
			local Res;
			while true do
				if (FlatIdent_475BC == 0) then
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
		local FlatIdent_60EA1 = 0;
		local a;
		while true do
			if (FlatIdent_60EA1 == 1) then
				return a;
			end
			if (FlatIdent_60EA1 == 0) then
				a = Byte(ByteString, DIP, DIP);
				DIP = DIP + 1;
				FlatIdent_60EA1 = 1;
			end
		end
	end
	local function gBits16()
		local a, b = Byte(ByteString, DIP, DIP + 2);
		DIP = DIP + 2;
		return (b * 256) + a;
	end
	local function gBits32()
		local a, b, c, d = Byte(ByteString, DIP, DIP + 3);
		DIP = DIP + 4;
		return (d * 16777216) + (c * 65536) + (b * 256) + a;
	end
	local function gFloat()
		local FlatIdent_8F047 = 0;
		local Left;
		local Right;
		local IsNormal;
		local Mantissa;
		local Exponent;
		local Sign;
		while true do
			if (2 == FlatIdent_8F047) then
				Exponent = gBit(Right, 21, 31);
				Sign = ((gBit(Right, 32) == 1) and -1) or 1;
				FlatIdent_8F047 = 3;
			end
			if (FlatIdent_8F047 == 1) then
				IsNormal = 1;
				Mantissa = (gBit(Right, 1, 20) * (2 ^ 32)) + Left;
				FlatIdent_8F047 = 2;
			end
			if (FlatIdent_8F047 == 3) then
				if (Exponent == 0) then
					if (Mantissa == 0) then
						return Sign * 0;
					else
						Exponent = 1;
						IsNormal = 0;
					end
				elseif (Exponent == 2047) then
					return ((Mantissa == 0) and (Sign * (1 / 0))) or (Sign * NaN);
				end
				return LDExp(Sign, Exponent - 1023) * (IsNormal + (Mantissa / (2 ^ 52)));
			end
			if (FlatIdent_8F047 == 0) then
				Left = gBits32();
				Right = gBits32();
				FlatIdent_8F047 = 1;
			end
		end
	end
	local function gString(Len)
		local FlatIdent_7F35E = 0;
		local Str;
		local FStr;
		while true do
			if (1 == FlatIdent_7F35E) then
				Str = Sub(ByteString, DIP, (DIP + Len) - 1);
				DIP = DIP + Len;
				FlatIdent_7F35E = 2;
			end
			if (FlatIdent_7F35E == 0) then
				Str = nil;
				if not Len then
					Len = gBits32();
					if (Len == 0) then
						return "";
					end
				end
				FlatIdent_7F35E = 1;
			end
			if (3 == FlatIdent_7F35E) then
				return Concat(FStr);
			end
			if (FlatIdent_7F35E == 2) then
				FStr = {};
				for Idx = 1, #Str do
					FStr[Idx] = Char(Byte(Sub(Str, Idx, Idx)));
				end
				FlatIdent_7F35E = 3;
			end
		end
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
			local Descriptor = gBits8();
			if (gBit(Descriptor, 1, 1) == 0) then
				local Type = gBit(Descriptor, 2, 3);
				local Mask = gBit(Descriptor, 4, 6);
				local Inst = {gBits16(),gBits16(),nil,nil};
				if (Type == 0) then
					Inst[3] = gBits16();
					Inst[4] = gBits16();
				elseif (Type == 1) then
					Inst[3] = gBits32();
				elseif (Type == 2) then
					Inst[3] = gBits32() - (2 ^ 16);
				elseif (Type == 3) then
					Inst[3] = gBits32() - (2 ^ 16);
					Inst[4] = gBits16();
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
				if (Enum <= 18) then
					if (Enum <= 8) then
						if (Enum <= 3) then
							if (Enum <= 1) then
								if (Enum == 0) then
									local A = Inst[2];
									local T = Stk[A];
									for Idx = A + 1, Inst[3] do
										Insert(T, Stk[Idx]);
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
							elseif (Enum == 2) then
								for Idx = Inst[2], Inst[3] do
									Stk[Idx] = nil;
								end
							else
								Stk[Inst[2]] = Wrap(Proto[Inst[3]], nil, Env);
							end
						elseif (Enum <= 5) then
							if (Enum == 4) then
								Stk[Inst[2]] = Env[Inst[3]];
							else
								local A;
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
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
								Stk[Inst[2]][Inst[3]] = Inst[4];
							end
						elseif (Enum <= 6) then
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
						elseif (Enum > 7) then
							Stk[Inst[2]] = Inst[3] ~= 0;
						else
							local FlatIdent_2AC68 = 0;
							local A;
							local T;
							local B;
							while true do
								if (FlatIdent_2AC68 == 0) then
									A = Inst[2];
									T = Stk[A];
									FlatIdent_2AC68 = 1;
								end
								if (FlatIdent_2AC68 == 1) then
									B = Inst[3];
									for Idx = 1, B do
										T[Idx] = Stk[A + Idx];
									end
									break;
								end
							end
						end
					elseif (Enum <= 13) then
						if (Enum <= 10) then
							if (Enum > 9) then
								local FlatIdent_33EA4 = 0;
								local A;
								local Results;
								local Limit;
								local Edx;
								while true do
									if (FlatIdent_33EA4 == 0) then
										A = Inst[2];
										Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
										FlatIdent_33EA4 = 1;
									end
									if (FlatIdent_33EA4 == 2) then
										for Idx = A, Top do
											Edx = Edx + 1;
											Stk[Idx] = Results[Edx];
										end
										break;
									end
									if (FlatIdent_33EA4 == 1) then
										Top = (Limit + A) - 1;
										Edx = 0;
										FlatIdent_33EA4 = 2;
									end
								end
							else
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							end
						elseif (Enum <= 11) then
							Stk[Inst[2]] = Stk[Inst[3]];
						elseif (Enum > 12) then
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
						else
							Env[Inst[3]] = Stk[Inst[2]];
						end
					elseif (Enum <= 15) then
						if (Enum == 14) then
							VIP = Inst[3];
						else
							local A = Inst[2];
							Stk[A](Stk[A + 1]);
						end
					elseif (Enum <= 16) then
						Stk[Inst[2]][Inst[3]] = Inst[4];
					elseif (Enum > 17) then
						local Edx;
						local Results, Limit;
						local B;
						local A;
						A = Inst[2];
						Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]]();
						VIP = VIP + 1;
						Inst = Instr[VIP];
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
					else
						local A = Inst[2];
						Stk[A] = Stk[A](Stk[A + 1]);
					end
				elseif (Enum <= 28) then
					if (Enum <= 23) then
						if (Enum <= 20) then
							if (Enum == 19) then
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
							else
								local FlatIdent_8DCA9 = 0;
								local A;
								while true do
									if (FlatIdent_8DCA9 == 4) then
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										FlatIdent_8DCA9 = 5;
									end
									if (FlatIdent_8DCA9 == 2) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										FlatIdent_8DCA9 = 3;
									end
									if (FlatIdent_8DCA9 == 0) then
										A = nil;
										Stk[Inst[2]] = {};
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_8DCA9 = 1;
									end
									if (FlatIdent_8DCA9 == 5) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A](Stk[A + 1]);
										FlatIdent_8DCA9 = 6;
									end
									if (FlatIdent_8DCA9 == 3) then
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_8DCA9 = 4;
									end
									if (FlatIdent_8DCA9 == 7) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = {};
										break;
									end
									if (FlatIdent_8DCA9 == 6) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										FlatIdent_8DCA9 = 7;
									end
									if (FlatIdent_8DCA9 == 1) then
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										FlatIdent_8DCA9 = 2;
									end
								end
							end
						elseif (Enum <= 21) then
							if (Stk[Inst[2]] == Inst[4]) then
								VIP = VIP + 1;
							else
								VIP = Inst[3];
							end
						elseif (Enum == 22) then
							local A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
						else
							local A = Inst[2];
							Stk[A](Unpack(Stk, A + 1, Inst[3]));
						end
					elseif (Enum <= 25) then
						if (Enum == 24) then
							local A;
							Stk[Inst[2]] = {};
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Stk[A + 1]);
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = {};
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Stk[A + 1]);
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
						else
							do
								return;
							end
						end
					elseif (Enum <= 26) then
						local FlatIdent_75B50 = 0;
						local A;
						while true do
							if (FlatIdent_75B50 == 5) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								FlatIdent_75B50 = 6;
							end
							if (FlatIdent_75B50 == 6) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								VIP = Inst[3];
								break;
							end
							if (0 == FlatIdent_75B50) then
								A = nil;
								Stk[Inst[2]] = {};
								VIP = VIP + 1;
								FlatIdent_75B50 = 1;
							end
							if (3 == FlatIdent_75B50) then
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								FlatIdent_75B50 = 4;
							end
							if (FlatIdent_75B50 == 2) then
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								FlatIdent_75B50 = 3;
							end
							if (FlatIdent_75B50 == 4) then
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A](Stk[A + 1]);
								FlatIdent_75B50 = 5;
							end
							if (FlatIdent_75B50 == 1) then
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								FlatIdent_75B50 = 2;
							end
						end
					elseif (Enum == 27) then
						local FlatIdent_98388 = 0;
						local A;
						while true do
							if (FlatIdent_98388 == 0) then
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								break;
							end
						end
					else
						Stk[Inst[2]] = {};
					end
				elseif (Enum <= 33) then
					if (Enum <= 30) then
						if (Enum > 29) then
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
						else
							local FlatIdent_5F1CB = 0;
							while true do
								if (FlatIdent_5F1CB == 2) then
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_5F1CB = 3;
								end
								if (FlatIdent_5F1CB == 4) then
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_5F1CB = 5;
								end
								if (FlatIdent_5F1CB == 0) then
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_5F1CB = 1;
								end
								if (1 == FlatIdent_5F1CB) then
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_5F1CB = 2;
								end
								if (FlatIdent_5F1CB == 5) then
									Stk[Inst[2]][Inst[3]] = Inst[4];
									break;
								end
								if (FlatIdent_5F1CB == 3) then
									Stk[Inst[2]] = {};
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_5F1CB = 4;
								end
							end
						end
					elseif (Enum <= 31) then
						local FlatIdent_494F6 = 0;
						while true do
							if (FlatIdent_494F6 == 4) then
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_494F6 = 5;
							end
							if (FlatIdent_494F6 == 6) then
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_494F6 = 7;
							end
							if (FlatIdent_494F6 == 5) then
								Stk[Inst[2]] = {};
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_494F6 = 6;
							end
							if (FlatIdent_494F6 == 7) then
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_494F6 = 8;
							end
							if (FlatIdent_494F6 == 0) then
								Stk[Inst[2]] = {};
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_494F6 = 1;
							end
							if (FlatIdent_494F6 == 8) then
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_494F6 = 9;
							end
							if (FlatIdent_494F6 == 1) then
								Stk[Inst[2]] = {};
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_494F6 = 2;
							end
							if (FlatIdent_494F6 == 9) then
								Stk[Inst[2]][Inst[3]] = Inst[4];
								break;
							end
							if (FlatIdent_494F6 == 3) then
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_494F6 = 4;
							end
							if (FlatIdent_494F6 == 2) then
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_494F6 = 3;
							end
						end
					elseif (Enum == 32) then
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
					elseif (Inst[2] == Stk[Inst[4]]) then
						VIP = VIP + 1;
					else
						VIP = Inst[3];
					end
				elseif (Enum <= 35) then
					if (Enum == 34) then
						local FlatIdent_628E3 = 0;
						local A;
						while true do
							if (FlatIdent_628E3 == 6) then
								Stk[A](Stk[A + 1]);
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_628E3 = 7;
							end
							if (FlatIdent_628E3 == 7) then
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_628E3 = 8;
							end
							if (FlatIdent_628E3 == 0) then
								A = nil;
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								FlatIdent_628E3 = 1;
							end
							if (FlatIdent_628E3 == 8) then
								VIP = Inst[3];
								break;
							end
							if (FlatIdent_628E3 == 4) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								FlatIdent_628E3 = 5;
							end
							if (1 == FlatIdent_628E3) then
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								FlatIdent_628E3 = 2;
							end
							if (3 == FlatIdent_628E3) then
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								FlatIdent_628E3 = 4;
							end
							if (FlatIdent_628E3 == 2) then
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								FlatIdent_628E3 = 3;
							end
							if (FlatIdent_628E3 == 5) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								FlatIdent_628E3 = 6;
							end
						end
					else
						Stk[Inst[2]] = Inst[3];
					end
				elseif (Enum <= 36) then
					local A = Inst[2];
					local B = Stk[Inst[3]];
					Stk[A + 1] = B;
					Stk[A] = B[Inst[4]];
				elseif (Enum > 37) then
					Stk[Inst[2]]();
				else
					Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
				end
				VIP = VIP + 1;
			end
		end;
	end
	return Wrap(Deserialize(), {}, vmenv)(...);
end
return VMCall("LOL!4B3O00028O00027O0040030A3O004D616B654E6F7469666903053O005469746C6503093O00576F726C642048756203043O005465787403273O004C6F6164696E6720536372697074203A20556C74696D61746520546F77657220446566656E736503043O0054696D65026O00244003023O005F4703083O006175746F466973682O01026O00F03F026O000840030B3O004E68E1BAAD74204D696E6803183O0057656C636F6D652053637269707420576F726C6420487562026O001440030A3O004D616B6557696E646F772O033O0048756203093O00574F524C442048554203093O00416E696D6174696F6E03103O006279203A206E68E1BAAD74206D696E682O033O004B657903093O004B657953797374656D0100030A3O004B65792053797374656D030B3O004465736372697074696F6E034O0003073O004B65794C696E6B03213O00682O7470733A2O2F6C2O6F742D6C696E6B2E636F6D2F733F62343638363762352003043O004B65797303133O007468616E6B2D757365722D736372697074732003063O004E6F74696669030D3O004E6F74696669636174696F6E73030A3O00436F2O726563744B657903153O0052752O6E696E6720746865205363726970743O2E030C3O00496E636F2O726563746B657903143O00546865206B657920697320696E636F2O72656374030B3O00436F70794B65794C696E6B03133O00436F7069656420746F20436C6970626F617264030E3O004D696E696D697A6542752O746F6E03053O00496D61676503183O00726278612O73657469643A2O2F312O37342O37352O37353903043O0053697A65026O00444003053O00436F6C6F7203063O00436F6C6F723303073O0066726F6D52474203063O00436F726E657203063O005374726F6B65030B3O005374726F6B65436F6C6F72025O00E06F40030A3O00412O6453656374696F6E031D3O00646973636F72642E636F6D2F696E766974652F70734538455561396B6703093O00412O64546F2O676C6503043O004E616D6503093O004175746F204669736803073O0044656661756C7403083O0043612O6C6261636B03093O00412O6442752O746F6E03083O00416E74692041666B030A3O006C6F6164737472696E6703043O0067616D6503073O00482O7470476574034C3O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F4E6861744D696E68564E512F67616D656C6F2O6765722F6D61696E2F6E6861746D696E68647A2E6C7561034A3O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F4E6861744D696E68564E512F67616D656C6F2O6765722F6D61696E2F6E6861746D696E682E6C756103403O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F5245447A4855422F4C69627261727956322F6D61696E2F7265647A4C696203073O004D616B6554616203133O00E289AB20496E666F726D6174696F6E20E289AA030C3O00E289AB204D61696E20E289AA030C3O00E289AB204D69736320E289AA026O001040030D3O00574F524B494E47203A20E29C8503123O004F776E65723A204E68E1BAAD74204D696E6803123O0066622E636F6D2F6E6861746D696E68766E7A00BE3O0012233O00014O0002000100053O0026153O00170001000200040E3O00170001001223000600013O000E21000100100001000600040E3O00100001001204000700034O000600083O000300302O00080004000500302O00080006000700302O0008000800094O00070002000100122O0007000A3O00302O0007000B000C00122O0006000D3O002615000600050001000D00040E3O0005000100020300075O00120C0007000B3O0012233O000E3O00040E3O0017000100040E3O000500010026153O00580001000D00040E3O00580001001223000600013O002615000600240001000D00040E3O00240001001204000700034O001A00083O000300302O00080004000F00302O00080006001000302O0008000800114O00070002000100124O00023O00044O005800010026150006001A0001000100040E3O001A0001001204000700124O001F00083O00024O00093O000200302O00090004001400302O00090015001600102O0008001300094O00093O000600302O00090018001900302O00090004001A00302O0009001B001C00302O0009001D001E2O001C000A00013O001223000B00204O0007000A000100010010090009001F000A2O0014000A3O000400302O000A0022000C00302O000A0023002400302O000A0025002600302O000A0027002800102O00090021000A00102O0008001700094O00070002000100122O000700296O00083O00060030100008002A002B2O001C000900023O001223000A002D3O001223000B002D4O00070009000200010010090008002C00090012130009002F3O00202O00090009003000122O000A00093O00122O000B00093O00122O000C00096O0009000C000200102O0008002E000900302O00080031000C00302O00080032001900122O0009002F3O002025000900090030001222000A00343O00122O000B00013O00122O000C00016O0009000C000200102O0008003300094O00070002000100122O0006000D3O00044O001A00010026153O00720001001100040E3O00720001001204000600354O000B000700014O001C000800013O001223000900364O00070008000100012O001B0006000800022O001D000400063O00122O000600376O000700026O00083O000300302O00080038003900302O0008003A0019000203000900013O0010050008003B00094O0006000800024O000500063O00122O0006003C6O000700026O00083O000200302O00080038003D000203000900023O0010090008003B00092O001700060008000100040E3O00BD00010026153O008A0001000100040E3O008A00010012040006003E3O00121E0007003F3O00202O00070007004000122O000900416O000700096O00063O00024O00060001000100122O0006003E3O00122O0007003F3O00202O00070007004000122O000900424O000A000700094O001200063O00024O00060001000100122O0006003E3O00122O0007003F3O00202O00070007004000122O000900436O000700096O00063O00024O00060001000100124O000D3O0026153O009C0001000E00040E3O009C0001001204000600444O001800073O000100302O0007003800454O0006000200024O000100063O00122O000600446O00073O000100302O0007003800464O0006000200024O000200063O00122O000600444O001C00073O00010030100007003800472O00110006000200022O000B000300063O0012233O00483O0026153O00020001004800040E3O00020001001223000600013O002615000600B00001000100040E3O00B00001001204000700354O000B000800014O001C000900013O001223000A00494O00070009000100012O001B0007000900022O0001000400073O00122O000700356O000800016O000900013O00122O000A004A6O0009000100012O001B0007000900022O000B000400073O0012230006000D3O0026150006009F0001000D00040E3O009F0001001204000700354O000B000800014O001C000900013O001223000A004B4O00070009000100012O001B0007000900022O000B000400073O0012233O00113O00040E3O0002000100040E3O009F000100040E3O000200012O00193O00013O00033O000D3O0003023O005F4703083O006175746F466973682O01028O0003043O0067616D65030A3O004765745365727669636503113O005265706C69636174656453746F7261676503073O004D6F64756C6573030A3O00476C6F62616C496E6974030C3O0052656D6F74654576656E7473030F3O00506C61796572436174636846697368030A3O004669726553657276657203043O0077616974001E3O0012043O00013O0020255O00020026153O001D0001000300040E3O001D00010012233O00044O0002000100013O0026153O00060001000400040E3O00060001001223000100043O002615000100090001000400040E3O00090001001204000200053O00200D00020002000600122O000400076O00020004000200202O00020002000800202O00020002000900202O00020002000A00202O00020002000B00202O00020002000C4O00020002000100122O0002000D3O00122O000300046O00020002000100046O000100040E3O0009000100040E5O000100040E3O0006000100040E5O00012O00193O00017O00033O00028O0003023O005F4703083O006175746F46697368010A3O001223000100013O002615000100010001000100040E3O00010001001204000200023O001009000200033O001204000200034O002600020001000100040E3O0009000100040E3O000100012O00193O00017O00043O00030A3O006C6F6164737472696E6703043O0067616D6503073O00482O747047657403473O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F4E6861744D696E68564E512F772D6875622F6D61696E2F416E746925323041666B2E6C756100093O0012203O00013O00122O000100023O00202O00010001000300122O000300046O000400016O000100049O0000026O000100016O00017O00", GetFEnv(), ...);
