/*
 *  basicOCR.mm
 *
 *
 *  Created by damiles on 18/11/08.
 *  Copyright 2008 Damiles. GPL License
 *
 *  Modified by haoest on 7/27/2011 (mm/dd/yyyy)
 *  Ported to the OpenCV 4 C++ API (cv::ml::KNearest) in 2026.
 */

#include <opencv2/imgproc.hpp>
#include <cstdio>
#include "preprocessing.h"
#include "basicOCR.hpp"
#import "cvutil.hpp"

void basicOCR::getData(const cv::Mat &ocrTemplate)
{
	for(int i = 0; i < classes; i++){
		for(int j = 0; j < train_samples; j++){
			cv::Rect roi(i * OCRTemplateCharacterSize, j * OCRTemplateCharacterSize,
			             OCRTemplateCharacterSize, OCRTemplateCharacterSize);
			cv::Mat src_image;
			ocrTemplate(roi).copyTo(src_image);
			cv::threshold(src_image, src_image, 255/2, 255, cv::THRESH_BINARY);
			cv::Mat prs_image = preprocessing(src_image, size, size);
			//Set class label
			trainClasses.at<float>(i * train_samples + j, 0) = (float)i;
			if (prs_image.empty()){
				trainData.row(i * train_samples + j).setTo(0);
				continue;
			}
			//Set data: convert 8 bit image to 32 bit float row vector
			cv::Mat img32;
			prs_image.convertTo(img32, CV_32F, 1.0/255.0);
			img32.reshape(0, 1).copyTo(trainData.row(i * train_samples + j));
		}
	}
}

void basicOCR::train()
{
	knn = cv::ml::KNearest::create();
	knn->setDefaultK(K);
	knn->train(trainData, cv::ml::ROW_SAMPLE, trainClasses);
}

float basicOCR::classify(const cv::Mat &img, int showResult)
{
	cv::Mat prs_image = preprocessing(img, size, size);
	if (prs_image.empty()) return 0;
	cv::Mat img32;
	prs_image.convertTo(img32, CV_32F, 1.0/255.0);
	cv::Mat sample = img32.reshape(0, 1);
	cv::Mat results, neighborResponses, dists;
	float result = knn->findNearest(sample, K, results, neighborResponses, dists);
	int accuracy = 0;
	for(int i = 0; i < K; i++){
		if (neighborResponses.at<float>(0, i) == result)
			accuracy++;
	}
	float pre = 100 * ((float)accuracy / (float)K);
	if (showResult == 1){
		printf("|\t%.0f\t| \t%.2f%%  \t| \t%d of %d \t| \n", result, pre, accuracy, K);
		printf(" ---------------------------------------------------------------\n");
	}
	return result;
}

basicOCR::basicOCR()
{
	OCRTemplateCharacterSize = 50;
	cv::Mat ocrTemplate = [cvutil LoadUIImageAsMat:@"OCRTemplateSet3.png" asGrayscale:YES];
	train_samples = ocrTemplate.rows / OCRTemplateCharacterSize;
	classes = 10;
	size = 40;
	K = 1;

	trainData.create(train_samples * classes, size * size, CV_32FC1);
	trainClasses.create(train_samples * classes, 1, CV_32FC1);

	//Get data (get images and process it)
	getData(ocrTemplate);
	//train
	train();
}
