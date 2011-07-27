/*
 *  preprocessing.h
 *  
 *
 *  Created by damiles on 18/11/08.
 *  Copyright 2008 __MyCompanyName__. All rights reserved.
 *
 */

#include <opencv/cv.h>
//#include <opencv/highgui.h>
#include <stdio.h>
#include <ctype.h>


IplImage *preprocessing(IplImage* imgSrc,int new_width, int new_height);
CvRect findBB(IplImage* imgSrc);

