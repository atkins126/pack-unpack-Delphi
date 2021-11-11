unit uSwapBytes;

interface

function SwapBytesU64(const Value: UInt64): UInt64; register; overload;
function SwapBytes64(const Value: Int64): Int64; register; overload;
function SwapBytesU32(const Value: UInt32): UInt32; register; overload;
function SwapBytes32(const Value: Int32): Int32; register; overload;
function SwapBytesU16(const Value: UInt16): UInt16; register; overload;
function SwapBytes16(const Value: Int16): Int16; register; overload;
function SwapBytes64(const Value: Double): Double; overload; inline;
function SwapBytes32(const Value: Single): Single; overload; inline;

function LEByteOrder: boolean;

implementation

/// <summary>
///   Reverse byte order in UInt64
/// </summary>
/// <param name="Value">UInt64</param>
/// <returns> UInt64 with reverse byte order</returns>
{$IFDEF CPUX64}
function SwapBytesU64(const Value: UInt64): UInt64; register; overload;
asm
  mov rax,rcx
  bswap rax
end;
{$ELSE}//IF Defined(CPUX86)}
function SwapBytesU64(const Value: UInt64): UInt64; register; overload;
asm
  mov edx, [ebp + $08]
  mov eax, [ebp + $0c]
  bswap edx
  bswap eax
end;
//{$ELSE}
//function SwapBytes(const Value: UInt64): UInt64; overload;
//begin
//  Result := SwapBytes(UInt32(Value));
//  Result := (Result shl 32) or SwapBytes(UInt32(Value shr 32));
//end;
{$ENDIF}

/// <summary>
///   Reverse byte order in Int64
/// </summary>
/// <param name="Value">Int64</param>
/// <returns> Int64 with reverse byte order</returns>
{$IFDEF CPUX64}
function SwapBytes64(const Value: Int64): Int64; register; overload;
asm
  mov rax,rcx
  bswap rax
end;
{$ELSE}//IF Defined(CPUX86)}
function SwapBytes64(const Value: Int64): Int64; register; overload;
asm
  mov edx, [ebp + $08]
  mov eax, [ebp + $0c]
  bswap edx
  bswap eax
end;
//{$ELSE}
//function SwapBytes(const Value: Int64): Int64; overload;
//begin
//  Result := SwapBytes(UInt32(Value));
//  Result := (Result shl 32) or SwapBytes(UInt32(Value shr 32));
//end;
{$ENDIF}

/// <summary>
///   Reverse byte order in Single
/// </summary>
/// <param name="Value">Single</param>
/// <returns> Single with reverse byte order</returns>
function SwapBytes32(const Value: Single): Single; overload; inline;
var
  R: UInt32 absolute Result;
  V: Uint32 absolute Value;
begin
  R := SwapBytesU32(V);
end;

/// <summary>
///   Reverse byte order in Double
/// </summary>
/// <param name="Value">Double</param>
/// <returns> Double with reverse byte order</returns>
function SwapBytes64(const Value: Double): Double; overload; inline;
var
  R: Int64 absolute Result;
  V: Int64 absolute Value;
begin
  R := SwapBytes64(V);
end;

/// <summary>
///   Reverse byte order in UInt32
/// </summary>
/// <param name="Value">UInt32</param>
/// <returns> UInt32 with reverse byte order</returns>
//{$IF Defined(CPUX86) or Defined(CPUX64)}
function SwapBytesU32(const Value: UInt32): UInt32; register; overload;
asm
  bswap eax
end;
//{$ELSE}
//function SwapBytes(const Value: UInt32): UInt32; overload;
//begin
//  Result := Swap(UInt16(Value)) shl 16 + Swap(UInt16(Value shr 16))
//end;
//{$IFEND}

/// <summary>
///   Reverse byte order in Int32
/// </summary>
/// <param name="Value">Int32</param>
/// <returns> Int32 with reverse byte order</returns>
//{$IF Defined(CPUX86) or Defined(CPUX64)}
function SwapBytes32(const Value: Int32): Int32; register; overload;
asm
  bswap eax
end;
//{$ELSE}
//function SwapBytes(const Value: Int32): Int32; overload;
//begin
//  Result := Swap(UInt16(Value)) shl 16 + Swap(UInt16(Value shr 16))
//end;
//{$IFEND}

/// <summary>
///   Reverse byte order in UInt16
/// </summary>
/// <param name="Value">UInt16</param>
/// <returns> UInt16 with reverse byte order</returns>
function SwapBytesU16(const Value: UInt16): UInt16; register; overload;
asm
  xchg al, ah
end;

/// <summary>
///   Reverse byte order in Int16
/// </summary>
/// <param name="Value">Int16</param>
/// <returns> Int16 with reverse byte order</returns>
function SwapBytes16(const Value: Int16): Int16; register; overload;
asm
  xchg al, ah
end;


/// <summary>
///   Check machine byte order
/// </summary>
/// <returns>True on Little Endian</returns>
function LEByteOrder: boolean;
var w: Word;
    p: ^Byte;
begin
  w:=1;
  p:=@w;
  Result:=(p^=1);
end;


end.
