#define _check_interrupts _checkints

'Variables generales
dim track, old_track as ubyte
dim fichero as string
dim direccion, size as uinteger
dim half_life, half_life2, success as ubyte
dim i, j, k as ubyte
dim dif_x, dif_y as integer


' Variables & Defines Player
dim num_objects as ubyte
dim playing, player_energy, lives, player_damaged as ubyte
dim p_vx, p_vy, total_vx, total_vy as integer 
dim player_x_ini, player_y_ini as ubyte 
dim p_x, p_y as integer 
dim gpx, gpy as uinteger
dim p_frame, p_subframe, player_facing, spnum, p_frame_base as ubyte 
dim player_status, p_ct_estado, player_jumping, jump_pressed, brinco as ubyte 
dim on_ground as ubyte 
dim plataforma_vx, plataforma_vy as integer
dim ptx1, pty1, ptx2, pty2 as uinteger 'Puntos caja de colision player
dim _x1, _y1 as uinteger 
dim _x as integer
dim _y, _n, _t as ubyte

dim spike_touched as ubyte
dim ct1, ct2, ct3, aux1, aux2, aux3, aux4 as ubyte 'Puntos auxiliares
dim cx1, cy1, cx2, cy2, cx3, cy3 as integer 'Puntos auxiliares
dim contador as ubyte

dim player_counter, fps_animacion as ubyte
dim diferencia, distancia as integer
dim auxi1 as integer
dim auxi2, auxi3, auxi4, uit as ubyte
dim ajuste_ccol_y as ubyte
dim score, next_extra_life as uinteger
dim ladder_on, ladder_up, ladder_down, ladder_middle as ubyte
dim val_a, val_b as ubyte

#define FACING_RIGHT    0
#define FACING_LEFT     8
#define FACING_UP       2
#define FACING_DOWN     3

#define EST_NORMAL 		0
#define EST_SALTANDO	1
#define EST_PARP 		9
#define EST_MURIENDO	10

'Array frames player'
dim player_frames(MAX_FRAMES_PLAYER-1) as ubyte
                                 

'Variables disparos player'
dim disparando, disparado as ubyte 
dim x_bala (3)  as uinteger
dim y_bala (3)  as ubyte
dim v_bala (3)  as byte
dim facing_bala (3)  as byte
dim estado_bala (3)  as ubyte


'Variables enemigos'
dim total_enemies as ubyte 'Guarda el total de enemigos del nivel actual'
dim enit, enviit as ubyte 'iteradores para enem y enem visibles'
dim enoffset as uinteger
dim active, no_kill as ubyte
dim en_an_frame (MAX_ENEMS) as ubyte
dim en_an_subframe (MAX_ENEMS) as ubyte
dim enem_counter (MAX_ENEMS) as ubyte
dim en_an_state (MAX_ENEMS) as ubyte
dim en_an_facing (MAX_ENEMS) as ubyte
dim en_an_fps (MAX_ENEMS) as ubyte
dim en_an_num_frames (MAX_ENEMS) as ubyte
dim enemies_t (MAX_ENEMS) as ubyte
dim enemies_npant (MAX_ENEMS) as ubyte
dim enemies_spritenum (MAX_ENEMS) as ubyte
dim enemies_life (MAX_ENEMS) as byte
dim enemies_maxlife (MAX_ENEMS) as byte
dim enemies_x (MAX_ENEMS) as integer
dim enemies_y (MAX_ENEMS) as integer
dim enemies_x1 (MAX_ENEMS) as integer
dim enemies_y1 (MAX_ENEMS) as integer
dim enemies_x2 (MAX_ENEMS) as integer
dim enemies_y2 (MAX_ENEMS) as integer
dim enemies_mx (MAX_ENEMS) as byte
dim enemies_mx_ini (MAX_ENEMS) as byte
dim enemies_my (MAX_ENEMS) as byte
dim enemies_my_ini (MAX_ENEMS) as byte
dim enem_vy (MAX_ENEMS) as integer 'Velocidad para saltarines y osciladores'
dim enem_ajuste_ccol_y as ubyte

'Variables auxiliares para custom code'
dim enem_var1 (MAX_ENEMS) as ubyte
dim enem_var2 (MAX_ENEMS) as ubyte
dim enem_var3 (MAX_ENEMS) as ubyte
dim enem_var4 (MAX_ENEMS) as ubyte
dim enem_var5 (MAX_ENEMS) as ubyte
dim enem_counter2 (MAX_ENEMS) as ubyte

