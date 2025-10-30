'GENERAL SUBS AND FUNCTIONS'

Sub Test_SetSprites(byVal Total as ubyte, spraddress as uinteger, byval firstSprite as ubyte)
  ' uploads sprites from memory location to sprite memory 
  ' Total = number of sprites, spraddess memory address 
  ' works for both 8 and 4 bit sprites 
  ASM 
    ld d,(IX+5)
    ;Select slot #0
    ;xor a        
        ld a,(ix+9)
    ld bc, $303b
    out (c), a

    ld b,d                ; how many sprites to send 

    ld l, (IX+6)
    ld h, (IX+7)
sploop:
    push bc
    ld bc,$005b          
    otir
    pop bc 
    djnz sploop
  end asm 
end sub

' QTILE: la variable aux1 devuelve el tipo de tile (beh) que hay en las coordenadas x_punto,y_punto en tiles'
        'la variable aux2 devuelve el número de tile en el tileset (posicion de 0 a 47 p.ej, si son 48 tiles)'
sub qtile(byval x_punto as uinteger, byval y_punto as uinteger)

  tilenum = x_punto + (ancho_mapa *cast(uinteger,y_punto)) 'Sin el cast tt pasa a valores ubyte' ' calcula la posicion del tile de la pantalla x_punto + y_punto*H (H = numero de tiles por fila en area de juego)
  mapbuffer = MAP_BUFFER
  p = peek(tilenum + mapbuffer) ' Lee el numero de tile que hay en esa posicion
  aux1 = behs(p) 'consultamos el tipo del tile en el array behs y lo almacenamos
  aux2 = p
end sub


' CM_TWO_POINTS: Devuelve el comportamiento (beh) del tile que hay en dos puntos (ct1 y ct2) definidos por sus coordenadas x,y en pixeles: cx1,cy1 para ct1 y cx2,cy2 para ct2
sub cm_two_points ()
    ' Punto ct1
    qtile(cx1 >> 4, cy1 >> 4)
    ct1 = aux1

    ' Punto ct2
    qtile(cx2 >> 4, cy2 >> 4)
    ct2 = aux1
end sub

sub pausa(tiempo as uinteger) 'Thanks to Duefectu'
    
    while tiempo > 0
      asm 
        push bc
        ld b,117
  pausa_Bucle1:        
          push bc
          ld b,255
  pausa_Bucle2:
            nop
            djnz pausa_Bucle2
          pop bc
          djnz pausa_Bucle1
        pop bc
      end asm
      tiempo = tiempo - 1
    wend

end sub


/'
MUSIC AND SOUND
'/

'Play a song from the begining (track = number of song) / Save the songs as 1.pt3 , 2.pt3, etc'
sub play_music ()
#ifdef ENABLE_SOUND
  DisableMusic
  LoadSDBank("music/"+ str(track) +".pt3",0,0,0,51) 
  InitMusic(50,51,0000)
  EnableMusic
#endif
end sub

' Get vertical frecuency speed
sub get_frecuency()
  
    contador_frecuencia60 = 6
    v=GetReg($05) bAND %100
    if v=0 then
      VarFrec=50  ' 50Hz
    else
      VarFrec=60  ' 60Hz
    end if

end sub

sub NoOptimizar()
    print VarFrec
    print contador_frecuencia60
end sub

'Force Kempston joystick MD1 3/6 buttons'
' forzar kempston joystick MD1 3/6 botones  '
sub set_joystick()
v = GetReg($05)
v = v bAND %101
v = v bOR %01001000 
NextRegA($05,v)
end sub

'SET NEXT REGISTERS'
sub set_registers()

  NextReg($7,$3) 'Set 28MHZ
  NextReg($15,%01110011) 'Sprites, L2 & ULA setting
  NextReg(GLOBAL_TRANSPARENCY_NR_14, GLOBAL_TRANSPARENT_COLOR) 'global transparent color (includes 8-bit tiles)'
  NextReg(SPRITE_TRANSPARENCY_I_NR_4B, SPRITES_TRANSPARENT_COLOR) 'transparent color for sprites'
  NextReg(LAYER2_RAM_BANK_NR_12,9)

