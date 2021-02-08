MODULE RFSafety;

FROM RealStr IMPORT ConvResults, StrToReal;
FROM SYSTEM  IMPORT ADR, CAST;
FROM Windows IMPORT AppendMenu, BeginPaint, BS_CHECKBOX, CreateMenu, CreateWindowEx, CS_SET, CW_USEDEFAULT, DefWindowProc, DestroyWindow, DispatchMessage,
                    EndPaint, GetDlgItemTextA,
                    GetMessage, HDC, HMENU, HWND, IDC_ARROW, IDI_APPLICATION, InvalidateRect, LoadCursor, LoadIcon, LOWORD, LPARAM, LRESULT,
		    MB_ICONEXCLAMATION,
                    MB_ICONINFORMATION, MB_OK, MessageBox, MSG, MF_STRING, MyInstance, PAINTSTRUCT, PostQuitMessage, RECT, RegisterClass, ShowWindow,
		    SW_SHOWNORMAL, TextOut, TranslateMessage, UINT, WM_CLOSE, WM_COMMAND, WM_DESTROY, WM_PAINT, WNDCLASS, WPARAM, WS_CHILD,
		    WS_EX_CLIENTEDGE, WS_SYSMENU, WS_VISIBLE;

CONST
     ABOUT_ITEM    = 1001;
     EXIT_ITEM     = 1002;
     g_szClassName = "myWindowClass";

VAR
     invalidaterect : RECT;

PROCEDURE ["StdCall"] WndProc(hwnd : HWND; msg : UINT; wParam : WPARAM;  lParam : LPARAM): LRESULT;
VAR
     hdc             : HDC;
     inputdistance   : ARRAY [0..10] OF CHAR;
     inputfrequency  : ARRAY [0..10] OF CHAR;
     inputgain       : ARRAY [0..10] OF CHAR;
     inputpower      : ARRAY [0..10] OF CHAR;
     ps              : PAINTSTRUCT;
     resultdistance  : ConvResults;
     resultfrequency : ConvResults;
     resultgain      : ConvResults;
     resultpower     : ConvResults;
     valuedistance   : REAL;
     valuefrequency  : REAL;
     valuegain       : REAL;
     valuepower      : REAL;    
			   
BEGIN
    CASE msg OF
    | WM_COMMAND :      
      (* TODO - Handle checkbox click? *)
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
	    GetDlgItemTextA(hwnd, 0, inputpower, 10);
	    StrToReal(inputpower, valuepower, resultpower); 
	    GetDlgItemTextA(hwnd, 0, inputgain, 10);
	    StrToReal(inputgain, valuegain, resultgain);
	    GetDlgItemTextA(hwnd, 0, inputfrequency, 10);
	    StrToReal(inputfrequency, valuefrequency, resultfrequency);
	    GetDlgItemTextA(hwnd, 0, inputdistance, 10);
	    StrToReal(inputdistance, valuedistance, resultdistance);
	    IF (resultpower = strAllRight) AND (resultgain = strAllRight) AND (resultfrequency = strAllRight) AND (resultdistance = strAllRight) THEN
		 (* TODO - Perform calculations and update output text*)
	    ELSE
		 (* TODO - Blank output text *)
	    END; (* IF *)
	    InvalidateRect(hwnd, invalidaterect, FALSE);
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
    distancehwnd    : HWND;
    frequencyhwnd   : HWND; 
    gainhwnd        : HWND;
    gfhwnd          : HWND;
    hwnd            : HWND;
    menu            : HMENU;
    Msg             : MSG;
    powerhwnd       : HWND;
    wc              : WNDCLASS;

BEGIN
    invalidaterect.left := 250;
    invalidaterect.top := 10;
    invalidaterect.right := 350;
    invalidaterect.bottom := 420;
    
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
			   350, 420, NIL, menu, MyInstance(), NIL);
    IF hwnd = NIL THEN
       MessageBox(NIL, "Window Creation failed!", "Error!", MB_ICONEXCLAMATION + MB_OK);
       RETURN ;
    END;

    (* Create menu (exit and about box) plus input windows *)
    powerhwnd := CreateWindowEx(WS_EX_CLIENTEDGE, "Edit", "", WS_CHILD, 250, 10, 80, 20, hwnd, NIL, MyInstance(), NIL);
    gainhwnd := CreateWindowEx(WS_EX_CLIENTEDGE, "Edit", "", WS_CHILD, 250, 40, 80, 20, hwnd, NIL, MyInstance(), NIL);
    frequencyhwnd := CreateWindowEx(WS_EX_CLIENTEDGE, "Edit", "", WS_CHILD, 250, 70, 80, 20, hwnd, NIL, MyInstance(), NIL);
    distancehwnd := CreateWindowEx(WS_EX_CLIENTEDGE, "Edit", "", WS_CHILD, 250, 100, 80, 20, hwnd, NIL, MyInstance(), NIL);
    gfhwnd := CreateWindowEx(WS_EX_CLIENTEDGE, "Button", "", WS_CHILD + BS_CHECKBOX, 250, 130, 17, 17, hwnd, NIL, MyInstance(), NIL);
    
    ShowWindow(hwnd, SW_SHOWNORMAL);
    ShowWindow(powerhwnd, SW_SHOWNORMAL);
    ShowWindow(gainhwnd, SW_SHOWNORMAL);
    ShowWindow(frequencyhwnd, SW_SHOWNORMAL);
    ShowWindow(distancehwnd, SW_SHOWNORMAL);
    ShowWindow(gfhwnd, SW_SHOWNORMAL);
            
    (* The Message Loop *)
    WHILE GetMessage( Msg, NIL, 0, 0) DO
       TranslateMessage(Msg);
       DispatchMessage(Msg);
    END;

END RFSafety.
