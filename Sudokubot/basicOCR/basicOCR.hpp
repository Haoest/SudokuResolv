/*
 *  basicOCR.hpp
 *
 *
 *  Created by damiles on 18/11/08.
 *  Copyright 2008 Damiles. GPL License
 *
 *  Modified by haoest on 7/27/2011 (mm/dd/yyyy)
 *  Ported to the OpenCV 4 C++ API (cv::ml::KNearest) in 2026.
 */
#ifndef __BASICOCR_HPP__
#define __BASICOCR_HPP__

#include <opencv2/core.hpp>
#include <opencv2/ml.hpp>

class basicOCR{
public:
    // imgBinary: single-channel binary image of one grid cell, white background
    float classify(const cv::Mat &imgBinary, int showResult);
    basicOCR();
private:
    int train_samples;
    int classes;
    cv::Mat trainData;
    cv::Mat trainClasses;
    int size;
    int OCRTemplateCharacterSize;
    int K;
    cv::Ptr<cv::ml::KNearest> knn;
    void getData(const cv::Mat &ocrTemplate);
    void train();
};

#endif
