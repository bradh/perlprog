
'''
Created on 8 mai 2018

@author: stephane
'''

x = 1.0/3.0
y = 1.0/4.0
s = 'the value of x,y is roughly %(x).4f,%(y).4f' % vars()
print s


s1 = "new string"          # change to new string
                            # substitute newlines with the text "[newline]"
s2 = s1.replace("new", "old")
s2 = s2[:3]

print s1
print s2

filename = "first_test.py"
f = open(filename) # Python has exceptions with somewhat-easy to
                    # understand error messages. If the file could
                    # not be opened, it would say "No such file or
                    # directory: %filename" which is as
                    # understandable as "can't open $filename:"
lines = f.readlines()
print lines

import fileinput
for line in fileinput.input(filename):
    print line
    
for line in open(filename):
    print line
    
import sys
for fname in sys.argv[1:]
    for line in open(fname):
        print line