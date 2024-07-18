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
		local FlatIdent_475BC = 0;
		local a;
		local b;
		while true do
			if (FlatIdent_475BC == 0) then
				a, b = Byte(ByteString, DIP, DIP + 2);
				DIP = DIP + 2;
				FlatIdent_475BC = 1;
			end
			if (FlatIdent_475BC == 1) then
				return (b * 256) + a;
			end
		end
	end
	local function gBits32()
		local a, b, c, d = Byte(ByteString, DIP, DIP + 3);
		DIP = DIP + 4;
		return (d * 16777216) + (c * 65536) + (b * 256) + a;
	end
	local function gFloat()
		local FlatIdent_43862 = 0;
		local Left;
		local Right;
		local IsNormal;
		local Mantissa;
		local Exponent;
		local Sign;
		while true do
			if (FlatIdent_43862 == 1) then
				IsNormal = 1;
				Mantissa = (gBit(Right, 1, 20) * (2 ^ 32)) + Left;
				FlatIdent_43862 = 2;
			end
			if (FlatIdent_43862 == 3) then
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
			if (0 == FlatIdent_43862) then
				Left = gBits32();
				Right = gBits32();
				FlatIdent_43862 = 1;
			end
			if (FlatIdent_43862 == 2) then
				Exponent = gBit(Right, 21, 31);
				Sign = ((gBit(Right, 32) == 1) and -1) or 1;
				FlatIdent_43862 = 3;
			end
		end
	end
	local function gString(Len)
		local Str;
		if not Len then
			local FlatIdent_A36C = 0;
			while true do
				if (FlatIdent_A36C == 0) then
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
			local FlatIdent_7F35E = 0;
			local Descriptor;
			while true do
				if (FlatIdent_7F35E == 0) then
					Descriptor = gBits8();
					if (gBit(Descriptor, 1, 1) == 0) then
						local FlatIdent_A9A3 = 0;
						local Type;
						local Mask;
						local Inst;
						while true do
							if (FlatIdent_A9A3 == 0) then
								Type = gBit(Descriptor, 2, 3);
								Mask = gBit(Descriptor, 4, 6);
								FlatIdent_A9A3 = 1;
							end
							if (1 == FlatIdent_A9A3) then
								Inst = {gBits16(),gBits16(),nil,nil};
								if (Type == 0) then
									local FlatIdent_2AC68 = 0;
									while true do
										if (FlatIdent_2AC68 == 0) then
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
								FlatIdent_A9A3 = 2;
							end
							if (FlatIdent_A9A3 == 2) then
								if (gBit(Mask, 1, 1) == 1) then
									Inst[2] = Consts[Inst[2]];
								end
								if (gBit(Mask, 2, 2) == 1) then
									Inst[3] = Consts[Inst[3]];
								end
								FlatIdent_A9A3 = 3;
							end
							if (FlatIdent_A9A3 == 3) then
								if (gBit(Mask, 3, 3) == 1) then
									Inst[4] = Consts[Inst[4]];
								end
								Instrs[Idx] = Inst;
								break;
							end
						end
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
				if (Enum <= 29) then
					if (Enum <= 14) then
						if (Enum <= 6) then
							if (Enum <= 2) then
								if (Enum <= 0) then
									Stk[Inst[2]][Inst[3]] = Inst[4];
								elseif (Enum == 1) then
									local FlatIdent_1B51D = 0;
									local B;
									local A;
									while true do
										if (FlatIdent_1B51D == 5) then
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_1B51D = 6;
										end
										if (FlatIdent_1B51D == 0) then
											B = nil;
											A = nil;
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											FlatIdent_1B51D = 1;
										end
										if (FlatIdent_1B51D == 4) then
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											FlatIdent_1B51D = 5;
										end
										if (FlatIdent_1B51D == 8) then
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											Inst = Instr[VIP];
											VIP = Inst[3];
											break;
										end
										if (FlatIdent_1B51D == 2) then
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_1B51D = 3;
										end
										if (FlatIdent_1B51D == 1) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_1B51D = 2;
										end
										if (FlatIdent_1B51D == 6) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											FlatIdent_1B51D = 7;
										end
										if (FlatIdent_1B51D == 7) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_1B51D = 8;
										end
										if (FlatIdent_1B51D == 3) then
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_1B51D = 4;
										end
									end
								else
									local B = Inst[3];
									local K = Stk[B];
									for Idx = B + 1, Inst[4] do
										K = K .. Stk[Idx];
									end
									Stk[Inst[2]] = K;
								end
							elseif (Enum <= 4) then
								if (Enum > 3) then
									local FlatIdent_52551 = 0;
									local B;
									local T;
									local A;
									while true do
										if (5 == FlatIdent_52551) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_52551 = 6;
										end
										if (FlatIdent_52551 == 1) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Stk[A + 1]);
											FlatIdent_52551 = 2;
										end
										if (4 == FlatIdent_52551) then
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = {};
											FlatIdent_52551 = 5;
										end
										if (FlatIdent_52551 == 3) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_52551 = 4;
										end
										if (FlatIdent_52551 == 2) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_52551 = 3;
										end
										if (FlatIdent_52551 == 6) then
											Inst = Instr[VIP];
											A = Inst[2];
											T = Stk[A];
											B = Inst[3];
											FlatIdent_52551 = 7;
										end
										if (FlatIdent_52551 == 7) then
											for Idx = 1, B do
												T[Idx] = Stk[A + Idx];
											end
											break;
										end
										if (FlatIdent_52551 == 0) then
											B = nil;
											T = nil;
											A = nil;
											Stk[Inst[2]][Inst[3]] = Inst[4];
											FlatIdent_52551 = 1;
										end
									end
								else
									for Idx = Inst[2], Inst[3] do
										Stk[Idx] = nil;
									end
								end
							elseif (Enum == 5) then
								local B;
								local A;
								Stk[Inst[2]] = Stk[Inst[3]];
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
							else
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							end
						elseif (Enum <= 10) then
							if (Enum <= 8) then
								if (Enum == 7) then
									local FlatIdent_28F3E = 0;
									local A;
									while true do
										if (FlatIdent_28F3E == 6) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_28F3E = 7;
										end
										if (FlatIdent_28F3E == 7) then
											A = Inst[2];
											Stk[A] = Stk[A]();
											break;
										end
										if (FlatIdent_28F3E == 2) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											FlatIdent_28F3E = 3;
										end
										if (FlatIdent_28F3E == 1) then
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											FlatIdent_28F3E = 2;
										end
										if (FlatIdent_28F3E == 5) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_28F3E = 6;
										end
										if (0 == FlatIdent_28F3E) then
											A = nil;
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_28F3E = 1;
										end
										if (FlatIdent_28F3E == 4) then
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											FlatIdent_28F3E = 5;
										end
										if (FlatIdent_28F3E == 3) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_28F3E = 4;
										end
									end
								else
									Stk[Inst[2]]();
								end
							elseif (Enum > 9) then
								Stk[Inst[2]] = Inst[3];
							else
								local FlatIdent_6A091 = 0;
								local A;
								local Results;
								local Limit;
								local Edx;
								while true do
									if (1 == FlatIdent_6A091) then
										Top = (Limit + A) - 1;
										Edx = 0;
										FlatIdent_6A091 = 2;
									end
									if (FlatIdent_6A091 == 0) then
										A = Inst[2];
										Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
										FlatIdent_6A091 = 1;
									end
									if (FlatIdent_6A091 == 2) then
										for Idx = A, Top do
											Edx = Edx + 1;
											Stk[Idx] = Results[Edx];
										end
										break;
									end
								end
							end
						elseif (Enum <= 12) then
							if (Enum > 11) then
								Stk[Inst[2]] = Stk[Inst[3]];
							else
								local FlatIdent_7DFA5 = 0;
								local B;
								local T;
								local A;
								while true do
									if (FlatIdent_7DFA5 == 7) then
										for Idx = 1, B do
											T[Idx] = Stk[A + Idx];
										end
										break;
									end
									if (FlatIdent_7DFA5 == 5) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_7DFA5 = 6;
									end
									if (FlatIdent_7DFA5 == 4) then
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = {};
										FlatIdent_7DFA5 = 5;
									end
									if (FlatIdent_7DFA5 == 0) then
										B = nil;
										T = nil;
										A = nil;
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										FlatIdent_7DFA5 = 1;
									end
									if (FlatIdent_7DFA5 == 2) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										FlatIdent_7DFA5 = 3;
									end
									if (FlatIdent_7DFA5 == 6) then
										Inst = Instr[VIP];
										A = Inst[2];
										T = Stk[A];
										B = Inst[3];
										FlatIdent_7DFA5 = 7;
									end
									if (FlatIdent_7DFA5 == 1) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										FlatIdent_7DFA5 = 2;
									end
									if (FlatIdent_7DFA5 == 3) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_7DFA5 = 4;
									end
								end
							end
						elseif (Enum == 13) then
							local FlatIdent_77172 = 0;
							local B;
							local T;
							local A;
							while true do
								if (FlatIdent_77172 == 0) then
									B = nil;
									T = nil;
									A = nil;
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									FlatIdent_77172 = 1;
								end
								if (FlatIdent_77172 == 6) then
									for Idx = 1, B do
										T[Idx] = Stk[A + Idx];
									end
									break;
								end
								if (FlatIdent_77172 == 1) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = {};
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									FlatIdent_77172 = 2;
								end
								if (FlatIdent_77172 == 5) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									T = Stk[A];
									B = Inst[3];
									FlatIdent_77172 = 6;
								end
								if (FlatIdent_77172 == 2) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_77172 = 3;
								end
								if (FlatIdent_77172 == 3) then
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									FlatIdent_77172 = 4;
								end
								if (FlatIdent_77172 == 4) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = {};
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									FlatIdent_77172 = 5;
								end
							end
						else
							local A;
							local K;
							local B;
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
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
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
						end
					elseif (Enum <= 21) then
						if (Enum <= 17) then
							if (Enum <= 15) then
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
							elseif (Enum > 16) then
								Stk[Inst[2]][Inst[3]] = Inst[4];
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
							else
								local FlatIdent_44265 = 0;
								while true do
									if (FlatIdent_44265 == 0) then
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_44265 = 1;
									end
									if (FlatIdent_44265 == 2) then
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_44265 = 3;
									end
									if (FlatIdent_44265 == 1) then
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_44265 = 2;
									end
									if (FlatIdent_44265 == 3) then
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_44265 = 4;
									end
									if (FlatIdent_44265 == 4) then
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_44265 = 5;
									end
									if (FlatIdent_44265 == 5) then
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_44265 = 6;
									end
									if (FlatIdent_44265 == 6) then
										Stk[Inst[2]] = Inst[3];
										break;
									end
								end
							end
						elseif (Enum <= 19) then
							if (Enum > 18) then
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
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							end
						elseif (Enum > 20) then
							VIP = Inst[3];
						else
							local A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
						end
					elseif (Enum <= 25) then
						if (Enum <= 23) then
							if (Enum > 22) then
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
						elseif (Enum == 24) then
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
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							if (Stk[Inst[2]] == Inst[4]) then
								VIP = VIP + 1;
							else
								VIP = Inst[3];
							end
						else
							local A = Inst[2];
							Stk[A](Stk[A + 1]);
						end
					elseif (Enum <= 27) then
						if (Enum == 26) then
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
							local FlatIdent_7873D = 0;
							local A;
							while true do
								if (FlatIdent_7873D == 5) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_7873D = 6;
								end
								if (FlatIdent_7873D == 1) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									FlatIdent_7873D = 2;
								end
								if (0 == FlatIdent_7873D) then
									A = nil;
									Stk[Inst[2]] = {};
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									FlatIdent_7873D = 1;
								end
								if (FlatIdent_7873D == 4) then
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Stk[A + 1]);
									FlatIdent_7873D = 5;
								end
								if (FlatIdent_7873D == 6) then
									Stk[Inst[2]] = Env[Inst[3]];
									break;
								end
								if (FlatIdent_7873D == 2) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									FlatIdent_7873D = 3;
								end
								if (FlatIdent_7873D == 3) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = {};
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_7873D = 4;
								end
							end
						end
					elseif (Enum == 28) then
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
						local A = Inst[2];
						Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
					end
				elseif (Enum <= 44) then
					if (Enum <= 36) then
						if (Enum <= 32) then
							if (Enum <= 30) then
								local FlatIdent_985A2 = 0;
								local A;
								while true do
									if (FlatIdent_985A2 == 7) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										break;
									end
									if (FlatIdent_985A2 == 4) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										FlatIdent_985A2 = 5;
									end
									if (FlatIdent_985A2 == 0) then
										A = nil;
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										FlatIdent_985A2 = 1;
									end
									if (3 == FlatIdent_985A2) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										FlatIdent_985A2 = 4;
									end
									if (FlatIdent_985A2 == 6) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										FlatIdent_985A2 = 7;
									end
									if (1 == FlatIdent_985A2) then
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										FlatIdent_985A2 = 2;
									end
									if (FlatIdent_985A2 == 5) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = {};
										FlatIdent_985A2 = 6;
									end
									if (FlatIdent_985A2 == 2) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										FlatIdent_985A2 = 3;
									end
								end
							elseif (Enum > 31) then
								local FlatIdent_145D2 = 0;
								local B;
								local A;
								while true do
									if (5 == FlatIdent_145D2) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										FlatIdent_145D2 = 6;
									end
									if (FlatIdent_145D2 == 8) then
										Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										FlatIdent_145D2 = 9;
									end
									if (FlatIdent_145D2 == 3) then
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										FlatIdent_145D2 = 4;
									end
									if (FlatIdent_145D2 == 0) then
										B = nil;
										A = nil;
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										FlatIdent_145D2 = 1;
									end
									if (FlatIdent_145D2 == 2) then
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_145D2 = 3;
									end
									if (FlatIdent_145D2 == 4) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										FlatIdent_145D2 = 5;
									end
									if (FlatIdent_145D2 == 9) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										FlatIdent_145D2 = 10;
									end
									if (FlatIdent_145D2 == 7) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										FlatIdent_145D2 = 8;
									end
									if (10 == FlatIdent_145D2) then
										Stk[A](Stk[A + 1]);
										VIP = VIP + 1;
										Inst = Instr[VIP];
										VIP = Inst[3];
										break;
									end
									if (FlatIdent_145D2 == 1) then
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_145D2 = 2;
									end
									if (FlatIdent_145D2 == 6) then
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_145D2 = 7;
									end
								end
							else
								local B = Stk[Inst[4]];
								if not B then
									VIP = VIP + 1;
								else
									Stk[Inst[2]] = B;
									VIP = Inst[3];
								end
							end
						elseif (Enum <= 34) then
							if (Enum > 33) then
								local A = Inst[2];
								Stk[A] = Stk[A]();
							elseif (Stk[Inst[2]] == Inst[4]) then
								VIP = VIP + 1;
							else
								VIP = Inst[3];
							end
						elseif (Enum > 35) then
							Stk[Inst[2]] = Env[Inst[3]];
						else
							local A = Inst[2];
							Stk[A] = Stk[A](Stk[A + 1]);
						end
					elseif (Enum <= 40) then
						if (Enum <= 38) then
							if (Enum > 37) then
								Env[Inst[3]] = Stk[Inst[2]];
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
								Stk[Inst[2]] = Inst[3];
							end
						elseif (Enum == 39) then
							if (Inst[2] == Stk[Inst[4]]) then
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
					elseif (Enum <= 42) then
						if (Enum == 41) then
							local FlatIdent_40096 = 0;
							local A;
							while true do
								if (FlatIdent_40096 == 3) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									FlatIdent_40096 = 4;
								end
								if (1 == FlatIdent_40096) then
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									FlatIdent_40096 = 2;
								end
								if (FlatIdent_40096 == 4) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									FlatIdent_40096 = 5;
								end
								if (7 == FlatIdent_40096) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									break;
								end
								if (FlatIdent_40096 == 0) then
									A = nil;
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									FlatIdent_40096 = 1;
								end
								if (FlatIdent_40096 == 5) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = {};
									FlatIdent_40096 = 6;
								end
								if (FlatIdent_40096 == 6) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									FlatIdent_40096 = 7;
								end
								if (FlatIdent_40096 == 2) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									FlatIdent_40096 = 3;
								end
							end
						else
							local A = Inst[2];
							Stk[A](Unpack(Stk, A + 1, Inst[3]));
						end
					elseif (Enum > 43) then
						local FlatIdent_14124 = 0;
						while true do
							if (FlatIdent_14124 == 3) then
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
								break;
							end
							if (FlatIdent_14124 == 2) then
								Inst = Instr[VIP];
								Stk[Inst[2]] = {};
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_14124 = 3;
							end
							if (FlatIdent_14124 == 0) then
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								FlatIdent_14124 = 1;
							end
							if (FlatIdent_14124 == 1) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								FlatIdent_14124 = 2;
							end
						end
					else
						Stk[Inst[2]] = Wrap(Proto[Inst[3]], nil, Env);
					end
				elseif (Enum <= 51) then
					if (Enum <= 47) then
						if (Enum <= 45) then
							local FlatIdent_11AA1 = 0;
							local B;
							local A;
							while true do
								if (FlatIdent_11AA1 == 0) then
									B = nil;
									A = nil;
									A = Inst[2];
									B = Stk[Inst[3]];
									FlatIdent_11AA1 = 1;
								end
								if (FlatIdent_11AA1 == 1) then
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_11AA1 = 2;
								end
								if (FlatIdent_11AA1 == 2) then
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									FlatIdent_11AA1 = 3;
								end
								if (FlatIdent_11AA1 == 7) then
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									FlatIdent_11AA1 = 8;
								end
								if (FlatIdent_11AA1 == 11) then
									Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									Inst = Instr[VIP];
									VIP = Inst[3];
									break;
								end
								if (FlatIdent_11AA1 == 9) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_11AA1 = 10;
								end
								if (FlatIdent_11AA1 == 4) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									FlatIdent_11AA1 = 5;
								end
								if (3 == FlatIdent_11AA1) then
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									FlatIdent_11AA1 = 4;
								end
								if (FlatIdent_11AA1 == 6) then
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									FlatIdent_11AA1 = 7;
								end
								if (FlatIdent_11AA1 == 8) then
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									FlatIdent_11AA1 = 9;
								end
								if (FlatIdent_11AA1 == 5) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_11AA1 = 6;
								end
								if (FlatIdent_11AA1 == 10) then
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									FlatIdent_11AA1 = 11;
								end
							end
						elseif (Enum > 46) then
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
							local FlatIdent_1CFC3 = 0;
							local A;
							local T;
							while true do
								if (FlatIdent_1CFC3 == 0) then
									A = Inst[2];
									T = Stk[A];
									FlatIdent_1CFC3 = 1;
								end
								if (FlatIdent_1CFC3 == 1) then
									for Idx = A + 1, Inst[3] do
										Insert(T, Stk[Idx]);
									end
									break;
								end
							end
						end
					elseif (Enum <= 49) then
						if (Enum > 48) then
							Stk[Inst[2]] = {};
						else
							Stk[Inst[2]] = Inst[3] ~= 0;
						end
					elseif (Enum > 50) then
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
						local FlatIdent_35C62 = 0;
						local T;
						local B;
						local A;
						while true do
							if (FlatIdent_35C62 == 3) then
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_35C62 = 4;
							end
							if (FlatIdent_35C62 == 9) then
								T = Stk[A];
								B = Inst[3];
								for Idx = 1, B do
									T[Idx] = Stk[A + Idx];
								end
								break;
							end
							if (FlatIdent_35C62 == 6) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								FlatIdent_35C62 = 7;
							end
							if (FlatIdent_35C62 == 1) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								FlatIdent_35C62 = 2;
							end
							if (FlatIdent_35C62 == 4) then
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								FlatIdent_35C62 = 5;
							end
							if (FlatIdent_35C62 == 7) then
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_35C62 = 8;
							end
							if (5 == FlatIdent_35C62) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								FlatIdent_35C62 = 6;
							end
							if (FlatIdent_35C62 == 2) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								FlatIdent_35C62 = 3;
							end
							if (FlatIdent_35C62 == 8) then
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								FlatIdent_35C62 = 9;
							end
							if (0 == FlatIdent_35C62) then
								T = nil;
								B = nil;
								A = nil;
								Stk[Inst[2]] = Inst[3];
								FlatIdent_35C62 = 1;
							end
						end
					end
				elseif (Enum <= 55) then
					if (Enum <= 53) then
						if (Enum == 52) then
							local A = Inst[2];
							local T = Stk[A];
							local B = Inst[3];
							for Idx = 1, B do
								T[Idx] = Stk[A + Idx];
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
					elseif (Enum == 54) then
						local FlatIdent_C79F = 0;
						local B;
						local A;
						while true do
							if (FlatIdent_C79F == 2) then
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								FlatIdent_C79F = 3;
							end
							if (FlatIdent_C79F == 3) then
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								FlatIdent_C79F = 4;
							end
							if (FlatIdent_C79F == 7) then
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								FlatIdent_C79F = 8;
							end
							if (FlatIdent_C79F == 4) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								FlatIdent_C79F = 5;
							end
							if (FlatIdent_C79F == 9) then
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								FlatIdent_C79F = 10;
							end
							if (FlatIdent_C79F == 5) then
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_C79F = 6;
							end
							if (FlatIdent_C79F == 11) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								FlatIdent_C79F = 12;
							end
							if (10 == FlatIdent_C79F) then
								Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								FlatIdent_C79F = 11;
							end
							if (FlatIdent_C79F == 8) then
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_C79F = 9;
							end
							if (FlatIdent_C79F == 0) then
								B = nil;
								A = nil;
								A = Inst[2];
								B = Stk[Inst[3]];
								FlatIdent_C79F = 1;
							end
							if (FlatIdent_C79F == 13) then
								Inst = Instr[VIP];
								VIP = Inst[3];
								break;
							end
							if (FlatIdent_C79F == 6) then
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								FlatIdent_C79F = 7;
							end
							if (FlatIdent_C79F == 12) then
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A](Stk[A + 1]);
								VIP = VIP + 1;
								FlatIdent_C79F = 13;
							end
							if (FlatIdent_C79F == 1) then
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_C79F = 2;
							end
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
				elseif (Enum <= 57) then
					if (Enum > 56) then
						local B;
						local A;
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
					else
						do
							return;
						end
					end
				elseif (Enum == 58) then
					local FlatIdent_59C45 = 0;
					local B;
					local A;
					while true do
						if (5 == FlatIdent_59C45) then
							Stk[A] = B[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A](Stk[A + 1]);
							VIP = VIP + 1;
							FlatIdent_59C45 = 6;
						end
						if (FlatIdent_59C45 == 1) then
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							FlatIdent_59C45 = 2;
						end
						if (3 == FlatIdent_59C45) then
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							FlatIdent_59C45 = 4;
						end
						if (FlatIdent_59C45 == 2) then
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							FlatIdent_59C45 = 3;
						end
						if (FlatIdent_59C45 == 4) then
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							B = Stk[Inst[3]];
							Stk[A + 1] = B;
							FlatIdent_59C45 = 5;
						end
						if (FlatIdent_59C45 == 7) then
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A](Stk[A + 1]);
							VIP = VIP + 1;
							Inst = Instr[VIP];
							VIP = Inst[3];
							break;
						end
						if (6 == FlatIdent_59C45) then
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							FlatIdent_59C45 = 7;
						end
						if (FlatIdent_59C45 == 0) then
							B = nil;
							A = nil;
							A = Inst[2];
							B = Stk[Inst[3]];
							Stk[A + 1] = B;
							Stk[A] = B[Inst[4]];
							FlatIdent_59C45 = 1;
						end
					end
				else
					local A = Inst[2];
					local B = Stk[Inst[3]];
					Stk[A + 1] = B;
					Stk[A] = B[Inst[4]];
				end
				VIP = VIP + 1;
			end
		end;
	end
	return Wrap(Deserialize(), {}, vmenv)(...);
