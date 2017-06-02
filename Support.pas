unit Support;

{$MODE Delphi}

interface

uses
  Types, SysUtils, Math;

const
  NilPoint: TPoint =
    (
      X: 0;
      Y: 0;
    );
  InfinityPoint: TPoint =
    (
      X: MaxInt;
      Y: MaxInt;
    );

  PRECISION = 0.00001;

type

  TPoints = array of TPoint;
  
  TRotationMatrix = class; //forward declaration

  TPrecisePoint = class
    private
      _x, _y: Real;
      function getPoint(): TPoint;
      procedure setPoint(p: TPoint);
    public
      function pointDistance(p: TPrecisePoint): Real; //vrati vzdialenost bodu od bodu
      function toString(): String; //vrati textovu reprezentaciu
      function clone(): TPrecisePoint; //vrati kopiu bodu

      constructor Create(x, y: Real); overload; //vytvori bod zo suradnic
      constructor Create(p: TPoint); overload; //vytvori bod z bodu :)

      property point: TPoint read getPoint write setPoint; //vrati bod ako record
      property x: Real read _x write _x; //X suradnica bodu
      property y: Real read _y write _y; //Y suradnica bodu
  end;

  TPrecisePoints = array of TPrecisePoint;

  TPlanarVector = class
    private
      _x, _y: Real;
    public
      function getLength(): Real; //vrati dlzku vektora
      function getPerpendicularVector(): TPlanarVector; //vrati kolmy vektor
      function toString(): String; //vrati textovu reprezentaciu
      function clone(): TPlanarVector; //vrati kopiu vektora

      procedure rotate(angle: Real); overload; //otoci vektor o zadany uhol
      procedure rotate(matrix: TRotationMatrix); overload; //otoci vektor o maticu
      procedure perpendicular(); //zmeny vektor na kolmy
      procedure reverse(); //otoci vektor
      procedure normalize(); //vytvori vektor s dlzkov 1

      constructor Create(x, y: Real); overload; //vytvori priamo z suradnic
      constructor Create(x1, y1, x2, y2: Integer); overload; //vytvori z danych bodov
      constructor Create(a, b: TPrecisePoint); overload; //vytvori vektor z 2 presnych bodov
      constructor Create(a, b: TPoint); overload; //vytvori vektor z 2 bodov (triedy)

      property x: Real read _x write _x; //X suradnica vektoru
      property y: Real read _y write _y; //Y suradnica vektoru
  end;

  TGeneralLineEquation = class  //ak je vektror normalovy nulovy tak da prianku rovnobeznu z osou X
    private
      _v: TPlanarVector;
      _p: TPrecisePoint;
      function getA(): Real;
      function getB(): Real;
      function getC(): Real;
      procedure setControlVector(v: TPlanarVector);
      procedure setControlPoint(p: TPrecisePoint);

    public
      function pointOnLine(p: TPoint): Boolean; //vrati true ak je bod na priamke, inak false
      function pointDistance(p: TPoint): Integer; //vrati vzdialenost bodu od priamky
      function solve(x, y: Real): Real; overload; //dosadi do rovnice x a y a vrati hodnotu
      function solve(p: TPoint): Real; overload; //to iste ako s predchadzajuce akurat s bodom
      function toString(): String; //vrati textovu reprezentaciu
      function clone(): TGeneralLineEquation; //vrati kopiu prianky

      procedure perpendicular(p: TPrecisePoint); overload; //zmeny priamku na kolmu, prechadzajucu zadanym bodom
      procedure perpendicular(p: TPoint); overload; //zmeny priamku na kolmu, prechadzajucu zadanym bodom
      procedure rotate(angle: Real; p: TPrecisePoint); //otoci priamku o zadany uhol okolo bodu P, ak je nil pouzije controlPoint 

      constructor Create(x1, y1, x2, y2: Integer); overload; //vytvori priamku z 2 bodov (zadane cele suradnice)
      constructor Create(a, b: TPoint); overload; //vytvori priamku z 2 bodov
      constructor Create(a, b: TPrecisePoint); overload; //vytvori priamku z 2 bodov
      constructor Create(point: TPoint; normal: TPlanarVector); overload; //vytvori priamku z bodu a normaloveho vektora
      constructor Create(point: TPrecisePoint; normal: TPlanarVector); overload; //vytvori priamku z bodu a normaloveho vektora

      destructor Destroy(); override;

      property controlPoint: TPrecisePoint read _p write setControlPoint;  //riadiaci bod
      property controlVector: TPlanarVector read _v write setControlVector; //riadiaci vektor, normala
      property a: Real read getA;
      property b: Real read getB;
      property c: Real read getC;
  end;

  TGeneralEllipseEquation = class
    private
      _m: TPrecisePoint;
      _a, _b: Real;

      function getF(): Real;
    public
      function pointInEllipse(p: TPoint): Boolean;
      function pointDistance(p: TPoint): Integer; //vzdialenost bodu od elipsi
      function lineIntersection(l: TGeneralLineEquation): TPrecisePoints; overload;
      function lineIntersection(a, b, c: Real): TPrecisePoints; overload;
      function xToPoint(x: Real): TPrecisePoint; //vrati bod ktory je na elipse a x suradnicu x - vrati bod s kladnou zlozkov y
      function yToPoint(y: Real): TPrecisePoint; //vrati bod ktory je na elipse a x suradnicu y - vrati bod s kladnou zlozkov x
      function toString(): String;
      function getPoints(): TPoints;

      constructor Create(x, y, a, b: Real);

      destructor Destroy; override;

      property a: Real read _a write _a; //semimajor axis
      property b: Real read _b write _b; //semiminor axis
      property f: Real read getF; //flattening
      property centre: TPrecisePoint read _m write _m;
  end;

  TRotationMatrix = class
    private
      _matrix: array [0..1] of array [0..1] of Real;
    public
      procedure vectorMultiply(v: TPlanarVector); //vynasobi vektor maticou

      constructor Create(angle: Real); //vytvori maticu otocenia
  end;

  TSupport = class
    private
      class function crossProductLength(v, u: TPlanarVector): Real;
      class function dotProduct(v, u: TPlanarVector): Real;
    public
      class function distance(a, b: TPrecisePoint): Real; overload;
      class function distance(a, b: TPoint): Real; overload;
      class function angle(v, u: TPlanarVector): Real;
      class function rotate(point, around: TPrecisePoint; angle: Real): TPrecisePoint; overload; //vracia prvy argument
      class function rotate(point, around: TPoint; angle: Real): TPoint; overload;
      class function rotate(point: TPrecisePoint; around: TPoint; angle: Real): TPrecisePoint; overload;
      class function rotate(point: TPoint; around: TPrecisePoint; angle: Real): TPoint; overload;
      class function binomialCoefficient(n, k: Integer): Integer;
  end;

