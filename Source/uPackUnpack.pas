unit uPackUnpack;

interface
uses SysUtils, StrUtils, Generics.Collections, Classes, System.Generics.Collections, Math, uSwapBytes;

function Pack (sFormat : string; acaParam : array of TCharArray) : TBytes;
function UnPack(sFormat : string; abVal : TBytes) : TDictionary<string,Variant>;

implementation


function IfThenChar(b : Boolean; c1, c2 : Char) : Char;
begin
  if b then
    Result := c1
  else
    Result := c2;
end;

function Pack (sFormat : string; acaParam : array of TCharArray) : TBytes;
var
  bs : TBytesStream;
  bw : TBinaryWriter;
  l, i, j, utlen : UInt64;
  cf : Char;

  function Get_Qual (k : UInt64) : string;
  begin
    Result := '';
    if k + 1 > sFormat.Length then
      Exit;
    if sFormat[k + 1] = '*' then
      Result := '0'
    else if CharInSet(sFormat[k + 1],['0'..'9']) then
      Result := sFormat[k + 1] + Get_Qual(k + 1);
    if (k = i) then
      i := i + Result.Length
  end;

  begin
  Result := [];
  l := 0;
  if sFormat.Length = 0 then
    Exit;
  bs := TBytesStream.Create;
  bw := TBinaryWriter.Create(bs);
  i := 1;
  j := 0;
  while i < sFormat.Length + 1 do
    begin
      cf := sFormat[i];
      utlen := StrToInt(Get_Qual(i));
      case cf of