#ifdef FANTYS
'Fantys'
dim enemies_x_fanty (MAX_ENEMS) as integer
dim enemies_y_fanty (MAX_ENEMS) as integer
dim enemies_mx_fanty (MAX_ENEMS) as integer
dim enemies_my_fanty (MAX_ENEMS) as integer
#endif

'Variables simples enemigos'
dim _en_x, _en_x1, _en_x2 as integer
dim _en_y, _en_y1, _en_y2 as integer
dim _en_mx, _en_my as byte
dim _en_t, _en_facing, _en_sprnum as ubyte
dim _en_life as byte
dim _en_vy as integer
dim enem_status as ubyte
dim colision_ok as ubyte

'Disparos enemigos (enemyBullets)'
dim x_enemyBullet (3)  as integer
dim y_enemyBullet (3)  as integer
dim vx_enemyBullet (3)  as integer
dim vy_enemyBullet (3)  as integer
dim estado_enemyBullet (3)  as ubyte

'enemyBullets animation secuences'
dim sprite_enemyBullet(1) as ubyte => {ENEM_BULLET_ANIM} '2 frames'
dim frame_enemyBullet as ubyte

'Arrays animaciones enemigos'
dim enem_animation (MAX_ENEMS, MAX_FRAMES_ENEMIES) as ubyte 'array para guardar la animacion de cada enemigo

'Estados enemigos
#define ENEM_NORMAL 0
#define ENEM_DAMAGED 10
#define ENEM_DYING 11
#define ENEM_DEAD 12
#define ENEM_NO_RESPAWN 99

'************************************************'
'Variables MAPAS
dim level_completed as ubyte
dim mapbuffer as uinteger
dim p, tilenum  as uinteger 
dim x, y  as ubyte
dim tt as uinteger
dim current_level, level_number, teleport  as ubyte
dim ancho_mapa, alto_mapa as uinteger
dim level_floor, first_row, changing_floor as ubyte 

'************************************************'
'Variables Tiles animados'
#ifdef TILANIMS
dim tiles_animados_x (0 to MAX_TILANIMS) as ubyte
dim tiles_animados_y (0 to MAX_TILANIMS) as ubyte
dim tiles_animados_t (0 to MAX_TILANIMS) as ubyte
dim tiles_frame, tiles_subframe, tilanim_num as ubyte
dim tilanims_first as ubyte
#endif     
dim resto_scrollx as integer

'************************************************'
'Variables scroll'
dim x_scroll, x_scroll_temp, posicion_x_inicial as integer
dim x_scroll_6, x_scroll_temp_6 as long
dim columna_actual, columna_anterior, addx as ubyte
dim columna_inicial, colocando_scroll as byte
dim x_fin_mapa as uinteger

'************************************************'
'Variables Timer
#ifdef TIMER_ENABLE
dim timer_on as ubyte
dim timer_t as uinteger
dim timer_frames as ubyte
dim timer_count as ubyte
dim timer_zero as ubyte
#endif                          


#define PLATFORM_TYPE       49  ' the number will be the type for mobile platforms
#define OBJECT_TYPE         50  ' the number will be the type for collectible objects

'NUMERO DEL PRIMER SPRITE EN MEMORIA DE SPRITES
#define PLAYER_FIRST_SP_VRAM  0
#define PLAYER_BULLET_FIRST_SP_VRAM  4
#define ENEMIES_FIRST_SP_VRAM  20
#define ENEMBULLET_FIRST_SP_VRAM  10


'DEFINICION DE BUFFERS EN ZONA DE PANTALLA ULA'
'PALETTE BUFFER
#define PALETTE_BUFFER 18432 'SOLO SE USARíA PARA CARGAR UNA PALETA CUSTOM, luego se borra'
'ENEMIES BUFFER
#define ENEMIES_BUFFER  18432
#define ENEMIES_DATA  ENEMIES_BUFFER+1
'MAP BUFFER
#define DIMENSIONES_MAPA $C000 'En los bancos 90,91. Paginamos para acceder.
#define MAP_BUFFER DIMENSIONES_MAPA+2 '2 BYTES Después de DIMENSIONES_MAPA, esos dos bytes guardan el ancho y alto del mapa en tiles' 

'Load the Charset (font)
fichero = "bin/font.bin"
LoadSD(fichero,@font_buffer+8,504,8)
direccion = @font_buffer
poke uInteger 23606, direccion - 256


dim cadena1, cadena2, cadena3 as string   
dim idioma as ubyte
'Calculos para FPS'
dim v, VarFrec, contador_frecuencia60 as ubyte



#define SCREEN_Y_OFFSET (HUD_HEIGHT+2)
#define SCREENS_H (12-HUD_HEIGHT)


dim behs(128) as ubyte AT $5b00

