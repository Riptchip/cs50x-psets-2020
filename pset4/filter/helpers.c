#include <math.h>
#include "helpers.h"

const int RGB = 3;

// Convert image to grayscale
void grayscale(int height, int width, RGBTRIPLE image[height][width])
{
    //these loops i and j are to go through all the pixels of the image
    for (int i = 0; i < height; i++)
    {
        for (int j = 0; j < width; j++)
        {
            //set the all color values to the average of the three (red, green, blue) values
            image[i][j].rgbtBlue = round(((double) image[i][j].rgbtBlue + (double) image[i][j].rgbtGreen + (double) image[i][j].rgbtRed) /
                                         (double) RGB);
            image[i][j].rgbtGreen = image[i][j].rgbtBlue;
            image[i][j].rgbtRed = image[i][j].rgbtBlue;
        }
    }
    return;
}

// Reflect image horizontally
void reflect(int height, int width, RGBTRIPLE image[height][width])
{
    RGBTRIPLE image_tmp;

    //these loops i and j are to go through half the pixels of the image
    for (int i = 0; i < width / 2; i++)
    {
        for (int j = 0; j < height; j++)
        {
            //swap the ith collumn with the width - ith collumn
            image_tmp = image[j][i];
            image[j][i] = image[j][width - i - 1];
            image[j][width - i - 1] = image_tmp;
        }
    }
    return;
}

// Blur image
void blur(int height, int width, RGBTRIPLE image[height][width])
{
    //make a copy of the image array
    RGBTRIPLE image_tmp[height][width];

    for (int i = 0; i < height; i++)
    {
        for (int j = 0; j < width; j++)
        {
            image_tmp[i][j] = image[i][j];

        }
    }

    //these loops i and j are to go through all the pixels of the image
    for (int i = 0; i < height; i++)
    {
        for (int j = 0; j < width; j++)
        {
            double sumR = 0, sumG = 0, sumB = 0;
            double pixels_in_box = 0;
            int height_offset = -1;
            int width_offset = -1;

            //go through by each pixel in the 3x3 box that's around the actual pixel
            while (height_offset < 2)
            {
                //check if the pixel is on the image
                if (i + height_offset >= 0 && i + height_offset < height)
                {
                    width_offset = -1;
                    while (width_offset < 2)
                    {
                        //check if the pixel is on the image
                        if (j + width_offset >= 0 && j + width_offset < width)
                        {
                            //sum the color values of each channel of the pixel that is in the 3x3 box
                            sumR += image_tmp[i + height_offset][j + width_offset].rgbtRed;
                            sumG += image_tmp[i + height_offset][j + width_offset].rgbtGreen;
                            sumB += image_tmp[i + height_offset][j + width_offset].rgbtBlue;
                            //count the number of existent pixels on the 3x3 box
                            pixels_in_box++;
                        }
                        width_offset++;
                    }
                }
                height_offset++;
            }

            //set the new color value to the average of the color values of each channel of the pixel in the 3x3 box
            image[i][j].rgbtBlue = round(sumB / pixels_in_box);
            image[i][j].rgbtGreen = round(sumG / pixels_in_box);
            image[i][j].rgbtRed = round(sumR / pixels_in_box);
        }
    }
    return;
}

