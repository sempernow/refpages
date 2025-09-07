!/usr/bin/python -tt
# Python.org  https://www.python.org/
# 2.7 Docs  https://docs.python.org/2/
# 2.7 Language Reference  https://docs.python.org/2/reference/index.html
# 2.7 Standard Library Overview: https://docs.python.org/2/tutorial/stdlib.html
# 2.7 Standard Library  https://docs.python.org/2/library/index.html
# 2.7 Tutorial  https://docs.python.org/2/tutorial/index.html
# A Byte of Python [3]  https://python.swaroopch.com/

# META

  # White space AFFECTS MEANING
  # Use spaces NOT tabs
  # use Unix line endings

  # @ first line of script, use [either is okay] ...
  #  `#!/usr/bin/env python`
  #  `#!/usr/bin/python -tt`   # issue error on bad tab usage
    
  # COMMENTs 
    # Single-line comment; this line is one; 1st char is `#` symbol
    """ 
      Multi-line comment, or any such string, can be written thus; 
      delimited by 3 consecutive double-quote chars, before & after.
    """
  
  # RUN Python SCRIPT @ shell
    $ python foo.py bar
    $ ./foo.py bar          # equivalent first (Unix)

    $ python -i foo.py bar  # stay in Python interpreter [+state/env] after run.
    
  # RUN Python COMMAND @ shell
    $ python -c 'help("modules")'     # list all installed packages
    $ python -c 'help("modules foo")' # list all ... per [string] search `foo`
    
  # RUN Python SCRIPT @ Python interpreter 
    >>> execfile('foo.py')

  # RUN shell COMMAND/SCRIPT from Python interpreter
    # call a OS or shell script or executable [Win|Linux] from a Python script
    # https://docs.python.org/2/library/subprocess.html
    import subprocess as bash
    # Note LIST form; `[command, arg1, arg2]`
    bash.call(["./foo.sh", "arg1-a arg1-b","arg2"])  # script 
    bash.call(["ls", "-l"])                          # command/binary/utility
    
    #`...shell=True` [method]; DISCOURAGED where cmd string is untrusted
    bash.call("ls -l", shell=True)                   # equiv.
    bash.call("ps | grep python", shell=True)        # PIPEs okay
    
      # older [but simpler] method 
      import os 
      cmd = 'command.xyz arg1 "arg2-a arg2-b" arg3'
      os.system(cmd)
  
  # PIPE from/to [stdin/stdout] BASH @ Python interpreter
    import sys 
    for name in sys.stdin.readlines():  # pipe from stdin
      ...
    for name, count in names.items():   # pipe to stdout 
      sys.stdout.write("{0}\t{1}\n".format(name, count)) 
    
  # ACCESS OS Env. Vars. 
    import os 
    print os.environ           # dict of Env.Vars.; key-val pairs
    print os.environ[varName]  # value of dict @ key=varName
    
    # sort/print all Env. Vars.; key-val pairs
    for k,v in sorted(os.environ.items()):      
      print k + '=' + v
      
  # INFO on modules/functions/methods 
  
    # @ python interpreter 
      help(foo)              # man page for [object] foo()
      dir(modFoo)            # list names [functions] EXPORTED by module modFoo
      dir(modFoo.obj)        # list names defined by modFoo.obj
      help('modules')        # list all installed modules
      help('modules mNAME')  # list all ... per string search
      
      # pretty-print available [installed/loaded] modules
        import sys, pprint
        pprint.pprint(sys.modules)
      
    # PIP @ shell
      $ pip search pkgNAME     # search PyPI repo for pkg-names `pkgNAME` [substr]

  # INSTALL packages/modules 
    $ pip install pkgNAME      # DOWNLOAD+INSTALL pkg-name pkgNAME from PyPI repo
                               # Note @ Win install, `pip.exe` @ `C:\Python27\Scripts`


# MODULEs

  # A module is a Python script, `*.py`, that follows certain conventions.
  # https://docs.python.org/2/tutorial/modules.html
  
  # Module Namespaces 
    # if module `foo.py` contains function `def bar()`, 
    # then the FULLY QUALIFIED NAME of that `bar` function is `foo.bar`.

  import sys      # import a module
  sys.exit()      # call function `exit` in module `sys` 
  
  import module.submodule  # sub-module, NOT a function or class
  
    # alt method, but nullifies namespace protection; 
    # may be redefined elsewhere in script
    from sys import argv, exit
    exit(); argv()  # now available; vs. `sys.exit()`
  
  import foo, bar, baz # import several modules
  import math as m     # change module name [alias], e.g., shorten it
  
  # `__name__` is a global variable containing the script [module] name.
    import thisFoo as thatFoo
    thatFoo.__name__   # => `thisFoo`
    thatFoo.thisBar()  # call function `thisBar` from module `thisFoo`, 
                       # which is aliased as `thatFoo`.

    if __name__ == '__main__':
        print('This is the "main" script; NOT imported from any other script')
    else:
        print('This script [module] is imported by some parent script.')
  
  from __future__ import thisModule # `__future__` is a pseudo-module; a compiler directive to interpret `thisModule` per newer version of Python; enables use of newer language features otherwise incompatible.


# PACKAGES 
  # Packages are just folders of modules with a special `__init__.py` file.  
  - <some folder present in the sys.path>/
      - world/
          - __init__.py
          - asia/
              - __init__.py
              - india/
                  - __init__.py
                  - foo.py
          - africa/
              - __init__.py
              - madagascar/
                  - __init__.py
                  - bar.py 

  # SEARCH               
    $ pip search pkgNAME       # search PyPI repo for pkg-names `pkgNAME` [substr]

  # INSTALL packages/modules 
    $ pip install pkgNAME      # DOWNLOAD+INSTALL pkg-name pkgNAME from PyPI repo
                               # Note @ Win install, `pip.exe` @ `C:\Python27\Scripts`

                               
