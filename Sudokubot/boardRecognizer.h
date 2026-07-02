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

// Ported to the OpenCV 4 C++ API (cv::Mat) in 2026.

#ifndef BOARDRECOGNIZER_H
#define BOARDRECOGNIZER_H

#include <opencv2/core.hpp>
#include <vector>

struct recognizerResultPack{
    cv::Mat boardGray;
    int **boardArr = nullptr;
    std::vector<cv::Rect> grids;
    bool success = false;
    void destroy();
};

// imageInput may be single channel (gray), 3-channel BGR, or 4-channel RGBA
recognizerResultPack recognizeBoardFromPhoto(const cv::Mat &imageInput);
recognizerResultPack recognizeFromBoard(const cv::Mat &boardGray, int initialBoardThreshold);

// given original image as input, find the image containing just the board as
// a gray scale image; empty Mat when no board is found
cv::Mat findSudokuBoard(const cv::Mat &fullSrc, int &backgroundThresholdUsed);

#endif
