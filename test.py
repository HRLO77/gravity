from plum import dispatch as overload

@overload
def b(k: int, p=1):
    print('test1')

@overload
def b(first, second: float=4.0):
    return first+second

@overload
def b(l: tuple[str], p: int):
    print('test3')

b(7, 0)
b(9, p=0)
print(b(9.0))
b(('t', '2'), 9)
class t:
    
    @overload
    def j(self, test: str):
        print(test)
        
    @overload
    def j(self, k: int):
        print('j')
        
k = t()

k.j('k')

@overload
def j(l):
    print('j test')
    
j('')

k.j(0)

@overload
def t(l: tuple[tuple]):
    print('t0')

@overload
def t(l: tuple[tuple[int]]):
    print('t1')

    
@overload
def t(l: int):
    pass


t(((1,2), (3,4)))


@overload
def complicate(a: tuple[list[int|float]]|frozenset):
    print('first complicate')
    
@overload
def complicate(a: tuple[tuple[int|str|float]]):
    print('second complicate')
    
complicate(([1.], [2.]))

complicate((('', ''), ('', '')))  # 2

complicate(frozenset((1, 2)))  # 1
