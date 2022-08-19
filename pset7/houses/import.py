import csv
import sqlite3
from sys import argv, exit

argc = len(argv)

# Check correct usage
if not argc == 2:
    print('Usage: "python import.py file.csv"')
    exit(1)


# Open file to be imported
file = open(argv[1], "r")


# Create cursor to execute SQL queries
conn = sqlite3.connect('students.db')
c = conn.cursor()

# Create a reader to CSV file
reader = csv.reader(file)

# Jump the first line
i = reader.__next__()

# Iterate over all the other lines to insert it's data to students.db
for i in reader:
    # Manipulate i list to inset into database properly
    names = i[0].split()
    i.remove(i[0])
    for x in range(len(names) - 1, -1, -1):
        i.insert(0, names[x])
    int(i[len(i) - 1])
    # Execute SQL query to insert values into datase according with the number of names the student has
    if len(names) == 2:
        c.execute("INSERT INTO students (first, middle, last, house, birth) VALUES (?, NULL,?,?,?);", i)
    else:
        c.execute("INSERT INTO students (first, middle, last, house, birth) VALUES (?,?,?,?,?);", i)

# Save changes in database file
conn.commit()
# Close SQL cursor
conn.close()

exit(0)