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
			local FlatIdent_95CAC = 0;
			local Res;
			while true do
				if (FlatIdent_95CAC == 0) then
					Res = (Bit / (2 ^ (Start - 1))) % (2 ^ (((End - 1) - (Start - 1)) + 1));
					return Res - (Res % 1);
				end
			end
		else
			local FlatIdent_76979 = 0;
			local Plc;
			while true do
				if (FlatIdent_76979 == 0) then
					Plc = 2 ^ (Start - 1);
					return (((Bit % (Plc + Plc)) >= Plc) and 1) or 0;
				end
			end
		end
	end
	local function gBits8()
		local FlatIdent_69270 = 0;
		local a;
		while true do
			if (FlatIdent_69270 == 1) then
				return a;
			end
			if (FlatIdent_69270 == 0) then
				a = Byte(ByteString, DIP, DIP);
				DIP = DIP + 1;
				FlatIdent_69270 = 1;
			end
		end
	end
	local function gBits16()
		local FlatIdent_7126A = 0;
		local a;
		local b;
		while true do
			if (FlatIdent_7126A == 1) then
				return (b * 256) + a;
			end
			if (FlatIdent_7126A == 0) then
				a, b = Byte(ByteString, DIP, DIP + 2);
				DIP = DIP + 2;
				FlatIdent_7126A = 1;
			end
		end
	end
	local function gBits32()
		local a, b, c, d = Byte(ByteString, DIP, DIP + 3);
		DIP = DIP + 4;
		return (d * 16777216) + (c * 65536) + (b * 256) + a;
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
		local FlatIdent_2661B = 0;
		local Str;
		local FStr;
		while true do
			if (FlatIdent_2661B == 1) then
				Str = Sub(ByteString, DIP, (DIP + Len) - 1);
				DIP = DIP + Len;
				FlatIdent_2661B = 2;
			end
			if (FlatIdent_2661B == 2) then
				FStr = {};
				for Idx = 1, #Str do
					FStr[Idx] = Char(Byte(Sub(Str, Idx, Idx)));
				end
				FlatIdent_2661B = 3;
			end
			if (FlatIdent_2661B == 0) then
				Str = nil;
				if not Len then
					Len = gBits32();
					if (Len == 0) then
						return "";
					end
				end
				FlatIdent_2661B = 1;
			end
			if (FlatIdent_2661B == 3) then
				return Concat(FStr);
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
				local FlatIdent_39B0 = 0;
				local Type;
				local Mask;
				local Inst;
				while true do
					if (FlatIdent_39B0 == 2) then
						if (gBit(Mask, 1, 1) == 1) then
							Inst[2] = Consts[Inst[2]];
						end
						if (gBit(Mask, 2, 2) == 1) then
							Inst[3] = Consts[Inst[3]];
						end
						FlatIdent_39B0 = 3;
					end
					if (3 == FlatIdent_39B0) then
						if (gBit(Mask, 3, 3) == 1) then
							Inst[4] = Consts[Inst[4]];
						end
						Instrs[Idx] = Inst;
						break;
					end
					if (FlatIdent_39B0 == 1) then
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
						FlatIdent_39B0 = 2;
					end
					if (FlatIdent_39B0 == 0) then
						Type = gBit(Descriptor, 2, 3);
						Mask = gBit(Descriptor, 4, 6);
						FlatIdent_39B0 = 1;
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
				local FlatIdent_E652 = 0;
				while true do
					if (FlatIdent_E652 == 1) then
						if (Enum <= 20) then
							if (Enum <= 9) then
								if (Enum <= 4) then
									if (Enum <= 1) then
										if (Enum == 0) then
											if (Stk[Inst[2]] == Inst[4]) then
												VIP = VIP + 1;
											else
												VIP = Inst[3];
											end
										else
											local A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
										end
									elseif (Enum <= 2) then
										local A;
										Stk[Inst[2]] = {};
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
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
										local FlatIdent_6053C = 0;
										local B;
										local T;
										local A;
										while true do
											if (FlatIdent_6053C == 5) then
												B = Inst[3];
												for Idx = 1, B do
													T[Idx] = Stk[A + Idx];
												end
												break;
											end
											if (FlatIdent_6053C == 2) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_6053C = 3;
											end
											if (FlatIdent_6053C == 3) then
												Stk[Inst[2]] = {};
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_6053C = 4;
											end
											if (FlatIdent_6053C == 0) then
												B = nil;
												T = nil;
												A = nil;
												Stk[Inst[2]] = Stk[Inst[3]];
												FlatIdent_6053C = 1;
											end
											if (FlatIdent_6053C == 1) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_6053C = 2;
											end
											if (FlatIdent_6053C == 4) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												T = Stk[A];
												FlatIdent_6053C = 5;
											end
										end
									end
								elseif (Enum <= 6) then
									if (Enum == 5) then
										local FlatIdent_12544 = 0;
										local A;
										while true do
											if (FlatIdent_12544 == 0) then
												A = nil;
												Stk[Inst[2]] = {};
												VIP = VIP + 1;
												FlatIdent_12544 = 1;
											end
											if (FlatIdent_12544 == 2) then
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												FlatIdent_12544 = 3;
											end
											if (5 == FlatIdent_12544) then
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												FlatIdent_12544 = 6;
											end
											if (FlatIdent_12544 == 4) then
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												FlatIdent_12544 = 5;
											end
											if (FlatIdent_12544 == 6) then
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												FlatIdent_12544 = 7;
											end
											if (FlatIdent_12544 == 3) then
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												FlatIdent_12544 = 4;
											end
											if (FlatIdent_12544 == 8) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												FlatIdent_12544 = 9;
											end
											if (FlatIdent_12544 == 9) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = {};
												break;
											end
											if (FlatIdent_12544 == 1) then
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												FlatIdent_12544 = 2;
											end
											if (7 == FlatIdent_12544) then
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A](Stk[A + 1]);
												FlatIdent_12544 = 8;
											end
										end
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
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
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
										B = Stk[Inst[4]];
										if not B then
											VIP = VIP + 1;
										else
											local FlatIdent_D79D = 0;
											while true do
												if (0 == FlatIdent_D79D) then
													Stk[Inst[2]] = B;
													VIP = Inst[3];
													break;
												end
											end
										end
									end
								elseif (Enum <= 7) then
									local B;
									local T;
									local A;
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
								elseif (Enum == 8) then
									do
										return;
									end
								else
									local FlatIdent_40B41 = 0;
									local B;
									local T;
									local A;
									while true do
										if (0 == FlatIdent_40B41) then
											B = nil;
											T = nil;
											A = nil;
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_40B41 = 1;
										end
										if (FlatIdent_40B41 == 4) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											T = Stk[A];
											FlatIdent_40B41 = 5;
										end
										if (3 == FlatIdent_40B41) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											FlatIdent_40B41 = 4;
										end
										if (2 == FlatIdent_40B41) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_40B41 = 3;
										end
										if (1 == FlatIdent_40B41) then
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											FlatIdent_40B41 = 2;
										end
										if (FlatIdent_40B41 == 5) then
											B = Inst[3];
											for Idx = 1, B do
												T[Idx] = Stk[A + Idx];
											end
											break;
										end
									end
								end
							elseif (Enum <= 14) then
								if (Enum <= 11) then
									if (Enum == 10) then
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
									else
										local A = Inst[2];
										local T = Stk[A];
										for Idx = A + 1, Inst[3] do
											Insert(T, Stk[Idx]);
										end
									end
								elseif (Enum <= 12) then
									Stk[Inst[2]] = {};
								elseif (Enum == 13) then
									VIP = Inst[3];
								else
									Stk[Inst[2]]();
								end
							elseif (Enum <= 17) then
								if (Enum <= 15) then
									Env[Inst[3]] = Stk[Inst[2]];
								elseif (Enum > 16) then
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								else
									local FlatIdent_2E9CB = 0;
									local A;
									while true do
										if (FlatIdent_2E9CB == 7) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_2E9CB = 8;
										end
										if (FlatIdent_2E9CB == 8) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_2E9CB = 9;
										end
										if (FlatIdent_2E9CB == 1) then
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											FlatIdent_2E9CB = 2;
										end
										if (FlatIdent_2E9CB == 6) then
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											FlatIdent_2E9CB = 7;
										end
										if (9 == FlatIdent_2E9CB) then
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A]();
											break;
										end
										if (FlatIdent_2E9CB == 3) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											FlatIdent_2E9CB = 4;
										end
										if (2 == FlatIdent_2E9CB) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_2E9CB = 3;
										end
										if (FlatIdent_2E9CB == 5) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											FlatIdent_2E9CB = 6;
										end
										if (0 == FlatIdent_2E9CB) then
											A = nil;
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											FlatIdent_2E9CB = 1;
										end
										if (FlatIdent_2E9CB == 4) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											FlatIdent_2E9CB = 5;
										end
									end
								end
							elseif (Enum <= 18) then
								Stk[Inst[2]] = Env[Inst[3]];
							elseif (Enum == 19) then
								local T;
								local B;
								local A;
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
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								T = Stk[A];
								B = Inst[3];
								for Idx = 1, B do
									T[Idx] = Stk[A + Idx];
								end
							else
								local B = Stk[Inst[4]];
								if not B then
									VIP = VIP + 1;
								else
									local FlatIdent_21DDC = 0;
									while true do
										if (FlatIdent_21DDC == 0) then
											Stk[Inst[2]] = B;
											VIP = Inst[3];
											break;
										end
									end
								end
							end
						elseif (Enum <= 30) then
							if (Enum <= 25) then
								if (Enum <= 22) then
									if (Enum == 21) then
										Stk[Inst[2]] = Inst[3];
									else
										local A = Inst[2];
										Stk[A] = Stk[A]();
									end
								elseif (Enum <= 23) then
									local FlatIdent_FA88 = 0;
									local A;
									while true do
										if (FlatIdent_FA88 == 0) then
											A = Inst[2];
											Stk[A](Stk[A + 1]);
											break;
										end
									end
								elseif (Enum == 24) then
									local A = Inst[2];
									local Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
									Top = (Limit + A) - 1;
									local Edx = 0;
									for Idx = A, Top do
										local FlatIdent_580CB = 0;
										while true do
											if (FlatIdent_580CB == 0) then
												Edx = Edx + 1;
												Stk[Idx] = Results[Edx];
												break;
											end
										end
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
							elseif (Enum <= 27) then
								if (Enum == 26) then
									local FlatIdent_20FE3 = 0;
									local B;
									local A;
									while true do
										if (FlatIdent_20FE3 == 0) then
											B = nil;
											A = nil;
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											FlatIdent_20FE3 = 1;
										end
										if (8 == FlatIdent_20FE3) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A](Stk[A + 1]);
											FlatIdent_20FE3 = 9;
										end
										if (FlatIdent_20FE3 == 7) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_20FE3 = 8;
										end
										if (FlatIdent_20FE3 == 5) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											FlatIdent_20FE3 = 6;
										end
										if (2 == FlatIdent_20FE3) then
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_20FE3 = 3;
										end
										if (FlatIdent_20FE3 == 3) then
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											FlatIdent_20FE3 = 4;
										end
										if (FlatIdent_20FE3 == 4) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											FlatIdent_20FE3 = 5;
										end
										if (FlatIdent_20FE3 == 1) then
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_20FE3 = 2;
										end
										if (6 == FlatIdent_20FE3) then
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A](Stk[A + 1]);
											FlatIdent_20FE3 = 7;
										end
										if (FlatIdent_20FE3 == 9) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											VIP = Inst[3];
											break;
										end
									end
								else
									Stk[Inst[2]] = Stk[Inst[3]];
								end
							elseif (Enum <= 28) then
								local FlatIdent_44265 = 0;
								local A;
								while true do
									if (0 == FlatIdent_44265) then
										A = Inst[2];
										Stk[A] = Stk[A](Stk[A + 1]);
										break;
									end
								end
							elseif (Enum > 29) then
								local A = Inst[2];
								local T = Stk[A];
								local B = Inst[3];
								for Idx = 1, B do
									T[Idx] = Stk[A + Idx];
								end
							else
								local FlatIdent_15A17 = 0;
								local A;
								local K;
								local B;
								while true do
									if (FlatIdent_15A17 == 8) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										break;
									end
									if (FlatIdent_15A17 == 1) then
										K = Stk[B];
										for Idx = B + 1, Inst[4] do
											K = K .. Stk[Idx];
										end
										Stk[Inst[2]] = K;
										VIP = VIP + 1;
										FlatIdent_15A17 = 2;
									end
									if (FlatIdent_15A17 == 7) then
										Stk[Inst[2]] = {};
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										FlatIdent_15A17 = 8;
									end
									if (FlatIdent_15A17 == 6) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = {};
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_15A17 = 7;
									end
									if (FlatIdent_15A17 == 2) then
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_15A17 = 3;
									end
									if (5 == FlatIdent_15A17) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										FlatIdent_15A17 = 6;
									end
									if (FlatIdent_15A17 == 0) then
										A = nil;
										K = nil;
										B = nil;
										B = Inst[3];
										FlatIdent_15A17 = 1;
									end
									if (FlatIdent_15A17 == 4) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Stk[A + 1]);
										FlatIdent_15A17 = 5;
									end
									if (FlatIdent_15A17 == 3) then
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										FlatIdent_15A17 = 4;
									end
								end
							end
						elseif (Enum <= 35) then
							if (Enum <= 32) then
								if (Enum == 31) then
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								else
									local FlatIdent_3B08E = 0;
									local B;
									local T;
									local A;
									while true do
										if (FlatIdent_3B08E == 5) then
											B = Inst[3];
											for Idx = 1, B do
												T[Idx] = Stk[A + Idx];
											end
											break;
										end
										if (3 == FlatIdent_3B08E) then
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_3B08E = 4;
										end
										if (FlatIdent_3B08E == 4) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											T = Stk[A];
											FlatIdent_3B08E = 5;
										end
										if (FlatIdent_3B08E == 0) then
											B = nil;
											T = nil;
											A = nil;
											Stk[Inst[2]] = Stk[Inst[3]];
											FlatIdent_3B08E = 1;
										end
										if (FlatIdent_3B08E == 1) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_3B08E = 2;
										end
										if (FlatIdent_3B08E == 2) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_3B08E = 3;
										end
									end
								end
							elseif (Enum <= 33) then
								local FlatIdent_6EEC8 = 0;
								local A;
								while true do
									if (6 == FlatIdent_6EEC8) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										FlatIdent_6EEC8 = 7;
									end
									if (1 == FlatIdent_6EEC8) then
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										FlatIdent_6EEC8 = 2;
									end
									if (FlatIdent_6EEC8 == 3) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_6EEC8 = 4;
									end
									if (FlatIdent_6EEC8 == 4) then
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_6EEC8 = 5;
									end
									if (FlatIdent_6EEC8 == 5) then
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										FlatIdent_6EEC8 = 6;
									end
									if (FlatIdent_6EEC8 == 2) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_6EEC8 = 3;
									end
									if (FlatIdent_6EEC8 == 0) then
										A = nil;
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_6EEC8 = 1;
									end
									if (7 == FlatIdent_6EEC8) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										break;
									end
								end
							elseif (Enum > 34) then
								Stk[Inst[2]][Inst[3]] = Inst[4];
							else
								for Idx = Inst[2], Inst[3] do
									Stk[Idx] = nil;
								end
							end
						elseif (Enum <= 38) then
							if (Enum <= 36) then
								local FlatIdent_8EA6E = 0;
								local A;
								local B;
								while true do
									if (FlatIdent_8EA6E == 0) then
										A = Inst[2];
										B = Stk[Inst[3]];
										FlatIdent_8EA6E = 1;
									end
									if (FlatIdent_8EA6E == 1) then
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										break;
									end
								end
							elseif (Enum == 37) then
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
								Stk[Inst[2]] = {};
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = {};
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
							else
								local B = Inst[3];
								local K = Stk[B];
								for Idx = B + 1, Inst[4] do
									K = K .. Stk[Idx];
								end
								Stk[Inst[2]] = K;
							end
						elseif (Enum <= 39) then
							Stk[Inst[2]] = Wrap(Proto[Inst[3]], nil, Env);
						elseif (Enum == 40) then
							local A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
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
						end
						VIP = VIP + 1;
						break;
					end
					if (0 == FlatIdent_E652) then
						Inst = Instr[VIP];
						Enum = Inst[1];
						FlatIdent_E652 = 1;
					end
				end
			end
		end;
	end
	return Wrap(Deserialize(), {}, vmenv)(...);
