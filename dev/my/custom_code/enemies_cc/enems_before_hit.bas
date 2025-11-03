'Escribe aquí tu código custom para justo cuando un enemigo recibe daño. 
'** Por ejemplo para volver a poner animación de dañado, aturdido, etc. 
'(Luego puedes restaurar la animación normal en "enems_after_hit.bas") 

IF ENEMY_TYPE = 2 THEN               'FANTYS'
    ENEMY_ANIMATION(1,99,2) 'Animación golpeado'
END IF
