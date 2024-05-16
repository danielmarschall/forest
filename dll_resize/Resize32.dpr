library Resize32;

{$R *.res}

type
  TImgMemBlockHeader = packed record
    width: cardinal;
    height: cardinal;
    colordepth: cardinal;
  end;
  PImgMemBlockHeader = ^TImgMemBlockHeader;

function _Resize24(srcMemblock, dstMemblock: PImgMemBlockHeader; newWidth, newHeight: Cardinal): integer;
// --- Based on http://www.davdata.nl/math/bmresize.html ---
type
  TBGRATriple = packed record
    B: byte;
    G: byte;
    R: byte;
  end;
  PBGRATriple = ^TBGRATriple;
var
  psStep,pdStep: integer;
  ps0,pd0 : Pointer;       //scanline[0], row steps
  sx1,sy1,sx2,sy2 : single;             //source field positions
  x,y,i,j: word;  //source,dest field pixels
  destR,destG,destB : single;           //destination colors
  src: TBGRATriple;                      //source colors
  fx,fy,fix,fiy,dyf : single;           //factors
  fxstep,fystep, dx,dy : single;
  psi,psj : Pointer;
  AP : single;
  istart,iend,jstart,jend : word;
  devX1,devX2,devY1,devY2 : single;
  DSTPIX: PBGRATriple;
begin
  dstMemblock.width := newWidth;
  dstMemblock.height := newHeight;
  dstMemblock.colordepth := sizeof(TBGRATriple) * 8;

  if srcMemblock.colordepth <> dstMemblock.colordepth then
  begin
    result := -1;
    exit;
  end;

  result := 0;

  ps0 := Pointer(srcMemblock); Inc(pbyte(ps0), SizeOf(TImgMemBlockHeader));
  psstep := -srcMemblock.width * sizeof(TBGRATriple);
  pd0 := Pointer(dstMemblock); Inc(pbyte(pd0), SizeOf(TImgMemBlockHeader));
  pdstep := -dstMemblock.width * sizeof(TBGRATriple);
  fx := srcMemblock.width/ newWidth;
  fy := srcMemblock.height/newHeight;
  fix := 1/fx;
  fiy := 1/fy;
  fxstep := 0.9999 * fx;
  fystep := 0.9999 * fy;
  DSTPIX := PBGRATriple(pd0);
  for y := 0 to newHeight-1 do         //vertical destination pixels
  begin
    sy1 := fy * y;
    sy2 := sy1 + fystep;
    jstart := trunc(sy1);
    jend := trunc(sy2);
    devY1 := 1-sy1+jstart;
    devY2 := jend+1-sy2;
    for x := 0 to newWidth-1 do        //horizontal destination pixels
    begin
      sx1 := fx * x;                        //x related values are repeated
      sx2 := sx1 + fxstep;                  //for each y and may be placed in
      istart := trunc(sx1);                 //lookup table
      iend := trunc(sx2);                   //...

      if istart >= srcMemblock.width then istart := srcMemblock.width-1;
      if iend   >= srcMemblock.width then iend   := srcMemblock.width-1;

      devX1 := 1-sx1+istart;                  //...
      devX2 := iend+1-sx2;                  //...
      destR := 0; destG := 0; destB := 0;   //clear destination colors

      if jstart >= srcMemblock.height then jstart := srcMemblock.height-1;
      if jend   >= srcMemblock.height then jend   := srcMemblock.height-1;

      psj := ps0; dec(pbyte(psj), jstart*psStep);
      dy := devY1;

      for j := jstart to jend do  //vertical source pixels
      begin
        if j = jend then dy := dy - devY2;
        dyf := dy*fiy;
        psi := psj; Inc(pbyte(psi), istart*SizeOf(TBGRATriple));
        dx := devX1;
        for i := istart to iend do //horizontal source pixels
        begin
          if i = iend then dx := dx - devX2;
          AP := dx*dyf*fix;
          src := PBGRATriple(psi)^;

          destB := destB + src.B*AP;
          destG := destG + src.G*AP;
          destR := destR + src.R*AP;

          inc(pbyte(psi), sizeof(TBGRATriple));
          dx := 1;
        end;//for i
        dec(pbyte(psj),psStep);
        dy := 1;
      end;//for j

      src.B := round(destB);
      src.G := round(destG);
      src.R := round(destR);
      DSTPIX^ := src;
      inc(DSTPIX, 1{element});
      inc(result, SizeOf(TBGRATriple));
    end;//for x
  end;//for y
end;

function _Resize32(srcMemblock, dstMemblock: PImgMemBlockHeader; newWidth, newHeight: Cardinal): integer;
// --- Based on http://www.davdata.nl/math/bmresize.html ---
type
  TBGRATriple = packed record
    B: byte;
    G: byte;
    R: byte;
    A: byte;
  end;
  PBGRATriple = ^TBGRATriple;
