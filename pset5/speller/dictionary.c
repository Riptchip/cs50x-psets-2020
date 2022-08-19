// Implements a dictionary's functionality

#include <stdbool.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

#include "dictionary.h"

// Number of buckets in hash table
const unsigned int N = 27;

// Hash table
node *table = NULL;

//daclare some global variables
int hash_calls_for_word = 0;
int words_dictionary = 0;

// Returns true if word is in dictionary else false
bool check(const char *word)
{
    //create traveller pointer
    node *trav = NULL;
    trav = table;

    int letter;

    //go through every letter of string except the last one
    for (int i = 1, n = strlen(word); i < n; i++)
    {
        //create int for the letter index
        letter = hash(word);

        //if doesn't have any word on the dictionary that starts with this i letters the word is misspelled
        if (trav[letter].next == NULL)
        {
            //prepare hash function to other word
            hash_calls_for_word = 0;
            return false;
        }
        //update the traveller pointer
        trav = trav[letter].next;
    }

    letter = hash(word);

    //prepare hash function to other word
    hash_calls_for_word = 0;

    //if have any word on the dictionary with this letters and finishes here the word is correctly spelled
    if (trav[letter].finish_word)
    {
        return true;
    }

    //else the word are misspelled
    return false;
}

// Hashes word to a number
unsigned int hash(const char *word)
{
    //get the ASCII decimal value of the character
    unsigned int letter = word[hash_calls_for_word];
    //lowercase the character
    letter += (letter < 97) ? 32 : 0;
    //if the character are "\'" return index 26
    if (letter < 97)
    {
        hash_calls_for_word++;
        return 26;
    }
    //update the global variable for the next character
    hash_calls_for_word++;
    //return the index of the character
    return letter % 97;
}

// Loads dictionary into memory, returning true if successful else false
bool load(const char *dictionary)
{
    //before load the dictionary preapre table array
    table = malloc(N * sizeof(node));
    if (table == NULL)
    {
        return false;
    }
    prepare_node_array(table);

    //opens dictionary and checks if it open
    FILE *file = fopen(dictionary, "r");
    if (file == NULL)
    {
        return false;
    }

    //prepare to load words
    char *word = malloc((LENGTH * sizeof(char)) + 1);
    if (word == NULL)
    {
        return false;
    }
    int index = 0;

    //go through all the file characters
    for (char c = fgetc(file); c != EOF; c = fgetc(file))
    {
        //if is a letter or an apostrophe add to word
        if (c != '\n')
        {
            word[index] = c;
            index++;
        }
        //else prepare to other word and put this word on the trie
        else
        {
            word[index] = '\0';
            words_dictionary++;
            bool word_hashed = word_into_trie(word);
            if (!word_hashed)
            {
                return false;
            }
            index = 0;
        }
    }

    fclose(file);

    free(word);

    return true;
}

// Returns number of words in dictionary if loaded else 0 if not yet loaded
unsigned int size(void)
{
    return words_dictionary;
}

// Unloads dictionary from memory, returning true if successful else false
bool unload(void)
{
    free_table(table);
    return true;
}

//construct trie with dictionary words
bool word_into_trie(const char *word)
{
    //create traveller pointer
    node *trav = NULL;
    trav = table;

    //create int for the letter index
    int letter;

    //go through every letter of string except the last one
    for (int i = 1, n = strlen(word); i < n; i++)
    {
        letter = hash(word);
        //if doesn't have any word on the dictionary that starts with this i letters yet update the trie
        if (trav[letter].next == NULL)
        {
            node *tmp = malloc(N * sizeof(node));
            if (tmp == NULL)
            {
                //prepare hash function to other word
                hash_calls_for_word = 0;
                return false;
            }
            prepare_node_array(tmp);
            trav[letter].next = tmp;
            trav = tmp;
        }
        else
        {
            //update the traveller pointer
            trav = trav[letter].next;
        }
    }

    letter = hash(word);
    //update the trie
    trav[letter].finish_word = true;

    //prepare hash function to other word
    hash_calls_for_word = 0;

    return true;
}

void free_table(node *ptr)
{
    for (int i = 0; i < N; i++)
    {
        if (ptr[i].next != NULL)
        {
            free_table(ptr[i].next);
        }
    }

    free(ptr);

    return;
}

void prepare_node_array(node *ptr)
{
    for (int i = 0; i < N; i++)
    {
        ptr[i].finish_word = false;
        ptr[i].next = NULL;
    }

    return;
}