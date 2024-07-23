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
			local FlatIdent_76979 = 0;
			local a;
			while true do
				if (FlatIdent_76979 == 0) then
					a = Char(StrToNumber(byte, 16));
					if repeatNext then
						local FlatIdent_69270 = 0;
						local b;
						while true do
							if (FlatIdent_69270 == 1) then
								return b;
							end
							if (FlatIdent_69270 == 0) then
								b = Rep(a, repeatNext);
								repeatNext = nil;
								FlatIdent_69270 = 1;
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
			local Res = (Bit / (2 ^ (Start - 1))) % (2 ^ (((End - 1) - (Start - 1)) + 1));
			return Res - (Res % 1);
		else
			local FlatIdent_7126A = 0;
			local Plc;
			while true do
				if (FlatIdent_7126A == 0) then
					Plc = 2 ^ (Start - 1);
					return (((Bit % (Plc + Plc)) >= Plc) and 1) or 0;
				end
			end
		end
	end
	local function gBits8()
		local FlatIdent_12703 = 0;
		local a;
		while true do
			if (FlatIdent_12703 == 0) then
				a = Byte(ByteString, DIP, DIP);
				DIP = DIP + 1;
				FlatIdent_12703 = 1;
			end
			if (FlatIdent_12703 == 1) then
				return a;
			end
		end
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
			local FlatIdent_43862 = 0;
			while true do
				if (0 == FlatIdent_43862) then
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
				if (Enum <= 22) then
					if (Enum <= 10) then
						if (Enum <= 4) then
							if (Enum <= 1) then
								if (Enum == 0) then
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
									Stk[Inst[2]]();
								end
							elseif (Enum <= 2) then
								local FlatIdent_8F047 = 0;
								while true do
									if (2 == FlatIdent_8F047) then
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_8F047 = 3;
									end
									if (3 == FlatIdent_8F047) then
										Stk[Inst[2]][Inst[3]] = Inst[4];
										break;
									end
									if (FlatIdent_8F047 == 1) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = {};
										VIP = VIP + 1;
										FlatIdent_8F047 = 2;
									end
									if (FlatIdent_8F047 == 0) then
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										FlatIdent_8F047 = 1;
									end
								end
							elseif (Enum > 3) then
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
								for Idx = Inst[2], Inst[3] do
									Stk[Idx] = nil;
								end
							end
						elseif (Enum <= 7) then
							if (Enum <= 5) then
								local A;
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
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
							elseif (Enum > 6) then
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
									local FlatIdent_940A0 = 0;
									while true do
										if (FlatIdent_940A0 == 0) then
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
								do
									return;
								end
							elseif (Stk[Inst[2]] == Inst[4]) then
								VIP = VIP + 1;
							else
								VIP = Inst[3];
							end
						elseif (Enum <= 8) then
							Env[Inst[3]] = Stk[Inst[2]];
						elseif (Enum == 9) then
							local A;
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
						else
							VIP = Inst[3];
						end
					elseif (Enum <= 16) then
						if (Enum <= 13) then
							if (Enum <= 11) then
								Stk[Inst[2]] = Wrap(Proto[Inst[3]], nil, Env);
							elseif (Enum == 12) then
								do
									return;
								end
							else
								local FlatIdent_946F = 0;
								local B;
								local T;
								local A;
								while true do
									if (FlatIdent_946F == 5) then
										A = Inst[2];
										T = Stk[A];
										B = Inst[3];
										FlatIdent_946F = 6;
									end
									if (FlatIdent_946F == 2) then
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_946F = 3;
									end
									if (0 == FlatIdent_946F) then
										B = nil;
										T = nil;
										A = nil;
										FlatIdent_946F = 1;
									end
									if (FlatIdent_946F == 6) then
										for Idx = 1, B do
											T[Idx] = Stk[A + Idx];
										end
										break;
									end
									if (FlatIdent_946F == 3) then
										Stk[Inst[2]] = {};
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_946F = 4;
									end
									if (FlatIdent_946F == 4) then
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_946F = 5;
									end
									if (FlatIdent_946F == 1) then
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_946F = 2;
									end
								end
							end
						elseif (Enum <= 14) then
							local FlatIdent_25DF3 = 0;
							local B;
							local Edx;
							local Results;
							local Limit;
							local A;
							while true do
								if (FlatIdent_25DF3 == 10) then
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_25DF3 = 11;
								end
								if (FlatIdent_25DF3 == 1) then
									A = Inst[2];
									Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
									Top = (Limit + A) - 1;
									Edx = 0;
									FlatIdent_25DF3 = 2;
								end
								if (FlatIdent_25DF3 == 8) then
									Inst = Instr[VIP];
									A = Inst[2];
									Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
									Top = (Limit + A) - 1;
									FlatIdent_25DF3 = 9;
								end
								if (FlatIdent_25DF3 == 5) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_25DF3 = 6;
								end
								if (FlatIdent_25DF3 == 0) then
									B = nil;
									Edx = nil;
									Results, Limit = nil;
									A = nil;
									FlatIdent_25DF3 = 1;
								end
								if (FlatIdent_25DF3 == 4) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									FlatIdent_25DF3 = 5;
								end
								if (FlatIdent_25DF3 == 6) then
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									FlatIdent_25DF3 = 7;
								end
								if (FlatIdent_25DF3 == 11) then
									Stk[Inst[2]]();
									break;
								end
								if (FlatIdent_25DF3 == 9) then
									Edx = 0;
									for Idx = A, Top do
										Edx = Edx + 1;
										Stk[Idx] = Results[Edx];
									end
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_25DF3 = 10;
								end
								if (FlatIdent_25DF3 == 2) then
									for Idx = A, Top do
										Edx = Edx + 1;
										Stk[Idx] = Results[Edx];
									end
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									FlatIdent_25DF3 = 3;
								end
								if (FlatIdent_25DF3 == 7) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									FlatIdent_25DF3 = 8;
								end
								if (FlatIdent_25DF3 == 3) then
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]]();
									FlatIdent_25DF3 = 4;
								end
							end
						elseif (Enum == 15) then
							local A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
						else
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
						end
					elseif (Enum <= 19) then
						if (Enum <= 17) then
							Stk[Inst[2]] = Inst[3] ~= 0;
						elseif (Enum > 18) then
							local A = Inst[2];
							Stk[A](Stk[A + 1]);
						else
							local FlatIdent_6DC53 = 0;
							local A;
							while true do
								if (FlatIdent_6DC53 == 6) then
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									FlatIdent_6DC53 = 7;
								end
								if (FlatIdent_6DC53 == 9) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = {};
									break;
								end
								if (FlatIdent_6DC53 == 4) then
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									FlatIdent_6DC53 = 5;
								end
								if (FlatIdent_6DC53 == 1) then
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									FlatIdent_6DC53 = 2;
								end
								if (FlatIdent_6DC53 == 8) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									FlatIdent_6DC53 = 9;
								end
								if (5 == FlatIdent_6DC53) then
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									FlatIdent_6DC53 = 6;
								end
								if (FlatIdent_6DC53 == 7) then
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Stk[A + 1]);
									FlatIdent_6DC53 = 8;
								end
								if (FlatIdent_6DC53 == 3) then
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									FlatIdent_6DC53 = 4;
								end
								if (FlatIdent_6DC53 == 2) then
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									FlatIdent_6DC53 = 3;
								end
								if (0 == FlatIdent_6DC53) then
									A = nil;
									Stk[Inst[2]] = {};
									VIP = VIP + 1;
									FlatIdent_6DC53 = 1;
								end
							end
						end
					elseif (Enum <= 20) then
						local FlatIdent_45D37 = 0;
						local A;
						local Results;
						local Limit;
						local Edx;
						while true do
							if (FlatIdent_45D37 == 0) then
								A = Inst[2];
								Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
								FlatIdent_45D37 = 1;
							end
							if (FlatIdent_45D37 == 1) then
								Top = (Limit + A) - 1;
								Edx = 0;
								FlatIdent_45D37 = 2;
							end
							if (FlatIdent_45D37 == 2) then
								for Idx = A, Top do
									Edx = Edx + 1;
									Stk[Idx] = Results[Edx];
								end
								break;
							end
						end
					elseif (Enum > 21) then
						local A = Inst[2];
						Stk[A](Unpack(Stk, A + 1, Inst[3]));
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
						Stk[Inst[2]] = Env[Inst[3]];
					end
				elseif (Enum <= 34) then
					if (Enum <= 28) then
						if (Enum <= 25) then
							if (Enum <= 23) then
								local FlatIdent_DFF4 = 0;
								local B;
								local A;
								while true do
									if (FlatIdent_DFF4 == 3) then
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_DFF4 = 4;
									end
									if (FlatIdent_DFF4 == 4) then
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										FlatIdent_DFF4 = 5;
									end
									if (FlatIdent_DFF4 == 0) then
										B = nil;
										A = nil;
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										FlatIdent_DFF4 = 1;
									end
									if (FlatIdent_DFF4 == 6) then
										A = Inst[2];
										Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										FlatIdent_DFF4 = 7;
									end
									if (FlatIdent_DFF4 == 5) then
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_DFF4 = 6;
									end
									if (FlatIdent_DFF4 == 7) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A](Stk[A + 1]);
										FlatIdent_DFF4 = 8;
									end
									if (FlatIdent_DFF4 == 2) then
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_DFF4 = 3;
									end
									if (FlatIdent_DFF4 == 8) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										VIP = Inst[3];
										break;
									end
									if (FlatIdent_DFF4 == 1) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										FlatIdent_DFF4 = 2;
									end
								end
							elseif (Enum == 24) then
								local FlatIdent_5431F = 0;
								local Edx;
								local Results;
								local Limit;
								local B;
								local A;
								while true do
									if (FlatIdent_5431F == 1) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										FlatIdent_5431F = 2;
									end
									if (4 == FlatIdent_5431F) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_5431F = 5;
									end
									if (FlatIdent_5431F == 0) then
										Edx = nil;
										Results, Limit = nil;
										B = nil;
										A = nil;
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										FlatIdent_5431F = 1;
									end
									if (2 == FlatIdent_5431F) then
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_5431F = 3;
									end
									if (FlatIdent_5431F == 6) then
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										FlatIdent_5431F = 7;
									end
									if (FlatIdent_5431F == 7) then
										Stk[A] = B[Inst[4]];
										break;
									end
									if (FlatIdent_5431F == 3) then
										Inst = Instr[VIP];
										A = Inst[2];
										Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
										Top = (Limit + A) - 1;
										Edx = 0;
										for Idx = A, Top do
											Edx = Edx + 1;
											Stk[Idx] = Results[Edx];
										end
										FlatIdent_5431F = 4;
									end
									if (FlatIdent_5431F == 5) then
										Stk[Inst[2]]();
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_5431F = 6;
									end
								end
							else
								Stk[Inst[2]] = Stk[Inst[3]];
							end
						elseif (Enum <= 26) then
							local B;
							local T;
							local A;
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
						elseif (Enum == 27) then
							local FlatIdent_869A9 = 0;
							local B;
							local A;
							while true do
								if (FlatIdent_869A9 == 0) then
									B = nil;
									A = nil;
									A = Inst[2];
									B = Stk[Inst[3]];
									FlatIdent_869A9 = 1;
								end
								if (FlatIdent_869A9 == 7) then
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									FlatIdent_869A9 = 8;
								end
								if (FlatIdent_869A9 == 3) then
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									FlatIdent_869A9 = 4;
								end
								if (FlatIdent_869A9 == 4) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									FlatIdent_869A9 = 5;
								end
								if (6 == FlatIdent_869A9) then
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									FlatIdent_869A9 = 7;
								end
								if (11 == FlatIdent_869A9) then
									Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									Inst = Instr[VIP];
									VIP = Inst[3];
									break;
								end
								if (FlatIdent_869A9 == 10) then
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									FlatIdent_869A9 = 11;
								end
								if (FlatIdent_869A9 == 1) then
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_869A9 = 2;
								end
								if (FlatIdent_869A9 == 8) then
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									FlatIdent_869A9 = 9;
								end
								if (FlatIdent_869A9 == 9) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_869A9 = 10;
								end
								if (FlatIdent_869A9 == 2) then
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									FlatIdent_869A9 = 3;
								end
								if (FlatIdent_869A9 == 5) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_869A9 = 6;
								end
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
					elseif (Enum <= 31) then
						if (Enum <= 29) then
							local FlatIdent_3CDED = 0;
							local B;
							local A;
							while true do
								if (FlatIdent_3CDED == 5) then
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = {};
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_3CDED = 6;
								end
								if (FlatIdent_3CDED == 8) then
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									Inst = Instr[VIP];
									VIP = Inst[3];
									break;
								end
								if (6 == FlatIdent_3CDED) then
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									FlatIdent_3CDED = 7;
								end
								if (FlatIdent_3CDED == 7) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									FlatIdent_3CDED = 8;
								end
								if (FlatIdent_3CDED == 1) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									FlatIdent_3CDED = 2;
								end
								if (4 == FlatIdent_3CDED) then
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									FlatIdent_3CDED = 5;
								end
								if (0 == FlatIdent_3CDED) then
									B = nil;
									A = nil;
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									FlatIdent_3CDED = 1;
								end
								if (FlatIdent_3CDED == 3) then
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_3CDED = 4;
								end
								if (FlatIdent_3CDED == 2) then
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_3CDED = 3;
								end
							end
						elseif (Enum == 30) then
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
							local A;
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
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
					elseif (Enum <= 32) then
						local FlatIdent_7147 = 0;
						local B;
						local A;
						while true do
							if (FlatIdent_7147 == 1) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								FlatIdent_7147 = 2;
							end
							if (FlatIdent_7147 == 6) then
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								FlatIdent_7147 = 7;
							end
							if (FlatIdent_7147 == 4) then
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								FlatIdent_7147 = 5;
							end
							if (FlatIdent_7147 == 2) then
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_7147 = 3;
							end
							if (FlatIdent_7147 == 5) then
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A](Stk[A + 1]);
								VIP = VIP + 1;
								FlatIdent_7147 = 6;
							end
							if (FlatIdent_7147 == 0) then
								B = nil;
								A = nil;
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								FlatIdent_7147 = 1;
							end
							if (FlatIdent_7147 == 7) then
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A](Stk[A + 1]);
								VIP = VIP + 1;
								Inst = Instr[VIP];
								VIP = Inst[3];
								break;
							end
							if (3 == FlatIdent_7147) then
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_7147 = 4;
							end
						end
					elseif (Enum > 33) then
						local A = Inst[2];
						Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
					else
						Stk[Inst[2]] = {};
					end
				elseif (Enum <= 40) then
					if (Enum <= 37) then
						if (Enum <= 35) then
							Stk[Inst[2]] = Inst[3];
						elseif (Enum > 36) then
							local FlatIdent_3121 = 0;
							local A;
							while true do
								if (FlatIdent_3121 == 0) then
									A = Inst[2];
									Stk[A] = Stk[A](Stk[A + 1]);
									break;
								end
							end
						else
							local A = Inst[2];
							local T = Stk[A];
							local B = Inst[3];
							for Idx = 1, B do
								T[Idx] = Stk[A + Idx];
							end
						end
					elseif (Enum <= 38) then
						local B;
						local T;
						local A;
						Stk[Inst[2]][Inst[3]] = Inst[4];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						A = Inst[2];
						Stk[A] = Stk[A](Stk[A + 1]);
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
					elseif (Enum == 39) then
						local FlatIdent_90A69 = 0;
						local A;
						local T;
						while true do
							if (FlatIdent_90A69 == 1) then
								for Idx = A + 1, Inst[3] do
									Insert(T, Stk[Idx]);
								end
								break;
							end
							if (FlatIdent_90A69 == 0) then
								A = Inst[2];
								T = Stk[A];
								FlatIdent_90A69 = 1;
							end
						end
					else
						Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
					end
				elseif (Enum <= 43) then
					if (Enum <= 41) then
						local B;
						local T;
						local A;
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
					elseif (Enum > 42) then
						Stk[Inst[2]] = Env[Inst[3]];
					else
						local A = Inst[2];
						local B = Stk[Inst[3]];
						Stk[A + 1] = B;
						Stk[A] = B[Inst[4]];
					end
				elseif (Enum <= 44) then
					Stk[Inst[2]][Inst[3]] = Inst[4];
				elseif (Enum == 45) then
					local FlatIdent_92514 = 0;
					local A;
					while true do
						if (6 == FlatIdent_92514) then
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
							break;
						end
						if (FlatIdent_92514 == 3) then
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]];
							FlatIdent_92514 = 4;
						end
						if (FlatIdent_92514 == 2) then
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							FlatIdent_92514 = 3;
						end
						if (FlatIdent_92514 == 1) then
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							FlatIdent_92514 = 2;
						end
						if (FlatIdent_92514 == 0) then
							A = nil;
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							VIP = VIP + 1;
							FlatIdent_92514 = 1;
						end
						if (FlatIdent_92514 == 4) then
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = {};
							FlatIdent_92514 = 5;
						end
						if (FlatIdent_92514 == 5) then
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
							FlatIdent_92514 = 6;
						end
					end
				elseif (Inst[2] == Stk[Inst[4]]) then
					VIP = VIP + 1;
				else
					VIP = Inst[3];
				end
				VIP = VIP + 1;
			end
		end;
	end
	return Wrap(Deserialize(), {}, vmenv)(...);
