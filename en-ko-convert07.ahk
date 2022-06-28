#SingleInstance, Force
#NoEnv
SetBatchLines, -1
ListLines, Off
#persistent

;;컨트롤+스페이스=영문 오타 한단어 전환
;;오른쪽 윈도우키=영문 오타 한단어 전환
;;오른쪽 앱키=영문 오타 한줄 전환
;;컨트롤 + esc 누르면 프로그램 종료 <- 이것 있으면 작동을 안함
;;<#esc::exitapp
;;<#`::Pause  ; Pressing Win+` once will pause the script. Pressing it again will unpause.
Menu, Tray, Tip, EN/KR

^Space::
	BeepSound()
;;	LedLight()
	Clipboard=
	Send,{shiftdown}{ctrldown}{left}{ctrlup}{shiftup}
	Goto,CONV
        SoundBeep, 2000, 50
return

RWin::
	BeepSound()
;;	LedLight()
	Clipboard=
	Send,{shiftdown}{ctrldown}{left}{ctrlup}{shiftup}
	Goto,CONV
return

AppsKey::
;;	LedLight()
	BeepSound()
	Clipboard=
	Send,{shiftdown}{home}{shiftup}
	Goto,CONV
return
	
BeepSound()
{
If CheckIME(WinExist("A"))
        {      
	SoundBeep, 700, 250
	  } 
Else
	 {
        SoundBeep, 2000, 50
	Sleep, 50
        SoundBeep, 2000, 50
	}
}
return