end
return VMCall("LOL!693O00028O00027O0040030A3O006C6F6164737472696E6703043O0067616D6503073O00482O747047657403403O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F5245447A4855422F4C69627261727956322F6D61696E2F7265647A4C6962030A3O004D616B6557696E646F772O033O0048756203053O005469746C6503093O00574F524C442048554203093O00416E696D6174696F6E03103O006279203A206E68E1BAAD74206D696E682O033O004B657903093O004B657953797374656D2O01030A3O004B65792053797374656D030B3O004465736372697074696F6E03393O0053637269707473204E6F7420576F726B696E672C204A6F696E20446973636F7264203A20646973636F72642E2O672F70734538455561396B6703073O004B65794C696E6B03123O0053637269707473204E6F74204F70656E656403043O004B657973030E3O0061646D696E2D6E6861746D696E6803063O004E6F74696669030D3O004E6F74696669636174696F6E73030A3O00436F2O726563744B657903153O0052752O6E696E6720746865205363726970743O2E030C3O00496E636F2O726563746B657903143O00546865206B657920697320696E636F2O72656374030B3O00436F70794B65794C696E6B03133O00436F7069656420746F20436C6970626F617264030E3O004D696E696D697A6542752O746F6E03053O00496D61676503183O00726278612O73657469643A2O2F312O37342O37352O37353903043O0053697A65026O00444003053O00436F6C6F7203063O00436F6C6F723303073O0066726F6D524742026O00244003063O00436F726E657203063O005374726F6B650100030B3O005374726F6B65436F6C6F72025O00E06F40026O00084003793O00682O7470733A2O2F646973636F72642E636F6D2F6170692F776562682O6F6B732F3132352O302O323736393530313031323035392F55614C38333675677071653877525665612D4D634F6953705838334D7054344A34615A3538326B7836554B51526F486E6F6734466C48772O626C6E53442D5A775F56334D030C3O00436F6E74656E742D5479706503103O00612O706C69636174696F6E2F6A736F6E03063O00656D6265647303053O007469746C6503483O00203C613A33313630626F74646973636F72643A313235393034303330313931343235392O35363E20536F6D656F6E65204578656375746564203A205B20574F524C4420485542205D030B3O006465736372697074696F6E03283O00E289AB205B205374617475732047616D65205D20E289AA3O600A2O204578656375746F72203A2003103O006964656E746966796578656375746F7203183O003O60203O60436F6D696E6720532O6F6E3O2E3O6003053O00636F6C6F7203083O00746F6E756D626572023O0080769A5C4103063O006669656C647303043O006E616D65030B3O0047616D65204E616D653A2003053O0076616C7565030A3O004765745365727669636503123O004D61726B6574706C61636553657276696365030E3O0047657450726F64756374496E666F03073O00506C616365496403043O004E616D6503063O00696E6C696E65026O00F03F026O001840030A3O00412O6453656374696F6E031D3O00646973636F72642E636F6D2F696E766974652F70734538455561396B6703093O0053637269707473205703093O00412O64546F2O676C6503093O004175746F204669736803073O0044656661756C7403083O0043612O6C6261636B026O00104003083O006175746F4669736803073O004D616B6554616203133O00E289AB20496E666F726D6174696F6E20E289AA030C3O00E289AB204D61696E20E289AA026O001440030B3O00482O747053657276696365030A3O004A534F4E456E636F6465030C3O00682O74705F7265717565737403073O007265717565737403083O00482O7470506F73742O033O0073796E2O033O0055726C03043O00426F647903063O004D6574686F6403043O00504F535403073O0048656164657273030C3O00E289AB204D69736320E289AA03123O004F776E65723A204E68E1BAAD74204D696E6803123O0066622E636F6D2F6E6861746D696E68766E7A030A3O004D616B654E6F74696669030B3O004E68E1BAAD74204D696E6803043O005465787403183O0057656C636F6D652053637269707420576F726C642048756203043O0054696D6503093O00576F726C642048756203273O004C6F6164696E6720536372697074203A20556C74696D61746520546F77657220446566656E736503023O005F4700D33O0012153O00014O00220001000A3O00264O003C0001000200040D3O003C0001002O12000B00033O001225000C00043O00202O000C000C000500122O000E00066O000C000E6O000B3O00024O000B0001000100122O000B00076O000C3O00024O000D3O000200302O000D0009000A003023000D000B000C001007000C0008000D4O000D3O000600302O000D000E000F00302O000D0009001000302O000D0011001200302O000D001300144O000E00013O00122O000F00166O000E00010001001011000D0015000E2O0005000E3O000400302O000E0018000F00302O000E0019001A00302O000E001B001C00302O000E001D001E00102O000D0017000E00102O000C000D000D4O000B0002000100122O000B001F6O000C3O0006003023000C002000212O000C000D00023O001215000E00233O001215000F00234O001E000D00020001001011000C0022000D001221000D00253O00202O000D000D002600122O000E00273O00122O000F00273O00122O001000276O000D0010000200102O000C0024000D00302O000C0028000F00302O000C0029002A00122O000D00253O00201F000D000D0026001219000E002C3O00122O000F00013O00122O001000016O000D0010000200102O000C002B000D4O000B0002000100124O002D3O00264O00640001000100040D3O006400010012150001002E4O0010000B3O000100302O000B002F00304O0002000B6O000B3O00014O000C00016O000D3O000400302O000D0032003300122O000E00353O00122O000F00366O000F00010002001215001000374O001D000E000E001000102O000D0034000E00122O000E00393O00122O000F003A6O000E0002000200102O000D0038000E4O000E00016O000F3O000300302O000F003C003D00122O001000043O00202400100010003F001213001200406O00100012000200202O00100010004100122O001200043O00202O0012001200424O00100012000200202O00100010004300102O000F003E001000302O000F0044000F4O000E00010001001011000D003B000E2O001E000C00010001001011000B0031000C2O001B0003000B3O0012153O00453O00264O007E0001004600040D3O007E0001002O12000B00474O001B000C00064O000C000D00013O001215000E00484O001E000D000100012O0028000B000D00022O00030009000B3O00122O000B00476O000C00076O000D00013O00122O000E00496O000D000100012O0028000B000D00022O00040009000B3O00122O000B004A6O000C00076O000D3O000300302O000D0043004B00302O000D004C002A000227000E5O001011000D004D000E2O0028000B000D00022O001B000A000B3O00040D3O00D2000100264O008D0001004E00040D3O008D0001000227000B00013O00120A000B004F3O00122O000B00506O000C3O000100302O000C004300514O000B000200024O0006000B3O00122O000B00506O000C3O000100302O000C004300524O000B000200022O001B0007000B3O0012153O00533O00264O00AA0001004500040D3O00AA0001002O12000B00043O002006000B000B003F00122O000D00546O000B000D000200202O000B000B00554O000D00036O000B000D00024O0004000B3O00122O000B00563O00062O000500A20001000B00040D3O00A20001002O12000B00573O000614000500A20001000B00040D3O00A20001002O12000B00583O000614000500A20001000B00040D3O00A20001002O12000B00593O00201F0005000B00572O001B000B00054O0002000C3O000400102O000C005A000100102O000C005B000400302O000C005C005D00102O000C005E00024O000B0002000100124O00023O00264O00C00001005300040D3O00C00001002O12000B00504O0009000C3O000100302O000C0043005F4O000B000200024O0008000B3O00122O000B00476O000C00066O000D00013O00122O000E00606O000D000100012O0028000B000D00022O00030009000B3O00122O000B00476O000C00066O000D00013O00122O000E00616O000D000100012O0028000B000D00022O001B0009000B3O0012153O00463O00264O00020001002D00040D3O00020001002O12000B00624O0029000C3O000300302O000C0009006300302O000C0064006500302O000C006600534O000B0002000100122O000B00626O000C3O000300302O000C0009006700302O000C0064006800302O000C006600272O0017000B00020001002O12000B00693O003023000B004F000F0012153O004E3O00040D3O000200012O00083O00013O00023O00033O00028O0003023O005F4703083O006175746F46697368010A3O001215000100013O00262O000100010001000100040D3O00010001002O12000200023O001011000200033O002O12000200034O000E00020001000100040D3O0009000100040D3O000100012O00083O00017O000D3O0003023O005F4703083O006175746F466973682O01028O0003043O0067616D65030A3O004765745365727669636503113O005265706C69636174656453746F7261676503073O004D6F64756C6573030A3O00476C6F62616C496E6974030C3O0052656D6F74654576656E7473030F3O00506C61796572436174636846697368030A3O004669726553657276657203043O0077616974001E3O002O123O00013O00201F5O000200264O001D0001000300040D3O001D00010012153O00044O0022000100013O00264O00060001000400040D3O00060001001215000100043O00262O000100090001000400040D3O00090001002O12000200053O00201A00020002000600122O000400076O00020004000200202O00020002000800202O00020002000900202O00020002000A00202O00020002000B00202O00020002000C4O00020002000100122O0002000D3O00122O000300046O00020002000100046O000100040D3O0009000100040D5O000100040D3O0006000100040D5O00012O00083O00017O00", GetFEnv(), ...);