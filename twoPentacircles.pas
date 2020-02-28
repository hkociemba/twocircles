unit twoPentacircles;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

  TTileID = array [0 .. 17] of Integer;
  TTileOri = array [0 .. 17] of Integer;
  TPuzOri = array [0 .. 1] of Integer;

  TPuz = record
    id: TTileID;
    ori: TTileOri;
    pzo: TPuzOri;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

const
  prunID = 17642862720;

var
  pruning9: array [0 .. 48620 - 1] of array of UInt64; // 48620 = 18 choose 9

function c_nk(n, k: Integer): Integer;
var
  i, j: Integer;
begin
  if n < k then
    exit(0);
  if k > n div 2 then
    k := n - k;
  result := 1;
  i := n;
  j := 1;
  while i <> n - k do
  begin
    result := result * i;
    result := result div j;
    Dec(i);
    inc(j);
  end;
end;

procedure rot_right(var a: Array of Integer; l, r: Integer);
// Rotate array arr right between l and r. r is included.
var
  tmp, i: Integer;
begin
  tmp := a[r];
  for i := r downto l + 1 do
    a[i] := a[i - 1];
  a[l] := tmp
end;

procedure rot_left(var a: Array of Integer; l, r: Integer);
// Rotate array arr left between l and r. r is included.
var
  tmp, i: Integer;
begin
  tmp := a[l];
  for i := l to r - 1 do
    a[i] := a[i + 1];
  a[r] := tmp
end;

function get_9tupel_sorted(var arr: array of Integer): Int64;
// 0<=get_9tupel_sorted < 17.643.225.600
var
  a, b, x, j, k: Integer;
  perm9: array [0 .. 8] of Integer;
begin
  a := 0;
  x := 0;
  // First compute the index a < (18 choose 9) and the permutation array perm9
  // for the tiles 0..8
  for j := 17 downto 0 do
  begin
    if arr[j] < 9 then
    begin
      inc(a, c_nk(17 - j, x + 1));
      perm9[8 - x] := arr[j];
      inc(x);
    end;
  end;

  // Then compute the index b < 9! for the permutation in perm9
  b := 0;
  for j := 8 downto 1 do
  begin
    k := 0;
    while perm9[j] <> j do
    begin
      rot_left(perm9, 0, j);
      inc(k)
    end;
    b := (j + 1) * b + k
  end;
  result := Int64(362880) * a + b
end;

procedure set_9tupel_sorted(var arr: array of Integer; idx: Int64);
var
  a, b, j, k, x: Integer;
  perm9: array [0 .. 8] of Integer;
begin
  for j := 0 to 8 do
    perm9[j] := j;

  b := idx mod 362880;
  a := idx div 362880;
  for j := 0 to 17 do
    arr[j] := -1;
  j := 1; // generate permutation of tiles 0..8
  while j < 9 do
  begin
    k := b mod (j + 1);
    b := b div (j + 1);
    while k > 0 do
    begin
      rot_right(perm9, 0, j);
      Dec(k);
    end;
    inc(j)
  end;
  x := 9; // set tiles 0..8
  for j := 0 to 17 do
  begin
    if a - c_nk(17 - j, x) >= 0 then
    begin
      arr[j] := perm9[9 - x];
      Dec(a, c_nk(17 - j, x));
      Dec(x);
    end;
  end;
  // Set the remainig tiles
  x := 9;
  for j := 0 to 17 do
    if arr[j] = -1 then
    begin
      arr[j] := x;
      inc(x)
    end;

end;

procedure initPuzzle(var p: TPuz);
var
  i: Integer;
begin
  for i := 0 to 17 do
  begin
    p.id[i] := i;
    p.ori[i] := 0;
  end;
  p.pzo[0] := 0;
  p.pzo[1] := 0;
end;

procedure move(var p: TPuz; cID, dir: Integer);
var
  i, tmpID, tmpOri: Integer;
begin
  case dir of
    0: // clockwise turn
      begin
        if cID = 0 then
        begin
          tmpID := p.id[0];
          tmpOri := p.ori[0];
          for i := 0 to 8 do
          begin
            p.id[i] := p.id[i + 1];
            p.ori[i] := (p.ori[i + 1] + 1) mod 10;
          end;
          p.id[9] := tmpID;
          p.ori[9] := (tmpOri + 1) mod 10;
        end
        else
        begin
          tmpID := p.id[9];
          tmpOri := p.ori[9];
          for i := 9 to 16 do
          begin
            p.id[i] := p.id[i + 1];
            p.ori[i] := (p.ori[i + 1] + 1) mod 10;;
          end;
          p.id[17] := p.id[0];
          p.ori[17] := (p.ori[0] + 1) mod 10;
          p.id[0] := tmpID;
          p.ori[0] := (tmpOri + 1) mod 10;
        end;
        p.pzo[cID] := (p.pzo[cID] + 1) mod 10;
      end;
    1: // anticlockwise turn
      begin
        if cID = 0 then
        begin
          tmpID := p.id[9];
          tmpOri := p.ori[9];
          for i := 9 downto 1 do
          begin
            p.id[i] := p.id[i - 1];
            p.ori[i] := (p.ori[i - 1] + 9) mod 10;
          end;
          p.id[0] := tmpID;
          p.ori[0] := (tmpOri + 9) mod 10;
        end
        else
        begin
          tmpID := p.id[17];
          tmpOri := p.ori[17];
          for i := 17 downto 10 do
          begin
            p.id[i] := p.id[i - 1];
            p.ori[i] := (p.ori[i - 1] + 9) mod 10;;
          end;
          p.id[9] := p.id[0];
          p.ori[9] := (p.ori[0] + 9) mod 10;
          p.id[0] := tmpID;
          p.ori[0] := (tmpOri + 9) mod 10;
        end;
        p.pzo[cID] := (p.pzo[cID] + 9) mod 10;
      end;
  end;
