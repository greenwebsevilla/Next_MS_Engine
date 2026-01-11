' Iniciar los enemigos del nivel

sub reset_enems()
    for enit = 0 to MAX_ENEMS-1
        enemies_t (enit) = 0
    next enit
end sub

sub reset_enems_extra_vars()
    for enit = 0 to MAX_ENEMS-1
        ENEMY_VAR1 = 0
        ENEMY_VAR2 = 0
        ENEMY_VAR3 = 0
        ENEMY_VAR4 = 0
        ENEMY_VAR5 = 0
    next enit
end sub

sub enemy_start_code()
    #include "../my/custom_code/enemies_cc/enems_start.bas"
end sub

'Load the level's enemy data and store it in the variables'
sub enems_load ()

    total_enemies = peek(ENEMIES_BUFFER)

    for enit = 0 to total_enemies-1

		en_an_frame (enit) = 0
		en_an_state (enit) = ENEM_NORMAL

        enoffset = cast (uinteger, enit) * 12
         
        enemies_x (enit) =cast (uinteger, peek(ENEMIES_DATA + enoffset))<<4
        enemies_y (enit) =cast (uinteger, peek(ENEMIES_DATA + enoffset + 1) MOD SCREENS_H)<<4
        enemies_x1 (enit) =cast (uinteger, peek(ENEMIES_DATA + enoffset + 2))<<4
        enemies_y1 (enit) =cast (uinteger, peek(ENEMIES_DATA + enoffset + 3) MOD SCREENS_H)<<4
        enemies_x2 (enit) =cast (uinteger, peek(ENEMIES_DATA + enoffset + 4))<<4
        enemies_y2 (enit) =cast (uinteger, peek(ENEMIES_DATA + enoffset + 5) MOD SCREENS_H)<<4
     
        'ordenar limites en x e y'
        if enemies_x1 (enit) > enemies_x2 (enit) then
           enemies_x2 (enit) = enemies_x1 (enit)
           enemies_y2 (enit) = enemies_y1 (enit)
           enemies_x1 (enit) = cast (uinteger, peek(ENEMIES_DATA + enoffset + 4))<<4
           enemies_y1 (enit) = cast (uinteger, peek(ENEMIES_DATA + enoffset + 5) MOD SCREENS_H)<<4
        elseif enemies_y1 (enit) > enemies_y2 (enit) 
           enemies_y2 (enit) = enemies_y1 (enit)
           enemies_x1 (enit) = cast (uinteger, peek(ENEMIES_DATA + enoffset + 4))<<4
           enemies_y1 (enit) = cast (uinteger, peek(ENEMIES_DATA + enoffset + 5) MOD SCREENS_H)<<4
        end if

        enemies_mx (enit) = peek(ENEMIES_DATA + enoffset + 6)'Initial X speed'
        enemies_mx_ini (enit) = abs(enemies_mx (enit))'Initial X speed absolute value'
        enemies_my (enit) = peek(ENEMIES_DATA + enoffset + 7) 'Initial Y speed'
        enemies_my_ini (enit) = abs(enemies_my (enit))'Initial Y speed absolute value'
        enemies_t (enit) = peek(ENEMIES_DATA + enoffset + 8) 'Type of enemy'
        enemies_life (enit) = peek(ENEMIES_DATA + enoffset + 10) 'Enemy points of life'
        enemies_maxlife (enit) = enemies_life (enit) 'Max life of the enemy'

        enemies_spritenum (enit) = peek(ENEMIES_DATA + enoffset + 11) 'Sprite number in sprites memory, used for this enemy'

        enem_vy (enit) = 0 'Reset jump or oscillators speed'

        en_an_fps (enit) = DEFAULT_ENEM_FPS
 		en_an_num_frames (enit) = 1

        enemies_npant (enit) = peek(ENEMIES_DATA + enoffset + 1)/SCREENS_H ' numero de planta (level_floor) donde está'

        _en_t = enemies_t (enit)

        if _en_t = 255 'Type 255 is the player default location when a map is loaded'
            
            if teleport = 0 
                player_x_ini = peek(ENEMIES_DATA + enoffset)
                player_y_ini = peek(ENEMIES_DATA + enoffset + 1) MOD SCREENS_H
                level_floor = peek(ENEMIES_DATA + enoffset + 1)/SCREENS_H
            end if

            enemies_t (enit) = 0 'anulamos el tipo porque no es un enemigo'
            _en_t = 0
        end if
        

        enemy_start_code()

	next enit
    teleport = 0
    
