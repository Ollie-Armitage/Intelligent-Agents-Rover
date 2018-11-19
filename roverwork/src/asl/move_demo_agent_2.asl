/**
 * Movement Update Demo Agent 2
 * This Agent has been configured to cause a collision by moving 
 * to a point 6 places away on the y-axis and 0 places away on the x axis at a speed of 3
 *
 * 
 * 	IMPORTANT
 * ------------
 * 
 * See move_demo_agent_1 code for more details
 */
!start.

/* Plans */

+!start : true <- .print("I am going to move 5 steps right now at speed 1");
				  move(0,6,3);
				  .print("scanning....");
				  scan(1);
				  move(0,-1, 1).
