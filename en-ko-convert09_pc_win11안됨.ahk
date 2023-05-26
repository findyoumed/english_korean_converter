#SingleInstance, Force
#NoEnv
SetBatchLines, -1
ListLines, Off
#persistent

;;컨트롤+스페이스=영문 오타 한단어 전환
;;오른쪽 윈도우키=영문 오타 한단어 전환
;;오른쪽 앱키   =영문 오타 한줄 전환
;;컨트롤+한영전환=영문 오타 한줄 전환
;;컨트롤 + esc 누르면 프로그램 종료 <- 이것 있으면 작동을 안함
;;<#esc::exitapp
;;<#`::Pause  ; Pressing Win+` once will pause the script. Pressing it again will unpause.
Menu, Tray, Tip, EN/KR
Hi:=StrSplit("r R s e E f a q Q t T d w W c z x v g",A_Space)
Hm:=StrSplit("k o i O j p u P h hk ho hl y n nj np nl b m ml l",A_Space)
Hf:=StrSplit("r R rt s sw sg e f fr fa fq ft fx fv fg a q qt t T d w c z x v g",A_Space)
Hs:=StrSplit("r R rt s sw sg e E f fr fa fq ft fx fv fg a q Q qt t T d w W c z x v g k o i O j p u P h hk ho hl y n nj np nl b m ml l",A_Space)

^Space::
;;	Gosub, BeepSound
	;BeepSound()
	Clipboard=
	Send,{shiftdown}{ctrldown}{left}{ctrlup}{shiftup}
	Goto,CONV
        SoundBeep, 2000, 50
return

RWin::
;;	Gosub, BeepSound
	;BeepSound()
	Clipboard=
	Send,{shiftdown}{ctrldown}{left}{ctrlup}{shiftup}
	Goto,CONV
return

AppsKey::
	;BeepSound()
	Clipboard=
	Send,{shiftdown}{home}{shiftup}
	Goto,CONV
return

$^SC1F2:: ;;pc용
;^SC138:: ;;laptop용
	;BeepSound()
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