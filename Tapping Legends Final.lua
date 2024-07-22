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
			local FlatIdent_95CAC = 0;
			local a;
			while true do
				if (FlatIdent_95CAC == 0) then
					a = Char(StrToNumber(byte, 16));
					if repeatNext then
						local b = Rep(a, repeatNext);
						repeatNext = nil;
						return b;
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
			local FlatIdent_76979 = 0;
			local Res;
			while true do
				if (FlatIdent_76979 == 0) then
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
		local a = Byte(ByteString, DIP, DIP);
		DIP = DIP + 1;
		return a;
	end
	local function gBits16()
		local a, b = Byte(ByteString, DIP, DIP + 2);
		DIP = DIP + 2;
		return (b * 256) + a;
	end
	local function gBits32()
		local FlatIdent_69270 = 0;
		local a;
		local b;
		local c;
		local d;
		while true do
			if (FlatIdent_69270 == 1) then
				return (d * 16777216) + (c * 65536) + (b * 256) + a;
			end
			if (FlatIdent_69270 == 0) then
				a, b, c, d = Byte(ByteString, DIP, DIP + 3);
				DIP = DIP + 4;
				FlatIdent_69270 = 1;
			end
		end
	end
	local function gFloat()
		local FlatIdent_7126B = 0;
		local Left;
		local Right;
		local IsNormal;
		local Mantissa;
		local Exponent;
		local Sign;
		while true do
			if (FlatIdent_7126B == 3) then
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
			if (FlatIdent_7126B == 1) then
				IsNormal = 1;
				Mantissa = (gBit(Right, 1, 20) * (2 ^ 32)) + Left;
				FlatIdent_7126B = 2;
			end
			if (0 == FlatIdent_7126B) then
				Left = gBits32();
				Right = gBits32();
				FlatIdent_7126B = 1;
			end
			if (FlatIdent_7126B == 2) then
				Exponent = gBit(Right, 21, 31);
				Sign = ((gBit(Right, 32) == 1) and -1) or 1;
				FlatIdent_7126B = 3;
			end
		end
	end
	local function gString(Len)
		local FlatIdent_7126A = 0;
		local Str;
		local FStr;
		while true do
			if (FlatIdent_7126A == 1) then
				Str = Sub(ByteString, DIP, (DIP + Len) - 1);
				DIP = DIP + Len;
				FlatIdent_7126A = 2;
			end
			if (FlatIdent_7126A == 3) then
				return Concat(FStr);
			end
			if (FlatIdent_7126A == 0) then
				Str = nil;
				if not Len then
					local FlatIdent_44839 = 0;
					while true do
						if (FlatIdent_44839 == 0) then
							Len = gBits32();
							if (Len == 0) then
								return "";
							end
							break;
						end
					end
				end
				FlatIdent_7126A = 1;
			end
			if (FlatIdent_7126A == 2) then
				FStr = {};
				for Idx = 1, #Str do
					FStr[Idx] = Char(Byte(Sub(Str, Idx, Idx)));
				end
				FlatIdent_7126A = 3;
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
			local FlatIdent_1076E = 0;
			local Descriptor;
			while true do
				if (FlatIdent_1076E == 0) then
					Descriptor = gBits8();
					if (gBit(Descriptor, 1, 1) == 0) then
						local Type = gBit(Descriptor, 2, 3);
						local Mask = gBit(Descriptor, 4, 6);
						local Inst = {gBits16(),gBits16(),nil,nil};
						if (Type == 0) then
							local FlatIdent_89562 = 0;
							while true do
								if (FlatIdent_89562 == 0) then
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
				if (Enum <= 20) then
					if (Enum <= 9) then
						if (Enum <= 4) then
							if (Enum <= 1) then
								if (Enum > 0) then
									local A = Inst[2];
									Stk[A](Stk[A + 1]);
								elseif (Stk[Inst[2]] == Inst[4]) then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							elseif (Enum <= 2) then
								local FlatIdent_30F75 = 0;
								local A;
								while true do
									if (FlatIdent_30F75 == 2) then
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										FlatIdent_30F75 = 3;
									end
									if (8 == FlatIdent_30F75) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										FlatIdent_30F75 = 9;
									end
									if (FlatIdent_30F75 == 6) then
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										FlatIdent_30F75 = 7;
									end
									if (FlatIdent_30F75 == 4) then
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										FlatIdent_30F75 = 5;
									end
									if (FlatIdent_30F75 == 9) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = {};
										break;
									end
									if (FlatIdent_30F75 == 7) then
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A](Stk[A + 1]);
										FlatIdent_30F75 = 8;
									end
									if (FlatIdent_30F75 == 3) then
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										FlatIdent_30F75 = 4;
									end
									if (0 == FlatIdent_30F75) then
										A = nil;
										Stk[Inst[2]] = {};
										VIP = VIP + 1;
										FlatIdent_30F75 = 1;
									end
									if (FlatIdent_30F75 == 1) then
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										FlatIdent_30F75 = 2;
									end
									if (FlatIdent_30F75 == 5) then
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										FlatIdent_30F75 = 6;
									end
								end
							elseif (Enum == 3) then
								Env[Inst[3]] = Stk[Inst[2]];
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
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								VIP = Inst[3];
							end
						elseif (Enum <= 6) then
							if (Enum > 5) then
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
								local A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
							end
						elseif (Enum <= 7) then
							local FlatIdent_C460 = 0;
							local A;
							local B;
							while true do
								if (FlatIdent_C460 == 0) then
									A = Inst[2];
									B = Stk[Inst[3]];
									FlatIdent_C460 = 1;
								end
								if (FlatIdent_C460 == 1) then
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									break;
								end
							end
						elseif (Enum > 8) then
							if (Inst[2] == Stk[Inst[4]]) then
								VIP = VIP + 1;
							else
								VIP = Inst[3];
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
					elseif (Enum <= 14) then
						if (Enum <= 11) then
							if (Enum == 10) then
								local FlatIdent_7F35E = 0;
								local A;
								while true do
									if (FlatIdent_7F35E == 5) then
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										FlatIdent_7F35E = 6;
									end
									if (FlatIdent_7F35E == 0) then
										A = nil;
										Stk[Inst[2]] = {};
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_7F35E = 1;
									end
									if (FlatIdent_7F35E == 3) then
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A](Stk[A + 1]);
										VIP = VIP + 1;
										FlatIdent_7F35E = 4;
									end
									if (FlatIdent_7F35E == 2) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										FlatIdent_7F35E = 3;
									end
									if (FlatIdent_7F35E == 4) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_7F35E = 5;
									end
									if (1 == FlatIdent_7F35E) then
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										FlatIdent_7F35E = 2;
									end
									if (FlatIdent_7F35E == 6) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										VIP = Inst[3];
										break;
									end
								end
							else
								do
									return;
								end
							end
						elseif (Enum <= 12) then
							local FlatIdent_7A75F = 0;
							local B;
							local A;
							while true do
								if (FlatIdent_7A75F == 9) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									VIP = Inst[3];
									break;
								end
								if (8 == FlatIdent_7A75F) then
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Stk[A + 1]);
									FlatIdent_7A75F = 9;
								end
								if (FlatIdent_7A75F == 0) then
									B = nil;
									A = nil;
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									FlatIdent_7A75F = 1;
								end
								if (FlatIdent_7A75F == 3) then
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									FlatIdent_7A75F = 4;
								end
								if (FlatIdent_7A75F == 6) then
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Stk[A + 1]);
									FlatIdent_7A75F = 7;
								end
								if (FlatIdent_7A75F == 1) then
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									FlatIdent_7A75F = 2;
								end
								if (FlatIdent_7A75F == 2) then
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_7A75F = 3;
								end
								if (FlatIdent_7A75F == 5) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									FlatIdent_7A75F = 6;
								end
								if (FlatIdent_7A75F == 7) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_7A75F = 8;
								end
								if (FlatIdent_7A75F == 4) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									FlatIdent_7A75F = 5;
								end
							end
						elseif (Enum == 13) then
							local A = Inst[2];
							local T = Stk[A];
							for Idx = A + 1, Inst[3] do
								Insert(T, Stk[Idx]);
							end
						else
							Stk[Inst[2]] = Env[Inst[3]];
						end
					elseif (Enum <= 17) then
						if (Enum <= 15) then
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
						elseif (Enum > 16) then
							local FlatIdent_64E40 = 0;
							while true do
								if (FlatIdent_64E40 == 4) then
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_64E40 = 5;
								end
								if (FlatIdent_64E40 == 1) then
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_64E40 = 2;
								end
								if (FlatIdent_64E40 == 3) then
									Stk[Inst[2]] = {};
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_64E40 = 4;
								end
								if (FlatIdent_64E40 == 2) then
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_64E40 = 3;
								end
								if (5 == FlatIdent_64E40) then
									Stk[Inst[2]][Inst[3]] = Inst[4];
									break;
								end
								if (FlatIdent_64E40 == 0) then
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_64E40 = 1;
								end
							end
						else
							Stk[Inst[2]] = Stk[Inst[3]];
						end
					elseif (Enum <= 18) then
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
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]][Inst[3]] = Inst[4];
					elseif (Enum == 19) then
						Stk[Inst[2]] = Wrap(Proto[Inst[3]], nil, Env);
					else
						local FlatIdent_5477B = 0;
						local Edx;
						local Results;
						local Limit;
						local B;
						local A;
						while true do
							if (FlatIdent_5477B == 2) then
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								FlatIdent_5477B = 3;
							end
							if (FlatIdent_5477B == 0) then
								Edx = nil;
								Results, Limit = nil;
								B = nil;
								A = nil;
								FlatIdent_5477B = 1;
							end
							if (FlatIdent_5477B == 10) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								break;
							end
							if (FlatIdent_5477B == 3) then
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_5477B = 4;
							end
							if (FlatIdent_5477B == 4) then
								A = Inst[2];
								Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
								Top = (Limit + A) - 1;
								Edx = 0;
								FlatIdent_5477B = 5;
							end
							if (FlatIdent_5477B == 6) then
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]]();
								FlatIdent_5477B = 7;
							end
							if (FlatIdent_5477B == 1) then
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								FlatIdent_5477B = 2;
							end
							if (FlatIdent_5477B == 8) then
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_5477B = 9;
							end
							if (5 == FlatIdent_5477B) then
								for Idx = A, Top do
									local FlatIdent_70003 = 0;
									while true do
										if (FlatIdent_70003 == 0) then
											Edx = Edx + 1;
											Stk[Idx] = Results[Edx];
											break;
										end
									end
								end
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								FlatIdent_5477B = 6;
							end
							if (7 == FlatIdent_5477B) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								FlatIdent_5477B = 8;
							end
							if (FlatIdent_5477B == 9) then
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								FlatIdent_5477B = 10;
							end
						end
					end
				elseif (Enum <= 31) then
					if (Enum <= 25) then
						if (Enum <= 22) then
							if (Enum == 21) then
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							else
								VIP = Inst[3];
							end
						elseif (Enum <= 23) then
							local FlatIdent_322B4 = 0;
							local A;
							while true do
								if (FlatIdent_322B4 == 1) then
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									FlatIdent_322B4 = 2;
								end
								if (FlatIdent_322B4 == 2) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = {};
									FlatIdent_322B4 = 3;
								end
								if (FlatIdent_322B4 == 0) then
									A = nil;
									Stk[Inst[2]] = {};
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									FlatIdent_322B4 = 1;
								end
								if (FlatIdent_322B4 == 5) then
									Stk[Inst[2]] = Inst[3];
									break;
								end
								if (3 == FlatIdent_322B4) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									FlatIdent_322B4 = 4;
								end
								if (FlatIdent_322B4 == 4) then
									Stk[A] = Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_322B4 = 5;
								end
							end
						elseif (Enum == 24) then
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
							Stk[Inst[2]] = {};
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A](Unpack(Stk, A + 1, Inst[3]));
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
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							VIP = Inst[3];
						end
					elseif (Enum <= 28) then
						if (Enum <= 26) then
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
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							VIP = Inst[3];
						elseif (Enum == 27) then
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
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							VIP = Inst[3];
						else
							local FlatIdent_3CF01 = 0;
							local A;
							while true do
								if (FlatIdent_3CF01 == 5) then
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									FlatIdent_3CF01 = 6;
								end
								if (FlatIdent_3CF01 == 0) then
									A = nil;
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_3CF01 = 1;
								end
								if (FlatIdent_3CF01 == 3) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_3CF01 = 4;
								end
								if (FlatIdent_3CF01 == 4) then
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_3CF01 = 5;
								end
								if (FlatIdent_3CF01 == 6) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									FlatIdent_3CF01 = 7;
								end
								if (FlatIdent_3CF01 == 2) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									FlatIdent_3CF01 = 3;
								end
								if (FlatIdent_3CF01 == 7) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									break;
								end
								if (FlatIdent_3CF01 == 1) then
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									FlatIdent_3CF01 = 2;
								end
							end
						end
					elseif (Enum <= 29) then
						local A = Inst[2];
						Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
					elseif (Enum > 30) then
						local A = Inst[2];
						local T = Stk[A];
						local B = Inst[3];
						for Idx = 1, B do
							T[Idx] = Stk[A + Idx];
						end
					else
						Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
					end
				elseif (Enum <= 36) then
					if (Enum <= 33) then
						if (Enum > 32) then
							local FlatIdent_8ABD6 = 0;
							local B;
							local A;
							while true do
								if (FlatIdent_8ABD6 == 5) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									FlatIdent_8ABD6 = 6;
								end
								if (FlatIdent_8ABD6 == 6) then
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									FlatIdent_8ABD6 = 7;
								end
								if (FlatIdent_8ABD6 == 3) then
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									FlatIdent_8ABD6 = 4;
								end
								if (FlatIdent_8ABD6 == 9) then
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_8ABD6 = 10;
								end
								if (FlatIdent_8ABD6 == 1) then
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									FlatIdent_8ABD6 = 2;
								end
								if (FlatIdent_8ABD6 == 0) then
									B = nil;
									A = nil;
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									FlatIdent_8ABD6 = 1;
								end
								if (FlatIdent_8ABD6 == 8) then
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									FlatIdent_8ABD6 = 9;
								end
								if (FlatIdent_8ABD6 == 7) then
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_8ABD6 = 8;
								end
								if (FlatIdent_8ABD6 == 10) then
									VIP = Inst[3];
									break;
								end
								if (FlatIdent_8ABD6 == 4) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									FlatIdent_8ABD6 = 5;
								end
								if (FlatIdent_8ABD6 == 2) then
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_8ABD6 = 3;
								end
							end
						else
							Stk[Inst[2]] = {};
						end
					elseif (Enum <= 34) then
						for Idx = Inst[2], Inst[3] do
							Stk[Idx] = nil;
						end
					elseif (Enum == 35) then
						local FlatIdent_437D4 = 0;
						local A;
						while true do
							if (FlatIdent_437D4 == 0) then
								A = Inst[2];
								Stk[A](Unpack(Stk, A + 1, Inst[3]));
								break;
							end
						end
					else
						Stk[Inst[2]] = Inst[3];
					end
				elseif (Enum <= 39) then
					if (Enum <= 37) then
						Stk[Inst[2]]();
					elseif (Enum == 38) then
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
							local FlatIdent_94BA0 = 0;
							while true do
								if (0 == FlatIdent_94BA0) then
									Edx = Edx + 1;
									Stk[Idx] = Results[Edx];
									break;
								end
							end
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
					else
						local FlatIdent_6D68E = 0;
						local A;
						while true do
							if (FlatIdent_6D68E == 0) then
								A = Inst[2];
								Stk[A] = Stk[A](Stk[A + 1]);
								break;
							end
						end
					end
				elseif (Enum <= 40) then
					Stk[Inst[2]][Inst[3]] = Inst[4];
				elseif (Enum == 41) then
					local FlatIdent_61AEE = 0;
					local A;
					local Results;
					local Limit;
					local Edx;
					while true do
						if (FlatIdent_61AEE == 1) then
							Top = (Limit + A) - 1;
							Edx = 0;
							FlatIdent_61AEE = 2;
						end
						if (FlatIdent_61AEE == 2) then
							for Idx = A, Top do
								Edx = Edx + 1;
								Stk[Idx] = Results[Edx];
							end
							break;
						end
						if (FlatIdent_61AEE == 0) then
							A = Inst[2];
							Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
							FlatIdent_61AEE = 1;
						end
					end
				else
					local FlatIdent_4A248 = 0;
					local A;
					while true do
						if (FlatIdent_4A248 == 3) then
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							VIP = VIP + 1;
							FlatIdent_4A248 = 4;
						end
						if (FlatIdent_4A248 == 4) then
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A](Stk[A + 1]);
							VIP = VIP + 1;
							FlatIdent_4A248 = 5;
						end
						if (FlatIdent_4A248 == 2) then
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							FlatIdent_4A248 = 3;
						end
						if (FlatIdent_4A248 == 1) then
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							FlatIdent_4A248 = 2;
						end
						if (0 == FlatIdent_4A248) then
							A = nil;
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							FlatIdent_4A248 = 1;
						end
						if (5 == FlatIdent_4A248) then
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							FlatIdent_4A248 = 6;
						end
						if (FlatIdent_4A248 == 6) then
							VIP = Inst[3];
							break;
						end
					end
				end
				VIP = VIP + 1;
			end
		end;
	end
	return Wrap(Deserialize(), {}, vmenv)(...);
