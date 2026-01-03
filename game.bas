#pragma strict_bool = true
'!ORG=24576
'!HEAP=1024
'!OPT=2
'!copy=.\data\My_Game.nex
'Adjust these parameters only if you know what you're doing, otherwise leave them as they are.'
'Ajusta estos parámetros si sabes bien lo que haces, si no, mejor déjalos como están.'

#include "dev/engine/control_keys_def.bas"
#include "dev/my/config.bas"
#include "dev/engine/definitions.bas"

#define IM2
#include <nextlib.bas>
#include <keys.bas>
#include <string.bas>
#include <asc.bas>

#include "dev/engine/nms_script.bas"
#include "dev/engine/levels_config.bas"
#include "dev/engine/printer.bas"
#include "dev/engine/general.bas"
#include "dev/engine/player.bas"
#include "dev/engine/enengine.bas"
#include "dev/my/custom_code/extra_functions.bas"
#include "dev/engine/hud_functions.bas"

ShowLayer2(0) 
get_frecuency()
set_joystick()
set_registers()
#ifdef CUSTOM_PALETTE
load_palettes()
#endif
init_sound()

paper 3: border 0 : bright 1: ink 0 : cls 'Magenta background on the ULA layer to use it for the hud'

#include "dev/my/custom_code/game_cc/after_load.bas" 'Custom code for intro, language selection, etc'

do ' main loop										
  #include "dev/engine/title_screen.bas" ' Here the title screen
  #include "dev/my/custom_code/game_cc/before_game.bas" 'custom code before the main loop of the game
  #include "dev/engine/game_loop.bas"
loop 'main loop

end

#ifdef FULL_CHARSET
font_buffer: 
asm
  defs 768
end asm  
#else
font_buffer: 
asm
  defs 512
end asm  
#endif