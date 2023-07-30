import functools
import inspect
from collections import abc
import typing
import types
import warnings
__overloads__ = {}


@functools.cache
def overload(function: abc.Callable):
    global __overloads__
    """A decorator which provides overloading capabilities of languages such as C++ functions.

    Args:
        function (abc.Callable): Function to overload
        
    """

    class ext_type:
        '''This class is used to provide greater resolution of special type annotations so less inferring is required.
        Args:
            extended_type (typing.Any): The special type to store.'''
        def __init__(self, extended_type: typing.Any) -> None:
            self.extended  = type(extended_type)
            self.base = typing.get_origin(extended_type)
            self.args = typing.get_args(extended_type)

            
            for i in self.args:
                if isinstance(i, (types.UnionType, types.GenericAlias, typing.ByteString)):
                    self.args = ext_type(self.args)
                elif i==typing.AnyStr:
                    self.args = ext_type(typing.Union[str, bytes])
                elif i==typing.Any:
                    self.args = (inspect._empty, )
                elif self.args==typing.Optional or self.args==typing.Union:
                    self.args = ext_type(self.args)
                
        def __repr__(self) -> str:
            return f'{self.extended} object, base {self.base} args {self.args}'
        
        @functools.cache
        def __eq__(self, other) -> bool:
            return hash(self) == hash(other)
        
        
        def __hash__(self) -> int:
            return hash((self.extended, self.base, self.args))

    @functools.cache
    def match(f1: tuple[tuple[str, typing.Any]], f2: tuple[tuple[str, typing.Any]]):
        '''This function accepts 2 same length tuples, and check if they are compatible.
        Args:
            f1 (tuple[tuple[str, typing.Any]]): The parameters to be check against.
            f2 (tuple[tuple[str, typing.Any]]): The overload annotations to check for.'''
        if len(f1)!=len(f2):
            return False
        for index in range(len(f1)):
            param = f1[index][1]
            annotation = f2[index][1]
            if annotation == inspect._empty:
                continue
            if param != annotation:return False
        return True
                

    
    def lookup(function: str, *args, **kwargs):
        '''This function looks up possible overloads for a function name, given the arguments and key-word arguments.
            Args:
                function (str): Name of the function to search overloads for.
                '''
        
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
                    data = (param_name, anon_t)  # get the parameter name and type
                    # check for special type cases
                    if isinstance(data[1], (types.UnionType, types.GenericAlias, typing.ByteString)):
                        data = (data[0], ext_type(data[1]))
                    elif data[1]==typing.Any:
                        data = (data[0], inspect._empty)
                    elif data[1]==typing.AnyStr:
                        data = (data[0], ext_type(typing.Union[str, bytes]))
                    elif data[1]==typing.Optional or data[1]==typing.Union:
                        data = (data[0], ext_type(data[1]))
                    elif hasattr(formatted[i][1], 'extended'):  # check if the overloaded annotation is ext_type (used for special annotations)
                        if data[1] in (list, tuple, memoryview, frozenset, set):  # if we can easily determine the arguments of the annotation
                            for fx in annotate:
                                tanon = type(fx)
                                break
                            if tanon in formatted[i][1].args and formatted[i][1].base is anon_t:
                                data = (data[0], formatted[i][1])
                        else:
                            if formatted[i][1].base is anon_t:  # otherwise infer the arguments by whether or not their basetypes align
                                data = (data[0], formatted[i][1])
                                warnings.warn(f"Could not verify arguments for arg {data[0]} with type {anon_t}, inferred to annotation {formatted[i][1].base} (expected type {formatted[i][1].args})")
                    format_params += [data]
                    i += 1
                format_params = tuple(format_params)
                del fsig, bargs
                if match(format_params, formatted):  # check if the overload for this function matches the arguments
                    return func(*args, **kwargs)
            except (TypeError, KeyError, IndexError) as e:
                continue
        
        assert False, f"No overloads found for function {function} with args {binded_args}"  # no suitable overload for the arguments and types was found
      
    if function.__name__ not in __overloads__:  # if overloads for this function do not exist,
        __overloads__[function.__name__] = {}
        f = function.__name__
        globals()[function.__name__] = (lambda *args, **kwargs:  lookup(f, *args, **kwargs))  # replace the function with a function that looks for overloads of itself
    
    if not function in __overloads__[function.__name__].values():  # check if this specific function overload currently exists
        sig = inspect.signature(function)
        params = sig.parameters.items()
        format_params = []
        for param_name, param in params:
            data = (param_name, param.annotation)  # get the name and type of each parameter
            typedef = type(param.default)
            # below if-elif statements process the annotations and make an overload for them
            if isinstance(data[1], inspect._empty) and isinstance((param.default if isinstance(typedef, type) else typedef), inspect._empty):
                format_params += [(data[0], typedef)]  # be smart!
                continue
            elif isinstance(data[1], (types.UnionType, types.GenericAlias, typing.ByteString)):
                data = (data[0], ext_type(data[1]))
            elif data[1]==typing.Any:
                data = (data[0], inspect._empty)
            elif data[1]==typing.AnyStr:
                data = (data[0], ext_type(typing.Union[str, bytes]))
            elif data[1]==typing.Optional or data[1]==typing.Union:
                data = (data[0], ext_type(data[1]))
            format_params += [data]
        format_params = tuple(format_params)
        if not format_params in __overloads__[function.__name__]:        
            __overloads__[function.__name__][format_params] = function  # create an overload for this function name

    @functools.wraps(function)
    def inner(*args, **kwargs):
        return lookup(function.__name__, *args, **kwargs)  # lookup possible overloads for the function

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
def j(l: typing.Any):
    print('j test')
    
j('')

k.j(0)
