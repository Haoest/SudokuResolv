/*
 *  preprocessing.cpp
 *
 *
 *  Created by damiles on 18/11/08.
 *  Copyright 2008 __MyCompanyName__. All rights reserved.
 *
 *  Modified by haoest on 7/27/2011 (mm/dd/yyyy)
 *  Ported to the OpenCV 4 C++ API in 2026.
 */

#include "preprocessing.h"
#include <opencv2/imgproc.hpp>
#include <cmath>

/*****************************************************************
 *
 * Find the min box. The min box respect original aspect ratio image
 * The image is a binary data and background is white.
 *
 *******************************************************************/
static void findX(const cv::Mat &imgSrc, int *min, int *max){
	int minFound = 0;
	double maxVal = imgSrc.rows * 255.0;
	//For each col sum, if sum < height*255 then we find the min
	//then continue to end to search the max, if sum < height*255 then is new max
	for (int i = 0; i < imgSrc.cols; i++){
		double val = cv::sum(imgSrc.col(i))[0];
		if (val < maxVal){
			*max = i;
			if (!minFound){
				*min = i;
				minFound = 1;
			}
		}
	}
}

static void findY(const cv::Mat &imgSrc, int *min, int *max){
	int minFound = 0;
	double maxVal = imgSrc.cols * 255.0;
	for (int i = 0; i < imgSrc.rows; i++){
		double val = cv::sum(imgSrc.row(i))[0];
		if (val < maxVal){
			*max = i;
			if (!minFound){
				*min = i;
				minFound = 1;
			}
		}
	}
}

cv::Rect findBB(const cv::Mat &imgSrc){
	int xmin, xmax, ymin, ymax;
	xmin = xmax = ymin = ymax = 0;
	findX(imgSrc, &xmin, &xmax);
	findY(imgSrc, &ymin, &ymax);
	return cv::Rect(xmin, ymin, xmax - xmin, ymax - ymin);
}

cv::Mat preprocessing(const cv::Mat &imgSrc, int new_width, int new_height){
	//Find bounding box
	cv::Rect bb = findBB(imgSrc);
	if (bb.width == 0 || bb.height == 0){
		return cv::Mat();
	}
	//Create image with this data with width and height with aspect ratio 1
	//then we get highest size betwen width and height of our bounding box
	int size = (bb.width > bb.height) ? bb.width : bb.height;
	cv::Mat result(size, size, CV_8UC1, cv::Scalar(255));
	//Copy the data in center of image
	int x = (int)floor((float)(size - bb.width) / 2.0f);
	int y = (int)floor((float)(size - bb.height) / 2.0f);
	imgSrc(bb).copyTo(result(cv::Rect(x, y, bb.width, bb.height)));
	//Scale result
	cv::Mat scaledResult;
	cv::resize(result, scaledResult, cv::Size(new_width, new_height), 0, 0, cv::INTER_NEAREST);
	return scaledResult;
}
