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
				local FlatIdent_95CAC = 0;
				local b;
				while true do
					if (FlatIdent_95CAC == 1) then
						return b;
					end
					if (FlatIdent_95CAC == 0) then
						b = Rep(a, repeatNext);
						repeatNext = nil;
						FlatIdent_95CAC = 1;
					end
				end
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
		local FlatIdent_8D327 = 0;
		local a;
		local b;
		local c;
		local d;
		while true do
			if (FlatIdent_8D327 == 0) then
				a, b, c, d = Byte(ByteString, DIP, DIP + 3);
				DIP = DIP + 4;
				FlatIdent_8D327 = 1;
			end
			if (FlatIdent_8D327 == 1) then
				return (d * 16777216) + (c * 65536) + (b * 256) + a;
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
			local FlatIdent_67C40 = 0;
			while true do
				if (FlatIdent_67C40 == 0) then
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
					local FlatIdent_1743D = 0;
					while true do
						if (FlatIdent_1743D == 0) then
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
				local FlatIdent_43862 = 0;
				while true do
					if (0 == FlatIdent_43862) then
						Inst = Instr[VIP];
						Enum = Inst[1];
						FlatIdent_43862 = 1;
					end
					if (FlatIdent_43862 == 1) then
						if (Enum <= 19) then
							if (Enum <= 9) then
								if (Enum <= 4) then
									if (Enum <= 1) then
										if (Enum == 0) then
											Stk[Inst[2]] = Wrap(Proto[Inst[3]], nil, Env);
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
									elseif (Enum <= 2) then
										VIP = Inst[3];
									elseif (Enum > 3) then
										local FlatIdent_781F8 = 0;
										local A;
										local B;
										while true do
											if (FlatIdent_781F8 == 0) then
												A = Inst[2];
												B = Stk[Inst[3]];
												FlatIdent_781F8 = 1;
											end
											if (1 == FlatIdent_781F8) then
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												break;
											end
										end
									elseif (Inst[2] == Stk[Inst[4]]) then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
								elseif (Enum <= 6) then
									if (Enum == 5) then
										Env[Inst[3]] = Stk[Inst[2]];
									else
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
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										VIP = Inst[3];
									end
								elseif (Enum <= 7) then
									local FlatIdent_104D4 = 0;
									local Edx;
									local Results;
									local Limit;
									local B;
									local A;
									while true do
										if (FlatIdent_104D4 == 1) then
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]]();
											VIP = VIP + 1;
											FlatIdent_104D4 = 2;
										end
										if (FlatIdent_104D4 == 6) then
											for Idx = A, Top do
												local FlatIdent_2D2B8 = 0;
												while true do
													if (FlatIdent_2D2B8 == 0) then
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
											FlatIdent_104D4 = 7;
										end
										if (FlatIdent_104D4 == 3) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											FlatIdent_104D4 = 4;
										end
										if (FlatIdent_104D4 == 8) then
											Stk[Inst[2]] = Inst[3];
											break;
										end
										if (FlatIdent_104D4 == 0) then
											Edx = nil;
											Results, Limit = nil;
											B = nil;
											A = nil;
											A = Inst[2];
											FlatIdent_104D4 = 1;
										end
										if (FlatIdent_104D4 == 5) then
											Inst = Instr[VIP];
											A = Inst[2];
											Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
											Top = (Limit + A) - 1;
											Edx = 0;
											FlatIdent_104D4 = 6;
										end
										if (4 == FlatIdent_104D4) then
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_104D4 = 5;
										end
										if (FlatIdent_104D4 == 7) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]]();
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_104D4 = 8;
										end
										if (2 == FlatIdent_104D4) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											FlatIdent_104D4 = 3;
										end
									end
								elseif (Enum == 8) then
									local A = Inst[2];
									local T = Stk[A];
									for Idx = A + 1, Inst[3] do
										Insert(T, Stk[Idx]);
									end
								else
									local A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
								end
							elseif (Enum <= 14) then
								if (Enum <= 11) then
									if (Enum == 10) then
										local FlatIdent_E0D0 = 0;
										local A;
										while true do
											if (FlatIdent_E0D0 == 0) then
												A = nil;
												Stk[Inst[2]] = {};
												VIP = VIP + 1;
												FlatIdent_E0D0 = 1;
											end
											if (FlatIdent_E0D0 == 2) then
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												FlatIdent_E0D0 = 3;
											end
											if (FlatIdent_E0D0 == 3) then
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												FlatIdent_E0D0 = 4;
											end
											if (FlatIdent_E0D0 == 6) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												VIP = Inst[3];
												break;
											end
											if (FlatIdent_E0D0 == 1) then
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												FlatIdent_E0D0 = 2;
											end
											if (FlatIdent_E0D0 == 4) then
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A](Stk[A + 1]);
												FlatIdent_E0D0 = 5;
											end
											if (FlatIdent_E0D0 == 5) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_E0D0 = 6;
											end
										end
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
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
									end
								elseif (Enum <= 12) then
									if (Stk[Inst[2]] == Inst[4]) then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
								elseif (Enum == 13) then
									do
										return;
									end
								else
									local A = Inst[2];
									Stk[A] = Stk[A](Stk[A + 1]);
								end
							elseif (Enum <= 16) then
								if (Enum == 15) then
									Stk[Inst[2]][Inst[3]] = Inst[4];
								else
									Stk[Inst[2]] = Inst[3] ~= 0;
								end
							elseif (Enum <= 17) then
								Stk[Inst[2]] = Env[Inst[3]];
							elseif (Enum > 18) then
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							else
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
							end
						elseif (Enum <= 29) then
							if (Enum <= 24) then
								if (Enum <= 21) then
									if (Enum > 20) then
										for Idx = Inst[2], Inst[3] do
											Stk[Idx] = nil;
										end
									else
										local A = Inst[2];
										local Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
										Top = (Limit + A) - 1;
										local Edx = 0;
										for Idx = A, Top do
											local FlatIdent_9622C = 0;
											while true do
												if (FlatIdent_9622C == 0) then
													Edx = Edx + 1;
													Stk[Idx] = Results[Edx];
													break;
												end
											end
										end
									end
								elseif (Enum <= 22) then
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
								elseif (Enum == 23) then
									local A = Inst[2];
									Stk[A](Stk[A + 1]);
								else
									local FlatIdent_2D88C = 0;
									local A;
									local T;
									local B;
									while true do
										if (1 == FlatIdent_2D88C) then
											B = Inst[3];
											for Idx = 1, B do
												T[Idx] = Stk[A + Idx];
											end
											break;
										end
										if (FlatIdent_2D88C == 0) then
											A = Inst[2];
											T = Stk[A];
											FlatIdent_2D88C = 1;
										end
									end
								end
							elseif (Enum <= 26) then
								if (Enum > 25) then
									local A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								else
									Stk[Inst[2]]();
								end
							elseif (Enum <= 27) then
								local FlatIdent_5346B = 0;
								while true do
									if (FlatIdent_5346B == 4) then
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_5346B = 5;
									end
									if (FlatIdent_5346B == 7) then
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_5346B = 8;
									end
									if (6 == FlatIdent_5346B) then
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_5346B = 7;
									end
									if (FlatIdent_5346B == 3) then
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_5346B = 4;
									end
									if (FlatIdent_5346B == 8) then
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_5346B = 9;
									end
									if (FlatIdent_5346B == 9) then
										Stk[Inst[2]][Inst[3]] = Inst[4];
										break;
									end
									if (1 == FlatIdent_5346B) then
										Stk[Inst[2]] = {};
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_5346B = 2;
									end
									if (FlatIdent_5346B == 0) then
										Stk[Inst[2]] = {};
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_5346B = 1;
									end
									if (FlatIdent_5346B == 5) then
										Stk[Inst[2]] = {};
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_5346B = 6;
									end
									if (FlatIdent_5346B == 2) then
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_5346B = 3;
									end
								end
							elseif (Enum == 28) then
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							else
								local A = Inst[2];
								Stk[A](Unpack(Stk, A + 1, Inst[3]));
							end
						elseif (Enum <= 34) then
							if (Enum <= 31) then
								if (Enum > 30) then
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
							elseif (Enum <= 32) then
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
							elseif (Enum == 33) then
								Stk[Inst[2]] = Stk[Inst[3]];
							else
								Stk[Inst[2]] = {};
							end
						elseif (Enum <= 36) then
							if (Enum == 35) then
								Stk[Inst[2]] = Inst[3];
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
						elseif (Enum <= 37) then
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
							Stk[Inst[2]] = Inst[3];
						elseif (Enum > 38) then
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
						VIP = VIP + 1;
						break;
					end
				end
			end
		end;
	end
	return Wrap(Deserialize(), {}, vmenv)(...);