end sub

'LOADING CUSTOM PALETTE'
sub load_palettes()

  LoadSD("pal/sprites.pal",PALETTE_BUFFER,512,0)
  NextReg($43,%00100000)
  PalUpload(PALETTE_BUFFER,0,0)
  LoadSD("pal/tiles.pal",PALETTE_BUFFER,512,0)
  NextReg($43,%00010000)
  PalUpload(PALETTE_BUFFER,0,0)

end sub

'Iniciar players de sonido y musica'
sub init_sound()
  ' MUSIC
  LoadSDBank("music/0.pt3",0,0,0,51) 				' load music.pt3 into bank 51
  LoadSDBank("music/vt24000.bin",0,0,0,50) 		' load the music replayer into bank 50
  LoadSDBank("music/fx.afb",0,0,0,44) 		' load SFX afb file into bank  44
  ' SFX
  InitSFX(44)							          ' init the SFX engine, sfx are in bank 44
  InitMusic(50,51,0000)				      ' init the music engine 50 has the player, 51 the pt3, 0000 the offset in bank 51
  SetUpIM()							            ' init the IM2 code 
  EnableSFX							            ' Enables the AYFX, use DisableSFX to top
  DisableMusic
end sub

' STAGE CLEAR
sub stage_clear ()

#include "../my/custom_code/game_cc/stage_clear.bas"
	
end sub
 
'Removes all sprites'
sub clear_sprites()
  for i = 0 to 96
    RemoveSprite(i,0)
  next i
end sub

'Detects collision between player and enemies'
'Detecta colision entre el jugador y enemigos'
function collide () as ubyte

	#ifdef SMALL_COLLISION_ENEM
		if (gpx + 8 >= cx2 AND gpx <= cx2 + 8 AND gpy + 8 - PLAYER_EXTRA_TOP_BB >= cy2 - ENEMY_EXTRA_TOP_BB AND gpy - PLAYER_EXTRA_TOP_BB <= cy2 + 8)
	#else
		if (gpx + 13 >= cx2 AND gpx <= cx2 + 13 AND gpy + 12 - PLAYER_EXTRA_TOP_BB >= cy2 - ENEMY_EXTRA_TOP_BB AND gpy - PLAYER_EXTRA_TOP_BB  <= cy2 + 12)
	#endif
      colision_ok = 1
    else 
      colision_ok = 0
  end if
      return colision_ok

end function

'Detects the collision of a point with the player (for example, enemy shots)'
' Detecta la colision de un punto con el player (por ejemplo, disparos enemigos)'
function point_collide () as ubyte

	#ifdef SMALL_COLLISION_SHOTS
		if (cx2 > gpx  AND cx2 < gpx+12 AND cy2 > gpy+4- PLAYER_EXTRA_TOP_BB AND cy2 < gpy+12)
	#else
		if (cx2 > gpx  AND cx2 < gpx+15 AND cy2 > gpy- PLAYER_EXTRA_TOP_BB AND cy2 < gpy+15)
	#endif
      colision_ok = 1
    else 
      colision_ok = 0
  end if
      return colision_ok

end function

'ANIMATED TILES'
'TILES ANIMADOS'
#ifdef TILANIMS
  sub AnimateTiles()
    tiles_subframe = tiles_subframe + 1
    if tiles_subframe = TILANIM_FREQUENCY 'Cambio de tile cada n frames' 
      tiles_subframe = 0
      dim tile_id as ubyte = 0

      tiles_frame = tiles_frame + 1
      if tiles_frame = MAX_FRAMES_TILANIM 
          tiles_frame = 0
      end if

      for tile_id = 0 to MAX_TILANIMS
        _x = tiles_animados_x (tile_id)
        if _x = 255 then EXIT FOR
          ' _x = _x - (x_scroll>>4)
          ' if _x > 1 AND _x < 20  
            _y = tiles_animados_y (tile_id)
            _t = tiles_animados_t (tile_id) + tiles_frame 
            ' resto_scrollx = (tiles_animados_x (tile_id) MOD 20) + 2
            ' if _x > 0 AND _x < 20
              update_tile(0)
            ' end if
          ' end if
      next tile_id
      
    end if
    
  end sub
