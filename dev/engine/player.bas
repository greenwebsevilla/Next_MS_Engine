sub player_locate()

    p_subframe = 0
    
    p_frame = 0 : p_subframe = 0

    if x_scroll > -32 AND x_scroll < x_fin_mapa 
        gpx = CAM_RIGHT_LIMIT
    else
        gpx = (cast(uinteger, player_x_ini) << 4) - x_scroll
    end if
    gpy = cast(uinteger, player_y_ini) << 4

    p_x = gpx << 6
    p_y = gpy << 6
   
    changing_floor = 0

end sub

sub game_init()

    success = 0: half_life = 0
    level_completed = 0
    level_number = FIRST_LEVEL 
    current_level = 255
    player_energy = INIT_ENERGY
    lives = INIT_LIVES
    playing = 1
    p_vx = 0: p_vy = 0
    player_facing = 0
    PLAYER_EXTRA_TOP_BB = 0 'por defecto no se amplía la caja de colisión por arriba'
    player_status = 0 : p_ct_estado = 0
    num_objects = 0 : player_damaged = 0
    level_floor = 0 : changing_floor = 0
    old_track = 255

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

sub go_to_another_map(level_num as ubyte, x_inicial as ubyte = 255, y_inicial as ubyte = 255)

    level_number = level_num
    current_level = 255 'Fuerza a repintar el nivel aunque vayamos al mismo nivel en el que estamos

    if y_inicial < 255 'Si no indicamos coordenadas x e y, solo vamos al mapa nuevo y apareceremos donde esté definido en el mapa
        player_x_ini = x_inicial
        player_y_ini = y_inicial MOD SCREENS_H
        level_floor = y_inicial/SCREENS_H
   
        teleport = 1 'ignorará la posición del player definida en el mapa'
    end if

end sub

function player_touch_tile_num() as ubyte

    qtile( (gpx+7+x_scroll)>>4, (gpy+3)>>4 )
    val_a = aux2
    qtile( (gpx+7+x_scroll)>>4, (gpy+15)>>4 )
    val_b = aux2
    if val_a = val_b then return aux2
    return 0

end function

function player_touch_tile_type() as ubyte

    qtile( (gpx+7+x_scroll)>>4, (gpy+3)>>4 )
    val_a = aux1
    qtile( (gpx+7+x_scroll)>>4, (gpy+15)>>4 )
    val_b = aux1
    if val_a = val_b then return aux1
    return 0
    
end function

sub stop_hz_speed()
    total_vx = 0
end sub

sub PlayerMove()

    if player_status < DYING_ST 
        control_vars () 'Read the control'
    end if

    'Gravedad'
#ifdef PLAYER_GRAVITY
    #ifdef ENABLE_LADDERS
    if PLAYER_ON_LADDER = 0
    #endif
        p_vy = p_vy + PLAYER_GRAVITY
        if p_vy > PLAYER_MAX_VY_FALLING then p_vy = PLAYER_MAX_VY_FALLING
    #ifdef ENABLE_LADDERS
    end if
    #endif
#endif

    ' Control Vertical
#ifndef ENABLE_UPDOWN_MOVE

#ifdef ENABLE_LADDERS

    player_calc_bounding_box()

    cx1 = ptx1+1 : cy1 = pty2   'abajo-izq
    cx2 = ptx2-1 : cy2 = pty2      'abajo-der
    check_n_points(2)
    if ct1 = 2 AND ct2 = 2 then ladder_up = 1 else ladder_up = 0

    cx1 = ptx1+1 : cy1 = pty2+17   '2 tiles más abajo, abajo-izq
    cx2 = ptx2-1 : cy2 = cy1     '2 tiles más abajo, abajo-der
    check_n_points(2)
    if ct1 = 2 AND ct2 = 2 then ladder_down = 1 else ladder_down = 0

    cx1 = ptx1+1 : cy1 = pty2+1   '1 tiles más abajo, abajo-izq
    cx2 = ptx2-1 : cy2 = cy1     '1 tiles más abajo, abajo-der
    check_n_points(2)
    if ct1 = 2 AND ct2 = 2 then ladder_middle = 1 else ladder_middle = 0

    if ladder_up AND KEY_TO_UP then PLAYER_ON_LADDER = 1 : p_vx = 0 : player_jumping = 0 
    if ladder_down AND KEY_TO_DOWN then PLAYER_ON_LADDER = 1 : p_vx = 0 : player_jumping = 0 

    if PLAYER_ON_LADDER

        IF KEY_TO_UP  
            p_vy = -LADDER_VY
        ELSEIF KEY_TO_DOWN  then
            p_vy = LADDER_VY
        else
            p_vy = 0
        END IF

    end if

    if not ladder_up AND not ladder_down AND not ladder_middle
        PLAYER_ON_LADDER = 0
    end if


