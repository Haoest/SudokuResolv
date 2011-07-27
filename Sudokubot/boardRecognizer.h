//
//Copyright 2011 Haoest
//
//Licensed under the Apache License, Version 2.0 (the "License");
//you may not use this file except in compliance with the License.
//You may obtain a copy of the License at
//
//http://www.apache.org/licenses/LICENSE-2.0
//
//Unless required by applicable law or agreed to in writing, software
//distributed under the License is distributed on an "AS IS" BASIS,
//WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//See the License for the specific language governing permissions and
//limitations under the License.


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
    void destroy();
};

recognizerResultPack recognizeBoardFromPhoto(IplImage *imageInput);
recognizerResultPack recognizeFromBoard(IplImage *boardGray, int initialBoardThreshold);

// given original image as input, find the image containing just the board as gray scale image
IplImage* findSudokuBoard(IplImage *fullSrc, int &backgroundThresholdUsed);

#endif