implementation

//-------------------TPrecisePoint-----------------------

function TPrecisePoint.getPoint(): TPoint;
begin
  Result.X := round(_x);
  Result.Y := round(_y);
end;

procedure TPrecisePoint.setPoint(p: TPoint);
begin
  _x := p.X;
  _y := p.Y;
end;

function TPrecisePoint.pointDistance(p: TPrecisePoint): Real;
begin
  result := abs(sqrt(sqr(p.x - x) + sqr(p.y - y)));
end;

function TPrecisePoint.toString(): String;
begin
  Result := 'X: ' + FloatToStrF(x, ffFixed, 2, 2) + ' Y: ' + FloatToStrF(y, ffFixed, 2, 2);
end;

function TPrecisePoint.clone(): TPrecisePoint;
begin
  Result := TPrecisePoint.Create(x, y);
end;

constructor TPrecisePoint.Create(x, y: Real);
begin
  _x := x;
  _y := y;
end;

constructor TPrecisePoint.Create(p: TPoint);
begin
  Create(p.X, p.Y);
end;              

//------------------TSupport----------------------

class function TSupport.crossProductLength(v, u: TPlanarVector): Real;
begin
  Result := v.x*u.y - v.y*u.x;
end;

class function TSupport.dotProduct(v, u: TPlanarVector): Real;
begin
  Result := (v.x * u.x) + (v.y * u.y);
