import sys
import re

with open("state","r") as data:
    data = data.readlines()

input_file = data[0].strip() + ".tex"

with open("state_num","r") as data:
    data = data.readlines()

first = int(data[0].strip())

lines = []

with open(input_file, 'r') as filename:
    for line in filename:
        lines.append(line)

y = re.compile(r"\\hypertarget\{(\w*:\w*)\}")

for (num,line) in enumerate(lines, 1):
    for i in y.findall(line):
        if num > first:
            print(num, i, end='\n')
