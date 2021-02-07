MODULE RFSafety;

FROM SYSTEM  IMPORT ADR, CAST;
FROM Windows IMPORT BeginPaint, CreateWindowEx, CS_SET, CW_USEDEFAULT, DefWindowProc, DestroyWindow, DispatchMessage, EndPaint, GetMessage, HDC, HWND,
                    IDC_ARROW, IDI_APPLICATION, LoadCursor, LoadIcon, LPARAM, LRESULT, MB_ICONEXCLAMATION, MB_OK, MessageBox, MSG, MyInstance,
		    PAINTSTRUCT, PostQuitMessage, RegisterClass, ShowWindow, SW_SHOWNORMAL, TranslateMessage, UINT, WM_CLOSE, WM_COMMAND, WM_DESTROY,
		    WM_PAINT, WNDCLASS, WPARAM, WS_EX_CLIENTEDGE, WS_SYSMENU, WS_VISIBLE;

CONST
     g_szClassName = "myWindowClass";

PROCEDURE ["StdCall"] WndProc(hwnd : HWND; msg : UINT; wParam : WPARAM;  lParam : LPARAM): LRESULT;
VAR
     hdc            : HDC;
     ps             : PAINTSTRUCT;
			   
BEGIN
    CASE msg OF
    | WM_COMMAND :
      (* TODO - Process form *)
      RETURN 0;
    | WM_PAINT   :      
      hdc := BeginPaint(hwnd, ps);
      (* TODO - Paint/generate form *)
      EndPaint(hwnd, ps);
      RETURN 0;
    | WM_CLOSE   :
      DestroyWindow(hwnd);
    | WM_DESTROY :
      PostQuitMessage(0);
    ELSE RETURN DefWindowProc(hwnd, msg, wParam, lParam);
    END; (* CASE *)
    RETURN 0;
END WndProc;

VAR
    className       : ARRAY [0..14] OF CHAR;
    hwnd            : HWND;
    Msg             : MSG;
    wc              : WNDCLASS;

BEGIN
        (* Register the Window Class *)
    wc.style         := CAST(CS_SET, NIL);
    wc.lpfnWndProc   := WndProc;
    wc.cbClsExtra    := 0;
    wc.cbWndExtra    := 0;
    wc.hInstance     := MyInstance();
    wc.hIcon         := LoadIcon(NIL, IDI_APPLICATION);
    wc.hCursor       := LoadCursor(NIL, IDC_ARROW);
    wc.lpszMenuName  := NIL;
    className        := g_szClassName;
    wc.lpszClassName := ADR(className);

    IF RegisterClass(wc)=0 THEN
       MessageBox(NIL, "Window Class registration failed!", "Error!", MB_ICONEXCLAMATION + MB_OK);
       RETURN ;
    END;
               
    (* Create the Window *)
    hwnd := CreateWindowEx(WS_EX_CLIENTEDGE, g_szClassName, "RFSafety", WS_VISIBLE + WS_SYSMENU, CW_USEDEFAULT, CW_USEDEFAULT,
			   480, 360, NIL, NIL, MyInstance(), NIL);
    IF hwnd = NIL THEN
       MessageBox(NIL, "Window Creation failed!", "Error!", MB_ICONEXCLAMATION + MB_OK);
       RETURN ;
    END;

    (* Create menu (exit and about box) plus input windows *)
    ShowWindow(hwnd, SW_SHOWNORMAL);
            
    (* The Message Loop *)
    WHILE GetMessage( Msg, NIL, 0, 0) DO
       TranslateMessage(Msg);
       DispatchMessage(Msg);
    END;

END RFSafety.
