/'
CONFIGURACION DEL MOTOR, MK1 CHURRERA STYLE
- Se pueden cambiar los valores de los #define para variar parámetros como la velocidad del jugador,
pantalla de inicio, vidas, que enemigos activar, posicionar elementos del hud, etc.
- Comenta los defines que no se vayan a usar si por ejemplo tu juego no salta, comenta #define PLAYER_JUMPS
'/

' ============================================================================
' General configuration
' ============================================================================
#define ENABLE_SOUND 'Comentar para desactivar el sonido'
#define FIX_MUSIC_60HZ 'Makes the music sound at the same speed in 50/60 hz (needs to modify Nextlib.bas)

' #define DEBUGGING     'If defined you can go to previous/next map by pressing Z/X'

' #define CUSTOM_PALETTE 'Activar para usar paletas personalizadas. Nombra los ficheros como sprites.pal / tiles.pal en data/pal/'
#define SPRITES_TRANSPARENT_COLOR 227
#define GLOBAL_TRANSPARENT_COLOR 231

' Menu
#define REDEFINE_TEXT_X 2   'Coords where to print Redefine keys dialog'
#define REDEFINE_TEXT_Y 12

' CAMERA SETTINGS: define los límites a partir de los cuales la cámara sigue al jugador haciendo un scroll
' Valores en píxeles: de 8 a 296 para horizontal y de 8 a 168 para vertical)'
#define CAM_RIGHT_LIMIT     152
#define CAM_LEFT_LIMIT      152
#define CAM_DOWN_LIMIT      100
#define CAM_UP_LIMIT        80


' ============================================================================
' LEVELS CONFIGURATION (here, we consider each maps as a levels)
' ============================================================================
#define FIRST_LEVEL			    0		        ' Initial level
#define MAX_LEVELS				4		        ' # of levels in total (if you win the last level, the game ends)
#define LEVELS_TILESETS         0,0,0,0	        ' Tilesets (spr) used in each level, separated by commas //Eg. Value 0 will use files: "tiles_1.spr +  beh1.bin"
#define LEVELS_ENEMIES          0,0,0,1	        ' Enemies spriteset (spr) used in each level, separated by commas //Eg. Value 0 will use files: "enemies_1.spr"
#define LEVELS_MUSICS           1,1,2,4	        ' # music used in each level, separated by commas //Eg. Value 2 will use the file "2.pt3"
#define MAX_ENEMS               40              ' Max enemies+objects+platforms per level (one level is a map)'

' ============================================================================
' TILES ANIMADOS (ANIMATED TILES)'
' ============================================================================
#define TILANIMS                                ' If defined, animations in tiles is active'
#define MAX_TILANIMS               30           ' Max number of animated tiles per map (Don't use too many tiles)'
#define MAX_FRAMES_TILANIM          4           ' Number of tiles that the animations use'
#define TILANIM_FREQUENCY           8           ' Number of frames (time) to print the next tile of the animation'
#define LEVELS_FIRST_TILANIM      124	        ' First tile which is animated (to change it for a specific level, use FIRST_TILANIM = N in file "before_entering_map.bas")

' ============================================================================
' TIMER CONFIGURATION
' ============================================================================
#define TIMER_ENABLE					' Enable timer
#define TIMER_INITIAL 			300		' Initial value.
#define TIMER_LAPSE				50		' # of frames between decrements
#define TIMER_START						' If defined, start timer from the beginning
#define TIMER_AUTO_RESET				' If defined, timer resets after "time up"

' ============================================================================
' MISCELANEA
' ============================================================================
#define EXTRA_LIFE_SCORE    3000    'Win extra life each N points'
#define SPIKES_KILL_VERTICAL_ONLY   ' If defined, tile type 1 only damages if touched on top or bottom, horizontally is a solid block