end
return VMCall("LOL!7F3O00028O00026O001C4003093O00412O64546F2O676C6503043O004E616D6503093O00426173696320452O6703073O0044656661756C74010003083O0043612O6C6261636B03093O00466C616E7420452O6703093O004C6561667920452O67030A3O00412O6453656374696F6E03073O00576562482O6F6B030E3O00436F6D696E6720532O6F6E3O2E03793O00682O7470733A2O2F646973636F72642E636F6D2F6170692F776562682O6F6B732F3132352O302O323736393530313031323035392F55614C38333675677071653877525665612D4D634F6953705838334D7054344A34615A3538326B7836554B51526F486E6F6734466C48772O626C6E53442D5A775F56334D030C3O00436F6E74656E742D5479706503103O00612O706C69636174696F6E2F6A736F6E03063O00656D6265647303053O007469746C6503483O00203C613A33313630626F74646973636F72643A313235393034303330313931343235392O35363E20536F6D656F6E65204578656375746564203A205B20574F524C4420485542205D030B3O006465736372697074696F6E03283O00E289AB205B205374617475732047616D65205D20E289AA3O600A2O204578656375746F72203A2003103O006964656E746966796578656375746F7203183O003O60203O60436F6D696E6720532O6F6E3O2E3O6003053O00636F6C6F7203083O00746F6E756D626572023O0080769A5C4103063O006669656C647303043O006E616D65030B3O0047616D65204E616D653A2003053O0076616C756503043O0067616D65030A3O004765745365727669636503123O004D61726B6574706C61636553657276696365030E3O0047657450726F64756374496E666F03073O00506C616365496403063O00696E6C696E652O01030B3O00482O747053657276696365030A3O004A534F4E456E636F6465030C3O00682O74705F7265717565737403073O007265717565737403083O00482O7470506F73742O033O0073796E026O00F03F026O00104003093O0065717569704265737403053O006175746F3103053O006175746F3203053O006175746F3303073O004D616B6554616203133O00E289AB20496E666F726D6174696F6E20E289AA026O001440026O00084003023O005F4703073O006175746F546170030B3O006175746F52656269727468027O0040030A3O004D616B654E6F7469666903053O005469746C65030B3O004E68E1BAAD74204D696E6803043O005465787403183O0057656C636F6D652053637269707420576F726C642048756203043O0054696D6503093O00576F726C642048756203263O004C6F6164696E6720536372697074203A2054612O70696E67204C6567656E64732046696E616C026O002440026O001840031D3O00646973636F72642E636F6D2F696E766974652F70734538455561396B6703083O004175746F20546170030C3O004175746F2052656269727468030A3O004571756970204265737403133O004175746F20452O6773203378204E6F742031782O033O0055726C03043O00426F647903063O004D6574686F6403043O00504F535403073O0048656164657273022O00188A0D410D4203063O00776F726C643103063O00776F726C643203053O00776F726C3303073O00506C6179657273030B3O004C6F63616C506C6179657203043O004B69636B03473O0047616D65204E6F742053752O706F727465642C204A6F696E20446973636F72642C20682O7470733A2O2F646973636F72642E636F6D2F696E766974652F70734538455561396B67030A3O006C6F6164737472696E6703073O00482O747047657403403O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F5245447A4855422F4C69627261727956322F6D61696E2F7265647A4C6962030A3O004D616B6557696E646F772O033O0048756203093O00574F524C442048554203093O00416E696D6174696F6E03103O006279203A206E68E1BAAD74206D696E682O033O004B657903093O004B657953797374656D030A3O004B65792053797374656D030B3O004465736372697074696F6E034O0003073O004B65794C696E6B03163O00682O7470733A2O2F6269742E6C792F334C6E5375773003043O004B657973030C3O006E65777570646174652O303103063O004E6F74696669030D3O004E6F74696669636174696F6E73030A3O00436F2O726563744B657903153O0052752O6E696E6720746865205363726970743O2E030C3O00496E636F2O726563746B657903143O00546865206B657920697320696E636F2O72656374030B3O00436F70794B65794C696E6B03133O00436F7069656420746F20436C6970626F617264030E3O004D696E696D697A6542752O746F6E03053O00496D61676503183O00726278612O73657469643A2O2F312O37342O37352O37353903043O0053697A65026O00444003053O00436F6C6F7203063O00436F6C6F723303073O0066726F6D52474203063O00436F726E657203063O005374726F6B65030B3O005374726F6B65436F6C6F72025O00E06F40030C3O00E289AB204D61696E20E289AA030C3O00E289AB20452O677320E289AA030C3O00E289AB204D69736320E289AA03123O004F776E65723A204E68E1BAAD74204D696E6803123O0066622E636F6D2F6E6861746D696E68766E7A0045012O00120A3O00014O00030001000B3O0026213O002E000100020004153O002E0001001224000C00034O000C000D00084O0031000E3O000300302O000E0004000500302O000E0006000700022B000F5O001029000E0008000F4O000C000E00024O000B000C3O00122O000C00036O000D00086O000E3O000300302O000E0004000900302O000E0006000700022B000F00013O001029000E0008000F4O000C000E00024O000B000C3O00122O000C00036O000D00086O000E3O000300302O000E0004000A00302O000E0006000700022B000F00023O00102F000E0008000F4O000C000E00024O000B000C3O00122O000C000B6O000D00086O000E00013O00122O000F000C6O000E000100012O0014000C000E00022O0037000A000C3O00122O000C000B6O000D00086O000E00013O00122O000F000D6O000E000100012O0014000C000E00022O000C000A000C3O0004153O00442O010026213O0069000100010004153O0069000100120A0001000E4O0007000C3O000100302O000C000F00104O0002000C6O000C3O00014O000D00016O000E3O000400302O000E0012001300122O000F00153O00122O001000166O00100001000200120A001100174O000E000F000F001100102O000E0014000F00122O000F00193O00122O0010001A6O000F0002000200102O000E0018000F4O000F00016O00103O000300302O0010001C001D00122O0011001F3O00203B001100110020001232001300216O00110013000200202O00110011002200122O0013001F3O00202O0013001300234O00110013000200202O00110011000400102O0010001E001100302O0010002400254O000F00010001001012000E001B000F2O0034000D00010001001012000C0011000D2O00050003000C3O00122O000C001F3O00202O000C000C002000122O000E00266O000C000E000200202O000C000C00274O000E00036O000C000E00024O0004000C3O00122O000C00283O00061F000500680001000C0004153O00680001001224000C00293O00061F000500680001000C0004153O00680001001224000C002A3O00061F000500680001000C0004153O00680001001224000C002B3O0020060005000C002900120A3O002C3O0026213O00790001002D0004153O0079000100022B000C00033O001226000C002E3O00022B000C00043O001226000C002F3O00022B000C00053O001226000C00303O00022B000C00063O001225000C00313O00122O000C00326O000D3O000100302O000D000400334O000C000200024O0006000C3O00124O00343O000E270035008600013O0004153O00860001001224000C00363O003011000C002F002500122O000C00363O00302O000C0030002500122O000C00363O00302O000C0031002500022B000C00073O001226000C00373O00022B000C00083O001226000C00383O00120A3O002D3O0026213O009B000100390004153O009B0001001224000C003A4O000F000D3O000300302O000D003B003C00302O000D003D003E00302O000D003F00344O000C0002000100122O000C003A6O000D3O000300302O000D003B004000302O000D003D004100302O000D003F00422O0019000C00020001001210000C00363O00302O000C0037002500122O000C00363O00302O000C0038002500122O000C00363O00302O000C002E002500124O00353O0026213O00C7000100430004153O00C70001001224000C000B4O000C000D00064O0031000E00013O00120A000F00444O0034000E000100012O0014000C000E00022O002C000A000C3O00122O000C00036O000D00076O000E3O000300302O000E0004004500302O000E0006000700022B000F00093O001029000E0008000F4O000C000E00024O000B000C3O00122O000C00036O000D00076O000E3O000300302O000E0004004600302O000E0006000700022B000F000A3O001029000E0008000F4O000C000E00024O000B000C3O00122O000C00036O000D00096O000E3O000300302O000E0004004700302O000E0006000700022B000F000B3O00102F000E0008000F4O000C000E00024O000B000C3O00122O000C000B6O000D00086O000E00013O00122O000F00486O000E000100012O0014000C000E00022O000C000A000C3O00120A3O00023O000E27002C00232O013O0004153O00232O012O000C000C00054O0018000D3O000400102O000D0049000100102O000D004A000400302O000D004B004C00102O000D004D00024O000C0002000100122O000C001F3O00202O000C000C002300262O000C00D70001004E0004153O00D700012O0030000C00013O001226000C004F3O0004153O00EB0001001224000C001F3O002006000C000C0023002621000C00DE0001004E0004153O00DE00012O0030000C00013O001226000C00503O0004153O00EB0001001224000C001F3O002006000C000C0023002621000C00E50001004E0004153O00E500012O0030000C00013O001226000C00513O0004153O00EB0001001224000C001F3O002039000C000C005200202O000C000C005300202O000C000C005400122O000E00556O000C000E0001001224000C00563O001213000D001F3O00202O000D000D005700122O000F00586O000D000F6O000C3O00024O000C0001000100122O000C00596O000D3O00024O000E3O000200302O000E003B005B00302O000E005C005D00100D000D005A000E4O000E3O000600302O000E005F000700302O000E003B006000302O000E0061006200302O000E006300644O000F00013O00122O001000666O000F00010001001012000E0065000F2O0017000F3O000400302O000F0068002500302O000F0069006A00302O000F006B006C00302O000F006D006E00102O000E0067000F00102O000D005E000E4O000C0002000100122O000C006F6O000D3O000600302O000D007000712O0031000E00023O00120A000F00733O00120A001000734O0034000E00020001001012000D0072000E00121A000E00753O00202O000E000E007600122O000F00423O00122O001000423O00122O001100426O000E0011000200102O000D0074000E00302O000D0077002500302O000D0078000700122O000E00753O002006000E000E0076001228000F007A3O00122O001000013O00122O001100016O000E0011000200102O000D0079000E4O000C0002000100124O00393O0026213O0002000100340004153O00020001001224000C00324O001B000D3O000100302O000D0004007B4O000C000200024O0007000C3O00122O000C00326O000D3O000100302O000D0004007C4O000C000200024O0008000C3O00122O000C00324O0031000D3O0001003004000D0004007D4O000C000200024O0009000C3O00122O000C000B6O000D00066O000E00013O00122O000F007E6O000E000100012O0014000C000E00022O0037000A000C3O00122O000C000B6O000D00066O000E00013O00122O000F007F6O000E000100012O0014000C000E00022O000C000A000C3O00120A3O00433O0004153O000200012O00383O00013O000C3O00033O00028O0003023O005F4703053O006175746F3101103O00120A000100014O0003000200023O00262100010002000100010004153O0002000100120A000200013O000E2700010005000100020004153O00050001001224000300023O001012000300033O001224000300034O00080003000100010004153O000F00010004153O000500010004153O000F00010004153O000200012O00383O00017O00033O00028O0003023O005F4703053O006175746F3201103O00120A000100014O0003000200023O00262100010002000100010004153O0002000100120A000200013O00262100020005000100010004153O00050001001224000300023O001012000300033O001224000300034O00080003000100010004153O000F00010004153O000500010004153O000F00010004153O000200012O00383O00017O00033O00028O0003023O005F4703053O006175746F3301103O00120A000100014O0003000200023O00262100010002000100010004153O0002000100120A000200013O000E2700010005000100020004153O00050001001224000300023O001012000300033O001224000300034O00080003000100010004153O000F00010004153O000500010004153O000F00010004153O000200012O00383O00017O000F3O0003023O005F4703093O006571756970426573742O01028O0003043O0067616D65030A3O004765745365727669636503113O005265706C69636174656453746F72616765030D3O002O5347204672616D65776F726B03063O0053686172656403073O004E6574776F726B2O033O00706574030C3O00496E766F6B6553657276657203063O00416374696F6E030A3O004571756970204265737403043O0077616974001A3O0012243O00013O0020065O00020026213O0019000100030004153O0019000100120A3O00043O0026213O0005000100040004153O00050001001224000100053O00203500010001000600122O000300076O00010003000200202O00010001000800202O00010001000900202O00010001000A00202O00010001000B00202O00010001000C4O00033O000100302O0003000D000E4O00010003000100122O0001000F3O00122O000200046O00010002000100046O00010004153O000500010004155O00012O00383O00017O000F3O0003023O005F4703053O006175746F312O01028O0003043O0067616D65030A3O004765745365727669636503113O005265706C69636174656453746F72616765030D3O002O5347204672616D65776F726B03063O0053686172656403073O004E6574776F726B03073O0062757920652O67030C3O00496E766F6B6553657276657203093O00426173696320452O67026O00084003043O007761697400203O0012243O00013O0020065O00020026213O001F000100030004153O001F000100120A3O00044O0003000100013O000E270004000600013O0004153O0006000100120A000100043O00262100010009000100040004153O00090001001224000200053O00203600020002000600122O000400076O00020004000200202O00020002000800202O00020002000900202O00020002000A00202O00020002000B00202O00020002000C00122O0004000D3O00122O0005000E6O00020005000100122O0002000F3O00122O000300046O00020002000100046O00010004153O000900010004155O00010004153O000600010004155O00012O00383O00017O000F3O0003023O005F4703053O006175746F322O01028O0003043O0067616D65030A3O004765745365727669636503113O005265706C69636174656453746F72616765030D3O002O5347204672616D65776F726B03063O0053686172656403073O004E6574776F726B03073O0062757920652O67030C3O00496E766F6B6553657276657203093O00506C616E7420452O67026O00084003043O0077616974001A3O0012243O00013O0020065O00020026213O0019000100030004153O0019000100120A3O00043O0026213O0005000100040004153O00050001001224000100053O00203600010001000600122O000300076O00010003000200202O00010001000800202O00010001000900202O00010001000A00202O00010001000B00202O00010001000C00122O0003000D3O00122O0004000E6O00010004000100122O0001000F3O00122O000200046O00010002000100046O00010004153O000500010004155O00012O00383O00017O000F3O0003023O005F4703053O006175746F332O01028O0003043O0067616D65030A3O004765745365727669636503113O005265706C69636174656453746F72616765030D3O002O5347204672616D65776F726B03063O0053686172656403073O004E6574776F726B03073O0062757920652O67030C3O00496E766F6B6553657276657203093O004C6561667920452O67026O00084003043O0077616974001A3O0012243O00013O0020065O00020026213O0019000100030004153O0019000100120A3O00043O0026213O0005000100040004153O00050001001224000100053O00203600010001000600122O000300076O00010003000200202O00010001000800202O00010001000900202O00010001000A00202O00010001000B00202O00010001000C00122O0003000D3O00122O0004000E6O00010004000100122O0001000F3O00122O000200046O00010002000100046O00010004153O000500010004155O00012O00383O00017O000D3O0003023O005F4703073O006175746F5461702O01028O0003043O0067616D65030A3O004765745365727669636503113O005265706C69636174656453746F72616765030D3O002O5347204672616D65776F726B03063O0053686172656403073O004E6574776F726B2O033O00746170030A3O004669726553657276657203043O007761697400183O0012243O00013O0020065O00020026213O0017000100030004153O0017000100120A3O00043O0026213O0005000100040004153O00050001001224000100053O00203A00010001000600122O000300076O00010003000200202O00010001000800202O00010001000900202O00010001000A00202O00010001000B00202O00010001000C4O00010002000100122O0001000D3O00122O000200046O00010002000100046O00010004153O000500010004155O00012O00383O00017O000D3O0003023O005F47030B3O006175746F526562697274682O01028O0003043O0067616D65030A3O004765745365727669636503113O005265706C69636174656453746F72616765030D3O002O5347204672616D65776F726B03063O0053686172656403073O004E6574776F726B03073O0072656269727468030C3O00496E766F6B6553657276657203043O0077616974001E3O0012243O00013O0020065O00020026213O001D000100030004153O001D000100120A3O00044O0003000100013O000E270004000600013O0004153O0006000100120A000100043O00262100010009000100040004153O00090001001224000200053O00203A00020002000600122O000400076O00020004000200202O00020002000800202O00020002000900202O00020002000A00202O00020002000B00202O00020002000C4O00020002000100122O0002000D3O00122O000300046O00020002000100046O00010004153O000900010004155O00010004153O000600010004155O00012O00383O00017O00033O00028O0003023O005F4703073O006175746F54617001103O00120A000100014O0003000200023O00262100010002000100010004153O0002000100120A000200013O00262100020005000100010004153O00050001001224000300023O001012000300033O001224000300034O00080003000100010004153O000F00010004153O000500010004153O000F00010004153O000200012O00383O00017O00033O00028O0003023O005F47030B3O006175746F5265626972746801103O00120A000100014O0003000200023O00262100010002000100010004153O0002000100120A000200013O00262100020005000100010004153O00050001001224000300023O001012000300033O001224000300034O00080003000100010004153O000F00010004153O000500010004153O000F00010004153O000200012O00383O00017O00033O00028O0003023O005F4703093O0065717569704265737401103O00120A000100014O0003000200023O00262100010002000100010004153O0002000100120A000200013O00262100020005000100010004153O00050001001224000300023O001012000300033O001224000300034O00080003000100010004153O000F00010004153O000500010004153O000F00010004153O000200012O00383O00017O00", GetFEnv(), ...);