LedLight()
{
If CheckIME(WinExist("A"))
        {      
	KeyboardLED(1, "off", 0)  ; all LED('s) according to keystate (Command = on or off) 
	  } 
Else
	 {
	KeyboardLED(1, "on", 0)  ; all LED('s) according to keystate (Command = on or off) 
	}
}
return

;한영 영한 전환
;https://windowsforum.kr/index.php?&mid=lecture&search_target=title_content&search_keyword=%ED%95%9C%EC%98%81&document_srl=14042639
Hi:=StrSplit("r R s e E f a q Q t T d w W c z x v g",A_Space)
Hm:=StrSplit("k o i O j p u P h hk ho hl y n nj np nl b m ml l",A_Space)
Hf:=StrSplit("r R rt s sw sg e f fr fa fq ft fx fv fg a q qt t T d w c z x v g",A_Space)
Hs:=StrSplit("r R rt s sw sg e E f fr fa fq ft fx fv fg a q Q qt t T d w W c z x v g k o i O j p u P h hk ho hl y n nj np nl b m ml l",A_Space)
CONV:
	Send,^x
	ClipWait,1
	if ErrorLevel
		return
	Loop, parse, clipboard
	{
		chrAsc:=Asc(A_LoopField)
		if (65<=chrAsc and chrAsc<=90) or (97<=chrAsc and chrAsc<=122) or chrAsc=33
		{
			Gosub,KO
			SendRaw,%A_LoopField%
		}
		else
		{
			if RegExMatch(A_LoopField,"[가-힣]")
			{
				i:=Floor((Asc(A_LoopField)-44032)/588)+1
				m:=Floor(Mod((Asc(A_LoopField)-44032),588)/28)+1
				f:=Mod((Asc(A_LoopField)-44032),28)
				o:=Hi[i] Hm[m] (Mod((Asc(A_LoopField)-44032),28) ? Hf[f]:"")
			}
			else if RegExMatch(A_LoopField,"[ㄱ-ㅣ]")
			{
				s:=Asc(A_LoopField)-12592
				o:=Hs[s]
			}
			else
			{
				o:=A_LoopField
			}
			Gosub,EN
			SendInput,%o%
		}
	}
	return

KO:
	if IME_CHECK("A")=0
		Send, {vk15sc138}
	return
EN:
	if IME_CHECK("A")=1
		Send, {vk15sc138}
	return
IME_CHECK(WinTitle)
{
	WinGet,hWnd,ID,%WinTitle%
	Return Send_ImeControl(ImmGetDefaultIMEWnd(hWnd),0x005,"")
}
Send_ImeControl(DefaultIMEWnd, wParam, lParam)
{
	DetectSave := A_DetectHiddenWindows
	DetectHiddenWindows,ON
	SendMessage 0x283,wParam,lParam,,ahk_id %DefaultIMEWnd%
	if (DetectSave <> A_DetectHiddenWindows)
		DetectHiddenWindows,%DetectSave%
	Return ErrorLevel
}
ImmGetDefaultIMEWnd(hWnd)
{
	Return DllCall("imm32\ImmGetDefaultIMEWnd",Uint,hWnd,Uint)
}

CheckIME(hWnd) 
{ 
DefaultIMEWnd := DllCall("imm32\ImmGetDefaultIMEWnd", "UInt", hWnd) 
DetectSave := A_DetectHiddenWindows 
DetectHiddenWindows, On 
SendMessage, 0x283, 0x005, 0,, ahk_id %DefaultIMEWnd% 
DetectHiddenWindows, %DetectSave% 
Return ErrorLevel
}


/*

    Keyboard LED control for AutoHotkey_L
        http://www.autohotkey.com/forum/viewtopic.php?p=468000#468000

    KeyboardLED(LEDvalue, "Cmd", Kbd)
        LEDvalue  - ScrollLock=1, NumLock=2, CapsLock=4
        Cmd       - on/off/switch
        Kbd       - index of keyboard (probably 0 or 2)

*/


KeyboardLED(LEDvalue, Cmd, Kbd)
{
  SetUnicodeStr(fn,"\Device\KeyBoardClass" Kbd)
  h_device:=NtCreateFile(fn,0+0x00000100+0x00000080+0x00100000,1,1,0x00000040+0x00000020,0)
  
  If Cmd= switch  ;switches every LED according to LEDvalue
   KeyLED:= LEDvalue
  If Cmd= on  ;forces all choosen LED's to ON (LEDvalue= 0 ->LED's according to keystate)
   KeyLED:= LEDvalue | (GetKeyState("ScrollLock", "T") + 2*GetKeyState("NumLock", "T") + 4*GetKeyState("CapsLock", "T"))
  If Cmd= off  ;forces all choosen LED's to OFF (LEDvalue= 0 ->LED's according to keystate)
    {
    LEDvalue:= LEDvalue ^ 7
    KeyLED:= LEDvalue & (GetKeyState("ScrollLock", "T") + 2*GetKeyState("NumLock", "T") + 4*GetKeyState("CapsLock", "T"))
    }
  
  success := DllCall( "DeviceIoControl"
              ,  "ptr", h_device
              , "uint", CTL_CODE( 0x0000000b     ; FILE_DEVICE_KEYBOARD
                        , 2
                        , 0             ; METHOD_BUFFERED
                        , 0  )          ; FILE_ANY_ACCESS
              , "int*", KeyLED << 16
              , "uint", 4
              ,  "ptr", 0
              , "uint", 0
              ,  "ptr*", output_actual
              ,  "ptr", 0 )
  
  NtCloseFile(h_device)
  return success
}

CTL_CODE( p_device_type, p_function, p_method, p_access )
{
  Return, ( p_device_type << 16 ) | ( p_access << 14 ) | ( p_function << 2 ) | p_method
}


NtCreateFile(ByRef wfilename,desiredaccess,sharemode,createdist,flags,fattribs)
{
  VarSetCapacity(objattrib,6*A_PtrSize,0)
  VarSetCapacity(io,2*A_PtrSize,0)
  VarSetCapacity(pus,2*A_PtrSize)
  DllCall("ntdll\RtlInitUnicodeString","ptr",&pus,"ptr",&wfilename)
  NumPut(6*A_PtrSize,objattrib,0)
  NumPut(&pus,objattrib,2*A_PtrSize)
  status:=DllCall("ntdll\ZwCreateFile","ptr*",fh,"UInt",desiredaccess,"ptr",&objattrib
                  ,"ptr",&io,"ptr",0,"UInt",fattribs,"UInt",sharemode,"UInt",createdist
                  ,"UInt",flags,"ptr",0,"UInt",0, "UInt")
  return % fh
}

NtCloseFile(handle)
{
  return DllCall("ntdll\ZwClose","ptr",handle)
}


SetUnicodeStr(ByRef out, str_)
{
  VarSetCapacity(out,2*StrPut(str_,"utf-16"))
  StrPut(str_,&out,"utf-16")
}
return