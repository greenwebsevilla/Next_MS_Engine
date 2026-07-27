' Dibujar pantalla inicial
sub draw_scr()

    first_row = level_floor*SCREENS_H
#ifdef TILANIMS
    detect_tilanims() ' detectamos tiles animados de todo el level_floor'
#endif

    for y = 0 to (SCREENS_H-1)
        
        tt = ancho_mapa * cast(uinteger,y+first_row) 'Sin el cast tt pasa a valores ubyte'

        for x = 2  to 19 'Sumo 2 para empezar desde el tile 0, que se oculta con el clip de layer 2'
            asm : di: nextreg $56,90 : nextreg $57,91 : end asm 
            p = peek(tt+MAP_BUFFER)
            asm : nextreg $56,0 : nextreg $57,1 : ei :end asm 
            
            FDoTile16(p,x,y+SCREEN_Y_OFFSET,36)			' draw tiles from bank 36
            tt=tt+1 						' increase tile number
        next x

    next y 

end sub

'Before calling this sub, you need to set col_x and col_offset
'Antes de llamar a esta sub, hay que pasarle col_x y col_offset
sub draw_column()

    addx = (x_scroll>>4) + col_offset
    tt = ancho_mapa * cast(uinteger, first_row) + addx

    for y = 0 to (SCREENS_H-1)
        
        asm : di : nextreg $56,90 : nextreg $57,91 : end asm ' Paginamos el banco del mapa UNA sola vez para toda la columna
        p = peek(tt + MAP_BUFFER)
        asm : nextreg $56,0 : nextreg $57,1 : ei : end asm ' Restauramos la paginación normal
        tt = tt + ancho_mapa
        FDoTile16(p, col_x, y+SCREEN_Y_OFFSET, 36)

    next y

end sub

'Before calling this sub, you need to set _x, _y (in tile coordinates) and _t (tile number from the tileset)'
'Antes de llamar a esta sub, hay que pasarle _x, _y (en coordenadas de tiles) y  _t (numero de tile del tileset)'
sub update_tile(modify_map as ubyte)

    'Si modifica permanentemente el mapa actual, se cambia el valor del tile en el buffer'
    if modify_map = 1 
         
        tt = _x + (ancho_mapa * cast(uinteger,_y) )
        asm : di: nextreg $56,90 : nextreg $57,91 : end asm 
        poke(MAP_BUFFER + tt, _t) '  modificamos el mapa'
        asm : nextreg $56,0 : nextreg $57,1 : ei :end asm 
        
    end if

    'calcular la variación de la posición con el scroll'
    resto_scrollx = (_x MOD 20) + 2
    if resto_scrollx > 19 
        resto_scrollx = resto_scrollx - 20
    end if

    _x = _x - (x_scroll>>4)
    _y = _y+SCREEN_Y_OFFSET-first_row
    if _x > 0 AND _x < 20 AND _y < 16
        FDoTile16(_t,resto_scrollx, _y, 36)	' draw tiles from bank 36
    end if
    
end sub


sub pintar_tile (x_tile as ubyte, y_tile as ubyte, num_tile as ubyte)
    _x = x_tile : _y = y_tile : _t = num_tile
    update_tile(0)
end sub

sub actualizar_tile (x_tile as ubyte, y_tile as ubyte, num_tile as ubyte)
    _x = x_tile : _y = y_tile : _t = num_tile
    update_tile(1)
end sub

#ifdef TILANIMS
' Register all animated tiles
sub detect_tilanims()
    
    tilanim_num = 0

    for y = first_row to first_row+SCREENS_H-1
        
        tt = ancho_mapa * cast(uinteger,y) 'Sin el cast tt pasa a valores ubyte'

        for x = 0  to ancho_mapa-1 
            asm : di: nextreg $56,90 : nextreg $57,91 : end asm 
            p = peek(tt+MAP_BUFFER)
            asm : nextreg $56,0 : nextreg $57,1 : ei :end asm 
            if p >= tilanims_first AND tilanim_num < MAX_TILANIMS
                tiles_animados_x (tilanim_num) = x  'guardamos la x global en tiles'
                tiles_animados_y (tilanim_num) = y  'guardamos la y global en tiles'
                tiles_animados_t (tilanim_num) = p
                tilanim_num = tilanim_num + 1
            end if

            tt=tt+1 						' increase tile number
            
        next x

    next y 
    total_tilanims = tilanim_num
    tiles_subframe = 0
    
end sub


sub reset_tilanims ()

    for tile_id = 0 to MAX_TILANIMS
        tiles_animados_t(tile_id) = 255
    next tile_id

end sub
#endif



'PINTAR SPRITES CUSTOM'

sub put_sprite (bank_num as ubyte, spr_id as ubyte, image_num as ubyte, x_sprite as integer, y_sprite as ubyte, sp_facing as ubyte)

	'LOAD IMAGE IN SPRITE RAM'
    NextRegA($50,bank_num)
    NextRegA($51,bank_num+1) 
	direccion = $0000+(cast(uInteger,image_num)<<8)
    Test_SetSprites(1, direccion, 63-spr_id)
	asm : nextreg $50,$ff : nextreg $51,$ff : end asm

	'SHOW SPRITE'
	UpdateSprite(x_sprite, y_sprite, 127-spr_id, 63-spr_id, sp_facing, 0)

end sub

sub delete_sprite (spr_id as ubyte)
	RemoveSprite(127-spr_id,0)
end sub