#include <cs50.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

// Max number of candidates
#define MAX 9

// preferences[i][j] is number of voters who prefer i over j
int preferences[MAX][MAX];

// locked[i][j] means i is locked in over j
bool locked[MAX][MAX];

// Each pair has a winner, loser
typedef struct
{
    int winner;
    int loser;
}
pair;

// Array of candidates
string candidates[MAX];
pair pairs[MAX * (MAX - 1) / 2];
int win_strength[MAX * (MAX - 1) / 2];
int loses_array[MAX];

int pair_count;
int candidate_count;
bool is_cycling = false;

// Function prototypes
bool vote(int rank, string name, int ranks[]);
void record_preferences(int ranks[]);
void add_pairs(void);
void sort_pairs(void);
void lock_pairs(void);
void print_winner(void);
void merge_sort(int array[], int array_size);
bool cycling(int winner, int index);

int main(int argc, string argv[])
{
    // Check for invalid usage
    if (argc < 2)
    {
        printf("Usage: tideman [candidate ...]\n");
        return 1;
    }

    // Populate array of candidates
    candidate_count = argc - 1;
    if (candidate_count > MAX)
    {
        printf("Maximum number of candidates is %i\n", MAX);
        return 2;
    }
    for (int i = 0; i < candidate_count; i++)
    {
        candidates[i] = argv[i + 1];
    }

    // Clear graph of locked in pairs
    for (int i = 0; i < candidate_count; i++)
    {
        for (int j = 0; j < candidate_count; j++)
        {
            locked[i][j] = false;
        }
    }

    pair_count = 0;
    int voter_count = get_int("Number of voters: ");

    // Query for votes
    for (int i = 0; i < voter_count; i++)
    {
        // ranks[i] is voter's ith preference
        int ranks[candidate_count];

        // Query for each rank
        for (int j = 0; j < candidate_count; j++)
        {
            string name = get_string("Rank %i: ", j + 1);

            if (!vote(j, name, ranks))
            {
                printf("Invalid vote.\n");
                return 3;
            }
        }

        record_preferences(ranks);

        printf("\n");
    }

    add_pairs();
    sort_pairs();
    lock_pairs();
    print_winner();
    return 0;
}

// Update ranks given a new vote
bool vote(int rank, string name, int ranks[])
{
    for (int i = 0; i < candidate_count; i++)
    {
        if (strcmp(name, candidates[i]) == 0)
        {
            ranks[rank] = i;
            return true;
        }
    }
    return false;
}

// Update preferences given one voter's ranks
void record_preferences(int ranks[])
{
    for (int i = 0; i < candidate_count; i++)
    {
        for (int j = 0; j < candidate_count; j++)
        {
            if (i != j)
            {
                if (ranks[0] == i)
                {
                    preferences[i][j]++;
                }
                else if (ranks[1] == i && ranks[0] != j)
                {
                    preferences[i][j]++;
                }
            }
        }
    }
    return;
}

// Record pairs of candidates where one is preferred over the other
void add_pairs(void)
{
    for (int i = 0; i < candidate_count; i++)
    {
        for (int j = i + 1; j < candidate_count; j++)
        {
            if (preferences[i][j] > preferences[j][i])
            {
                win_strength[pair_count] = preferences[i][j] - preferences[j][i];
                pairs[pair_count].winner = i;
                pairs[pair_count].loser = j;
                pair_count++;
            }
            else if (preferences[j][i] > preferences[i][j])
            {
                win_strength[pair_count] = preferences[j][i] - preferences[i][j];
                pairs[pair_count].winner = j;
                pairs[pair_count].loser = i;
                pair_count++;
            }
        }
    }

    return;
}

// Sort pairs in decreasing order by strength of victory
void sort_pairs(void)
{
    //make a copy of the unsorted array for change the pairs order
    int win_strength_backup[pair_count];
    for (int i = 0; i < pair_count; i++)
    {
        win_strength_backup[i] = win_strength[i];
    }

    //sort
    merge_sort(win_strength, sizeof win_strength / sizeof win_strength[0]);

    //swap to sort elements of pairs
    for (int i = 0; i < pair_count; i++)
    {
        for (int j = i; j < pair_count; j++)
        {
            if (win_strength[i] == win_strength_backup[j])
            {
                //create temporary variables to swap
                pair temp = pairs[i];
                int temp_win_array = win_strength_backup[i];
                //swap
                pairs[i] = pairs[j];
                pairs[j] = temp;
                win_strength_backup[i] = win_strength_backup[j];
                win_strength_backup[j] = temp_win_array;
            }
        }
    }

    return;
}

