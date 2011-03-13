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
//    NSLog([NSString stringWithFormat:@"number of lines: %d", lines.size()]);
    
    MergeAdjacentLines(&lines);
    //NSString *lineInfo = @"";
    // draw lines found
    for( size_t i = 0; i < lines.size(); i++ )
    {
        float rho = lines[i][0];
        float theta = lines[i][1];
        double a = cos(theta), b = sin(theta);
        double x0 = a*rho, y0 = b*rho;
        cv::Point pt1(cvRound(x0 + 1000*(-b)),
                  cvRound(y0 + 1000*(a)));
        cv::Point pt2(cvRound(x0 - 1000*(-b)),
                  cvRound(y0 - 1000*(a)));
        line( dst_color, pt1, pt2, Scalar(255,0,0), 3, 8 );
        //lineInfo = [NSString stringWithFormat:@"%@\n%f\t\t%f", lineInfo, lines[i][0], lines[i][1]]; 
    }
//    NSLog(lineInfo);
    IplImage rv = dst_color;
    return [cvutil CreateUIImageFromIplImage:&rv];
}

//line should be in [rho][theta] form
bool LineComparator( Vec2f line1,  Vec2f line2){
    float line1rho = line1[0];
    float line2rho = line2[0];
    float line1theta = line1[1];
    float line2theta = line2[1];
    if (line1theta < line2theta) return true;
    return line1rho < line2rho;
}

void MergeAdjacentLines(vector<Vec2f>* lines){
    //sort(lines->begin(), lines->end(), LineComparator);
}

+(void) Log{
    NSLog(@"dfdfdf");
}


@end
