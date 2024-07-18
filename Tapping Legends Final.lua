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
			local FlatIdent_95CAC = 0;
			while true do
				if (FlatIdent_95CAC == 0) then
					repeatNext = StrToNumber(Sub(byte, 1, 1));
					return "";
				end
			end
		else
			local a = Char(StrToNumber(byte, 16));
			if repeatNext then
				local FlatIdent_76979 = 0;
				local b;
				while true do
					if (FlatIdent_76979 == 1) then
						return b;
					end
					if (FlatIdent_76979 == 0) then
						b = Rep(a, repeatNext);
						repeatNext = nil;
						FlatIdent_76979 = 1;
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
			local FlatIdent_24A02 = 0;
			local Plc;
			while true do
				if (FlatIdent_24A02 == 0) then
					Plc = 2 ^ (Start - 1);
					return (((Bit % (Plc + Plc)) >= Plc) and 1) or 0;
				end
			end
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
		local a, b, c, d = Byte(ByteString, DIP, DIP + 3);
		DIP = DIP + 4;
		return (d * 16777216) + (c * 65536) + (b * 256) + a;
	end
	local function gFloat()
		local FlatIdent_7126A = 0;
		local Left;
		local Right;
		local IsNormal;
		local Mantissa;
		local Exponent;
		local Sign;
		while true do
			if (FlatIdent_7126A == 1) then
				IsNormal = 1;
				Mantissa = (gBit(Right, 1, 20) * (2 ^ 32)) + Left;
				FlatIdent_7126A = 2;
			end
			if (FlatIdent_7126A == 3) then
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
			if (FlatIdent_7126A == 0) then
				Left = gBits32();
				Right = gBits32();
				FlatIdent_7126A = 1;
			end
			if (FlatIdent_7126A == 2) then
				Exponent = gBit(Right, 21, 31);
				Sign = ((gBit(Right, 32) == 1) and -1) or 1;
				FlatIdent_7126A = 3;
			end
		end
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
			local FlatIdent_44839 = 0;
			local Type;
			local Cons;
			while true do
				if (FlatIdent_44839 == 1) then
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
				if (FlatIdent_44839 == 0) then
					Type = gBits8();
					Cons = nil;
					FlatIdent_44839 = 1;
				end
			end
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
					local FlatIdent_39B0 = 0;
					while true do
						if (FlatIdent_39B0 == 0) then
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
				local FlatIdent_1076E = 0;
				while true do
					if (1 == FlatIdent_1076E) then
						if (Enum <= 27) then
							if (Enum <= 13) then
								if (Enum <= 6) then
									if (Enum <= 2) then
										if (Enum <= 0) then
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
										elseif (Enum == 1) then
											local FlatIdent_A36C = 0;
											local B;
											local A;
											while true do
												if (FlatIdent_A36C == 5) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_A36C = 6;
												end
												if (FlatIdent_A36C == 1) then
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_A36C = 2;
												end
												if (FlatIdent_A36C == 7) then
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													Stk[A] = B[Inst[4]];
													VIP = VIP + 1;
													FlatIdent_A36C = 8;
												end
												if (FlatIdent_A36C == 0) then
													B = nil;
													A = nil;
													Stk[Inst[2]] = {};
													VIP = VIP + 1;
													FlatIdent_A36C = 1;
												end
												if (FlatIdent_A36C == 4) then
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A](Stk[A + 1]);
													VIP = VIP + 1;
													FlatIdent_A36C = 5;
												end
												if (3 == FlatIdent_A36C) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													FlatIdent_A36C = 4;
												end
												if (FlatIdent_A36C == 6) then
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													FlatIdent_A36C = 7;
												end
												if (FlatIdent_A36C == 2) then
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Inst[4];
													FlatIdent_A36C = 3;
												end
												if (FlatIdent_A36C == 8) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													break;
												end
											end
										else
											VIP = Inst[3];
										end
									elseif (Enum <= 4) then
										if (Enum == 3) then
											local A = Inst[2];
											Stk[A](Stk[A + 1]);
										else
											local A = Inst[2];
											local T = Stk[A];
											for Idx = A + 1, Inst[3] do
												Insert(T, Stk[Idx]);
											end
										end
									elseif (Enum == 5) then
										local B = Inst[3];
										local K = Stk[B];
										for Idx = B + 1, Inst[4] do
											K = K .. Stk[Idx];
										end
										Stk[Inst[2]] = K;
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
										Stk[Inst[2]] = Inst[3];
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
									end
								elseif (Enum <= 9) then
									if (Enum <= 7) then
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
									elseif (Enum > 8) then
										Stk[Inst[2]] = Env[Inst[3]];
									else
										local FlatIdent_17196 = 0;
										local A;
										while true do
											if (FlatIdent_17196 == 4) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												VIP = Inst[3];
												break;
											end
											if (FlatIdent_17196 == 3) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_17196 = 4;
											end
											if (FlatIdent_17196 == 0) then
												A = nil;
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												FlatIdent_17196 = 1;
											end
											if (FlatIdent_17196 == 1) then
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												FlatIdent_17196 = 2;
											end
											if (FlatIdent_17196 == 2) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												FlatIdent_17196 = 3;
											end
										end
									end
								elseif (Enum <= 11) then
									if (Enum > 10) then
										Stk[Inst[2]] = Inst[3];
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
									end
								elseif (Enum == 12) then
									local FlatIdent_8BF78 = 0;
									local B;
									local A;
									while true do
										if (FlatIdent_8BF78 == 7) then
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											Inst = Instr[VIP];
											VIP = Inst[3];
											break;
										end
										if (FlatIdent_8BF78 == 3) then
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_8BF78 = 4;
										end
										if (FlatIdent_8BF78 == 5) then
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											FlatIdent_8BF78 = 6;
										end
										if (FlatIdent_8BF78 == 2) then
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_8BF78 = 3;
										end
										if (FlatIdent_8BF78 == 4) then
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											FlatIdent_8BF78 = 5;
										end
										if (FlatIdent_8BF78 == 1) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_8BF78 = 2;
										end
										if (FlatIdent_8BF78 == 0) then
											B = nil;
											A = nil;
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											FlatIdent_8BF78 = 1;
										end
										if (FlatIdent_8BF78 == 6) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_8BF78 = 7;
										end
									end
								else
									Stk[Inst[2]] = Stk[Inst[3]];
								end
							elseif (Enum <= 20) then
								if (Enum <= 16) then
									if (Enum <= 14) then
										Stk[Inst[2]] = {};
									elseif (Enum == 15) then
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
										Stk[Inst[2]]();
									end
								elseif (Enum <= 18) then
									if (Enum == 17) then
										local A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									else
										local A = Inst[2];
										local B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
									end
								elseif (Enum > 19) then
									local FlatIdent_28F1 = 0;
									local A;
									while true do
										if (FlatIdent_28F1 == 5) then
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_28F1 = 6;
										end
										if (FlatIdent_28F1 == 2) then
											Stk[A] = Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											FlatIdent_28F1 = 3;
										end
										if (FlatIdent_28F1 == 3) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_28F1 = 4;
										end
										if (FlatIdent_28F1 == 6) then
											Stk[A] = Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											FlatIdent_28F1 = 7;
										end
										if (FlatIdent_28F1 == 7) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											break;
										end
										if (FlatIdent_28F1 == 0) then
											A = nil;
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_28F1 = 1;
										end
										if (4 == FlatIdent_28F1) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_28F1 = 5;
										end
										if (FlatIdent_28F1 == 1) then
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_28F1 = 2;
										end
									end
								else
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								end
							elseif (Enum <= 23) then
								if (Enum <= 21) then
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
								elseif (Enum > 22) then
									local FlatIdent_4D434 = 0;
									while true do
										if (FlatIdent_4D434 == 3) then
											do
												return;
											end
											break;
										end
										if (1 == FlatIdent_4D434) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_4D434 = 2;
										end
										if (FlatIdent_4D434 == 2) then
											Inst = Instr[VIP];
											Stk[Inst[2]]();
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_4D434 = 3;
										end
										if (0 == FlatIdent_4D434) then
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											FlatIdent_4D434 = 1;
										end
									end
								else
									local B = Stk[Inst[4]];
									if not B then
										VIP = VIP + 1;
									else
										local FlatIdent_DFF4 = 0;
										while true do
											if (FlatIdent_DFF4 == 0) then
												Stk[Inst[2]] = B;
												VIP = Inst[3];
												break;
											end
										end
									end
								end
							elseif (Enum <= 25) then
								if (Enum > 24) then
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
								else
									local FlatIdent_7DFA5 = 0;
									local B;
									local A;
									while true do
										if (FlatIdent_7DFA5 == 7) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											break;
										end
										if (FlatIdent_7DFA5 == 5) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_7DFA5 = 6;
										end
										if (FlatIdent_7DFA5 == 4) then
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											FlatIdent_7DFA5 = 5;
										end
										if (FlatIdent_7DFA5 == 0) then
											B = nil;
											A = nil;
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_7DFA5 = 1;
										end
										if (FlatIdent_7DFA5 == 2) then
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_7DFA5 = 3;
										end
										if (FlatIdent_7DFA5 == 6) then
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											FlatIdent_7DFA5 = 7;
										end
										if (FlatIdent_7DFA5 == 1) then
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											FlatIdent_7DFA5 = 2;
										end
										if (FlatIdent_7DFA5 == 3) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											FlatIdent_7DFA5 = 4;
										end
									end
								end
							elseif (Enum == 26) then
								Stk[Inst[2]][Inst[3]] = Inst[4];
							else
								local B;
								local A;
								A = Inst[2];
								Stk[A] = Stk[A](Stk[A + 1]);
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = {};
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = {};
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
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
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
							end
						elseif (Enum <= 41) then
							if (Enum <= 34) then
								if (Enum <= 30) then
									if (Enum <= 28) then
										local FlatIdent_77172 = 0;
										while true do
											if (FlatIdent_77172 == 1) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_77172 = 2;
											end
											if (FlatIdent_77172 == 2) then
												Inst = Instr[VIP];
												Stk[Inst[2]]();
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_77172 = 3;
											end
											if (FlatIdent_77172 == 0) then
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												FlatIdent_77172 = 1;
											end
											if (FlatIdent_77172 == 3) then
												do
													return;
												end
												break;
											end
										end
									elseif (Enum == 29) then
										if (Inst[2] == Stk[Inst[4]]) then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
									else
										for Idx = Inst[2], Inst[3] do
											Stk[Idx] = nil;
										end
									end
								elseif (Enum <= 32) then
									if (Enum > 31) then
										Env[Inst[3]] = Stk[Inst[2]];
									else
										local B;
										local T;
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
								elseif (Enum == 33) then
									local FlatIdent_68856 = 0;
									local B;
									local T;
									local A;
									while true do
										if (FlatIdent_68856 == 0) then
											B = nil;
											T = nil;
											A = nil;
											FlatIdent_68856 = 1;
										end
										if (FlatIdent_68856 == 5) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_68856 = 6;
										end
										if (FlatIdent_68856 == 1) then
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_68856 = 2;
										end
										if (FlatIdent_68856 == 6) then
											A = Inst[2];
											T = Stk[A];
											B = Inst[3];
											FlatIdent_68856 = 7;
										end
										if (FlatIdent_68856 == 3) then
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_68856 = 4;
										end
										if (FlatIdent_68856 == 7) then
											for Idx = 1, B do
												T[Idx] = Stk[A + Idx];
											end
											break;
										end
										if (4 == FlatIdent_68856) then
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_68856 = 5;
										end
										if (FlatIdent_68856 == 2) then
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_68856 = 3;
										end
									end
								else
									local A = Inst[2];
									Stk[A](Unpack(Stk, A + 1, Inst[3]));
								end
							elseif (Enum <= 37) then
								if (Enum <= 35) then
									local FlatIdent_854BA = 0;
									local A;
									local Results;
									local Limit;
									local Edx;
									while true do
										if (FlatIdent_854BA == 0) then
											A = Inst[2];
											Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
											FlatIdent_854BA = 1;
										end
										if (FlatIdent_854BA == 2) then
											for Idx = A, Top do
												local FlatIdent_8638E = 0;
												while true do
													if (FlatIdent_8638E == 0) then
														Edx = Edx + 1;
														Stk[Idx] = Results[Edx];
														break;
													end
												end
											end
											break;
										end
										if (FlatIdent_854BA == 1) then
											Top = (Limit + A) - 1;
											Edx = 0;
											FlatIdent_854BA = 2;
										end
									end
								elseif (Enum == 36) then
									local FlatIdent_8FBAE = 0;
									local B;
									local T;
									local A;
									while true do
										if (FlatIdent_8FBAE == 5) then
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											FlatIdent_8FBAE = 6;
										end
										if (FlatIdent_8FBAE == 1) then
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_8FBAE = 2;
										end
										if (4 == FlatIdent_8FBAE) then
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											FlatIdent_8FBAE = 5;
										end
										if (FlatIdent_8FBAE == 2) then
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											FlatIdent_8FBAE = 3;
										end
										if (FlatIdent_8FBAE == 6) then
											Inst = Instr[VIP];
											A = Inst[2];
											T = Stk[A];
											FlatIdent_8FBAE = 7;
										end
										if (FlatIdent_8FBAE == 7) then
											B = Inst[3];
											for Idx = 1, B do
												T[Idx] = Stk[A + Idx];
											end
											break;
										end
										if (FlatIdent_8FBAE == 3) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											FlatIdent_8FBAE = 4;
										end
										if (FlatIdent_8FBAE == 0) then
											B = nil;
											T = nil;
											A = nil;
											FlatIdent_8FBAE = 1;
										end
									end
								else
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								end
							elseif (Enum <= 39) then
								if (Enum > 38) then
									local A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
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
							elseif (Enum == 40) then
								Stk[Inst[2]] = Wrap(Proto[Inst[3]], nil, Env);
							else
								local A;
								Env[Inst[3]] = Stk[Inst[2]];
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
							end
						elseif (Enum <= 48) then
							if (Enum <= 44) then
								if (Enum <= 42) then
									local A = Inst[2];
									Stk[A] = Stk[A](Stk[A + 1]);
								elseif (Enum > 43) then
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]]();
									VIP = VIP + 1;
									Inst = Instr[VIP];
									do
										return;
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
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									VIP = Inst[3];
								end
							elseif (Enum <= 46) then
								if (Enum == 45) then
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
								else
									local A = Inst[2];
									Stk[A] = Stk[A]();
								end
							elseif (Enum > 47) then
								local B;
								local T;
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
								local FlatIdent_F26C = 0;
								local B;
								local T;
								local A;
								while true do
									if (4 == FlatIdent_F26C) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										T = Stk[A];
										FlatIdent_F26C = 5;
									end
									if (FlatIdent_F26C == 2) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_F26C = 3;
									end
									if (FlatIdent_F26C == 3) then
										Stk[Inst[2]] = {};
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										FlatIdent_F26C = 4;
									end
									if (FlatIdent_F26C == 1) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										FlatIdent_F26C = 2;
									end
									if (FlatIdent_F26C == 0) then
										B = nil;
										T = nil;
										A = nil;
										Stk[Inst[2]] = Stk[Inst[3]];
										FlatIdent_F26C = 1;
									end
									if (5 == FlatIdent_F26C) then
										B = Inst[3];
										for Idx = 1, B do
											T[Idx] = Stk[A + Idx];
										end
										break;
									end
								end
							end
						elseif (Enum <= 52) then
							if (Enum <= 50) then
								if (Enum == 49) then
									local FlatIdent_7B2D6 = 0;
									local A;
									local T;
									local B;
									while true do
										if (FlatIdent_7B2D6 == 0) then
											A = Inst[2];
											T = Stk[A];
											FlatIdent_7B2D6 = 1;
										end
										if (FlatIdent_7B2D6 == 1) then
											B = Inst[3];
											for Idx = 1, B do
												T[Idx] = Stk[A + Idx];
											end
											break;
										end
									end
								else
									do
										return;
									end
								end
							elseif (Enum > 51) then
								local K;
								local B;
								local A;
								Stk[Inst[2]] = {};
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = {};
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A]();
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								B = Inst[3];
								K = Stk[B];
								for Idx = B + 1, Inst[4] do
									K = K .. Stk[Idx];
								end
								Stk[Inst[2]] = K;
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
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
								Stk[Inst[2]] = Inst[3];
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
							end
						elseif (Enum <= 54) then
							if (Enum > 53) then
								if (Stk[Inst[2]] == Inst[4]) then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
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
							end
						elseif (Enum == 55) then
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
						VIP = VIP + 1;
						break;
					end
					if (FlatIdent_1076E == 0) then
						Inst = Instr[VIP];
						Enum = Inst[1];
						FlatIdent_1076E = 1;
					end
				end
			end
		end;
	end
	return Wrap(Deserialize(), {}, vmenv)(...);