#endif


#ifdef PLAYER_JUMPS
#ifdef DAMAGE_BOUNCE_POWER
        if (KEY_TO_JUMP AND player_jumping = 0 AND jump_pressed = 0) OR brinco
#else
        if KEY_TO_JUMP AND player_jumping = 0 AND jump_pressed = 0
#endif
    
            p_vy = - JUMP_POWER
            player_jumping = 1
            jump_pressed = 1
            on_ground = 0
            PlaySFX(SOUND_JUMP)
#ifdef ENABLE_LADDERS
            if PLAYER_ON_LADDER 
                p_vy = - JUMP_POWER_ON_LADDER
                PLAYER_ON_LADDER = 0
            end if
#endif
        end if


        if NOT KEY_TO_JUMP then jump_pressed = 0

#ifdef DAMAGE_BOUNCE_POWER
        if brinco then 
            p_vy = - DAMAGE_BOUNCE_POWER
            brinco = 0
        end if
#endif
#endif

#else 'defined ENABLE_UPDOWN'


    'UP & DOWN MOVEMENT
    if KEY_TO_UP

        '    player_facing = FACING_LEFT
#ifdef INERTIA
            p_vy = p_vy - PLAYER_AX
            if p_vy < -PLAYER_MAX_VX then p_vy = -PLAYER_MAX_VX
#else
            p_vy = -PLAYER_MAX_VX
#endif
        else

            if KEY_TO_DOWN
                ' player_facing = FACING_RIGHT
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

        check_n_points(2)
        
        if ct1 bAND 12 OR ct2 bAND 12 OR on_ground 'on_ground IMPORTANTE para plataformas móviles
            if (cy1 >= 0)
#ifdef ENABLE_LADDERS
                if not (PLAYER_ON_LADDER AND ct1 = 4) 
#endif
                cx1 = ptx1 : cy1 = pty2-4
                cx2 = ptx2 : cy2 = cy1
                check_n_points(2)
                if ct1 <> 4 AND ct2 <> 4 'Nos aseguramos que esté en la parte superior de la plataforma (TILE 4), y no por debajo'
                        p_vy = 0
#ifdef ENABLE_LADDERS
                        PLAYER_ON_LADDER = 0
#endif
#ifdef PLAYER_JUMPS
                        player_jumping = 0: brinco = 0
                    
#endif
                        if on_ground = 0 'Si no está subido a una plataforma, ajustamos la Y a la cuadrícula
                            gpy = gpy bAND 0xfff0
                            p_y = gpy << 6 
                        end if
                    end if
#ifdef ENABLE_LADDERS
                end if
#endif
            end if
        else 
#ifdef ENABLE_LADDERS
            if PLAYER_ON_LADDER = 0
#endif
#ifdef PLAYER_JUMPS
            player_jumping = 1: jump_pressed = 1
#endif
#ifdef ENABLE_LADDERS
            end if
#endif
            if (cy1 >= 0)
                if ct1 = 1 OR ct2 = 1
                    if player_status < FLICKERING_ST 

                    spike_touched = 1
                    end if
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
        if (cy1 >= 0)
            check_n_points(2)
            if ct1 = 8 OR ct2 = 8
                p_vy = 0
            end if

            if ct1 = 1 OR ct2 = 1
                if player_status < FLICKERING_ST 
                spike_touched = 1
                end if
            end if
        end if
        
    end if 

   

	p_y = p_y + p_vy

    if p_y < LIMITE_ARRIBA 
        if first_row        'CAMBIANDO DE PLANO DE ALTURA HACIA ARRIBA'
            changing_floor = 1
            level_floor = level_floor - 1
            current_level = 255
            player_x_ini = cast (ubyte, (gpx+x_scroll+7 >> 4))
            player_y_ini = SCREENS_H-1

        else
            p_y = LIMITE_ARRIBA
        end if
    end if
    
    if p_y > LIMITE_ABAJO
        if (first_row + SCREENS_H) < alto_mapa 'CAMBIANDO DE PLANO DE ALTURA HACIA ABAJO'
            changing_floor = 1
            level_floor = level_floor + 1
            current_level = 255
            player_x_ini = cast (ubyte, (gpx+x_scroll+7 >> 4))
            player_y_ini = 0

        else    
            p_y = LIMITE_ABAJO
        end if
    end if
	gpy = p_y >> 6


    

    ' CONTROL HORIZONTAL