end;

procedure remap(var p, pm: TPuz);
var
  i: Integer;
begin
  for i := 0 to 17 do
  begin
    pm.id[i] := (p.id[(i + 9) mod 18] + 9) mod 18;
    pm.ori[i] := p.ori[(i + 9) mod 18];
  end;
  for i := 0 to 17 do
  begin
    p.id[i] := pm.id[i];
    p.ori[i] := pm.ori[i];
  end;
end;

procedure setPruning(pos, val: Int64);
/// // / 0<=val<4
var
  chunk, offset, offset64, base64: Integer;
  mask: Int64;
begin
  chunk := pos div 362880;
  offset := pos mod 362880;
  base64 := offset div 32; // 32 Positionen pro Int64
  offset64 := offset mod 32;
  val := val shl (offset64 * 2);
  mask := Int64(3);
  mask := mask shl (offset64 * 2);
  mask := not mask;
  pruning9[chunk, base64] := pruning9[chunk, base64] and mask; // zero bits
  pruning9[chunk, base64] := pruning9[chunk, base64] or val;
end;

function getPruning(pos: Int64): Integer;
var
  chunk, offset, offset64, base64: Integer;
  mask, val: Int64;
begin
  chunk := pos div 362880;
  offset := pos mod 362880;
  base64 := offset div 32; // 32 Positionen pro Int64
  offset64 := offset mod 32;
  mask := Int64(3);
  mask := mask shl (offset64 * 2);
  val := pruning9[chunk, base64] and mask;
  result := Integer(val shr (offset64 * 2));
end;

procedure makePruning;
var
  fs: TFileStream;
var
  pz: TPuz;
  depth: UInt8;
  done, doneOld, n, i, j: Int64;
const
  fn = 'pruning9';
begin
  for i := 0 to 48620 - 1 do
    Setlength(pruning9[i], 11340); // 362880 = 9!/4/8
  if FileExists(fn) then
  begin
    fs := TFileStream.Create(fn, fmOpenRead);
    for i := 0 to 48620 - 1 do
      fs.ReadBuffer(pruning9[i], 11340);
  end
  else
  begin
    for i := 0 to 48620 - 1 do
    begin
      for j := 0 to 11340 - 1 do
        pruning9[i, j] := $FFFFFFFFFFFFFFFF;
    end;

    initPuzzle(pz);
    n := get_9tupel_sorted(pz.id);
    depth := 0;
    setPruning(n, depth);
    done := 1;
    doneOld := 0;
    while done <> doneOld do
    begin
      Form1.Memo1.Lines.Add(Inttostr(depth) + ': ' + Inttostr(done));
      Application.ProcessMessages;
      doneOld := done;
      inc(depth);
      for i := 0 to 17643225600 - 1 do
      begin
        if i mod 100000 = 0 then
          Application.ProcessMessages;
        if getPruning(i) = (depth-1) mod 3 then // occupied
        begin
          set_9tupel_sorted(pz.id, i);
          move(pz, 0, 0); // rotate disk 0 clockwise
          n := get_9tupel_sorted(pz.id);
          if getPruning(n) = 3 then // yet free
          begin
            setPruning(n, depth mod 3);
            inc(done);
          end;
          move(pz, 0, 1); // rotate disk 0 anticlockwise
          move(pz, 0, 1);
          n := get_9tupel_sorted(pz.id);
          if getPruning(n) = 3 then // yet free
          begin
            setPruning(n, depth mod 3);
            inc(done);
          end;
          move(pz, 0, 0);

          move(pz, 1, 0); // rotate disk 1 clockwise
          n := get_9tupel_sorted(pz.id);
          if getPruning(n) = 3 then // yet free
          begin
            setPruning(n, depth mod 3);
            inc(done);
          end;
          move(pz, 1, 1); // rotate disk 1 anticlockwise
          move(pz, 1, 1);
          n := get_9tupel_sorted(pz.id);
          if getPruning(n) = 3 then // yet free
          begin
            setPruning(n, depth mod 3);
            inc(done);
          end;
        end;
      end;
    end;
    Form1.Memo1.Lines.Add(Inttostr(depth) + ': ' + Inttostr(done));

  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  pz, pz2: TPuz;
  i, n: Int64;
begin
  initPuzzle(pz);
  n := get_9tupel_sorted(pz.id);

  makePruning;
end;

end.
