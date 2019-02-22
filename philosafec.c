/* Dining Philosophers example for a habr.com 
*  by Siemargl, 2019
*  Safe-C variant. Compile >mk.exe philosafec.c
*/

from std use console, thread, random;

enum philos (ushort) { Aristotle, Kant, Spinoza, Marx, Russell, };
const int cycles = 10;
const ushort NUM = 5;
uint  lived = NUM;


packed struct philosopher // 32-bit
{
	philos	name;
	byte left, right;
}

philosopher philo_body[NUM];

SHARED_OBJECT forks[NUM];

void philosopher_life(philosopher philo) 
{
	int age;
    for (age = 0; age++ < cycles; )
    {
        printf("%s is thinking\n", philo.name'string);
        delay((uint)rnd(1, 100));
        printf("%s is hungry\n", philo.name'string);

		enter_shared_object(ref forks[philo.left]);
		enter_shared_object(ref forks[philo.right]);

        printf("%s is eating\n", philo.name'string);
        delay((uint)rnd(1, 100));

		leave_shared_object(ref forks[philo.right]);
		leave_shared_object(ref forks[philo.left]);
    }

    printf("%s is leaving\n", philo.name'string);
    InterlockedExchange(ref lived, lived-1);
}


void main()
{
	philos i;

	assert philosopher'size == 4;
	philo_body[0] = {Aristotle, 0, 1};
	philo_body[1] = {Kant, 1, 2};
	philo_body[2] = {Spinoza, 2, 3};
	philo_body[3] = {Marx, 3, 4};
	philo_body[4] = {Russell, 0, 4};
	
	for (i = philos'first; i <= philos'last; i++)
	{
		assert run philosopher_life(philo_body[(uint)i]) == 0;
	}

	while (lived > 0) sleep 0; // until all dies

	for (i = philos'first; i <= philos'last; i++)
	{
		destroy_shared_object(ref forks[(uint)i]);
	}
}