' ============================================================================
' PLAYER CONFIGURATION
' ============================================================================
' #define PLAYER_SPRITE_16X32                 ' El sprite del player usará el tamaño de 16x32 píxeles en lugar de 16x16
#define MAX_FRAMES_PLAYER   4               ' Numero de sprites del player por animación'
#define PLAYER_FLICKERS                     ' If defined, player flickers after damaged for the number of frames defined in FLICKERING_TIME
#define FLICKERING_TIME     100             ' number of frames flickering

' Player data
#define INIT_ENERGY 				3		' Max and starting energy gauge (put 1 for touched = death)
#define INIT_LIVES				    3		' Max and starting lives gauge. (put 1 for just one life and use energy instead)

' Fire
#define PLAYER_CAN_FIRE			     		' If defined, player can shoot
#define BULLET_SPRITE				63		' # of sprite for the bullets in spriteset
#define MAX_BULLETS				    3		' # of sprite for the bullets in spriteset

' Vertical movement.
#define PLAYER_GRAVITY				16		' If defined, apply gravity acceleration (value increases fall every frame until reach PLAYER_MAX_VY_FALLING) 
#define PLAYER_MAX_VY_FALLING		256 	' Max falling speed 

#define PLAYER_JUMPS                        ' If defined, player can jump
#define JUMP_POWER		            255 	' Jump initial Y speed 
#define DAMAGE_BOUNCE_POWER    		200 	' If defined, player bounces when damaged. Value is Y speed 

' #define ENABLE_UPDOWN_MOVE                ' If defined, player can move up and down (for top view games, remember to disable gravity and jump)

#define ENABLE_LADDERS                      ' If defined, tile type 2 are ladders.
#define LADDER_VY                   64      ' Y speed when moving up/down on ladders.


' Horizontal (side view) or general (top view) movement.
#define PLAYER_MAX_VX				96  	' Max X speed  (96/64 = 1.5 pixels/frame)
#define INERTIA                             ' Comment this out to disable inertia'
#define PLAYER_AX					8		' Acceleration (24/64 = 0,375 pixels/frame^2)
#define PLAYER_RX					8		' Friction (32/64 = 0,5 pixels/frame^2)

' Bounding box size
' Collision with tiles, use 0 for normal 16x16 bounding box
#define BOUNDING_BOX_LEFT_OFFSET	   -1	' in pixels: negative to reduce the box, positive to increase
#define BOUNDING_BOX_RIGHT_OFFSET	   -1	' in pixels: negative to reduce the box, positive to increase
#define BOUNDING_BOX_UP_OFFSET	       -3	' in pixels: negative to reduce the box, positive to increase
#define BOUNDING_BOX_DOWN_OFFSET	   0	' in pixels: negative to reduce the box, positive to increase (If use gravity, let it 0)

' Collision with enemies and shots'
#define SMALL_COLLISION_ENEM 				' reduced bounding box for collision with enemies
' #define SMALL_COLLISION_SHOTS				' reduced bounding box for collision with enemy bullets
#define STOMP_ENEMIES                       ' Kill enemies by stomping on them'

' ============================================================================
' ENEMIES, PLATFORMS & OBJECTS CONFIGURATION
' ============================================================================
' #define ENEMY_SPRITES_16X32         ' Los Sprites enemigos usarán el tamaño de 16x32 píxeles en lugar de 16x16
#define MAX_SPRITES_ON_SCREEN  10   ' Numero máximo de sprites en pantalla (a la vez), contando enemigos, objetos y plataformas móviles'

#define MAX_FRAMES_ENEMIES  4   ' Numero máximo de sprites de animacion de los enemigos'
#define DEFAULT_ENEM_FPS    4   ' Numero de frames que pasan para cambiar el sprite de animacion de los enemigos'

#define RESPAWN_ENEMIES         ' If defined, enemies will respawn in the the place they died, when it is out of the visible area.'
#define ENEMY_DEATH_BOUNCE  24  ' If defined, when enemies die, they bounce, and the number is the vertical speed (VY) of the bounce (default is 24)'
#define WALLS_STOP_ENEMIES      ' If defined, enemies change direction when colliding with a solid tile.