# STANDARD LIBRARY  https://docs.python.org/2/library/index.html

  # Special Attributes  https://docs.python.org/2/library/stdtypes.html#special-attributes
    object.__dict__     # returns object’s (writable) ATTRIBUTES.
    instance.__class__  # returns class to which a class INSTANCE belongs.
    class.__bases__     # returns TUPLE OF BASE CLASSES of a class object.
    definition.__name__ # returns name of class, type, function, method, ... or whatever.


# DECLARE/ASSIGN VARIABLEs
  # var name convention: lower_case_with_underscores
    some_var = 5  # declare + assign in one statement


# PRIMITIVES [Datatypes + Operators]

  bool(0)   # => False
  bool("")  # => False
  
  # IS/NOT; compare OBJECTS [Do not use `==`]

    "etc" is None  # => False
    None is None   # => True 
    None           # => None [is an object]

  # ternary syntax; equiv per C's `?:`
  'Yes.' if 3 > 2 else 'F-NO!'  # => 'Yes.'

  # ELLIPSIS 
    ... # `Ellipsis`; its origin and main utility is to handle multidimensional arrays (See "NumPy" pkg; `numpy`; "Numberic Extension of Python"), where slicing becomes more complex than just a start and stop index. Specifically, where `:` is a full slice per dimension, `...` is that in all implied dimensions. 
    # E.g., if `a` is a 4d array, then the following two expressions are EQUIVALENT:
      a[0,:,:,0] 
      a[0,...,0] 

  # STRINGS [immutable]
    # Regular Python strings are BYTES, NOT Unicode.
    "This is a string."
    'This is also a string.'
    
    "Hello " + "world!"    # => "Hello world!"
    "Hello " "world!"      # => "Hello world!"
    'hello ' * 3           # => 'hello hello hello '
    'Foo'.upper().lower()  # => foo

    "foo bar"[4:6]       # => 'ba'
    len(' foo ')         # => 5

    # justify/center; optionally per padding `n` w/ spaces or optionally w/ `char`
      str.rjust(n,char); str.ljust(n,char); str.center(n,char)
    
    # `split()` ; str => tup
      "foo bar".split(" ")      # => ['foo', 'bar']
    
    # `join()`  ; str <= tup
      "-".join(['foo', 'bar'])  # => 'foo-bar'

    # ESCAPE CHARACTERS  https://www.tutorialspoint.com/python/python_strings.htm
    """
      \a  0x07  Bell or alert
      \b  0x08  Backspace
      \cx       Control-x
      \C-x      Control-x
      \e  0x1b  Escape
      \f  0x0c  Formfeed
      \M-\C-x   Meta-Control-x
      \n  0x0a  Newline (Line Feed [LF])
      \nnn      Octal notation, where n is 0-7
      \r  0x0d  Carriage return
      \s  0x20  Space
      \t  0x09  Tab
      \v  0x0b  Vertical tab
      \x        Character x
      \xnn      Hex notation, where n is 0-9, a-f, A-F  
    """
      # E.g., Newline [LF]
        print('\n') 
        print('\x0a')     # equiv. [hex notation]
        print('\12')      # equiv. [octal notation]
        print(u'\u000a')  # equiv. [Unicode; 'LINE FEED']

    # UNICODE <==> BYTES conversions [NOTE: lingo is back-ass-wards]   
      # `.encode()` TO bytes; `.decode()` TO Unicode 
      # [Not all string ops work on Unicode strings; thus `encode()` to bytes]
    # Unicode is a character-set; UTF-8 is an encoding.   
    # Unicode Charset;   char =>  int  [glyph to CODE-POINTS]
    # UTF-8   Encoding;  int  =>  bin  [CODE-POINTS to bytes]
    # [UTF-8 is *the* universally accepted encoding for all Unicode Charsets.]  
    # ASCII to Unicode Evolution:  https://nedbatchelder.com/text/unipain.html
    # HTML UTF-8  https://www.w3schools.com/charsets/ref_html_utf8.asp
    
    # SANDWICHED UNICODE [strategy]: bytes on the outside, Unicode on the inside.
      # Data into and out of script must be [serialized] in bytes, but script doesn't need bytes. So, DECODE incoming bytes to Unicode [as soon as possible]; use Unicode throughout script; then ENCODE any output [to bytes, per utf-8].
    
      str = 'foo bar'  # bytes
      # encode; Unicode TO bytes 
        str.encode('utf-8')    # =>  'foo bar'
      # decode; bytes TO Unicode 
        str.decode('utf-8')    # => u'foo bar'
        unicode(str, 'utf-8')  # => u'foo bar'
        
      str = u'foo bar \u2627'    # => u'foo bar \u2627'
      str = str.encode('utf-8')  # => 'foo bar \xe2\x98\xa7'
      print str                  # => foo bar ☧
      str = str.decode('utf-8')  # => u'foo bar \u2627'

    # 'ascii','xmlcharrefreplace' [Unicode to HTML ENTITY]
    str.encode('ascii','xmlcharrefreplace')  # => 'foo bar &#9767;'
    
    # 'ascii','ignore' [removes what can't be decoded] 
    str = u'foo bar \u9999'       # if bogus code-points
    str.encode('utf-8','ignore')  # => 'foo bar '
    str.encode('utf-8')           # => 'foo bar \xe9\xa6\x99'
    str.decode('ascii','ignore')  # => u'foo bar '      
      
    # implicit conversions per default; Python 3 does NOT [cuz painful if mixed encodings]
    import sys 
    sys.getdefaultencoding()      # 'ascii'

    # access to Unicode Character Database (UCD)
    import unicodedata as u               
      u.category(u'a')                    # => 'Ll'  # L:letter, l:lowercase
      u.name(u'a')                        # => 'LATIN SMALL LETTER A'
      print u'\u00ae',u.name(u'\u00ae')   # => ® REGISTERED SIGN    
      u.lookup('BLACK SPADE SUIT')        # => u'\u2660'
      print u.lookup('BLACK SPADE SUIT')  # => ♠

    # STR TESTs [True or False]
      'Hello' in 'Hello World'       # => True 
      'cats' not in 'cats and dogs'  # => False
      
      str.isalpha(); str.isalnum(); str.isdecimal(); str.istitle()
      str.startswith('This '); str.endswith('Fin.')
      
      'FOo'.isupper()                # => False 
      'foo'.islower()                # => True
      ' \t \n '.isspace()            # => True
      
    # OUTPUT [FORMAT] :: `print `...
    # STRING INTERPOLATION 4 ways to FORMAT 
    %-formatting; str.format(); Template(); f'This format'
    
      apples = 4
      # Python; all versions
      print "I have %d apples" % apples            # old way; no longer recommended
      print "I have %(apples)d apples" % locals() 
      # Python 2.6+
      print "I have {0} apples".format(apples)     # new way
      print "I have {a} apples".format(a=apples)
      # Python 2.7+
      print "I have {} apples".format(apples)
      # Python 3.6+
      print(f"I have {apples} apples")            # "f-string"

        # %-formatting [old way] ; substitute tuple/dict values
        str % tup  
          "The %s is a %d" % ('foo', 33)                    # 'The foo is a 33'
        str % dict
          "The %(k1)s is a %(k2)d" % {'k1':'foo', 'k2':33}  # 'The foo is a 33'
          # %d:int, %s:str, %f/%g:float
        
        # `format()` [new way]
        str.format(args)
        "The {} is a {}".format("foo", 33)            # 'The foo is a 33'
        "The {0} is a {1}.".format("foo", 33)         # 'The foo is a 33'
        "The {k1} is a {k2}".format(k1="foo", k2=33)  # 'The foo is a 33'
        
        for x in range(1,11):  # write a table of squares and cubes
          '{0:2d} {1:3d} {2:4d}'.format(x, x*x, x*x*x) 

        # Template() method
          from string import Template
          str = Template('$who likes $what')
          str.safe_substitute(who='tim', what='kung pao')  # => 'tim likes kung pao'

      repr(objFoo)  # str containing printable representation of object
      str(objFoo)   # same, but not eval() compatible 
      str.rjust(n)  # right-justify str
      
    # ... NOTE on all above, prepend w/ `print ` for STDOUT 
    
  # INT/FLOAT
    3         # => 3
    1 + 1     # => 2
    8 - 1     # => 7
    
    10 * 2    # => 20
    2.5 * 2   # => 5.0    infers/sets type float
    
    5 / 2     # => 2      infers/sets type int
    5.0 / 2   # => 2.5    infers/sets type float
    
    5 // 2    # => 2      integer [floored] div operator
    5.0 // 2  # => 2.0    integer [floored] div operator

    from __future__ import division  # allows normal [float] division
    
    5 / 2     # => 2.5
    5 // 2    # => 2.0
    
    7 % 3        # => 1   Modulo

    2 ** 4       # => 16  Exponentiation [X to the Yth power]

    (1 + 3) * 2  # => 8   enforce precedence per parens 

    in, not in, is, is not, <, <=, >, >=, !=, ==
    
    True and False  # => False
    False or True   # => True  
    2 and True      # => True  
    0 and 2         # => 0  [int]
    -5 or 0         # => -5 [int]
    not True        # => False
    not False       # => True  
    0 == False      # => True  
    1 == True       # => True  
    2 == True       # => False 
    1 == 1          # => True
    2 == 1          # => False  
    1 != 1          # => False
    2 != 1          # => True
    1 < 10          # => True
    1 > 10          # => False
    2 <= 2          # => True
    2 >= 2          # => True  
    1 < 2 < 3       # => True  [boolean]  chainable !!!