//A 	SPACE-padded string
//a 	NUL-padded string
//Z 	NUL-padded string
        'A', 'a', 'Z' :
          begin
            var tvlen := Length(acaParam[j]);
            if (utlen = 0) or (utlen = tvlen) then
              begin
                bw.Write(acaParam[j]);
                l := l + tvlen;
              end
            else
              begin
                l := l + utlen;
                if (utlen < tvlen) then
                  bw.Write(Copy(acaParam[j], 0, utlen))
                else
                  begin
                    bw.Write(acaParam[j]);
                    bw.Write(StringOfChar(IfThenChar(cf = 'A',' ', #0), utlen - tvlen).ToCharArray);
                  end;
              end
          end;
//H 	Hex string, high nibble first
//h 	Hex string, low nibble first
        'H', 'h':
          begin
            var uT : UInt64 := 0;
            var uL : UInt64 := IfThen((utlen = 0) or (utlen >= Length(acaParam[j])), Length(acaParam[j]), utlen);
            while uT < uL do
              begin
                if uL - uT >= 2 then
                  begin
                    bw.Write(StrToInt('$' + IfThen(cf = 'H', acaParam[j][uT] + acaParam[j][uT+1], acaParam[j][uT + 1] + acaParam[j][uT])));
                    uT := uT + 1;
                  end
                else
                  bw.Write(StrToInt('$' + IfThen(cf = 'H', acaParam[j][uT] + '0', '0' + acaParam[j][uT])));
                uT := uT + 1;
                l := l + 1;
              end;
          end;
//Q 	unsigned long long (always 64 bit, machine byte order)
//P 	unsigned long long (always 64 bit, little endian byte order)
//J 	unsigned long long (always 64 bit, big endian byte order)
        'Q', 'P', 'J':
          begin
            if (cf = 'P') or ((cf = 'Q') and LEByteOrder) then
              begin
                bw.Write(UInt64(acaParam[j]));
                l:= l + SizeOf(UInt64);
              end
            else
              begin
                bw.Write(SwapBytesU64(UInt64(acaParam[j])));
                l:= l + SizeOf(UInt64);
              end;
          end;
//S 	unsigned short (always 16 bit, machine byte order)
//v 	unsigned short (always 16 bit, little endian byte order)
//n 	unsigned short (always 16 bit, big endian byte order)
        'S', 'n', 'v' :
          begin
            if (cf = 'v') or ((cf = 'S') and LEByteOrder) then
              begin
                bw.Write(UInt16(acaParam[j]));
                l := l + SizeOf(UInt16);
              end
            else
              begin
                bw.Write(SwapBytesU16(UInt16(acaParam[j])));
                l := l + SizeOf(UInt16);
              end;
          end;
//f 	float (machine dependent size and representation)
//g 	float (machine dependent size, little endian byte order)
//G 	float (machine dependent size, big endian byte order)
        'f', 'g', 'G' :
          begin
            if (cf = 'g') or ((cf = 'f') and LEByteOrder) then
              begin
                bw.Write(Single(acaParam[j]));
                l := l + SizeOf(Single);
              end
            else
              begin
                bw.Write(SwapBytes32(Single(acaParam[j])));
                l := l + SizeOf(Single);
              end;
          end;
//d 	double (machine dependent size and representation)
//e 	double (machine dependent size, little endian byte order)
//E 	double (machine dependent size, big endian byte order)
        'd', 'e', 'E' :
          begin
            if (cf = 'e') or ((cf = 'd') and LEByteOrder) then
              begin
                bw.Write(string(acaParam[j]).ToDouble);
                l := l + SizeOf(Double);
              end
            else
              begin
                bw.Write(SwapBytes64(string(acaParam[j]).ToDouble));
                l := l + SizeOf(Double);
              end;
          end;
//L 	unsigned long (always 32 bit, machine byte order)
//V 	unsigned long (always 32 bit, little endian byte order)
//N 	unsigned long (always 32 bit, big endian byte order)
        'L', 'N', 'V' :
          begin
            if (cf = 'V') or ((cf = 'L') and LEByteOrder) then
              begin
                bw.Write(UInt32(acaParam[j]));
                l := l + SizeOf(UInt32);
              end
            else
              begin
                bw.Write(SwapBytesU32(UInt32(acaParam[j])));
                l := l + SizeOf(UInt32);
              end;
          end;
//q 	signed long long (always 64 bit, machine byte order)
        'q' :
          begin
            if LEByteOrder then
              begin
                bw.Write(Int64(acaParam[j]));
                l := l + SizeOf(Int64);
              end
            else
              begin
                bw.Write(SwapBytes64(Int64(acaParam[j])));
                l := l + SizeOf(Int64);
              end;
          end;
//s 	signed short (always 16 bit, machine byte order)
        's' :
          begin
            if LEByteOrder then
              begin
                bw.Write(Int16(acaParam[j]));
                l := l + SizeOf(Int16);
              end
            else
              begin
                bw.Write(SwapBytes16(Int16(acaParam[j])));
                l := l + SizeOf(Int16);
              end;
          end;
//c	  signed char
        'c' :
          begin
            bw.Write(Int8(acaParam[j]));
            l := l + SizeOf(Int8);
          end;
//C 	unsigned char
        'C' :
          begin
            bw.Write(UInt8(acaParam[j]));
            l := l + SizeOf(UInt8);
          end;
//i 	signed integer (machine dependent size and byte order)
//l 	signed long (always 32 bit, machine byte order)
        'i', 'l' :
          begin
            if (cf = 'l') or ((cf = 'i') and (SizeOf(NativeInt) = 4)) then
              begin
                if LEByteOrder then
                  bw.Write(Int32(acaParam[j]))
                else
                  bw.Write(SwapBytes32(Int32(acaParam[j])));
                l := l + 4;
              end
            else  //8
              begin
                if LEByteOrder then
                  bw.Write(Int64(acaParam[j]))
                else
                  bw.Write(SwapBytes64(Int64(acaParam[j])));
                l := l + 8;
              end;
          end;
//I 	unsigned integer (machine dependent size and byte order)
        'I' :
          begin
            if SizeOf(NativeUInt) = 4 then
              begin
                if LEByteOrder then
                  bw.Write(UInt32(acaParam[j]))
                else
                  bw.Write(SwapBytesU32(UInt32(acaParam[j])));
                l := l + 4;
              end
            else //8
              begin
                if LEByteOrder then
                  bw.Write(UInt64(acaParam[j]))
                else
                  bw.Write(SwapBytesU64(UInt64(acaParam[j])));
                l := l + 8;
              end;
          end;


      end;
      i := i + 1;
      j := j + 1;
    end;

  Result := Copy(bs.Bytes, 0, l);
end;
//  Code 	Description
//x 	NUL byte
//X 	Back up one byte
//@ 	NUL-fill to absolute position

function UnPack(sFormat : string; abVal : TBytes) : TDictionary<string,Variant>;
var
  asFormat : TArray<string>;
//  bs : TBytesStream;
//  br : TBinaryReader;
begin
  Result := TDictionary<string,Variant>.Create;
  if sFormat.Length = 0 then
    Exit;
  asFormat := sFormat.Split(['\']);



  Result.TrimExcess;
end;


end.
