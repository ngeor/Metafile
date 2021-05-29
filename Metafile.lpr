program Metafile;

{$MODE Delphi}

uses
  Windows,
  Messages;

{$R Metafile.RES}

const
  ClassName = 'NGMETAVIEW';

(* Register the main class with Windows. *)
procedure RegisterWindowClass;
var
  WndClass: TWndClass;
begin
  if not GetClassInfo(HInstance, ClassName, @WndClass) then
  begin
    FillChar(WndClass, SizeOf(WndClass), #0);
    WndClass.hInstance := HInstance;
    with WndClass do
    begin
      lpfnWndProc := @DefDlgProc;
      cbWndExtra := DLGWINDOWEXTRA;
      hIcon := LoadIcon(HInstance, MakeIntResource(1));
      hCursor := LoadCursor(0, IDC_Arrow);
      hbrBackGround := COLOR_WINDOW + 1;
      lpszClassName := ClassName;
    end;
    if RegisterClass(WndClass) = 0 then
    begin
      MessageBox(0, 'Αδύνατη η εγγραφή της κλάσης!', nil, 0);
      Halt;
    end;
  end;
end;

{
procedure RenderScene(DC: HDC);
const
  Buf: Array[0..12] of Char = 'Installation';
var
  Font, OldFont: HFont;
  LogFont: TLogFont;
  R: TRect;
begin
  FillChar(LogFont, SizeOf(LogFont), #0);
  With LogFont Do Begin
    lfFaceName:='Arial Greek';
    lfHeight:=-32;
    lfWeight:=700;
  End;
  Font:=CreateFontIndirect(LogFont);
  OldFont:=SelectObject(DC, Font);
  SetBkMode(DC, TRANSPARENT);
  SetTextColor(DC, $0000FFFF);
  R.Left:=14;
  R.Top:=4;
  R.Right:=200;
  R.Bottom:=100;
  DrawText(DC, Buf, -1, R, 0);
  R.Left:=13;
  R.Top:=3;
  SetTextColor(DC, $000000FF);
  DrawText(DC, Buf, -1, R, 0);
  SelectObject(DC, OldFont);

  DeleteObject(Font);
end;
}
procedure RenderScene(DC: HDC);
const
  Buf = 'Η ΕΙΚΟΝΑ ΔΕ ΒΡΕΘΗΚΕ';
var
  Font, OldFont: HFont;
  LogFont: TLogFont;
  pt: TPoint;
  i, x, y: integer;
  Pen, OldPen: HPEN;
  u: extended;
begin
  Pen := CreatePen(PS_SOLID, 10, RGB(255, 0, 0));
  OldPen := SelectObject(DC, Pen);
  SelectObject(DC, GetStockObject(NULL_BRUSH));
  Ellipse(DC, 5, 5, 110, 110);

  MoveToEx(DC, 22, 22, @pt);
  LineTo(DC, 93, 93);

  SelectObject(DC, OldPen);
  DeleteObject(Pen);

  u := 3600 / (Length(Buf)+1);
  FillChar(LogFont, SizeOf(LogFont), #0);
  with LogFont do begin
    lfFaceName := 'Arial';
    lfCharset  := GREEK_CHARSET;
    lfHeight   := 11;
    lfWeight   := 1000;
  end;
  SetBkMode(DC, TRANSPARENT);
  SetTextColor(DC, $0000FFFF);

  for i:=0 to Length(Buf)-1 do begin
    LogFont.lfEscapement := round(-i*u);
    Font := CreateFontIndirect(LogFont);
    OldFont := SelectObject(DC, Font);

    x := Round(60 + 55 * cos(-i*u*pi/1800+pi/2));
    y := Round(60 - 55 * sin(-i*u*pi/1800+pi/2));
    TextOut(DC, x, y, @Buf[i+1], 1);
    SelectObject(DC, OldFont);
    DeleteObject(Font);
  end;

end;

procedure Go(Wnd: HWND);
var
  DC, DC1: HDC;
  hMeta: HMETAFILE;
  R: TRect;
begin
  DC1 := GetDC(Wnd);
  GetClientRect(Wnd, R);
  DC := CreateEnhMetafile(DC1, 'Meta1.wmf', @R, nil);
  RenderScene(DC);
  hMeta := CloseEnhMetafile(DC);
  FillRect(DC1, R, GetStockObject(WHITE_BRUSH));
  PlayEnhMetaFile(DC1, hMeta, R);
  DeleteEnhMetafile(hMeta);
  ReleaseDC(Wnd, DC1);
end;

function MainDialogProc(Wnd: HWND; Msg: UINT; wp: WPARAM; lp: LPARAM): BOOL; stdcall;
begin
  Result := Msg = WM_InitDialog;
  case Msg of
    WM_Close: EndDialog(Wnd, 0);
    WM_LButtonUp: Go(Wnd);
  end;
end;

begin
  RegisterWindowClass;
  DialogBox(HInstance, 'MAIN', 0, @MainDialogProc);
end.