# ARRAYs
  # Python has NO native ARRAY DATATYPE, but Python's 
  # Standard Library has `array` module; 'Efficient arrays of numeric values'
    # Arrays are sequence types and behave very much like lists, 
    # except that the type of objects stored in them is constrained. 
  # https://docs.python.org/2/library/array.html
  # Also, see 'NumPy' pkg  https://pypi.python.org/pypi/numpy  http://www.numpy.org

    class array.array(typecode[, initializer])
    # Type-codes: 'c', 'b', 'B', 'u' , 'h', 'H', 'i', 'I',  'l', 'L', 'f', 'd'

    import array
    arr = array.array('i',[1,2,3,4])  # array of integers; initialized with values

 
# COMPOUND DATA TYPES  https://en.wikiversity.org/wiki/Python_Programming/Tuples_and_Sets

  # DATATYPE                               # MUTABLE  ORDERED  UNIQUE  FOR/IN  ACCESS
    list  = [1, 1, 1]                      #    X        X                X     index
    tuple = (1, 1, 1)                      #             X                X     index
    dict  = {1: 'one', 1: 'one', 1: 'one'} #    X                 X       X     key
    set   = {1, 1, 1}                      #                      X       X     --

    # Note UNIQUE elements RESTRICTION @ `dict` and `set`, 
    # so, declare/assign statements above INTERPRET to: 
      dict # => {1: 'one'}
      set  # => set([1])
    # unlike `list` and `tuple`; both keep all elements [3] assigned per statement

    # SET and DICT are hashtables; VERY FAST lookups, O(1), 
    # so PREFERable to lists, O(n), when large/repeatable-searches etc
    # https://stackoverflow.com/questions/513882/python-list-vs-dict-for-look-up-table

    # LOGIC @ setting VALUEs
      foo = {'a':1,'b':2}
      zoo = {'c':3}
      dict = {'AND': foo and zoo, 'OR': foo or zoo,} 
        # => {'AND': {'c': 3}, 'OR': {'a': 1, 'b': 2}}
      list = [foo and zoo, foo or zoo] 
        # => [{'c': 3}, {'a': 1, 'b': 2}]
      tupl = (foo and zoo, foo or zoo)
        # => ({'c': 3}, {'a': 1, 'b': 2})

  # function to create [useless?]
    list(), dict(), tuple(), set()

  # TEST for TYPE 
    isinstance({}, dict)  # => True

  # METHODS on such datatypes, @ Python3+, TRACK CHANGES in their parent 
    # E.g.,
    dict = {'one':1, 'two':2}
    keys = dict.keys()
    dict['three'] = 3
    keys  # => dict_keys(['one', 'two', 'three'])


  # LIST  `[]`
    # mutable, ordered sequence
    # https://docs.python.org/2.7/tutorial/introduction.html#lists
    # https://developers.google.com/edu/python/lists
    
    # create list `li`
    li0 = []       # => []
    li  = [1,2,3]  # => [1, 2, 3]
            
      # access 
        li[-2]     # => 2
        li[1]      # => 2
        
    # create nested list `x` [list of lists]
    a = ['a', 'b', 'c']
    x = [a, li]    # [['a', 'b', 'c'], [1, 2, 3]]

    # LIST COMPREHENSIONs  
    #   https://docs.python.org/2/tutorial/datastructures.html#list-comprehensions
    #   comprehensions a concise way to create list/set/dict.
    
      [x**2 for x in range(6)]       # => [0, 1, 4, 9, 16, 25]
      map(lambda x: x**2, range(6))  # equivalent; less readable; 
      # though "preferred" per docs.python-guide.org 

      # access 
        x          # => [['a', 'b', 'c'], [1, 2, 3]]
        x[0]       # => ['a', 'b', 'c']
        x[0][1]    # => 'b'
        x[1][1]    # => 2

    # process; non-mutating
    filter(), map(), and reduce() # all take args: `(function, sequence)`
    map(lambda x: x**2, range(6)) # E.g., list of squares per map/lambda @ range
    
    len(li)                # length of list [number of items therein]
    li.index(item)         # index of 1st instance of `item`
    li1 + li2              # concat; vars unmodified
    1 in li                # => True
    if item in li:         # conditionally do if `item` is in list
      do_stuff()

    # sorting
      sorted(li)             # returns `li` sorted; does NOT mutate `li`
      sorted(li,key=fooFunc) # `key=` invokes a func; xform each item, pre-sort
        # E.g., sort list by item-length
        strs = ['ccc', 'aaaa', 'd', 'bb']
        sorted(strs, key=len)  # ['d', 'bb', 'ccc', 'aaaa']
                               # applied built-in `len()` func on each pre-sorted 
                               # item, so, sorted list by item-length; 
                               # `strs` list is NOT mutated.

        # E.g., sort list by items' last letter.
        strs = ['xc', 'zb', 'yd' ,'wa']
        def cL(s):            # define the key function; it takes 1 str arg,
          return s[-1]        # and returns its last char. Now use @ sorted() ...
        sorted(strs, key=cL)  # ['wa', 'zb', 'xc', 'yd']
    
    # process; mutating
    
      # slice syntax 
      
      li[start:stop:step]
      li[::step]     # step as a filter
      li[::-1]       # reverse
      
      li  = [1,2,3]  # => [1, 2, 3]
      li[1:3]        # => [2, 3]
      li[0:2] = 'z'  # => ['z', 3]  # replace 2 items w/ 1 value
      
      # methods [on list object]

      del li[index]          # del item at `index` [does NOT return item]
      li.pop(index)          # remove and return item at `index`
      li.pop()               # remove and return rightmost item  
      li.append(item)        # append `item` to `li`
      li.insert(here, item)  # insert `item` @ index `here`
      li1.extend(li2)        # concat; mutates `li1`, NOT `li2`
      li.remove(item)        # remove 1st instance of `item`
      li.sort()              # sort; mutates `li` [does NOT return it]
      li.reverse()           # reverse; mutates `li` [does NOT return it]

  # TUPLE  `()`
    # immutable, ordered sequence; 
    # https://docs.python.org/2/tutorial/datastructures.html#tuples-and-sequences
  
    tup = ()          # empty tuple
    tup = (1, 2, 3)
    tup = 1, 2, 3     # equivalent
    tup = ('foo',)    # singleton aka "size-1 tuple"
    len(tup)          # => 1
      
      tup = ('foo')  # NO; sans comma creates a string, not a tuple
      len(tup)       # => 3
    
    # TUPLE COMPREHENSIONs; per Tuple() [Generator]
    tuple(x**2 for x in range(6))  # => (0, 1, 4, 9, 16, 25)
    
    # STR TO TUPLE 
      str = 'foo bar baz'
      tup = str.split(' ')  # => ['foo', 'bar', 'baz']

    # TUPLE to STR
      ', '.join(tup)        # => 'foo, bar, baz'
      
  # LISTs || TUPLEs
  #  all list operations okay for tuples, 
  #  except the ones that would mutate it.
  
    # UNPACK argument LIST||TUP into vars
    a, b, c = tup
    
    # swap two vars 
    b,c = c,b
    b # => 3
    c # => 2

  # DICT  `{}`
    # mutable, unordered, unique `key:value` HASH TABLE STRUCTURE
    # a mapping; an indexed object; JSON-esque
    # https://docs.python.org/2/tutorial/datastructures.html#dictionaries
    
    # create 
      dict = {}
      dict = {key1:value1, key2:value2, ... }
      dict = {"one": 1, "two": 2, "three": 3}

    # DICT COMPREHENSIONs
      {x: x**2 for x in range(2,8,2)}  # => {2: 4, 4: 16, 6: 36}

    # modify
      dict["two"] = 'haha'  # reset value of existing key
      dict["four"] = 4      # add new key:value pair
      del dict[thisKey]     # delete `thisKey`

      setdefault() # inserts ONLY IF a new key
      dict.setdefault("zz", 'top')  # {'three': 3, 'two': 2, 'zz': 'top', 'one': 1}
      dict.setdefault("zz", 99)     # {'three': 3, 'two': 2, 'zz': 'top', 'one': 1}

    # TEST existence of KEY
      "one" in dict  # => True
      1 in dict      # => False
 
    # SHOW KEYs or VALUEs
      dict['two']    # => 2; access value per key
      dict.keys()    # => ['three', 'two', 'one'] #  equiv.
      dict.values()  # => [3, 2, 1]
      dict.items()   # => [("one", 1), ("two", 2), ("three", 3)]
      # Python 3+
      [*dict]        # => ['one', 'two', 'three']

    # .get(key [,default-value])
      dict.get("one")    # => 1
      dict.get("bogus")  # => None  [avoids KeyError if key not exist]
        dict["bogus"]    # => ... `KeyError: 'bogus'`
      
      # result is the default-value arg when the key is missing
      dict.get("one", 4)    # => 1
      dict.get("bogus", 4)  # => 4

    # CONVERT dict to LIST or SET
      set(dict)      # => set(['one', 'three', 'two'])
      list(dict)     # => ['three', 'two', 'one']  
      dict.items()   # => [("one", 1), ("two", 2), ("three", 3)]

    # CONVERT dict to JSON [dict <=> json-Unicode-formatted-string]
      import json
      jsn1 = json.dumps(dct1)  # => '{"one": 1, "three": 3, "two": 2}'
      dct1 = json.loads(jsn1)  # => {u'three': 3, u'two': 2, u'one': 1}
    
    # ANY OBJECT; view its JSON representation 
    json.dumps(obj) # list/tuple/dict 
    
    # PICKLE; Contrary to JSON, pickle is a protocol which allows the serialization of arbitrarily complex Python objects; it is specific to Python and cannot be used to communicate with applications written in other languages.

  # SET   `{}` or `set()`
    # immutable, unordered, unique 
    # https://docs.python.org/2/tutorial/datastructures.html#sets

    set([1,2,3,4,'foo',1,1,2,4,'foo',5,3])  # => set([1, 2, 3, 4, 5, 'foo'])

    a = set('abracadabra') # unique letters
    b = set('alacazam')    # unique letters
    a & b                  # in both a AND b; intersection of sets
    a | b                  # in a OR b; union of sets 
    a - b                  # in a, but NOT in b
    a ^ b                  # in a or b, but NOT both; XOR

    # SET COMPREHENSIONs
      {x for x in 'abracadabra' if x not in 'abc'}  # => set(['r', 'd']) 

    # convert SET to LIST 
    [x for x in setFoo]
    