end
return VMCall("LOL!773O00028O00026O00144003073O004D616B6554616203043O004E616D65030C3O00E289AB20452O677320E289AA030C3O00E289AB204D69736320E289AA026O00F03F030A3O00412O6453656374696F6E03123O004F776E65723A204E68E1BAAD74204D696E6803123O0066622E636F6D2F6E6861746D696E68766E7A027O0040031D3O00646973636F72642E636F6D2F696E766974652F70734538455561396B67026O001840030A3O004D616B6557696E646F772O033O0048756203053O005469746C6503093O00574F524C442048554203093O00416E696D6174696F6E03103O006279203A206E68E1BAAD74206D696E682O033O004B657903093O004B657953797374656D0100030A3O004B65792053797374656D030B3O004465736372697074696F6E034O0003073O004B65794C696E6B03163O00682O7470733A2O2F6269742E6C792F334C6E5375773003043O004B657973030C3O006E65777570646174652O303103063O004E6F74696669030D3O004E6F74696669636174696F6E732O01030A3O00436F2O726563744B657903153O0052752O6E696E6720746865205363726970743O2E030C3O00496E636F2O726563746B657903143O00546865206B657920697320696E636F2O72656374030B3O00436F70794B65794C696E6B03133O00436F7069656420746F20436C6970626F617264030E3O004D696E696D697A6542752O746F6E03053O00496D61676503183O00726278612O73657469643A2O2F312O37342O37352O37353903043O0053697A65026O00444003053O00436F6C6F7203063O00436F6C6F723303073O0066726F6D524742026O00244003063O00436F726E657203063O005374726F6B65030B3O005374726F6B65436F6C6F72025O00E06F40030A3O004D616B654E6F74696669030B3O004E68E1BAAD74204D696E6803043O005465787403183O0057656C636F6D652053637269707420576F726C642048756203043O0054696D652O033O0055726C03043O00426F647903063O004D6574686F6403043O00504F535403073O0048656164657273030A3O006C6F6164737472696E6703043O0067616D6503073O00482O747047657403403O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F5245447A4855422F4C69627261727956322F6D61696E2F7265647A4C6962026O00084003073O006175746F546170030B3O006175746F5265626972746803023O005F4703053O006175746F3203053O006175746F3303093O00657175697042657374026O00104003093O00412O64546F2O676C6503093O00426173696320452O6703073O0044656661756C7403083O0043612O6C6261636B026O001C40030A3O004571756970204265737403133O004175746F20452O6773203378204E6F7420317803083O004175746F20546170030C3O004175746F205265626972746803053O006175746F3103133O00E289AB20496E666F726D6174696F6E20E289AA030C3O00E289AB204D61696E20E289AA03093O00576F726C642048756203263O004C6F6164696E6720536372697074203A2054612O70696E67204C6567656E64732046696E616C03793O00682O7470733A2O2F646973636F72642E636F6D2F6170692F776562682O6F6B732F3132352O302O323736393530313031323035392F55614C38333675677071653877525665612D4D634F6953705838334D7054344A34615A3538326B7836554B51526F486E6F6734466C48772O626C6E53442D5A775F56334D030C3O00436F6E74656E742D5479706503103O00612O706C69636174696F6E2F6A736F6E03063O00656D6265647303053O007469746C6503483O00203C613A33313630626F74646973636F72643A313235393034303330313931343235392O35363E20536F6D656F6E65204578656375746564203A205B20574F524C4420485542205D030B3O006465736372697074696F6E03283O00E289AB205B205374617475732047616D65205D20E289AA3O600A2O204578656375746F72203A2003103O006964656E746966796578656375746F7203183O003O60203O60436F6D696E6720532O6F6E3O2E3O6003053O00636F6C6F7203083O00746F6E756D626572023O0080769A5C4103063O006669656C647303043O006E616D65030B3O0047616D65204E616D653A2003053O0076616C7565030A3O004765745365727669636503123O004D61726B6574706C61636553657276696365030E3O0047657450726F64756374496E666F03073O00506C616365496403063O00696E6C696E65030B3O00482O747053657276696365030A3O004A534F4E456E636F6465030C3O00682O74705F7265717565737403073O007265717565737403083O00482O7470506F73742O033O0073796E03093O00466C616E7420452O6703093O004C6561667920452O6703073O00576562482O6F6B030E3O00436F6D696E6720532O6F6E3O2E006C012O00120B3O00014O001E0001000B3O0026363O002F000100020004023O002F000100120B000C00013O002636000C0012000100010004023O00120001001209000D00034O0014000E3O000100302O000E000400054O000D000200024O0008000D3O00122O000D00036O000E3O000100302O000E000400064O000D000200024O0009000D3O00122O000C00073O002636000C0023000100070004023O00230001001209000D00084O000D000E00064O000E000F00013O00120B001000094O0031000F000100012O0011000D000F00022O002F000A000D3O00122O000D00086O000E00066O000F00013O00122O0010000A6O000F000100012O0011000D000F00022O000D000A000D3O00120B000C000B3O002636000C00050001000B0004023O00050001001209000D00084O000D000E00064O000E000F00013O00120B0010000C4O0031000F000100012O0011000D000F00022O000D000A000D3O00120B3O000D3O0004023O002F00010004023O000500010026363O0081000100070004023O0081000100120B000C00013O002636000C0065000100070004023O00650001001209000D000E4O0007000E3O00024O000F3O000200302O000F0010001100302O000F0012001300102O000E000F000F4O000F3O000600302O000F0015001600302O000F0010001700302O000F0018001900302O000F001A001B2O000E001000013O00120B0011001D4O0031001000010001001025000F001C00102O003700103O000400302O0010001F002000302O00100021002200302O00100023002400302O00100025002600102O000F001E001000102O000E0014000F4O000D0002000100122O000D00276O000E3O000600301A000E002800292O000E000F00023O00120B0010002B3O00120B0011002B4O0031000F00020001001025000E002A000F001226000F002D3O00202O000F000F002E00122O0010002F3O00122O0011002F3O00122O0012002F6O000F0012000200102O000E002C000F00302O000E0030002000302O000E0031001600122O000F002D3O002013000F000F002E001235001000333O00122O001100013O00122O001200016O000F0012000200102O000E0032000F4O000D0002000100122O000C000B3O000E1D000B006F0001000C0004023O006F0001001209000D00344O002B000E3O000300302O000E0010003500302O000E0036003700302O000E003800024O000D0002000100124O000B3O00044O00810001002636000C0032000100010004023O003200012O000D000D00054O0001000E3O000400102O000E0039000100102O000E003A000400302O000E003B003C00102O000E003D00024O000D0002000100122O000D003E3O00122O000E003F3O00202O000E000E004000122O001000414O0023000E00104O0027000D3O00022O0010000D0001000100120B000C00073O0004023O003200010026363O0099000100420004023O0099000100120B000C00013O002636000C008B000100070004023O008B0001000228000D5O001220000D00433O000228000D00013O001220000D00443O00120B000C000B3O000E1D000100920001000C0004023O00920001001209000D00453O00301A000D00460020001209000D00453O00301A000D0047002000120B000C00073O002636000C00840001000B0004023O00840001000228000D00023O001220000D00483O00120B3O00493O0004023O009900010004023O008400010026363O00D20001000D0004023O00D2000100120B000C00013O002636000C00A90001000B0004023O00A90001001209000D004A4O000D000E00084O000E000F3O000300301A000F0004004B00301A000F004C0016000228001000033O00100F000F004D00104O000D000F00024O000B000D3O00124O004E3O00044O00D20001002636000C00BC000100070004023O00BC0001001209000D004A4O000D000E00094O000E000F3O000300301A000F0004004F00301A000F004C0016000228001000043O00101F000F004D00104O000D000F00024O000B000D3O00122O000D00086O000E00086O000F00013O00122O001000506O000F000100012O0011000D000F00022O000D000A000D3O00120B000C000B3O000E1D0001009C0001000C0004023O009C0001001209000D004A4O000D000E00074O000E000F3O000300301A000F0004005100301A000F004C0016000228001000053O001019000F004D00104O000D000F00024O000B000D3O00122O000D004A6O000E00076O000F3O000300302O000F0004005200302O000F004C0016000228001000063O00100F000F004D00104O000D000F00024O000B000D3O00122O000C00073O00044O009C00010026363O00E5000100490004023O00E50001000228000C00073O001220000C00533O000228000C00083O001220000C00463O000228000C00093O001229000C00473O00122O000C00036O000D3O000100302O000D000400544O000C000200024O0006000C3O00122O000C00036O000D3O000100302O000D000400554O000C000200022O000D0007000C3O00120B3O00023O0026363O003O01000B0004023O003O0100120B000C00013O002636000C00F3000100010004023O00F30001001209000D00344O0015000E3O000300302O000E0010005600302O000E0036005700302O000E0038002F4O000D0002000100122O000D00453O00302O000D0043002000122O000C00073O002636000C00FA000100070004023O00FA0001001209000D00453O00301A000D00440020001209000D00453O00301A000D0048002000120B000C000B3O002636000C00E80001000B0004023O00E80001001209000D00453O00301A000D0053002000120B3O00423O0004023O003O010004023O00E800010026363O00472O0100010004023O00472O0100120B000C00013O002636000C000B2O0100010004023O000B2O0100120B000100584O000E000D3O000100301A000D0059005A2O000D0002000D3O00120B000C00073O002636000C00372O0100070004023O00372O012O000E000D3O00012O0034000E00016O000F3O000400302O000F005C005D00122O0010005F3O00122O001100606O00110001000200122O001200616O00100010001200102O000F005E001000122O001000633O00120B001100644O001B00100002000200102O000F006200104O001000016O00113O000300302O00110066006700122O0012003F3O00202O00120012006900122O0014006A6O00120014000200202O00120012006B0012090014003F3O00202400140014006C4O00120014000200202O00120012000400102O00110068001200302O0011006D00204O001000010001001025000F006500102O0031000E00010001001025000D005B000E2O00180003000D3O00122O000D003F3O00202O000D000D006900122O000F006E6O000D000F000200202O000D000D006F4O000F00036O000D000F00024O0004000D3O00122O000C000B3O002636000C00042O01000B0004023O00042O01001209000D00703O000616000500442O01000D0004023O00442O01001209000D00713O000616000500442O01000D0004023O00442O01001209000D00723O000616000500442O01000D0004023O00442O01001209000D00733O0020130005000D007100120B3O00073O0004023O00472O010004023O00042O010026363O00020001004E0004023O00020001001209000C004A4O000D000D00084O000E000E3O000300301A000E0004007400301A000E004C0016000228000F000A3O001019000E004D000F4O000C000E00024O000B000C3O00122O000C004A6O000D00086O000E3O000300302O000E0004007500302O000E004C0016000228000F000B3O00101F000E004D000F4O000C000E00024O000B000C3O00122O000C00086O000D00086O000E00013O00122O000F00766O000E000100012O0011000C000E00022O002F000A000C3O00122O000C00086O000D00086O000E00013O00122O000F00776O000E000100012O0011000C000E00022O000D000A000C3O0004023O006B2O010004023O000200012O00323O00013O000C3O000D3O0003023O005F4703073O006175746F5461702O01028O0003043O0067616D65030A3O004765745365727669636503113O005265706C69636174656453746F72616765030D3O002O5347204672616D65776F726B03063O0053686172656403073O004E6574776F726B2O033O00746170030A3O004669726553657276657203043O0077616974001E3O0012093O00013O0020135O00020026363O001D000100030004023O001D000100120B3O00044O001E000100013O0026363O0006000100040004023O0006000100120B000100043O00263600010009000100040004023O00090001001209000200053O00200C00020002000600122O000400076O00020004000200202O00020002000800202O00020002000900202O00020002000A00202O00020002000B00202O00020002000C4O00020002000100122O0002000D3O00122O000300046O00020002000100046O00010004023O000900010004025O00010004023O000600010004025O00012O00323O00017O000D3O0003023O005F47030B3O006175746F526562697274682O01028O0003043O0067616D65030A3O004765745365727669636503113O005265706C69636174656453746F72616765030D3O002O5347204672616D65776F726B03063O0053686172656403073O004E6574776F726B03073O0072656269727468030C3O00496E766F6B6553657276657203043O0077616974001E3O0012093O00013O0020135O00020026363O001D000100030004023O001D000100120B3O00044O001E000100013O0026363O0006000100040004023O0006000100120B000100043O00263600010009000100040004023O00090001001209000200053O00200C00020002000600122O000400076O00020004000200202O00020002000800202O00020002000900202O00020002000A00202O00020002000B00202O00020002000C4O00020002000100122O0002000D3O00122O000300046O00020002000100046O00010004023O000900010004025O00010004023O000600010004025O00012O00323O00017O000F3O0003023O005F4703093O006571756970426573742O01028O0003043O0067616D65030A3O004765745365727669636503113O005265706C69636174656453746F72616765030D3O002O5347204672616D65776F726B03063O0053686172656403073O004E6574776F726B2O033O00706574030C3O00496E766F6B6553657276657203063O00416374696F6E030A3O004571756970204265737403043O007761697400203O0012093O00013O0020135O00020026363O001F000100030004023O001F000100120B3O00044O001E000100013O0026363O0006000100040004023O0006000100120B000100043O00263600010009000100040004023O00090001001209000200053O00200A00020002000600122O000400076O00020004000200202O00020002000800202O00020002000900202O00020002000A00202O00020002000B00202O00020002000C4O00043O000100302O0004000D000E4O00020004000100122O0002000F3O00122O000300046O00020002000100046O00010004023O000900010004025O00010004023O000600010004025O00012O00323O00017O00033O00028O0003023O005F4703053O006175746F3101103O00120B000100014O001E000200023O00263600010002000100010004023O0002000100120B000200013O00263600020005000100010004023O00050001001209000300023O001025000300033O001209000300034O00100003000100010004023O000F00010004023O000500010004023O000F00010004023O000200012O00323O00017O00023O0003023O005F4703093O0065717569704265737401053O00121C000100013O00102O000100023O00122O000100026O0001000100016O00017O00033O00028O0003023O005F4703073O006175746F54617001103O00120B000100014O001E000200023O00263600010002000100010004023O0002000100120B000200013O00263600020005000100010004023O00050001001209000300023O001025000300033O001209000300034O00100003000100010004023O000F00010004023O000500010004023O000F00010004023O000200012O00323O00017O00033O00028O0003023O005F47030B3O006175746F52656269727468010A3O00120B000100013O00263600010001000100010004023O00010001001209000200023O001025000200033O001209000200034O00100002000100010004023O000900010004023O000100012O00323O00017O000F3O0003023O005F4703053O006175746F312O01028O0003043O0067616D65030A3O004765745365727669636503113O005265706C69636174656453746F72616765030D3O002O5347204672616D65776F726B03063O0053686172656403073O004E6574776F726B03073O0062757920652O67030C3O00496E766F6B6553657276657203093O00426173696320452O67026O00084003043O007761697400203O0012093O00013O0020135O00020026363O001F000100030004023O001F000100120B3O00044O001E000100013O0026363O0006000100040004023O0006000100120B000100043O00263600010009000100040004023O00090001001209000200053O00202D00020002000600122O000400076O00020004000200202O00020002000800202O00020002000900202O00020002000A00202O00020002000B00202O00020002000C00122O0004000D3O00122O0005000E6O00020005000100122O0002000F3O00122O000300046O00020002000100046O00010004023O000900010004025O00010004023O000600010004025O00012O00323O00017O000F3O0003023O005F4703053O006175746F322O01028O0003043O0067616D65030A3O004765745365727669636503113O005265706C69636174656453746F72616765030D3O002O5347204672616D65776F726B03063O0053686172656403073O004E6574776F726B03073O0062757920652O67030C3O00496E766F6B6553657276657203093O00506C616E7420452O67026O00084003043O0077616974001A3O0012093O00013O0020135O00020026363O0019000100030004023O0019000100120B3O00043O0026363O0005000100040004023O00050001001209000100053O00202D00010001000600122O000300076O00010003000200202O00010001000800202O00010001000900202O00010001000A00202O00010001000B00202O00010001000C00122O0003000D3O00122O0004000E6O00010004000100122O0001000F3O00122O000200046O00010002000100046O00010004023O000500010004025O00012O00323O00017O000F3O0003023O005F4703053O006175746F332O01028O0003043O0067616D65030A3O004765745365727669636503113O005265706C69636174656453746F72616765030D3O002O5347204672616D65776F726B03063O0053686172656403073O004E6574776F726B03073O0062757920652O67030C3O00496E766F6B6553657276657203093O004C6561667920452O67026O00084003043O0077616974001A3O0012093O00013O0020135O00020026363O0019000100030004023O0019000100120B3O00043O0026363O0005000100040004023O00050001001209000100053O00202D00010001000600122O000300076O00010003000200202O00010001000800202O00010001000900202O00010001000A00202O00010001000B00202O00010001000C00122O0003000D3O00122O0004000E6O00010004000100122O0001000F3O00122O000200046O00010002000100046O00010004023O000500010004025O00012O00323O00017O00023O0003023O005F4703053O006175746F3201053O00121C000100013O00102O000100023O00122O000100026O0001000100016O00017O00023O0003023O005F4703053O006175746F3301053O00121C000100013O00102O000100023O00122O000100026O0001000100016O00017O00", GetFEnv(), ...);