end
return VMCall("LOL!4B3O00028O00027O0040030A3O004D616B654E6F7469666903053O005469746C6503093O00576F726C642048756203043O005465787403273O004C6F6164696E6720536372697074203A20556C74696D61746520546F77657220446566656E736503043O0054696D65026O00244003023O005F4703083O006175746F466973682O01026O00F03F026O000840030B3O004E68E1BAAD74204D696E6803183O0057656C636F6D652053637269707420576F726C6420487562026O001440030A3O004D616B6557696E646F772O033O0048756203093O00574F524C442048554203093O00416E696D6174696F6E03103O006279203A206E68E1BAAD74206D696E682O033O004B657903093O004B657953797374656D0100030A3O004B65792053797374656D030B3O004465736372697074696F6E03273O004B65792046722O6520446973636F72643A20646973636F72642E2O672F70734538455561396B6703073O004B65794C696E6B03153O00646973636F72642E2O672F70734538455561396B6703043O004B657973030F3O00776F726C645F39313834373430313403063O004E6F74696669030D3O004E6F74696669636174696F6E73030A3O00436F2O726563744B657903153O0052752O6E696E6720746865205363726970743O2E030C3O00496E636F2O726563746B657903143O00546865206B657920697320696E636F2O72656374030B3O00436F70794B65794C696E6B03133O00436F7069656420746F20436C6970626F617264030E3O004D696E696D697A6542752O746F6E03053O00496D61676503183O00726278612O73657469643A2O2F312O37342O37352O37353903043O0053697A65026O00444003053O00436F6C6F7203063O00436F6C6F723303073O0066726F6D52474203063O00436F726E657203063O005374726F6B65030B3O005374726F6B65436F6C6F72025O00E06F40030A3O00412O6453656374696F6E031D3O00646973636F72642E636F6D2F696E766974652F70734538455561396B6703093O00412O64546F2O676C6503043O004E616D6503093O004175746F204669736803073O0044656661756C7403083O0043612O6C6261636B03093O00412O6442752O746F6E03083O00416E74692041666B030A3O006C6F6164737472696E6703043O0067616D6503073O00482O7470476574034C3O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F4E6861744D696E68564E512F67616D656C6F2O6765722F6D61696E2F6E6861746D696E68647A2E6C7561034A3O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F4E6861744D696E68564E512F67616D656C6F2O6765722F6D61696E2F6E6861746D696E682E6C756103403O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F5245447A4855422F4C69627261727956322F6D61696E2F7265647A4C696203073O004D616B65546162030C3O00E289AB204D69736320E289AA026O00104003133O00E289AB20496E666F726D6174696F6E20E289AA030C3O00E289AB204D61696E20E289AA03123O0066622E636F6D2F6E6861746D696E68766E7A030D3O00574F524B494E47203A20E29C8503123O004F776E65723A204E68E1BAAD74204D696E6800C63O0012233O00014O0015000100053O00260C3O0017000100020004023O00170001001223000600013O00260C00060010000100010004023O00100001001211000700034O000B00083O000300302O00080004000500302O00080006000700302O0008000800094O00070002000100122O0007000A3O00302O0007000B000C00122O0006000D3O00260C000600050001000D0004023O0005000100022O00075O0012050007000B3O0012233O000E3O0004023O001700010004023O0005000100260C3O00580001000D0004023O00580001001223000600013O00260C000600240001000D0004023O00240001001211000700034O000A00083O000300302O00080004000F00302O00080006001000302O0008000800114O00070002000100124O00023O00044O0058000100260C0006001A000100010004023O001A0001001211000700124O001B00083O00024O00093O000200302O00090004001400302O00090015001600102O0008001300094O00093O000600302O00090018001900302O00090004001A00302O0009001B001C00302O0009001D001E2O0022000A00013O001223000B00204O0018000A000100010010130009001F000A2O0027000A3O000400302O000A0022000C00302O000A0023002400302O000A0025002600302O000A0027002800102O00090021000A00102O0008001700094O00070002000100122O000700296O00083O000600300F0008002A002B2O0022000900023O001223000A002D3O001223000B002D4O00180009000200010010130008002C0009002O120009002F3O00202O00090009003000122O000A00093O00122O000B00093O00122O000C00096O0009000C000200102O0008002E000900302O00080031000C00302O00080032001900122O0009002F3O00201C000900090030001206000A00343O00122O000B00013O00122O000C00016O0009000C000200102O0008003300094O00070002000100122O0006000D3O00044O001A000100260C3O0072000100110004023O00720001001211000600354O0021000700014O0022000800013O001223000900364O00180008000100012O001A0006000800022O0016000400063O00122O000600376O000700026O00083O000300302O00080038003900302O0008003A001900022O000900013O00101F0008003B00094O0006000800024O000500063O00122O0006003C6O000700026O00083O000200302O00080038003D00022O000900023O0010130008003B00092O001D0006000800010004023O00C5000100260C3O008A000100010004023O008A00010012110006003E3O0012010007003F3O00202O00070007004000122O000900416O000700096O00063O00024O00060001000100122O0006003E3O00122O0007003F3O00202O00070007004000122O000900424O0014000700094O000700063O00024O00060001000100122O0006003E3O00122O0007003F3O00202O00070007004000122O000900436O000700096O00063O00024O00060001000100124O000D3O00260C3O00A40001000E0004023O00A40001001223000600013O00260C000600960001000D0004023O00960001001211000700444O002000083O000100302O0008003800454O0007000200024O000300073O00124O00463O00044O00A4000100260C0006008D000100010004023O008D0001001211000700444O002500083O000100302O0008003800474O0007000200024O000100073O00122O000700446O00083O000100302O0008003800484O0007000200024O000200073O00122O0006000D3O0004023O008D000100260C3O0002000100460004023O00020001001223000600013O00260C000600B20001000D0004023O00B20001001211000700354O0021000800014O0022000900013O001223000A00494O00180009000100012O001A0007000900022O0021000400073O0012233O00113O0004023O0002000100260C000600A7000100010004023O00A70001001211000700354O0021000800014O0022000900013O001223000A004A4O00180009000100012O001A0007000900022O0024000400073O00122O000700356O000800016O000900013O00122O000A004B6O0009000100012O001A0007000900022O0021000400073O0012230006000D3O0004023O00A700010004023O000200012O000D3O00013O00033O000D3O0003023O005F4703083O006175746F466973682O01028O0003043O0067616D65030A3O004765745365727669636503113O005265706C69636174656453746F7261676503073O004D6F64756C6573030A3O00476C6F62616C496E6974030C3O0052656D6F74654576656E7473030F3O00506C61796572436174636846697368030A3O004669726553657276657203043O0077616974001E3O0012113O00013O00201C5O000200260C3O001D000100030004023O001D00010012233O00044O0015000100013O000E030004000600013O0004023O00060001001223000100043O00260C00010009000100040004023O00090001001211000200053O00201E00020002000600122O000400076O00020004000200202O00020002000800202O00020002000900202O00020002000A00202O00020002000B00202O00020002000C4O00020002000100122O0002000D3O00122O000300046O00020002000100046O00010004023O000900010004025O00010004023O000600010004025O00012O000D3O00017O00033O00028O0003023O005F4703083O006175746F4669736801103O001223000100014O0015000200023O00260C00010002000100010004023O00020001001223000200013O00260C00020005000100010004023O00050001001211000300023O001013000300033O001211000300034O00190003000100010004023O000F00010004023O000500010004023O000F00010004023O000200012O000D3O00017O00043O00030A3O006C6F6164737472696E6703043O0067616D6503073O00482O747047657403473O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F4E6861744D696E68564E512F772D6875622F6D61696E2F416E746925323041666B2E6C756100093O0012263O00013O00122O000100023O00202O00010001000300122O000300046O000400016O000100049O0000026O000100016O00017O00", GetFEnv(), ...);