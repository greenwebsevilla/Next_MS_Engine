LoadSDBank("gfx/lang.bin",0,0,0,18)
ShowLayer2(1)
do
    if MultiKeys(KEY1) 
     idioma = 0 : EXIT DO
    end if

    if MultiKeys(KEY2) 
     idioma = 1 : EXIT DO
    end if
loop
PlaySFX(SOUND_LANGUAGE_SELECTED)
WaitForNoKey()
pausa(30)
ShowLayer2(0)
CLS
clear_sprites()


