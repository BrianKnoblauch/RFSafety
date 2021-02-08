MODULE RFSafety;

FROM RealMath IMPORT pi, power, sqrt;
FROM RealStr  IMPORT ConvResults, RealToStr, StrToReal;
FROM SYSTEM   IMPORT ADR, CAST;
FROM Windows  IMPORT AppendMenu, BeginPaint, BM_GETCHECK, BN_CLICKED, BS_CHECKBOX, CreateMenu, CreateSolidBrush, CreateWindowEx, CS_SET, CW_USEDEFAULT,
                     DefWindowProc, DestroyWindow, DispatchMessage, EndPaint, FillRect, GetBkColor, GetDlgItemTextA,
                     GetMessage, HDC, HIWORD, HMENU, HWND, IDC_ARROW, IDI_APPLICATION, InvalidateRect, LoadCursor, LoadIcon, LOWORD,
		     LPARAM, LRESULT, MB_ICONEXCLAMATION,
                     MB_ICONINFORMATION, MB_OK, MessageBox, MSG, MF_STRING, MyInstance, PAINTSTRUCT, PostQuitMessage, RECT, RegisterClass,
		     SendDlgItemMessage, ShowWindow,
		     SW_SHOWNORMAL, TextOut, TranslateMessage, UINT, WM_CLOSE, WM_COMMAND, WM_DESTROY, WM_PAINT, WNDCLASS, WPARAM, WS_CHILD,
		     WS_EX_CLIENTEDGE, WS_SYSMENU, WS_VISIBLE;

CONST
     ABOUT_ITEM    = 1001;
     EXIT_ITEM     = 1002;
     g_szClassName = "myWindowClass";

VAR
     invalidaterect               : RECT;
     gfchecked                    : BOOLEAN;
     outputcompliancecontrolled   : ARRAY [0..3] OF CHAR;
     outputcomplianceuncontrolled : ARRAY [0..3] OF CHAR;
     outputdensity                : ARRAY [0..10] OF CHAR;
     outputdistancecontrolled     : ARRAY [0..10] OF CHAR;
     outputdistanceuncontrolled   : ARRAY [0..10] OF CHAR;
     outputmpecontrolled          : ARRAY [0..10] OF CHAR;
     outputmpeuncontrolled        : ARRAY [0..10] OF CHAR;

PROCEDURE ["StdCall"] WndProc(hwnd : HWND; msg : UINT; wParam : WPARAM;  lParam : LPARAM): LRESULT;
VAR
     DX              : REAL;
     DX1             : REAL;
     DX2             : REAL;
     EIRP            : REAL;
     GF              : REAL;
     hdc             : HDC;
     inputdistance   : ARRAY [0..10] OF CHAR;
     inputfrequency  : ARRAY [0..10] OF CHAR;
     inputgain       : ARRAY [0..10] OF CHAR;
     inputpower      : ARRAY [0..10] OF CHAR;
     PWR             : REAL;
     PWRDENS       : REAL;
     ps              : PAINTSTRUCT;
     resultdistance  : ConvResults;
     resultfrequency : ConvResults;
     resultgain      : ConvResults;
     resultpower     : ConvResults;
     std1            : REAL;
     std2            : REAL;
     valuedistance   : REAL;
     valuefrequency  : REAL;
     valuegain       : REAL;
     valuepower      : REAL;    
			   
BEGIN
    CASE msg OF
    | WM_COMMAND :      
      (* TODO - Handle checkbox click? *)
      CASE LOWORD(wParam) OF        
        | ABOUT_ITEM:          
	  MessageBox(NIL,
		     "A port from Java to Modula-2 of a port from BASIC to Java of FCC RF Safety calculations from the early 2000's.  Use at your own risk as it's still in beta and has not yet been updated to current FCC regulations.",
		     "RFSafety", MB_ICONINFORMATION + MB_OK);
            RETURN 0;
        | EXIT_ITEM:
            PostQuitMessage (0);
	    RETURN 0;
	(* TODO - Checkbox activation code does not work *)
