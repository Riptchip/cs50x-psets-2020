from cs50 import get_int

# get pyramid height from the user
while True:
    height = get_int("Height: ")
    if height > 0 and height <= 8:
        break

# print blocks that construct the double half pyramids
for i in range(1, height + 1, 1):
    if height - i > 0:
        print(" " * (height - i), end="")
    print("#" * i, end="")
    print("  ", end="")
    print("#" * i)