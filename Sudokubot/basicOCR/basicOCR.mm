/*
 *  basicOCR.c
 *  
 *
 *  Created by damiles on 18/11/08.
 *  Copyright 2008 Damiles. GPL License
 *
 */

#include <opencv/cv.h>
#include <opencv/ml.h>
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include "preprocessing.h"
#include "basicOCR.hpp"
#import "cvutil.hpp"


void basicOCR::getData(IplImage* OCRTemplate)
{
	IplImage *prs_image;
	CvMat row,data;
	int i,j;
	for(i =0; i<classes; i++){
		for( j = 0; j< train_samples; j++){
			/*
             trainData = cvCreateMat(train_samples*classes, size*size, CV_32FC1);
             trainClasses = cvCreateMat(train_samples*classes, 1, CV_32FC1);
             */
			//process file
			CvRect roi = cvRect(i * OCRTemplateCharacterSize, j * OCRTemplateCharacterSize, OCRTemplateCharacterSize, OCRTemplateCharacterSize);
			cvSetImageROI(OCRTemplate, roi);
			IplImage *src_image = cvCreateImage(cvGetSize(OCRTemplate), 8, 1);
			cvCopy(OCRTemplate, src_image);
			cvThreshold(src_image, src_image, 255/2, 255, CV_THRESH_BINARY);
			//showImage(src_image, "");
			prs_image = preprocessing(src_image, size, size);
			cvReleaseImage(&src_image);
			//Set class label
			cvGetRow(trainClasses, &row, i*train_samples + j);
			cvSet(&row, cvRealScalar(i));
			//Set data 
			cvGetRow(trainData, &row, i*train_samples + j);
			IplImage* img = cvCreateImage( cvSize( size, size ), IPL_DEPTH_32F, 1 );
			//convert 8 bits image to 32 float image
			cvConvertScale(prs_image, img, 1.0/255.0, 0);
			cvGetSubRect(img, &data, cvRect(0,0, size,size));
			CvMat row_header, *row1;
			//convert data matrix sizexsize to vecor
			row1 = cvReshape( &data, &row_header, 0, 1 );
			cvCopy(row1, &row, NULL);
			cvReleaseImage(&prs_image);
            cvReleaseImage(&img);
		}
	}
}

void basicOCR::train()
{
	knn=new CvKNearest( trainData, trainClasses, 0, false, K );
}

float basicOCR::classify(IplImage* img, int showResult)
{
	IplImage *prs_image;
	CvMat data;
	CvMat* nearest=cvCreateMat(1,K,CV_32FC1);
	float result;
	//process file
	prs_image = preprocessing(img, size, size);
	if (prs_image==0) return 0;
	//Set data 
	IplImage* img32 = cvCreateImage( cvSize( size, size ), IPL_DEPTH_32F, 1 );
	cvConvertScale(prs_image, img32, 0.0039215, 0);
	cvGetSubRect(img32, &data, cvRect(0,0, size,size));
	//showImage(img32, "classify");
	CvMat row_header, *row1;
	row1 = cvReshape( &data, &row_header, 0, 1 );
	result = knn->find_nearest(row1,K,0,0,nearest,0);
	int accuracy=0;
	for(int i=0;i<K;i++){
		if( nearest->data.fl[i] == result)
            accuracy++;
	}
	float pre=100*((float)accuracy/(float)K);
	if(showResult==1){
		printf("|\t%.0f\t| \t%.2f%%  \t| \t%d of %d \t| \n",result,pre,accuracy,K);
		printf(" ---------------------------------------------------------------\n");
	}
	cvReleaseImage(&prs_image);
    cvReleaseImage(&img32);
    cvReleaseMat(&nearest);
	return result;
}

basicOCR::basicOCR()
{
	OCRTemplateCharacterSize = 50;
//	IplImage *OCRTemplate = cvLoadImage("OCRTemplateSet3.png", 0);
    IplImage *OCRTemplate = [cvutil LoadUIImageAsIplImage:@"OCRTemplateSet3.png" asGrayscale:YES ignoreOrientation:YES];
	train_samples = OCRTemplate->height / OCRTemplateCharacterSize;
	classes= 10;
	size=40;
	K = 1;
    
	trainData = cvCreateMat(train_samples*classes, size*size, CV_32FC1);
	trainClasses = cvCreateMat(train_samples*classes, 1, CV_32FC1);
    
	//Get data (get images and process it)
	getData(OCRTemplate);
	//train	
	train();
	cvReleaseImage(&OCRTemplate);
//	printf(" ---------------------------------------------------------------\n");
//	printf("|\tClass\t|\tPrecision\t|\tAccuracy\t|\n");
//	printf(" ---------------------------------------------------------------\n");
    
}

basicOCR::~basicOCR(){
    cvReleaseMat(&trainData);
    cvReleaseMat(&trainClasses);
    knn->clear();
    delete knn;
}
