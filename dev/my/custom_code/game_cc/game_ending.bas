'INSERT HERE CODE FOR GAME ENDING'

ShowLayer2(0)
clear_sprites()
CLS  
ResetScroll320()
MODE256 ' usar 256x192'
' DisableMusic
' DisableSFX
LoadSDBank("gfx/ending.bin",0,0,0,18)
ScrollLayer(0,175)
ClipLayer2(0,255,0,191)
ShowLayer2(1)
' EnableMusic
' EnableSFX
track = MUSIC_ENDING : play_music()
 
if idioma = 0
cadena1 = "YOU HAVE COMPLETED THE GAME... %CHANGE THIS SCREEN AND ADD%YOUR OWN CODE AT %GAME_ENDING.BAS*"
cadena2 = "GAME OVER*"
else
cadena1 = "HAS COMPLETADO EL JUEGO...%CAMBIA ESTA PANTALLA Y AÑADE TU%PROPIO CODIGO EN EL FICHERO%GAME_ENDING.BAS*"
cadena2 = "GAME OVER*"
end if

print_cadena(1)
pausa(300)
borra_cadena()
cadena1 = cadena2
print_cadena(1)
pausa(150)
borra_cadena()
pausa(100)



