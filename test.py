import time
import os
import random
while 1:
    f = ''.join(random.sample('ABC123DEF456abcdefGHIghi789', 7))
    if input(f'Type {f} and press enter: ')==f:
        for i in range(random.randint(2, 5)):
            print('|', end='\r')
            time.sleep(0.3)
            print("/", end='\r')
            time.sleep(0.3)
            print('-', end='\r')
            time.sleep(0.3)
            print('\\', end='\r')
            time.sleep(0.3)
            print('|', end='\r')
            time.sleep(0.3)
            print('/', end='\r')
            time.sleep(0.3)
            print('-', end='\r')
            time.sleep(0.3)
            print('\\', end='\r')
            time.sleep(0.3)
            
        print('.', end='\r')
        time.sleep(0.5)
        print('..', end='\r')
        time.sleep(0.5)
        print('...', end='\r')
        time.sleep(0.5)
        print('Done system reset!')
        time.sleep(2)
        os.system('cls||clear')
    else:
        os.system('cls||clear')
        print('Incorrect code, wait for system reset prompt...')
        time.sleep(random.randint(5, 15))