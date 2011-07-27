/*
 *  preprocessing.c
 *  
 *
 *  Created by damiles on 18/11/08.
 *  Copyright 2008 __MyCompanyName__. All rights reserved.
 *
 */

#include "preprocessing.h"
#include <opencv/cv.h>
//#include <opencv/highgui.h>
#include <stdio.h>
#include <ctype.h>
#include <math.h>


/*****************************************************************
 *
 * Find the min box. The min box respect original aspect ratio image 
 * The image is a binary data and background is white.
 *
 *******************************************************************/
void findX(IplImage* imgSrc,int* min, int* max){
	int i;
	int minFound=0;
	CvMat data;
	CvScalar maxVal=cvRealScalar(imgSrc->height * 255);
	CvScalar val=cvRealScalar(0);
	//For each col sum, if sum < width*255 then we find the min 
	//then continue to end to search the max, if sum< width*255 then is new max
	for (i=0; i< imgSrc->width; i++){
		cvGetCol(imgSrc, &data, i);
		val= cvSum(&data);
		if(val.val[0] < maxVal.val[0]){
			*max= i;
			if(!minFound){
				*min= i;
				minFound= 1;
			}
		}
	}
}

void findY(IplImage* imgSrc,int* min, int* max){
	int i;
	int minFound=0;
	
	CvScalar maxVal=cvRealScalar(imgSrc->width * 255);
	CvScalar val=cvRealScalar(0);
	//For each col sum, if sum < width*255 then we find the min 
	//then continue to end to search the max, if sum< width*255 then is new max
	for (i=0; i< imgSrc->height; i++){
		CvMat data;
		cvGetRow(imgSrc, &data, i);
		val= cvSum(&data);
		if(val.val[0] < maxVal.val[0]){
			*max=i;
			if(!minFound){
				*min= i;
				minFound= 1;
			}
		}
	}
}

CvRect findBB(IplImage* imgSrc){
	CvRect aux;
	int xmin, xmax, ymin, ymax;
	xmin=xmax=ymin=ymax=0;
    
	findX(imgSrc, &xmin, &xmax);
	findY(imgSrc, &ymin, &ymax);
	
	aux=cvRect(xmin, ymin, xmax-xmin, ymax-ymin);
	
	return aux;
	
}

IplImage* preprocessing(IplImage* imgSrc,int new_width, int new_height){
	IplImage* result;
	IplImage* scaledResult;
	CvMat data;
	CvMat dataA;
	CvRect bb;//bounding box
	//Find bounding box
	bb=findBB(imgSrc);
	if (bb.width == 0 || bb.height ==0){
		return 0;
	} 
	//Get bounding box data and no with aspect ratio, the x and y can be corrupted
	cvGetSubRect(imgSrc, &data, cvRect(bb.x, bb.y, bb.width, bb.height));
	//Create image with this data with width and height with aspect ratio 1 
	//then we get highest size betwen width and height of our bounding box
	int size=(bb.width>bb.height)?bb.width:bb.height;
	result=cvCreateImage( cvSize( size, size ), 8, 1 );
	cvSet(result,CV_RGB(255,255,255),NULL);
	//Copy de data in center of image
	int x=(int)floor((float)(size-bb.width)/2.0f);
	int y=(int)floor((float)(size-bb.height)/2.0f);
	cvGetSubRect(result, &dataA, cvRect(x,y,bb.width, bb.height));
	cvCopy(&data, &dataA, NULL);
	//Scale result
	scaledResult=cvCreateImage( cvSize( new_width, new_height ), 8, 1 );
	cvResize(result, scaledResult, CV_INTER_NN);
	cvReleaseImage(&result);
	//Return processed data
	return scaledResult;
}


