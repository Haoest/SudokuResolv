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
    return ret;  
}

+(IplImage*) LoadUIImageAsIplImage: (NSString*) fileName asGrayscale:(BOOL) asGrayscale{
    UIImage *img = [UIImage imageNamed:fileName];
    IplImage *rv = [cvutil CreateIplImageFromUIImage:img];
    if (asGrayscale){
        IplImage *gray = cvCreateImage(cvGetSize(rv), 8, 1);
        cvCvtColor(rv, gray, CV_BGR2GRAY);
        cvReleaseImage(&rv);
        rv = gray;
    }
    [img release];
    return rv;
}

+(IplImage*) LoadPbmAsIplImage: (NSString*) fileName{
    int firstLineOfImageData = 5;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"pbm"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSString *content = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    NSArray *lines = [content componentsSeparatedByString:@"\n"];
    NSString *first = [lines objectAtIndex:firstLineOfImageData]; //because first line (index 0) contains meta data
    int width = [first length];
    int height = [lines count]-firstLineOfImageData-1;
    IplImage *img = cvCreateImage(cvSize(width, height), IPL_DEPTH_8U, 1);
    for (int i=firstLineOfImageData; i<[lines count]; i++){
        for (int j=0; j<[[lines objectAtIndex:i] length]; j++){
            int pixelValue = 255;
            unichar c = [[lines objectAtIndex:i] characterAtIndex:j];
            if (c == '1'){
                pixelValue = 0;
            }
            *(img->imageData + (i-firstLineOfImageData) * img->widthStep + j) = pixelValue;
        }
    }
    return img;
}

+(IplImage*) GetNormalizedImageFromBlackNWhite:(IplImage*) blackWhiteImage{
    IplImage* rv = cvCreateImage(cvGetSize(blackWhiteImage), IPL_DEPTH_8U, 3);
    for(int y=0; y<rv->height; y++){
        uchar *dstx0 = (uchar*)(rv->imageData + y*rv->widthStep);
        uchar *srcx0 = (uchar*)(blackWhiteImage->imageData + y*blackWhiteImage->widthStep);
        for(int x=0; x<rv->width; x++){
            uchar pixelValue = (*(srcx0+x)) * 255;
            dstx0[3*x+0] = pixelValue;
            dstx0[3*x+1] = pixelValue;
            dstx0[3*x+2] = pixelValue;
        }
    }
    return rv;
}

+(int**) ReadBoardFromFile:(NSString*) fileName{
    NSString *s = [NSString stringWithContentsOfFile:fileName encoding:NSASCIIStringEncoding error:nil];
    return [cvutil DeserializedBoard:s];
}

+(int**) DeserializedBoard:(NSString*) board{
    board = [board stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    int **a;
    a = new int*[9];
    for(int i=0; i<9; i++){
        a[i] = new int[9];
    }
    NSArray *rawBoard = [board componentsSeparatedByString:@" "];
    if ([rawBoard count] != 9){
        return nil;
    }
    for(int i=0; i<9; i++){
        NSString *line = [rawBoard objectAtIndex:i];
        if ([line length] != 9){
            return nil;
        }
        for(int j=0; j<9; j++){
            a[i][j] = ((int) [line characterAtIndex:j]) - 48;
            if (a[i][j] <1 || a[i][j] >9){
                return nil;
            }
        }
    }
    return a;
}


+(NSString*) SerializeBoard:(int**)board{
    NSMutableString *rv = [NSMutableString stringWithFormat:@""];
    for(int i=0; i<9; i++){
        for(int j=0; j<9; j++){
            [rv appendFormat:@"%d", board[i][j]];
        }
        [rv appendString:@" "];
    }
    return [NSString stringWithString:rv];
}

@end
