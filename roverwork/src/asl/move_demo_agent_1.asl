/**
 * Movement Update Demonstration Agent 1
 * 
 * This Agent wishes to move 0 places on the x axis and 6 places on the y axis at speed 2
 * Based on the code in Demonstration Agent 2, they will collide at a location:
 * 		0 places on the x axis and 4 places on the y axis
 * 
 * This agent would print out how far it has travelled and the remaining journey left
 * 
 * IMPORTANT
 * ---------
 * 
 * In situations where an Agent is travelling to get a resource for instance, this would
 * help you clear your last entry in the map, update it with the new information regarding
 * how far the Agent actually travelled and how far the agent is from its goal		
 * 
 */

!start.

/* Plans */

+!start : true <- .print("hello world.");
				  move(0,6,2);
				  .print("I am here....").

-!start : true <- .print("Check the error message").

+ result(move,4,A,B,X,Y)[source(percept)] : true 
			<- .print("I have moved: (", X , ",", Y , ")");
			   .print("I still have to move (", A , ",", B , ")");
			   .print("Place your mouse over both agents to confirm").
										