#define ENABLE_PLATFORMS        ' IF defined, enemy type 49 will be a mobile platform
#define ENABLE_OBJECTS          ' IF defined, enemy type 50 will be a collectible object
#define OBJECTS_GET_SOUND   8   ' # of sound played when you get a collectible object

' Fantys
#define FANTYS                  ' Activate the pursuer enemy type (type 2)'
#define FANTYS_MAX_VEL 32 
#define FANTYS_ACELERACION 1


' Jumpers
#define JUMPERS                 ' Activate the jumping enemy type (type 3)'
#define ENEM_JUMP_POWER     48  ' Jump initial vertical speed (jump power) for type 3 

' Oscillators
#define OSCILLATORS              ' Oscillating enemy (type 4)'

#define ENEMY_GRAVITY       2    ' For jumpers, oscillators, or enemies that can fall
#define ENEMY_MAX_VY        96   ' For jumpers, oscillators, or enemies that can fall  

' Enemy fire'
#define ENEMY_BULLETS           ' If defined, enemies can fire
#define MAX_ENEMY_BULLETS   3   ' max # of enemy bullets on screen
#define ENEM_BULLET_ANIM 62,63  ' Sprites animation for enemy bullets, separated by commas (2 frames)

' ============================================================================
' HUD CONFIGURATION
' ============================================================================
#define HUD_HEIGHT 1 'how many ROWS OF TILES (16px each): Recommended 1 or 2 depends on your needs, 0 if you don't use hud. 
' IMPORTANT: There is not vertical scroll at this point, so make your maps height according to the hud used: Game area height in tiles = 18-Hud height
#define SHOW_SCORE                      ' If defined, print score points on hud
#define SCORE_X                 26      ' Score coord X on hud
#define SCORE_Y                 1       ' Score coord Y on hud
#define SHOW_ENERGYBAR                  ' If defined, print energy bar on hud
#define ENERGYBAR_X             0       ' Energy bar coord X on hud
#define ENERGYBAR_Y             1       ' Energy bar coord Y on hud
#define SHOW_LIVES                      ' If defined, print # of lives on hud
#define LIVES_X                 12       ' Lives coord X on hud
#define LIVES_Y                 1      ' Lives coord Y on hud
#define SHOW_TIMER                      ' If defined, print timer on hud
#define TIMER_X                 20      ' Timer coord X on hud
#define TIMER_Y                 1       ' Timer coord Y on hud
#define SHOW_OBJECTS                    ' If defined, print # of captured objects on hud
#define OBJECTS_X               6       ' Timer coord X on hud
#define OBJECTS_Y               1       ' Timer coord Y on hud


' ============================================================================
' MUSIC & SOUND CONFIGURATION
' ============================================================================

'Default songs'
#define MUSIC_TITLE 0       'Title/menu screen'
#define MUSIC_GAMEOVER 12
#define MUSIC_ENDING 9
#define MUSIC_STAGE_CLEAR 11

'Default fx sounds'
#define SOUND_JUMP 5
#define SOUND_PLAYER_DAMAGED 4
#define SOUND_PLAYER_SHOOT 3
#define SOUND_START_GAME 6
#define SOUND_LANGUAGE_SELECTED 11
#define SOUND_EXTRA_LIFE 6
#define SOUND_KEY_DEFINED 13
#define SOUND_ENEMY_DAMAGED 7
#define SOUND_ENEMY_DIE 9
#define SOUND_ENEMY_STOMPED 12


' ============================================================================
' CONTROL CONFIGURATION
' ============================================================================

#define KEY_TO_LEFT     PRESS_LEFT
#define KEY_TO_RIGHT    PRESS_RIGHT
#define KEY_TO_UP       PRESS_UP
#define KEY_TO_DOWN     PRESS_DOWN

#define KEY_TO_FIRE     PRESS_FIRE
#define KEY_TO_JUMP     PRESS_FIRE2
#define KEY_TO_PAUSE    PRESS_PAUSE

