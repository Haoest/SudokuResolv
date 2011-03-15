//
//  cvutil.m
//  Sudokubot
//
//  Created by Haoest on 3/10/11.
//  Copyright 2011 none. All rights reserved.
//



#import "cvutil.hpp"
#import <opencv2/imgproc/imgproc.hpp>
#import <opencv2/imgproc/imgproc_c.h>
#import <algorithm>

using namespace cv;


@implementation cvutil


// NOTE you SHOULD cvReleaseImage() for the return value when end of the code.
+(IplImage *) CreateIplImageFromUIImage: (UIImage*) image{
    // Getting CGImage from UIImage
    CGImageRef imageRef = image.CGImage;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    // Creating temporal IplImage for drawing
    IplImage *iplimage = cvCreateImage(
                                       cvSize(image.size.width,image.size.height), IPL_DEPTH_8U, 4
                                       );
    // Creating CGContext for temporal IplImage
    CGContextRef contextRef = CGBitmapContextCreate(
                                                    iplimage->imageData, iplimage->width, iplimage->height,
                                                    iplimage->depth, iplimage->widthStep,
                                                    colorSpace, kCGImageAlphaPremultipliedLast|kCGBitmapByteOrderDefault
                                                    );
    // Drawing CGImage to CGContext
    CGContextDrawImage(
                       contextRef,
                       CGRectMake(0, 0, image.size.width, image.size.height),
                       imageRef
                       );
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
    
    // Creating result IplImage
    IplImage *ret = cvCreateImage(cvGetSize(iplimage), IPL_DEPTH_8U, 3);
    cvCvtColor(iplimage, ret, CV_RGBA2BGR);
    cvReleaseImage(&iplimage);
    
    return ret;
}

// NOTE You should convert color mode as RGB before passing to this function
+(UIImage*) CreateUIImageFromIplImage: (IplImage*) image{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    // Allocating the buffer for CGImage
    NSData *data =
    [NSData dataWithBytes:image->imageData length:image->imageSize];
    CGDataProviderRef provider =
    CGDataProviderCreateWithCFData((CFDataRef)data);
    // Creating CGImage from chunk of IplImage
    CGImageRef imageRef = CGImageCreate(
                                        image->width, image->height,
                                        image->depth, image->depth * image->nChannels, image->widthStep,
                                        colorSpace, kCGImageAlphaNone|kCGBitmapByteOrderDefault,
                                        provider, NULL, false, kCGRenderingIntentDefault
                                        );
    // Getting UIImage from CGImage
    UIImage *ret = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    return ret;  
}

+(UIImage*) BlurImage: (UIImage*) image{
    IplImage *cvimg = [cvutil CreateIplImageFromUIImage: image];
    IplImage *newImg = cvCreateImage(cvGetSize(cvimg), IPL_DEPTH_8U, 3);
    Mat srcmat(cvimg, true);
    Mat dstmat(newImg);
    GaussianBlur(srcmat, dstmat, cvSize(0, 0), 2);
    IplImage blurImage = dstmat;
    cvReleaseImage(&cvimg);
    cvReleaseImage(&newImg);
    UIImage* rv = [cvutil CreateUIImageFromIplImage:&blurImage];
    return rv;
}

+(UIImage*) FindLines:(UIImage *)image{
    IplImage* cvimage = [cvutil CreateIplImageFromUIImage:image];
    IplImage *cvimage_gray = cvCreateImage(cvGetSize(cvimage), IPL_DEPTH_8U, 1);
    cvCvtColor(cvimage, cvimage_gray, CV_BGR2GRAY);
    Mat src(cvimage_gray, true);
    Mat dst, dst_color;
    Canny(src, dst, 50, 200, 3);
    cvtColor(dst, dst_color, CV_GRAY2BGR);
    vector<Vec2f> lines;
    HoughLines(dst, lines, 1, CV_PI/180, cvimage->width * 0.6);
    NSLog([NSString stringWithFormat:@"raw total number of lines: %d", lines.size()]);
    vector<Vec2f> horizontalLines;
    vector<Vec2f> verticalLines;
    SplitIntoHorizontalAndVeriticalLines(&lines, &horizontalLines, &verticalLines);
    MergeAdjacentLines(&horizontalLines);
    MergeAdjacentLines(&verticalLines);
    NSLog([NSString stringWithFormat:@"total number of horizontal lines %d", horizontalLines.size()]);
    NSLog([NSString stringWithFormat:@"total number of vertical lines %d", verticalLines.size()]);
    drawLines(&dst_color, &horizontalLines);
    drawLines(&dst_color, &verticalLines);
    // draw lines found


    IplImage rv = dst_color;
    return [cvutil CreateUIImageFromIplImage:&rv];
}

void drawLines(Mat *mat, vector<Vec2f> *lines){
    NSString *lineInfo = @"";
    for( size_t i = 0; i < lines->size(); i++ )
    {
        float rho = lines->at(i)[0];
        float theta = lines->at(i)[1];
        double a = cos(theta), b = sin(theta);
        double x0 = a*rho, y0 = b*rho;
        cv::Point pt1(cvRound(x0 + 1000*(-b)),
                  cvRound(y0 + 1000*(a)));
        cv::Point pt2(cvRound(x0 - 1000*(-b)),
                  cvRound(y0 - 1000*(a)));
        line( *mat, pt1, pt2, Scalar(255,0,0), 1, 8 );
        lineInfo = [NSString stringWithFormat:@"%@\n%f\t\t%f", lineInfo, lines->at(i)[0], lines->at(i)[1]]; 
    }
    NSLog(lineInfo);
}

//line should be in the form where [0] is rho and [1] is theta
bool CompareLineByTheta( Vec2f line1,  Vec2f line2){
    return line1[1] < line2[1];
    
}

//line should be in the form where [0] is rho and [1] is theta
bool CompareLineByRho(Vec2f line1, Vec2f line2){
    return line1[0] < line2[0];
}

void MergeAdjacentLines(vector<Vec2f>* lines){
    stable_sort(lines->begin(), lines->end(), CompareLineByRho);
    stable_sort(lines->begin(), lines->end(), CompareLineByTheta);
    float distance = lines->back()[0] - lines->front()[0];
    vector<Vec2f> goodLines;
    int prevPivotIndex = 0;
    goodLines.push_back(lines->at(0));
    for(int i=1; i<lines->size(); i++){
        if (!(lines->at(i)[0] - lines->at(prevPivotIndex)[0] < distance / 10 / 2)){
            prevPivotIndex = i;
            goodLines.push_back(lines->at(i));
        }
    }
    lines = &goodLines;
}

void SplitIntoHorizontalAndVeriticalLines(vector<Vec2f>* allLines, vector<Vec2f>* horizontalLines, vector<Vec2f>* verticalLines){
    horizontalLines->clear();
    verticalLines->clear();
    float tolerance = 15.0/360.0;
    for(int i=0; i<allLines->size(); i++){
        float theta = allLines->at(i)[1];
        if ( theta < tolerance || theta > CV_PI - tolerance){
            horizontalLines->push_back( allLines->at(i));
        }
        if (theta > CV_PI / 2.0 - tolerance && theta < CV_PI / 2.0 + tolerance){
            verticalLines->push_back( allLines->at(i));
        }
    }
}

@end
