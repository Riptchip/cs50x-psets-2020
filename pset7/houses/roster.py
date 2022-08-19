import sqlite3
from sys import argv, exit

argc = len(argv)

# Check correct usage
if not argc == 2:
    print('Usage: "python roster.py hogwartsHouse"')
    exit(1)

# Create cursor to execute SQL queries
conn = sqlite3.connect('students.db')
c = conn.cursor()

# Create variable to use execute properly
house = (argv[1], )

# Iterate over results and printing then formatted
for i in c.execute('SELECT first, middle, last, birth FROM students WHERE house == ? ORDER BY last, first', house):
    if i[1] == None:
        print(f"{i[0]} {i[2]}, born {i[3]}")
    else:
        print(f"{i[0]} {i[1]} {i[2]}, born {i[3]}")

# Close SQL cursor
conn.close()

exit(0)