end;

class function TSupport.distance(a, b: TPrecisePoint): Real;
begin
  Result := a.pointDistance(b)
end;

class function TSupport.distance(a, b: TPoint): Real;
begin
  Result := sqrt((a.x-b.x)*(a.x-b.x) + (a.y-b.y)*(a.y-b.y));
end;

class function TSupport.angle(v, u: TPlanarVector): Real;  //moze hodit invalid floating point op - uz nemoze :)
begin
  Result := 0;
  if ((u.getLength * v.getLength = 0)) then
    Exit;
  Result := ArcSin(crossProductLength(v, u) / (u.getLength * v.getLength));
  Result := (Result / Pi) * 180;
end;

class function TSupport.rotate(point, around: TPrecisePoint; angle: Real): TPrecisePoint;
var
  v: TPlanarVector;
begin
  v := TPlanarVector.Create(around, point);
  v.rotate(angle);
  point.x := around.x - v.x;
  point.y := around.y - v.y;
  v.Free;
  Result := point;
end;

class function TSupport.rotate(point, around: TPoint; angle: Real): TPoint;
var
  v: TPlanarVector;
begin
  v := TPlanarVector.Create(around, point);
  v.rotate(angle);
  Result.x := round(around.x - v.x);
  Result.y := round(around.y - v.y);
  v.Free;
end;

class function TSupport.rotate(point: TPrecisePoint; around: TPoint; angle: Real): TPrecisePoint;
var
  v: TPlanarVector;
  pom: TPrecisePoint;
begin
  pom := TPrecisePoint.Create(around);
  v := TPlanarVector.Create(pom, point);
  v.rotate(angle);
  point.x := around.x - v.x;
  point.y := around.y - v.y;
  v.Free;
  pom.Free;
  Result := point;
end;

class function TSupport.rotate(point: TPoint; around: TPrecisePoint; angle: Real): TPoint;
var
  v: TPlanarVector;
  pom: TPrecisePoint;
begin
  pom := TPrecisePoint.Create(point);
  v := TPlanarVector.Create(around, pom);
  v.rotate(angle);
  Result.x := round(around.x - v.x);
  Result.y := round(around.y - v.y);
  v.Free;
  pom.Free;
end;

class function TSupport.binomialCoefficient(n, k: Integer): Integer;
var
  i: Integer;
begin
  Result := 1;
  if ((n < 1) or (k < 0)) then
    Result := 0;
  if ((n > 0) and (k > 0)) then
  begin
    for i := 1 to n do
      Result := Result * i;
    for i := 1 to k do
      Result := Result div i;
    for i := 1 to n - k do
      Result := Result div i;
  end;
end;

//----------------TPlanarVector-------------------

function TPlanarVector.getLength(): Real;
begin
  Result := sqrt(_x*_x + _y*_y);
end;

function TPlanarVector.getPerpendicularVector(): TPlanarVector;
begin
  Result := TPlanarVector.Create(-y, x);
end;

function TPlanarVector.toString(): String;
begin
  Result := 'X: ' + FloatToStrF(x, ffFixed, 2, 2) +
            ' Y: ' + FloatToStrF(y, ffFixed, 2, 2) +
            ' length: ' + FloatToStrF(getLength, ffFixed, 2, 2);
end;

function TPlanarVector.clone(): TPlanarVector;
begin
  Result := TPlanarVector.Create(x, y);
end;

procedure TPlanarVector.rotate(angle: Real);
var
  matrix: TRotationMatrix;
begin
  matrix := TRotationMatrix.Create(angle);
  rotate(matrix);
  matrix.Free();
end;

procedure TPlanarVector.rotate(matrix: TRotationMatrix);
begin
  matrix.vectorMultiply(Self);
end;

procedure TPlanarVector.perpendicular();
var
  pom: Real;
begin
  pom := -_y;
  _y := _x;
  _x := pom;
end;

procedure TPlanarVector.normalize();
var
  length: Real;
begin
  length := getLength;
  if (length = 0) then
    Exit;
  _x := _x / length;
  _y := _y / length;