end
return VMCall("LOL!4D3O00030A3O006C6F6164737472696E6703043O0067616D6503073O00482O7470476574034C3O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F4E6861744D696E68564E512F67616D656C6F2O6765722F6D61696E2F6E6861746D696E68647A2E6C7561034A3O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F4E6861744D696E68564E512F67616D656C6F2O6765722F6D61696E2F6E6861746D696E682E6C756103403O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F5245447A4855422F4C69627261727956322F6D61696E2F7265647A4C6962030A3O004D616B6557696E646F772O033O0048756203053O005469746C6503093O00574F524C442048554203093O00416E696D6174696F6E03103O006279203A206E68E1BAAD74206D696E682O033O004B657903093O004B657953797374656D0100030A3O004B65792053797374656D030B3O004465736372697074696F6E03273O004B65792046722O6520446973636F72643A20646973636F72642E2O672F70734538455561396B6703073O004B65794C696E6B03153O00646973636F72642E2O672F70734538455561396B6703043O004B657973030F3O00776F726C645F39313834373430313403063O004E6F74696669030D3O004E6F74696669636174696F6E732O01030A3O00436F2O726563744B657903153O0052752O6E696E6720746865205363726970743O2E030C3O00496E636F2O726563746B657903143O00546865206B657920697320696E636F2O72656374030B3O00436F70794B65794C696E6B03133O00436F7069656420746F20436C6970626F617264030E3O004D696E696D697A6542752O746F6E03053O00496D61676503183O00726278612O73657469643A2O2F312O37342O37352O37353903043O0053697A65026O00444003053O00436F6C6F7203063O00436F6C6F723303073O0066726F6D524742026O00244003063O00436F726E657203063O005374726F6B65030B3O005374726F6B65436F6C6F72025O00E06F40028O00030A3O004D616B654E6F74696669030B3O004E68E1BAAD74204D696E6803043O005465787403183O0057656C636F6D652053637269707420576F726C642048756203043O0054696D65026O00144003093O00576F726C642048756203263O004C6F6164696E6720536372697074203A2054612O70696E67204C6567656E64732046696E616C03023O005F4703073O006175746F546170030B3O006175746F5265626972746803093O00657175697042657374030E3O006175746F4461696C79436865737403073O004D616B6554616203043O004E616D6503133O00E289AB20496E666F726D6174696F6E20E289AA030C3O00E289AB204D61696E20E289AA030C3O00E289AB204D69736320E289AA030A3O00412O6453656374696F6E030D3O00574F524B494E47203A20E29C8503123O004F776E65723A204E68E1BAAD74204D696E6803123O0066622E636F6D2F6E6861746D696E68766E7A031D3O00646973636F72642E636F6D2F696E766974652F70734538455561396B6703093O00412O64546F2O676C6503083O004175746F2054617003073O0044656661756C7403083O0043612O6C6261636B030C3O004175746F2052656269727468030F3O004175746F204571756970204265737403103O004175746F204461696C7920436865737403093O00412O6442752O746F6E03083O00416E74692041666B00AD3O0012183O00013O00122O000100023O00202O00010001000300122O000300046O000100039O0000026O0001000100124O00013O00122O000100023O00202O000100010003001223000300054O000E000100039O0000026O0001000100124O00013O00122O000100023O00202O00010001000300122O000300066O000100039O0000026O0001000100122B3O00074O000400013O00024O00023O000200302O00020009000A00302O0002000B000C00102O0001000800024O00023O000600302O0002000E000F00302O00020009001000302O00020011001200302O0002001300142O0021000300013O001223000400164O0024000300010001002O100002001500032O001200033O000400302O00030018001900302O0003001A001B00302O0003001C001D00302O0003001E001F00102O00020017000300102O0001000D00026O0002000100124O00206O00013O000600302C0001002100222O0021000200023O001223000300243O001223000400244O0024000200020001002O1000010023000200122O000200263O00202O00020002002700122O000300283O00122O000400283O00122O000500286O00020005000200102O00010025000200302O00010029001900302O0001002A000F00122O000200263O00202800020002002700121E0003002C3O00122O0004002D3O00122O0005002D6O00020005000200102O0001002B00026O0002000100124O002E6O00013O000300302O00010009002F00302O00010030003100302C0001003200332O00093O0002000100124O002E6O00013O000300302O00010009003400302O00010030003500302O0001003200286O0002000100124O00363O00304O0037001900124O00363O00302C3O0038001900122B3O00363O00302C3O0039001900122B3O00363O00302C3O003A001900020B7O0012083O00373O00020B3O00013O0012083O00383O00020B3O00023O0012083O00393O00020B3O00033O0012153O003A3O00124O003B6O00013O000100302O0001003C003D6O0002000200122O0001003B6O00023O000100302O0002003C003E4O00010002000200122O0002003B4O002100033O00010030260003003C003F4O00020002000200122O000300406O00048O000500013O00122O000600416O0005000100012O0022000300050002001229000400406O00058O000600013O00122O000700426O0006000100012O0022000400060002001229000500406O00068O000700013O00122O000800436O0007000100012O0022000500070002001229000600406O00078O000800013O00122O000900446O0008000100012O0022000600080002001202000700456O000800016O00093O000300302O0009003C004600302O00090047000F00020B000A00043O00100500090048000A4O00070009000200122O000800456O000900016O000A3O000300302O000A003C004900302O000A0047000F00020B000B00053O001005000A0048000B4O0008000A000200122O000900456O000A00026O000B3O000300302O000B003C004A00302O000B0047000F00020B000C00063O001005000B0048000C4O0009000B000200122O000A00456O000B00026O000C3O000300302O000C003C004B00302O000C0047000F00020B000D00073O00101F000C0048000D4O000A000C000200122O000B004C6O000C00026O000D3O000200302O000D003C004D00020B000E00083O002O10000D0048000E2O0016000B000D00012O000C3O00013O00093O000D3O0003023O005F4703073O006175746F5461702O01028O0003043O0067616D65030A3O004765745365727669636503113O005265706C69636174656453746F72616765030D3O002O5347204672616D65776F726B03063O0053686172656403073O004E6574776F726B2O033O00746170030A3O004669726553657276657203043O007761697400183O00122B3O00013O0020285O00020026063O00170001000300040A3O001700010012233O00043O0026063O00050001000400040A3O0005000100122B000100053O00201B00010001000600122O000300076O00010003000200202O00010001000800202O00010001000900202O00010001000A00202O00010001000B00202O00010001000C4O00010002000100122O0001000D3O00122O000200046O00010002000100046O000100040A3O0005000100040A5O00012O000C3O00017O000D3O0003023O005F47030B3O006175746F526562697274682O01028O0003043O0067616D65030A3O004765745365727669636503113O005265706C69636174656453746F72616765030D3O002O5347204672616D65776F726B03063O0053686172656403073O004E6574776F726B03073O0072656269727468030C3O00496E766F6B6553657276657203043O007761697400183O00122B3O00013O0020285O00020026063O00170001000300040A3O001700010012233O00043O0026063O00050001000400040A3O0005000100122B000100053O00201B00010001000600122O000300076O00010003000200202O00010001000800202O00010001000900202O00010001000A00202O00010001000B00202O00010001000C4O00010002000100122O0001000D3O00122O000200046O00010002000100046O000100040A3O0005000100040A5O00012O000C3O00017O000F3O0003023O005F4703093O006571756970426573742O01028O0003043O0067616D65030A3O004765745365727669636503113O005265706C69636174656453746F72616765030D3O002O5347204672616D65776F726B03063O0053686172656403073O004E6574776F726B2O033O00706574030C3O00496E766F6B6553657276657203063O00416374696F6E030A3O004571756970204265737403043O007761697400203O00122B3O00013O0020285O00020026063O001F0001000300040A3O001F00010012233O00044O0003000100013O0026063O00060001000400040A3O00060001001223000100043O002606000100090001000400040A3O0009000100122B000200053O00201D00020002000600122O000400076O00020004000200202O00020002000800202O00020002000900202O00020002000A00202O00020002000B00202O00020002000C4O00043O000100302O0004000D000E4O00020004000100122O0002000F3O00122O000300046O00020002000100046O000100040A3O0009000100040A5O000100040A3O0006000100040A5O00012O000C3O00017O000E3O0003023O005F47030E3O006175746F4461696C7943686573742O01028O0003043O0067616D65030A3O004765745365727669636503113O005265706C69636174656453746F72616765030D3O002O5347204672616D65776F726B03063O0053686172656403073O004E6574776F726B030B3O006461696C79206368657374030C3O00496E766F6B65536572766572030B3O00537061776E20436865737403043O0077616974001F3O00122B3O00013O0020285O00020026063O001E0001000300040A3O001E00010012233O00044O0003000100013O0026063O00060001000400040A3O00060001001223000100043O002606000100090001000400040A3O0009000100122B000200053O00201700020002000600122O000400076O00020004000200202O00020002000800202O00020002000900202O00020002000A00202O00020002000B00202O00020002000C00122O0004000D6O00020004000100122O0002000E3O00122O000300046O00020002000100046O000100040A3O0009000100040A5O000100040A3O0006000100040A5O00012O000C3O00017O00033O00028O0003023O005F4703073O006175746F546170010A3O001223000100013O002606000100010001000100040A3O0001000100122B000200023O002O10000200033O00122B000200034O000100020001000100040A3O0009000100040A3O000100012O000C3O00017O00033O00028O0003023O005F47030B3O006175746F5265626972746801103O001223000100014O0003000200023O002606000100020001000100040A3O00020001001223000200013O002606000200050001000100040A3O0005000100122B000300023O002O10000300033O00122B000300034O000100030001000100040A3O000F000100040A3O0005000100040A3O000F000100040A3O000200012O000C3O00017O00033O00028O0003023O005F4703093O00657175697042657374010A3O001223000100013O000E2E000100010001000100040A3O0001000100122B000200023O002O10000200033O00122B000200034O000100020001000100040A3O0009000100040A3O000100012O000C3O00017O00033O00028O0003023O005F47030E3O006175746F4461696C79436865737401103O001223000100014O0003000200023O002606000100020001000100040A3O00020001001223000200013O000E2E000100050001000200040A3O0005000100122B000300023O002O10000300033O00122B000300034O000100030001000100040A3O000F000100040A3O0005000100040A3O000F000100040A3O000200012O000C3O00017O00043O00030A3O006C6F6164737472696E6703043O0067616D6503073O00482O747047657403473O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F4E6861744D696E68564E512F772D6875622F6D61696E2F416E746925323041666B2E6C756100093O0012073O00013O00122O000100023O00202O00010001000300122O000300046O000400016O000100049O0000026O000100016O00017O00", GetFEnv(), ...);