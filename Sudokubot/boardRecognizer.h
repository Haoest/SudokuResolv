
//#include <opencv2\imgproc\imgproc_c.h>
//#include "core\core_c.h"
//c++ includes
//#include "opencv2/highgui/highgui.hpp"
#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/core/core.hpp>

#include <map>

#ifndef BOARDRECOGNIZER_H
#define BOARDRECOGNIZER_H

int** recognizeBoardFromPhoto(IplImage *imageInput);
int ** recognizeFromBoard(IplImage *boardGray, int initialBoardThreshold);

// given original image as input, find the image containing just the board as gray scale image
IplImage* findSudokuBoard(IplImage *fullSrc, int &backgroundThresholdUsed);

void showImage(IplImage*, char *title="no name", bool forceDisplay=0);


#endif

