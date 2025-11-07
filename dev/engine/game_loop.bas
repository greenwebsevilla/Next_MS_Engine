'This is the GAME LOOP, it ends when var playing is 0'
    
'Iniciar variables del juego'
game_init ()

#include "../my/custom_code/game_cc/before_game_loop.bas"

CROP_ULA ' recortamos la ULA a solo la parte superior para el marcador
' ClipLayer2(17,144,SCREEN_Y_OFFSET*16,SCREEN_Y_OFFSET*16+SCREENS_H*16) 'Define game area' 

do 'Game loop' 
    WaitRetrace(1) 'Espera al siguiente frame o interrupcion'
    
    'Saltar un frame de cada 6 en modo 60HZ para mantener la velocidad original del juego.'
    if contador_frecuencia60 = 6 AND VarFrec = 60 : WaitRetrace(1): end if

#ifdef DEBUGGING 'can change level pressing Z/X'

    if MultiKeys(KEYX) then level_number = level_number +1
    if MultiKeys(KEYZ) then level_number = level_number -1

#endif

    if press_pause
        print at 2,13;ink 6;"PAUSE"
        WaitForNoKey()
        do
            control_vars()
            if press_pause then EXIT DO
        loop
        WaitForNoKey()
        print at 2,13;ink 7;"     "
    end if

    if level_completed 

        stage_clear()
        level_number = level_number + 1
        level_completed = 0

        'EXIT LOOP IF WE WIN THE GAME'
        'SALIR DEL BUCLE SI GANAMOS EL JUEGO'
        if level_number = MAX_LEVELS 'si se pasa el ultimo nivel de alguna forma, se termina el juego'
            success = 1: playing = 0
            GOTO fin_playing_loop
        end if

    end if

    if current_level <> level_number
        
        #include "../engine/level_screen.bas"
        #include "../my/custom_code/game_cc/before_entering_map.bas" 
        SHOW_SPRITES 'Activamos el área de juego para los sprites'
        CLS320()
        ClipLayer2(0,0,0,0)
        ShowLayer2(0)
        draw_scr() 'Draws the screen'
        coloca_scroll()
        player_locate()
        

        ClipLayer2(17,144,SCREEN_Y_OFFSET*16,SCREEN_Y_OFFSET*16+SCREENS_H*16)
        ShowLayer2(1)
        
        current_level = level_number
        
        if level_music(level_number) <> track
            track = level_music(level_number) : play_music()
        end if

        EnableSFX

    end if

#ifdef TIMER_ENABLE
    if player_status < EST_MURIENDO then run_timer() 'Hace las cosas del temporizador (tiempo) siempre que no esté muriendo'
#endif

    '1/2 TIEMPO Y 1/4 de TIEMPO'
    half_life =  NOT half_life
    if half_life
        half_life2 = NOT half_life2
    end if

    'Animacion de tiles'
#ifdef TILANIMS
    AnimateTiles()
#endif

    'Funciones enemigos'
    EnemiesMove()

    'Funciones proyectiles'
#ifdef PLAYER_CAN_FIRE
    BulletsPlayerMove()
#endif
#ifdef ENEMY_BULLETS
    EnemyBulletsMove()
#endif

    'Funciones player'
    PlayerMove() 
    PlayerAnimation()
    UpdatePlayer()
    check_death() 'Comprueba si ha terminado la animación de morir'

    #include "../my/custom_code/game_cc/ingame_routines.bas"
    

    fin_playing_loop:
loop until playing = 0

    PAPER 3: BRIGHT 1
    CLS

    if success = 1 
        fin()
    else
    
        game_over ()
    end if