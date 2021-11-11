program PackUnpack;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  uPackUnpack in '..\Source\uPackUnpack.pas',
  uSwapBytes in '..\Source\uSwapBytes.pas';

var i : Integer;
    tb : TBytes;
    sin, sstring : string;
    av : array of TCharArray;
    tas : TArray<string>;
begin
  try
    repeat
      Writeln('Enter format');
      Readln(sin);
      Writeln('Enter arg');
      Readln(sstring);
      tas := sstring.Split([',']);
      SetLength(av, Length(tas));
      FOR I:=0 TO Length(tas) - 1 do
        av[i] := tas[i].ToCharArray;
      tb := Pack(sin, av);
      for I := Low(tb) to High(tb) do
        Write(tb[i], ' ');
      Readln;
    until sin = '';
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
