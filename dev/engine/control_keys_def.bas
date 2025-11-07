'Variables control'
dim press_up, press_down, press_left, press_right, press_fire, press_fire2, press_pause as uinteger
dim key_up, key_down, key_left, key_right, key_fire, key_fire2, key_pause as uinteger
dim control as ubyte
dim tecla as ubyte
dim teclas_redef (0 to 6) as string
dim keys_to_play(6) as uinteger

'LOAD REDEFINED KEYS'
LoadSD("bin/keys.bin",@keys_to_play(0), 14, 0)

'Copy keys from array'
key_left = keys_to_play(0)
key_right = keys_to_play(1)
key_up = keys_to_play(2)
key_down = keys_to_play(3)
key_fire = keys_to_play(4)
key_fire2 = keys_to_play(5)
key_pause = keys_to_play(6)


'Control macros'
#define PRESS_UP press_up
#define PRESS_DOWN press_down
#define PRESS_LEFT press_left
#define PRESS_RIGHT press_right
#define PRESS_FIRE press_fire
#define PRESS_FIRE2 press_fire2
#define PRESS_PAUSE press_pause