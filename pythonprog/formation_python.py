'''
Created on 10 mai 2018

@author: stephane
'''
import sys
from pip._vendor.progress.bar import FillingSquaresBar
def fibo (n):
    result = []
    a,b = 0,1
    while a<n:
        print (b)
        a,b = b, a+b
        result.append(a)
        
    return result

def ask_ok(prompt, retries=4, reminder='Please try again!'):
    while True:
        ok = input(prompt)
        if ok in ('y', 'ye', 'yes'):
            return True
        if ok in ('n', 'no', 'nop', 'nope'):
            return False
        retries = retries - 1
        if retries < 0:
            raise ValueError('invalid user response')
        print(reminder)

a, b = 1,2
while b< 10 :
    print b, a
    a,b = b, a+b 
    
word = [ 'cat', 'dog', 'gold fish']
for w in word:
    print w, len(w)
    

for i in range(len(word)):
    print i, word[i]

for i in range(5):
    print i

list(range(len(word)))

print (fibo(10))

#ask_ok('voulez-vous quitter ?')

action = 'toto'
#print("-- This parrot wouldn't", action, end=' ')
# funcction with named parameters
def parrot(voltage, state='a stiff', action='voom', type='Norwegian Blue'):
    print"-- This parrot wouldn't", action
    print"if you put", voltage, "volts through it."
    print"-- Lovely plumage, the", type
    print"-- It's", state, "!"
#function anonymous
def make_incrementor(n):
     return lambda x: x + n

f = make_incrementor(42)
print f(0)

print f(1)

parrot(voltage = 6, state = "toto")
'''
def f(ham: str, eggs: str = 'eggs') -> str:
     print("Annotations:", f.__annotations__)
     print("Arguments:", ham, eggs)
     return ham + ' and ' + eggs
f('spam')
Annotations: {'ham': <class 'str'>, 'return': <class 'str'>, 'eggs': <class 'str'>}
Arguments: spam eggs
'spam and eggs'

'''
print "Gestion des listes\n"

fruits = ['orange', 'apple', 'pear', 'banana', 'kiwi', 'apple', 'banana']
print fruits.count('apple')

print fruits.count('tangerine')

print fruits.index('banana')

print fruits.index('banana', 4)  # Find next banana starting a position 4

fruits.reverse()
print fruits
fruits.append('grape')
print fruits
fruits.sort()
print fruits

fruits.pop()

# Queues
from collections import deque
queue = deque(["Eric", "John", "Michael"])
queue.append("Terry")           # Terry arrives
queue.append("Graham")          # Graham arrives
print queue.popleft()                 # The first to arrive now leaves
print queue.popleft()                 # The second to arrive now leaves

print queue                           # Remaining queue in order of arrival

squares = [x**2 for x in range(100)]
print squares 

# comprhention de liste
print [(x, y) for x in [1,2,3] for y in [3,1,4] if x != y]

vec = [-4, -2, 0, 2, 4]
# create a new list with the values doubled
print [x*2 for x in vec]

matrix = [
    [1, 2, 3, 4],
    [5, 6, 7, 8],
    [9, 10, 11, 12],
]
print [[row[i] for row in matrix] for i in range(4)]

print list(zip(*matrix))

#tuples
empty = ()
singleton = 'hello',    # <-- note trailing comma
print len(empty)
print len(singleton)
1
print singleton

#ensemble
basket = {'apple', 'orange', 'apple', 'pear', 'orange', 'banana'}
print(basket)                      # show that duplicates have been removed
print 'orange' in basket                 # fast membership testing
print 'crabgrass' in basket

# Demonstrate set operations on unique letters from two words

a = set('abracadabra')
b = set('alacazam')
print a                                  # unique letters in a
print a - b                              # letters in a but not in b
print a | b                              # letters in either a or b
print a & b                              # letters in both a and b
print a ^ b                              # letters in a or b but not both

# boucle dictionnaire
knights = {'gallahad': 'the pure', 'robin': 'the brave'}
for k, v in knights.items():
     print k, v
for i, v in enumerate(['tic', 'tac', 'toe']):
     print i, v
     
import math
raw_data = [56.2, float('NaN'), 51.7, 55.3, 52.5, float('NaN'), 47.8]
filtered_data = []
for value in raw_data:
     if not math.isnan(value):
         filtered_data.append(value)

print filtered_data
# affichage
table = {'Sjoerd': 4127, 'Jack': 4098, 'Dcab': 7678}
for name, phone in table.items():
    print('{0:10} ==> {1:10d}'.format(name, phone))

# file
with open('formation_python.py') as f:
     read_data = f.read()
     print read_data
f.closed


