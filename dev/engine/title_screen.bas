' Pantalla de inicio, menu, etc
DisableMusic
DisableSFX
' ShowLayer2(0)
' CLS256(0)
' CLS
ScrollLayer(0,0)
LoadSDBank("gfx/title.bin",0,0,0,18)
ClipLayer2(0,255,0,191)
ClipULA(0,255,0,191)
ShowLayer2(1)
EnableSFX
contador = 0
track = MUSIC_TITLE : play_music()

menu:
control = 1
	
do
	WaitRetrace(1)
	v = in(31)
	
	if MultiKeys(key_fire) 
		control = 0 'control por teclas'
		EXIT DO
	end if

	if v bAND %10000
		'control por kempston'
		EXIT DO
	end if

	'Redefinir teclas'
	if MultiKeys(KEYR) 
			redefine_keys()
		'  GOTO menu
	end if

	WaitForNoKey()
loop

RANDOMIZE
DisableMusic
PlaySFX(6)
pausa (50)
CLS
ShowLayer2(0)
CLS256(0)
CLS320()