#endif

sub game_over ()

    ShowLayer2(0)
    clear_sprites()
    CLS 
    CLS320()
    DisableMusic
    ResetScroll320()
    NextReg($70,0) ' usar 256x192'
    DisableMusic
    DisableSFX
    LoadSDBank("gfx/gameover.bin",0,0,0,18)
    ClipLayer2(0,255,0,191)
    ShowLayer2(1)
    EnableMusic
    EnableSFX
    track = 12 : play_music()
    pausa (200)
    
end sub


sub fin()

#include "../my/custom_code/game_cc/game_ending.bas"

end sub

sub ResetScroll320()
  asm
  nextreg $16,0 ;este registro mueve el layer2 de 0 a 255 pixeles 
  nextreg $71,0 ;este registro usa el bit 0 para moverlo hasta 319 en modo 320x256
  end asm
end sub

#ifdef TIMER_ENABLE
sub time_over ()

#include "../my/custom_code/game_cc/time_up.bas"

end sub

sub run_timer


    if timer_zero 
    
        time_over ()
        timer_zero = 0
        #ifdef TIMER_AUTO_RESET 			
            timer_t = TIMER_INITIAL
        #endif
        
    end if


    ' Timer
    if timer_on AND timer_t
        timer_count = timer_count + 1
        if timer_count = timer_frames
            timer_count = 0
            timer_t = timer_t-1
            print_time()
            if timer_t = 0 : timer_zero = 1 : end if
        end if
    end if



end sub


#endif

function print_cadena(salto_linea as ubyte) as ubyte
    dim caracter as string
    dim contador_cadena as integer
    dim xc, yc as ubyte
    ink 6
    xc = 0 : yc = 0 : contador_cadena = 0
    do
      caracter = cadena1$(contador_cadena)
      if caracter = "*"
        EXIT DO
      end if
      if caracter = "%"
        xc = 0
        yc = yc + salto_linea
        if yc > 23 then EXIT DO
      else
        PRINT AT yc,xc;caracter$
        xc = xc + 1
      end if
      pausa(2)
      contador_cadena = contador_cadena + 1
    loop
end function

function borra_cadena() as ubyte
    
     _y = 0
    while _y < 8
        for _x = 0 to 31
          ' L2Text(_x,_y," ",40,3)
          PRINT AT _y,_x;" "
        next _x
        _y = _y + 1
    wend
end function

sub WaitForNoKey()
do
  v = in(31)
  if GetKeyScanCode = 0 AND v = 0 then EXIT DO
loop
  ' while GetKeyScanCode <> 0 OR in(31) <> 0 : wend
end sub



' REDEFINIR TECLAS'
'Function to check if a key was defined previously when redefining keys'
function already_defined(codigo as uinteger) as ubyte
    for i = 0 to tecla
      if codigo = keys_to_play(i)
        return 1
      end if
    next i
    return 0
end function

