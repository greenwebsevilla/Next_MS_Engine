#ifdef SHOW_OBJECTS
function print_objs() as ubyte
#if OBJECTS_X < 32
    PRINT AT OBJECTS_Y,OBJECTS_X;INK 7;BRIGHT 1;str(num_objects)+" "
#endif
end function
#endif

#ifdef TIMER_ENABLE
#ifdef SHOW_TIMER
function print_time() as ubyte
       PRINT AT TIMER_Y,TIMER_X;INK 7;BRIGHT 1;str(timer_t)+" "
end function
#endif
#endif

#ifdef SHOW_LIVES
function print_number_of_lives() as ubyte
       PRINT AT LIVES_Y,LIVES_X;INK 7;BRIGHT 1;str(lives)+" "
end function
#endif

#ifdef SHOW_SCORE
function print_score() as ubyte
    dim x_score as ubyte
        
    if score < 100 then 
    x_score = SCORE_X+3
    elseif score < 1000 then 
    x_score = SCORE_X+2
    elseif score < 10000 then 
    x_score = SCORE_X+1
    else 
    x_score = SCORE_X
    end if
    print INK 7;BRIGHT 1;at SCORE_Y,x_score;score
    
	if score > next_extra_life
			next_extra_life = next_extra_life + EXTRA_LIFE_SCORE
            PLAYER_LIVES = PLAYER_LIVES + 1
			PlaySFX (6)
	end if
    
end function
#endif


#ifdef SHOW_ENERGYBAR
function print_energy() as ubyte
    if player_energy = 0 
        PRINT AT ENERGYBAR_Y,ENERGYBAR_X;"     "
    else
        for uit = 0 to player_energy-1
            PRINT AT ENERGYBAR_Y, uit + ENERGYBAR_X;ink 2;BRIGHT 1;"# "
        next uit
    end if	
end function
#endif

function print_hud() as ubyte

#include "../my/custom_code/game_cc/hud.bas"

#ifdef SHOW_SCORE   
    print INK 7;BRIGHT 1;at SCORE_Y,SCORE_X;"000000" 
    print_score ()
#endif

#ifdef SHOW_ENERGYBAR
    print_energy()
#endif

#ifdef SHOW_LIVES
    print_number_of_lives()
#endif

#ifdef SHOW_TIMER
    print_time()
#endif

#ifdef SHOW_OBJECTS
    print_objs()
#endif

end function


sub add_points (points as ubyte)
    score = score + points
    print_score()
end sub

sub delete_hud()

    PAPER 3: BRIGHT 1

    for i=0 to 7
        for j=0 to 31
            PRINT AT i,j;" "
        next j
    next i'

end sub