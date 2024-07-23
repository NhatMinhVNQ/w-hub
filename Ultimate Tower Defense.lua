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
			local FlatIdent_45D37 = 0;
			while true do
				if (FlatIdent_45D37 == 0) then
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
			Len = gBits32();
			if (Len == 0) then
				return "";
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
			local FlatIdent_6A091 = 0;
			local Type;
			local Cons;
			while true do
				if (1 == FlatIdent_6A091) then
					if (Type == 1) then
						Cons = gBits8() ~= 0;
					elseif (Type == 2) then
						Cons = gFloat();
					elseif (Type == 3) then
						Cons = gString();
					end
					Consts[Idx] = Cons;
					break;
				end
				if (FlatIdent_6A091 == 0) then
					Type = gBits8();
					Cons = nil;
					FlatIdent_6A091 = 1;
				end
			end
		end
		Chunk[3] = gBits8();
		for Idx = 1, gBits32() do
			local Descriptor = gBits8();
			if (gBit(Descriptor, 1, 1) == 0) then
				local FlatIdent_89ECE = 0;
				local Type;
				local Mask;
				local Inst;
				while true do
					if (FlatIdent_89ECE == 3) then
						if (gBit(Mask, 3, 3) == 1) then
							Inst[4] = Consts[Inst[4]];
						end
						Instrs[Idx] = Inst;
						break;
					end
					if (FlatIdent_89ECE == 2) then
						if (gBit(Mask, 1, 1) == 1) then
							Inst[2] = Consts[Inst[2]];
						end
						if (gBit(Mask, 2, 2) == 1) then
							Inst[3] = Consts[Inst[3]];
						end
						FlatIdent_89ECE = 3;
					end
					if (FlatIdent_89ECE == 1) then
						Inst = {gBits16(),gBits16(),nil,nil};
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
						FlatIdent_89ECE = 2;
					end
					if (FlatIdent_89ECE == 0) then
						Type = gBit(Descriptor, 2, 3);
						Mask = gBit(Descriptor, 4, 6);
						FlatIdent_89ECE = 1;
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
				local FlatIdent_21DDC = 0;
				while true do
					if (FlatIdent_21DDC == 1) then
						if (Enum <= 18) then
							if (Enum <= 8) then
								if (Enum <= 3) then
									if (Enum <= 1) then
										if (Enum > 0) then
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
										else
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										end
									elseif (Enum > 2) then
										local FlatIdent_8199B = 0;
										local Edx;
										local Results;
										local Limit;
										local B;
										local A;
										while true do
											if (FlatIdent_8199B == 7) then
												Top = (Limit + A) - 1;
												Edx = 0;
												for Idx = A, Top do
													local FlatIdent_99389 = 0;
													while true do
														if (FlatIdent_99389 == 0) then
															Edx = Edx + 1;
															Stk[Idx] = Results[Edx];
															break;
														end
													end
												end
												VIP = VIP + 1;
												FlatIdent_8199B = 8;
											end
											if (FlatIdent_8199B == 3) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_8199B = 4;
											end
											if (FlatIdent_8199B == 9) then
												Inst = Instr[VIP];
												Stk[Inst[2]]();
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_8199B = 10;
											end
											if (5 == FlatIdent_8199B) then
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_8199B = 6;
											end
											if (FlatIdent_8199B == 1) then
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_8199B = 2;
											end
											if (6 == FlatIdent_8199B) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
												FlatIdent_8199B = 7;
											end
											if (FlatIdent_8199B == 8) then
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
												VIP = VIP + 1;
												FlatIdent_8199B = 9;
											end
											if (10 == FlatIdent_8199B) then
												Stk[Inst[2]] = Inst[3];
												break;
											end
											if (FlatIdent_8199B == 4) then
												Inst = Instr[VIP];
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												FlatIdent_8199B = 5;
											end
											if (FlatIdent_8199B == 2) then
												Stk[Inst[2]]();
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												FlatIdent_8199B = 3;
											end
											if (FlatIdent_8199B == 0) then
												Edx = nil;
												Results, Limit = nil;
												B = nil;
												A = nil;
												FlatIdent_8199B = 1;
											end
										end
									else
										Stk[Inst[2]][Inst[3]] = Inst[4];
									end
								elseif (Enum <= 5) then
									if (Enum > 4) then
										local FlatIdent_1CA5D = 0;
										local A;
										while true do
											if (FlatIdent_1CA5D == 0) then
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												break;
											end
										end
									else
										local A = Inst[2];
										local T = Stk[A];
										for Idx = A + 1, Inst[3] do
											Insert(T, Stk[Idx]);
										end
									end
								elseif (Enum <= 6) then
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
								elseif (Enum > 7) then
									if (Stk[Inst[2]] == Inst[4]) then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
								else
									for Idx = Inst[2], Inst[3] do
										Stk[Idx] = nil;
									end
								end
							elseif (Enum <= 13) then
								if (Enum <= 10) then
									if (Enum > 9) then
										local FlatIdent_272FB = 0;
										local A;
										local Results;
										local Limit;
										local Edx;
										while true do
											if (FlatIdent_272FB == 2) then
												for Idx = A, Top do
													local FlatIdent_8CEDF = 0;
													while true do
														if (FlatIdent_8CEDF == 0) then
															Edx = Edx + 1;
															Stk[Idx] = Results[Edx];
															break;
														end
													end
												end
												break;
											end
											if (FlatIdent_272FB == 0) then
												A = Inst[2];
												Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
												FlatIdent_272FB = 1;
											end
											if (1 == FlatIdent_272FB) then
												Top = (Limit + A) - 1;
												Edx = 0;
												FlatIdent_272FB = 2;
											end
										end
									else
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									end
								elseif (Enum <= 11) then
									do
										return;
									end
								elseif (Enum > 12) then
									local A = Inst[2];
									local T = Stk[A];
									local B = Inst[3];
									for Idx = 1, B do
										T[Idx] = Stk[A + Idx];
									end
								else
									local FlatIdent_33EA4 = 0;
									local A;
									while true do
										if (FlatIdent_33EA4 == 5) then
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_33EA4 = 6;
										end
										if (FlatIdent_33EA4 == 0) then
											A = nil;
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_33EA4 = 1;
										end
										if (FlatIdent_33EA4 == 4) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_33EA4 = 5;
										end
										if (FlatIdent_33EA4 == 3) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_33EA4 = 4;
										end
										if (FlatIdent_33EA4 == 2) then
											Stk[A] = Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											FlatIdent_33EA4 = 3;
										end
										if (FlatIdent_33EA4 == 1) then
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_33EA4 = 2;
										end
										if (FlatIdent_33EA4 == 6) then
											Stk[A] = Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											FlatIdent_33EA4 = 7;
										end
										if (FlatIdent_33EA4 == 7) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											break;
										end
									end
								end
							elseif (Enum <= 15) then
								if (Enum > 14) then
									local FlatIdent_634AF = 0;
									local B;
									local T;
									local A;
									while true do
										if (FlatIdent_634AF == 4) then
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_634AF = 5;
										end
										if (FlatIdent_634AF == 6) then
											A = Inst[2];
											T = Stk[A];
											B = Inst[3];
											FlatIdent_634AF = 7;
										end
										if (FlatIdent_634AF == 3) then
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_634AF = 4;
										end
										if (7 == FlatIdent_634AF) then
											for Idx = 1, B do
												T[Idx] = Stk[A + Idx];
											end
											break;
										end
										if (FlatIdent_634AF == 5) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_634AF = 6;
										end
										if (FlatIdent_634AF == 1) then
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_634AF = 2;
										end
										if (FlatIdent_634AF == 0) then
											B = nil;
											T = nil;
											A = nil;
											FlatIdent_634AF = 1;
										end
										if (FlatIdent_634AF == 2) then
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_634AF = 3;
										end
									end
								else
									Stk[Inst[2]] = Inst[3];
								end
							elseif (Enum <= 16) then
								Env[Inst[3]] = Stk[Inst[2]];
							elseif (Enum == 17) then
								Stk[Inst[2]] = {};
							elseif (Inst[2] == Stk[Inst[4]]) then
								VIP = VIP + 1;
							else
								VIP = Inst[3];
							end
						elseif (Enum <= 28) then
							if (Enum <= 23) then
								if (Enum <= 20) then
									if (Enum > 19) then
										local A;
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
										A = Inst[2];
										Stk[A](Stk[A + 1]);
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
										Stk[Inst[2]][Inst[3]] = Inst[4];
									else
										local FlatIdent_44603 = 0;
										local A;
										local B;
										while true do
											if (FlatIdent_44603 == 0) then
												A = Inst[2];
												B = Stk[Inst[3]];
												FlatIdent_44603 = 1;
											end
											if (FlatIdent_44603 == 1) then
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												break;
											end
										end
									end
								elseif (Enum <= 21) then
									Stk[Inst[2]] = Env[Inst[3]];
								elseif (Enum > 22) then
									local FlatIdent_82923 = 0;
									local A;
									while true do
										if (FlatIdent_82923 == 0) then
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
											break;
										end
									end
								else
									local FlatIdent_52551 = 0;
									local A;
									while true do
										if (FlatIdent_52551 == 1) then
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_52551 = 2;
										end
										if (5 == FlatIdent_52551) then
											Stk[Inst[2]][Inst[3]] = Inst[4];
											break;
										end
										if (FlatIdent_52551 == 0) then
											A = nil;
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_52551 = 1;
										end
										if (4 == FlatIdent_52551) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_52551 = 5;
										end
										if (FlatIdent_52551 == 2) then
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											FlatIdent_52551 = 3;
										end
										if (FlatIdent_52551 == 3) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_52551 = 4;
										end
									end
								end
							elseif (Enum <= 25) then
								if (Enum > 24) then
									local A = Inst[2];
									Stk[A](Stk[A + 1]);
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
							elseif (Enum <= 26) then
								Stk[Inst[2]] = Stk[Inst[3]];
							elseif (Enum > 27) then
								local FlatIdent_61EE = 0;
								local A;
								while true do
									if (FlatIdent_61EE == 2) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										FlatIdent_61EE = 3;
									end
									if (FlatIdent_61EE == 5) then
										Stk[Inst[2]][Inst[3]] = Inst[4];
										break;
									end
									if (FlatIdent_61EE == 4) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_61EE = 5;
									end
									if (FlatIdent_61EE == 0) then
										A = nil;
										Stk[Inst[2]] = {};
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_61EE = 1;
									end
									if (FlatIdent_61EE == 1) then
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										FlatIdent_61EE = 2;
									end
									if (3 == FlatIdent_61EE) then
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A](Stk[A + 1]);
										VIP = VIP + 1;
										FlatIdent_61EE = 4;
									end
								end
							else
								VIP = Inst[3];
							end
						elseif (Enum <= 33) then
							if (Enum <= 30) then
								if (Enum == 29) then
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
								else
									local FlatIdent_77478 = 0;
									local Edx;
									local Results;
									local Limit;
									local B;
									local A;
									while true do
										if (FlatIdent_77478 == 3) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_77478 = 4;
										end
										if (FlatIdent_77478 == 8) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_77478 = 9;
										end
										if (FlatIdent_77478 == 4) then
											A = Inst[2];
											Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
											Top = (Limit + A) - 1;
											Edx = 0;
											FlatIdent_77478 = 5;
										end
										if (FlatIdent_77478 == 2) then
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											FlatIdent_77478 = 3;
										end
										if (FlatIdent_77478 == 7) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_77478 = 8;
										end
										if (FlatIdent_77478 == 6) then
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]]();
											FlatIdent_77478 = 7;
										end
										if (FlatIdent_77478 == 10) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											break;
										end
										if (FlatIdent_77478 == 9) then
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											FlatIdent_77478 = 10;
										end
										if (5 == FlatIdent_77478) then
											for Idx = A, Top do
												local FlatIdent_1E5DB = 0;
												while true do
													if (FlatIdent_1E5DB == 0) then
														Edx = Edx + 1;
														Stk[Idx] = Results[Edx];
														break;
													end
												end
											end
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_77478 = 6;
										end
										if (0 == FlatIdent_77478) then
											Edx = nil;
											Results, Limit = nil;
											B = nil;
											A = nil;
											FlatIdent_77478 = 1;
										end
										if (1 == FlatIdent_77478) then
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_77478 = 2;
										end
									end
								end
							elseif (Enum <= 31) then
								local FlatIdent_3CF36 = 0;
								local A;
								while true do
									if (0 == FlatIdent_3CF36) then
										A = Inst[2];
										Stk[A] = Stk[A](Stk[A + 1]);
										break;
									end
								end
							elseif (Enum == 32) then
								Stk[Inst[2]] = Inst[3] ~= 0;
							else
								Stk[Inst[2]] = Wrap(Proto[Inst[3]], nil, Env);
							end
						elseif (Enum <= 35) then
							if (Enum == 34) then
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
						elseif (Enum <= 36) then
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
						elseif (Enum == 37) then
							Stk[Inst[2]]();
						else
							local FlatIdent_1E4CB = 0;
							local A;
							while true do
								if (FlatIdent_1E4CB == 0) then
									A = Inst[2];
									Stk[A](Unpack(Stk, A + 1, Inst[3]));
									break;
								end
							end
						end
						VIP = VIP + 1;
						break;
					end
					if (FlatIdent_21DDC == 0) then
						Inst = Instr[VIP];
						Enum = Inst[1];
						FlatIdent_21DDC = 1;
					end
				end
			end
		end;
	end
	return Wrap(Deserialize(), {}, vmenv)(...);
