/*
 *  preprocessing.h
 *
 *
 *  Created by damiles on 18/11/08.
 *  Copyright 2008 __MyCompanyName__. All rights reserved.
 *
 *  Modified by haoest on 7/27/2011 (mm/dd/yyyy)
 *  Ported to the OpenCV 4 C++ API in 2026.
 */

#ifndef __PREPROCESSING_H__
#define __PREPROCESSING_H__

#include <opencv2/core.hpp>

// Crop imgSrc (binary, white background) to its bounding box, pad to a square
// preserving aspect ratio, and scale to new_width x new_height.
// Returns an empty Mat when the image contains no foreground pixels.
cv::Mat preprocessing(const cv::Mat &imgSrc, int new_width, int new_height);
cv::Rect findBB(const cv::Mat &imgSrc);

#endif