#ifdef ENABLE_LADDERS
    if PLAYER_ON_LADDER = 0
#endif    
        if KEY_TO_LEFT 

            player_facing = FACING_LEFT
#ifdef INERTIA
            p_vx = p_vx - PLAYER_AX
            if p_vx < -PLAYER_MAX_VX then p_vx = -PLAYER_MAX_VX
#else
            p_vx = -PLAYER_MAX_VX
#endif
        else

            if KEY_TO_RIGHT 
                player_facing = FACING_RIGHT
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

   

    ' if disparando AND player_jumping = 0 then p_vx = 0

    total_vx = p_vx + plataforma_vx



#ifdef ENABLE_LADDERS
    end if ' END IF 'NOT PLAYER_ON_LADDER' PARA MOV HORIZONTAL
#endif




    ' Colisiones horizontales'
    if player_status < DYING_ST

#ifdef ENABLE_LADDERS
    if NOT PLAYER_ON_LADDER
#endif 

        player_calc_bounding_box()

        if total_vx > 0
       
                cx1 = ptx2+1 : cy1 = pty1 
                cx2 = ptx2+1 : cy2 = pty2-1 
                if (cy1 >= 0)
                    check_n_points(2)
#ifdef SPIKES_KILL_VERTICAL_ONLY
                    if ct1 bAND 9 OR ct2 bAND 9
#else
                    if ct1 = 8 OR ct2 = 8
#endif
                        stop_hz_speed() 
                    end if
#ifndef SPIKES_KILL_VERTICAL_ONLY
                    if ct1 = 1 OR ct2 = 1
                        if player_status < FLICKERING_ST 
                        spike_touched = 1
                        end if
                    end if
#endif
                end if
#ifdef PLAYER_SPRITE_16X32 
                cx1 = ptx2+1
                cy1 = pty1 - PLAYER_EXTRA_TOP_BB
                if (cy1 > 0)
                    check_n_points(2)
                    if ct1 bAND 9
                            stop_hz_speed() 
                    end if
                end if
#endif



#ifdef ENABLE_AUTOSCROLL
                if NOT autoscroll_on
                    p_x = p_x + total_vx

                    if p_x > CAM_RIGHT_LIMIT*64 
                        if ScrollToRight()
                        p_x = CAM_RIGHT_LIMIT*64 
                        end if
                    end if
                end if
#else
                p_x = p_x + total_vx
                
                if p_x > CAM_RIGHT_LIMIT*64 
                    if ScrollToRight()
                    p_x = CAM_RIGHT_LIMIT*64 
                    end if
                end if
#endif
                
        end if


        if total_vx < 0
        
                cx1 = ptx1-1 : cy1 = pty1 
                cx2 = ptx1-1 : cy2 = pty2-1 
                if (cy1 > 0)
                    check_n_points(2)
#ifdef SPIKES_KILL_VERTICAL_ONLY
                    if ct1 bAND 9 OR ct2 bAND 9
#else
                    if ct1 = 8 OR ct2 = 8
#endif
                        stop_hz_speed()
                    end if

#ifndef SPIKES_KILL_VERTICAL_ONLY
                    if ct1 = 1 OR ct2 = 1
                        if player_status < FLICKERING_ST 
                        spike_touched = 1
                        end if
                    end if
               
#endif
                end if
#ifdef PLAYER_SPRITE_16X32 
                cx1 = ptx1-1
                cy1 = pty1 - PLAYER_EXTRA_TOP_BB
                if (cy1 > 0)
                    check_n_points(2)
                    if ct1 bAND 9
                        stop_hz_speed() 
                    end if
                end if
#endif

                
#ifdef ENABLE_AUTOSCROLL   
                if NOT autoscroll_on   
                    p_x = p_x + total_vx  
                    if p_x < CAM_LEFT_LIMIT*64 
                        if ScrollToLeft()
                            p_x = CAM_LEFT_LIMIT*64
                        end if
                    end if
                end if
#else
                p_x = p_x + total_vx

                if p_x < CAM_LEFT_LIMIT*64 
                    if ScrollToLeft()
                        p_x = CAM_LEFT_LIMIT*64
                    end if
                end if
#endif
        end if 


#ifdef ENABLE_LADDERS
    end if ' END IF 'NOT PLAYER_ON_LADDER' PARA MOV HORIZONTAL
#endif

#ifdef ENABLE_AUTOSCROLL
    if autoscroll_on
        total_vx = total_vx - autoscroll_vel
        p_x = p_x + total_vx
    end if
#endif
 
