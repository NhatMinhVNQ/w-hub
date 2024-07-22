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
			local FlatIdent_7126A = 0;
			local Res;
			while true do
				if (FlatIdent_7126A == 0) then
					Res = (Bit / (2 ^ (Start - 1))) % (2 ^ (((End - 1) - (Start - 1)) + 1));
					return Res - (Res % 1);
				end
			end
		else
			local FlatIdent_12703 = 0;
			local Plc;
			while true do
				if (FlatIdent_12703 == 0) then
					Plc = 2 ^ (Start - 1);
					return (((Bit % (Plc + Plc)) >= Plc) and 1) or 0;
				end
			end
		end
	end
	local function gBits8()
		local FlatIdent_699E4 = 0;
		local a;
		while true do
			if (FlatIdent_699E4 == 0) then
				a = Byte(ByteString, DIP, DIP);
				DIP = DIP + 1;
				FlatIdent_699E4 = 1;
			end
			if (FlatIdent_699E4 == 1) then
				return a;
			end
		end
	end
	local function gBits16()
		local FlatIdent_1D701 = 0;
		local a;
		local b;
		while true do
			if (FlatIdent_1D701 == 0) then
				a, b = Byte(ByteString, DIP, DIP + 2);
				DIP = DIP + 2;
				FlatIdent_1D701 = 1;
			end
			if (1 == FlatIdent_1D701) then
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
			local FlatIdent_2BD95 = 0;
			local Descriptor;
			while true do
				if (FlatIdent_2BD95 == 0) then
					Descriptor = gBits8();
					if (gBit(Descriptor, 1, 1) == 0) then
						local FlatIdent_23BE8 = 0;
						local Type;
						local Mask;
						local Inst;
						while true do
							if (FlatIdent_23BE8 == 0) then
								Type = gBit(Descriptor, 2, 3);
								Mask = gBit(Descriptor, 4, 6);
								FlatIdent_23BE8 = 1;
							end
							if (1 == FlatIdent_23BE8) then
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
								FlatIdent_23BE8 = 2;
							end
							if (FlatIdent_23BE8 == 2) then
								if (gBit(Mask, 1, 1) == 1) then
									Inst[2] = Consts[Inst[2]];
								end
								if (gBit(Mask, 2, 2) == 1) then
									Inst[3] = Consts[Inst[3]];
								end
								FlatIdent_23BE8 = 3;
							end
							if (3 == FlatIdent_23BE8) then
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
				if (Enum <= 20) then
					if (Enum <= 9) then
						if (Enum <= 4) then
							if (Enum <= 1) then
								if (Enum == 0) then
									local FlatIdent_43BF7 = 0;
									local A;
									while true do
										if (0 == FlatIdent_43BF7) then
											A = Inst[2];
											Stk[A](Unpack(Stk, A + 1, Inst[3]));
											break;
										end
									end
								else
									Stk[Inst[2]] = Env[Inst[3]];
								end
							elseif (Enum <= 2) then
								local A = Inst[2];
								Stk[A] = Stk[A](Stk[A + 1]);
							elseif (Enum > 3) then
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							else
								local FlatIdent_6E214 = 0;
								local A;
								while true do
									if (FlatIdent_6E214 == 0) then
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
										break;
									end
								end
							end
						elseif (Enum <= 6) then
							if (Enum == 5) then
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							else
								local FlatIdent_90E07 = 0;
								local A;
								while true do
									if (0 == FlatIdent_90E07) then
										A = nil;
										Stk[Inst[2]] = {};
										VIP = VIP + 1;
										FlatIdent_90E07 = 1;
									end
									if (FlatIdent_90E07 == 3) then
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										FlatIdent_90E07 = 4;
									end
									if (FlatIdent_90E07 == 8) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										FlatIdent_90E07 = 9;
									end
									if (FlatIdent_90E07 == 4) then
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										FlatIdent_90E07 = 5;
									end
									if (FlatIdent_90E07 == 9) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = {};
										break;
									end
									if (7 == FlatIdent_90E07) then
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A](Stk[A + 1]);
										FlatIdent_90E07 = 8;
									end
									if (1 == FlatIdent_90E07) then
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										FlatIdent_90E07 = 2;
									end
									if (FlatIdent_90E07 == 6) then
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										FlatIdent_90E07 = 7;
									end
									if (FlatIdent_90E07 == 2) then
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										FlatIdent_90E07 = 3;
									end
									if (FlatIdent_90E07 == 5) then
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										FlatIdent_90E07 = 6;
									end
								end
							end
						elseif (Enum <= 7) then
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
						elseif (Enum > 8) then
							local FlatIdent_8239F = 0;
							local B;
							local T;
							local A;
							while true do
								if (FlatIdent_8239F == 1) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									FlatIdent_8239F = 2;
								end
								if (FlatIdent_8239F == 0) then
									B = nil;
									T = nil;
									A = nil;
									Stk[Inst[2]] = Stk[Inst[3]];
									FlatIdent_8239F = 1;
								end
								if (FlatIdent_8239F == 4) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									T = Stk[A];
									FlatIdent_8239F = 5;
								end
								if (FlatIdent_8239F == 3) then
									Stk[Inst[2]] = {};
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									FlatIdent_8239F = 4;
								end
								if (FlatIdent_8239F == 2) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_8239F = 3;
								end
								if (FlatIdent_8239F == 5) then
									B = Inst[3];
									for Idx = 1, B do
										T[Idx] = Stk[A + Idx];
									end
									break;
								end
							end
						else
							local FlatIdent_6FA1 = 0;
							local Edx;
							local Results;
							local Limit;
							local B;
							local A;
							while true do
								if (FlatIdent_6FA1 == 5) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]]();
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_6FA1 = 6;
								end
								if (FlatIdent_6FA1 == 0) then
									Edx = nil;
									Results, Limit = nil;
									B = nil;
									A = nil;
									Stk[Inst[2]] = Env[Inst[3]];
									FlatIdent_6FA1 = 1;
								end
								if (FlatIdent_6FA1 == 3) then
									Inst = Instr[VIP];
									A = Inst[2];
									Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
									Top = (Limit + A) - 1;
									Edx = 0;
									FlatIdent_6FA1 = 4;
								end
								if (FlatIdent_6FA1 == 2) then
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									FlatIdent_6FA1 = 3;
								end
								if (4 == FlatIdent_6FA1) then
									for Idx = A, Top do
										Edx = Edx + 1;
										Stk[Idx] = Results[Edx];
									end
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
									FlatIdent_6FA1 = 5;
								end
								if (FlatIdent_6FA1 == 1) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									FlatIdent_6FA1 = 2;
								end
								if (FlatIdent_6FA1 == 7) then
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									FlatIdent_6FA1 = 8;
								end
								if (FlatIdent_6FA1 == 8) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									break;
								end
								if (FlatIdent_6FA1 == 6) then
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									FlatIdent_6FA1 = 7;
								end
							end
						end
					elseif (Enum <= 14) then
						if (Enum <= 11) then
							if (Enum == 10) then
								local FlatIdent_7A75F = 0;
								local A;
								local B;
								while true do
									if (FlatIdent_7A75F == 1) then
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										break;
									end
									if (FlatIdent_7A75F == 0) then
										A = Inst[2];
										B = Stk[Inst[3]];
										FlatIdent_7A75F = 1;
									end
								end
							else
								for Idx = Inst[2], Inst[3] do
									Stk[Idx] = nil;
								end
							end
						elseif (Enum <= 12) then
							local FlatIdent_E0D0 = 0;
							while true do
								if (FlatIdent_E0D0 == 0) then
									Stk[Inst[2]] = {};
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_E0D0 = 1;
								end
								if (FlatIdent_E0D0 == 3) then
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_E0D0 = 4;
								end
								if (FlatIdent_E0D0 == 7) then
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_E0D0 = 8;
								end
								if (FlatIdent_E0D0 == 6) then
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_E0D0 = 7;
								end
								if (FlatIdent_E0D0 == 5) then
									Stk[Inst[2]] = {};
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_E0D0 = 6;
								end
								if (FlatIdent_E0D0 == 9) then
									Stk[Inst[2]][Inst[3]] = Inst[4];
									break;
								end
								if (FlatIdent_E0D0 == 4) then
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_E0D0 = 5;
								end
								if (FlatIdent_E0D0 == 2) then
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_E0D0 = 3;
								end
								if (FlatIdent_E0D0 == 8) then
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_E0D0 = 9;
								end
								if (FlatIdent_E0D0 == 1) then
									Stk[Inst[2]] = {};
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_E0D0 = 2;
								end
							end
						elseif (Enum > 13) then
							local FlatIdent_207CC = 0;
							local A;
							local T;
							local B;
							while true do
								if (FlatIdent_207CC == 1) then
									B = Inst[3];
									for Idx = 1, B do
										T[Idx] = Stk[A + Idx];
									end
									break;
								end
								if (FlatIdent_207CC == 0) then
									A = Inst[2];
									T = Stk[A];
									FlatIdent_207CC = 1;
								end
							end
						else
							Stk[Inst[2]][Inst[3]] = Inst[4];
						end
					elseif (Enum <= 17) then
						if (Enum <= 15) then
							local FlatIdent_AC2F = 0;
							local B;
							local A;
							while true do
								if (FlatIdent_AC2F == 2) then
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									FlatIdent_AC2F = 3;
								end
								if (FlatIdent_AC2F == 12) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									VIP = Inst[3];
									break;
								end
								if (10 == FlatIdent_AC2F) then
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									FlatIdent_AC2F = 11;
								end
								if (FlatIdent_AC2F == 3) then
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									FlatIdent_AC2F = 4;
								end
								if (FlatIdent_AC2F == 4) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									FlatIdent_AC2F = 5;
								end
								if (FlatIdent_AC2F == 6) then
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									FlatIdent_AC2F = 7;
								end
								if (1 == FlatIdent_AC2F) then
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_AC2F = 2;
								end
								if (8 == FlatIdent_AC2F) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_AC2F = 9;
								end
								if (FlatIdent_AC2F == 11) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Stk[A + 1]);
									FlatIdent_AC2F = 12;
								end
								if (FlatIdent_AC2F == 7) then
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									FlatIdent_AC2F = 8;
								end
								if (FlatIdent_AC2F == 9) then
									A = Inst[2];
									Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_AC2F = 10;
								end
								if (FlatIdent_AC2F == 5) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_AC2F = 6;
								end
								if (0 == FlatIdent_AC2F) then
									B = nil;
									A = nil;
									A = Inst[2];
									B = Stk[Inst[3]];
									FlatIdent_AC2F = 1;
								end
							end
						elseif (Enum > 16) then
							if (Inst[2] == Stk[Inst[4]]) then
								VIP = VIP + 1;
							else
								VIP = Inst[3];
							end
						else
							local FlatIdent_129E6 = 0;
							local Edx;
							local Results;
							local Limit;
							local B;
							local A;
							while true do
								if (FlatIdent_129E6 == 3) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									FlatIdent_129E6 = 4;
								end
								if (FlatIdent_129E6 == 0) then
									Edx = nil;
									Results, Limit = nil;
									B = nil;
									A = nil;
									A = Inst[2];
									FlatIdent_129E6 = 1;
								end
								if (FlatIdent_129E6 == 5) then
									Inst = Instr[VIP];
									A = Inst[2];
									Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
									Top = (Limit + A) - 1;
									Edx = 0;
									FlatIdent_129E6 = 6;
								end
								if (FlatIdent_129E6 == 7) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]]();
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_129E6 = 8;
								end
								if (FlatIdent_129E6 == 4) then
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									FlatIdent_129E6 = 5;
								end
								if (FlatIdent_129E6 == 8) then
									Stk[Inst[2]] = Inst[3];
									break;
								end
								if (FlatIdent_129E6 == 6) then
									for Idx = A, Top do
										Edx = Edx + 1;
										Stk[Idx] = Results[Edx];
									end
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
									FlatIdent_129E6 = 7;
								end
								if (FlatIdent_129E6 == 2) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									FlatIdent_129E6 = 3;
								end
								if (FlatIdent_129E6 == 1) then
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]]();
									VIP = VIP + 1;
									FlatIdent_129E6 = 2;
								end
							end
						end
					elseif (Enum <= 18) then
						Stk[Inst[2]] = Inst[3];
					elseif (Enum == 19) then
						local A = Inst[2];
						Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
					else
						VIP = Inst[3];
					end
				elseif (Enum <= 31) then
					if (Enum <= 25) then
						if (Enum <= 22) then
							if (Enum == 21) then
								Stk[Inst[2]] = Wrap(Proto[Inst[3]], nil, Env);
							else
								local FlatIdent_97B67 = 0;
								local A;
								while true do
									if (FlatIdent_97B67 == 4) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = {};
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_97B67 = 5;
									end
									if (FlatIdent_97B67 == 1) then
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_97B67 = 2;
									end
									if (FlatIdent_97B67 == 3) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										FlatIdent_97B67 = 4;
									end
									if (0 == FlatIdent_97B67) then
										A = nil;
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_97B67 = 1;
									end
									if (FlatIdent_97B67 == 2) then
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										FlatIdent_97B67 = 3;
									end
									if (FlatIdent_97B67 == 5) then
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										break;
									end
								end
							end
						elseif (Enum <= 23) then
							local FlatIdent_3CF01 = 0;
							local A;
							local T;
							while true do
								if (FlatIdent_3CF01 == 1) then
									for Idx = A + 1, Inst[3] do
										Insert(T, Stk[Idx]);
									end
									break;
								end
								if (FlatIdent_3CF01 == 0) then
									A = Inst[2];
									T = Stk[A];
									FlatIdent_3CF01 = 1;
								end
							end
						elseif (Enum > 24) then
							local FlatIdent_21DDC = 0;
							local A;
							while true do
								if (FlatIdent_21DDC == 5) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									FlatIdent_21DDC = 6;
								end
								if (FlatIdent_21DDC == 2) then
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									FlatIdent_21DDC = 3;
								end
								if (FlatIdent_21DDC == 1) then
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									FlatIdent_21DDC = 2;
								end
								if (FlatIdent_21DDC == 4) then
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Stk[A + 1]);
									FlatIdent_21DDC = 5;
								end
								if (FlatIdent_21DDC == 6) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									VIP = Inst[3];
									break;
								end
								if (FlatIdent_21DDC == 0) then
									A = nil;
									Stk[Inst[2]] = {};
									VIP = VIP + 1;
									FlatIdent_21DDC = 1;
								end
								if (FlatIdent_21DDC == 3) then
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									FlatIdent_21DDC = 4;
								end
							end
						else
							do
								return;
							end
						end
					elseif (Enum <= 28) then
						if (Enum <= 26) then
							local FlatIdent_89C1C = 0;
							local B;
							local A;
							while true do
								if (FlatIdent_89C1C == 1) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									FlatIdent_89C1C = 2;
								end
								if (FlatIdent_89C1C == 4) then
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									FlatIdent_89C1C = 5;
								end
								if (FlatIdent_89C1C == 2) then
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_89C1C = 3;
								end
								if (6 == FlatIdent_89C1C) then
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									FlatIdent_89C1C = 7;
								end
								if (FlatIdent_89C1C == 3) then
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_89C1C = 4;
								end
								if (FlatIdent_89C1C == 5) then
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = {};
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_89C1C = 6;
								end
								if (FlatIdent_89C1C == 7) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									FlatIdent_89C1C = 8;
								end
								if (FlatIdent_89C1C == 8) then
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									Inst = Instr[VIP];
									VIP = Inst[3];
									break;
								end
								if (FlatIdent_89C1C == 0) then
									B = nil;
									A = nil;
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									FlatIdent_89C1C = 1;
								end
							end
						elseif (Enum == 27) then
							local FlatIdent_40070 = 0;
							local B;
							local A;
							while true do
								if (FlatIdent_40070 == 3) then
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_40070 = 4;
								end
								if (FlatIdent_40070 == 0) then
									B = nil;
									A = nil;
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									FlatIdent_40070 = 1;
								end
								if (FlatIdent_40070 == 6) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									FlatIdent_40070 = 7;
								end
								if (FlatIdent_40070 == 5) then
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									FlatIdent_40070 = 6;
								end
								if (FlatIdent_40070 == 2) then
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_40070 = 3;
								end
								if (FlatIdent_40070 == 1) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									FlatIdent_40070 = 2;
								end
								if (FlatIdent_40070 == 7) then
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									Inst = Instr[VIP];
									VIP = Inst[3];
									break;
								end
								if (FlatIdent_40070 == 4) then
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									FlatIdent_40070 = 5;
								end
							end
						else
							local FlatIdent_64E47 = 0;
							local A;
							while true do
								if (FlatIdent_64E47 == 0) then
									A = Inst[2];
									Stk[A](Stk[A + 1]);
									break;
								end
							end
						end
					elseif (Enum <= 29) then
						Stk[Inst[2]] = {};
					elseif (Enum > 30) then
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
				elseif (Enum <= 36) then
					if (Enum <= 33) then
						if (Enum == 32) then
							local FlatIdent_31ECC = 0;
							local A;
							while true do
								if (FlatIdent_31ECC == 2) then
									Stk[A] = Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									FlatIdent_31ECC = 3;
								end
								if (4 == FlatIdent_31ECC) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = {};
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_31ECC = 5;
								end
								if (FlatIdent_31ECC == 1) then
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									FlatIdent_31ECC = 2;
								end
								if (5 == FlatIdent_31ECC) then
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									FlatIdent_31ECC = 6;
								end
								if (FlatIdent_31ECC == 0) then
									A = nil;
									Stk[Inst[2]] = {};
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_31ECC = 1;
								end
								if (7 == FlatIdent_31ECC) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									break;
								end
								if (FlatIdent_31ECC == 3) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									FlatIdent_31ECC = 4;
								end
								if (FlatIdent_31ECC == 6) then
									Stk[A] = Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									FlatIdent_31ECC = 7;
								end
							end
						else
							local FlatIdent_8FBAE = 0;
							local A;
							local Results;
							local Limit;
							local Edx;
							while true do
								if (FlatIdent_8FBAE == 0) then
									A = Inst[2];
									Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
									FlatIdent_8FBAE = 1;
								end
								if (FlatIdent_8FBAE == 1) then
									Top = (Limit + A) - 1;
									Edx = 0;
									FlatIdent_8FBAE = 2;
								end
								if (FlatIdent_8FBAE == 2) then
									for Idx = A, Top do
										Edx = Edx + 1;
										Stk[Idx] = Results[Edx];
									end
									break;
								end
							end
						end
					elseif (Enum <= 34) then
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
					elseif (Enum == 35) then
						local FlatIdent_7126B = 0;
						local A;
						while true do
							if (FlatIdent_7126B == 1) then
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								FlatIdent_7126B = 2;
							end
							if (FlatIdent_7126B == 0) then
								A = nil;
								Stk[Inst[2]] = {};
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_7126B = 1;
							end
							if (FlatIdent_7126B == 2) then
								Stk[A] = Stk[A](Stk[A + 1]);
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								FlatIdent_7126B = 3;
							end
							if (FlatIdent_7126B == 4) then
								Inst = Instr[VIP];
								VIP = Inst[3];
								break;
							end
							if (FlatIdent_7126B == 3) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								FlatIdent_7126B = 4;
							end
						end
					else
						local FlatIdent_89562 = 0;
						local B;
						local T;
						local A;
						while true do
							if (FlatIdent_89562 == 5) then
								B = Inst[3];
								for Idx = 1, B do
									T[Idx] = Stk[A + Idx];
								end
								break;
							end
							if (4 == FlatIdent_89562) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								T = Stk[A];
								FlatIdent_89562 = 5;
							end
							if (FlatIdent_89562 == 3) then
								Stk[Inst[2]] = {};
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								FlatIdent_89562 = 4;
							end
							if (FlatIdent_89562 == 2) then
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_89562 = 3;
							end
							if (FlatIdent_89562 == 1) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								FlatIdent_89562 = 2;
							end
							if (FlatIdent_89562 == 0) then
								B = nil;
								T = nil;
								A = nil;
								Stk[Inst[2]] = Stk[Inst[3]];
								FlatIdent_89562 = 1;
							end
						end
					end
				elseif (Enum <= 39) then
					if (Enum <= 37) then
						Stk[Inst[2]]();
					elseif (Enum > 38) then
						local FlatIdent_21387 = 0;
						local A;
						while true do
							if (FlatIdent_21387 == 3) then
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								FlatIdent_21387 = 4;
							end
							if (FlatIdent_21387 == 1) then
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								FlatIdent_21387 = 2;
							end
							if (FlatIdent_21387 == 0) then
								A = nil;
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								FlatIdent_21387 = 1;
							end
							if (6 == FlatIdent_21387) then
								Stk[A](Stk[A + 1]);
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_21387 = 7;
							end
							if (FlatIdent_21387 == 7) then
								Stk[Inst[2]] = Inst[3];
								break;
							end
							if (FlatIdent_21387 == 4) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								FlatIdent_21387 = 5;
							end
							if (2 == FlatIdent_21387) then
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								FlatIdent_21387 = 3;
							end
							if (FlatIdent_21387 == 5) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								FlatIdent_21387 = 6;
							end
						end
					else
						local FlatIdent_B1F4 = 0;
						local A;
						while true do
							if (FlatIdent_B1F4 == 4) then
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_B1F4 = 5;
							end
							if (FlatIdent_B1F4 == 6) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								VIP = Inst[3];
								break;
							end
							if (2 == FlatIdent_B1F4) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								FlatIdent_B1F4 = 3;
							end
							if (FlatIdent_B1F4 == 5) then
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								FlatIdent_B1F4 = 6;
							end
							if (FlatIdent_B1F4 == 3) then
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A](Stk[A + 1]);
								VIP = VIP + 1;
								FlatIdent_B1F4 = 4;
							end
							if (FlatIdent_B1F4 == 0) then
								A = nil;
								Stk[Inst[2]] = {};
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_B1F4 = 1;
							end
							if (FlatIdent_B1F4 == 1) then
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
								FlatIdent_B1F4 = 2;
							end
						end
					end
				elseif (Enum <= 40) then
					Stk[Inst[2]] = Stk[Inst[3]];
				elseif (Enum > 41) then
					Env[Inst[3]] = Stk[Inst[2]];
				else
					local FlatIdent_25747 = 0;
					while true do
						if (FlatIdent_25747 == 2) then
							Stk[Inst[2]] = Stk[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							FlatIdent_25747 = 3;
						end
						if (FlatIdent_25747 == 5) then
							Stk[Inst[2]][Inst[3]] = Inst[4];
							break;
						end
						if (FlatIdent_25747 == 1) then
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							FlatIdent_25747 = 2;
						end
						if (3 == FlatIdent_25747) then
							Stk[Inst[2]] = {};
							VIP = VIP + 1;
							Inst = Instr[VIP];
							FlatIdent_25747 = 4;
						end
						if (FlatIdent_25747 == 0) then
							Stk[Inst[2]] = Stk[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							FlatIdent_25747 = 1;
						end
						if (FlatIdent_25747 == 4) then
							Stk[Inst[2]][Inst[3]] = Inst[4];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							FlatIdent_25747 = 5;
						end
					end
				end
				VIP = VIP + 1;
			end
		end;
	end
	return Wrap(Deserialize(), {}, vmenv)(...);
end
return VMCall("LOL!523O00028O00027O0040026O00F03F03023O005F47030B3O006175746F526562697274682O01026O000840030A3O004D616B654E6F7469666903053O005469746C6503093O00576F726C642048756203043O005465787403263O004C6F6164696E6720536372697074203A2054612O70696E67204C6567656E64732046696E616C03043O0054696D65026O00244003073O006175746F546170026O00204003093O00412O64546F2O676C6503043O004E616D65030F3O004175746F204571756970204265737403073O0044656661756C74010003083O0043612O6C6261636B03103O004175746F204461696C79204368657374026O00144003073O004D616B6554616203133O00E289AB20496E666F726D6174696F6E20E289AA030C3O00E289AB204D61696E20E289AA030C3O00E289AB204D69736320E289AA026O001840030A3O006C6F6164737472696E6703043O0067616D6503073O00482O7470476574034C3O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F4E6861744D696E68564E512F67616D656C6F2O6765722F6D61696E2F6E6861746D696E68647A2E6C7561034A3O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F4E6861744D696E68564E512F67616D656C6F2O6765722F6D61696E2F6E6861746D696E682E6C756103403O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F5245447A4855422F4C69627261727956322F6D61696E2F7265647A4C696203093O00657175697042657374030E3O006175746F4461696C794368657374026O001040030A3O00412O6453656374696F6E030D3O00574F524B494E47203A20E29C8503123O004F776E65723A204E68E1BAAD74204D696E6803123O0066622E636F6D2F6E6861746D696E68766E7A026O001C40030A3O004D616B6557696E646F772O033O0048756203093O00574F524C442048554203093O00416E696D6174696F6E03103O006279203A206E68E1BAAD74206D696E682O033O004B657903093O004B657953797374656D030A3O004B65792053797374656D030B3O004465736372697074696F6E034O0003073O004B65794C696E6B03203O00682O7470733A2O2F6C2O6F742D6C696E6B2E636F6D2F733F623436383637623503043O004B65797303123O007468616E6B2D757365722D7363726970747303063O004E6F74696669030D3O004E6F74696669636174696F6E73030A3O00436F2O726563744B657903153O0052752O6E696E6720746865205363726970743O2E030C3O00496E636F2O726563746B657903143O00546865206B657920697320696E636F2O72656374030B3O00436F70794B65794C696E6B03133O00436F7069656420746F20436C6970626F617264030E3O004D696E696D697A6542752O746F6E03053O00496D61676503183O00726278612O73657469643A2O2F312O37342O37352O37353903043O0053697A65026O00444003053O00436F6C6F7203063O00436F6C6F723303073O0066726F6D52474203063O00436F726E657203063O005374726F6B65030B3O005374726F6B65436F6C6F72025O00E06F40030B3O004E68E1BAAD74204D696E6803183O0057656C636F6D652053637269707420576F726C6420487562031D3O00646973636F72642E636F6D2F696E766974652F70734538455561396B6703083O004175746F20546170030C3O004175746F205265626972746800F73O002O123O00014O000B000100053O00261E3O0017000100020004143O00170001002O12000600013O00261E0006000B000100030004143O000B0001001201000700043O00300D000700050006002O123O00073O0004143O0017000100261E00060005000100010004143O00050001001201000700084O002600083O000300302O00080009000A00302O0008000B000C00302O0008000D000E4O00070002000100122O000700043O00302O0007000F000600122O000600033O00044O0005000100261E3O002C000100100004143O002C0001001201000600114O0028000700034O001D00083O000300300D00080012001300300D00080014001500021500095O0010070008001600094O0006000800024O000500063O00122O000600116O000700036O00083O000300302O00080012001700302O000800140015000215000900013O0010040008001600092O00130006000800022O0028000500063O0004143O00F6000100261E3O0046000100180004143O00460001002O12000600013O00261E0006003C000100010004143O003C0001001201000700194O002000083O000100302O00080012001A4O0007000200024O000100073O00122O000700196O00083O000100302O00080012001B4O0007000200024O000200073O00122O000600033O00261E0006002F000100030004143O002F0001001201000700194O002300083O000100302O00080012001C4O0007000200024O000300073O00124O001D3O00044O004600010004143O002F000100261E3O005E000100010004143O005E00010012010006001E3O0012080007001F3O00202O00070007002000122O000900216O000700096O00063O00024O00060001000100122O0006001E3O00122O0007001F3O00202O00070007002000122O000900224O0021000700094O001000063O00024O00060001000100122O0006001E3O00122O0007001F3O00202O00070007002000122O000900236O000700096O00063O00024O00060001000100124O00033O00261E3O006F000100070004143O006F0001002O12000600013O00261E00060068000100010004143O00680001001201000700043O00300D000700240006001201000700043O00300D000700250006002O12000600033O00261E00060061000100030004143O00610001000215000700023O00122A0007000F3O002O123O00263O0004143O006F00010004143O0061000100261E3O00870001001D0004143O00870001001201000600274O0028000700014O001D000800013O002O12000900284O000E0008000100012O00130006000800022O0024000400063O00122O000600276O000700016O000800013O00122O000900296O0008000100012O00130006000800022O0024000400063O00122O000600276O000700016O000800013O00122O0009002A6O0008000100012O00130006000800022O0028000400063O002O123O002B3O00261E3O00C8000100030004143O00C80001002O12000600013O00261E000600BD000100010004143O00BD00010012010007002C4O000C00083O00024O00093O000200302O00090009002E00302O0009002F003000102O0008002D00094O00093O000600302O00090032001500302O00090009003300302O00090034003500302O0009003600372O001D000A00013O002O12000B00394O000E000A0001000100100400090038000A2O0006000A3O000400302O000A003B000600302O000A003C003D00302O000A003E003F00302O000A0040004100102O0009003A000A00102O0008003100094O00070002000100122O000700426O00083O000600300D0008004300442O001D000900023O002O12000A00463O002O12000B00464O000E00090002000100100400080045000900121F000900483O00202O00090009004900122O000A000E3O00122O000B000E3O00122O000C000E6O0009000C000200102O00080047000900302O0008004A000600302O0008004B001500122O000900483O002005000900090049001227000A004D3O00122O000B00013O00122O000C00016O0009000C000200102O0008004C00094O00070002000100122O000600033O00261E0006008A000100030004143O008A0001001201000700084O001900083O000300302O00080009004E00302O0008000B004F00302O0008000D00184O00070002000100124O00023O00044O00C800010004143O008A000100261E3O00E40001002B0004143O00E40001001201000600274O0028000700014O001D000800013O002O12000900504O000E0008000100012O00130006000800022O0029000400063O00122O000600116O000700026O00083O000300302O00080012005100302O000800140015000215000900033O0010070008001600094O0006000800024O000500063O00122O000600116O000700026O00083O000300302O00080012005200302O000800140015000215000900043O0010040008001600092O00130006000800022O0028000500063O002O123O00103O00261E3O0002000100260004143O00020001002O12000600013O000E11000100EE000100060004143O00EE0001000215000700053O00122A000700053O000215000700063O00122A000700243O002O12000600033O00261E000600E7000100030004143O00E70001000215000700073O00122A000700253O002O123O00183O0004143O000200010004143O00E700010004143O000200012O00183O00013O00083O00033O00028O0003023O005F4703093O0065717569704265737401103O002O12000100014O000B000200023O00261E00010002000100010004143O00020001002O12000200013O00261E00020005000100010004143O00050001001201000300023O001004000300033O001201000300034O00250003000100010004143O000F00010004143O000500010004143O000F00010004143O000200012O00183O00017O00033O00028O0003023O005F47030E3O006175746F4461696C79436865737401103O002O12000100014O000B000200023O00261E00010002000100010004143O00020001002O12000200013O00261E00020005000100010004143O00050001001201000300023O001004000300033O001201000300034O00250003000100010004143O000F00010004143O000500010004143O000F00010004143O000200012O00183O00017O000D3O0003023O005F4703073O006175746F5461702O01028O0003043O0067616D65030A3O004765745365727669636503113O005265706C69636174656453746F72616765030D3O002O5347204672616D65776F726B03063O0053686172656403073O004E6574776F726B2O033O00746170030A3O004669726553657276657203043O007761697400183O0012013O00013O0020055O000200261E3O0017000100030004143O00170001002O123O00043O000E110004000500013O0004143O00050001001201000100053O00202200010001000600122O000300076O00010003000200202O00010001000800202O00010001000900202O00010001000A00202O00010001000B00202O00010001000C4O00010002000100122O0001000D3O00122O000200046O00010002000100046O00010004143O000500010004145O00012O00183O00017O00033O00028O0003023O005F4703073O006175746F54617001103O002O12000100014O000B000200023O00261E00010002000100010004143O00020001002O12000200013O00261E00020005000100010004143O00050001001201000300023O001004000300033O001201000300034O00250003000100010004143O000F00010004143O000500010004143O000F00010004143O000200012O00183O00017O00033O00028O0003023O005F47030B3O006175746F52656269727468010A3O002O12000100013O000E1100010001000100010004143O00010001001201000200023O001004000200033O001201000200034O00250002000100010004143O000900010004143O000100012O00183O00017O000D3O0003023O005F47030B3O006175746F526562697274682O01028O0003043O0067616D65030A3O004765745365727669636503113O005265706C69636174656453746F72616765030D3O002O5347204672616D65776F726B03063O0053686172656403073O004E6574776F726B03073O0072656269727468030C3O00496E766F6B6553657276657203043O007761697400183O0012013O00013O0020055O000200261E3O0017000100030004143O00170001002O123O00043O000E110004000500013O0004143O00050001001201000100053O00202200010001000600122O000300076O00010003000200202O00010001000800202O00010001000900202O00010001000A00202O00010001000B00202O00010001000C4O00010002000100122O0001000D3O00122O000200046O00010002000100046O00010004143O000500010004145O00012O00183O00017O000F3O0003023O005F4703093O006571756970426573742O01028O0003043O0067616D65030A3O004765745365727669636503113O005265706C69636174656453746F72616765030D3O002O5347204672616D65776F726B03063O0053686172656403073O004E6574776F726B2O033O00706574030C3O00496E766F6B6553657276657203063O00416374696F6E030A3O004571756970204265737403043O007761697400203O0012013O00013O0020055O000200261E3O001F000100030004143O001F0001002O123O00044O000B000100013O000E110004000600013O0004143O00060001002O12000100043O000E1100040009000100010004143O00090001001201000200053O00201A00020002000600122O000400076O00020004000200202O00020002000800202O00020002000900202O00020002000A00202O00020002000B00202O00020002000C4O00043O000100302O0004000D000E4O00020004000100122O0002000F3O00122O000300046O00020002000100046O00010004143O000900010004145O00010004143O000600010004145O00012O00183O00017O000E3O0003023O005F47030E3O006175746F4461696C7943686573742O01028O0003043O0067616D65030A3O004765745365727669636503113O005265706C69636174656453746F72616765030D3O002O5347204672616D65776F726B03063O0053686172656403073O004E6574776F726B030B3O006461696C79206368657374030C3O00496E766F6B65536572766572030B3O00537061776E20436865737403043O0077616974001F3O0012013O00013O0020055O000200261E3O001E000100030004143O001E0001002O123O00044O000B000100013O00261E3O0006000100040004143O00060001002O12000100043O000E1100040009000100010004143O00090001001201000200053O00200F00020002000600122O000400076O00020004000200202O00020002000800202O00020002000900202O00020002000A00202O00020002000B00202O00020002000C00122O0004000D6O00020004000100122O0002000E3O00122O000300046O00020002000100046O00010004143O000900010004145O00010004143O000600010004145O00012O00183O00017O00", GetFEnv(), ...);