end sub



sub aplicar_gravedad_enem()

    ' fuerza gravedad'
    _en_vy = _en_vy + ENEMY_GRAVITY
    if  _en_vy > ENEMY_MAX_VY then _en_vy = ENEMY_MAX_VY
    _en_my = cast(byte, (_en_vy >> 4))

end sub

sub aplicar_gravedad_invertida_enem()

    ' fuerza gravedad invertida'
    _en_vy = _en_vy - ENEMY_GRAVITY
    if  _en_vy < -ENEMY_MAX_VY then _en_vy = -ENEMY_MAX_VY
    _en_my = cast(byte, (_en_vy >> 4))

end sub

function pisa_suelo_enem() as ubyte
    cx1 = _en_x : cx2 = cx1+15
    cy1 = _en_y + 16 : cy2 = cy1
    check_n_points(2)
    if ct1 bAND 12 OR ct2 bAND 12 then return 1
    return 0
end function


'MOVER ENEMIGOS'

sub EnemiesMove()
    if total_enemies = 0 then return
    enviit = 0
    on_ground = 0

#ifdef ENABLE_PLATFORMS    'reset platform things'
    plataforma_vx = 0: plataforma_vy = 0
#endif

    for enit = 0 to total_enemies-1
        active = 0

        'copiar datos en variables auxiliares'
        _en_x = enemies_x(enit)
        _en_t = enemies_t(enit)
        enem_status = en_an_state (enit)

        'Descartamos los que estén fuera de pantalla o sean tipo 0'
        if _en_x > x_scroll+320 OR _en_x < x_scroll OR enemies_npant (enit) <> level_floor
#ifdef RESPAWN_ENEMIES
            if enem_status = ENEM_DEAD
                en_an_state (enit) = ENEM_NORMAL : enemies_life(enit) = enemies_maxlife(enit)
                enemy_start_code()
            end if
#endif
            CONTINUE FOR
        end if

        if _en_t = 0 OR enem_status = ENEM_DEAD then CONTINUE FOR

        'copiar resto de datos en variables auxiliares'
        _en_y = enemies_y(enit)
        _en_x1 = enemies_x1(enit)
        _en_y1 = enemies_y1(enit)
        _en_x2 = enemies_x2(enit)
        _en_y2 = enemies_y2(enit)
        _en_mx = enemies_mx(enit)
        _en_my = enemies_my(enit)
        _en_vy = enem_vy(enit)
        _en_facing = en_an_facing(enit)
        _en_sprnum = enemies_spritenum(enit)
        _en_life = enemies_life(enit)
        
        active = 0
        if  _en_t  'Si el tipo de enemigo es diferente a 0, se activa'
            active = 1
            diferencia = (_en_x- x_scroll) - gpx ' Calcular la posicion en X respecto al player'
#ifdef ENEMY_SPRITES_16X32
            ENEMY_EXTRA_TOP_BB = 0
#endif
            #include "../my/custom_code/enemies_cc/enems_loop.bas"
        end if
 
        'Animar enemigo'
        animate_enemy()

        'Pintar enemigo'
        draw_current_enemy()

        if active = 1 
            if enem_status < ENEM_DEAD 'No muerto'
                'COLISION CON PLAYER'
                #include "collisions.bas"
            end if
        end if

        'guardar de nuevo los valores actualizados en los arrays'     
        enemies_x(enit) = _en_x
        enemies_y(enit) = _en_y
        enemies_x1(enit) = _en_x1
        enemies_y1(enit) = _en_y1
        enemies_x2(enit) = _en_x2
        enemies_y2(enit) = _en_y2
        enemies_mx(enit) = _en_mx
        enemies_my(enit) = _en_my
        enem_vy(enit) = _en_vy
        enemies_t(enit) = _en_t
        en_an_facing(enit) = _en_facing
        enemies_spritenum(enit) = _en_sprnum
        enemies_life(enit) = _en_life
        en_an_state (enit) = enem_status

        enviit = enviit + 1
        if enviit = MAX_SPRITES_ON_SCREEN then EXIT FOR 'Up to X enemies (or objects) on screen'
    next enit
    
    while enviit < MAX_SPRITES_ON_SCREEN   'Up to X enemies (or objects) on screen'
        RemoveSprite(ENEMIES_FIRST_SP_VRAM+enviit, 0) 
