import csv
from sys import argv, exit

argc = len(argv)

# check for the correct usage
if not argc == 3:
    print("Usage: python dna.py data.csv sequence.txt")
    exit(1)

# open files
csv_file = open(argv[1], "r")
dna = open(argv[2], "r")

# read sequence file
genome = dna.read().replace('\n', '')

# list of STR numbers found in sequence of each STR that the database provides
STRs_founded = []

# create object to get dictionaries for each person from the database
csv_reader = csv.DictReader(csv_file, dialect='excel')

# read first line of databese file to get the STRs that it will look for
STRs_reader = csv.reader(csv_file)
STRs = STRs_reader.__next__()
STRs.remove('name')
str_count = len(STRs)

# iterate over the genome to find the numbers of STRs in sequence that it's looking for and update the STRs_founded list
for i in range(str_count):
    tmp = 0
    STRs_founded.append(0)
    j = 0
    while j < len(genome):
        if genome[j:(j + len(STRs[i])) - len(genome)] == STRs[i]:
            tmp += 1
            j += len(STRs[i]) - 1
        else:
            if tmp > STRs_founded[i]:
                STRs_founded[i] = tmp
            tmp = 0
        j += 1

# go to the start of database file to use csv_reader properly
csv_file.seek(0)

# iterate over dictionaries created by csv_reader to see if the took data from genome matches with someone in database
for line in csv_reader:
    matches = 0
    for x in range(str_count):
        if int(line[STRs[x]]) == STRs_founded[x]:
            matches += 1
    if matches == str_count:
        print(line['name'])
        exit(0)

print("No match")

exit(0)
