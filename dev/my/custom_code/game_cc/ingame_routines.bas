'/ENTER HERE YOUR EXTRA ROUTINES WITHIN THE GAMELOOP'


IF LEVEL_NUM = 0     'SI ESTAMOS EN EL MAPA O NIVEL 0'
  
    'PUERTA HACIA MAPA O NIVEL 1'
    IF PLAYER_IN_ZONE(0,7,0,8)
        GOTOMAP(1,38,8) 'Vamos al mapa 1 y aparecerá el player en el tile x=38, y=8
    END IF

    'DETECCIÓN DE ZONA DEL MAPA DEL NIVEL 0, CAMBIAMOS LA MÚSICA E IMPRIMIMOS UN TEXTO'
    IF PLAYER_IN_ZONE(6,6,7,6) AND PRESS_UP
        DIALOG (1)
    END IF

    IF PLAYER_IN_ZONE(18,6,19,6) AND PRESS_UP
        DIALOG (2)
        MUSIC = 3
    END IF

ELSE IF LEVEL_NUM = 1  'SI ESTAMOS EN EL MAPA O NIVEL 1'

    'PUERTA HACIA MAPA O NIVEL 0'
    IF PLAYER_IN_ZONE(39,7,39,8) 
        GOTOMAP(0,1,8)  'Vamos al mapa 0 y aparecerá el player en el tile x=1, y=8
    END IF

    'PUERTA HACIA MAPA O NIVEL 2'
    IF PLAYER_IN_ZONE(0,7,0,8)
        GOTOMAP(2,14,8) 'Vamos al mapa 2 y aparecerá el player en el tile x=38, y=8
    END IF   
    

ELSE IF LEVEL_NUM = 2  'SI ESTAMOS EN EL MAPA O NIVEL 2'

    'PUERTA HACIA MAPA O NIVEL 1'
    IF PLAYER_IN_ZONE(15,7,15,8) 
        GOTOMAP(1,1,8)  'Vamos al mapa 1 y aparecerá el player en el tile x=1, y=8
    END IF

    'ZONA QUE TERMINA EL JUEGO SI LA TOCAMOS'
    IF PLAYER_IN_ZONE(0,7,0,8)
        SOUND(1)   'Suena el sonido 1'
        PAUSA(50)   'Hace una pausa de 50 frames'  
        END_GAME
    END IF

END IF




