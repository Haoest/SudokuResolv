//
//  PuzzleParser.m
//  Sudokubot
//
//  Created by Haoest on 3/19/11.
//  Copyright 2011 none. All rights reserved.
//

#import <opencv2/imgproc/imgproc.hpp>
#import <opencv2/imgproc/imgproc_c.h>
#import <opencv2/core/core_c.h>
#import "PuzzleParser.hpp"
#import "preprocessing.hpp"
#import "SudokubotViewController.h"

using namespace cv;


@implementation PuzzleParser
static basicOCR *ocr = nil;

basicOCR* GetOCR(){
    if (!ocr){
        ocr = new basicOCR();
    }
    return ocr;
}

void CleanUp(){
    if(ocr){
        delete ocr;
    }
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
    cvtColor(src, dst_color, CV_GRAY2BGR);
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
    cv::Rect rects[9*9];
    GetRectanglesFromLines(rects, &horizontalLines, &verticalLines);
    for(int i=0; i<9*9;i++){
        rectangle(dst_color, cvPoint(rects[i].x, rects[i].y), cvPoint(rects[i].width + rects[i].x, rects[i].height + rects[i].y), Scalar(255,0,0));
    }
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

// lines vector must contain lines of the same theta
void MergeAdjacentLines(vector<Vec2f>* lines){
    stable_sort(lines->begin(), lines->end(), CompareLineByRho);
    stable_sort(lines->begin(), lines->end(), CompareLineByTheta);
    float distance = lines->back()[0] - lines->front()[0];
    vector<int> removableLines;
    int prevPivotIndex = 0;
    for(int i=1; i<lines->size(); i++){
        float currentRho = lines->at(i)[0];
        float prevRho = lines->at(prevPivotIndex)[0];
        if (currentRho - prevRho  < distance / 10 / 2){
            removableLines.push_back(i);
        }else{
            prevPivotIndex = i;
        }
    }
    for(int i=removableLines.size()-1; i>=0 ;i--){
        lines->erase( removableLines[i] + lines->begin() );
    }
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

void GetRectanglesFromLines(cv::Rect dst_rectangles[], vector<Vec2f>* horizontalLines, vector<Vec2f>* verticalLines){
    int index = 0;
    for(int i=0; i<horizontalLines->size()-1; i++){
        int y0 = horizontalLines->at(i)[0];
        for(int j=0; j<verticalLines->size()-1; j++){
            int x0 = verticalLines->at(j)[0];
            int width = verticalLines->at(j+1)[0] - x0;
            int height = horizontalLines->at(i+1)[0] - y0;
            dst_rectangles[index++] = cv::Rect(x0,y0, width, height);
        }
    }
}

int** ParseFromImage(UIImage* puzzleUIImage){
    IplImage *puzzle = [cvutil CreateIplImageFromUIImage: puzzleUIImage];
    IplImage *cvimage_gray = cvCreateImage(cvGetSize(puzzle), IPL_DEPTH_8U, 1);
    cvCvtColor(puzzle, cvimage_gray, CV_BGR2GRAY);
    Mat src(cvimage_gray, true);
    Mat dst;
    Canny(src, dst, 50, 200, 3);
    vector<Vec2f> lines;
    HoughLines(dst, lines, 1, CV_PI/180, puzzle->width * 0.6);
    vector<Vec2f> horizontalLines;
    vector<Vec2f> verticalLines;
    SplitIntoHorizontalAndVeriticalLines(&lines, &horizontalLines, &verticalLines);
    MergeAdjacentLines(&horizontalLines);
    MergeAdjacentLines(&verticalLines);
    cv::Rect rects[9*9];
    GetRectanglesFromLines(rects, &horizontalLines, &verticalLines);
    return FindExistingNumbers(puzzle, rects);
}

int** FindExistingNumbers(IplImage* puzzle, cv::Rect grids[]){
    int** board = new int*[9];
    for(int i=0; i<9; i++){
        board[i] = new int[9];
    }
    IplImage *gray = cvCreateImage(cvGetSize(puzzle), IPL_DEPTH_8U, 1);
    cvCvtColor(puzzle, gray, CV_BGR2GRAY);
    cvThreshold(gray, gray, 255/2.0, 255, CV_THRESH_BINARY);
    for(int i=0; i<9*9; i++){
        IplImage *region = CreateSubImage(gray, grids[i]);
        basicOCR *ocr = GetOCR();
        whitenBorders(region);
        IplImage processedRegion = preprocessing(region, 40, 40);
        int result = 0;
        if (processedRegion.width!=0 && processedRegion.height!=0){
            result = (int)ocr->classify(&processedRegion, 0);
        }
        board[i/9][i%9] = result;
    }
    return board;
}

IplImage* CreateSubImage(IplImage* fullImage, cv::Rect& region){
    IplImage *rv = cvCreateImage(cvSize(region.width, region.height), fullImage->depth, fullImage->nChannels);
    cvSetImageROI(fullImage, region);
    cvCopy(fullImage, rv, NULL);
    cvResetImageROI(fullImage);
    return rv;
}

@end