'AUTOSCROLL (WIP)'
#ifdef ENABLE_AUTOSCROLL
    if autoscroll_on
        if autoscroll_vel < 0 
            ScrollToLeft()
        else
            ScrollToRight()                    
        end if
    end if
#endif

'PINCHOS Y TILES QUE MATAN'
        if spike_touched
            player_damaged = 1
            PlaySFX(SOUND_PLAYER_DAMAGED)
            spike_touched = 0
        end if
        
' // Flickering
        #ifdef PLAYER_FLICKERS

            if player_status = FLICKERING_ST
                    p_ct_estado = p_ct_estado - 1
                    if p_ct_estado = 0
                        player_status = NORMAL_ST
                    end if
            end if
        #endif

        ' El jugador recibe daño'
        if player_damaged 

            player_energy = player_energy - 1
#ifdef SHOW_ENERGYBAR
            print_energy()   
#endif

   'pequeño salto al dañar player'
#ifdef ENABLE_LADDERS
#ifndef FALL_OFF_LADDER
            if NOT PLAYER_ON_LADDER 
#endif
#endif
                brinco = 1
#ifdef ENABLE_LADDERS
#ifndef FALL_OFF_LADDER
            end if
#endif  
#endif  

            if player_energy > 0

                player_damaged = 0

#ifdef PLAYER_FLICKERS
                player_status = FLICKERING_ST
                p_ct_estado = FLICKERING_TIME
#endif   
                #include "../my/custom_code/player_cc/player_damaged.bas"
            else
                #include "../my/custom_code/player_cc/player_dies.bas"
                player_damaged = 0
                player_status = DYING_ST
                player_counter = 100
                lives = lives - 1
#ifdef SHOW_LIVES
                print_number_of_lives()
#endif 
            end if
        
        end if


    
    end if ' if player_status < DYING_ST

    if p_x < 2048 then p_x = 2048 'límite izquierdo pantalla'

    if p_x > 17408 'límite derecho pantalla'
        p_x = 17408 
    end if

    gpx = p_x >> 6  

#ifdef PLAYER_CAN_FIRE
    if KEY_TO_FIRE
        if disparando = 0 AND disparado = 0

            disparando = 4 
            disparado = 1
        
            shoot()

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
    _y1 = gpy + (SCREEN_Y_OFFSET<<4)

    if player_status = FLICKERING_ST AND half_life2 = 0

        RemoveSprite(PLAYER_FIRST_SP_VRAM,0)
#ifdef PLAYER_SPRITE_16X32
        RemoveSprite(PLAYER_FIRST_SP_VRAM+1,0)
#endif

    else

#ifdef PLAYER_SPRITE_16X32
        UpdateSprite(_x1, _y1-16, PLAYER_FIRST_SP_VRAM+1, PLAYER_FIRST_SP_VRAM+1, player_facing, 0) 'Extra Sprite Player for 32 pixels height
#endif
        UpdateSprite(_x1, _y1, PLAYER_FIRST_SP_VRAM, PLAYER_FIRST_SP_VRAM, player_facing, 0) 'Sprite Player

    end if

end sub 

sub player_calc_bounding_box()

	' definimos los puntos de la caja de colision del player
	ptx1 = gpx - (BOUNDING_BOX_LEFT_OFFSET)  + x_scroll
	pty1 = gpy - (BOUNDING_BOX_UP_OFFSET)

	ptx2 = gpx + x_scroll + 15 +(BOUNDING_BOX_RIGHT_OFFSET)
	pty2 = gpy + 15 +(BOUNDING_BOX_DOWN_OFFSET)

end sub




sub check_death()
    player_counter = player_counter - 1
    'Ultimo frame de muerte'
    if player_status = DYING_ST AND player_counter = 0

        pausa(50)
        player_status = NORMAL_ST

        'Si no hay mas vidas, Game Over'
        if lives > 0
            ' DisableMusic
            old_track = 255 'Reinicio la musica '
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


function player_in_zone (x as integer, y as integer, x2 as integer, y2 as integer) as ubyte

    dim absolute_y as integer = gpy + (cast(uinteger,level_floor*SCREENS_H)<<4)

    if ((cast(integer, gpx) + x_scroll) >= (x<<4) AND (gpx + x_scroll) < ((x2+1)<<4) AND absolute_y >= (y<<4) AND absolute_y < ((y2+1)<<4)) return 1

    return 0

end function

function get_player_xtiles () as ubyte

    return cast(ubyte,(cast(uinteger,gpx)+x_scroll)>>4)
    
end function

function get_player_ytiles () as ubyte

    return cast(ubyte,(gpy>>4)) + (level_floor*SCREENS_H)

end function