# STRUCT module
  # Interpret strings as packed binary data; conversions between Python values and C structs represented as Python strings.
  # https://docs.python.org/2/library/struct.html?highlight=struct#module-struct  
  # FORMAT CHARs  https://docs.python.org/2/library/struct.html?highlight=struct#format-characters
  # Examples:  https://pymotw.com/2/struct/
  
  import struct
  s = struct.pack('hh', 1, 2)    # => '\x01\x00\x02\x00'
  struct.unpack('hh',s)          # => (1, 2)
  struct.calcsize('hh')          # => 4
  
  # CREATE STRUCT OBJECT [ONCE]
  # Then process it. [Creating struct is a resource hog.]
  import struct
  import binascii
  values = (1, 'ab', 2.7)             # => (1, 'ab', 2.7)
  s = struct.Struct('I 2s f')         # <Struct object at 0x6ffffe705e0>
  s.format                            # => 'I 2s f'  # [3 els; int, 2-char-str, float]
  s.size                              # => 12
  packed = s.pack(*values)            # => '\x01\x00\x00\x00ab\x00\x00\xcd\xcc,@'
  s.unpack(packed)                    # => (1, 'ab', 2.700000047683716)  # NOTE digits
  
  pkval = binascii.hexlify(packed)    # => '0100000061620000cdcc2c40'
  packed = binascii.unhexlify(pkval)  # => '\x01\x00\x00\x00ab\x00\x00\xcd\xcc,@'

  
