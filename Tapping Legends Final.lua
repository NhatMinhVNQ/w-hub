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
			local Res = (Bit / (2 ^ (Start - 1))) % (2 ^ (((End - 1) - (Start - 1)) + 1));
			return Res - (Res % 1);
		else
			local FlatIdent_95CAC = 0;
			local Plc;
			while true do
				if (FlatIdent_95CAC == 0) then
					Plc = 2 ^ (Start - 1);
					return (((Bit % (Plc + Plc)) >= Plc) and 1) or 0;
				end
			end
		end
	end
	local function gBits8()
		local FlatIdent_76979 = 0;
		local a;
		while true do
			if (FlatIdent_76979 == 1) then
				return a;
			end
			if (FlatIdent_76979 == 0) then
				a = Byte(ByteString, DIP, DIP);
				DIP = DIP + 1;
				FlatIdent_76979 = 1;
			end
		end
	end
	local function gBits16()
		local a, b = Byte(ByteString, DIP, DIP + 2);
		DIP = DIP + 2;
		return (b * 256) + a;
	end
	local function gBits32()
		local FlatIdent_24A02 = 0;
		local a;
		local b;
		local c;
		local d;
		while true do
			if (FlatIdent_24A02 == 1) then
				return (d * 16777216) + (c * 65536) + (b * 256) + a;
			end
			if (FlatIdent_24A02 == 0) then
				a, b, c, d = Byte(ByteString, DIP, DIP + 3);
				DIP = DIP + 4;
				FlatIdent_24A02 = 1;
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
				Exponent = 1;
				IsNormal = 0;
			end
		elseif (Exponent == 2047) then
			return ((Mantissa == 0) and (Sign * (1 / 0))) or (Sign * NaN);
		end
		return LDExp(Sign, Exponent - 1023) * (IsNormal + (Mantissa / (2 ^ 52)));
	end
	local function gString(Len)
		local Str;
		if not Len then
			local FlatIdent_89ECE = 0;
			while true do
				if (FlatIdent_89ECE == 0) then
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
			local Descriptor = gBits8();
			if (gBit(Descriptor, 1, 1) == 0) then
				local FlatIdent_2661B = 0;
				local Type;
				local Mask;
				local Inst;
				while true do
					if (FlatIdent_2661B == 1) then
						Inst = {gBits16(),gBits16(),nil,nil};
						if (Type == 0) then
							local FlatIdent_39B0 = 0;
							while true do
								if (FlatIdent_39B0 == 0) then
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
						FlatIdent_2661B = 2;
					end
					if (FlatIdent_2661B == 2) then
						if (gBit(Mask, 1, 1) == 1) then
							Inst[2] = Consts[Inst[2]];
						end
						if (gBit(Mask, 2, 2) == 1) then
							Inst[3] = Consts[Inst[3]];
						end
						FlatIdent_2661B = 3;
					end
					if (FlatIdent_2661B == 0) then
						Type = gBit(Descriptor, 2, 3);
						Mask = gBit(Descriptor, 4, 6);
						FlatIdent_2661B = 1;
					end
					if (FlatIdent_2661B == 3) then
						if (gBit(Mask, 3, 3) == 1) then
							Inst[4] = Consts[Inst[4]];
						end
						Instrs[Idx] = Inst;
						break;
					end
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
				local FlatIdent_C460 = 0;
				while true do
					if (FlatIdent_C460 == 0) then
						Inst = Instr[VIP];
						Enum = Inst[1];
						FlatIdent_C460 = 1;
					end
					if (FlatIdent_C460 == 1) then
						if (Enum <= 21) then
							if (Enum <= 10) then
								if (Enum <= 4) then
									if (Enum <= 1) then
										if (Enum == 0) then
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
										else
											Env[Inst[3]] = Stk[Inst[2]];
										end
									elseif (Enum <= 2) then
										local FlatIdent_7F35E = 0;
										local A;
										local T;
										local B;
										while true do
											if (1 == FlatIdent_7F35E) then
												B = Inst[3];
												for Idx = 1, B do
													T[Idx] = Stk[A + Idx];
												end
												break;
											end
											if (FlatIdent_7F35E == 0) then
												A = Inst[2];
												T = Stk[A];
												FlatIdent_7F35E = 1;
											end
										end
									elseif (Enum > 3) then
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
									else
										for Idx = Inst[2], Inst[3] do
											Stk[Idx] = nil;
										end
									end
								elseif (Enum <= 7) then
									if (Enum <= 5) then
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									elseif (Enum == 6) then
										local FlatIdent_455BF = 0;
										local A;
										while true do
											if (FlatIdent_455BF == 0) then
												A = Inst[2];
												Stk[A](Stk[A + 1]);
												break;
											end
										end
									else
										local A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
									end
								elseif (Enum <= 8) then
									local FlatIdent_2FD19 = 0;
									local A;
									while true do
										if (FlatIdent_2FD19 == 3) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											FlatIdent_2FD19 = 4;
										end
										if (FlatIdent_2FD19 == 2) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											FlatIdent_2FD19 = 3;
										end
										if (FlatIdent_2FD19 == 5) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = {};
											FlatIdent_2FD19 = 6;
										end
										if (FlatIdent_2FD19 == 4) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											FlatIdent_2FD19 = 5;
										end
										if (FlatIdent_2FD19 == 0) then
											A = nil;
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											FlatIdent_2FD19 = 1;
										end
										if (FlatIdent_2FD19 == 6) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											break;
										end
										if (FlatIdent_2FD19 == 1) then
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											FlatIdent_2FD19 = 2;
										end
									end
								elseif (Enum == 9) then
									Stk[Inst[2]][Inst[3]] = Inst[4];
								elseif (Inst[2] == Stk[Inst[4]]) then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							elseif (Enum <= 15) then
								if (Enum <= 12) then
									if (Enum == 11) then
										Stk[Inst[2]] = Wrap(Proto[Inst[3]], nil, Env);
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
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
									end
								elseif (Enum <= 13) then
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								elseif (Enum > 14) then
									local A = Inst[2];
									Stk[A](Unpack(Stk, A + 1, Inst[3]));
								else
									Stk[Inst[2]] = {};
								end
							elseif (Enum <= 18) then
								if (Enum <= 16) then
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
								elseif (Enum > 17) then
									do
										return;
									end
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
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
								end
							elseif (Enum <= 19) then
								Stk[Inst[2]]();
							elseif (Enum == 20) then
								local A = Inst[2];
								local B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
							else
								Stk[Inst[2]] = Stk[Inst[3]];
							end
						elseif (Enum <= 32) then
							if (Enum <= 26) then
								if (Enum <= 23) then
									if (Enum == 22) then
										Stk[Inst[2]] = Inst[3] ~= 0;
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
											local FlatIdent_8DCA9 = 0;
											while true do
												if (FlatIdent_8DCA9 == 0) then
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
									end
								elseif (Enum <= 24) then
									local A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								elseif (Enum == 25) then
									local FlatIdent_39EBF = 0;
									local B;
									local A;
									while true do
										if (FlatIdent_39EBF == 5) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_39EBF = 6;
										end
										if (FlatIdent_39EBF == 8) then
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											FlatIdent_39EBF = 9;
										end
										if (10 == FlatIdent_39EBF) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_39EBF = 11;
										end
										if (FlatIdent_39EBF == 3) then
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											FlatIdent_39EBF = 4;
										end
										if (FlatIdent_39EBF == 2) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_39EBF = 3;
										end
										if (11 == FlatIdent_39EBF) then
											Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											Inst = Instr[VIP];
											VIP = Inst[3];
											break;
										end
										if (FlatIdent_39EBF == 9) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_39EBF = 10;
										end
										if (FlatIdent_39EBF == 0) then
											B = nil;
											A = nil;
											A = Inst[2];
											B = Stk[Inst[3]];
											FlatIdent_39EBF = 1;
										end
										if (FlatIdent_39EBF == 1) then
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_39EBF = 2;
										end
										if (FlatIdent_39EBF == 7) then
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											FlatIdent_39EBF = 8;
										end
										if (FlatIdent_39EBF == 4) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											FlatIdent_39EBF = 5;
										end
										if (FlatIdent_39EBF == 6) then
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_39EBF = 7;
										end
									end
								else
									local FlatIdent_28F3E = 0;
									local A;
									while true do
										if (FlatIdent_28F3E == 4) then
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_28F3E = 5;
										end
										if (0 == FlatIdent_28F3E) then
											A = nil;
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_28F3E = 1;
										end
										if (FlatIdent_28F3E == 1) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											FlatIdent_28F3E = 2;
										end
										if (FlatIdent_28F3E == 3) then
											Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_28F3E = 4;
										end
										if (FlatIdent_28F3E == 5) then
											Stk[Inst[2]][Inst[3]] = Inst[4];
											break;
										end
										if (FlatIdent_28F3E == 2) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_28F3E = 3;
										end
									end
								end
							elseif (Enum <= 29) then
								if (Enum <= 27) then
									VIP = Inst[3];
								elseif (Enum == 28) then
									local FlatIdent_19F98 = 0;
									local Edx;
									local Results;
									local Limit;
									local B;
									local A;
									while true do
										if (FlatIdent_19F98 == 6) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
											FlatIdent_19F98 = 7;
										end
										if (FlatIdent_19F98 == 10) then
											Stk[Inst[2]] = Inst[3];
											break;
										end
										if (FlatIdent_19F98 == 9) then
											Inst = Instr[VIP];
											Stk[Inst[2]]();
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_19F98 = 10;
										end
										if (FlatIdent_19F98 == 8) then
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
											VIP = VIP + 1;
											FlatIdent_19F98 = 9;
										end
										if (FlatIdent_19F98 == 7) then
											Top = (Limit + A) - 1;
											Edx = 0;
											for Idx = A, Top do
												Edx = Edx + 1;
												Stk[Idx] = Results[Edx];
											end
											VIP = VIP + 1;
											FlatIdent_19F98 = 8;
										end
										if (FlatIdent_19F98 == 3) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_19F98 = 4;
										end
										if (FlatIdent_19F98 == 4) then
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											FlatIdent_19F98 = 5;
										end
										if (FlatIdent_19F98 == 5) then
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_19F98 = 6;
										end
										if (FlatIdent_19F98 == 1) then
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_19F98 = 2;
										end
										if (0 == FlatIdent_19F98) then
											Edx = nil;
											Results, Limit = nil;
											B = nil;
											A = nil;
											FlatIdent_19F98 = 1;
										end
										if (FlatIdent_19F98 == 2) then
											Stk[Inst[2]]();
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											FlatIdent_19F98 = 3;
										end
									end
								else
									local FlatIdent_284EA = 0;
									local A;
									while true do
										if (1 == FlatIdent_284EA) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											FlatIdent_284EA = 2;
										end
										if (FlatIdent_284EA == 4) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_284EA = 5;
										end
										if (FlatIdent_284EA == 0) then
											A = nil;
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_284EA = 1;
										end
										if (FlatIdent_284EA == 9) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											break;
										end
										if (FlatIdent_284EA == 8) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											FlatIdent_284EA = 9;
										end
										if (7 == FlatIdent_284EA) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											FlatIdent_284EA = 8;
										end
										if (FlatIdent_284EA == 3) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_284EA = 4;
										end
										if (5 == FlatIdent_284EA) then
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											FlatIdent_284EA = 6;
										end
										if (FlatIdent_284EA == 6) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											FlatIdent_284EA = 7;
										end
										if (FlatIdent_284EA == 2) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_284EA = 3;
										end
									end
								end
							elseif (Enum <= 30) then
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
							elseif (Enum == 31) then
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
								local A = Inst[2];
								local Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
								Top = (Limit + A) - 1;
								local Edx = 0;
								for Idx = A, Top do
									Edx = Edx + 1;
									Stk[Idx] = Results[Edx];
								end
							end
						elseif (Enum <= 38) then
							if (Enum <= 35) then
								if (Enum <= 33) then
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
								elseif (Enum == 34) then
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
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
								else
									local FlatIdent_869A9 = 0;
									local B;
									local T;
									local A;
									while true do
										if (FlatIdent_869A9 == 2) then
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_869A9 = 3;
										end
										if (FlatIdent_869A9 == 0) then
											B = nil;
											T = nil;
											A = nil;
											FlatIdent_869A9 = 1;
										end
										if (6 == FlatIdent_869A9) then
											A = Inst[2];
											T = Stk[A];
											B = Inst[3];
											FlatIdent_869A9 = 7;
										end
										if (FlatIdent_869A9 == 1) then
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_869A9 = 2;
										end
										if (FlatIdent_869A9 == 7) then
											for Idx = 1, B do
												T[Idx] = Stk[A + Idx];
											end
											break;
										end
										if (FlatIdent_869A9 == 5) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_869A9 = 6;
										end
										if (FlatIdent_869A9 == 4) then
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_869A9 = 5;
										end
										if (FlatIdent_869A9 == 3) then
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_869A9 = 4;
										end
									end
								end
							elseif (Enum <= 36) then
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
								Stk[Inst[2]] = Inst[3];
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
							elseif (Enum > 37) then
								local A = Inst[2];
								local T = Stk[A];
								for Idx = A + 1, Inst[3] do
									Insert(T, Stk[Idx]);
								end
							else
								Stk[Inst[2]] = Inst[3];
							end
						elseif (Enum <= 41) then
							if (Enum <= 39) then
								if (Stk[Inst[2]] == Inst[4]) then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							elseif (Enum > 40) then
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
								Stk[Inst[2]] = Env[Inst[3]];
							end
						elseif (Enum <= 42) then
							local A = Inst[2];
							Stk[A] = Stk[A](Stk[A + 1]);
						elseif (Enum > 43) then
							local FlatIdent_43337 = 0;
							local A;
							while true do
								if (FlatIdent_43337 == 2) then
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									FlatIdent_43337 = 3;
								end
								if (FlatIdent_43337 == 3) then
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									FlatIdent_43337 = 4;
								end
								if (FlatIdent_43337 == 8) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									FlatIdent_43337 = 9;
								end
								if (FlatIdent_43337 == 1) then
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									FlatIdent_43337 = 2;
								end
								if (FlatIdent_43337 == 4) then
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									FlatIdent_43337 = 5;
								end
								if (FlatIdent_43337 == 7) then
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Stk[A + 1]);
									FlatIdent_43337 = 8;
								end
								if (FlatIdent_43337 == 9) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = {};
									break;
								end
								if (6 == FlatIdent_43337) then
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									FlatIdent_43337 = 7;
								end
								if (FlatIdent_43337 == 0) then
									A = nil;
									Stk[Inst[2]] = {};
									VIP = VIP + 1;
									FlatIdent_43337 = 1;
								end
								if (FlatIdent_43337 == 5) then
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									FlatIdent_43337 = 6;
								end
							end
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
						VIP = VIP + 1;
						break;
					end
				end
			end
		end;
	end
	return Wrap(Deserialize(), {}, vmenv)(...);
