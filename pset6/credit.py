from cs50 import get_string

# get the credit card number from the user
number = get_string("Number: ")

# get the number length
length = len(number)


def main():
    # check the length and the first numbers of the credit card number
    if length == 16:
        if number[0] == "5" and int(number[1]) <= 5 and int(number[1]) >= 1 and algorithm(True):
            print("MASTERCARD")
        elif number[0] == "4" and algorithm(True):
            print("VISA")
        else:
            print("INVALID")
    elif length == 15 and number[0] == "3" and (number[1] == "4" or number[1] == "7") and algorithm(False):
        print("AMEX")
    elif length == 13 and number[0] == "4" and algorithm(False):
        print("VISA")
    else:
        print("INVALID")


# apply the Luhn’s algorithm in the number
def algorithm(even_length):
    sum1 = 0
    sum2 = 0

    # iterate by all digits of credit number
    for i in range(0 if even_length else 1, length, 2):
        # take the sum of the product digits of every other digit if credit card number
        product = int(number[i]) * 2
        if product >= 10:
            product_digits = str(product)
            sum1 += int(product_digits[0])
            sum1 += int(product_digits[1])
        else:
            sum1 += product
    # take the sum of the digits that weren’t multiplied by 2
    for j in range(1 if even_length else 0, length, 2):
        sum2 += int(number[j])

    # take the total sum and transform to string to check if the last number is 0
    sum_total = sum1 + sum2

    total = str(sum_total)

    if total[len(total) - 1] == "0":
        return True
    else:
        return False


main()
