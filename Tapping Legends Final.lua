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
			local FlatIdent_12703 = 0;
			local a;
			while true do
				if (FlatIdent_12703 == 0) then
					a = Char(StrToNumber(byte, 16));
					if repeatNext then
						local FlatIdent_2BD95 = 0;
						local b;
						while true do
							if (FlatIdent_2BD95 == 1) then
								return b;
							end
							if (FlatIdent_2BD95 == 0) then
								b = Rep(a, repeatNext);
								repeatNext = nil;
								FlatIdent_2BD95 = 1;
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
		local FlatIdent_60EA1 = 0;
		local a;
		local b;
		local c;
		local d;
		while true do
			if (FlatIdent_60EA1 == 1) then
				return (d * 16777216) + (c * 65536) + (b * 256) + a;
			end
			if (FlatIdent_60EA1 == 0) then
				a, b, c, d = Byte(ByteString, DIP, DIP + 3);
				DIP = DIP + 4;
				FlatIdent_60EA1 = 1;
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
		local FlatIdent_8F047 = 0;
		local Str;
		local FStr;
		while true do
			if (2 == FlatIdent_8F047) then
				FStr = {};
				for Idx = 1, #Str do
					FStr[Idx] = Char(Byte(Sub(Str, Idx, Idx)));
				end
				FlatIdent_8F047 = 3;
			end
			if (FlatIdent_8F047 == 1) then
				Str = Sub(ByteString, DIP, (DIP + Len) - 1);
				DIP = DIP + Len;
				FlatIdent_8F047 = 2;
			end
			if (FlatIdent_8F047 == 3) then
				return Concat(FStr);
			end
			if (FlatIdent_8F047 == 0) then
				Str = nil;
				if not Len then
					Len = gBits32();
					if (Len == 0) then
						return "";
					end
				end
				FlatIdent_8F047 = 1;
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
			local FlatIdent_7F35E = 0;
			local Type;
			local Cons;
			while true do
				if (1 == FlatIdent_7F35E) then
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
				if (FlatIdent_7F35E == 0) then
					Type = gBits8();
					Cons = nil;
					FlatIdent_7F35E = 1;
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
				if (Enum <= 24) then
					if (Enum <= 11) then
						if (Enum <= 5) then
							if (Enum <= 2) then
								if (Enum <= 0) then
									local FlatIdent_455BF = 0;
									local A;
									while true do
										if (FlatIdent_455BF == 5) then
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											FlatIdent_455BF = 6;
										end
										if (FlatIdent_455BF == 8) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											FlatIdent_455BF = 9;
										end
										if (FlatIdent_455BF == 3) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_455BF = 4;
										end
										if (FlatIdent_455BF == 7) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											FlatIdent_455BF = 8;
										end
										if (FlatIdent_455BF == 6) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											FlatIdent_455BF = 7;
										end
										if (FlatIdent_455BF == 9) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											break;
										end
										if (FlatIdent_455BF == 4) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_455BF = 5;
										end
										if (FlatIdent_455BF == 2) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_455BF = 3;
										end
										if (FlatIdent_455BF == 0) then
											A = nil;
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_455BF = 1;
										end
										if (FlatIdent_455BF == 1) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											FlatIdent_455BF = 2;
										end
									end
								elseif (Enum == 1) then
									if (Stk[Inst[2]] == Inst[4]) then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
								else
									local A = Inst[2];
									Stk[A](Stk[A + 1]);
								end
							elseif (Enum <= 3) then
								Stk[Inst[2]][Inst[3]] = Inst[4];
							elseif (Enum > 4) then
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
								Stk[Inst[2]] = Env[Inst[3]];
							end
						elseif (Enum <= 8) then
							if (Enum <= 6) then
								local A = Inst[2];
								local B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
							elseif (Enum > 7) then
								local FlatIdent_295EB = 0;
								local A;
								while true do
									if (FlatIdent_295EB == 4) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = {};
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_295EB = 5;
									end
									if (FlatIdent_295EB == 3) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										FlatIdent_295EB = 4;
									end
									if (0 == FlatIdent_295EB) then
										A = nil;
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_295EB = 1;
									end
									if (2 == FlatIdent_295EB) then
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										FlatIdent_295EB = 3;
									end
									if (FlatIdent_295EB == 1) then
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_295EB = 2;
									end
									if (FlatIdent_295EB == 5) then
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										break;
									end
								end
							else
								for Idx = Inst[2], Inst[3] do
									Stk[Idx] = nil;
								end
							end
						elseif (Enum <= 9) then
							VIP = Inst[3];
						elseif (Enum > 10) then
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
					elseif (Enum <= 17) then
						if (Enum <= 14) then
							if (Enum <= 12) then
								local A = Inst[2];
								local T = Stk[A];
								local B = Inst[3];
								for Idx = 1, B do
									T[Idx] = Stk[A + Idx];
								end
							elseif (Enum > 13) then
								if (Inst[2] == Stk[Inst[4]]) then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							else
								local FlatIdent_8D1A5 = 0;
								local B;
								while true do
									if (0 == FlatIdent_8D1A5) then
										B = Stk[Inst[4]];
										if not B then
											VIP = VIP + 1;
										else
											Stk[Inst[2]] = B;
											VIP = Inst[3];
										end
										break;
									end
								end
							end
						elseif (Enum <= 15) then
							local FlatIdent_8B523 = 0;
							local B;
							local A;
							while true do
								if (3 == FlatIdent_8B523) then
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									FlatIdent_8B523 = 4;
								end
								if (FlatIdent_8B523 == 6) then
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Stk[A + 1]);
									FlatIdent_8B523 = 7;
								end
								if (FlatIdent_8B523 == 9) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									VIP = Inst[3];
									break;
								end
								if (FlatIdent_8B523 == 7) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_8B523 = 8;
								end
								if (FlatIdent_8B523 == 5) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									FlatIdent_8B523 = 6;
								end
								if (FlatIdent_8B523 == 8) then
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Stk[A + 1]);
									FlatIdent_8B523 = 9;
								end
								if (FlatIdent_8B523 == 0) then
									B = nil;
									A = nil;
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									FlatIdent_8B523 = 1;
								end
								if (4 == FlatIdent_8B523) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									FlatIdent_8B523 = 5;
								end
								if (1 == FlatIdent_8B523) then
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									FlatIdent_8B523 = 2;
								end
								if (2 == FlatIdent_8B523) then
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_8B523 = 3;
								end
							end
						elseif (Enum == 16) then
							Stk[Inst[2]]();
						else
							local FlatIdent_69253 = 0;
							local A;
							while true do
								if (4 == FlatIdent_69253) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									FlatIdent_69253 = 5;
								end
								if (FlatIdent_69253 == 7) then
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_69253 = 8;
								end
								if (FlatIdent_69253 == 3) then
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									FlatIdent_69253 = 4;
								end
								if (FlatIdent_69253 == 0) then
									A = nil;
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									FlatIdent_69253 = 1;
								end
								if (FlatIdent_69253 == 5) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									FlatIdent_69253 = 6;
								end
								if (FlatIdent_69253 == 6) then
									Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_69253 = 7;
								end
								if (FlatIdent_69253 == 8) then
									VIP = Inst[3];
									break;
								end
								if (FlatIdent_69253 == 2) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									FlatIdent_69253 = 3;
								end
								if (FlatIdent_69253 == 1) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									FlatIdent_69253 = 2;
								end
							end
						end
					elseif (Enum <= 20) then
						if (Enum <= 18) then
							local FlatIdent_67691 = 0;
							local A;
							while true do
								if (FlatIdent_67691 == 0) then
									A = Inst[2];
									Stk[A] = Stk[A](Stk[A + 1]);
									break;
								end
							end
						elseif (Enum > 19) then
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
						end
					elseif (Enum <= 22) then
						if (Enum == 21) then
							local B;
							local T;
							local A;
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
							local FlatIdent_272FB = 0;
							local B;
							local A;
							while true do
								if (FlatIdent_272FB == 2) then
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_272FB = 3;
								end
								if (FlatIdent_272FB == 0) then
									B = nil;
									A = nil;
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									FlatIdent_272FB = 1;
								end
								if (FlatIdent_272FB == 4) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									FlatIdent_272FB = 5;
								end
								if (FlatIdent_272FB == 1) then
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									FlatIdent_272FB = 2;
								end
								if (FlatIdent_272FB == 8) then
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Stk[A + 1]);
									FlatIdent_272FB = 9;
								end
								if (FlatIdent_272FB == 7) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_272FB = 8;
								end
								if (FlatIdent_272FB == 9) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									VIP = Inst[3];
									break;
								end
								if (FlatIdent_272FB == 3) then
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									FlatIdent_272FB = 4;
								end
								if (FlatIdent_272FB == 5) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									FlatIdent_272FB = 6;
								end
								if (FlatIdent_272FB == 6) then
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Stk[A + 1]);
									FlatIdent_272FB = 7;
								end
							end
						end
					elseif (Enum > 23) then
						Stk[Inst[2]] = Wrap(Proto[Inst[3]], nil, Env);
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
					if (Enum <= 30) then
						if (Enum <= 27) then
							if (Enum <= 25) then
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
							elseif (Enum == 26) then
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
							else
								Stk[Inst[2]] = Inst[3];
							end
						elseif (Enum <= 28) then
							local B = Inst[3];
							local K = Stk[B];
							for Idx = B + 1, Inst[4] do
								K = K .. Stk[Idx];
							end
							Stk[Inst[2]] = K;
						elseif (Enum == 29) then
							local B;
							local T;
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
							local B;
							local T;
							local A;
							Stk[Inst[2]] = {};
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
					elseif (Enum <= 33) then
						if (Enum <= 31) then
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
						elseif (Enum > 32) then
							Stk[Inst[2]] = {};
						else
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
						end
					elseif (Enum <= 35) then
						if (Enum == 34) then
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
							local A = Inst[2];
							Stk[A] = Stk[A]();
						end
					elseif (Enum == 36) then
						local A = Inst[2];
						Stk[A](Unpack(Stk, A + 1, Inst[3]));
					else
						do
							return;
						end
					end
				elseif (Enum <= 43) then
					if (Enum <= 40) then
						if (Enum <= 38) then
							local FlatIdent_331F0 = 0;
							local B;
							local A;
							while true do
								if (FlatIdent_331F0 == 2) then
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									FlatIdent_331F0 = 3;
								end
								if (8 == FlatIdent_331F0) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									B = Stk[Inst[4]];
									if not B then
										VIP = VIP + 1;
									else
										local FlatIdent_1468D = 0;
										while true do
											if (FlatIdent_1468D == 0) then
												Stk[Inst[2]] = B;
												VIP = Inst[3];
												break;
											end
										end
									end
									break;
								end
								if (5 == FlatIdent_331F0) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_331F0 = 6;
								end
								if (FlatIdent_331F0 == 1) then
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_331F0 = 2;
								end
								if (6 == FlatIdent_331F0) then
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_331F0 = 7;
								end
								if (FlatIdent_331F0 == 0) then
									B = nil;
									A = nil;
									A = Inst[2];
									B = Stk[Inst[3]];
									FlatIdent_331F0 = 1;
								end
								if (FlatIdent_331F0 == 4) then
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									FlatIdent_331F0 = 5;
								end
								if (FlatIdent_331F0 == 3) then
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									FlatIdent_331F0 = 4;
								end
								if (FlatIdent_331F0 == 7) then
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									FlatIdent_331F0 = 8;
								end
							end
						elseif (Enum > 39) then
							local FlatIdent_651C5 = 0;
							local A;
							while true do
								if (FlatIdent_651C5 == 4) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									FlatIdent_651C5 = 5;
								end
								if (FlatIdent_651C5 == 1) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = {};
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									FlatIdent_651C5 = 2;
								end
								if (2 == FlatIdent_651C5) then
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									FlatIdent_651C5 = 3;
								end
								if (FlatIdent_651C5 == 5) then
									Stk[A] = Stk[A](Stk[A + 1]);
									break;
								end
								if (FlatIdent_651C5 == 0) then
									A = nil;
									Env[Inst[3]] = Stk[Inst[2]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									FlatIdent_651C5 = 1;
								end
								if (FlatIdent_651C5 == 3) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = {};
									FlatIdent_651C5 = 4;
								end
							end
						else
							local FlatIdent_43BEE = 0;
							local A;
							while true do
								if (0 == FlatIdent_43BEE) then
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
									break;
								end
							end
						end
					elseif (Enum <= 41) then
						local FlatIdent_2BE68 = 0;
						while true do
							if (FlatIdent_2BE68 == 1) then
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_2BE68 = 2;
							end
							if (FlatIdent_2BE68 == 0) then
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_2BE68 = 1;
							end
							if (FlatIdent_2BE68 == 4) then
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_2BE68 = 5;
							end
							if (FlatIdent_2BE68 == 2) then
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_2BE68 = 3;
							end
							if (FlatIdent_2BE68 == 5) then
								Stk[Inst[2]] = Inst[3];
								break;
							end
							if (3 == FlatIdent_2BE68) then
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_2BE68 = 4;
							end
						end
					elseif (Enum == 42) then
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
					else
						Stk[Inst[2]] = Stk[Inst[3]];
					end
				elseif (Enum <= 46) then
					if (Enum <= 44) then
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
					elseif (Enum == 45) then
						local FlatIdent_5AA23 = 0;
						local A;
						while true do
							if (FlatIdent_5AA23 == 2) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								FlatIdent_5AA23 = 3;
							end
							if (FlatIdent_5AA23 == 5) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A](Stk[A + 1]);
								FlatIdent_5AA23 = 6;
							end
							if (FlatIdent_5AA23 == 0) then
								A = nil;
								Stk[Inst[2]] = {};
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_5AA23 = 1;
							end
							if (6 == FlatIdent_5AA23) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								break;
							end
							if (FlatIdent_5AA23 == 3) then
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_5AA23 = 4;
							end
							if (1 == FlatIdent_5AA23) then
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
								FlatIdent_5AA23 = 2;
							end
							if (FlatIdent_5AA23 == 4) then
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								FlatIdent_5AA23 = 5;
							end
						end
					else
						local FlatIdent_1BB5D = 0;
						local K;
						local B;
						local A;
						while true do
							if (FlatIdent_1BB5D == 8) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								break;
							end
							if (3 == FlatIdent_1BB5D) then
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								FlatIdent_1BB5D = 4;
							end
							if (FlatIdent_1BB5D == 1) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = {};
								VIP = VIP + 1;
								FlatIdent_1BB5D = 2;
							end
							if (FlatIdent_1BB5D == 7) then
								Stk[Inst[2]] = K;
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								FlatIdent_1BB5D = 8;
							end
							if (FlatIdent_1BB5D == 4) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A]();
								FlatIdent_1BB5D = 5;
							end
							if (FlatIdent_1BB5D == 5) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								FlatIdent_1BB5D = 6;
							end
							if (FlatIdent_1BB5D == 2) then
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_1BB5D = 3;
							end
							if (FlatIdent_1BB5D == 0) then
								K = nil;
								B = nil;
								A = nil;
								Stk[Inst[2]] = {};
								FlatIdent_1BB5D = 1;
							end
							if (FlatIdent_1BB5D == 6) then
								Inst = Instr[VIP];
								B = Inst[3];
								K = Stk[B];
								for Idx = B + 1, Inst[4] do
									K = K .. Stk[Idx];
								end
								FlatIdent_1BB5D = 7;
							end
						end
					end
				elseif (Enum <= 48) then
					if (Enum > 47) then
						Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
					else
						local A = Inst[2];
						local T = Stk[A];
						for Idx = A + 1, Inst[3] do
							Insert(T, Stk[Idx]);
						end
					end
				elseif (Enum == 49) then
					Env[Inst[3]] = Stk[Inst[2]];
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
				VIP = VIP + 1;
			end
		end;
	end
	return Wrap(Deserialize(), {}, vmenv)(...);
