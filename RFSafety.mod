MODULE RFSafety;

FROM SYSTEM  IMPORT ADR, CAST;
FROM Windows IMPORT AppendMenu, BeginPaint, CreateWindowEx, CS_SET, CW_USEDEFAULT, DefWindowProc, DestroyWindow, DispatchMessage, EnableMenuItem,
                    EndPaint, GetMessage, GetSystemMenu, HDC, HMENU, HWND, IDC_ARROW, IDI_APPLICATION, LoadCursor, LoadIcon, LOWORD, LPARAM, LRESULT,
                    MB_ICONEXCLAMATION, MB_OK, MessageBox, MF_BYCOMMAND, MSG, MF_ENABLED, MF_STRING, MyInstance, PAINTSTRUCT, PostQuitMessage,
		    RegisterClass, ShowWindow, SW_SHOWNORMAL, TranslateMessage, UINT, WM_CLOSE, WM_COMMAND, WM_CREATE, WM_DESTROY, WM_INITMENU, WM_PAINT,
		    WM_SYSCOMMAND, WNDCLASS, WPARAM, WS_EX_CLIENTEDGE, WS_SYSMENU, WS_VISIBLE;

CONST
     ABOUT_ITEM    = 1001;
     EXIT_ITEM     = 1002;
     g_szClassName = "myWindowClass";

PROCEDURE ["StdCall"] WndProc(hwnd : HWND; msg : UINT; wParam : WPARAM;  lParam : LPARAM): LRESULT;
VAR
     hdc            : HDC;
     menu           : HMENU;
     ps             : PAINTSTRUCT;
			   
BEGIN
    CASE msg OF
    | WM_COMMAND :
      (* TODO - Process form *)
      RETURN 0;
    | WM_CREATE  :
      menu := GetSystemMenu (hwnd, FALSE);
      AppendMenu(menu, MF_STRING, ABOUT_ITEM, "&About");
      AppendMenu(menu, MF_STRING, EXIT_ITEM,  "E&xit");
      RETURN 0;
    | WM_INITMENU:
      menu := GetSystemMenu (hwnd, FALSE);
      EnableMenuItem(menu, ABOUT_ITEM, MF_BYCOMMAND + MF_ENABLED);
      EnableMenuItem(menu, EXIT_ITEM, MF_BYCOMMAND + MF_ENABLED);        
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
    | WM_SYSCOMMAND:
         CASE LOWORD (wParam) OF        
        | ABOUT_ITEM:
            (* TODO - Popup about window *)
            RETURN 0;
        | EXIT_ITEM:
            PostQuitMessage (0);
	    RETURN 0;
	ELSE
        END; (* CASE *)
    ELSE 
    END; (* CASE *)
    RETURN DefWindowProc(hwnd, msg, wParam, lParam);
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
