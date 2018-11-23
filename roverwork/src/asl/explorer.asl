// Starting Beliefs.

rowStepsTaken(0).
xPosition(0).
yPosition(0).
gold(0).


// Rules.

horizontal_scanned :-
	xPosition(X) & rover.ia.get_config(C,R,S,T) & mapWidth(Map) & (X >= (Map-R)).
	
/* Deprecated

 * return_up :-
	yStepsTaken(Y) & mapHeight(Map) & Y <= (Map/2).

	return_left :-
	xPosition(X) & mapWidth(Map) & (X mod Map <= (Map/2)).
*/	

at_Max_Capacity :-
	capacity(C) & gold(X) & (C <= X).



!start.

// Scouting.

+!block_me_right[source(collector)] : true <- 
	!move(1, 0, 1).
	
+!block_me_down[source(collector)] : true <-
	!move(0, 1, 1).
	
	
// Initial Positioning.

+!move_down(Y)[source(collector)] : true <-
	!move(0, Y, 1);
	-+yPosition(Y);
	!scan_for_gold.
	

// Goals.

+!start : true <-  rover.ia.get_energy(E);
				   rover.ia.get_config(C,R,S,T);
				   +capacity(C);
				   +speed(S);
				   +range(R);
				   .print("My Capacity: ", C,  " ...My Range: ", R, " .... My Speed: ", S,  "  ... My pref Type: " , T).
				   

+!move(X, Y, Z) : true <-
	?xPosition(OldX);
	?yPosition(OldY);
	move(X, Y, Z);
	NewX = OldX + X;
	NewY = OldY + Y;
	-+xPosition(NewX);
	-+yPosition(NewY);
	.print("X: ", NewX, " Y: ", NewY).
	

/*Deprecated  
// Return to base goals.

+! returnY : return_up <- 
	?yPosition(Y);
	!move(0, -Y, 1).

+! returnY : not return_up <-
	?yPosition(Y);
	?mapHeight(Map);
	!move(0, Map-Y, 1).
	
+! returnX : return_left <-
	?xPosition(X);
	?mapWidth(Map);
	!move(-(X mod Map), 0, 1).

+! returnX : not return_left <-
	?xPosition(X);
	?mapWidth(Map);
	!move(Map -(X mod Map), 0, 1).
	
// Return from base goals.
	
+! reverseReturnY : return_up <- 
	?yPosition(Y);
	?mapHeight(Map);
	!move(0, Y, 1).

+! reverseReturnY : not return_up <-
	?yPosition(Y);
	?mapHeight(Map);
	!move(0, Y-Map, 1).
	
+! reverseReturnX : return_left <-
	?xPosition(X);
	?mapWidth(Map);
	
	!move((X mod Map), 0, 1).

+! reverseReturnX : not return_left <-
	?xPosition(X);
	?mapWidth(Map);
	
	!move((X mod Map)-Map, 0, 1).
*/

+! scan_for_gold : true  <- scan(7).
							
+! move_strategically : true <-  
							!patrol;							
							!scan_for_gold.
							
// Patrol until scanned a row, then step down to the next row.
							
+! patrol : not horizontal_scanned <- 
	
	rover.ia.get_config(C,R,S,T);
	!move(((2*R)-1),0,1).

	
+! patrol : horizontal_scanned <-
	rover.ia.get_config(C,R,S,T);
	!move(0,R,1).

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
						 


// Events.

// Collect results.
												   
+ result(collect, 0): true <- .print("Agent collected one resource from the Map successfully").
								

+ result(collect, 1): true <- .print("The Agent does not have enough energy to move to collect the resource").

+ result(collect, 2): true <- .print("The Agent is unable to collect/does not support resource collection/ has a max_capacity of 0").

+ result(collect, 3): true <- .print("There is no resource at the Location").

+ result(collect, 4): true <- .print("The Agent is carrying its maximum load and has no space to accommodate the new item").

// Scan results.

+ result(scan, -1) : true <- 	//.print("I did not find anything after scanning");
								!move_strategically.							 
					
+ result (scan, 0) : true <- -result(scan,0)[source(percept)].

+ result (scan, 1): true <- .print("The Agent does not have enough energy to scan at the given range").	

+ result (scan, 2) : true <- .print("The Agent is unable to scan/does not support scanning/ has a scan range of 0").

+ result (scan, 3) : true <- .print("The scan range parameter provided is not a valid number").
							
+ discovery(X,Y,Q,gold): not discovery_happening <- .print("I found gold and I am moving to it");
								 + discovery_happening;		 
								 .send(collector, achieve, collect_gold(X, Y)).
								 - discovery_happening.
								 
// Move results.

//+ result (move, 0) : true <- .print("Movement was successful and Agent is at its destination").

+ result (move, 1) : true <- .print("The Agent does not have enough energy to move to the location at the specified speed").

+ result (move, 2) : true <- .print("The Agent is unable to move/does not support moving/ has a speed of 0").

+ result (move, 3) : true <- .print("The displacement or speed provided is not a valid number").
								 							 
+ result (move, 4) : true <- .print("can\'t move there").

// Deposit results.

+ result (deposit, 0): true <- .print("Agent deposited one resource to the Map successfully (To deposit at a Base, the Agent has to be at the base location").

+ result (deposit, 1): true <- .print("The Agent does not have enough energy to deposit the resource").

+ result (deposit, 2): true <- .print("The Agent is unable to deposit /does not support resource collecting and hence depositing / has a max_capacity of 0").

+ result (deposit, 3): true <- .print("The Agent does not have a resource to deposit").


// Map fixed to map size.
				
+ xPosition(X) : mapWidth(Z) & (X >= Z) <- NewX = X mod Z;
							   -+xPosition(NewX).
							   
							   
+ yPosition(Y) : mapHeight(Z) & (Y >= Z) <- NewY = Y mod Z;
							   -+yPosition(NewY).

					

				
