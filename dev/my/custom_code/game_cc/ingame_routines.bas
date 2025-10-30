'/ENTER HERE YOUR EXTRA ROUTINES WITHIN THE GAMELOOP'


IF LEVEL_NUM = 0     'SI ESTAMOS EN EL MAPA O NIVEL 0'
  
    'PUERTA HACIA MAPA O NIVEL 1'
    PLAYER_IN_ZONE(0,7,0,8)
        ' SOUND(0)    'Suena el sonido 0'
        ' PAUSA(20)   'Hace una pausa de 20 frames'
        GOTOMAP(1,38,7) 'Vamos al mapa 1 y aparecerá el player en el tile x=38, y=7
        ' STAGE_CLEAR
    ENDING

    'DETECCIÓN DE ZONA DEL MAPA DEL NIVEL 0, CAMBIAMOS LA MÚSICA E IMPRIMIMOS UN TEXTO'
    PLAYER_IN_ZONE(73,4,74,5)
        TEXT(10,3,2,"ZONA TOCADA!!!")
        MUSIC(3)
    ENDING

    IF PRESS_DOWN
        UPDATE_TILE (84,7,6)
    END IF

ELSE IF LEVEL_NUM = 1  'SI ESTAMOS EN EL MAPA O NIVEL 1'

    'PUERTA HACIA MAPA O NIVEL 0'
    PLAYER_IN_ZONE(39,7,39,8) 
        ' SOUND(1)    'Suena el sonido 1'
        ' PAUSA(20)   'Hace una pausa de 20 frames'  
        GOTOMAP(0,1,7)  'Vamos al mapa 0 y aparecerá el player en el tile x=1, y=7
    ENDING

    'PUERTA HACIA MAPA O NIVEL 2'
    PLAYER_IN_ZONE(0,7,0,8)
        GOTOMAP(2,14,7) 'Vamos al mapa 1 y aparecerá el player en el tile x=38, y=7
    ENDING   

ELSE IF LEVEL_NUM = 2  'SI ESTAMOS EN EL MAPA O NIVEL 2'

    'PUERTA HACIA MAPA O NIVEL 1'
    PLAYER_IN_ZONE(15,7,15,8) 
        ' SOUND(1)    'Suena el sonido 1'
        ' PAUSA(20)   'Hace una pausa de 20 frames'  
        GOTOMAP(1,1,7)  'Vamos al mapa 0 y aparecerá el player en el tile x=1, y=7
    ENDING

    'ZONA QUE TERMINA EL JUEGO SI LA TOCAMOS'
    PLAYER_IN_ZONE(0,7,0,8)
        SOUND(10)   'Suena el sonido 1'
        PAUSA(50)   'Hace una pausa de 50 frames'  
        END_GAME
    ENDING

END IF
