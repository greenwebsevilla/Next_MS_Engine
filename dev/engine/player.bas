sub player_locate()
    p_subframe = 0
    tocado = 0
    
    p_frame = 0 : p_subframe = 0

    if x_scroll > -32 AND x_scroll < x_fin_mapa 
        gpx = CAM_RIGHT_LIMIT
    else
        gpx = (cast(uinteger, player_x_ini) << 4) - x_scroll
    end if
    gpy = cast(uinteger, player_y_ini) << 4

    p_x = gpx << 6
    p_y = gpy << 6
   
end sub

sub game_init()
    success = 0: half_life = 0
	level = 0
    level_completed = 0
    level_number = FIRST_LEVEL 
    current_level = 255
    player_energy = INIT_ENERGY
    lives = INIT_LIVES
    playing = 1
    p_vx = 0: p_vy = 0
    p_facing = 0
    PLAYER_EXTRA_TOP_BB = 0 'por defecto por se amplía la caja de colisión por arriba'
    p_estado = 0 : p_ct_estado = 0
    num_objects = 0 : player_damaged = 0


#ifdef TIMER_ENABLE
    timer_t = TIMER_INITIAL
    timer_count = 0 : timer_zero = 0
#ifdef TIMER_LAPSE
    timer_frames = TIMER_LAPSE
#endif
#ifdef TIMER_START
    timer_on = 1
#else
    timer_on = 0
#endif
#endif

    score = 0
	next_extra_life = EXTRA_LIFE_SCORE

end sub

sub go_to_another_map(level_num as ubyte, x_inicial as ubyte == 255, y_inicial as ubyte = 255)
    level_number = level_num
    if y_inicial < 255 'Si no indicamos coordenadas x e y, solo vamos al mapa nuevo y apareceremos donde esté definido en el mapa
        player_x_ini = x_inicial
        player_y_ini = y_inicial
        teleport = 1 'ignorará la posición del player definida en el mapa'
    end if
end sub

sub PlayerMove()

    if p_estado < EST_MURIENDO 
        control_vars () 'Read the control'
    end if

    'Gravedad'
#ifdef PLAYER_GRAVITY
    p_vy = p_vy + PLAYER_GRAVITY
    if p_vy > PLAYER_MAX_VY_FALLING then p_vy = PLAYER_MAX_VY_FALLING
#endif

    ' Control Vertical

#ifdef PLAYER_JUMPS
#ifdef DAMAGE_BOUNCE_POWER
        if (press_up OR brinco) AND p_saltando = 0 AND salto_pulsado = 0
#else
        if press_up AND p_saltando = 0 AND salto_pulsado = 0
#endif
    
            p_vy = - JUMP_POWER
            p_saltando = 1
            salto_pulsado = 1

            possee = 0
            PlaySFX(5)
        end if
#endif

#ifndef ENABLE_UPDOWN_MOVE
    #ifdef DAMAGE_BOUNCE_POWER
        if brinco then 
            p_vy = - DAMAGE_BOUNCE_POWER
            brinco = 0
        end if
    #endif

#else
    'UP & DOWN MOVEMENT
    if press_up

        '    p_facing = FACING_LEFT
#ifdef INERTIA
            p_vy = p_vy - PLAYER_AX
            if p_vy < -PLAYER_MAX_VX then p_vy = -PLAYER_MAX_VX
#else
            p_vy = -PLAYER_MAX_VX
#endif
        else

            if press_down
                ' p_facing = FACING_RIGHT
#ifdef INERTIA
                p_vy = p_vy + PLAYER_AX
                if p_vy > PLAYER_MAX_VX then p_vy = PLAYER_MAX_VX
#else
                p_vy = PLAYER_MAX_VX
#endif
            else
#ifdef INERTIA  
                if p_vy < 0 then p_vy = p_vy + PLAYER_RX
                if p_vy > 0 then p_vy = p_vy - PLAYER_RX
#else
                p_vy = 0
#endif
            end if

        end if

#endif

    'Colisiones verticales
    player_calc_bounding_box()
    
    if p_vy > 0
        cx1 = ptx1+1 : cy1 = pty2+1
        cx2 = ptx2-1 : cy2 = cy1 
        cm_two_points()
        if ct1 bAND 12 OR ct2 bAND 12 OR possee
            cx1 = ptx1 : cy1 = pty2-4
            cx2 = ptx2 : cy2 = cy1
            cm_two_points()
            if ct1 <> 4 AND ct2 <> 4 'Nos aseguramos que esté en la parte superior de la plataforma, y no por debajo'
                p_vy = 0
#ifdef PLAYER_JUMPS
                p_saltando = 0: brinco = 0
                if press_up = 0 then salto_pulsado = 0
#endif
                if possee = 0
                    gpy = gpy bAND 0xfff0
                    p_y = gpy << 6 
                end if
            end if
        else 
#ifdef PLAYER_JUMPS
            p_saltando = 1: salto_pulsado = 1
