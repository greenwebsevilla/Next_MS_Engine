' Pantalla de inicio, menu, etc
DisableMusic
DisableSFX
MODE256
HIDE_SPRITES
ScrollLayer(0,0)
LoadSDBank("gfx/title.bin",0,0,0,18)
ClipLayer2(0,255,0,191)
ClipULA(0,255,0,191)
ShowLayer2(1)
EnableSFX
contador = 0
track = MUSIC_TITLE : play_music()
border 0
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
	end if

	WaitForNoKey()
loop

DisableMusic
PlaySFX(SOUND_START_GAME)
pausa (50)
CLS
ShowLayer2(0)
CLS256(0)
asm 
okok:
end asm
CROP_ULA ' recortamos la ULA a solo la parte superior para el marcador