var
  psStep,pdStep: integer;
  ps0,pd0 : Pointer;       //scanline[0], row steps
  sx1,sy1,sx2,sy2 : single;             //source field positions
  x,y,i,j: word;  //source,dest field pixels
  destA,destR,destG,destB : single;           //destination colors
  src: TBGRATriple;                      //source colors
  fx,fy,fix,fiy,dyf : single;           //factors
  fxstep,fystep, dx,dy : single;
  psi,psj : Pointer;
  AP : single;
  istart,iend,jstart,jend : word;
  devX1,devX2,devY1,devY2 : single;
  DSTPIX: PBGRATriple;
begin
  dstMemblock.width := newWidth;
  dstMemblock.height := newHeight;
  dstMemblock.colordepth := sizeof(TBGRATriple) * 8;

  if srcMemblock.colordepth <> dstMemblock.colordepth then
  begin
    result := -1;
    exit;
  end;

  result := 0;

  ps0 := Pointer(srcMemblock); Inc(pbyte(ps0), SizeOf(TImgMemBlockHeader));
  psstep := -srcMemblock.width * sizeof(TBGRATriple);
  pd0 := Pointer(dstMemblock); Inc(pbyte(pd0), SizeOf(TImgMemBlockHeader));
  pdstep := -dstMemblock.width * sizeof(TBGRATriple);
  fx := srcMemblock.width/ newWidth;
  fy := srcMemblock.height/newHeight;
  fix := 1/fx;
  fiy := 1/fy;
  fxstep := 0.9999 * fx;
  fystep := 0.9999 * fy;
  DSTPIX := PBGRATriple(pd0);
  for y := 0 to newHeight-1 do         //vertical destination pixels
  begin
    sy1 := fy * y;
    sy2 := sy1 + fystep;
    jstart := trunc(sy1);
    jend := trunc(sy2);
    devY1 := 1-sy1+jstart;
    devY2 := jend+1-sy2;
    for x := 0 to newWidth-1 do        //horizontal destination pixels
    begin
      sx1 := fx * x;                        //x related values are repeated
      sx2 := sx1 + fxstep;                  //for each y and may be placed in
      istart := trunc(sx1);                 //lookup table
      iend := trunc(sx2);                   //...

      if istart >= srcMemblock.width then istart := srcMemblock.width-1;
      if iend   >= srcMemblock.width then iend   := srcMemblock.width-1;

      devX1 := 1-sx1+istart;                  //...
      devX2 := iend+1-sx2;                  //...
      destR := 0; destG := 0; destB := 0; destA := 0;   //clear destination colors

      if jstart >= srcMemblock.height then jstart := srcMemblock.height-1;
      if jend   >= srcMemblock.height then jend   := srcMemblock.height-1;

      psj := ps0; dec(pbyte(psj), jstart*psStep);
      dy := devY1;

      for j := jstart to jend do  //vertical source pixels
      begin
        if j = jend then dy := dy - devY2;
        dyf := dy*fiy;
        psi := psj; Inc(pbyte(psi), istart*SizeOf(TBGRATriple));
        dx := devX1;
        for i := istart to iend do //horizontal source pixels
        begin
          if i = iend then dx := dx - devX2;
          AP := dx*dyf*fix;
          src := PBGRATriple(psi)^;

          destB := destB + src.B*AP;
          destG := destG + src.G*AP;
          destR := destR + src.R*AP;
          destA := destA + src.A*AP;

          inc(pbyte(psi), sizeof(TBGRATriple));
          dx := 1;
        end;//for i
        dec(pbyte(psj),psStep);
        dy := 1;
      end;//for j

      src.B := round(destB);
      src.G := round(destG);
      src.R := round(destR);
      src.A := round(destA);
      DSTPIX^ := src;
      inc(DSTPIX, 1{element});
      inc(result, SizeOf(TBGRATriple));
    end;//for x
  end;//for y
end;

function DestSize(memblock: PImgMemBlockHeader; newWidth, newHeight: Cardinal): integer; cdecl;
begin
  if memblock.colordepth = 32 then
    result := SizeOf(TImgMemBlockHeader) + newWidth * newHeight * 4
  else if memblock.colordepth = 24 then
    result := SizeOf(TImgMemBlockHeader) + newWidth * newHeight * 3
  else
    result := -1;
end;

function Resize(srcMemblock, dstMemblock: PImgMemBlockHeader; newWidth, newHeight: Cardinal): integer; cdecl;
begin
  if srcMemblock.colordepth = 32 then
    result := _Resize32(srcMemblock, dstMemblock, newWidth, newHeight)
  else if srcMemblock.colordepth = 24 then
    result := _Resize24(srcMemblock, dstMemblock, newWidth, newHeight)
  else
    result := -1;
end;

exports
  Resize name 'Resize',
  DestSize name 'DestSize';

end.
