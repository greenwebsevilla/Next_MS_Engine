#ifdef SHOW_OBJECTS
sub print_objs() 
#if OBJECTS_X < 32
    PRINT AT OBJECTS_Y,OBJECTS_X;INK 7;BRIGHT 1;str(num_objects)+" "
#endif
end sub
#endif

#ifdef TIMER_ENABLE
#ifdef SHOW_TIMER
sub print_time()
       PRINT AT TIMER_Y,TIMER_X;INK 7;BRIGHT 1;str(timer_t)+" "
end sub
#endif
#endif

#ifdef SHOW_LIVES
sub print_number_of_lives()
       PRINT AT LIVES_Y,LIVES_X;INK 7;BRIGHT 1;str(lives)+" "
end sub
#endif

#ifdef SHOW_SCORE
sub print_score()
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
			PlaySFX (SOUND_EXTRA_LIFE)
	end if
    
end sub
#endif


#ifdef SHOW_ENERGYBAR
sub print_energy() 
    if player_energy = 0 
        PRINT AT ENERGYBAR_Y,ENERGYBAR_X;"     "
    else
        for uit = 0 to player_energy-1
            PRINT AT ENERGYBAR_Y, uit + ENERGYBAR_X;ink 2;BRIGHT 1;"# "
        next uit
    end if	
end sub
#endif

sub print_hud() 

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

#ifdef TIMER_ENABLE
#ifdef SHOW_TIMER
    print_time()
#endif
#endif

#ifdef SHOW_OBJECTS
    print_objs()
#endif

end sub


sub add_points (points as ubyte)
    score = score + points
#ifdef SHOW_SCORE
    print_score()
#endif
end sub

sub delete_hud(start_y as ubyte)

    PAPER 3: BRIGHT 1

    for i=start_y to 9
        for j=0 to 31
            PRINT AT i,j;" "
        next j
    next i'

end sub

