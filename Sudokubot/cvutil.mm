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
#import "AppConfig.h"

using namespace cv;

@implementation cvutil


// NOTE you SHOULD cvReleaseImage() for the return value when end of the code.
+(IplImage *) CreateIplImageFromUIImage: (UIImage*) image ignoreUIOrientation:(bool) ignoreUIOrientation{
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
    if (ignoreUIOrientation){
        return ret;
    }
    CGFloat imageOrientationInDegree = [cvutil getImageOrientationInDegrees:image];
    UIImageOrientation orientation = image.imageOrientation;
    IplImage *resized = [cvutil normalizeSourceImageSize:ret];
    if (resized){
        cvReleaseImage(&ret);
        ret = resized;
    }
    int originalWidth = ret->width;
    int originalHeight = ret->height;
    if (orientation == UIImageOrientationDown){
        IplImage* srcImg = ret;
        ret = cvCreateImage(cvSize(originalWidth, originalHeight), 8, 3);
        Mat src = srcImg;
        Point2f center(src.cols/2.0F, src.rows/2.0F);
        Mat rotMat = getRotationMatrix2D(center, imageOrientationInDegree, 1.0);
        Mat dst = ret;
        warpAffine(src, dst, rotMat, src.size());
        cvReleaseImage(&srcImg);
    }
    else if(orientation == UIImageOrientationLeft || orientation == UIImageOrientationRight){
        IplImage* srcImg = cvCreateImage(cvSize(originalHeight, originalHeight), 8, 3);
        IplImage* dstImg = cvCreateImage(cvGetSize(srcImg), 8, 3);
        int offset = abs(ret->height - ret->width)/2;
		cvCopyMakeBorder(ret, srcImg, cvPoint(offset,0), IPL_BORDER_CONSTANT, cvScalar(0));
        cvReleaseImage(&ret);
        Mat src = srcImg;
        Mat dst = dstImg;
        Point2f center(src.cols/2.0F, src.rows/2.0F);
        Mat rotMat = getRotationMatrix2D(center, imageOrientationInDegree, 1.0);
        warpAffine(src, dst, rotMat, src.size());
        cvReleaseImage(&srcImg);
        ret = cvCreateImage(cvSize(originalHeight, originalWidth), 8, 3);
        CvRect roi = cvRect(0, abs(originalWidth - originalHeight)/2, originalHeight, originalWidth);
        cvSetImageROI(dstImg, roi);
        cvCopy(dstImg, ret);
        cvReleaseImage(&dstImg);
    }
    return ret;
}

// NOTE You should convert color mode as RGB before passing to this function
+(UIImage*) CreateUIImageFromIplImage: (IplImage*) image{
    bool colorRequiresConversion = false;
    if (image->nChannels == 1){
        colorRequiresConversion = true;
        IplImage *temp = cvCreateImage(cvGetSize(image), 8, 3);
        cvCvtColor(image, temp, CV_GRAY2BGR);
        image = temp;
    }
    IplImage* rgbImage = cvCreateImage(cvGetSize(image), 8, 4);
    cvCvtColor(image, rgbImage, CV_BGR2RGBA);
    cvReleaseImage(&image);
    image = rgbImage;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    // Allocating the buffer for CGImage
    NSData *data = [NSData dataWithBytes:image->imageData length:image->imageSize];
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
    if (colorRequiresConversion){
        cvReleaseImage(&image);
    }
    return ret;  
}

+(IplImage*) LoadUIImageAsIplImage: (NSString*) fileName asGrayscale:(BOOL) asGrayscale{
    UIImage *img = [UIImage imageNamed:fileName];
    IplImage *rv = [cvutil CreateIplImageFromUIImage:img ignoreUIOrientation:true];
    if (asGrayscale){
        IplImage *gray = cvCreateImage(cvGetSize(rv), 8, 1);
        cvCvtColor(rv, gray, CV_BGR2GRAY);
        cvReleaseImage(&rv);
        rv = gray;
    }
    [img release];
    return rv;
}

+(int**) ReadBoardFromFile:(NSString*) fileName{
    NSString *s = [NSString stringWithContentsOfFile:fileName encoding:NSASCIIStringEncoding error:nil];
    return [cvutil DeserializedBoard:s];
}

//board must contain a valid solution or nil is returned
+(int**) DeserializedBoard:(NSString*) board{
    board = [board stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSArray *rawBoard = [board componentsSeparatedByString:@" "];
    if ([rawBoard count] != 9){
        return nil;
    }
    int **a;
    a = new int*[9];
    for(int i=0; i<9; i++){
        a[i] = new int[9];
    }
    for(int i=0; i<9; i++){
        NSString *line = [rawBoard objectAtIndex:i];
        if ([line length] != 9){
            for(int i=0; i<9; i++){
                delete a[i];
            }
            delete a;
            return nil;
        }
        for(int j=0; j<9; j++){
            a[i][j] = ((int) [line characterAtIndex:j]) - 48;
            if (a[i][j] <0 || a[i][j] >9){
                for(int i=0; i<9; i++){
                    delete a[i];
                }
                delete a;
                return nil;
            }
        }
    }
    return a;
}


+(NSString*) SerializeBoard:(int**)board{
    NSMutableString *rv = [[NSMutableString alloc] initWithString:@""];
    for(int i=0; i<9; i++){
        for(int j=0; j<9; j++){
            [rv appendFormat:@"%d", board[i][j]];
        }
        [rv appendString:@" "];
    }
    
    NSString *s = [[NSString alloc] initWithString: rv];
    [rv release];
    return [s autorelease];
}

//load complete solution or incomplete board as a 2D array
+(int**) loadStringAsBoard: (char[89]) boardAsString{
	int **rv = new int*[9];
	for(int i=0; i<9; i++){
		rv[i] = new int[9];
	}
	int index = 0;
	int stringIndexOffset = 0;
	while(index<81){
		rv[index/9][index%9] = boardAsString[index + stringIndexOffset] - 48;
		index ++;
		if (index%9==0){
			stringIndexOffset ++;
		}
	}
	return rv;
}

+(CGFloat) getImageOrientationInDegrees:(UIImage*) img{
    CGFloat rv = 0;
    if (img.imageOrientation == UIImageOrientationLeft){
        rv = 90;
    }
    if (img.imageOrientation == UIImageOrientationRight){
        rv = -90;
    }
    if (img.imageOrientation == UIImageOrientationDown){
        rv = 180;
    }
    return rv;
}

+(IplImage*) normalizeSourceImageSize:(IplImage *)sourceImage{
	IplImage *rv = 0;
    float InputImageNormalizeLength = [AppConfig normalizedBoardImageSize];
	if (MAX(sourceImage->width, sourceImage->height) > InputImageNormalizeLength){
		int normalizedWidth, normalizedHeight;
		if(sourceImage->width > sourceImage->height){
			normalizedWidth = InputImageNormalizeLength;
			normalizedHeight = (float)InputImageNormalizeLength / sourceImage->width * sourceImage->height;
		}else{
			normalizedHeight = InputImageNormalizeLength;
			normalizedWidth = (float)InputImageNormalizeLength / sourceImage->height * sourceImage->width;
		}
		rv = cvCreateImage(cvSize(normalizedWidth, normalizedHeight), sourceImage->depth, sourceImage->nChannels);
        cvResize(sourceImage, rv);
	}
	return rv;
}

@end
