// Declares a dictionary's functionality

#ifndef DICTIONARY_H
#define DICTIONARY_H

#include <stdbool.h>

// Represents a node in a hash table
typedef struct node
{
    bool finish_word;
    struct node *next;
}
node;

// Maximum length for a word
// (e.g., pneumonoultramicroscopicsilicovolcanoconiosis)
#define LENGTH 45

// Prototypes
bool check(const char *word);
unsigned int hash(const char *word);
bool load(const char *dictionary);
unsigned int size(void);
bool unload(void);
bool word_into_trie(const char *word);
void free_table(node *ptr);
void prepare_node_array(node *ptr);

#endif // DICTIONARY_H
