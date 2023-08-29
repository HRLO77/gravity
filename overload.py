import functools
import inspect
from collections import abc
import typing
import types
from typing import Any
import warnings
import itertools
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
        def __init__(self, extended_type: typing.Any):
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
                else:
                    args += [i]
            @functools.cache
            def recurse(typed: ext_type, level = 0):
                i = 0
                for arg in typed.args:
                    if arg.__call__() == '~':
                        level += 1
                        level += recurse(arg, level)
                    i += 1
                    
                return level
            self.args = (*args, )
            self.level = recurse(self)
            
        @functools.cache
        def __repr__(self) -> str:
            return f'{self.extended} object, base {self.base} args {self.args}'
        
        @functools.cache
        def __eq__(self, other, sc: bool=False) -> bool|tuple[bool, int]:
            '''Fancy logic, all this does is approximate if the other extension class fits this one.'''
            is_match = [] 
            score = 0
            if other.__call__() == '~':  # just make sure the other object is ext_type
                is_match += [other.base==self.base]  # ensure base types align
                for oarg, sarg in itertools.zip_longest(other.args, self.args, fillvalue=0):  # iterate over arguments and make sure types align
                    
                    x = sarg == oarg
                    # if not x:
                    #     any1 = isinstance(oarg, sarg)
                    #     score += 1 if any1 else 0
                    #     x = any1
                        # if not x:
                        #     x = oarg == sarg
                        #     if not x:
                        #         any1 = isinstance(sarg, oarg)
                        #         score += 1 if any1 else 0
                        #         x = any1
                    is_match += [x]
                length = len(self.args)-len(other.args)
                score += abs(length)
                is_match += [(self.level==other.level), length==0]
            if all(is_match):
                return True if not sc else (True, score)
            else: return (hash(self) == hash(other)) if not sc else ((hash(self) == hash(other)), score)
                 
        
        
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
                args_match = []
                for param_name, annotate in binded_args.items():
                    local_match = True
                    anon_t = type(annotate)
                    format_anon = formatted[i][1]
                    data = (param_name, anon_t)  # get the parameter name and type
                    # if format_anon is inspect._empty:
                    #     if not func in possible:  # if this function is not a backup, make it one!
                    #         possible[func] = 0
                    #     possible[func] += 3  # increase this functions demerit score (higher means less likely to match arguments)
                    #     data = formatted[i]
                    if format_anon.__call__() == '~':  # check if the overloaded annotation is ext_type (used for special annotations)
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
                            res = extended_tanon.__eq__(format_anon, True)
                            if res[0] and res[1]==0:
                                data = (data[0], format_anon)
                                local_match = True
                            elif res[0] and res[1] > 0:
                                if not func in possible:  # if this function is not a backup, make it one!
                                    possible[func] = 0
                                possible[func] += res[1]  # increase this functions demerit score (higher means less likely to match arguments)
                            else:
                                local_match = False
                        else:  # we cannot determine the type of the argument precisely
                            if format_anon.base is anon_t:  # otherwise infer the arguments by whether or not their basetypes align
                                data = (data[0], format_anon)
                                if not func in possible:  # if this function is not a backup, make it one!
                                    possible[func] = 0
                                possible[func] += 1  # increase this functions demerit score (higher means less likely to match arguments)
                                warnings.warn(f"Could not verify arguments for arg {data[0]} with type {anon_t}, inferred to annotation {format_anon.base} (expected type {format_anon.args})")
                    # else:
                        # local_match = formatted[i][1]==data[1]
                        # if not local_match:
                            # local_match = isinstance(data[1], formatted[i][1])
                    if formatted[i][1] is inspect._empty:
                        i+=1;args_match+=[True];continue
                    if not local_match:
                        i+=1;continue
                    local_match = data==formatted[i]
                    if not local_match:
                        local_match = isinstance(data[1], format_anon)
                    args_match += [local_match]
                    if not args_match:
                        break
                    i += 1
                del fsig, bargs
                if all(args_match):
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
            if data[1] is inspect._empty and not(param.default is inspect._empty):
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