end;

procedure TPlanarVector.reverse();
begin
  _x := -_x;
  _y := -_y;
end;

constructor TPlanarVector.Create(x, y: Real);
begin
  _x := x;
  _y := y;
end;

constructor TPlanarVector.Create(x1, y1, x2, y2: Integer);
begin
  Create(x1 - x2, y1 - y2);
end;

constructor TPlanarVector.Create(a, b: TPrecisePoint);
begin
  Create(a.x - b.x, a.y - b.y);
end;

constructor TPlanarVector.Create(a, b: TPoint);
begin
  Create(a.X - b.X, a.Y - b.Y);
end;

//--------------TGeneralLineEquation---------------

function TGeneralLineEquation.getA(): Real;
begin
  Result := _v.x;
end;

function TGeneralLineEquation.getB(): Real;
begin
  Result := _v.y;
end;

function TGeneralLineEquation.getC(): Real;
begin
  Result := -((a * _p.x) + (b * _p.y));
end;

function TGeneralLineEquation.pointOnLine(p: TPoint): boolean;
begin
  Result := (a * p.x + b * p.y + c) = 0;
end;

function TGeneralLineEquation.pointDistance(p: TPoint): Integer;
begin
  if ((a = 0) and (b = 0)) then              //ak to  podstete ani nieje priamka, tedaboli zadane rovnake body
    Result := round(TSupport.distance(p, _p.point))
  else
    result := abs(round((a*p.X + b*p.Y + c) / sqrt(a*a + b*b)));
end;

function TGeneralLineEquation.solve(x, y: Real): Real;
begin
  Result := a*x + b*y + c;
end;

function TGeneralLineEquation.solve(p: TPoint): Real;
begin
  Result := solve(p.X, p.Y);
end;

procedure TGeneralLineEquation.setControlVector(v: TPlanarVector);
begin
  if (v <> nil) then
    begin
    if (_v <> nil) then
      _v.Free;
    _v := v
    end
  else
    raise EInvalidPointer.Create('Vector can not be nil.');
end;

procedure TGeneralLineEquation.setControlPoint(p: TPrecisePoint);
begin
  if (p <> nil) then
    begin
    if (_p <> nil) then
      _p.Free;
    _p := p
    end
  else
    raise EInvalidPointer.Create('Point can not be nil.');
end;

function TGeneralLineEquation.toString(): String;
begin
  Result := FloatToStrF(a, ffFixed, 2, 2) + '*x + ' +
            FloatToStrF(b, ffFixed, 2, 2) + '*y + ' +
            FloatToStrF(c, ffFixed, 2, 2) + ' = 0';
end;

function TGeneralLineEquation.clone(): TGeneralLineEquation;
begin
  Result := TGeneralLineEquation.Create(controlPoint.clone(), controlVector.clone());
end;

procedure TGeneralLineEquation.perpendicular(p: TPoint);
begin
  controlVector.perpendicular();
  if (_p <> nil) then
    _p.Free;
  _p := TPrecisePoint.Create(p);
end;

procedure TGeneralLineEquation.perpendicular(p: TPrecisePoint);
begin
  controlVector.perpendicular();
  if (_p <> nil) then
    _p.Free;
  _p := p.clone();
end;

procedure TGeneralLineEquation.rotate(angle: Real; p: TPrecisePoint);
var
  pom: TPlanarVector;
begin
  _v.rotate(angle);
  pom := TPlanarVector.Create(p, _p);
  pom.rotate(angle);           
  _p.x := p.x - pom.x;
  _p.y := p.y - pom.y;
  pom.Free;
end;

constructor TGeneralLineEquation.Create(x1, y1, x2, y2: Integer);
begin
  if ((x1 = x2) and (y1 = y2)) then
    x2 := x2 + 10;
  _p := TPrecisePoint.Create(x1, y1);
  _v := TPlanarVector.Create(x1, y1, x2, y2);
  _v.perpendicular();
  _v.normalize();
end;

constructor TGeneralLineEquation.Create(a, b: TPoint);
begin
  Create(a.X, a.Y, b.X, b.Y);
