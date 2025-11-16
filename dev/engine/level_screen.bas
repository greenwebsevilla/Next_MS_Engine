
ShowLayer2(0) 'Turn off Layer 2'
NextReg($70,$10) ' usar MODO 320x256'
clear_sprites()

'Reset scroll stuff'
ResetScroll320()
x_scroll = -32
x_scroll_temp = 0   
x_scroll_6 = x_scroll<<6
x_scroll_temp_6 = 0
columna_actual = 0
columna_anterior = 0


' Load the level assets'
'----------------------'
if NOT changing_floor  
#include "load_level_assets.bas"
end if


'Precalculos del mapa'
asm : nextreg $56,90 : nextreg $57,91 : end asm 
ancho_mapa = cast(uinteger, PEEK(DIMENSIONES_MAPA))
alto_mapa = cast(uinteger, PEEK(DIMENSIONES_MAPA+1))
asm : nextreg $56,0 : nextreg $57,1 : end asm 

x_fin_mapa = ((ancho_mapa - 18) << 4) - 2

' PRINT HUD
print_hud()

gpx = cast(uinteger, player_x_ini) << 4
gpy = cast(uinteger, player_y_ini) << 4

#ifdef TILANIMS
tilanims_first = LEVELS_FIRST_TILANIM
#endif

