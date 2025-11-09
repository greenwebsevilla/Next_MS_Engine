' Dibujar pantalla inicial
sub draw_scr()

    detect_tilanims() ' detectamos tiles animados de todo el mapa'
    mapbuffer = MAP_BUFFER	' point to the map 	
    columna_inicial = cast(byte, x_scroll>>4)
    ink 6

    for y = 0 to (SCREENS_H-1)
        
        tt = ancho_mapa * cast(uinteger,y) 'Sin el cast tt pasa a valores ubyte'
        tt = tt + columna_inicial + 2

        for x = 2  to 21 'Sumo 2 para empezar desde el tile 0, que se oculta con el clip de layer 2'
            p = peek(tt+mapbuffer)
            FDoTile16(p,x,y+SCREEN_Y_OFFSET,36)			' draw tiles from bank 36
            tt=tt+1 						' increase tile number
        next x
    next y 

end sub

'Dibujar nueva columna de tiles a la derecha'
sub draw_column_right()

    mapbuffer = MAP_BUFFER			' point to the map 	
    tt=0
    addx = (x_scroll>>4) + 19 'es el offset para leer el mapa, a partir de la columna que toque'
    if NOT colocando_scroll OR (cast(ubyte, posicion_x_inicial>>4) - cast(ubyte, x_scroll>>4))< 22 'pintamos solo las ultimas 21 si estamos colocando scroll'
        for y = 0 to (SCREENS_H-1)
            tt = ancho_mapa * cast(uinteger,y) 'Sin el cast tt pasa a valores ubyte'
            tt = tt + cast(uinteger,addx)
            p = peek(tt+mapbuffer)

            FDoTile16(p,columna_anterior,y+SCREEN_Y_OFFSET,36)			' draw tiles from bank 36
            tt=tt+1 						' increase tile number
            
        next y
    end if

end sub

'Dibujar nueva columna de tiles a la izquierda'
sub draw_column_left()
    
    mapbuffer = MAP_BUFFER			' point to the map 	
    tt=0
    addx = (x_scroll>>4) 'es el offset para leer el mapa, a partir de la columna que toque'
    for y = 0 to (SCREENS_H-1)
        tt = ancho_mapa * cast(uinteger,y) 'Sin el cast tt pasa a valores ubyte'
        tt = tt + cast(uinteger,addx)
        p = peek(tt+mapbuffer)

        FDoTile16(p,columna_actual,y+SCREEN_Y_OFFSET,36)			' draw tiles from bank 36
        tt=tt+1 						' increase tile number
    next y

end sub

'Before calling this sub, you need to set _x, _y (in tile coordinates) and _t (tile number from the tileset)'
'Antes de llamar a esta sub, hay que pasarle _x, _y (en coordenadas de tiles) y  _t (numero de tile del tileset)'
sub update_tile(modify_map as ubyte)

    'Si modifica permanentemente el mapa actual, se cambia el valor del tile en el buffer'
    if modify_map = 1 
        mapbuffer = MAP_BUFFER
        tt = _x + (ancho_mapa * cast(uinteger,_y) )
        poke(mapbuffer + tt, _t) '  modificamos el mapa'
    end if
    'calcular la variación de la posición con el scroll'
    resto_scrollx = (_x MOD 20) + 2
    if resto_scrollx > 19 
        resto_scrollx = resto_scrollx - 20
    end if

    _x = _x - (x_scroll>>4)
    if _x > 0 AND _x < 20 
    FDoTile16(_t,resto_scrollx, _y+SCREEN_Y_OFFSET, 36)	' draw tiles from bank 36
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
    mapbuffer = MAP_BUFFER	' point to the map 	

    for y = 0 to 9
        
        tt = ancho_mapa * cast(uinteger,y) 'Sin el cast tt pasa a valores ubyte'

        for x = 0  to ancho_mapa-1 
            p = peek(tt+mapbuffer)
            if p >= tilanims_first AND tilanim_num < MAX_TILANIMS
                tiles_animados_x (tilanim_num) = x  'guardamos la x global en tiles'
                tiles_animados_y (tilanim_num) = y  'guardamos la y global en tiles'
                tiles_animados_t (tilanim_num) = p
                tilanim_num = tilanim_num + 1
            end if
            tt=tt+1 						' increase tile number
            
        next x

    next y 
' pausa(999)
    tiles_animados_x (tilanim_num) = 255 'no mas tiles animados'
    tiles_animados_y (tilanim_num) = 255
end sub
#endif