end;

constructor TGeneralLineEquation.Create(point: TPoint; normal: TPlanarVector);
begin
  if (normal = nil) then
    raise EInvalidPointer.Create('Vector can not be nil.');
  _p := TPrecisePoint.Create(point);
  _v := normal.clone();
  if (_v.getLength = 0) then
    _v.x := _v.x + 10;
  _v.normalize();
end;

constructor TGeneralLineEquation.Create(point: TPrecisePoint; normal: TPlanarVector);
begin
  if (normal = nil) then
    raise EInvalidPointer.Create('Vector can not be nil.');
  if (point = nil) then
    raise EInvalidPointer.Create('Point can not be nil.');
  _p := point.clone();
  _v := normal.clone();
  if (_v.getLength = 0) then
    _v.x := _v.x + 10;
  _v.normalize();
end;

constructor TGeneralLineEquation.Create(a, b: TPrecisePoint);
begin
  if ((a = nil) or (b = nil)) then
    raise EInvalidPointer.Create('Point can not be nil.');
  _p := a.clone();
  _v := TPlanarVector.Create(a, b);
  _v.perpendicular();
  _v.normalize();
end;

destructor TGeneralLineEquation.Destroy();
begin
  _v.Free();
  _p.Free();
end;

//-------------------TRotationMatrix---------------

procedure TRotationMatrix.vectorMultiply(v: TPlanarVector);
var
  x, y: Real;
begin
  x := v.x;
  y := v.y;
  v.x := _matrix[0, 0]*x + _matrix[1, 0]*y;
  v.y := _matrix[0, 1]*x + _matrix[1, 1]*y;
end;

constructor TRotationMatrix.Create(angle: Real);
var
  pom: Real;
begin
  pom := (angle / 180) * Pi;
  _matrix[0, 0] := Cos(pom);
  _matrix[0, 1] := -Sin(pom);
  _matrix[1, 0] := Sin(pom);
  _matrix[1, 1] := Cos(pom);
end;

//------------TGeneralEllipseEquation--------------
    {
function TGeneralEllipseEquation.pointOnEllipse(p: TPoint): Boolean; //v podstate ani nefunguje :)
begin
  Result := (((p.X - _m.point.X)/(_a*_a)) + ((p.Y - _m.point.Y)/(_b*_b))) < (1 + PRECISION);
  Result := Result or (((p.X - _m.point.X)/(_a*_a)) + ((p.Y - _m.point.Y)/(_b*_b))) > (1 - PRECISION);
end; }

function TGeneralEllipseEquation.pointInEllipse(p: TPoint): Boolean;
begin
  Result := (((p.X - _m.point.X)*(p.X - _m.point.X)/(_a*_a)) + ((p.Y - _m.point.Y)*(p.Y - _m.point.Y)/(_b*_b))) < 1 ;
end;

function TGeneralEllipseEquation.xToPoint(x: Real): TPrecisePoint;
var
  p: Real;
begin
  x := x - centre.x;
  p := (1 - (x*x)/(a*a))*(b*b);
  if (p < 0) then
    Result := nil
  else
    Result := TPrecisePoint.Create(x + centre.x, sqrt(p) + centre.y);
end;

function TGeneralEllipseEquation.yToPoint(y: Real): TPrecisePoint;
var
  p: Real;
begin
  y := y - centre.y;
  p := (1 - (y*y)/(b*b))*(a*a);
  if (p < 0) then
    Result := nil
  else
    Result := TPrecisePoint.Create(sqrt(p) + centre.x, y + centre.y);
end;

function TGeneralEllipseEquation.lineIntersection(l: TGeneralLineEquation): TPrecisePoints;
begin
  Result := lineIntersection(l.a, l.b, l.c);
end;

function TGeneralEllipseEquation.lineIntersection(a, b, c: Real): TPrecisePoints;
var
  k, l, x: Real;
  p: TPrecisePoint;
  a1, a2, a3, D, cc: Real;
