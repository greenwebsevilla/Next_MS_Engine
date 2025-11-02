'Deteccion de colisiones con el player'

cx2 = _en_x - x_scroll
cy2 = _en_y

no_kill = 0 'Default, all enemies kill'


'Colisiones enemigos-balas y player-enemigos'

#ifdef ENABLE_PLATFORMS    
if _en_t <> PLATFORM_TYPE 'No afecta a plataformas'
#endif

    if enem_status < ENEM_DAMAGED 'afecta solo a estados diferentes a tocado o muriendo

    'DISPAROS'
#ifdef OBJECT_TYPE
    if _en_t <> OBJECT_TYPE
#endif
        'Bucle colisiones balas con enemigos'
        for i = 0 to MAX_BULLETS-1
            if estado_bala(i) = 1 
                cx1 = x_bala(i)
                cy1 = y_bala(i)
                if cx1 > (cx2-12) AND cx1 < (cx2+14) AND cy1 >= cy2-8 - ENEMY_EXTRA_TOP_BB AND cy1 <= (cy2+4)
                    enem_recibe_golpe(1)
                    estado_bala(i) = 0
                end if
            end if
        next i
        

#ifdef STOMP_ENEMIES
        'Colision player pisando enemigos'
        if p_vy > 0
            cx1 = gpx + 8
            cy1 = gpy + 15
    
            if cx1 >= cx2 AND cx1 <= (cx2+15) AND cy1 >= cy2 - ENEMY_EXTRA_TOP_BB AND cy1 <= (cy2+8)
                PlaySFX(SOUND_ENEMY_STOMP)
                enem_recibe_golpe(1)
                brinco = 1
            end if
        end if
#endif

#ifdef OBJECT_TYPE    
    end if
#endif
        if p_estado < EST_PARP
            if enem_status < ENEM_DYING
                if collide() = 1
#ifdef OBJECT_TYPE
                    'CODE FOR COLLECTIBLES OBJECTS'
                    IF ENEMY_TYPE = OBJECT_TYPE
                        SOUND(OBJECTS_GET_SOUND)
                        NO_KILL                                 'THE COLLISION DOES NOT KILL THE PLAYER'
                        OBJECTS_NUMBER = OBJECTS_NUMBER + 1     'ADD 1 OBJECT TO THE COUNTER
                        KILL_SPRITE_NO_RESPAWN                  'DELETE THE OBJECT AND DISABLE RESPAWN
#ifdef SHOW_OBJECTS
                        print_objs()
#endif
                    END IF
#endif
                    #include "../my/custom_code/enemies_cc/enems_collisions.bas"

                    if no_kill = 0
                        player_damaged = 1
                        ' // METER FX
                        PlaySFX(SOUND_PLAYER_DAMAGED)
                    end if

                end if
            end if
        end if



    end if


#ifdef ENABLE_PLATFORMS    

else
'PLATAFORMAS MóVILES'
    
    if gpx > cx2 - 15
    if gpx < cx2 + 15
    if gpy >= cy2 - 17
    if gpy < cy2 - 9

        possee = 1
        plataforma_vx = 0: plataforma_vy = 0
        if half_life = 0
            plataforma_vx = _en_mx << 6 
            plataforma_vy = _en_my << 6 
        end if
        gpy = cy2 - 16
        p_y = gpy << 6
 
    end if
    end if
    end if
    end if

#endif

end if