sub redefine_keys()

    CLS

    if idioma = 0
      let teclas_redef(0) = "LEFT"
      let teclas_redef(1) = "RIGHT"
      let teclas_redef(2) = "JUMP"
      let teclas_redef(3) = "FIRE"
      let teclas_redef(4) = "BUTTON 2"
      let teclas_redef(5) = "PAUSE"
      cadena1 = "PRESS"
    else
      let teclas_redef(0) = "IZQUIERDA"
      let teclas_redef(1) = "DERECHA"
      let teclas_redef(2) = "SALTO"
      let teclas_redef(3) = "DISPARO"
      let teclas_redef(4) = "BOTON 2"
      let teclas_redef(5) = "PAUSA"
      cadena1 = "PULSA"
    end if

    'Reset keys'
    for i = 0 to 5
      keys_to_play(i) = 0
    next i

    j = 0
    if idioma = 1 then j = 3
    Print ink 6;at REDEFINE_TEXT_Y,REDEFINE_TEXT_X;cadena1$

    tecla = 0
    while tecla < 6
        Print ink 5;at REDEFINE_TEXT_Y,REDEFINE_TEXT_X+6;teclas_redef(tecla)+"   "
        WaitForNoKey()
        WaitKey()
        if GetKeyScanCode <> KEYR AND GetKeyScanCode <> KEYJ
          if tecla = 0 OR already_defined(GetKeyScanCode) = 0
            if tecla = 0 then key_left = GetKeyScanCode
            if tecla = 1 then key_right = GetKeyScanCode
            if tecla = 2 then key_up = GetKeyScanCode
            if tecla = 3 then key_fire = GetKeyScanCode
            if tecla = 4 then key_down = GetKeyScanCode
            if tecla = 5 then key_pause = GetKeyScanCode
            keys_to_play(tecla) = GetKeyScanCode
            PlaySFX(13)
            tecla = tecla + 1
          end if
        end if
    wend
   
    WaitForNoKey()
    CLS

    WaitRetrace(60)
    DisableMusic
    DisableSFX
    SaveSD("bin/keys.bin",@keys_to_play(0), 12)
    EnableMusic
    EnableSFX

end sub

Sub fastcall CopyToBanks(startb as ubyte, destb as ubyte, nrbanks as ubyte)
   asm 
    pop hl
    ld (HL_Temp),hl

    ; a = start bank       
    di 
    ld c,a             ; store start bank in c 
    pop de             ; dest bank in e 
    ld e,c             ; d = source e = dest 
    pop af 
    ld b,a             ; number of loops 

copybankloop:  
    push bc
    push de 
    ld a,e
    nextreg $50,a
    ld a,d
    nextreg $51,a 
    ld hl,$0000
    ld de,$2000
    ld bc,$2000
    ldir 
    pop de
    pop bc
    inc d
    inc e
    djnz copybankloop
    
    nextreg $50,$ff
    nextreg $51,$ff
    ei
    ld hl,(HL_Temp)
    push hl
    ret

HL_Temp:
    db 0,0
   end asm  
end sub


function control_vars() as ubyte

    if control = 1 'Control por kempston 3 botones'

        v=in(31) 'leer el puerto kempston 1'
        press_up = v bAND %100000 'salto con boton 2'
        press_down = v bAND %1000000 'magia con boton 3'
        press_left = v bAND %10
        press_right = v bAND %1
        press_fire = v bAND %10000
        press_pause = v bAND %10000000

    else 'Control por teclado'

        press_up = MultiKeys(key_up) 
        press_down = MultiKeys(key_down)
        press_left = MultiKeys(key_left) 
        press_right = MultiKeys(key_right)
        press_fire = MultiKeys(key_fire)
        press_pause = MultiKeys(key_pause)

    end if

end function

'RUTINAS DE SCROLL'
function process_right_scroll() as ubyte
      columna_actual = x_scroll_temp>>4
' print ink 6;at 2,10;columna_actual;" - ";columna_anterior;" "
      if x_scroll_temp_6 >= 20480 'es lo mismo que 320<<6'
          x_scroll_temp_6 = x_scroll_temp_6 - 20480
          x_scroll_temp = cast(integer, (x_scroll_temp_6 >> 6))
          columna_actual = 0
      end if
' print ink 6;at 0,0;x_scroll;" "
' print ink 6;at 1,0;x_scroll_temp;" "

      if columna_actual <> columna_anterior
          draw_column_right()
          columna_anterior = columna_actual 
      end if  
      
