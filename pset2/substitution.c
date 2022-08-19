#include <stdio.h>
#include <cs50.h>
#include <string.h>
#include <ctype.h>

int main(int argc, string argv[])
{
    //initialization of variables
    int characters = 0;
    string alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";

    //check argumets
    if (argc != 2)
    {
        printf("Usage: ./substitution key\n");
        return 1;
    }

    //check chars
    for (int i = 0, n = strlen(argv[1]); i < n; i++)
    {
        //checking if is letters
        if (isupper(argv[1][i]) == 0 && islower(argv[1][i]) == 0)
        {
            printf("Usage: ./substitution key\n");
            return 1;
        }
        //capitalizing
        if (islower(argv[1][i]) != 0)
        {
            argv[1][i] -= 32;
        }
        //checking for duplicate letters
        for (int j = i + 1; j < n; j++)
        {
            if (argv[1][i] == argv[1][j])
            {
                printf("Usage: ./substitution key\n");
                return 1;
            }
        }

        characters++;
    }

    //check number of chars
    if (characters != 26)
    {
        printf("Key must contain 26 characters.\n");
        return 1;
    }

    //initialization of variables 2
    string plaintext = get_string("plaintext: ");
    string ciphertext = plaintext;
    int toLowerCase = 0;

    //encrypt
    for (int i = 0, n = strlen(ciphertext); i < n; i++)
    {
        //storing information of lowercase chars and capitalizing
        if (islower(ciphertext[i]))
        {
            toLowerCase = 32;
            ciphertext[i] -= 32;
        }
        else
        {
            toLowerCase = 0;
        }
        //changing letters
        if (isupper(ciphertext[i]) != 0 || islower(ciphertext[i]) != 0)
        {
            for (int x = 0, y = strlen(alphabet); x < y; x++)
            {
                if (ciphertext[i] == alphabet[x])
                {
                    ciphertext[i] = argv[1][x];
                    x = strlen(alphabet) + 1;
                }
            }
        }
        //lowercasing
        ciphertext[i] += toLowerCase;
    }

    //print encrypted message
    printf("ciphertext: %s\n", ciphertext);
    return 0;
}