end
return VMCall("LOL!543O00028O00027O0040030A3O004D616B654E6F7469666903053O005469746C6503093O00576F726C642048756203043O005465787403263O004C6F6164696E6720536372697074203A2054612O70696E67204C6567656E64732046696E616C03043O0054696D65026O00244003023O005F4703073O006175746F5461702O01030B3O006175746F52656269727468026O000840026O00144003073O004D616B6554616203043O004E616D6503133O00E289AB20496E666F726D6174696F6E20E289AA030C3O00E289AB204D61696E20E289AA030C3O00E289AB204D69736320E289AA026O001840030A3O00412O6453656374696F6E030D3O00574F524B494E47203A20E29C8503123O004F776E65723A204E68E1BAAD74204D696E6803123O0066622E636F6D2F6E6861746D696E68766E7A026O001C40026O00F03F030A3O004D616B6557696E646F772O033O0048756203093O00574F524C442048554203093O00416E696D6174696F6E03103O006279203A206E68E1BAAD74206D696E682O033O004B657903093O004B657953797374656D030A3O004B65792053797374656D030B3O004465736372697074696F6E03273O004B65792046722O6520446973636F72643A20646973636F72642E2O672F70734538455561396B6703073O004B65794C696E6B03153O00646973636F72642E2O672F70734538455561396B6703043O004B657973030F3O00776F726C645F39313834373430313403063O004E6F74696669030D3O004E6F74696669636174696F6E73030A3O00436F2O726563744B657903153O0052752O6E696E6720746865205363726970743O2E030C3O00496E636F2O726563746B657903143O00546865206B657920697320696E636F2O72656374030B3O00436F70794B65794C696E6B03133O00436F7069656420746F20436C6970626F617264030E3O004D696E696D697A6542752O746F6E03053O00496D61676503183O00726278612O73657469643A2O2F312O37342O37352O37353903043O0053697A65026O00444003053O00436F6C6F7203063O00436F6C6F723303073O0066726F6D52474203063O00436F726E657203063O005374726F6B650100030B3O005374726F6B65436F6C6F72025O00E06F40030B3O004E68E1BAAD74204D696E6803183O0057656C636F6D652053637269707420576F726C642048756203093O00657175697042657374030E3O006175746F4461696C794368657374026O001040030A3O006C6F6164737472696E6703043O0067616D6503073O00482O7470476574034C3O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F4E6861744D696E68564E512F67616D656C6F2O6765722F6D61696E2F6E6861746D696E68647A2E6C7561034A3O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F4E6861744D696E68564E512F67616D656C6F2O6765722F6D61696E2F6E6861746D696E682E6C756103403O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F5245447A4855422F4C69627261727956322F6D61696E2F7265647A4C6962026O00204003093O00412O64546F2O676C65030F3O004175746F204571756970204265737403073O0044656661756C7403083O0043612O6C6261636B03103O004175746F204461696C7920436865737403093O00412O6442752O746F6E03083O00416E74692041666B031D3O00646973636F72642E636F6D2F696E766974652F70734538455561396B6703083O004175746F20546170030C3O004175746F205265626972746800D63O0012253O00014O0003000100053O0026273O000F0001000200041B3O000F0001001228000600034O002200073O000300302O00070004000500302O00070006000700302O0007000800094O00060002000100122O0006000A3O00302O0006000B000C00122O0006000A3O00302O0006000D000C00124O000E3O0026273O00210001000F00041B3O00210001001228000600104O002900073O000100302O0007001100124O0006000200024O000100063O00122O000600106O00073O000100302O0007001100134O0006000200024O000200063O00122O000600104O000E00073O00010030090007001100142O002A0006000200022O0015000300063O0012253O00153O000E0A0015003900013O00041B3O00390001001228000600164O0015000700014O000E000800013O001225000900174O00020008000100012O00180006000800024O000400063O00122O000600166O000700016O000800013O00122O000900186O0008000100012O00180006000800024O000400063O00122O000600166O000700016O000800013O00122O000900196O0008000100012O00180006000800022O0015000400063O0012253O001A3O0026273O00720001001B00041B3O007200010012280006001C4O002100073O00024O00083O000200302O00080004001E00302O0008001F002000102O0007001D00084O00083O000600302O00080022000C00302O00080004002300302O00080024002500302O0008002600272O000E000900013O001225000A00294O000200090001000100100D0008002800092O002C00093O000400302O0009002B000C00302O0009002C002D00302O0009002E002F00302O00090030003100102O0008002A000900102O0007002100084O00060002000100122O000600326O00073O00060030090007003300342O000E000800023O001225000900363O001225000A00364O000200080002000100100D00070035000800121D000800383O00202O00080008003900122O000900093O00122O000A00093O00122O000B00096O0008000B000200102O00070037000800302O0007003A000C00302O0007003B003C00122O000800383O00200500080008003900121A0009003E3O00122O000A00013O00122O000B00016O0008000B000200102O0007003D00084O00060002000100122O000600036O00073O000300302O00070004003F00302O00070006004000300900070008000F2O00060006000200010012253O00023O0026273O007B0001000E00041B3O007B00010012280006000A3O00300900060041000C0012280006000A3O00300900060042000C00020B00065O0012010006000B3O0012253O00433O0026273O00930001000100041B3O00930001001228000600443O001217000700453O00202O00070007004600122O000900476O000700096O00063O00024O00060001000100122O000600443O00122O000700453O00202O00070007004600122O000900484O0020000700094O001C00063O00024O00060001000100122O000600443O00122O000700453O00202O00070007004600122O000900496O000700096O00063O00024O00060001000100124O001B3O0026273O009C0001004300041B3O009C000100020B000600013O0012010006000D3O00020B000600023O001201000600413O00020B000600033O001201000600423O0012253O000F3O000E0A004A00B800013O00041B3O00B800010012280006004B4O0015000700034O000E00083O000300300900080011004C0030090008004D003C00020B000900043O0010110008004E00094O0006000800024O000500063O00122O0006004B6O000700036O00083O000300302O00080011004F00302O0008004D003C00020B000900053O0010080008004E00094O0006000800024O000500063O00122O000600506O000700036O00083O000200302O00080011005100020B000900063O00100D0008004E00092O000F00060008000100041B3O00D500010026273O00020001001A00041B3O00020001001228000600164O0015000700014O000E000800013O001225000900524O00020008000100012O00180006000800022O0004000400063O00122O0006004B6O000700026O00083O000300302O00080011005300302O0008004D003C00020B000900073O0010110008004E00094O0006000800024O000500063O00122O0006004B6O000700026O00083O000300302O00080011005400302O0008004D003C00020B000900083O00101E0008004E00094O0006000800024O000500063O00124O004A3O00044O000200012O00123O00013O00093O000D3O0003023O005F4703073O006175746F5461702O01028O0003043O0067616D65030A3O004765745365727669636503113O005265706C69636174656453746F72616765030D3O002O5347204672616D65776F726B03063O0053686172656403073O004E6574776F726B2O033O00746170030A3O004669726553657276657203043O0077616974001E3O0012283O00013O0020055O00020026273O001D0001000300041B3O001D00010012253O00044O0003000100013O0026273O00060001000400041B3O00060001001225000100043O002627000100090001000400041B3O00090001001228000200053O00201900020002000600122O000400076O00020004000200202O00020002000800202O00020002000900202O00020002000A00202O00020002000B00202O00020002000C4O00020002000100122O0002000D3O00122O000300046O00020002000100046O000100041B3O0009000100041B5O000100041B3O0006000100041B5O00012O00123O00017O000D3O0003023O005F47030B3O006175746F526562697274682O0103043O0067616D65030A3O004765745365727669636503113O005265706C69636174656453746F72616765030D3O002O5347204672616D65776F726B03063O0053686172656403073O004E6574776F726B03073O0072656269727468030C3O00496E766F6B6553657276657203043O0077616974029O00133O0012283O00013O0020055O00020026273O00120001000300041B3O001200010012283O00043O0020195O000500122O000200068O0002000200206O000700206O000800206O000900206O000A00206O000B6O0002000100124O000C3O00122O0001000D8O0002000100046O00012O00123O00017O000F3O0003023O005F4703093O006571756970426573742O01028O0003043O0067616D65030A3O004765745365727669636503113O005265706C69636174656453746F72616765030D3O002O5347204672616D65776F726B03063O0053686172656403073O004E6574776F726B2O033O00706574030C3O00496E766F6B6553657276657203063O00416374696F6E030A3O004571756970204265737403043O0077616974001A3O0012283O00013O0020055O00020026273O00190001000300041B3O001900010012253O00043O0026273O00050001000400041B3O00050001001228000100053O00201F00010001000600122O000300076O00010003000200202O00010001000800202O00010001000900202O00010001000A00202O00010001000B00202O00010001000C4O00033O000100302O0003000D000E4O00010003000100122O0001000F3O00122O000200046O00010002000100046O000100041B3O0005000100041B5O00012O00123O00017O000E3O0003023O005F47030E3O006175746F4461696C7943686573742O01028O0003043O0067616D65030A3O004765745365727669636503113O005265706C69636174656453746F72616765030D3O002O5347204672616D65776F726B03063O0053686172656403073O004E6574776F726B030B3O006461696C79206368657374030C3O00496E766F6B65536572766572030B3O00537061776E20436865737403043O0077616974001F3O0012283O00013O0020055O00020026273O001E0001000300041B3O001E00010012253O00044O0003000100013O0026273O00060001000400041B3O00060001001225000100043O002627000100090001000400041B3O00090001001228000200053O00202400020002000600122O000400076O00020004000200202O00020002000800202O00020002000900202O00020002000A00202O00020002000B00202O00020002000C00122O0004000D6O00020004000100122O0002000E3O00122O000300046O00020002000100046O000100041B3O0009000100041B5O000100041B3O0006000100041B5O00012O00123O00017O00033O00028O0003023O005F4703093O0065717569704265737401103O001225000100014O0003000200023O002627000100020001000100041B3O00020001001225000200013O002627000200050001000100041B3O00050001001228000300023O00100D000300033O001228000300034O001300030001000100041B3O000F000100041B3O0005000100041B3O000F000100041B3O000200012O00123O00017O00033O00028O0003023O005F47030E3O006175746F4461696C794368657374010A3O001225000100013O002627000100010001000100041B3O00010001001228000200023O00100D000200033O001228000200034O001300020001000100041B3O0009000100041B3O000100012O00123O00017O00043O00030A3O006C6F6164737472696E6703043O0067616D6503073O00482O747047657403473O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F4E6861744D696E68564E512F772D6875622F6D61696E2F416E746925323041666B2E6C756100093O00122B3O00013O00122O000100023O00202O00010001000300122O000300046O000400016O000100049O0000026O000100016O00017O00033O00028O0003023O005F4703073O006175746F546170010A3O001225000100013O002627000100010001000100041B3O00010001001228000200023O00100D000200033O001228000200034O001300020001000100041B3O0009000100041B3O000100012O00123O00017O00033O00028O0003023O005F47030B3O006175746F5265626972746801103O001225000100014O0003000200023O002627000100020001000100041B3O00020001001225000200013O002627000200050001000100041B3O00050001001228000300023O00100D000300033O001228000300034O001300030001000100041B3O000F000100041B3O0005000100041B3O000F000100041B3O000200012O00123O00017O00", GetFEnv(), ...);