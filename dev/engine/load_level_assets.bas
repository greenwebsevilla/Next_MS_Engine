'Player sprites'
LoadSDBank ("spr/player.spr",0,0,0,32)

' Load the level (level_number) assets'
'-------------------------------------'

'Load the map at DIMENSIONES_MAPA (loads 2 bytes (map width,height) + tiles)
fichero = "bin/maps/level_"+str(level_number)+"_tiles.bin"
LoadSD(fichero, DIMENSIONES_MAPA, 4092, 0)

'Load the enemy data at ENEMIES_BUFFER
fichero = "bin/maps/level_"+str(level_number)+"_enemies.bin"
'Calculate the size of the enemy file to load based on the number of enemies per screen'
size = 12*MAX_ENEMS
LoadSD(fichero, ENEMIES_BUFFER, size, 0)

'Load the sprites for enemies of the current sublevel'
fichero = "spr/enemies_"+str(level_enemsprite(level_number))+".spr"
LoadSDBank (fichero,0,0,0,55)

'load the tilesets'
LoadSDBank ("spr/tiles_"+str(level_tileset(level_number))+".spr",0,0,0,36)

'Load the beh files for the tileset
fichero = "bin/beh/beh"+str(level_tileset(level_number))+".bin"
LoadSD(fichero,@behs(0),128,0)


reset_enems() 'Resets all enemies, put all to type 0'
enems_load () 'copy enemies data to variables'
#ifdef ENEMY_BULLETS
reset_enemyBullets() 'Resets all proyectils'
#endif