end function

function process_left_scroll() as ubyte
    columna_actual = x_scroll_temp>>4
' print ink 6;at 2,10;columna_actual;" - ";columna_anterior;" "
    if x_scroll_temp_6 < 0
        x_scroll_temp_6 = 20480 + x_scroll_temp_6
        x_scroll_temp = cast(integer, (x_scroll_temp_6 >> 6))
        columna_actual = 0
    end if
      
' print ink 6;at 0,0;x_scroll;" "
' print ink 6;at 1,0;x_scroll_temp;" "

    if columna_actual <> columna_anterior
        draw_column_left()
        columna_anterior = columna_actual 
    end if  
    
end function


sub do_x_scroll()

  asm
  ld hl, (_x_scroll_temp)
  ld a,l
  nextreg $16,a ;este registro mueve el layer2 de 0 a 255 pixeles 
  ld a,h 
  nextreg $71,a ;este registro usa el bit 0 para moverlo hasta 319 en modo 320x256
  end asm

end sub

sub calculos_vx_scroll()

  x_scroll_6 = x_scroll_6 + cast(long, total_vx)
  x_scroll = cast(integer, (x_scroll_6 >> 6))
  x_scroll_temp_6 = x_scroll_temp_6 + cast(long, total_vx)
  x_scroll_temp = cast(integer, (x_scroll_temp_6 >> 6))

end sub

function ScrollToLeft() as ubyte

    if x_scroll > -32
            calculos_vx_scroll()
            process_left_scroll()
            'Scroll en X'
            do_x_scroll()
            return 1
    else
      return 0
    end if

end function

function ScrollToRight() as ubyte

    if x_scroll < x_fin_mapa
            calculos_vx_scroll()
            process_right_scroll()
            'Scroll en X'
            do_x_scroll()
            return 1
    else
      return 0
    end if

end function


sub coloca_scroll()
  colocando_scroll = 1
  posicion_x_inicial = (cast(uinteger, player_x_ini) << 4) - CAM_RIGHT_LIMIT
  total_vx = 512 'Avanza 8 px (asegura el dibujado de las columnas)'
  while x_scroll < posicion_x_inicial AND x_scroll < x_fin_mapa 
    calculos_vx_scroll()
    ScrollToRight()
    ' pausa(25)
  wend
  total_vx = 0
  colocando_scroll = 0
end sub



sub ClearBank()
	asm
	;	di 
		nextreg $52,18
		ld hl,$4000 
		ld de,$4001 
		ld (hl),0
		ld bc,$2000
		ldir 
		nextreg $52,$0a 
	;	ei 
	end asm
end sub 

sub CLS320()
  ClearBank()
  CopyToBanks(18,19,9)
end sub




'Funciones y subs disparos jugador'
'R4 TL tk'
'C185 SKW GCHI'
sub shoot()

        for i = 0 to MAX_BULLETS-1
            if estado_bala(i) = 0 
                x_bala(i) = gpx + 4
                y_bala(i) = gpy + 0
                estado_bala(i) = 1
                v_bala(i) = 4 - p_facing
                facing_bala(i) = p_facing
                PlaySFX(11)
                EXIT FOR
            end if
        next i

end sub


