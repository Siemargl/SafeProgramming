(* Dining Philosophers example for a habr.com 
*  by Siemargl, 2019
*  ISO61131 ST language variant. Must be specialized 4 ur PLC 
* )
CONFIGURATION PLC_1

VAR_GLOBAL
	Forks : USINT;
	Philo_1: Philosopher;  (* Instance block - static vars *)
	Philo_2: Philosopher;
	Philo_3: Philosopher;
	Philo_4: Philosopher;
	Philo_5: Philosopher;
END_VAR

RESOURCE Station_1 ON CPU_1
	TASK Task_1 (INTERVAL := T#100MS, PRIORITY := 1);
	TASK Task_2 (INTERVAL := T#100MS, PRIORITY := 1);
	TASK Task_3 (INTERVAL := T#100MS, PRIORITY := 1);
	TASK Task_4 (INTERVAL := T#100MS, PRIORITY := 1);
	TASK Task_5 (INTERVAL := T#100MS, PRIORITY := 1);

	PROGRAM Life_1 WITH Task_1: 
		Philo_1(Name := 'Kant', 0, 1, Forks);
	PROGRAM Life2 WITH Task_2: 
		Philo_2(Name := 'Aristotel', 1, 2, Forks);
	PROGRAM Life3 WITH Task_3: 
		Philo_3(Name := 'Spinoza', 2, 3, Forks);
	PROGRAM Life4 WITH Task_4: 
		Philo_4(Name := 'Marx', 3, 4, Forks);
	PROGRAM Life5 WITH Task_5: 
		Philo_5(Name := 'Russel', 4, 0, Forks);

END_RESOURCE

END_CONFIGURATION

FUNCTION_BLOCK Philosopher;
USING SysCpuHandling.library;
VAR_INPUT
	Name: STRING;
	Left: UINT; 
	Right: UINT;
END_VAR
VAR_IN_OUT
	Forks: USINT;
END_VAR
VAR
	Thinking:	BOOL := TRUE;  (* States *)
	Hungry:	BOOL;
	Eating:	BOOL;
	
	HaveLeftFork:	BOOL;
	TmThink:	TON;
	TmEating:	TON;
END_VAR
	TmThink(In := Thinking; PT := T#3s);
	TmEating(In := Eating; PT := T#5s);
	IF Thinking THEN  (* Just waiting Timer *)
		Thinking := NOT TmThink.Q;
		Hungry := TmThink.Q;
	ELSIF Hungry (* Try Atomic Lock Forks *)
		IF HaveLeftFork 
			IF SysCpuTestAndSetBit(Address := Forks, Len := 1, iBit := Right, bSet := 1) = ERR_OK THEN
				Hungry := FALSE;
				Eating := TRUE;
			ELSE
				RETURN;
			END_IF
		ELSIF
			IF SysCpuTestAndSetBit(Address := Forks, Len := 1, iBit := Left, bSet := 1) = ERR_OK THEN
				HaveLeftFork := TRUE; 
			ELSE
				RETURN;
			END_IF
		END_IF
	ELSIF Eating  (* Waiting Timer, then lay forks *)
		IF TmEating.Q THEN
			Thinking := TRUE;
			Eating := FALSE;
			HaveLeftFork := FALSE;
			SysCpuTestAndSetBit(Address := Forks, Len := 1, iBit := Right, bSet := 0);
			SysCpuTestAndSetBit(Address := Forks, Len := 1, iBit := Left, bSet := 0);
		END_IF
	END_IF
END_FUNCTION_BLOCK
