import sys
import re

lines = []
input_file = sys.argv[1]
try:
    first = int(sys.argv[2])
except:
    first = 0
with open(input_file, 'r') as filename:
    for line in filename:
        lines.append(line)

y = re.compile(r"\\hypertarget\{(\w*:\w*)\}")

for (num,line) in enumerate(lines, 1):
    for i in y.findall(line):
        if num > first:
            print(num, i, end='\n')
