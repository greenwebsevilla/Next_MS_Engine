'This is the GAME LOOP, it ends when var playing is 0'
    
'Iniciar variables del juego'
game_init ()

#include "../my/custom_code/game_cc/before_game_loop.bas"



do 'Game loop' 
    

#ifdef DEBUGGING 'can change level pressing Z/X'

    if MultiKeys(KEYX) then level_number = level_number +1
    if MultiKeys(KEYZ) then level_number = level_number -1

#endif

    if press_pause
        PAPER 0: INK 6
        print at 7,13;"       "
        print at 8,13;" PAUSE "
        print at 9,13;"       "
        WaitForNoKey()
        do
            control_vars()
            if press_pause then EXIT DO
        loop
        WaitForNoKey()
        DELETE_TEXT_AREA
    end if

    if level_completed 

        stage_clear()
        level_number = level_number + 1
        level_completed = 0

        'EXIT LOOP IF WE WIN THE GAME'
        'SALIR DEL BUCLE SI GANAMOS EL JUEGO'
        if level_number = MAX_LEVELS 'si se pasa el ultimo nivel de alguna forma, se termina el juego'
            success = 1: playing = 0
            EXIT DO
        end if

    end if

    if current_level <> level_number
     
        ClipLayer2(0,0,0,0)
        ShowLayer2(0)

        ' DisableSFX

        #include "../engine/level_screen.bas"

        #include "../my/custom_code/game_cc/before_entering_map.bas" 
        SHOW_SPRITES 'Activamos el área de juego para los sprites'

        current_level = level_number
         
        if level_music(level_number) <> track AND NOT changing_floor
            track = level_music(level_number)
        end if
        
        ' EnableSFX
#ifdef TILANIMS
        reset_tilanims ()
#endif
        draw_scr() 'Draws the screen'
        coloca_scroll()
        player_locate()

        ClipLayer2(17,143,SCREEN_Y_OFFSET*16,SCREEN_Y_OFFSET*16+SCREENS_H*16-1)
        ShowLayer2(1)
        
    end if


    if track <> old_track 
        old_track = track
        play_music () 
        EnableMusic
    end if

#ifdef TIMER_ENABLE
    if player_status < DYING_ST then run_timer() 'Hace las cosas del temporizador (tiempo) siempre que no esté muriendo'
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
   
    check_death() 'Comprueba si ha terminado la animación de morir'

    #include "../my/custom_code/game_cc/ingame_routines.bas"
    
WaitRetrace(1) 'Espera al siguiente frame o interrupcion'
     UpdatePlayer()
    if haz_scroll then do_x_scroll()
    haz_scroll = 0
    'Saltar un frame de cada 6 en modo 60HZ para mantener la velocidad original del juego.'
    if contador_frecuencia60 = 6 AND VarFrec = 60 : WaitRetrace(1): end if

    fin_playing_loop:
loop until playing = 0

    PAPER 3: BRIGHT 1
    CLS

    if success = 1 
        fin()
    else
    
        game_over ()
    end if