// Lock pairs into the candidate graph in order, without creating cycles
void lock_pairs(void)
{
    for (int i = 0; i < pair_count; i++)
    {
        loses_array[pairs[i].loser]++;
        if (!cycling(pairs[i].winner, i))
        {
            locked[pairs[i].winner][pairs[i].loser] = true;
        }
    }
    return;
}

// Print the winner of the election
void print_winner(void)
{
    if (cycling(pairs[pair_count - 1].winner, pair_count - 1)) //if the votes are cycling the loser of the weakest win is the winner
    {
        printf("%s\n", candidates[pairs[pair_count - 1].loser]);
        return;
    }
    else
    {
        int loses = candidate_count;
        for (int i = 0; i < candidate_count; i++)
        {
            for (int j = 0; j < candidate_count; j++)
            {
                if (locked[j][i] == false)
                {
                    loses--;
                    if (loses == 0) //if candidate don't have loses, he/she is the winner
                    {
                        printf("%s\n", candidates[i]);
                        return;
                    }
                }
            }
            loses = candidate_count;
        }
    }
}

//Merge sort
void merge_sort(int array[], int array_size)
{
    //initialization
    int middle = round(array_size / 2);

    //check size for the loop don't be infinite
    if (array_size == 1)
    {
        return;
    }

    //create subarrays and copy the elements from the original array
    int left[middle], right[array_size - middle];
    for (int i = 0; i < array_size; i++)
    {
        if (i < middle)
        {
            left[i] = array[i];
        }
        else
        {
            right[i - middle] = array[i];
        }
    }

    int lengthL = sizeof left / sizeof left[0];
    int lengthR = sizeof right / sizeof right[0];

    //call yourself until the subarray have 1 element
    merge_sort(left, lengthL);
    merge_sort(right, lengthR);

    //sort decresently and merge
    int i = 0;
    int j = 0;
    int k = 0;
    while (i < lengthL && j < lengthR)
    {
        if (left[i] >= right[j])
        {
            array[k] = left[i];
            i++;
        }
        else
        {
            array[k] = right[j];
            j++;
        }
        k++;
    }

    //copy remaining elements of the subarrays if there are any
    while (i < lengthL)
    {
        array[k] = left[i];
        i++;
        k++;
    }
    while (j < lengthR)
    {
        array[k] = right[j];
        j++;
        k++;
    }

    return;
}

//check if a edge will make a loop
bool cycling(int winner, int index)
{

    if (loses_array[winner] == 0) //if the candidate don't have loses until now, he/she isn't creating a cycle
    {
        return false;
    }

    int temp_index = -1;
    int temp[index][2]; /*temp[index][0] is the candidate index and
    temp[index][1] is the value of i when the function found who won
    over the candidate, the first dimension is the number of candidates
    that is on the possible cycle and lost more than 1 time*/

    for (int i = index; i >= 0; i--)
    {
        if (winner == pairs[i].loser)
        {
            if (loses_array[pairs[i].loser] > 1)
            {
                temp_index++;
                temp[temp_index][0] = pairs[i].loser;
                temp[temp_index][1] = i;
            }

            if (loses_array[pairs[i].winner] > 0)
            {
                winner = pairs[i].winner;
                i = index + 1;

                if (winner == pairs[index].loser)
                {
                    return true;
                }
            }
            else if (temp[temp_index][1] > 0)
            {
                winner = temp[temp_index][0];
                i = temp[temp_index][1];
                temp[temp_index][1] = 0;
                temp_index--;
            }
            else
            {
                return false;
            }
        }
        else if (i == 0 && temp[temp_index][1] > 0)
        {
            winner = temp[temp_index][0];
            i = temp[temp_index][1];
            temp[temp_index][1] = 0;
            temp_index--;
        }
    }
    return false;
}