// Detect edges
void edges(int height, int width, RGBTRIPLE image[height][width])
{
    //make a copy of the image array
    RGBTRIPLE image_tmp[height][width];

    for (int i = 0; i < height; i++)
    {
        for (int j = 0; j < width; j++)
        {
            image_tmp[i][j] = image[i][j];
        }
    }

    //these loops i and j are to go through all the pixels of the image
    for (int i = 0; i < height; i++)
    {
        for (int j = 0; j < width; j++)
        {
            double gxR, gxG, gxB, gyR, gyG, gyB;

            //loop for compute gx and gy values (x = 0 is computing gx, x = 1 is computing gy)
            for (int x = 0; x < 2; x++)
            {
                double sumR = 0, sumG = 0, sumB = 0;
                int height_offset = -1;
                int width_offset = -1;

                //go through by each pixel in the 3x3 box that's around the actual pixel
                while (height_offset < 2)
                {
                    //check if the pixel is on the image
                    if (i + height_offset >= 0 && i + height_offset < height)
                    {
                        width_offset = -1;
                        while (width_offset < 2)
                        {
                            //check if the pixel is on the image
                            if (j + width_offset >= 0 && j + width_offset < width)
                            {
                                //multiply each pixel in 3x3 box by the respective number in sobel operator kernel and add to the total sum
                                switch (height_offset)
                                {
                                    case -1:
                                        switch (width_offset)
                                        {
                                            //first pixel
                                            case -1:
                                                sumR += image_tmp[i + height_offset][j + width_offset].rgbtRed * -1;
                                                sumG += image_tmp[i + height_offset][j + width_offset].rgbtGreen * -1;
                                                sumB += image_tmp[i + height_offset][j + width_offset].rgbtBlue * -1;
                                                break;

                                            //second pixel
                                            case 0:
                                                if (x == 1)
                                                {
                                                    sumR += image_tmp[i + height_offset][j + width_offset].rgbtRed * -2;
                                                    sumG += image_tmp[i + height_offset][j + width_offset].rgbtGreen * -2;
                                                    sumB += image_tmp[i + height_offset][j + width_offset].rgbtBlue * -2;
                                                }
                                                break;

                                            //third pixel
                                            case 1:
                                                if (x == 0)
                                                {
                                                    sumR += image_tmp[i + height_offset][j + width_offset].rgbtRed;
                                                    sumG += image_tmp[i + height_offset][j + width_offset].rgbtGreen;
                                                    sumB += image_tmp[i + height_offset][j + width_offset].rgbtBlue;
                                                }
                                                else
                                                {
                                                    sumR += image_tmp[i + height_offset][j + width_offset].rgbtRed * -1;
                                                    sumG += image_tmp[i + height_offset][j + width_offset].rgbtGreen * -1;
                                                    sumB += image_tmp[i + height_offset][j + width_offset].rgbtBlue * -1;
                                                }
                                                break;
                                        }
                                        break;

                                    case 0:
                                        switch (width_offset)
                                        {
                                            //fourth pixel
                                            case -1:
                                                if (x == 0)
                                                {
                                                    sumR += image_tmp[i + height_offset][j + width_offset].rgbtRed * -2;
                                                    sumG += image_tmp[i + height_offset][j + width_offset].rgbtGreen * -2;
                                                    sumB += image_tmp[i + height_offset][j + width_offset].rgbtBlue * -2;
                                                }
                                                break;

                                            // the fifth pixel is multiplyed by 0 in both gx and gy kernels

                                            //sixth pixel
                                            case 1:
                                                if (x == 0)
                                                {
                                                    sumR += image_tmp[i + height_offset][j + width_offset].rgbtRed * 2;
                                                    sumG += image_tmp[i + height_offset][j + width_offset].rgbtGreen * 2;
                                                    sumB += image_tmp[i + height_offset][j + width_offset].rgbtBlue * 2;
                                                }
                                                break;
                                        }
                                        break;

                                    case 1:
                                        switch (width_offset)
                                        {
                                            //seventh pixel
                                            case -1:
                                                if (x == 0)
                                                {
                                                    sumR += image_tmp[i + height_offset][j + width_offset].rgbtRed * -1;
                                                    sumG += image_tmp[i + height_offset][j + width_offset].rgbtGreen * -1;
                                                    sumB += image_tmp[i + height_offset][j + width_offset].rgbtBlue * -1;
                                                }
                                                else
                                                {
                                                    sumR += image_tmp[i + height_offset][j + width_offset].rgbtRed;
                                                    sumG += image_tmp[i + height_offset][j + width_offset].rgbtGreen;
                                                    sumB += image_tmp[i + height_offset][j + width_offset].rgbtBlue;
                                                }
                                                break;

                                            //eighth pixel
                                            case 0:
                                                if (x == 1)
                                                {
                                                    sumR += image_tmp[i + height_offset][j + width_offset].rgbtRed * 2;
                                                    sumG += image_tmp[i + height_offset][j + width_offset].rgbtGreen * 2;
                                                    sumB += image_tmp[i + height_offset][j + width_offset].rgbtBlue * 2;
                                                }
                                                break;

                                            //ninth pixel
                                            case 1:
                                                sumR += image_tmp[i + height_offset][j + width_offset].rgbtRed;
                                                sumG += image_tmp[i + height_offset][j + width_offset].rgbtGreen;
                                                sumB += image_tmp[i + height_offset][j + width_offset].rgbtBlue;
                                                break;
                                        }
                                        break;
                                }
                            }
                            width_offset++;
                        }
                    }
                    height_offset++;
                }

                // pass the sum values to gx and gy of each channel
                if (x == 0)
                {
                    gxR = sumR;
                    gxG = sumG;
                    gxB = sumB;
                }
                else
                {
                    gyR = sumR;
                    gyG = sumG;
                    gyB = sumB;
                }
            }

            image[i][j].rgbtBlue = lround(sqrt((gxB * gxB) + (gyB * gyB)));
            image[i][j].rgbtGreen = lround(sqrt((gxG * gxG) + (gyG * gyG)));
            image[i][j].rgbtRed = lround(sqrt((gxR * gxR) + (gyR * gyR)));

            //check if the equation result is more than 255 and if it is change the value to 255
            if (round(sqrt((gxB * gxB) + (gyB * gyB))) > 255)
            {
                image[i][j].rgbtBlue = 255;
            }
            if (round(sqrt((gxG * gxG) + (gyG * gyG))) > 255)
            {
                image[i][j].rgbtGreen = 255;
            }
            if (round(sqrt((gxR * gxR) + (gyR * gyR))) > 255)
            {
                image[i][j].rgbtRed = 255;
            }
        }
    }
    return;
}