begin
  Result := nil;
  if (abs(b) <= PRECISION) then
  begin
    if (a = 0) then
      Exit;
    k := (-c)/a;
    p := xToPoint(k);
    if (p <> nil) then
    begin
      if (p.y = 0) then
      begin
        SetLength(Result, 1);
        Result[0] := p;
      end
      else
      begin
        SetLength(Result, 2);
        Result[0] := p;
        Result[1] := TPrecisePoint.Create(p.x, -p.y);
      end;
    end;
  Exit;
  end;
  //ak b nieje 0
  cc := c;
  p := TPrecisePoint.Create(0, -c/b);
  c := -(a*(p.x-centre.x)+b*(p.Y-centre.Y));  //posuneme o stred
  p.Free;
  k := (-a)/b;
  l := ((-c)/b);
  a1 := ((_a*_a)*(k*k)) + (_b*_b);
  a2 := (2*k*l*(_a*_a));
  a3 := ((l*l)*(_a*_a)) - ((_a*_a)*(_b*_b));
  D := (a2*a2) - (4*a1*a3);
  if (D < 0) then
    Exit;
  if (D = 0) then
  begin
    SetLength(Result, 1);
    x := (-a2)/(2*a1);
    x := x + centre.x;
    Result[0] := TPrecisePoint.Create(x, ((-a*x) - c)/b);
    Exit;
  end;
  if (D > 0) then
  begin
    SetLength(Result, 2);
    x := ((-a2) + sqrt(D))/(2*a1);
    x := x + centre.x;
    Result[0] := TPrecisePoint.Create(x, ((-a*x) - cc)/b);
    x := ((-a2) - sqrt(D))/(2*a1);
    x := x + centre.x;
    Result[1] := TPrecisePoint.Create(x, ((-a*x) - cc)/b);
    Exit;
  end;
end;

function TGeneralEllipseEquation.pointDistance(p: TPoint): Integer;
const
  ITERATION = 100;
var
  pom, it: TPrecisePoint;
  poc: Integer;
  great: (a, b);
begin
  Result := MaxInt;
  poc := 0;
  if (_b > _a) then        //chceme ju tak aby hlavna os bola rovnobezna z X
    great := b
  else
    great := a;
  pom := TPrecisePoint.Create(abs(p.X - centre.x), abs(p.Y - centre.y));
  repeat
    if (great = a) then
      it := xToPoint((_a/ITERATION)*poc + centre.x)
    else
      it := yToPoint((_b/ITERATION)*poc + centre.y);
    if (not (it = nil)) then
    begin
      it.x := it.x - centre.x;
      it.y := it.y - centre.y;
      Result := Min(Result, round(TSupport.distance(it, pom)));
      it.Free;
    end;
    poc := poc + 1;
  until poc > ITERATION;
  pom.Free;
end;

function TGeneralEllipseEquation.toString(): String;
begin
  Result := 'X: ' + FloatToStrF(centre.x, ffFixed, 2, 2) + ' Y: ' + FloatToStrF(centre.y, ffFixed, 2, 2) +
            'majoraxis: '+ FloatToStrF(a, ffFixed, 2, 2) + ' minoraxis: '+ FloatToStrF(b, ffFixed, 2, 2);
end;

function TGeneralEllipseEquation.getPoints(): TPoints;
var
  angle: Real;
  i: Integer;
  Ellipse_points: Integer;
begin
  Ellipse_points := max(round((b+a) / 5), 30);
  SetLength(Result, Ellipse_points);
  for i:= 0 to Ellipse_points-1 do
  begin
    angle := -PI + ((PI/Ellipse_points)*(2*i));
    Result[i].X := round(centre.x + a*cos(angle));
    Result[i].Y := round(centre.y + b*sin(angle));
  end;
end;

function TGeneralEllipseEquation.getF(): Real;
begin
  Result := 1 - (b/a);
end;

constructor TGeneralEllipseEquation.Create(x, y, a, b: Real);
begin
  _m := TPrecisePoint.Create(x, y);
  _a := a;
  _b := b;
end;

destructor TGeneralEllipseEquation.Destroy;
begin
  _m.Free;
end;

//-------------------------------------------------

end.
