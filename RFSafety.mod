MODULE RFSafety;

FROM SYSTEM  IMPORT ADR, CAST;
FROM Windows IMPORT AppendMenu, BeginPaint, CreateMenu, CreateWindowEx, CS_SET, CW_USEDEFAULT, DefWindowProc, DestroyWindow, DispatchMessage, EndPaint,
                    GetMessage, HDC, HMENU, HWND, IDC_ARROW, IDI_APPLICATION, LoadCursor, LoadIcon, LOWORD, LPARAM, LRESULT, MB_ICONEXCLAMATION,
                    MB_ICONINFORMATION, MB_OK, MessageBox, MSG, MF_STRING, MyInstance, PAINTSTRUCT, PostQuitMessage, RegisterClass, ShowWindow,
		    SW_SHOWNORMAL, TextOut, TranslateMessage, UINT, WM_CLOSE, WM_COMMAND, WM_DESTROY, WM_PAINT, WNDCLASS, WPARAM, WS_EX_CLIENTEDGE,
		    WS_SYSMENU, WS_VISIBLE;

CONST
     ABOUT_ITEM    = 1001;
     EXIT_ITEM     = 1002;
     g_szClassName = "myWindowClass";

PROCEDURE ["StdCall"] WndProc(hwnd : HWND; msg : UINT; wParam : WPARAM;  lParam : LPARAM): LRESULT;
VAR
     hdc            : HDC;
     ps             : PAINTSTRUCT;
			   
BEGIN
    CASE msg OF
    | WM_COMMAND :
      (* TODO - Process form data / kick off calculation? *)
      CASE LOWORD (wParam) OF        
        | ABOUT_ITEM:          
	  MessageBox(NIL,
		     "A port from Java to Modula-2 of a port from BASIC to Java of FCC RF Safety calculations from the early 2000's.  Use at your own risk as it's still in beta and has not yet been updated to current FCC regulations.",
		     "RFSafety", MB_ICONINFORMATION + MB_OK);
            RETURN 0;
        | EXIT_ITEM:
            PostQuitMessage (0);
	    RETURN 0;
	ELSE
        END; (* CASE *)
      RETURN 0;
    | WM_PAINT   :      
      hdc := BeginPaint(hwnd, ps);
      (* TODO - Paint/generate form *)
      TextOut(hdc, 5, 10, "Power", 5);
      TextOut(hdc, 200, 10, ":", 1);
      TextOut(hdc, 5, 40, "Gain", 4);
      TextOut(hdc, 200, 40, ":", 1);
      TextOut(hdc, 5, 70, "Frequency", 9);
      TextOut(hdc, 200, 70, ":", 1);
      TextOut(hdc, 5, 100, "Distance", 8);
      TextOut(hdc, 200, 100, ":", 1);
      TextOut(hdc, 5, 130, "Ground Reflection", 17);
      TextOut(hdc, 200, 130, ":", 1);
      TextOut(hdc, 5, 160, "Power Density", 13);
      TextOut(hdc, 200, 160, ":", 1);
      TextOut(hdc, 5, 190, "Controlled MPE", 14);
      TextOut(hdc, 200, 190, ":", 1);
      TextOut(hdc, 5, 220, "Uncontrolled MPE", 16);
      TextOut(hdc, 200, 220, ":", 1);
      TextOut(hdc, 5, 250, "Controlled Distance", 19);
      TextOut(hdc, 200, 250, ":", 1);
      TextOut(hdc, 5, 280, "Uncontrolled Distance", 21);
      TextOut(hdc, 200, 280, ":", 1);
      TextOut(hdc, 5, 310, "Controlled Compliance", 21);
      TextOut(hdc, 200, 310, ":", 1);
      TextOut(hdc, 5, 340, "Uncontrolled Compliance", 23);
      TextOut(hdc, 200, 340, ":", 1);      
      EndPaint(hwnd, ps);
      RETURN 0;
    | WM_CLOSE   :
      DestroyWindow(hwnd);
    | WM_DESTROY :
      PostQuitMessage(0);
    ELSE 
    END; (* CASE *)
    RETURN DefWindowProc(hwnd, msg, wParam, lParam);
END WndProc;

VAR
    className       : ARRAY [0..14] OF CHAR;
    hwnd            : HWND;
    menu            : HMENU;
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

    menu := CreateMenu();
    AppendMenu(menu, MF_STRING, ABOUT_ITEM, "&About");
    AppendMenu(menu, MF_STRING, EXIT_ITEM,  "E&xit");
               
    (* Create the Window *)
    hwnd := CreateWindowEx(WS_EX_CLIENTEDGE, g_szClassName, "RFSafety", WS_VISIBLE + WS_SYSMENU, CW_USEDEFAULT, CW_USEDEFAULT,
			   480, 420, NIL, menu, MyInstance(), NIL);
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
