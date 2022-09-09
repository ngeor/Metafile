program Metafile;

{$MODE Delphi}

uses
  Windows,
  Messages;

{$R Metafile.RES}

const
  ClassName = 'NGMETAVIEW';

var
  meta: HMETAFILE = 0;

  (* Register the main class with Windows. *)
  procedure RegisterWindowClass;
  var
    WndClass: TWndClass;
  begin
    if not GetClassInfo(HInstance, ClassName, @WndClass) then
    begin
      FillChar(WndClass, SizeOf(WndClass), #0);
      WndClass.hInstance := HInstance;
      WndClass.style := CS_HREDRAW or CS_VREDRAW;
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

  procedure RenderScene(DC: HDC);
  const
    Buf = 'Η ΕΙΚΟΝΑ ΔΕ ΒΡΕΘΗΚΕ';
  var
    Font, OldFont: HFont;
    LogFont: TLogFont;
    pt: TPoint;
    i, x, y: Integer;
    Pen, OldPen: HPEN;
    u: Extended;
  begin
    Pen := CreatePen(PS_SOLID, 10, RGB(255, 0, 0));
    OldPen := SelectObject(DC, Pen);
    SelectObject(DC, GetStockObject(NULL_BRUSH));
    Ellipse(DC, 5, 5, 110, 110);

    MoveToEx(DC, 22, 22, @pt);
    LineTo(DC, 93, 93);

    SelectObject(DC, OldPen);
    DeleteObject(Pen);

    u := 3600 / (Length(Buf) + 1);
    FillChar(LogFont, SizeOf(LogFont), #0);
    with LogFont do
    begin
      lfFaceName := 'Arial';
      lfCharset := GREEK_CHARSET;
      lfHeight := 11;
      lfWeight := 1000;
    end;
    SetBkMode(DC, TRANSPARENT);
    SetTextColor(DC, $0000FFFF);

    for i := 0 to Length(Buf) - 1 do
    begin
      LogFont.lfEscapement := round(-i * u);
      Font := CreateFontIndirect(LogFont);
      OldFont := SelectObject(DC, Font);

      x := Round(60 + 55 * cos(-i * u * pi / 1800 + pi / 2));
      y := Round(60 - 55 * sin(-i * u * pi / 1800 + pi / 2));
      TextOut(DC, x, y, @Buf[i + 1], 1);
      SelectObject(DC, OldFont);
      DeleteObject(Font);
    end;

  end;

  procedure Go(Wnd: HWND);
  var
    DC, ReferenceDC: HDC;
    R: TRect;
    iWidthMM, iHeightMM, iWidthPels, iHeightPels: Longint;
  begin
    if meta <> 0 then
    begin
      DeleteEnhMetafile(meta);
    end;

    ReferenceDC := GetDC(Wnd);

    iWidthMM := GetDeviceCaps(ReferenceDC, HORZSIZE);
    iHeightMM := GetDeviceCaps(ReferenceDC, VERTSIZE);
    iWidthPels := GetDeviceCaps(ReferenceDC, HORZRES);
    iHeightPels := GetDeviceCaps(ReferenceDC, VERTRES);

    GetClientRect(Wnd, R);

    R.left := (R.left * iWidthMM * 100) div iWidthPels;
    R.top := (R.top * iHeightMM * 100) div iHeightPels;
    R.right := (R.right * iWidthMM * 100) div iWidthPels;
    R.bottom := (R.bottom * iHeightMM * 100) div iHeightPels;

    DC := CreateEnhMetafile(ReferenceDC, 'Meta1.wmf', @R, nil);
    RenderScene(DC);
    meta := CloseEnhMetafile(DC);
    ReleaseDC(Wnd, ReferenceDC);
    InvalidateRect(Wnd, nil, True);
  end;

  procedure OnClose(Wnd: HWND);
  begin
    if meta <> 0 then
    begin
      DeleteEnhMetafile(meta);
      meta := 0;
    end;
    EndDialog(Wnd, 0);
  end;

  procedure OnPaint(Wnd: HWND);
  var
    R: TRect;
    ps: TPaintStruct;
    dc: HDC;
  begin
    if meta <> 0 then
    begin
      GetClientRect(Wnd, R);
      dc := BeginPaint(Wnd, ps);
      PlayEnhMetaFile(dc, meta, R);
      EndPaint(Wnd, ps);
    end;
  end;

  function MainDialogProc(Wnd: HWND; Msg: UINT; wp: WPARAM; lp: LPARAM): BOOL; stdcall;
  begin
    Result := Msg = WM_InitDialog;
    case Msg of
      WM_Close: OnClose(Wnd);
      WM_LButtonUp: Go(Wnd);
      WM_Paint: OnPaint(Wnd);
    end;
  end;

begin
  RegisterWindowClass;
  DialogBox(HInstance, 'MAIN', 0, @MainDialogProc);
end.