# FLOW CONTROL
  # https://docs.python.org/2/tutorial/controlflow.html
  
    # PASS 
      # does nothing; placeholder to avoid err
      def someToDoFunc(*args):
        pass # ToDo; build out this function
    
    # IN [not in]
      li  = [1,2,3]
      tup = (1,2,3)
      dict = {'_1':1,'_2':2,'_3':3}
      2 in li       # => True
      2 in tup      # => True
      2 in dict     # => False
      _2 in dict    # => NameError: name '_2' is not defined
      '_2' in dict  # => True

    # IS [is not]
      # IDENTITY, NOT equality
        spam = "Hello!"
        eggs = "Hello!"
        spam is eggs     # => False
        eggs = spam 
        spam is eggs     # => True

 
  # COMPOUND STATEMENTS 
    # `suite` is a Py-Docs term for group of statements controlled by a clause
    if x < y < z: print x; print y; print z  # suite
    # https://docs.python.org/2/reference/compound_stmts.html

    # TRY [EXCEPT/ELSE/FINALLY]  
      # specifies exception handlers and/or cleanup code for a group of statements
      try:
          print("pop")
          assert x == 0  # used for testing; throws exception if false
        except:
          print("An error has occurred!")
        else:
          print("Everything went smoothly!")
        finally:
          print("Finishing up now...")
    
    # WITH/AS  
      # used to wrap a block w/ methods defined by a CONTEXT MANAGER   
      with A() as a:
        with B() as b:
          if x < y < z: print x; print y; print z  # suite

    # ITERATORs

      # FOR/IN [ELSE/CONTINUE/BREAK]
      for target_list in expression_list : suite
      [else: suite]
      
      for berry in (1, 2, 3, 4, 5, 6, 7, 8):
        if berry % 4 == 0:
          continue
        print(berry)
        if berry % 9 == 0:
          break
      else:
        print("Conditions did NOT trigger `break`")  
    
      foo = [0,-2,3,-4]
      for p,c in zip(range(len(foo)), foo):
        print ('a[{}] = {}'. format(p,c))
      # =>
      a[0] = 0
      a[2] = -2
      a[3] = 3
      a[4] = -4
    
      for x in someThing:
        do_stuff(x)
        
        # @ lists
        for item in list:
          traverse_list(item)  # iterates per item in list; do NOT mutate list herein
        
        # @ strings 
        for ch in str:
          print ch             # iterates per character in string

        # @ dict 
        for key in sorted(dict.keys()):
          print key, dict[key] # iterates per key in dict, sorted per keyname

        for k, v in dict.iteritems():  # [('three', 3), ('two', 2), ('one', 1)]
          print k, ':', v      # iterates per tuple in `dict.items()` list, 
                               # one (key, value) pair per iteration
        
          # create list from dict; iterate thru all functions in a module
          [name for name, val in modName.__dict__.iteritems() if callable(val)]
          
        # range(); xrange()
        for i in range(5):
          print i              # iterates/prints '0' thru '4' [each with '\n']
        
      # WHILE [BREAK/CONTINUE]
        i = 0
        while i < 33:
          if i == 27:
            break     # end `while` block here and now
          i = i + 3
          if i == 15: 
            continue  # next iteration now; below is NOT executed THIS iteration 
          print i
        

      # IF [ELIF/ELSE] 
        x = int(raw_input(" Enter: "))
        
        if x < 0:
             x = 0
             print 'Negative changed to zero'
         elif x == 0:
             print 'Zero'
         elif x == 1:
             print 'Single'
         else:
             print 'More'
      
      # SWITCH/CASE [Does NOT EXIST in Python] 
        # Equivalent per func+dict 
      
        # case [func] blocks
        def zero():
            print "You typed zero.\n"

        def sqr():
            print "n is a perfect square\n"

        def prime():
            print "n is a prime number\n"  
            
        # case per dif    
        options = {0 : zero,
                   1 : sqr,
                   9 : sqr,
                   3 : prime,
                   5 : prime,
        }
        # switch per x
        options[x]()