sub BulletsPlayerMove()
    'Seleccionar frame del disparo'
    dim sprite_bala as ubyte = BULLET_SPRITE
    asm : nextreg $50,32 : nextreg $51,33 : end asm  'paginamos a los bancos 32 y 33'
    direccion = $0000+(256*sprite_bala)
    Test_SetSprites(1,direccion,PLAYER_BULLET_FIRST_SP_VRAM)
    asm : nextreg $50,$ff : nextreg $51,$ff : end asm   	' paginamos a los bancos por defecto

    for i = 0 to 2
    if estado_bala(i) = 1 
        x_bala(i) =  x_bala(i) + v_bala(i)
        _x1 = x_bala(i) + 4 + x_scroll
        _y = y_bala(i)+4
        qtile(_x1 >> 4, _y >> 4) 'Consultamos tipo de tile que está tocando la bala, nos lo devuelve aux1'
        if x_bala(i) > 310 OR aux1 = 8 then estado_bala(i) = 0 'si sale de la pantalla o el tipo de tile es sólido la apagamos'
        UpdateSprite(x_bala(i), y_bala(i) + (SCREEN_Y_OFFSET<<4),PLAYER_BULLET_FIRST_SP_VRAM+i,PLAYER_BULLET_FIRST_SP_VRAM,facing_bala(i),0)
    else 
        RemoveSprite(PLAYER_BULLET_FIRST_SP_VRAM+i,0)
    end if
next i
end sub


'Disparos enemigos'

sub reset_enemyBullets() 'reset all enemy bullets and items'
    for i = 0 to 2
        estado_enemyBullet(i) = 0 
        ' estado_item(i) = 0 
        estado_bala(i) = 0
    next i
end sub

sub shoot_enemyBullet(vx as byte, vy as byte)
    for i = 0 to MAX_ENEMY_BULLETS-1
        if estado_enemyBullet(i) = 0 
            estado_enemyBullet(i) = 1

            x_enemyBullet(i) = _en_x + 4
            if _en_facing = 8 then x_enemyBullet(i) = _en_x - 4
            y_enemyBullet(i) = _en_y
            vx_enemyBullet(i) = vx
            vy_enemyBullet(i) = vy
          
            EXIT FOR
        end if
    next i
end sub

sub EnemyBulletsMove() 

    for i = 0 to 2
        if estado_enemyBullet(i) = 1 
            spnum = sprite_enemyBullet(frame_enemyBullet)
            
            asm : nextreg $50,55 : nextreg $51,56 : end asm 
                direccion = $0000+(256*spnum)
                Test_SetSprites(1,direccion,ENEMBULLET_FIRST_SP_VRAM)
            asm : nextreg $50,$ff : nextreg $51,$ff : end asm  

            x_enemyBullet(i) =  x_enemyBullet(i) + vx_enemyBullet(i)
            y_enemyBullet(i) =  y_enemyBullet(i) + vy_enemyBullet(i)
            _x1 = x_enemyBullet(i) + 4
            _y = y_enemyBullet(i)+4
            qtile(_x1 >> 4, _y >> 4) 'Consultamos tipo de tile que está tocando la bala, nos lo devuelve aux1'

            'si sale de la pantalla o el tipo de tile es sólido la apagamos'
            if (x_enemyBullet(i) - x_scroll) > 310 OR (x_enemyBullet(i) - x_scroll) < 10 then 
                estado_enemyBullet(i) = 0 
            elseif y_enemyBullet(i) > 160 OR  y_enemyBullet(i) < 0 then 
                estado_enemyBullet(i) = 0
            end if
            
            if aux1 = 8 
               estado_enemyBullet(i) = 0
            end if

            UpdateSprite(x_enemyBullet(i)- x_scroll, y_enemyBullet(i) + (SCREEN_Y_OFFSET<<4),ENEMBULLET_FIRST_SP_VRAM+i,ENEMBULLET_FIRST_SP_VRAM,0,0)

            if p_estado < EST_PARP
                cx2 = x_enemyBullet(i) + 8 - x_scroll
                cy2 = y_enemyBullet(i) + 8
                if point_collide() = 1
                    estado_enemyBullet(i) = 0
                    player_damaged = 1
                    ' // METER FX
                    PlaySFX(4)

                end if
            end if

        else 
            RemoveSprite(ENEMBULLET_FIRST_SP_VRAM+i,0)
        end if
    next i
    
    if half_life then frame_enemyBullet = frame_enemyBullet + 1
    if frame_enemyBullet > 3 then frame_enemyBullet = 0

end sub