end
return VMCall("LOL!4B3O00028O00026O001040030A3O00412O6453656374696F6E030D3O00574F524B494E47203A20E29C8503123O004F776E65723A204E68E1BAAD74204D696E6803123O0066622E636F6D2F6E6861746D696E68766E7A026O001440026O00084003073O004D616B6554616203043O004E616D6503133O00E289AB20496E666F726D6174696F6E20E289AA030C3O00E289AB204D61696E20E289AA030C3O00E289AB204D69736320E289AA030A3O006C6F6164737472696E6703043O0067616D6503073O00482O7470476574034C3O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F4E6861744D696E68564E512F67616D656C6F2O6765722F6D61696E2F6E6861746D696E68647A2E6C7561034A3O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F4E6861744D696E68564E512F67616D656C6F2O6765722F6D61696E2F6E6861746D696E682E6C756103403O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F5245447A4855422F4C69627261727956322F6D61696E2F7265647A4C6962026O00F03F027O0040030A3O004D616B654E6F7469666903053O005469746C6503093O00576F726C642048756203043O005465787403273O004C6F6164696E6720536372697074203A20556C74696D61746520546F77657220446566656E736503043O0054696D65026O00244003023O005F4703083O006175746F466973682O01031D3O00646973636F72642E636F6D2F696E766974652F70734538455561396B6703093O00412O64546F2O676C6503093O004175746F204669736803073O0044656661756C74010003083O0043612O6C6261636B03093O00412O6442752O746F6E03083O00416E74692041666B030A3O004D616B6557696E646F772O033O0048756203093O00574F524C442048554203093O00416E696D6174696F6E03103O006279203A206E68E1BAAD74206D696E682O033O004B657903093O004B657953797374656D030A3O004B65792053797374656D030B3O004465736372697074696F6E034O0003073O004B65794C696E6B03203O00682O7470733A2O2F6C2O6F742D6C696E6B2E636F6D2F733F623436383637623503043O004B65797303123O007468616E6B2D757365722D7363726970747303063O004E6F74696669030D3O004E6F74696669636174696F6E73030A3O00436F2O726563744B657903153O0052752O6E696E6720746865205363726970743O2E030C3O00496E636F2O726563746B657903143O00546865206B657920697320696E636F2O72656374030B3O00436F70794B65794C696E6B03133O00436F7069656420746F20436C6970626F617264030E3O004D696E696D697A6542752O746F6E03053O00496D61676503183O00726278612O73657469643A2O2F312O37342O37352O37353903043O0053697A65026O00444003053O00436F6C6F7203063O00436F6C6F723303073O0066726F6D52474203063O00436F726E657203063O005374726F6B65030B3O005374726F6B65436F6C6F72025O00E06F40030B3O004E68E1BAAD74204D696E6803183O0057656C636F6D652053637269707420576F726C642048756200A63O00120E3O00014O0007000100053O0026083O001A0001000200041B3O001A0001001215000600034O001A000700014O0011000800013O00120E000900044O000D0008000100012O00050006000800022O0018000400063O00122O000600036O000700016O000800013O00122O000900056O0008000100012O00050006000800022O0018000400063O00122O000600036O000700016O000800013O00122O000900066O0008000100012O00050006000800022O001A000400063O00120E3O00073O0026083O002C0001000800041B3O002C0001001215000600094O000C00073O000100302O0007000A000B4O0006000200024O000100063O00122O000600096O00073O000100302O0007000A000C4O0006000200024O000200063O00122O000600094O001100073O00010030020007000A000D2O001F0006000200022O001A000300063O00120E3O00023O0026083O00440001000100041B3O004400010012150006000E3O00121E0007000F3O00202O00070007001000122O000900116O000700096O00063O00024O00060001000100122O0006000E3O00122O0007000F3O00202O00070007001000122O000900124O000A000700094O000300063O00024O00060001000100122O0006000E3O00122O0007000F3O00202O00070007001000122O000900136O000700096O00063O00024O00060001000100124O00143O0026083O00510001001500041B3O00510001001215000600164O001C00073O000300302O00070017001800302O00070019001A00302O0007001B001C4O00060002000100122O0006001D3O00302O0006001E001F00022100065O0012100006001E3O00120E3O00083O0026083O006B0001000700041B3O006B0001001215000600034O001A000700014O0011000800013O00120E000900204O000D0008000100012O00050006000800022O0022000400063O00122O000600216O000700026O00083O000300302O0008000A002200302O000800230024000221000900013O0010160008002500094O0006000800024O000500063O00122O000600266O000700026O00083O000200302O0008000A0027000221000900023O0010090008002500092O002600060008000100041B3O00A500010026083O00020001001400041B3O00020001001215000600284O000100073O00024O00083O000200302O00080017002A00302O0008002B002C00102O0007002900084O00083O000600302O0008002E001F00302O00080017002F00302O00080030003100302O0008003200332O0011000900013O00120E000A00354O000D0009000100010010090008003400092O002400093O000400302O00090037001F00302O00090038003900302O0009003A003B00302O0009003C003D00102O00080036000900102O0007002D00084O00060002000100122O0006003E6O00073O00060030020007003F00402O0011000800023O00120E000900423O00120E000A00424O000D000800020001001009000700410008001206000800443O00202O00080008004500122O0009001C3O00122O000A001C3O00122O000B001C6O0008000B000200102O00070043000800302O00070046001F00302O00070047002400122O000800443O00202O000800080045001214000900493O00122O000A00013O00122O000B00016O0008000B000200102O0007004800084O00060002000100122O000600166O00073O000300302O00070017004A00302O00070019004B0030020007001B00072O001900060002000100120E3O00153O00041B3O000200012O000B3O00013O00033O000D3O0003023O005F4703083O006175746F466973682O01028O0003043O0067616D65030A3O004765745365727669636503113O005265706C69636174656453746F7261676503073O004D6F64756C6573030A3O00476C6F62616C496E6974030C3O0052656D6F74654576656E7473030F3O00506C61796572436174636846697368030A3O004669726553657276657203043O0077616974001E3O0012153O00013O00206O00020026083O001D0001000300041B3O001D000100120E3O00044O0007000100013O0026083O00060001000400041B3O0006000100120E000100043O002608000100090001000400041B3O00090001001215000200053O00202300020002000600122O000400076O00020004000200202O00020002000800202O00020002000900202O00020002000A00202O00020002000B00202O00020002000C4O00020002000100122O0002000D3O00122O000300046O00020002000100046O000100041B3O0009000100041B5O000100041B3O0006000100041B5O00012O000B3O00017O00033O00028O0003023O005F4703083O006175746F4669736801103O00120E000100014O0007000200023O000E12000100020001000100041B3O0002000100120E000200013O002608000200050001000100041B3O00050001001215000300023O001009000300033O001215000300034O002500030001000100041B3O000F000100041B3O0005000100041B3O000F000100041B3O000200012O000B3O00017O00043O00030A3O006C6F6164737472696E6703043O0067616D6503073O00482O747047657403473O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F4E6861744D696E68564E512F772D6875622F6D61696E2F416E746925323041666B2E6C756100093O00121D3O00013O00122O000100023O00202O00010001000300122O000300046O000400016O000100049O0000026O000100016O00017O00", GetFEnv(), ...);