# FUNCTIONs
  # https://docs.python.org/2/tutorial/controlflow.html#defining-functions
  # funcs w/OUT return return: None

  # `def` keyword
  def repeat(s, exclaim):
    result = s * 3 
    if exclaim:
      result = result + '!!!'
      
    global x, y   
    x = 2; y = 3   # globals
    return result
    
      #run ...
      repeat('foo ', 0)  # => 'foo foo foo '
      repeat('foo ', 1)  # => 'foo foo foo !!!'

  # Standard boilerplate @ bottom of module
  # calls `main()` unless it [module/script] is imported by another module.
  if __name__ == '__main__':
      main() # convention is to name THE function of the script `main`

  sys.argv     # list, `[...]`, of command-line args 
  sys.argv[0]  # module name 
  
  # OPTIONAL ARGs [Variable Number of Arguments]

    import sys
    def foo(args):
        print args  # script name + all args; primitives, lists, tups, dicts

    if __name__ == '__main__':   
      foo(sys.argv)
  
    # or use defaults [evaluated only once; see below]
    def foo(bar, baz=44):
      ...
      
    # Note that default[s] are evaluated only ONCE !!!
    # DO NOT USE mutables as defaults
    def foo(a, L=[]):
      L.append(a)
      return L

    foo(1)  # => [1]
    foo(2)  # => [1, 2]
    foo(3)  # => [1, 2, 3]
    
    # INSTEAD [but same result here] ...
    def function(x, L=None): 
        if L is None: L = []
    
  # KEYWORD ARGs 
    def foo(a,key1=1,key2=2):
      ... 
    foo(1,key1=11, key2=12)
  
  # PASS/receive ARBITRARY NUMBER of ARGs [LIST/TUPLE/DICT]
  # *args, **kwargs 
  
    # neither packed @ func def nor unpacked @ func call
      def foo(args, kwargs):
        print args          # tup
        print kwargs        # dict
        
        for a in args:
          print a           # tup
        
        for k, v in kwargs.items():
          print k, ':', v   # dict

        for k, v in kwargs.iteritems(): # BETTER [@ 2.x ONLY]; uses generator
          print k, ':', v   # dict
          
      tup = [1,2,3]
      dict = {'a': 1, 'b':2}
      
      foo(tup,dict) # =>
      
        [1, 2, 3]
        {'a': 1, 'b': 2}
        1
        2
        3
        a : 1
        b : 2
  
    # PACK @ function DEFINITION, `def foo(*args, **kwargs)`
      def foo(*args, **kwargs):
          print args    # ('1', '2', '3')
          print kwargs  # {'_5': '5', '_4': '4'}

      foo('1','2','3', _4='4', _5='5') 
      
        # ARGs ORDER must be: primitives, *tuples, **keywords
        def foo(a, b=3, *args, **kwargs): 
          ...
          
        foo(x)                # a=x, b=3, args=(), kwargs={}
        foo(x, y)             # a=x, b=y, args=(), kwargs={}
        foo(x, b=y)           # a=x, b=y, args=(), kwargs={}
        foo(x, y, z, k)       # a=x, b=y, args=(z, k), kwargs={}
        foo(x, c=y, d=k)      # a=x, b=3, args=(), kwargs={'c': y, 'd': k}
        foo(x, c=y, b=z, d=k) # a=x, b=z, args=(), kwargs={'c': y, 'd': k}

        def foo(arg, *tup, **kwarg): 
          print '    arg: ', arg    # primitive
          print '   *tup: ', tup    # tuple
          print '**kwarg: ', kwarg  # dict

        foo(1, 2, 3, _4=4, _5=5)

  # UNPACK @ function CALL, `foo(*tup, **dict)`
    def foo(a, b, c, _4='', _5=''): # okay if dict has too few args
      print a, b, c, _4, _5

    tup = (1,2,3)
    dict = { '_4':4, '_5':5 }
    
    foo(*tup, **dict)  # unpack list/tuple/dict @ call

    
  # BUILT-IN FUNCTIONS
  # https://docs.python.org/2/library/functions.html  
    dir(__builtins__) # list them all
    
    # `zip()` 
    x = [1, 2, 3, 4, 5, 6, 7, 8]
    y = ['a', 'b', 'c']
    zip(x,y)  # => [(1, 'a'), (2, 'b'), (3, 'c')]


