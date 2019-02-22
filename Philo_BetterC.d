// compile dmd -betterC 

import core.sys.windows.windows;
import core.stdc.stdio;
import core.stdc.stdlib : rand;
//import std.typecons; // -impossible (
//import std.string;  - impossible



extern (Windows) alias btex_fptr = void function(void*) /*nothrow*/;
//extern (C) uintptr_t _beginthreadex(void*, uint, btex_fptr, void*, uint, uint*) nothrow;
/* Dining Philosophers example for a habr.com 
*  by Siemargl, 2019
*  BetterC variant. Compile >dmd -betterC Philo_BetterC.d
*/

extern (C) uintptr_t _beginthread(btex_fptr, uint stack_size, void *arglist) nothrow;

alias HANDLE    uintptr_t;
alias HANDLE    Fork;

const philocount = 5;
const cycles = 20;

HANDLE[philocount]  forks;


struct Philosopher
{
    const(char)* name;
    Fork left, right;
    HANDLE lifethread; 
}
Philosopher[philocount]  philos;


extern (Windows) 
void PhilosopherLifeCycle(void* data) nothrow
{
    Philosopher* philo = cast(Philosopher*)data;

    
    for (int age = 0; age++ < cycles;)
    {
        printf("%s is thinking\n", philo.name);
        Sleep(rand() % 100);
        printf("%s is hungry\n", philo.name);

        WaitForSingleObject(philo.left, INFINITE);
        WaitForSingleObject(philo.right, INFINITE);

        printf("%s is eating\n", philo.name);
        Sleep(rand() % 100);
        ReleaseMutex(philo.right);
        ReleaseMutex(philo.left);
    }

    printf("%s is leaving\n", philo.name);
}

extern (C) int main() 
{
    version(Windows){} else { static assert(false, "OS not supported"); }

    philos[0] = Philosopher ("Aristotlet".ptr, forks[0], forks[1], null);
    philos[1] = Philosopher ("Kant".ptr, forks[1], forks[2], null);
    philos[2] = Philosopher ("Spinoza".ptr, forks[2], forks[3], null);
    philos[3] = Philosopher ("Marx".ptr, forks[3], forks[4], null);
    philos[4] = Philosopher ("Russel".ptr, forks[0], forks[4], null);

    foreach(ref f; forks)
    {
        f = CreateMutex(null, false, null);
        assert(f);  
    }

    foreach(ref ph; philos)
    {
        ph.lifethread = _beginthread(&PhilosopherLifeCycle, 0, &ph);
        assert(ph.lifethread);  
    }

    foreach(ref ph; philos)
        WaitForSingleObject(ph.lifethread, INFINITE);

    // Close thread and mutex handles
    for( auto i = 0; i < philocount; i++ )
    {
        CloseHandle(philos[i].lifethread);
        CloseHandle(forks[i]);
    }
    
    
	return 0;
}





