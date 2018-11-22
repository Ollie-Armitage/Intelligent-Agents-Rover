// Starting Beliefs.
mapSize(20).
rowStepsTaken(0).
xStepsTaken(0).
yStepsTaken(0).


horizontal_scanned :-
	rowStepsTaken(X) & rover.ia.get_config(C,R,S,T) & (X >= (20-R)).
	
return_up :-
	yStepsTaken(Y) & Y <= 10.

return_left :-
	xStepsTaken(X) & (X mod 20 <= 10).
	
!start.

+!start : true <-  rover.ia.get_energy(E);
				   rover.ia.get_config(C,R,S,T);
				   .print("My Capacity: ", C,  " ...My Range: ", R, " .... My Speed: ", S,  "  ... My pref Type: " , T);
				   ! scan_for_gold.

+! returnY : return_up <- 
	?yStepsTaken(Y);
	move(0, -Y, 1).

+! returnY : not return_up <-
	?yStepsTaken(Y);
	move(0, 20-Y, 1).
	
+! returnX : return_left <-
	?xStepsTaken(X);
	move(-(X mod 20), 0, 1).

+! returnX : not return_left <-
	?xStepsTaken(X);
	move(20-(X mod 20), 0, 1).

+! scan_for_gold : true  <- scan(2).
							
+! move_strategically : true <-  
							!patrol;							
							!scan_for_gold.
							
+! patrol : not horizontal_scanned <- 
	?rowStepsTaken(Steps);
	?xStepsTaken(XSteps);
	
	rover.ia.get_config(C,R,S,T);
	move(R,0,1);

	Z = Steps + (R);
	X = XSteps + (R);
	
	-+rowStepsTaken(Z);	
	-+xStepsTaken(X).
	
+! patrol : horizontal_scanned <-
	?yStepsTaken(Ysteps);
	rover.ia.get_config(C,R,S,T);
	move(0,R,1);	
	
	Z = Ysteps + (R);
	-+yStepsTaken(Z);
	
	-+rowStepsTaken(0).

+! returnLoot : true <- 
	!returnY;
	!returnX;
	!deposit.

+! deposit : true <- .print("depositing");
					  do(deposit)
					  !deposit.
					  
-! deposit : true <- .print("No more to deposit at this time.").
	
+! collect_gold : true <-  .print("collecting gold");
						   do(collect)
						   ! collect_gold.
						   
-! collect_gold: true <- .print("I failed to collect gold").
												   
+ result(collect, 4): at_gold <- .print("I can not carry any more gold").

+ result(collect, 3): at_gold <-  .print("I can not carry any more gold").
					
+ result (move, 0) : at_gold <- .print("I am at the gold deposit");
								! collect_gold.	
									
+ result (scan, 0) : true <- -result(scan,0)[source(percept)].						
							
+ result(scan, -1) : true <- 	.print("I did not find anything after scanning");
								!move_strategically.
							 
+ discovery(X,Y,Q,gold): true <- .print("I found gold and I am moving to it")
								 ?xStepsTaken(XSteps);
								 ?yStepsTaken(YSteps);						 
								 
								 move(X, Y, 1);
								 + at_gold;
								 !collect_gold;
								 move(-X, -Y, 1);
								 !returnLoot.
								 							 
+ result (move, 4) : true <- .print("can\'t move there").


				
