
//#include <opencv2\imgproc\imgproc_c.h>
//#include "core\core_c.h"
//c++ includes
//#include "opencv2/highgui/highgui.hpp"
#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/core/core.hpp>
#include <vector>


#ifndef BOARDRECOGNIZER_H
#define BOARDRECOGNIZER_H

struct recognizerResultPack{
    IplImage *boardGray;
    int ** boardArr;
    std::vector<CvRect> grids;
    bool success;
};

recognizerResultPack recognizeBoardFromPhoto(IplImage *imageInput);
recognizerResultPack recognizeFromBoard(IplImage *boardGray, int initialBoardThreshold);

// given original image as input, find the image containing just the board as gray scale image
IplImage* findSudokuBoard(IplImage *fullSrc, int &backgroundThresholdUsed);

#endif