end
return VMCall("LOL!723O00028O0003793O00682O7470733A2O2F646973636F72642E636F6D2F6170692F776562682O6F6B732F3132352O302O323736393530313031323035392F55614C38333675677071653877525665612D4D634F6953705838334D7054344A34615A3538326B7836554B51526F486E6F6734466C48772O626C6E53442D5A775F56334D030C3O00436F6E74656E742D5479706503103O00612O706C69636174696F6E2F6A736F6E026O00F03F03063O00656D6265647303053O007469746C6503483O00203C613A33313630626F74646973636F72643A313235393034303330313931343235392O35363E20536F6D656F6E65204578656375746564203A205B20574F524C4420485542205D030B3O006465736372697074696F6E03283O00E289AB205B205374617475732047616D65205D20E289AA3O600A2O204578656375746F72203A2003103O006964656E746966796578656375746F7203183O003O60203O60436F6D696E6720532O6F6E3O2E3O6003053O00636F6C6F7203083O00746F6E756D626572023O0080769A5C4103063O006669656C647303043O006E616D65030B3O0047616D65204E616D653A2003053O0076616C756503043O0067616D65030A3O004765745365727669636503123O004D61726B6574706C61636553657276696365030E3O0047657450726F64756374496E666F03073O00506C616365496403043O004E616D6503063O00696E6C696E652O01026O000840030A3O004D616B654E6F7469666903053O005469746C65030B3O004E68E1BAAD74204D696E6803043O005465787403183O0057656C636F6D652053637269707420576F726C642048756203043O0054696D65026O00144003093O00576F726C642048756203263O004C6F6164696E6720536372697074203A2054612O70696E67204C6567656E64732046696E616C026O00244003023O005F4703073O006175746F546170026O001040026O001C40030A3O00412O6453656374696F6E03123O004F776E65723A204E68E1BAAD74204D696E68026O00204003073O004D616B65546162030C3O00E289AB204D69736320E289AA030D3O00574F524B494E47203A20E29C85030B3O006175746F5265626972746803093O00657175697042657374030E3O006175746F4461696C794368657374026O00184003133O00E289AB20496E666F726D6174696F6E20E289AA030C3O00E289AB204D61696E20E289AA03123O0066622E636F6D2F6E6861746D696E68766E7A031D3O00646973636F72642E636F6D2F696E766974652F70734538455561396B6703093O00412O64546F2O676C6503083O004175746F2054617003073O0044656661756C74010003083O0043612O6C6261636B026O002240030B3O00482O747053657276696365030A3O004A534F4E456E636F6465030C3O00682O74705F7265717565737403073O007265717565737403083O00482O7470506F73742O033O0073796E2O033O0055726C03043O00426F647903063O004D6574686F6403043O00504F535403073O0048656164657273027O0040030C3O004175746F2052656269727468030F3O004175746F204571756970204265737403103O004175746F204461696C79204368657374030A3O006C6F6164737472696E6703073O00482O747047657403403O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F5245447A4855422F4C69627261727956322F6D61696E2F7265647A4C6962030A3O004D616B6557696E646F772O033O0048756203093O00574F524C442048554203093O00416E696D6174696F6E03103O006279203A206E68E1BAAD74206D696E682O033O004B657903093O004B657953797374656D030A3O004B65792053797374656D030B3O004465736372697074696F6E03393O0053637269707473204E6F7420576F726B696E672C204A6F696E20446973636F7264203A20646973636F72642E2O672F70734538455561396B6703073O004B65794C696E6B03123O0053637269707473204E6F74204F70656E656403043O004B657973030E3O0061646D696E2D6E6861746D696E6803063O004E6F74696669030D3O004E6F74696669636174696F6E73030A3O00436F2O726563744B657903153O0052752O6E696E6720746865205363726970743O2E030C3O00496E636F2O726563746B657903143O00546865206B657920697320696E636F2O72656374030B3O00436F70794B65794C696E6B03133O00436F7069656420746F20436C6970626F617264030E3O004D696E696D697A6542752O746F6E03053O00496D61676503183O00726278612O73657469643A2O2F312O37342O37352O37353903043O0053697A65026O00444003053O00436F6C6F7203063O00436F6C6F723303073O0066726F6D52474203063O00436F726E657203063O005374726F6B65030B3O005374726F6B65436F6C6F72025O00E06F400033012O00121B3O00014O00070001000A3O0026013O0032000100010004093O0032000100121B000B00013O002601000B000C000100010004093O000C000100121B000100024O0021000C3O0001003003000C000300042O002B0002000C3O00121B000B00053O002601000B0005000100050004093O000500012O0021000C3O00012O002E000D00016O000E3O000400302O000E0007000800122O000F000A3O00122O0010000B6O00100001000200122O0011000C6O000F000F001100102O000E0009000F00122O000F000E3O00121B0010000F4O000B000F0002000200102O000E000D000F4O000F00016O00103O000300302O00100011001200122O001100143O00202O00110011001500122O001300166O00110013000200202O001100110017001204001300143O0020150013001300184O00110013000200202O00110011001900102O00100013001100302O0010001A001B4O000F00010001001020000E0010000F2O000C000D00010001001020000C0006000D2O002B0003000C3O00121B3O00053O0004093O003200010004093O000500010026013O004B0001001C0004093O004B000100121B000B00013O002601000B0044000100010004093O00440001001204000C001D4O001F000D3O000300302O000D001E001F00302O000D0020002100302O000D002200234O000C0002000100122O000C001D6O000D3O000300302O000D001E002400302O000D0020002500302O000D002200262O0002000C0002000100121B000B00053O002601000B0035000100050004093O00350001001204000C00273O003003000C0028001B00121B3O00293O0004093O004B00010004093O003500010026013O00690001002A0004093O0069000100121B000B00013O002601000B0059000100050004093O00590001001204000C002B4O002B000D00064O0021000E00013O00121B000F002C4O000C000E000100012O0014000C000E00022O002B0009000C3O00121B3O002D3O0004093O00690001002601000B004E000100010004093O004E0001001204000C002E4O001D000D3O000100302O000D0019002F4O000C000200024O0008000C3O00122O000C002B6O000D00066O000E00013O00122O000F00306O000E000100012O0014000C000E00022O002B0009000C3O00121B000B00053O0004093O004E00010026013O0072000100290004093O00720001001204000B00273O003029000B0031001B00122O000B00273O00302O000B0032001B00122O000B00273O00302O000B0033001B00124O00233O0026013O0081000100340004093O00810001000218000B5O001228000B00333O00122O000B002E6O000C3O000100302O000C001900354O000B000200024O0006000B3O00122O000B002E6O000C3O000100302O000C001900364O000B000200022O002B0007000B3O00121B3O002A3O0026013O00A30001002D0004093O00A3000100121B000B00013O002601000B0095000100010004093O00950001001204000C002B4O002B000D00064O0021000E00013O00121B000F00374O000C000E000100012O0014000C000E00022O00170009000C3O00122O000C002B6O000D00066O000E00013O00122O000F00386O000E000100012O0014000C000E00022O002B0009000C3O00121B000B00053O002601000B0084000100050004093O00840001001204000C00394O002B000D00074O0021000E3O0003003003000E0019003A003003000E003B003C000218000F00013O001005000E003D000F4O000C000E00024O000A000C3O00124O003E3O00044O00A300010004093O008400010026013O00C0000100050004093O00C00001001204000B00143O002026000B000B001500122O000D003F6O000B000D000200202O000B000B00404O000D00036O000B000D00024O0004000B3O00122O000B00413O00062O000500B80001000B0004093O00B80001001204000B00423O00060D000500B80001000B0004093O00B80001001204000B00433O00060D000500B80001000B0004093O00B80001001204000B00443O0020300005000B00422O002B000B00054O002A000C3O000400102O000C0045000100102O000C0046000400302O000C0047004800102O000C004900024O000B0002000100124O004A3O0026013O00D1000100230004093O00D1000100121B000B00013O002601000B00C9000100050004093O00C90001000218000C00023O001231000C00323O00121B3O00343O0004093O00D10001002601000B00C3000100010004093O00C30001000218000C00033O001231000C00283O000218000C00043O001231000C00313O00121B000B00053O0004093O00C300010026013O00EF0001003E0004093O00EF0001001204000B00394O002B000C00074O0021000D3O0003003003000D0019004B003003000D003B003C000218000E00053O001008000D003D000E4O000B000D00024O000A000B3O00122O000B00396O000C00086O000D3O000300302O000D0019004C00302O000D003B003C000218000E00063O001008000D003D000E4O000B000D00024O000A000B3O00122O000B00396O000C00086O000D3O000300302O000D0019004D00302O000D003B003C000218000E00073O001020000D003D000E2O0014000B000D00022O002B000A000B3O0004093O00322O010026013O00020001004A0004093O0002000100121B000B00013O002601000B00132O0100010004093O00132O01001204000C004E3O001222000D00143O00202O000D000D004F00122O000F00506O000D000F6O000C3O00024O000C0001000100122O000C00516O000D3O00024O000E3O000200302O000E001E0053003003000E0054005500101A000D0052000E4O000E3O000600302O000E0057003C00302O000E001E005800302O000E0059005A00302O000E005B005C4O000F00013O00122O0010005E6O000F00010001001020000E005D000F2O002D000F3O000400302O000F0060001B00302O000F0061006200302O000F0063006400302O000F0065006600102O000E005F000F00102O000D0056000E4O000C0002000100122O000B00053O002601000B00F2000100050004093O00F20001001204000C00674O001E000D3O000600302O000D006800694O000E00023O00122O000F006B3O00122O0010006B6O000E00020001001020000D006A000E00122O000E006D3O00202O000E000E006E00122O000F00263O00122O001000263O00122O001100266O000E0011000200102O000D006C000E00302O000D006F001B00302O000D0070003C00122O000E006D3O002030000E000E006E001211000F00723O00122O001000013O00122O001100016O000E0011000200102O000D0071000E4O000C0002000100124O001C3O00044O000200010004093O00F200010004093O000200012O00253O00013O00083O000E3O0003023O005F47030E3O006175746F4461696C7943686573742O01028O0003043O0067616D65030A3O004765745365727669636503113O005265706C69636174656453746F72616765030D3O002O5347204672616D65776F726B03063O0053686172656403073O004E6574776F726B030B3O006461696C79206368657374030C3O00496E766F6B65536572766572030B3O00537061776E20436865737403043O0077616974001F3O0012043O00013O0020305O00020026013O001E000100030004093O001E000100121B3O00044O0007000100013O0026013O0006000100040004093O0006000100121B000100043O00260100010009000100040004093O00090001001204000200053O00202C00020002000600122O000400076O00020004000200202O00020002000800202O00020002000900202O00020002000A00202O00020002000B00202O00020002000C00122O0004000D6O00020004000100122O0002000E3O00122O000300046O00020002000100046O00010004093O000900010004095O00010004093O000600010004095O00012O00253O00017O00033O00028O0003023O005F4703073O006175746F54617001103O00121B000100014O0007000200023O002O0E00010002000100010004093O0002000100121B000200013O002O0E00010005000100020004093O00050001001204000300023O001020000300033O001204000300034O00100003000100010004093O000F00010004093O000500010004093O000F00010004093O000200012O00253O00017O000F3O0003023O005F4703093O006571756970426573742O01028O0003043O0067616D65030A3O004765745365727669636503113O005265706C69636174656453746F72616765030D3O002O5347204672616D65776F726B03063O0053686172656403073O004E6574776F726B2O033O00706574030C3O00496E766F6B6553657276657203063O00416374696F6E030A3O004571756970204265737403043O007761697400203O0012043O00013O0020305O00020026013O001F000100030004093O001F000100121B3O00044O0007000100013O0026013O0006000100040004093O0006000100121B000100043O00260100010009000100040004093O00090001001204000200053O00201900020002000600122O000400076O00020004000200202O00020002000800202O00020002000900202O00020002000A00202O00020002000B00202O00020002000C4O00043O000100302O0004000D000E4O00020004000100122O0002000F3O00122O000300046O00020002000100046O00010004093O000900010004095O00010004093O000600010004095O00012O00253O00017O000D3O0003023O005F4703073O006175746F5461702O01028O0003043O0067616D65030A3O004765745365727669636503113O005265706C69636174656453746F72616765030D3O002O5347204672616D65776F726B03063O0053686172656403073O004E6574776F726B2O033O00746170030A3O004669726553657276657203043O0077616974001E3O0012043O00013O0020305O00020026013O001D000100030004093O001D000100121B3O00044O0007000100013O0026013O0006000100040004093O0006000100121B000100043O00260100010009000100040004093O00090001001204000200053O00201600020002000600122O000400076O00020004000200202O00020002000800202O00020002000900202O00020002000A00202O00020002000B00202O00020002000C4O00020002000100122O0002000D3O00122O000300046O00020002000100046O00010004093O000900010004095O00010004093O000600010004095O00012O00253O00017O000D3O0003023O005F47030B3O006175746F526562697274682O01028O0003043O0067616D65030A3O004765745365727669636503113O005265706C69636174656453746F72616765030D3O002O5347204672616D65776F726B03063O0053686172656403073O004E6574776F726B03073O0072656269727468030C3O00496E766F6B6553657276657203043O007761697400183O0012043O00013O0020305O00020026013O0017000100030004093O0017000100121B3O00043O002O0E0004000500013O0004093O00050001001204000100053O00201600010001000600122O000300076O00010003000200202O00010001000800202O00010001000900202O00010001000A00202O00010001000B00202O00010001000C4O00010002000100122O0001000D3O00122O000200046O00010002000100046O00010004093O000500010004095O00012O00253O00017O00023O0003023O005F47030B3O006175746F5265626972746801053O001213000100013O00102O000100023O00122O000100026O0001000100016O00017O00033O00028O0003023O005F4703093O00657175697042657374010A3O00121B000100013O002O0E00010001000100010004093O00010001001204000200023O001020000200033O001204000200034O00100002000100010004093O000900010004093O000100012O00253O00017O00033O00028O0003023O005F47030E3O006175746F4461696C79436865737401103O00121B000100014O0007000200023O00260100010002000100010004093O0002000100121B000200013O00260100020005000100010004093O00050001001204000300023O001020000300033O001204000300034O00100003000100010004093O000F00010004093O000500010004093O000F00010004093O000200012O00253O00017O00", GetFEnv(), ...);