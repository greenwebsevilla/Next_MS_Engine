DisableMusic
DisableSFX
ShowLayer2(0) 'Turn off Layer 2'

clear_sprites()
CLS320()

'Reset scroll stuff'
ResetScroll320()
x_scroll = -32
x_scroll_temp = 0   
x_scroll_6 = x_scroll<<6
x_scroll_temp_6 = 0
columna_actual = 0
columna_anterior = 0


NextReg($70,$10) ' usar MODO 320x256'
ShowLayer2(0) 'Turn off Layer 2'
CLS320()
' CLS


' Load the level assets'
'----------------------'
#include "load_level_assets.bas"

'Precalculos del mapa'
ancho_mapa = cast(uinteger, PEEK(DIMENSIONES_MAPA))
alto_mapa = cast(uinteger, PEEK(DIMENSIONES_MAPA+1))
x_fin_mapa = ((ancho_mapa - 18) <<4) - 2

' PRINT HUD
print_hud()

gpx = cast(uinteger, player_x_ini) << 4
gpy = cast(uinteger, player_y_ini) << 4

#ifdef TILANIMS
tilanims_first = LEVELS_FIRST_TILANIM
#endif

EnableMusic