#ifdef ENEMY_SPRITES_16X32
        RemoveSprite(ENEMIES_FIRST_SP_VRAM+MAX_SPRITES_ON_SCREEN+enviit, 0) 
#endif
        enviit = enviit + 1
    wend

end sub

sub set_enem_animation (tf as ubyte, fpi as ubyte, f0 as ubyte, f1 as ubyte = 0, f2 as ubyte =0, f3 as ubyte =0, f4 as ubyte =0, f5 as ubyte =0, f6 as ubyte =0, f7 as ubyte =0)
    
    'Numero total de fotogramas de la animación'
    en_an_num_frames(enit) = tf
    'Cada cuantos frames cambia la animación del enemigo'
    en_an_fps(enit) = fpi
    'Setear las variables de animacion'
    en_an_frame(enit) = 0 : en_an_subframe(enit) = 0

    'Guardar la lista de fotogramas en enem_animation
    enem_animation (enit,0) = f0
#if MAX_FRAMES_ENEMIES > 1
    enem_animation (enit,1) = f1
#endif
#if MAX_FRAMES_ENEMIES > 2
    enem_animation (enit,2) = f2
#endif
#if MAX_FRAMES_ENEMIES > 3
    enem_animation (enit,3) = f3
#endif
#if MAX_FRAMES_ENEMIES > 4
    enem_animation (enit,4) = f4
#endif
#if MAX_FRAMES_ENEMIES > 5
    enem_animation (enit,5) = f5
#endif
#if MAX_FRAMES_ENEMIES > 6
    enem_animation (enit,6) = f6
#endif
#if MAX_FRAMES_ENEMIES > 7
    enem_animation (enit,7) = f7
#endif

end sub

sub animate_enemy()

    'Animacion enemigos'
    if enem_status <> ENEM_DAMAGED
        'Plataformas'
        if _en_t = PLATFORM_TYPE 
            spnum = _en_sprnum 'Ponemos el sprite fijo que hayamos elegido' 
        else
            en_an_subframe(enit) =  en_an_subframe(enit) +1
            
                if en_an_subframe(enit) >= en_an_fps(enit) 
                    en_an_subframe(enit) = 0
                    en_an_frame(enit) =  en_an_frame(enit) + 1
                    if  en_an_frame(enit) = en_an_num_frames(enit)
                        en_an_frame(enit) = 0
                    end if
                end if
            
            if enem_status = ENEM_DYING 'Estado muriendo'

                _en_mx = 0
                
                #ifdef ENEMY_DEATH_BOUNCE   
                        aplicar_gravedad_enem()
                        mover_enemigo()
                #endif

                if _en_y > 160  'SALE POR ABAJO DE LA PANTALLA'

                    'Resetear enemigo en posicion y velocidad'
                    _en_x = enemies_x1(enit)
                    _en_y = enemies_y1(enit)
                    _en_mx = enemies_mx_ini(enit)
                    _en_my = enemies_my_ini(enit)
                    _en_vy = 0
                    enem_status = ENEM_DEAD 'Estado Muerto del todo'

                end if 
                            
            end if

        end if

       

    else    'ESTADO  enem_status = ENEM_DAMAGED , enemigo dañado'
            enem_counter (enit) =  enem_counter (enit) -1
           
            if enem_counter (enit) = 0 
                if _en_life > 0
                    enem_status = ENEM_NORMAL
                    #include "../my/custom_code/enemies_cc/enems_after_hit.bas"
                else
                    enem_status = ENEM_DYING
