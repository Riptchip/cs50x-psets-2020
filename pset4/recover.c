#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

int jpegs_found = -1;

//define a byte
typedef uint8_t BYTE;

//define a block, that have a size of 512 bytes
typedef struct
{
    BYTE byte[512];
}
block;

int main(int argc, char *argv[])
{
    //check for correct usage
    if (argc != 2)
    {
        printf("Usage: ./recover image\n");
        return 1;
    }

    //open memory card file
    FILE *file = fopen(argv[1], "r");

    //check if the file exists
    if (file == NULL)
    {
        printf("Could not open %s\n", argv[1]);
        return 1;
    }

    //get the size of the file
    fseek(file, 0, SEEK_END);
    int file_size = ftell(file);
    fseek(file, 0, SEEK_SET);

    FILE *outfile = NULL;

    //go through all the blocks of the file
    for (int i = 0, n = file_size / sizeof(block); i < n; i++)
    {
        block blocks;
        fread(blocks.byte, sizeof(block), 1, file);
        //check if the block starts an JPEG and if starts store the JPEG found
        if (blocks.byte[0] == 0xff && blocks.byte[1] == 0xd8 && blocks.byte[2] == 0xff && blocks.byte[3] - (blocks.byte[3] % 16) == 0xe0)
        {
            jpegs_found++;
            if (jpegs_found > 0)
            {
                //close previous the JPEG file
                fclose(outfile);
            }
            //set the out JPEG file name by the number of JPEGS found - 1 (first JPEG found will be named 000.jpg, second 001.jpg and successively)
            char outfile_name[7];

            //created because sprintf was changing the blocks.byte[0] value
            BYTE block_first_byte = blocks.byte[0];

            sprintf(outfile_name, "%03i.jpg", jpegs_found);

            //create outfile and check if it creates
            outfile = fopen(outfile_name, "w");
            if (outfile == NULL)
            {
                printf("Could not create %s\n", outfile_name);
            }

            blocks.byte[0] = block_first_byte;

            //write the block to the new .jpg file
            fwrite(blocks.byte, sizeof(block), 1, outfile);
        }
        else if (jpegs_found >= 0)
        {
            //write the block to the current .jpg file
            fwrite(blocks.byte, sizeof(block), 1, outfile);
        }
    }

    //close memory card file and last JPEG
    fclose(file);
    fclose(outfile);

    return 0;
}