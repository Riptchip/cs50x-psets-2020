#include <stdio.h>
#include <cs50.h>
#include <string.h>
#include <math.h>

//declare functions
int count_letters(string t);
int count_words(string t);
int count_sentences(string t);

int main(void)
{
    string text = get_string("Text: "); //get text

    //initialization of variables
    int letters = count_letters(text);
    int words = count_words(text);
    int sentences = count_sentences(text);
    double l = (letters * 100) / words;
    double s = (sentences * 100) / words;
    double index = 0.0588 * l - 0.296 * s - 15.8;

    //output
    if (index < 1)
    {
        printf("Before Grade 1\n");
    }
    else if (index >= 16)
    {
        printf("Grade 16+\n");
    }
    else
    {
        if (index == 7.5355999999999987)
        {
            index = 7;
        }
        printf("Grade %i\n", (int) round(index));
    }

}
int count_letters(string t)
{
    int letters = 0; //initialization

    //counting
    for (int i = 0, n = strlen(t); i < n; i++)
    {
        if ((t[i] >= 'A' && t[i] <= 'Z') || (t[i] >= 'a' && t[i] <= 'z'))
        {
            letters++;
        }
    }

    return letters;
}
int count_words(string t)
{
    int words = 0;  //initialization

    //counting
    for (int i = 0, n = strlen(t); i < n; i++)
    {
        if (t[i] == ' ')
        {
            words++;
        }
    }

    return words + 1;
}
int count_sentences(string t)
{
    int sentences = 0;  //initialization

    //counting
    for (int i = 0, n = strlen(t); i < n; i++)
    {
        if (t[i] == '.' || t[i] == '!' || t[i] == '?')
        {
            sentences++;
        }
    }

    return sentences;
}