#ifdef ENEMY_DEATH_BOUNCE                    
                    _en_vy = -ENEMY_DEATH_BOUNCE
#endif
                    #include "../my/custom_code/enemies_cc/enems_die.bas"
                    en_an_subframe(enit) = 0
                    en_an_frame(enit) = 0
                    PlaySFX(SOUND_ENEMY_DIE)
    
                end if
            end if


    end if
    spnum = enem_animation (enit, en_an_frame(enit)) + _en_sprnum

 
end sub

sub draw_current_enemy()

    asm : nextreg $50,34 : nextreg $51,35 : end asm  'paginamos a los bancos 34 y 35'

    direccion = $0000+(256*spnum)
    Test_SetSprites(1,direccion,ENEMIES_FIRST_SP_VRAM+enviit) ' cargamos el frame que hay en direccion en el sprite 10+enviit'
#ifdef ENEMY_SPRITES_16X32
    if (ENEMY_EXTRA_TOP_BB>0)
        direccion = $0000+(256*spnum-(16*256))
        Test_SetSprites(1,direccion,ENEMIES_FIRST_SP_VRAM+MAX_SPRITES_ON_SCREEN+enviit) ' cargamos el frame que hay en direccion en el sprite 10+MAX_SPRITES_ON_SCREEN+enviit'
    end if
#endif
    
    asm : nextreg $50,$ff : nextreg $51,$ff : end asm   ' paginamos a los bancos por defecto
    
    if _en_t <> 0 AND enem_status < ENEM_DEAD 
        _x1 = _en_x - x_scroll
        _y = _en_y + (SCREEN_Y_OFFSET<<4) 'Imprimimos los sprites desplazados por haber desplazado el area de juego'
        UpdateSprite(_x1, _y, ENEMIES_FIRST_SP_VRAM+enviit, ENEMIES_FIRST_SP_VRAM+enviit, _en_facing, 0) 
#ifdef ENEMY_SPRITES_16X32
        if (ENEMY_EXTRA_TOP_BB>0)
            UpdateSprite(_x1, _y-16, ENEMIES_FIRST_SP_VRAM+MAX_SPRITES_ON_SCREEN+enviit, ENEMIES_FIRST_SP_VRAM+MAX_SPRITES_ON_SCREEN+enviit, _en_facing, 0) 'Parte superior del sprite enemigo de 16x32
        else
            RemoveSprite(ENEMIES_FIRST_SP_VRAM+MAX_SPRITES_ON_SCREEN+enviit, 0)  'Borrar enemigos inactivos'
        end if
#endif
    else
        RemoveSprite(ENEMIES_FIRST_SP_VRAM+enviit, 0)  'Borrar enemigos inactivos'
#ifdef ENEMY_SPRITES_16X32
        RemoveSprite(ENEMIES_FIRST_SP_VRAM+MAX_SPRITES_ON_SCREEN+enviit, 0)  'Borrar enemigos inactivos'
#endif
    end if

 
end sub


'COLISIONES ENEMIGOS CON PAREDES'

sub mons_col_sc_x()
    colision_ok = 0
    if _en_mx > 0 then
        cx1 = _en_x + 15 
    else
         cx1 = _en_x
    end if
    cx2 = cx1
    cy1 = _en_y
    cy2 = _en_y + 15
    check_n_points(2)
    if _en_t <>  5
        if ct1 = 8 OR ct2 = 8
            colision_ok = 1
        end if
    else
        if ct1 bAND 9 OR ct2 bAND 9
            colision_ok = 1
        end if
    end if
end sub

sub mons_col_sc_y()
    colision_ok = 0
    if _en_my > 0 then
        cy1 = _en_y + 15 
    else
         cy1 = _en_y
    end if
    cy2 = cy1
    cx1 = _en_x
    cx2 = _en_x + 15
    check_n_points(2)
    if ct1 = 8 OR ct2 = 8
        colision_ok = 1
    end if
end sub


