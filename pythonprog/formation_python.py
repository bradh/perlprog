'''
Created on 10 mai 2018

@author: stephane
'''
import sys
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




