!start.

+!start : true <-  rover.ia.get_energy(E);
				   rover.ia.get_config(C,R,S,T);
				   .print("My Capacity: ", C,  " ...My Range: ", R, " .... My Speed: ", S,  "  ... My pref Type: " , T);
				   ! scan_for_gold.


+! scan_for_gold : true  <- scan(2).
							
+! move_randomly : true <-  
							.print("moving around the map", 1, 1);
							 move(1, 1,1);
							.print("keeping track of my steps")
							rover.ia.add_journey(1, 1);
							!scan_for_gold.
	
+! collect_gold : true <-  .print("collecting gold");
						   do(collect)
						   ! collect_gold.
						   
-! collect_gold: true <- .print("I failed to collect gold").
												   
+ result(collect, 4): at_gold <- .print("I can not carry any more gold").

+ result(collect, 3): at_gold <-  .print("I can not carry any more gold").
					
+ result (move, 0) : at_gold <- .print("I am at the gold deposit");
								!collect_gold.	
									
+ result (scan, 0) : true <- -result(scan,0)[source(percept)].						
							
+ result(scan, -1) : true <- 	.print("I did not find anything after scanning");
								!move_randomly.
							 
+ discovery(X,Y,Q,diamond): true <- .print("I found diamond and I am moving to it")
								 move(X, Y, 1);
								 + at_gold;
								 rover.ia.add_journey(X, Y);
								 !collect_gold.	
								 
+ result (move, 4) : true <- .print("can\'t move there").