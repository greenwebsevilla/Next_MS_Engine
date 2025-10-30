'Definicion de niveles'
'Cada array tiene los valores para cada nivel, empezando por el 0, que es el primer nivel'

'Numero de tileset y beh que usa cada nivel // Ej. Para un valor 1, usará los archivos: "tiles_1.spr +  beh1.bin"
dim level_tileset(MAX_LEVELS-1) as ubyte => {LEVELS_TILESETS}

'Enemy sprites file for the levels // Ej. "enemiess_1.spr"
dim level_enemsprite(MAX_LEVELS-1) as ubyte => {LEVELS_ENEMIES}

'Tile to print instead of items per level'
dim tile_fondo(MAX_LEVELS-1) as ubyte => {61,61,0,0}

'Number of music track for the levels'
dim level_music(MAX_LEVELS-1) as ubyte => {LEVELS_MUSICS}