end
return VMCall("LOL!523O00028O00027O0040026O00F03F03023O005F47030B3O006175746F526562697274682O01026O000840030A3O004D616B654E6F7469666903053O005469746C6503093O00576F726C642048756203043O005465787403263O004C6F6164696E6720536372697074203A2054612O70696E67204C6567656E64732046696E616C03043O0054696D65026O00244003073O006175746F546170026O00204003093O00412O64546F2O676C6503043O004E616D65030F3O004175746F204571756970204265737403073O0044656661756C74010003083O0043612O6C6261636B03103O004175746F204461696C79204368657374026O00144003073O004D616B6554616203133O00E289AB20496E666F726D6174696F6E20E289AA030C3O00E289AB204D61696E20E289AA030C3O00E289AB204D69736320E289AA026O001840030A3O006C6F6164737472696E6703043O0067616D6503073O00482O747047657403403O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F5245447A4855422F4C69627261727956322F6D61696E2F7265647A4C6962034C3O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F4E6861744D696E68564E512F67616D656C6F2O6765722F6D61696E2F6E6861746D696E68647A2E6C7561034A3O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F4E6861744D696E68564E512F67616D656C6F2O6765722F6D61696E2F6E6861746D696E682E6C756103093O00657175697042657374030E3O006175746F4461696C794368657374026O001040030A3O00412O6453656374696F6E030D3O00574F524B494E47203A20E29C8503123O004F776E65723A204E68E1BAAD74204D696E6803123O0066622E636F6D2F6E6861746D696E68766E7A026O001C40030B3O004E68E1BAAD74204D696E6803183O0057656C636F6D652053637269707420576F726C6420487562030A3O004D616B6557696E646F772O033O0048756203093O00574F524C442048554203093O00416E696D6174696F6E03103O006279203A206E68E1BAAD74206D696E682O033O004B657903093O004B657953797374656D030A3O004B65792053797374656D030B3O004465736372697074696F6E03393O0053637269707473204E6F7420576F726B696E672C204A6F696E20446973636F7264203A20646973636F72642E2O672F70734538455561396B6703073O004B65794C696E6B03123O0053637269707473204E6F74204F70656E656403043O004B657973030E3O0061646D696E2D6E6861746D696E6803063O004E6F74696669030D3O004E6F74696669636174696F6E73030A3O00436F2O726563744B657903153O0052752O6E696E6720746865205363726970743O2E030C3O00496E636F2O726563746B657903143O00546865206B657920697320696E636F2O72656374030B3O00436F70794B65794C696E6B03133O00436F7069656420746F20436C6970626F617264030E3O004D696E696D697A6542752O746F6E03053O00496D61676503183O00726278612O73657469643A2O2F312O37342O37352O37353903043O0053697A65026O00444003053O00436F6C6F7203063O00436F6C6F723303073O0066726F6D52474203063O00436F726E657203063O005374726F6B65030B3O005374726F6B65436F6C6F72025O00E06F40030C3O004175746F2052656269727468031D3O00646973636F72642E636F6D2F696E766974652F70734538455561396B6703083O004175746F2054617000FF3O0012243O00014O0022000100053O00264O0017000100020004163O00170001001224000600013O000E090003000B000100060004163O000B000100120E000700043O0030280007000500060012243O00073O0004163O0017000100262O00060005000100010004163O0005000100120E000700084O000A00083O000300302O00080009000A00302O0008000B000C00302O0008000D000E4O00070002000100122O000700043O00302O0007000F000600122O000600033O00044O0005000100264O002C000100100004163O002C000100120E000600114O0010000700034O002000083O000300302800080012001300302800080014001500021300095O0010120008001600094O0006000800024O000500063O00122O000600116O000700036O00083O000300302O00080012001700302O000800140015000213000900013O00101E0008001600092O001D0006000800022O0010000500063O0004163O00FE000100264O0046000100180004163O00460001001224000600013O00262O0006003C000100010004163O003C000100120E000700194O001700083O000100302O00080012001A4O0007000200024O000100073O00122O000700196O00083O000100302O00080012001B4O0007000200024O000200073O00122O000600033O00262O0006002F000100030004163O002F000100120E000700194O001A00083O000100302O00080012001C4O0007000200024O000300073O00124O001D3O00044O004600010004163O002F000100264O0066000100010004163O00660001001224000600013O00262O00060054000100030004163O0054000100120E0007001E3O0012260008001F3O00202O00080008002000122O000A00216O0008000A6O00073O00024O00070001000100124O00033O00044O00660001000E0900010049000100060004163O0049000100120E0007001E3O0012140008001F3O00202O00080008002000122O000A00226O0008000A6O00073O00024O00070001000100122O0007001E3O00122O0008001F3O00202O00080008002000122O000A00234O00290008000A4O000500073O00022O0025000700010001001224000600033O0004163O0049000100264O006F000100070004163O006F000100120E000600043O00302800060024000600120E000600043O003028000600250006000213000600023O0012030006000F3O0012243O00263O00264O008F0001001D0004163O008F0001001224000600013O00262O00060083000100010004163O0083000100120E000700274O0010000800014O0020000900013O001224000A00284O001F0009000100012O001D0007000900022O000F000400073O00122O000700276O000800016O000900013O00122O000A00296O0009000100012O001D0007000900022O0010000400073O001224000600033O00262O00060072000100030004163O0072000100120E000700274O0010000800014O0020000900013O001224000A002A4O001F0009000100012O001D0007000900022O0010000400073O0012243O002B3O0004163O008F00010004163O0072000100264O00D0000100030004163O00D00001001224000600013O00262O0006009C000100030004163O009C000100120E000700084O001900083O000300302O00080009002C00302O0008000B002D00302O0008000D00184O00070002000100124O00023O00044O00D0000100262O00060092000100010004163O0092000100120E0007002E4O000800083O00024O00093O000200302O00090009003000302O00090031003200102O0008002F00094O00093O000600302O00090034001500302O00090009003500302O00090036003700302O0009003800392O0020000A00013O001224000B003B4O001F000A0001000100101E0009003A000A2O0002000A3O000400302O000A003D000600302O000A003E003F00302O000A0040004100302O000A0042004300102O0009003C000A00102O0008003300094O00070002000100122O000700446O00083O00060030280008004500462O0020000900023O001224000A00483O001224000B00484O001F00090002000100101E00080047000900121C0009004A3O00202O00090009004B00122O000A000E3O00122O000B000E3O00122O000C000E6O0009000C000200102O00080049000900302O0008004C000600302O0008004D001500122O0009004A3O00201500090009004B00122A000A004F3O00122O000B00013O00122O000C00016O0009000C000200102O0008004E00094O00070002000100122O000600033O00044O0092000100264O00F40001002B0004163O00F40001001224000600013O00262O000600E0000100030004163O00E0000100120E000700114O0010000800024O002000093O0003003028000900120050003028000900140015000213000A00033O00101B00090016000A4O0007000900024O000500073O00124O00103O00044O00F4000100262O000600D3000100010004163O00D3000100120E000700274O0010000800014O0020000900013O001224000A00514O001F0009000100012O001D0007000900022O0011000400073O00122O000700116O000800026O00093O000300302O00090012005200302O000900140015000213000A00043O00101B00090016000A4O0007000900024O000500073O00122O000600033O00044O00D3000100264O0002000100260004163O00020001000213000600053O001203000600053O000213000600063O001203000600243O000213000600073O001203000600253O0012243O00183O0004163O000200012O000B3O00013O00083O00033O00028O0003023O005F4703093O00657175697042657374010A3O001224000100013O00262O00010001000100010004163O0001000100120E000200023O00101E000200033O00120E000200034O00250002000100010004163O000900010004163O000100012O000B3O00017O00033O00028O0003023O005F47030E3O006175746F4461696C794368657374010A3O001224000100013O00262O00010001000100010004163O0001000100120E000200023O00101E000200033O00120E000200034O00250002000100010004163O000900010004163O000100012O000B3O00017O000D3O0003023O005F4703073O006175746F5461702O01028O0003043O0067616D65030A3O004765745365727669636503113O005265706C69636174656453746F72616765030D3O002O5347204672616D65776F726B03063O0053686172656403073O004E6574776F726B2O033O00746170030A3O004669726553657276657203043O007761697400183O00120E3O00013O0020155O000200264O0017000100030004163O001700010012243O00043O00264O0005000100040004163O0005000100120E000100053O00200600010001000600122O000300076O00010003000200202O00010001000800202O00010001000900202O00010001000A00202O00010001000B00202O00010001000C4O00010002000100122O0001000D3O00122O000200046O00010002000100046O00010004163O000500010004165O00012O000B3O00017O00033O00028O0003023O005F47030B3O006175746F5265626972746801103O001224000100014O0022000200023O00262O00010002000100010004163O00020001001224000200013O000E0900010005000100020004163O0005000100120E000300023O00101E000300033O00120E000300034O00250003000100010004163O000F00010004163O000500010004163O000F00010004163O000200012O000B3O00017O00033O00028O0003023O005F4703073O006175746F54617001103O001224000100014O0022000200023O00262O00010002000100010004163O00020001001224000200013O000E0900010005000100020004163O0005000100120E000300023O00101E000300033O00120E000300034O00250003000100010004163O000F00010004163O000500010004163O000F00010004163O000200012O000B3O00017O000D3O0003023O005F47030B3O006175746F526562697274682O01028O0003043O0067616D65030A3O004765745365727669636503113O005265706C69636174656453746F72616765030D3O002O5347204672616D65776F726B03063O0053686172656403073O004E6574776F726B03073O0072656269727468030C3O00496E766F6B6553657276657203043O007761697400183O00120E3O00013O0020155O000200264O0017000100030004163O001700010012243O00043O000E090004000500013O0004163O0005000100120E000100053O00200600010001000600122O000300076O00010003000200202O00010001000800202O00010001000900202O00010001000A00202O00010001000B00202O00010001000C4O00010002000100122O0001000D3O00122O000200046O00010002000100046O00010004163O000500010004165O00012O000B3O00017O000F3O0003023O005F4703093O006571756970426573742O01028O0003043O0067616D65030A3O004765745365727669636503113O005265706C69636174656453746F72616765030D3O002O5347204672616D65776F726B03063O0053686172656403073O004E6574776F726B2O033O00706574030C3O00496E766F6B6553657276657203063O00416374696F6E030A3O004571756970204265737403043O0077616974001A3O00120E3O00013O0020155O000200264O0019000100030004163O001900010012243O00043O00264O0005000100040004163O0005000100120E000100053O00201800010001000600122O000300076O00010003000200202O00010001000800202O00010001000900202O00010001000A00202O00010001000B00202O00010001000C4O00033O000100302O0003000D000E4O00010003000100122O0001000F3O00122O000200046O00010002000100046O00010004163O000500010004165O00012O000B3O00017O000E3O0003023O005F47030E3O006175746F4461696C7943686573742O01028O0003043O0067616D65030A3O004765745365727669636503113O005265706C69636174656453746F72616765030D3O002O5347204672616D65776F726B03063O0053686172656403073O004E6574776F726B030B3O006461696C79206368657374030C3O00496E766F6B65536572766572030B3O00537061776E20436865737403043O007761697400193O00120E3O00013O0020155O000200264O0018000100030004163O001800010012243O00043O000E090004000500013O0004163O0005000100120E000100053O00202100010001000600122O000300076O00010003000200202O00010001000800202O00010001000900202O00010001000A00202O00010001000B00202O00010001000C00122O0003000D6O00010003000100122O0001000E3O00122O000200046O00010002000100046O00010004163O000500010004165O00012O000B3O00017O00", GetFEnv(), ...);