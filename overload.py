import functools
import inspect
from collections import abc
import typing
import types
from typing import Any
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
            self.base = typing.get_origin(extended_type)  # get the original type that was generalized
            self.args = typing.get_args(extended_type)  # get the args of the type

            args = []
            for i in self.args:
                if isinstance(i, (types.UnionType, types.GenericAlias, typing.ByteString)):
                    args += [ext_type(i)]
                elif i==typing.AnyStr:
                    args += [ext_type(str|bytes)]
                elif i==typing.Any:
                    args += [(inspect._empty, )]
                # elif self.args==typing.Optional or self.args==typing.Union:
                    # args += [ext_type(i)]
                else:
                    args += [i]
            self.args = (*args, )
                
        def __repr__(self) -> str:
            return f'{self.extended} object, base {self.base} args {self.args}'
        
        @functools.cache
        def __eq__(self, other) -> bool:
            '''Fancy logic, all this does is approximate if the other extension class fits this one.'''
            is_match = []  # start off assuming the other class does not match
            if other.__call__() == '~':  # just make sure the other object is ext_type
                is_match += [other.base==self.base]  # ensure base types align
                for oarg, sarg in zip(other.args, self.args):  # iterate over arguments and make sure types align
                    x = sarg == oarg or isinstance(oarg, sarg)
                    is_match += [x]  
                    if not x:
                        x = oarg == sarg or isinstance(sarg, oarg)
                        if x:
                            is_match = is_match[:-1]+[True]
            if all(is_match):return True
            else: return (hash(self) == hash(other))
                 
        
        
        def __hash__(self) -> int:
            return hash((self.extended, self.base, self.args))
        
        def __call__(self, *args, **kwds):
            '''if __call__ on any object returns a "~", then it is an ext_type object'''
            return '~'
        
    @functools.cache
    def match(args: tuple[tuple[str, typing.Any]], annotations: tuple[tuple[str, typing.Any]]):
        '''This function accepts 2 same length tuples, and check if they are compatible.
        Args:
            args (tuple[tuple[str, typing.Any]]): The parameters to be check against.
            annotations (tuple[tuple[str, typing.Any]]): The overload annotations to check for.'''
        if len(args)!=len(annotations):
            return False
        for index in range(len(args)):
            param = args[index][1]
            annotation = annotations[index][1]
            if annotation == inspect._empty:
                continue
            if param != annotation:
                
                if isinstance(param, annotation):
                    continue
                return False
        return True
                

    
    def lookup(function: str, *args, **kwargs):
        '''This function looks up possible overloads for a function name, given the arguments and key-word arguments.
            Args:
                function (str): Name of the function to search overloads for.
                '''
        possible = {}
        for formatted, func in __overloads__[function].items():
            format_params = []
            try:
                done = 0
                fsig = inspect.signature(func)
                bargs = fsig.bind(*args, **kwargs)
                bargs.apply_defaults()
                i = 0
                binded_args = bargs.arguments
                for param_name, annotate in binded_args.items():
                    anon_t = type(annotate)
                    data = (param_name, anon_t)  # get the parameter name and type
                    if formatted[i][1] == inspect._empty:
                        data = formatted[i][0]
                        continue
                    elif formatted[i][1].__call__() == '~':  # check if the overloaded annotation is ext_type (used for special annotations)
                        if hasattr(annotate, '__iter__'):  # see if we can easily determine the arguments of the annotation

                            def loop(to_type):
                                '''Used to loop through an arguments' arguments to get the precise type.'''
                                for fx in to_type:
                                    tf = type(fx)
                                    if hasattr(fx, '__iter__') and (not(tf in (str, bytes, bytearray))):  # make sure we can continue forward
                                        tanon = tf[loop(fx)]
                                        break
                                    tanon = tf
                                
                                    break
                                return tanon
                            for fx in annotate:  # get the type of the argument precisely, by iterating through every single first element until we cannot -
                                # then we determine if the type is what this function requires.
                                tf = type(fx)
                                if hasattr(fx, '__iter__') and (not(tf in (str, bytes, bytearray))):
                                    tanon = tf[loop(fx)]
                                    break
                                tanon = tf
                                break
                            tanon = data[1][tanon]
                            extended_tanon = ext_type(tanon)
                            if extended_tanon == formatted[i][1]:
                                data = (data[0], formatted[i][1])
                        else:  # we cannot determine the type of the argument precisely
                            if formatted[i][1].base is anon_t:  # otherwise infer the arguments by whether or not their basetypes align
                                data = (data[0], formatted[i][1])
                                if not func in possible:  # if this function is not a backup, make it one!
                                    possible[func] = 0
                                possible += 1  # increase this functions demerit score (higher means less likely to match arguments)
                                warnings.warn(f"Could not verify arguments for arg {data[0]} with type {anon_t}, inferred to annotation {formatted[i][1].base} (expected type {formatted[i][1].args})")
                    format_params += [data]
                    i += 1
                format_params = tuple(format_params)
                del fsig, bargs
                full = []
                for j in range(len(format_params)):
                    if not format_params[j][0]==formatted[j][0]:
                        pass
                    else:
                        if isinstance(format_params[j][0], formatted[j][0]):
                            pass
                    if not func in possible:  # check if the overload for this function matches the arguments
                        return func(*args, **kwargs)
                done = 1
            except (TypeError, KeyError, IndexError) as e:  # oops! an error occurred!
                if func in possible:  # check if the function in the last iteration was a backup
                    if done == 0:  # if this function caused the error
                        del possible[func]  # delete it!
                continue
        if possible != {}:  # check if we have any inferred overloaded functions as backups
            func = sorted(possible.items(), key=lambda x: x[1])[0][0]
            warnings.warn(f"Could find suitable overloads for args {args} kwargs {kwargs}, using function {func} (scored {possible[func]})")
            return func(*args,**kwargs)  # pick the best one!
        assert False, f"No overloads found for function {function} with args {args} kwargs {kwargs}"  # no suitable overload for the arguments and types was found
      
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
                format_params += [(data[0], typedef)]  # be smart! if a default argument is found but no annotation, take the type of the default!
                continue
            elif isinstance(data[1], (types.UnionType, types.GenericAlias)):
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


class f:
    ...
    
def p(f: f):
    print('not preferred.')

def p(first: f):
    print('pd')
    

p(f())

t(((1,2), (3,4)))