#endif
            cx1 = ptx1+4 
            cx2 = ptx2-4  
            cm_two_points()
            if ct1 = 1 OR ct2 = 1
                if p_estado < EST_PARP 
                player_damaged = 1
                PlaySFX(4)
                end if
                if p_estado < EST_MURIENDO
                    brinco = 1
                end if
            end if
       
        end if
    end if

    if p_vy < 0

        cx1 = ptx1+1 : cy1 = pty1-1
        cx2 = ptx2-1 : cy2 = pty1-1
#ifdef PLAYER_SPRITE_16X32
        cy1 = cy1 - PLAYER_EXTRA_TOP_BB
        cy2 = cy1
#endif
        cm_two_points()
        if ct1 = 8 OR ct2 = 8
            p_vy = 0
        end if
    end if 

   

	p_y = p_y + p_vy

    if p_y < -1024 then p_y = -1024
    if p_y > 10240 
         p_y = 10240
    end if
	gpy = p_y >> 6

  
    

    ' CONTROL HORIZONTAL

        if press_left 

            p_facing = FACING_LEFT
#ifdef INERTIA
            p_vx = p_vx - PLAYER_AX
            if p_vx < -PLAYER_MAX_VX then p_vx = -PLAYER_MAX_VX
#else
            p_vx = -PLAYER_MAX_VX
#endif
        else

            if press_right 
                p_facing = FACING_RIGHT
#ifdef INERTIA
                p_vx = p_vx + PLAYER_AX
                if p_vx > PLAYER_MAX_VX then p_vx = PLAYER_MAX_VX
#else
                p_vx = PLAYER_MAX_VX
#endif
            else
#ifdef INERTIA  
                if p_vx < 0 then p_vx = p_vx + PLAYER_RX
                if p_vx > 0 then p_vx = p_vx - PLAYER_RX
#else
                p_vx = 0
#endif
            end if

        end if


    ' if disparando AND p_saltando = 0 then p_vx = 0

    total_vx = p_vx + plataforma_vx
  
    ' Colisiones horizontales'
    if p_estado < EST_MURIENDO

        player_calc_bounding_box()

        if total_vx > 0
       
                cx1 = ptx2+1 : cy1 = pty1 
                cx2 = ptx2+1 : cy2 = pty2 
                cm_two_points()
                if ct1 bAND 9 OR ct2 bAND 9
                    ' if p_x < 17216 'Este IF es para que no detecte colisiones al salir del mapa por la derecha'
                        total_vx = 0 
                    ' endif
                end if
#ifdef PLAYER_SPRITE_16X32 
                cx1 = ptx2+1
                cy1 = pty1 - PLAYER_EXTRA_TOP_BB
                cm_two_points()
                if ct1 bAND 9
                        total_vx = 0 
                end if
#endif
                p_x = p_x + total_vx
            if p_x > CAM_RIGHT_LIMIT*64 
                if ScrollToRight()
                p_x = CAM_RIGHT_LIMIT*64 
                end if
            endif
        end if


        if total_vx < 0
        
                cx1 = ptx1-1 : cy1 = pty1 
                cx2 = ptx1-1 : cy2 = pty2 
                cm_two_points()
                if ct1 bAND 9 OR ct2 bAND 9
                    total_vx = 0
                end if
#ifdef PLAYER_SPRITE_16X32 
                cx1 = ptx1-1
                cy1 = pty1 - PLAYER_EXTRA_TOP_BB
                cm_two_points()
                if ct1 bAND 9
                        total_vx = 0 
                end if
#endif
                p_x = p_x + total_vx
        
            if p_x < CAM_LEFT_LIMIT*64 
                if ScrollToLeft()
                    p_x = CAM_LEFT_LIMIT*64
                end if
            end if

        end if 

        #ifdef PLAYER_FLICKERS
            ' // Flickering
            if p_estado = EST_PARP
                    p_ct_estado = p_ct_estado - 1
                    if p_ct_estado = 0
                        p_estado = EST_NORMAL
                    end if
            end if
        #endif

        ' El jugador recibe daño'
        if player_damaged 

            player_energy = player_energy - 1
            print_energy()
            if player_energy > 0
                player_kill()
                #include "../my/custom_code/player_cc/player_damaged.bas"
            else
                #include "../my/custom_code/player_cc/player_dies.bas"
                player_damaged = 0
                p_estado = EST_MURIENDO
                p_counter = 100
                lives = lives - 1
                print_number_of_lives()
            end if
        
        end if


    
    end if ' if p_estado < EST_MURIENDO

    if p_x < 2048 then p_x = 2048 'límite izquierdo pantalla'

    if p_x > 17728 'límite derecho pantalla'
        p_x = 17728 
    end if

    gpx = p_x >> 6  

#ifdef PLAYER_CAN_FIRE
    if press_fire
        if disparando = 0 AND disparado = 0

            disparando = 4 
            disparado = 1
        
            shoot()
            PlaySFX(3)

        end if
    else
        disparado = 0
    end if

    if disparando
        disparando = disparando - 1
    end if
#endif

