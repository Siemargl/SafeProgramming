MODULE Philo;
(* Dining Philosophers Example from Active Oberon Language Report by Patrik Reali *)
(* Adapted for running in AOS by Siemargl *)


IMPORT Semaphores :=  Example8, Out;

CONST
	NofPhilo = 5; (* number of philosophers *)
	
VAR
	fork: ARRAY NofPhilo OF Semaphores.Semaphore;
	i: LONGINT;
	
TYPE
	Philosopher = OBJECT
		VAR
			first, second: LONGINT;
			(* forks used by this philosopher *)

		PROCEDURE & Init(id: LONGINT);
		BEGIN
			IF id # NofPhilo-1 THEN
				first := id; second := (id+1)
			ELSE
				first := 0; second := NofPhilo-1
			END
		END Init;
		
		PROCEDURE Think;  (* Need lock console output *)
		BEGIN {EXCLUSIVE}
			Out.Int(first);	Out.String(".... Think....");	Out.Ln;
		END Think;

		PROCEDURE Eat;
		BEGIN {EXCLUSIVE}
			Out.Int(first);	Out.String(".... Eat....");	Out.Ln;
		END Eat;

		
	BEGIN {ACTIVE}
		LOOP
			Think;
			fork[first].P; fork[second].P;
			
			Eat;
			fork[first].V; fork[second].V
		END
	END Philosopher;
	
VAR
	philo: ARRAY NofPhilo OF Philosopher;
	
BEGIN
	FOR i := 0 TO NofPhilo DO
		NEW(fork[i], INTEGER(i));
		NEW(philo[i], i);
	END;
END Philo.

Philo.Philo1 ~

