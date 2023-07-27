import functools
import inspect
from collections import abc
import typing
import types
import warnings
__overloads__ = {}


@functools.cache
def overload(function: abc.Callable):
    
    """A decorator which provides overloading capabilities of languages such as C++ functions.

    Args:
        function (abc.Callable): Function to overload
        
    """
    # check if overloads exist currectly
    try:
        global overloads
    except NameError:
        globals()['__overloads__'] = {}
    class ext_type:
        
        def __init__(self, extended_type: typing.Any) -> None:
            self.extended  = type(extended_type)
            self.base = typing.get_origin(extended_type)
            self.args = typing.get_args(extended_type)
            if isinstance(self.args, type):
                self.args = None
                
        def __repr__(self) -> str:
            return f'{self.extended} object, base {self.base} args {self.args}'
        
        @functools.cache
        def __eq__(self, other) -> bool:
            return hash(self) == hash(other)
        
        
        def __hash__(self) -> int:
            return hash((self.extended, self.base, self.args))

    @functools.cache
    def match(f1: tuple, f2: tuple):
        if len(f1)!=len(f2):
            return False
        for index in range(len(f1)):
            param = f1[index][1]
            annotation = f2[index][1]
            if annotation == inspect._empty:
                continue
            if param != annotation:return False
        return True
                

    @functools.cache
    def lookup(function: str, *args, **kwargs):
        
        
        for formatted, func in __overloads__[function].items():
            format_params = []
            try: 
                fsig = inspect.signature(func)
                bargs = fsig.bind(*args, **kwargs)
                bargs.apply_defaults()
                i = 0
                binded_args = bargs.arguments
                for param_name, annotate in binded_args.items():
                    anon_t = type(annotate)
                    data = (param_name, anon_t)
                    if isinstance(data[1], types.UnionType):
                        data = (data[0], ext_type(data[1]))
                    elif isinstance(data[1], types.GenericAlias):
                        data = (data[0], ext_type(data[1]))
                    elif hasattr(formatted[i][1], 'extended') :
                        if data[1] in (list, tuple, memoryview):
                            if type(annotate[0]) in formatted[i][1].args:
                                data = (data[0], formatted[i][1])
                        else:
                            if isinstance(formatted[i][1].base, anon_t):
                                data = (data[0], formatted[i][1])
                                warnings.warn(f"Could not verify arguments for {formatted[i][1].extended}, infered to {formatted[i][1].base} (expected {formatted[i][1].args})")
                    format_params += [data]
                    i += 1
                format_params = tuple(format_params)
                del fsig, bargs
                if match(format_params, formatted):
                    return func(*args, **kwargs)
            except (TypeError, KeyError, IndexError) as e:
                continue
        
        assert False, f"No overloads found for function {function} with args {binded_args}"

        
    if function.__name__ not in __overloads__:
        __overloads__[function.__name__] = {}
        f = function.__name__
        globals()[function.__name__] = lambda *args, **kwargs:  lookup(f, *args, **kwargs)
    
    if not function in __overloads__[function.__name__].values():
        sig = inspect.signature(function)
        params = sig.parameters.items()
        format_params = []
        for param_name, param in params:
            data = (param_name, param.annotation)
            typedef = type(param.default)
            if isinstance(data[1], inspect._empty) and isinstance((param.default if isinstance(typedef, type) else typedef), inspect._empty):
                format_params += [(data[0], typedef)]  # be smart!
                continue
            if isinstance(data[1], types.UnionType):
                data = (data[0], ext_type(data[1]))
            elif isinstance(data[1], types.GenericAlias):
                data = (data[0], ext_type(data[1]))
            format_params += [data]
        format_params = tuple(format_params)
        if not format_params in __overloads__[function.__name__]:        
            __overloads__[function.__name__][format_params] = function

    @functools.wraps(function)
    @functools.cache
    def inner(*args, **kwargs):
        return lookup(function.__name__, *args, **kwargs)

    return inner

@overload
def b(k: int, p):
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