end sub



sub PlayerAnimation ()

#include "../my/custom_code/player_cc/animations.bas"

' Animación del player
 
    p_subframe = p_subframe + 1
    if p_subframe >= fps_animacion 
        p_subframe = 0
        p_frame = p_frame + 1
        
        if p_frame >= MAX_FRAMES_PLAYER
            p_frame = 0
        end if
    end if
    
' Imprimir el player
'Leemos en el array player_frames que numero de sprite hay que copiar desde el banco de sprites (32,33)
' al sprite del jugador y lo guardamos en spnum, que será usada por UpdatePlayer()
    spnum = player_frames(p_frame) 

end sub

sub UpdatePlayer()

    asm : nextreg $50,32 : nextreg $51,33 : end asm  'paginamos a los bancos 32 y 33'

#ifdef PLAYER_SPRITE_16X32
    direccion = $0000+(256*spnum - (256*16))
    Test_SetSprites(1,direccion,PLAYER_FIRST_SP_VRAM+1) ' cargamos el frame que hay en direccion en el sprite numero 1'
#endif
    direccion = $0000+(256*spnum)
    Test_SetSprites(1,direccion,PLAYER_FIRST_SP_VRAM) ' cargamos el frame que hay en direccion en el sprite numero 0'


    asm : nextreg $50,$ff : nextreg $51,$ff : end asm   	' paginamos a los bancos por defecto

    'Pintamos los sprites nuevos'
    _x1 = gpx
    _y = gpy + (SCREEN_Y_OFFSET<<4)

    if p_estado = EST_PARP AND half_life = 0

        RemoveSprite(PLAYER_FIRST_SP_VRAM,0)
#ifdef PLAYER_SPRITE_16X32
        RemoveSprite(PLAYER_FIRST_SP_VRAM+1,0)
#endif

    else

#ifdef PLAYER_SPRITE_16X32
        UpdateSprite(_x1, _y-16, PLAYER_FIRST_SP_VRAM+1, PLAYER_FIRST_SP_VRAM+1, p_facing, 0) 'Extra Sprite Player for 32 pixels height
#endif
        UpdateSprite(_x1, _y, PLAYER_FIRST_SP_VRAM, PLAYER_FIRST_SP_VRAM, p_facing, 0) 'Sprite Player

    end if

end sub 

sub player_calc_bounding_box()

	' definimos los puntos de la caja de colision del player
	ptx1 = gpx - (BOUNDING_BOX_LEFT_OFFSET)  + x_scroll
	pty1 = gpy - (BOUNDING_BOX_UP_OFFSET)

	ptx2 = gpx + x_scroll + 15 +(BOUNDING_BOX_RIGHT_OFFSET)
	pty2 = gpy + 15 +(BOUNDING_BOX_DOWN_OFFSET)

end sub



sub player_kill()
#ifdef SHOW_ENERGYBAR
    print_energy()   
#endif
    player_damaged = 0
    'pequeño salto'
    brinco = 1

#ifdef PLAYER_FLICKERS
    p_estado = EST_PARP
    p_ct_estado = FLICKERING_TIME
#endif   

end sub


sub check_death()
    p_counter = p_counter - 1
    'Ultimo frame de muerte'
    if p_estado = EST_MURIENDO AND p_counter = 0

        pausa(50)
        p_estado = EST_NORMAL

        'Si no hay mas vidas, Game Over'
        if lives > 0
            DisableMusic
            track = 255 'Reinicio la musica aunque toque la misma música luego'
            current_level = 255 'Reinicio del nivel
            player_energy = INIT_ENERGY
        else
            playing = 0
            GOTO fin_playing_loop
        end if
        
    end if

end sub



sub set_player_animation (fpi as ubyte, f0 as ubyte , f1 as ubyte = 0, f2 as ubyte =0, f3 as ubyte =0, f4 as ubyte =0, f5 as ubyte =0, f6 as ubyte =0, f7 as ubyte =0)
    
    'Cada cuantos frames cambia la animación del enemigo'
    fps_animacion = fpi

    'Guardar la lista de fotogramas en player_frames
    player_frames (0) = f0
#if MAX_FRAMES_PLAYER > 1
    player_frames (1) = f1
#endif
#if MAX_FRAMES_PLAYER > 2
    player_frames (2) = f2
#endif
#if MAX_FRAMES_PLAYER > 3
    player_frames (3) = f3
#endif
#if MAX_FRAMES_PLAYER > 4
    player_frames (4) = f4
#endif
#if MAX_FRAMES_PLAYER > 5
    player_frames (5) = f5
#endif
#if MAX_FRAMES_PLAYER > 6
    player_frames (6) = f6
#endif
#if MAX_FRAMES_PLAYER > 7
    player_frames (7) = f7
#endif

end sub

function player_touch_tile_num() as ubyte
    qtile(gpx>>4, gpy>>4)
    return aux2
end function

function player_touch_tile_type() as ubyte
    qtile(gpx>>4, gpy>>4)
    return aux1
end function

