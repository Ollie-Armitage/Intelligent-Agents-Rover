// Starting Beliefs.

rowStepsTaken(0).
xStepsTaken(0).
yStepsTaken(0).
gold(0).

// Rules.

horizontal_scanned :-
	rowStepsTaken(X) & rover.ia.get_config(C,R,S,T) & (X >= (40-R)).
	
return_up :-
	yStepsTaken(Y) & Y <= 20.

return_left :-
	xStepsTaken(X) & (X mod 40 <= 20).
	
at_Max_Capacity :-
	rover.ia.get_config(C,R,S,T) & gold(X) & (C <= X).



!start.

// Goals.

+!start : true <-  rover.ia.get_energy(E);
				   rover.ia.get_config(C,R,S,T);
				   .print("My Capacity: ", C,  " ...My Range: ", R, " .... My Speed: ", S,  "  ... My pref Type: " , T);
				   ! scan_for_gold.


// Return to base goals.

+! returnY : return_up <- 
	?yStepsTaken(Y);
	move(0, -Y, 1).

+! returnY : not return_up <-
	?yStepsTaken(Y);
	move(0, 40-Y, 1).
	
+! returnX : return_left <-
	?xStepsTaken(X);
	move(-(X mod 40), 0, 1).

+! returnX : not return_left <-
	?xStepsTaken(X);
	move(40-(X mod 40), 0, 1).
	
// Return from base goals.
	
+! reverseReturnY : return_up <- 
	?yStepsTaken(Y);
	move(0, Y, 1).

+! reverseReturnY : not return_up <-
	?yStepsTaken(Y);
	move(0, Y-40, 1).
	
+! reverseReturnX : return_left <-
	?xStepsTaken(X);
	move((X mod 40), 0, 1).

+! reverseReturnX : not return_left <-
	?xStepsTaken(X);
	move((X mod 40)-40, 0, 1).

+! scan_for_gold : true  <- scan(5).
							
+! move_strategically : true <-  
							!patrol;							
							!scan_for_gold.
							
// Patrol until scanned a row, then step down to the next row.
							
+! patrol : not horizontal_scanned <- 
	?rowStepsTaken(Steps);
	?xStepsTaken(XSteps);
	
	rover.ia.get_config(C,R,S,T);
	move(((2*R)-1),0,1);

	Z = Steps + ((2*R)-1);
	X = XSteps + ((2*R)-1);
	
	-+rowStepsTaken(Z);	
	-+xStepsTaken(X).
	
+! patrol : horizontal_scanned <-
	?yStepsTaken(Ysteps);
	rover.ia.get_config(C,R,S,T);
	move(0,R,1);	
	
	Z = Ysteps + (R);
	-+yStepsTaken(Z);
	
	-+rowStepsTaken(0).

// Return to base and deposit loot.

+! returnLoot : at_Max_Capacity <- 
	!returnY;
	!returnX;
	!deposit.

+! returnLoot : not at_Max_Capacity <- !patrol.

// Returns to place before looting.

+! reverseReturn : true <-
	!reverseReturnY;
	!reverseReturnX;
	!scan_for_gold.
	
// Deposit loot until empty.

+! deposit : true <- .print("depositing");
					  ?gold(X)
					  Z = X - 1;
					  -+gold(Z);					  
					  do(deposit);
					  !deposit.
					  
					  
					  
-! deposit : true <- .print("No more to deposit at this time.");
					!reverseReturn.

// Collect gold until no more gold.
	
+! collect_gold : true <-  .print("collecting gold");
						   ?gold(X);
						   Y = X + 1;
						   -+gold(Y);
						   do(collect);   
						   !collect_gold.
						   
-! collect_gold: true <- .print("I failed to collect gold").
						 

+! move_to_gold(X, Y): true <- move(X, Y, 1);						
						 + at_gold;
						 !collect_gold;
						 move(-X, -Y, 1);
						 !returnLoot.
						 


// Plans.
												   
+ result(collect, 4): at_gold <- .print("I can not carry any more gold").

+ result(collect, 3): at_gold <- .print("There is no gold here.").
					
+ result (scan, 0) : true <- -result(scan,0)[source(percept)].						
							
+ result(scan, -1) : true <- 	.print("I did not find anything after scanning");
								!move_strategically.
							 
+ discovery(X,Y,Q,gold): true <- .print("I found gold and I am moving to it")			 
								 !move_to_gold(X, Y).
								 							 
+ result (move, 4) : true <- .print("can\'t move there").


				
