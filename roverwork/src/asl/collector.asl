// Starting Beliefs.
mapHeight(0).
mapWidth(0).
xPosition(0).
yPosition(0).
gold(0).



// Rules.

horizontal_scanned :-
	xPosition(X) & rover.ia.get_config(C,R,S,T) & mapWidth(Map) & (X >= (Map-R)).
	
at_Max_Capacity :-
	rover.ia.get_config(C,R,S,T) & gold(X) & (C <= X).



!start.

// Goals.

+!start : true <-  rover.ia.get_energy(E);
				   rover.ia.get_config(C,R,S,T);
				   -+capacity(C);
				   -+speed(S);
				   -+range(R);
				   .print("My Capacity: ", C,  " ...My Range: ", R, " .... My Speed: ", S,  "  ... My pref Type: " , T);
				   
				   !scout_Horizontal;
				   !scout_Vertical;
				   !delegate_Position.

+!move(X, Y, Z) : true <-
	?xPosition(OldX);
	?yPosition(OldY);
	move(X, Y, Z);
	NewX = OldX + X;
	NewY = OldY + Y;
	-+xPosition(NewX);
	-+yPosition(NewY);
	.print("X: ", NewX, " Y: ", NewY).
	
	




// Delegation Goals.

+! delegate_Position : true <-
	?mapWidth(X);
	?mapHeight(Y);
	.send(explorer1, achieve, move_down(Y/2));
	.send(explorer2, achieve, scan_for_gold).
	
	
	
// Gold Updates.

	
+! collect_gold(X, Y, Q) : not busy <-
	+busy;
	!move(X, Y, 1);
	!pickup;
	!move(-X, -Y, 1);
	!deposit;
	-busy.
	

//Scouting.

+! scout_Horizontal : true <-
	move(1, 0, 1);
	
	?mapWidth(X);
	Width = X + 1;
	-+mapWidth(Width);	
	!scout_Horizontal.
	
-! scout_Horizontal : true <-
	?mapWidth(X);
	.broadcast(tell, mapWidth(X)).
	
+! scout_Vertical : true <-
	move(0, 1, 1);
	
	?mapHeight(Y);
	Height = Y + 1;
	-+mapHeight(Height);	
	!scout_Vertical.
	
-! scout_Vertical : true <-
	?mapHeight(Y);
	.broadcast(tell, mapHeight(Y)).
					   				   							
							
// Deposit loot until empty.

+! deposit : true <- .print("depositing");
					  ?gold(X)
					  Z = X - 1;
					  -+gold(Z);					  
					  do(deposit);
					  !deposit.
					  
					  
					  
-! deposit : true <- .print("No more to deposit at this time.").

// Collect gold until no more gold.
	
+! pickup : true <-  .print("collecting gold");
						   ?gold(X);
						   Y = X + 1;
						   -+gold(Y);
						   do(collect);   
						   !pickup.
						   
-! pickup: true <- .print("I failed to pickup gold").
						 

// Events.

// Collect results.
												   
+ result(collect, 0): true <- .print("Agent collected one resource from the Map successfully").
								

+ result(collect, 1): true <- .print("The Agent does not have enough energy to move to collect the resource").

+ result(collect, 2): true <- .print("The Agent is unable to collect/does not support resource collection/ has a max_capacity of 0").

+ result(collect, 3): true <- .print("There is no resource at the Location").

+ result(collect, 4): true <- .print("The Agent is carrying its maximum load and has no space to accommodate the new item").

// Move results.

+ result (move, 0) : true <- .print("Movement was successful and Agent is at its destination").

+ result (move, 1) : true <- .print("The Agent does not have enough energy to move to the location at the specified speed").

+ result (move, 2) : true <- .print("The Agent is unable to move/does not support moving/ has a speed of 0").

+ result (move, 3) : true <- .print("The displacement or speed provided is not a valid number").
								 							 
+ result (move, 4) : true <- .print("can\'t move there").

// Deposit results.

+ result (deposit, 0): true <- .print("Agent deposited one resource to the Map successfully (To deposit at a Base, the Agent has to be at the base location").

+ result (deposit, 1): true <- .print("The Agent does not have enough energy to deposit the resource").

+ result (deposit, 2): true <- .print("The Agent is unable to deposit /does not support resource collecting and hence depositing / has a max_capacity of 0").

+ result (deposit, 3): true <- .print("The Agent does not have a resource to deposit").

// Delegation.





-busy :  gold_at(X, Y, Q) & xPosition(0) & yPosition(0) <-
		!collect_gold(X, Y, Q);
		-gold_at(X, Y, Q).
		



+ mapHeight(2) : true <- .send(explorer1, achieve, block_me_down).

+ mapWidth(2) : true <- .send(explorer2, achieve, block_me_right).


// Map fixed to map size.
				
+ xPosition(X) : mapWidth(Z) & (X >= Z) <- NewX = X - Z;
							   -+xPosition(NewX).


+ xPosition(X) : mapWidth(Z) & (X < 0) <- NewX = X + Z;
							   -+xPosition(NewX).
							   				   
							   
+ yPosition(Y) : mapHeight(Z) & (Y >= Z) <- NewY = Y - Z;
							   -+yPosition(NewY).

+ yPosition(Y) : mapHeight(Z) & (Y < 0) <- NewY = Y + Z;
							   -+yPosition(NewY).






	
