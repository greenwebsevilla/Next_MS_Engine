'Definición del lenguaje para el código custom'
'Definition of the language for custom code'

'Generales'
#define MODE256 NextReg($70,0)
#define MODE320 NextReg($70,$10)
#define CROP_ULA ClipULA(0,255,0,63)
#define FULL_ULA ClipULA(0,255,0,191)
#define HIDE_SPRITES ClipSprite(0,0,0,0)
#define SHOW_SPRITES ClipSprite(16,143,SCREEN_Y_OFFSET*16,SCREEN_Y_OFFSET*16+SCREENS_H*16)
#define HALF_LIFE half_life
#define QUARTER_LIFE half_life2



'Niveles'
#define LEVEL_NUM level_number
#define GOTOMAP go_to_another_map
#define STAGE_CLEAR level_completed = 1
#define END_GAME success = 1:playing = 0
#define RESTART_LEVEL current_level=255:track=255

'Player'
#define PLAYER_X cast(uinteger,gpx)+x_scroll
#define PLAYER_Y gpy
#define PLAYER_VX p_vx
#define PLAYER_VY p_vy
#define PLAYER_X_IN_TILES get_player_xtiles()
#define PLAYER_Y_IN_TILES get_player_ytiles()
#define PLAYER_ENERGY player_energy
#define PLAYER_LIVES lives
#define PLAYER_IN_ZONE player_in_zone
#define PLAYER_TOUCH_TILE_NUM player_touch_tile_num()
#define PLAYER_TOUCH_TILE_TYPE player_touch_tile_type()
#define SCORE_ADD add_points
#define REFILL_ENERGY player_energy=INIT_ENERGY
#define PLAYER_DIE player_energy=1:player_damaged = 1
#define SET_PLAYER_ANIMATION set_player_animation
#define PLAYER_STATUS player_status
#define PLAYER_EXTRA_TOP_BB ajuste_ccol_y
'Estados del player para diferentes animaciones'
#define PLAYER_JUMPING player_jumping
#define PLAYER_WALKING p_vx
#define PLAYER_GOING_LEFT p_vx<0
#define PLAYER_GOING_RIGHT p_vx>0
#define PLAYER_DYING player_status = DYING_ST
#define PLAYER_GOING_UP p_vy<0
#define PLAYER_GOING_DOWN p_vy>0
#define PLAYER_ON_LADDER ladder_on
#define PLAYER_FLICKERING player_status = FLICKERING_ST


'Utilidades / Loop'
#define TEXT(x,y,color,text) PRINT AT y,x;INK color;PAPER 0;text
#define MUSIC track
#define SOUND PlaySFX
#define STOP_MUSIC DisableMusic
#define PLAY_MUSIC EnableMusic
#define RESET_MUSIC NewMusic(31,0000)
#define PAUSA pausa
#define PRINT_TILE pintar_tile          '(x_tile as ubyte, y_tile as ubyte, num_tile as ubyte)'
#define UPDATE_TILE actualizar_tile     '(x_tile as ubyte, y_tile as ubyte, num_tile as ubyte)'
#define DELETE_HUD delete_hud(0)
#define DELETE_TEXT_AREA delete_hud(HUD_HEIGHT*2)
#define PRINT_HUD print_hud()
' #define NEW_SPRITE new_sprite
'  NEW_SPRITE (61, 50, PLAYER_X_IN_TILES, PLAYER_Y_IN_TILES-1, 1) 'Creamos un objeto a la izquierda del jugador: sprite 61, tipo 50
#define TIMER_ON timer_on = 1
#define TIMER_OFF timer_on = 0
#define TIME timer_t
#define RESTART_TIME timer_t=TIMER_INITIAL

'Enemigos'
#define ENEMY_TYPE _en_t
#define ENEMY_STATUS enem_status
#define ENEMY_VX _en_mx
#define ENEMY_VY _en_my
#define NO_KILL no_kill=1
#define KILL_SPRITE enem_status=ENEM_DEAD
#define KILL_SPRITE_NO_RESPAWN enem_status=ENEM_NO_RESPAWN
#define ENEMY_ANIMATION set_enem_animation
#define ENEMY_COUNTER enem_counter2(enit)
#define ENEMY_VAR1 enem_var1(enit)
#define ENEMY_VAR2 enem_var2(enit)
#define ENEMY_VAR3 enem_var3(enit)
#define ENEMY_VAR4 enem_var4(enit)
#define ENEMY_VAR5 enem_var5(enit)
#define ENEMY_SHOOT shoot_enemyBullet
#define MOVE_ENEMY mover_enemigo()
#define CHECK_ENEMY_LIMITS comprobar_limites()
#define CHECK_ENEMY_TILES colision_enem_tiles()
#define MOVE_FANTY mover_fantasma()
#define ENEMY_ADD_GRAVITY aplicar_gravedad_enem() 
#define ENEMY_IS_TOUCHING_GROUND pisa_suelo_enem() 
#define ENEMY_BOUNCE enem_rebote_vertical()
#define MOVE_OSCILLATOR mover_sube_baja()
#define ENEMY_EXTRA_TOP_BB enem_ajuste_ccol_y

'Acceso a otras variables'
#define OBJECTS_NUMBER num_objects
#define SCORE score
#define FIRST_TILANIM tilanims_first









