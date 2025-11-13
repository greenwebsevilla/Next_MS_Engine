' This code is executed once per enemy loop (every frame).
'----------------------------------------------------------

'PRE-BUILT ENEMY STATUS'
'ENEMY_STATUS -->  0: moving / 1: damaged / 10: dying / 12: dead
'ENEMY_STATUS -->  0: moviéndose / 1: dañado / 10: muriendo / 12: muerto 

'LOGICA DE LOS ENEMIGOS'

'ENEMIGO TIPO 1 y 49: Patrollers y plataformas'
IF ENEMY_TYPE = 1 OR ENEMY_TYPE = PLATFORM_TYPE   

        IF ENEMY_STATUS = 0         ' Si está en estado 0 (moviéndose)

            IF HALF_LIFE            'Solo se ejecuta cada 2 frames (se usa para enlentecer los enemigos, tambien existe QUARTER_LIFE, cada 4 frames)
                MOVE_ENEMY          'Mueve a los enemigos en los ejes X e Y
                CHECK_ENEMY_LIMITS  'Comprueba si llega a los límites y rebota si llega a alguno de ellos
                CHECK_ENEMY_TILES   'Comprueba si toca un tile sólido y rebota si los toca'
            END IF

        END IF

#ifdef FANTYS
'ENEMIGO TIPO 2: Perseguidores. 
ELSE IF ENEMY_TYPE = 2  

        IF HALF_LIFE AND ENEMY_STATUS = 0       'Solo se mueve y persigue cada dos frames y en el estado 0'
            MOVE_FANTY                          'Ejecuta el movimiento perseguidor del tipo 2'
        END IF
 
#endif

#ifdef JUMPERS

'ENEMIGO TIPO 3: Saltarines' 
ELSE IF ENEMY_TYPE = 3  

        IF ENEMY_STATUS = 0                 ' Si está en estado 0 (moviéndose)
           
            ENEMY_ADD_GRAVITY               'Aplica gravedad al enemigo
            MOVE_ENEMY                      'Mueve a los enemigos en los ejes X e Y
            CHECK_ENEMY_LIMITS              'Comprueba si llega a los límites y rebota si llega a alguno de ellos
            IF ENEMY_IS_TOUCHING_GROUND           'Si el enemigo toca el suelo, rebota (o salta en este caso)'
                ENEMY_BOUNCE
            END IF
            CHECK_ENEMY_TILES               'Comprueba si toca un tile sólido y rebota si los toca'

        END IF
#endif

#ifdef OSCILLATORS

'ENEMIGO TIPO 4: OSCILANTE'
ELSE IF ENEMY_TYPE = 4 
        
        'Contador para que el enemigo dispare cada 100 fotogramas (mas o menos 2 segundos)'
        ENEMY_COUNTER = ENEMY_COUNTER + 1

        IF ENEMY_COUNTER = 100
            ENEMY_COUNTER = 0   'Reseteamos el contador'
            ENEMY_SHOOT (0,2)   'Dispara proyectil hacia abajo, el primer parametro es velocidad en X (VX) y el segundo VY (en píxeles/frame)'
        END IF


        IF ENEMY_STATUS = 0
            CHECK_ENEMY_LIMITS  'Comprueba si llega a los límites y rebota si llega a alguno de ellos
            MOVE_OSCILLATOR     'Aplica movimiento oscilante en vertical
            MOVE_ENEMY          'Mueve a los enemigos en los ejes X e Y (en el caso del oscillator, solo aplica a X, porque Y se  mueve con MOVE_OSCILLATOR)
        END IF
       
#endif

'...ADD YOUR CUSTOM ENEMIES, FOR EXAMPLE:
ELSE IF ENEMY_TYPE = 5

'...code for type 5...

ELSE IF ENEMY_TYPE = 6

'...code for type 5...

ELSE IF ENEMY_TYPE = 7

'...code for type 5...




'DON'T REMOVE THIS "END IF"
END IF
'DON'T REMOVE THIS "END IF"