# GENERATORS
# a simple and powerful tool for creating iterators
# https://docs.python.org/2/tutorial/classes.html#generators
  
  def reverse(data):    # resume per iteration/char/call 
    for index in range(len(data)-1, -1, -1):
      yield data[index] # return per iteration/char/call 

  for char in reverse('golf'): # call passes entire string, 
    print char                 # but generator process one char per call
    # => ... one char per call ...
    f
    l
    o
    g

    
# LAMBDA EXPRESSION [Anonymous Function]
  lambda a, b: a+b  # can be returned from a function

  
# OOP
  # https://python.swaroopch.com/oop.html
  # DEFINE the class ...
  class Person:
      def __init__(self, name):  # `self` extra param MUST be first; IGNORED on call 
          self.name = name

      def say_hi(self):
          print('Hello, my name is', self.name)

  # USE the class ...
  p = Person('Swaroop')
  p.say_hi()
  self.__class__.say_hi()  # internal equiv 

# DECORATOR
  # A function that accepts another function as its argument; wrapper
  # https://www.blog.pythonlibrary.org/2017/07/18/python-all-about-decorators/

  # Decorator SYNTAX
  @fooDecorator
  def someFunc():
    ...

  # then the call ...
  someFunc() # => calls fooDecorator(someFunc())


# I/O 

  # get data from stdin; returns data as a string, unless wrapped
  guess = int(raw_input("Guess Integer: ")) # input must be integer

  # input CODE [do NOT use]; EVALUATES the data as Python code
  input_var = input("Enter some data: ")  
  
  # output 
  import sys
  sys.stdout.write('This is standard out.\n')
  sys.stderr.write('Warning, log file not found starting a new one\n')

  print "fo,o';bar:ok!"     # => fo,o';bar:ok!
  print 'c:\zoo\\bar'       # => c:\zoo\bar    [escaped]
  print r'c:\zoo\\bar'      # => c:\zoo\\bar   [raw]
  print u'c:\zoo\u005cbar'  # => c:\zoo\bar    [Unicode]

# HTML UTF-8  https://www.w3schools.com/charsets/ref_html_utf8.asp
  # Unicode is a character-set; UTF-8 is an encoding.
    # Unicode; char => num  https://en.wikipedia.org/wiki/Unicode
    # UTF-8;   num  => bin  https://en.wikipedia.org/wiki/UTF-8
    # [ Unicode Transformation Format [UTF] ]  
  
    # UTF-8; Unicode [Latin Suplemental]  
    print u'\u00b5\t&micro;'  # => µ       &micro;
    print u'\u00a9\t&copy;'   # => ©       &copy;
    # UTF-8; Unicode [Letterlike Symbols]
    print u'\u2014\t&mdash;'  # => —       &mdash;
    print u'\u2022\t&bull;'   # => •       &bull;
    print u'\u2026\t&hellip;' # => …       &hellip;
    # UTF-8; Unicode [Misc Symbols]
    print u'\u2627' # => ☧       CHI RHO
    print u'\u2629' # => ☩       CROSS OFJERUSALEM
    # UTF-8; Unicode [Dingbats]
    print u'\u271d' # => ✝       LATIN CROSS
 
 