(*	| IDB_CHECKBOX:
	    CASE HIWORD(wParam) OF
	      | BN_CLICKED:
	        IF SendDlgItemMessage(hwnd, IDB_CHECKBOX, BM_GETCHECK, 0, 0) = 0 THEN
                     MessageBox(NIL, "Checkbox Selected", "Success", MB_OK | MB_ICONINFORMATION);
                ELSE
                     MessageBox(NIL, "Checkbox Unselected", "Success", MB_OK | MB_ICONINFORMATION);
		END; (* IF *)
	    END; (* CASE *)   
	    RETURN 0; *)
       ELSE
	    (* TODO - Get dialog info only works for the first input box *)
	    GetDlgItemTextA(hwnd, 0, inputpower, 10);
	    StrToReal(inputpower, valuepower, resultpower); 
	    GetDlgItemTextA(hwnd, 1, inputgain, 10);
	    StrToReal(inputgain, valuegain, resultgain);
	    GetDlgItemTextA(hwnd, 2, inputfrequency, 10);
	    StrToReal(inputfrequency, valuefrequency, resultfrequency);
	    GetDlgItemTextA(hwnd, 3, inputdistance, 10);
	    StrToReal(inputdistance, valuedistance, resultdistance);
	    IF (resultpower = strAllRight) AND (resultgain = strAllRight) AND (resultfrequency = strAllRight) AND (resultdistance = strAllRight) THEN
		 (* TODO - Perform calculations and update output text*)
		 (* PWR = 1000 * WATTS *)
		 PWR := valuepower * 1000.0;
		 (* EIRP = PWR * (10 ^ (GAIN / 10)) *)
		 EIRP := PWR * power(valuegain / 10.0, 10.0);
		 (* DX = FT * 30.48 *)
		 DX := valuedistance * 30.48;
		 (* 260 IF F<1.34 THEN STD1=100:STD2=100:GOTO 330
		    270 IF F<3 THEN STD1=100:STD2=180/((F)^2):GOTO 330
		    280 IF F<30 THEN STD1=900/((F)^2):STD2=180/((F)^2):GOTO 330
		    290 IF F<300 THEN STD1=1:STD2=.2:GOTO 330
		    300 IF F<1500 THEN STD1=F/300:STD2=F/1500:GOTO 330
		    310 IF F<100000! THEN STD1=5:STD2=1:GOTO 330 *)
		 IF valuefrequency < 1.34 THEN
		      std1 := 100.0;
		      std2 := 100.0;
		 ELSIF valuefrequency < 3.0 THEN
		      std1 := 100.0;
		      std2 := 180.0 / power(valuefrequency, 2.0);
		 ELSIF valuefrequency < 30.0 THEN
		      std1 := 900.0 / power(valuefrequency, 2.0);
		      std2 := 180.0 / power(valuefrequency, 2.0);
		 ELSIF valuefrequency < 300.0 THEN
		      std1 := 1.0;
		      std2 := 0.2;
		 ELSIF valuefrequency < 1500.0 THEN
		      std1 := valuefrequency / 300.0;
		      std2 := valuefrequency / 1500.0;
		 ELSIF valuefrequency < 100000.0 THEN
		      std1 := 5.0;
		      std2 := 1.0;
		 ELSE
                      (* TODO - Add note field or just break as not valid? *)
		      (* 320 PRINT "THE FCC DOES NOT HAVE EXPOSURE LIMITS ABOVE 100 GHZ":GOTO 250 *)
		      std1 := 0.0;
		      std2 := 0.0;
		 END; (* IF *)
		 (* 370 GF=.25:GR$="WITHOUT":IF G$="Y" THEN GF=.64:GR$="WITH"
                    380 IF G$="y" THEN GF=.64:GR$="WITH" *)
		 IF gfchecked THEN
		      GF := 0.64;
		 ELSE
		      GF := 0.25;
		 END; (* IF *)
		 (* 390 PWRDENS = (GF * EIRP) / (3.14159 * (DX ^ 2)) *)
		 PWRDENS := (GF * EIRP) / (pi * power(DX, 2.0));
           	 (* 400 PWRDENS=(INT((PWRDENS*10000)+.5))/10000 *)              
		 (* 410 DX1=SQR((GF*EIRP)/(STD1*3.14159)):DX1=DX1/30.48:DX1=(INT((DX1*10)+.5))/10 *)
		 DX1 := sqrt((GF * EIRP) / (std1 * pi)) / 30.48;
		 (* 420 DX2=SQR((GF*EIRP)/(STD2*3.14159)):DX2=DX2/30.48:DX2=(INT((DX2*10)+.5))/10 *)
		 DX2 := sqrt((GF * EIRP) / (std2 * pi)) / 30.48;
                 (* 430 STD1=(INT((STD1*100)+.5))/100:STD2=(INT((STD2*100)+.5))/100 *)              
                 (* 450 PRINT "FROM THE ANTENNA CENTER THE ESTIMATED POWER DENSITY IS";PWRDENS;"MW/CM2.":PRINT *)
		 RealToStr(PWRDENS, outputdensity);
		 (* 460 PRINT "AT";F;"MHZ, THE MAXIMUM PERMISSIBLE EXPOSURE (MPE) IN `CONTROLLED" *)
		 (* 470 PRINT "ENVIRONMENTS' (SUCH AS YOUR OWN HOUSEHOLD OR CAR) IS"; STD1; "MW/CM2." *)
		 RealToStr(std1, outputmpecontrolled);
		 (* 480 PRINT "THE MPE IN `UNCONTROLLED ENVIRONMENTS' (SUCH AS NEIGHBORS' PROPERTY)" *)
		 (* 490 PRINT "IS"; STD2; "MW/CM2.  THIS INSTALLATION WOULD MEET THE CONTROLLED MPE" *)
		 RealToStr(std2, outputmpeuncontrolled);
		 (* 500 PRINT "LIMIT AT";DX1;"FEET AND THE UNCONTROLLED LIMIT AT";DX2;"FEET." *)
		 RealToStr(DX1, outputdistancecontrolled);
		 RealToStr(DX2, outputdistanceuncontrolled);
		 IF (DX / 30.48) > DX1 THEN
		      outputcompliancecontrolled := "YES";
		 ELSE
		      outputcompliancecontrolled := " NO";
		 END; (* IF *)
		 IF (DX / 30.48) > DX2 THEN
		      outputcomplianceuncontrolled := "YES";
		 ELSE
		      outputcomplianceuncontrolled := " NO";
		 END; (* IF *)
	    ELSE
		 outputcompliancecontrolled := " NO";
		 outputcomplianceuncontrolled := " NO";
		 outputdensity := "          ";
		 outputdistancecontrolled := "          ";
		 outputdistanceuncontrolled := "          ";
		 outputmpecontrolled := "          ";
		 outputmpeuncontrolled := "          ";
	    END; (* IF *)
	    InvalidateRect(hwnd, invalidaterect, FALSE);
        END; (* CASE *)
      RETURN 0;
    | WM_PAINT   :      
      hdc := BeginPaint(hwnd, ps);
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
      FillRect(hdc, invalidaterect, CreateSolidBrush(GetBkColor(hdc)));
      TextOut(hdc, 250, 160, outputdensity, 10);
      TextOut(hdc, 250, 190, outputmpecontrolled, 10);
      TextOut(hdc, 250, 220, outputmpeuncontrolled, 10);
      TextOut(hdc, 250, 250, outputdistancecontrolled, 10);
      TextOut(hdc, 250, 280, outputdistanceuncontrolled, 10);
      TextOut(hdc, 250, 310, outputcompliancecontrolled, 3);
      TextOut(hdc, 250, 340, outputcomplianceuncontrolled, 3);
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

    gfchecked := FALSE;
    
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
