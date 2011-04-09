//
//  PuzzleParser.h
//  Sudokubot
//
//  Created by Haoest on 3/19/11.
//  Copyright 2011 none. All rights reserved.
//

#import <opencv2/core/core.hpp>
#import "cvutil.hpp"
#import "basicOCR.hpp"

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>


using namespace cv;
@interface PuzzleParser : NSObject {

}

+(UIImage*) BlurImage: (UIImage*) image;
+(UIImage*) FindLines: (UIImage*) image;

basicOCR* GetOCR();
void CleanUp();

void MergeAdjacentLines(vector<Vec2f>* lines);
bool CompareLineByTheta( Vec2f line1,  Vec2f line2);
bool CompareLineByRho(Vec2f line1, Vec2f line2);
void SplitIntoHorizontalAndVeriticalLines(vector<Vec2f>* allLines, vector<Vec2f>* horizontalLines, vector<Vec2f>* verticalLines);
void drawLines(Mat *mat, vector<Vec2f> *lines);
void GetRectanglesFromLines(cv::Rect dst_rectangles[], vector<Vec2f>* horizontalLines, vector<Vec2f>* verticalLines);

// parse a sudoku partial board, and return a 9x9 grid of int with hints in their corresponding slot in the board
int** ParseFromImage(UIImage* puzzleUIImage);

//given the original board as image, and a list of adjucent grids as bounds, look into each grid and try to OCR a number
// return the OCR-ed 9x9 board with each recognized number in their corresponding slot.
int** FindExistingNumbers(IplImage* puzzle, cv::Rect grids[]);

IplImage* CreateSubImage(IplImage* fullImage, cv::Rect& region);
@end