'////// FUNCIONES ENEMIGOS //////'
sub mover_enemigo()

    'Estado 0: normal / 1: dañado /  10:muriendo / 12: muerto
    if enem_status < ENEM_DEAD
        _en_x = _en_x + _en_mx
        _en_y = _en_y + _en_my
    end if

    'Asignar facing y frame base a los enemigos animados'
    if _en_t <> PLATFORM_TYPE
        if _en_mx < 0 
            _en_facing = 8
        elseif _en_mx > 0 
            _en_facing = 0
        end if
    end if

end sub

#ifdef FANTYS
sub mover_fantasma()

        active = 1
        enemies_x_fanty(enit) = _en_x << 4
        enemies_y_fanty(enit) = _en_y << 4
            
        if diferencia < 0 
            enemies_mx_fanty(enit) = enemies_mx_fanty(enit) + FANTYS_ACELERACION
            if enemies_mx_fanty(enit) > FANTYS_MAX_VEL then enemies_mx_fanty(enit) = FANTYS_MAX_VEL
        else 
            enemies_mx_fanty(enit) = enemies_mx_fanty(enit) - FANTYS_ACELERACION
            if enemies_mx_fanty(enit) < -FANTYS_MAX_VEL then enemies_mx_fanty(enit) = -FANTYS_MAX_VEL
        end if

        diferencia = _en_y - gpy
    
        if diferencia < 0 
            enemies_my_fanty(enit) = enemies_my_fanty(enit) + FANTYS_ACELERACION
            if enemies_my_fanty(enit) > FANTYS_MAX_VEL then enemies_my_fanty(enit) = FANTYS_MAX_VEL
        else 
            enemies_my_fanty(enit) = enemies_my_fanty(enit) - FANTYS_ACELERACION
            if enemies_my_fanty(enit) < -FANTYS_MAX_VEL then enemies_my_fanty(enit) = -FANTYS_MAX_VEL
        end if

        _en_mx =  enemies_mx_fanty(enit)
        _en_my =  enemies_my_fanty(enit)

        enemies_x_fanty(enit) =  enemies_x_fanty(enit) + _en_mx
        enemies_y_fanty(enit) =  enemies_y_fanty(enit) + _en_my

        _en_x = enemies_x_fanty(enit) >> 4
        _en_y = enemies_y_fanty(enit) >> 4
        if _en_y < 0 then  _en_y = 0
        if _en_y > 192 then _en_y = 192
        
        'facing'
        if _en_mx >= 0
            _en_facing = 0
        else 
            _en_facing = 8
        end if

end sub
#endif

sub comprobar_limites()


    if _en_x <= _en_x1 then 
        _en_mx = enemies_mx_ini(enit)
    
    else if _en_x >= _en_x2
        _en_mx = -enemies_mx_ini(enit)

    end if

    ' limitex_ok:
    if _en_vy = 0
        if _en_y = _en_y1 OR _en_y = _en_y2
            _en_my = -_en_my
        end if
    end if


end sub

sub colision_enem_tiles()

#ifdef WALLS_STOP_ENEMIES
        mons_col_sc_x()
        if colision_ok  = 1
            _en_mx = -_en_mx
            _en_x = _en_x + 7
            _en_x = _en_x bAND 0xfff0
        end if
#endif

#ifdef WALLS_STOP_ENEMIES
        mons_col_sc_y()
        if colision_ok = 1
            _en_my = -_en_my
        end if
#endif

end sub

sub enem_rebote_vertical()

IF _en_vy >= 0
         _en_y = _en_y bAND 0xfff0
        _en_vy = -ENEM_JUMP_POWER
END IF

end sub

sub enem_recibe_golpe(fuerza as ubyte)

    _en_life = _en_life - fuerza
    enem_counter (enit) = 4
    enem_status = ENEM_DAMAGED 'estado dañado 
    enemies_mx_fanty(enit) = 0
    PlaySFX(SOUND_ENEMY_DAMAGED)
    #include "../my/custom_code/enemies_cc/enems_before_hit.bas"
end sub



#ifdef OSCILLATORS
sub mover_sube_baja()

    if _en_y < _en_y1-16
        aplicar_gravedad_enem()
    else
        aplicar_gravedad_invertida_enem()
    end if

end sub
#endif



