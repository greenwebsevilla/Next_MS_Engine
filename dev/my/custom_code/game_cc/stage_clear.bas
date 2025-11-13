'INSERT HERE CODE FOR STAGE CLEAR STUFF'
'INSERTA AQUI TU PROPIO CODIGO PARA COSAS QUE QUIERAS QUE PASEN AL SUPERAR UN NIVEL'

'CODIGO EJEMPLO:'

HIDE_SPRITES                'Ocultamos todos los sprites'
MODE256                     'Cambiamos al modo 256x192'
CLS256(0)                   'Limpiamos la LAYER2'
CLS                         'Limpiamos la capa ULA'
FULL_ULA                    'Ponemos la capa ULA a pantalla completa'
TEXT(10,10,7,"STAGE CLEAR!") 'Imprimimos un texto'
MUSIC = MUSIC_STAGE_CLEAR   'Suena música'
PAUSA(250)                  'Pausamos durante 5 segundos'
CLS                         'Limpiamos la capa ULA'
CROP_ULA                    'Acotamos la ULA solo para el marcador'
MODE320                     'Cambiamos al modo 320x256'