# FILE HANDLING 

  open()                 # open and return a file handle
  f = open(name, mode) # open file `name` into var `f`
  # modes are r/w/a/rU <=> read/write/append/Universal 
  # 'rU' for text files; smart converting per line-ending conventions; maps all to `\n`.
  # The for/in loop is effective for text files; iterates per line
  # efficient; reads one line [at a time] into memory [not the whole file]
  
    # Echo the contents of `foo.txt`
    f = open('foo.txt', 'rU')
    for line in f:   # iterates over the lines of the file
      print line,    # use trailing `,` so print does not add an end-of-line char
                     # since `line` already includes the end-of line.
    f.close() 
    
    # OR, per https://iluxonchik.github.io/why-you-should-learn-python/
    with open('foo.txt') as f:
    for line in f:
        print(line)

  f.readlines() # reads the whole file into memory; returns list [item per line]. 
  f.read()      # reads the whole file into a single string [handy for RegExp].

  f.write(string) # best way to write data to an open output file; supports Unicode. 
  print >> f, string # works too, but nasty syntax; does NOT support Unicode.
  
  # Unicode 
    import codecs  # support for reading Unicode file
    f = codecs.open('foo.txt', 'rU', 'utf-8')
    for line in f:
      # here `line` is a *unicode* string 
      f.write(...)
    f.close() 

    
# REGULAR EXPRESSIONS 
  import re
  match = re.search(pat, str)
  
  str = 'an example word:cat!!'
  match = re.search(r'word:\w\w\w', str)

  # If-statement after search() tests if it succeeded
  if match:                      
  print 'found', match.group() # 'found word:cat'
  else:
  print 'did not find'  
  
  # basic patterns/examples
  # https://developers.google.com/edu/python/regular-expressions
  
  findall() # finds *all* the matches and returns them as a list of strings
  
    # Suppose we have a text with many email addresses
    str = 'purple alice@google.com, blah monkey bob@abc.com blah dishwasher'

    # Here `re.findall()` returns a list of all the found email strings
    emails = re.findall(r'[\w\.-]+@[\w\.-]+', str) # ['alice@google.com', 'bob@abc.com']
    for email in emails:
    # do something with each found email string
    print email  
    
  # findall() With Files
  # Instead of FOR/IN loop, just feed the whole file text, per `f.read()`, into findall(), and let it return list of all matches in one step.

    f = open('test.txt', 'r')  # open file
    matches = re.findall(r'some pattern', f.read())

    
# OS/FILE-SYSTEM  https://docs.python.org/2/library/os.html

  # See 'RUN shell COMMAND/SCRIPT from Python interpreter', above @ META
  import subprocess  # newer; replaces: 
    os.system, os.spawn*, os.popen*, popen2.*, commands.*
    # https://docs.python.org/2/library/subprocess.html#using-the-subprocess-module    

  import os          # operating system interfaces
  import os.path     # filesystem sub-module [functions] 
  import shutil      # copy files 

  os.getcwd()                     # Return the current working dir; 'C:\\Python27'
  os.chdir('/server/accesslogs')  # Change current working directory
  os.system('mkdir foo')          # Run system shell command `mkdir foo` 
  
  # list files in dir
    from os.listdir

    for f in os.listdir('.'):
        print('Processing {} file...'.format(f))  
  
  # list files in dir; prints rel,abs paths
    import os
    dir = '/home/USERNAME/etc'
    def printdir(dir):
      filenames = os.listdir(dir)
      for filename in filenames:
        print filename  # foo.txt
        print os.path.join(dir, filename) # dir/foo.txt (relative to current dir)
        print os.path.abspath(os.path.join(dir, filename)) # /home/nick/dir/foo.txt  
        
    printdir(dir) # run it

  # Env. Vars. [dict]; sort/print all; key-val pairs
  for k,v in sorted(os.environ.items()):
    print k + '=' + v


# CLIPBOARD [Win/Mac/Linux]  https://github.com/asweigart/pyperclip

  import os, pyperclip
  strToClipboard = 'Send this to clipboard'  
  pyperclip.copy(strToClipboard)  # put
  retrieved = pyperclip.paste()   # get
  
  # @ Cygwin/Linux
    if os.environ.has_key('_root_install'):  # @ Cygwin
      cmd = 'echo ' + strToClipboard + ' > /dev/clipboard'
      os.system(cmd)
    else:                                    # @ Linux
      pyperclip.copy(strToClipboard)


# HTTP 
  import urlib, urlparse
  # Given a url, try to retrieve it. If it's text/html,
  # print its base url and its text.
  def wget(url):
    ufile = urllib.urlopen(url)  # get file-like object for url
    info = ufile.info()   # meta-info about the url content
    if info.gettype() == 'text/html':
      print 'base url:' + ufile.geturl()
      text = ufile.read()  # read all its text
      print text  
      
  # Version that uses try/except to print an error message if the
  # urlopen() fails.
  def wget2(url):
    try:
      ufile = urllib.urlopen(url)
      if ufile.info().gettype() == 'text/html':
        print ufile.read()
    except IOError:
      print 'problem reading url:', url      
  