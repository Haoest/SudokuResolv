//
//Copyright 2011 Haoest
//
//Licensed under the Apache License, Version 2.0 (the "License");
//you may not use this file except in compliance with the License.
//You may obtain a copy of the License at
//
//http://www.apache.org/licenses/LICENSE-2.0
//
//Unless required by applicable law or agreed to in writing, software
//distributed under the License is distributed on an "AS IS" BASIS,
//WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//See the License for the specific language governing permissions and
//limitations under the License.



#include <algorithm>
#include "BoardRecognizer.h"
//#include "highgui\highgui_c.h"
#include "basicOCR.hpp"

//c++ includes
//#include "opencv2/highgui/highgui.hpp"

using namespace std;
using namespace cv;

static bool debug_showImage = 0;
static bool showOcrResult = 0;
	
static basicOCR *OCREngine = 0;


IplImage* findBoardFromContour(CvSeq* contours, IplImage*fullSrcGray, IplImage *fullSrcBinary );
IplImage* doesResembleBoard(CvSeq* contours, IplImage*fullSrc, IplImage *fullSrcBinary);
void findExtremas(CvSeq* contour, int &left, int &right, int &top, int &bottom);
void updateLineSlopeFreq(CvScalar* lineSlopeFreq, int lineCount, float theta);
int findCharacterShadingThreshold(IplImage* gridBinary);
IplImage *getROIAsImageRef(IplImage* img, int left, int right, int top, int bottom);
static bool rectangleCmpByPositionX(const CvRect &a, const CvRect &b);
static bool rectangleCmpByPositionY(const CvRect &a, const CvRect &b);
std::vector<CvRect> getAllGrids(IplImage *boardBinary);
void findLineOccurenceBySlope(CvScalar *lineSlopeFreq, int freqLineCount, int &highIndex, int &secondIndex);
bool checkLineDistributionByRho(CvSeq *boardLines, float pivotLineTheta, int boardSpace);
bool areLinesSimilarInSlope(float theta1, float theta2);
int ** extractNumbersFromBoard(IplImage *boardGray, vector<CvRect> &grids);
vector<CvRect> getSortedGridsByCoord(vector<CvRect> &grids);
IplImage *normalizeSourceImageSize(IplImage *sourceImage);
vector<CvRect> findGridsByThreshold(IplImage *board, int initialThreshold);
CvRect findRectFromMask(IplImage* mask);
void findYExtremas(IplImage* mask,int* min, int* max);
void findXExtramas(IplImage* mask,int* min, int* max);
void drawContour(IplImage*, CvSeq *contour, int level = 1);
void findExtremas(CvSeq* contour, int &left, int &right, int &top, int &bottom);
inline float radiantToDegree(float radiant){return 180.0/CV_PI * radiant;}
inline float degreeToRadiant(float degree){return CV_PI/180 * degree;}

void findExtremasFromSumVector(int* sumVector, vector<int>&extremas, int lowerBound, int upperBound, int minSpace);

//find the grids by suming pixel values for every row to discover y-position of the horizontal lines
//and then suming pixel values for every column to discover x-position of the veritical lines
//crossing the x- and y- positions will ultimately form 81 grids.
vector<CvRect> findGridsByXYVectors(IplImage *boardGray, int initialThreshold);

//when summing pixel values of each row, partition the image vertically into 9 equal parts; a row of black pixels yeild very low sum value
//search is conducted to find all 10 low extremas from the resulting sum array, and these are the y positions of all the soduko boxes. 
//Similar partitioning is performed when summing the pixel values of each column. 
//Reason for paritioning is to offset image distortion towards corners and edges of the puzzle. 
void calcLocalizedSumVectors(IplImage *boardGray, int*** xsum, int*** ysum);

//when pixel value sum is used to find extremas, this ratio is used to calculate how far the extrema is away from
//the next extrema in order for the next to be considered a valid candidate.
// this value is uesd to multiply the expected width or height of one grid
const float ExtremaSearchMinSpaceRatio = 0.75;

void cleanUpScatteredNoise(IplImage* grid, int noiseThreshold);
//142 is a magic number found by performing blur with block size of 3 on a 2x2 square black pixel cluster contained inside white background
//each of the 4 black pixels with 0 gray scale value become 142 after blur.
//This means a small blob of black pixels is considered noise if it has less than or equal to 4 black pixels in a 3x3 island
const int NoiseThreshold = 142;

//given sudoku board image with ROI set as 1 single grid, keep contracting the 
//ROI until the 4 sides are completely white (noiseless)
//return the ROI as a rectangle
CvRect setNoiselessGridRoi(IplImage* boardBinary, int x, int y, int width, int height);

//unprocessedBoard is the image bound by the contour, this function should return a copy of 
// it with it set up-right, with the information provided by degreeOfHighestCount, which
// can be about ~0 degree or ~CV_?PI/2, plus or minus the value of SlopeLinetolerance
IplImage* extractAndSetBoardUpRight(CvSeq* contours, const CvPoint &contourOffset, IplImage* potentialBoardRoi, float degreeOfHighestCount);

//when parsing lines which form a potential sudoku board, consider multiple lines 
//the same degree as long as they fall in this tolerance
static double SlopeLineToleranceInDegree = 5;

//only accept images that are titled no more than this angle
static int BoardTiltTolerance = 30;

//when locating the board region from a photo, threshold value is used to produce a contour
//which helps to determine the location. In the next phase when grids are being located from
//the board region, binary images of the board, produced with different threshold values starting from
//the value used to find the board, incrementing and degrementing by GridSearchThresholdIncrementAmount,
//are used to produced board contours to get better shapes for the grids
const int GridSearchThresholdIncrementAmount = 5;

const int CharacterSearchThresholdIncrementAmount = 255/10;

//if input image is large, try to resize it to this size proportionally. The longer leg between width and height will use this size
const double InputImageNormalizeLength = 800;

//debug function
void showImage(IplImage* img, char* title, bool forceDisplay=0);
void debug_dump_array(int *arr, int size, char* fileName);
void drawGrids(IplImage* background, vector<CvRect> grids);
void debug_dump_array(CvScalar* arr, int count, char* fileName);


static int BoardThresholdCandidateSize  = 4;
static int BoardThresholdCandidates[] = {1,5, 10,20};

void recognizerResultPack::destroy(){
    if (boardGray){
        cvReleaseImage(&boardGray);
    }
    if(boardArr){
        for(int i=0; i<9; i++){
            delete boardArr[i];
        }
        delete boardArr;
        boardArr = 0;
    }
}

recognizerResultPack recognizeBoardFromPhoto(IplImage *imageInput){
    recognizerResultPack rv;
    rv.success = false;
	int backgroundThresholdMark;
	IplImage *board = findSudokuBoard(imageInput, backgroundThresholdMark);
	if (!board){
		return rv;
	}
	rv = recognizeFromBoard(board, backgroundThresholdMark);
    if (!rv.success){
        cvReleaseImage(&board);
    }
    return rv;
}

recognizerResultPack recognizeFromBoard(IplImage *boardGray, int initialBoardThreshold){
    recognizerResultPack rv;
    rv.success = false;
	vector<CvRect> grids;
	//grids = findGridsByThreshold(boardGray, initialBoardThreshold);
	grids = findGridsByXYVectors(boardGray, initialBoardThreshold);
	if (grids.size() == 81){
		grids = getSortedGridsByCoord(grids);
        if(!OCREngine){
            OCREngine = new basicOCR();
        }
		rv.boardArr = extractNumbersFromBoard(boardGray, grids);
        rv.boardGray = boardGray;
        cvResetImageROI(rv.boardGray);
        rv.grids = grids;
        rv.success = true;
        //        if (OCREngine){
        //            delete OCREngine;
        //            OCREngine = 0;
        //        }
	}
	return rv;
}

vector<CvRect> findGridsByXYVectors(IplImage *boardGray, int initialThreshold){
	int blockSize = MIN(boardGray->width, boardGray->height) / 9 |1; // quarter of a grid as block size
	int **rowSum, **colSum;
	IplImage* boardBinary = cvCreateImage(cvGetSize(boardGray), 8, 1);
	cvAdaptiveThreshold(boardGray, boardBinary, 255, CV_ADAPTIVE_THRESH_GAUSSIAN_C, CV_THRESH_BINARY, blockSize);
	calcLocalizedSumVectors(boardBinary, &rowSum, &colSum);
	//debug_dump_array(xsum, boardBlur->height, "d:\\plot\\x.txt");
	//debug_dump_array(colSum[0], boardBinary->width, "d:\\plot\\colsum0.txt");
	vector<int> horizontal_extremas[9];
	vector<int> vertical_extremas[9];
	bool isGridValid = true;
	//build get extremas from vector sum
	for(int i=0; i<9 && isGridValid; i++){
		horizontal_extremas[i].reserve(10);
		vertical_extremas[i].reserve(10);
		findExtremasFromSumVector(colSum[i], vertical_extremas[i], 0, boardGray->width-1, ExtremaSearchMinSpaceRatio * boardGray->width / 9);
		sort(vertical_extremas[i].begin(), vertical_extremas[i].end());
		findExtremasFromSumVector(rowSum[i], horizontal_extremas[i], 0, boardGray->height-1, ExtremaSearchMinSpaceRatio * boardGray->height / 9);
		sort(horizontal_extremas[i].begin(), horizontal_extremas[i].end());
		isGridValid = vertical_extremas[i].size() >= 10 && horizontal_extremas[i].size() >= 10;
		if(!isGridValid){
			//debug_dump_array(rowSum[i], boardGray->height, "d:\\plot\\he.txt");
			//debug_dump_array(colSum[i], boardGray->width, "d:\\plot\\ve.txt");
 			//showImage(boardGray, "horizontal sum");
		}
	}
	//free vector sum
	for(int i=0; i<9; i++){
		delete colSum[i];
		delete rowSum[i];
	}
	delete colSum;
	delete rowSum;
	vector<CvRect> rv;
	if (!isGridValid){
		return rv;
	}
	rv.reserve(81);
	for(int row = 0; row < 9; row++){
		for(int col = 0; col <9; col++){
			rv.push_back(cvRect(
                                vertical_extremas[row].at(col), 
                                horizontal_extremas[col].at(row), 
                                vertical_extremas[row].at(col+1) - vertical_extremas[row].at(col),
                                horizontal_extremas[col].at(row+1) - horizontal_extremas[col].at(row)));
		}
	}
 	drawGrids(boardGray, rv);
	return rv;
}

void calcLocalizedSumVectors(IplImage *boardGray, int*** rowSum, int*** colSum){
	(*rowSum) = new int*[9];
	(*colSum) = new int*[9];
	for(int i =0; i<9; i++){
		(*colSum)[i] = new int[boardGray->width];
		for(int j=0; j<boardGray->width; j++){
			(*colSum)[i][j] = 0;
		}
		(*rowSum)[i] = new int[boardGray->height];
		for(int j=0; j<boardGray->height; j++){
			(*rowSum)[i][j] = 0;
		}
	}
	float bracketSizeRow = (float) boardGray->width / 9;
	float bracketSizeCol = (float) boardGray->height / 9;
	IplConvKernel *kerode_horiz = cvCreateStructuringElementEx(3, 1, 1, 0, CV_SHAPE_RECT);
	IplConvKernel *kerode_vert = cvCreateStructuringElementEx(1, 3, 0, 1, CV_SHAPE_RECT);
	IplImage* eroded_hor = cvCreateImage(cvGetSize(boardGray), 8, 1);
	IplImage* eroded_ver = cvCreateImage(cvGetSize(boardGray), 8, 1);
	cvErode(boardGray, eroded_hor, kerode_horiz);
	cvErode(boardGray, eroded_ver, kerode_vert);
	cvReleaseStructuringElement(&kerode_horiz);
	cvReleaseStructuringElement(&kerode_vert);
	//showImage(eroded_hor, "eroded hor");
	//showImage(eroded_ver, "eroded vert");
	for(int y=0; y<boardGray->height; y++){
		uchar* rowbegin_hor = (uchar*) (eroded_hor->imageData + y * boardGray->widthStep);
		uchar* rowbegin_ver = (uchar*) (eroded_ver->imageData + y * boardGray->widthStep);
		int colBracket = floor((float)y/bracketSizeCol);
		for(int x=0; x<boardGray->width; x++){
			int rowBracket = floor((float)x/bracketSizeRow);
			(*rowSum)[rowBracket][y] += (uchar) rowbegin_ver[x];
			(*colSum)[colBracket][x] += (uchar) rowbegin_hor[x];
		}
	}
	cvReleaseImage(&eroded_hor);
	cvReleaseImage(&eroded_ver);
}

void findExtremasFromSumVector(int* sumVector, vector<int>&extremaIndice, int lowerBound, int upperBound, int minSpace){
	if (upperBound <= lowerBound){
		return;
	}
	int minIndex  = lowerBound;
	int extremaThickness = 1;
	for(int i=lowerBound+1; i<upperBound; i++){
		if (sumVector[minIndex] >= sumVector[i]){
			if(i == minIndex+1 && sumVector[minIndex] == sumVector[i]){
				extremaThickness ++;
			}else{
				extremaThickness = 1;
			}
			minIndex = i;
		}
	}
	minIndex -= extremaThickness /2 ;
	extremaIndice.push_back(minIndex);
	findExtremasFromSumVector(sumVector, extremaIndice, lowerBound, minIndex-minSpace, minSpace);
	findExtremasFromSumVector(sumVector, extremaIndice, minSpace+minIndex, upperBound, minSpace);
}

vector<CvRect> findGridsByThreshold(IplImage *board, int initialThreshold){
	// larger block size is beneficial to noisy images 
	// smaller block size seems to mess up lines near the edge of the board
	int blockSize = MIN(board->width, board->height) / 9 |1; // block size other than 9 causes some small sized puzzles to stop recognizing
	CvRect expandedRoi = cvRect(blockSize/2, blockSize/2, board->width, board->height);
	CvScalar paddingValue = cvScalar(255);
	IplImage *boardBinary = cvCreateImage(cvGetSize(board), 8, 1);
	IplImage *expanded = cvCreateImage(cvSize(board->width + blockSize, board->height + blockSize), 8, 1);
	cvCopyMakeBorder(board, expanded, cvPoint(blockSize/2, blockSize/2), IPL_BORDER_CONSTANT, paddingValue);
	cvAdaptiveThreshold(expanded, expanded, 255,CV_ADAPTIVE_THRESH_GAUSSIAN_C, CV_THRESH_BINARY, blockSize, initialThreshold);
	cvSetImageROI(expanded, expandedRoi);
	cvCopy(expanded, boardBinary);
	showImage(boardBinary, "recognize high contrast ratio 1");
	vector<CvRect> grids = getAllGrids(boardBinary);
	//drawGrids(board, grids);
	for(int i=2; i<10 && grids.size()<81; i++){
		cvReleaseImage(&boardBinary);
		cvReleaseImage(&expanded);
		boardBinary = cvCreateImage(cvGetSize(board), 8, 1);
		expanded = cvCreateImage(cvSize(board->width + blockSize, board->height + blockSize), 8, 1);
		cvCopyMakeBorder(board, expanded, cvPoint(blockSize/2, blockSize/2), IPL_BORDER_CONSTANT, paddingValue);
		int gridThreshold = initialThreshold + GridSearchThresholdIncrementAmount *(i/2) * (i%2?1:-1);
		cvAdaptiveThreshold(expanded, expanded, 255,CV_ADAPTIVE_THRESH_GAUSSIAN_C, CV_THRESH_BINARY, blockSize, gridThreshold);
		cvSetImageROI(expanded, expandedRoi);
		cvCopy(expanded, boardBinary);
		showImage(boardBinary, "recognize high contrast ratio loop");
		grids = getAllGrids(boardBinary);
		drawGrids(board, grids);
	}
	cvReleaseImage(&boardBinary);
	cvReleaseImage(&expanded);
	return grids;
}

int ** extractNumbersFromBoard(IplImage *boardGray, vector<CvRect> &grids){
	int index = 0;
	int** rv = new int*[9];
	for(int i=0; i<9; i++){
		rv[i] = new int[9];
	}
	for (int i=0; i<81; i++) {
		rv[i/9][i%9] = -1;
	}
	for(vector<CvRect>::iterator it = grids.begin(); it!=grids.end() && index<81; it++){
		cvSetImageROI(boardGray, *it);
		IplImage *grid = cvCreateImage(cvGetSize(boardGray), 8, 1);
		int characterGrayValue = findCharacterShadingThreshold(boardGray);
		int blockSize = MIN(grid->width, grid->height)|1;
		cvAdaptiveThreshold(boardGray, grid, 255, CV_ADAPTIVE_THRESH_MEAN_C, CV_THRESH_BINARY, blockSize, characterGrayValue);
		setNoiselessGridRoi(grid, 0, 0, grid->width, grid->height);
		IplImage *noiselessGrid = cvCreateImage(cvGetSize(grid), 8, 1);
		cvCopy(grid, noiselessGrid);
		cleanUpScatteredNoise(noiselessGrid, NoiseThreshold);
		int allWhiteSum = noiselessGrid->width * noiselessGrid->height * 255;
		int sum = cvSum(noiselessGrid).val[0];
		cvReleaseImage(&grid);
		if ( sum > 0.98 * allWhiteSum || sum < allWhiteSum * 0.03){
			rv[index/9][index%9] = 0;
		}else{
			int guess = (int) OCREngine->classify(noiselessGrid, showOcrResult);
			rv[index/9][index%9] = guess;
		}
		index++;
		cvReleaseImage(&noiselessGrid);
        cvReleaseImage(&grid);
	}
	return rv;
}

void cleanUpScatteredNoise(IplImage* grid, int noiseThreshold){
	cvSmooth(grid, grid, CV_BLUR);
	cvThreshold(grid, grid, noiseThreshold, 255, CV_THRESH_BINARY);
}

IplImage* findSudokuBoard(IplImage *fullSrc, int &backgroundThresholdUsed){
	IplImage *fullSrcGray = cvCreateImage(cvGetSize(fullSrc), 8, 1);
	cvCvtColor(fullSrc, fullSrcGray, CV_BGR2GRAY);
	IplImage *resized = normalizeSourceImageSize(fullSrcGray);
	if (resized){
		cvReleaseImage(&fullSrcGray);
		fullSrcGray = resized;
	}
	showImage(fullSrcGray, "findSudokuBoard original gray");
	IplImage *fullSrcGrayBlurred = cvCloneImage(fullSrcGray);
	IplImage *rv = 0;
	cvSmooth(fullSrcGray, fullSrcGrayBlurred, CV_GAUSSIAN);
	int blockSize = MIN(fullSrcGray->width, fullSrcGray->height) / 9 |1;
	for (int i=0; i<BoardThresholdCandidateSize && !rv; i++){
		backgroundThresholdUsed = BoardThresholdCandidates[i];
		IplImage *fullSrcInverted = cvCreateImage(cvGetSize(fullSrcGray), 8, 1);
		IplImage *fullSrcBinary = cvCreateImage(cvGetSize(fullSrcGray), 8, 1);
		CvMemStorage* storage = cvCreateMemStorage(0);
		CvSeq* contours = 0;
		cvAdaptiveThreshold(fullSrcGrayBlurred, fullSrcInverted, 255, CV_ADAPTIVE_THRESH_MEAN_C, CV_THRESH_BINARY_INV, blockSize, backgroundThresholdUsed);
		cvAdaptiveThreshold(fullSrcGrayBlurred, fullSrcBinary, 255, CV_ADAPTIVE_THRESH_MEAN_C, CV_THRESH_BINARY, blockSize, backgroundThresholdUsed);
		showImage(fullSrcInverted, "findSudokuBoard inverted");
		cvFindContours(fullSrcInverted, storage, &contours, sizeof(CvContour), CV_RETR_TREE, CV_CHAIN_APPROX_SIMPLE);
		rv = findBoardFromContour(contours, fullSrcGray, fullSrcBinary);
		cvReleaseImage(&fullSrcInverted);
		cvReleaseImage(&fullSrcBinary);
		cvReleaseMemStorage(&storage);
	} 
	showImage(rv, "found board");
	cvReleaseImage(&fullSrcGray);
	cvReleaseImage(&fullSrcGrayBlurred);
	return rv;
}

vector<CvRect> getAllGrids(IplImage *boardBinary){
	vector<CvRect> grids;
	CvMemStorage *storage = cvCreateMemStorage(0);
	CvSeq *contour = 0;
	IplImage *gameBoardScrap = cvCloneImage(boardBinary);
	cvFindContours(gameBoardScrap, storage, &contour, sizeof(CvContour), CV_RETR_LIST, CV_CHAIN_APPROX_SIMPLE);
	drawContour(boardBinary, contour, 3);
	cvReleaseImage(&gameBoardScrap);
	CvSeq * cur = contour;
	int widthLB = MAX(boardBinary->width / 9 /2, 10);
	int widthUB = boardBinary->width / 7;
	int heightLB = MAX(boardBinary->height / 9 /2, 10);
	int heightUB = boardBinary->height /7;
	while(cur){
		if (cur->total >=4){
			int left, right, top, bottom;
			findExtremas(cur, left, right, top, bottom);
			int width = right - left+1;
			int height = bottom - top + 1;
			if (width >widthLB && width <widthUB && height > heightLB && height < heightUB){
				CvRect roi = setNoiselessGridRoi(boardBinary, left+1, top+1, right-left-2, bottom-top-2);
				if (roi.width > 0 && roi.height >0){
					grids.push_back(roi);
				}
			}
		}
		cur = cur->h_next;
	}
	cvResetImageROI(boardBinary);
	cvReleaseMemStorage(&storage);
	return grids;
}

vector<CvRect> getSortedGridsByCoord(vector<CvRect> &grids){
	vector<CvRect> rv;
	sort(grids.begin(), grids.end(), rectangleCmpByPositionY);
	for(int i=0; i<81; i+=9){
		vector<CvRect> row(grids.begin()+i, grids.begin()+9+i);
		sort(row.begin(), row.end(), rectangleCmpByPositionX);
		rv.insert(rv.end(), row.begin(), row.end());
	}
	return rv;
}

static bool rectangleCmpByPositionX(const CvRect& a, const CvRect &b){
	return a.x < b.x;
}

static bool rectangleCmpByPositionY(const CvRect& a, const CvRect &b){
	return a.y < b.y;
}

CvRect setNoiselessGridRoi(IplImage* boardBinary, int x, int y, int width, int height){
	bool hasNoise = true;
	int limit = MIN(width/3, height/3);
	CvMat border;
	CvRect roi;
	while(hasNoise && limit >= 0){
		limit --;
		hasNoise = false;
		roi = cvRect(x, y, width, height);
		cvSetImageROI(boardBinary, roi);
        
		//detect noise top
		cvGetRow(boardBinary, &border, 0);
		CvScalar top = cvSum(&border);
		if (top.val[0] != roi.width*255){
			hasNoise = true;
		}
		//contract bottom
		cvGetRow(boardBinary, &border, roi.height-1);
		CvScalar bottom = cvSum(&border);
		if (bottom.val[0] != roi.width* 255){
			hasNoise = true;
		}
		//contract left
		cvGetCol(boardBinary, &border, 0);
		CvScalar left = cvSum(&border);
		if (left.val[0] != roi.height * 255){
			hasNoise = true;
		}
		//contract right
		cvGetCol(boardBinary, &border, roi.width-1);
		CvScalar right = cvSum(&border);
		if (right.val[0] != roi.height * 255){
			hasNoise = true;
		}
		if (hasNoise){
			x++;
			y++;
			width-=2;
			height-=2;
		}
	}
	if (hasNoise && limit <0){
		return cvRect(0,0,0,0);
	}
	return roi;
}

IplImage* findBoardFromContour(CvSeq* curNode, IplImage* fullSrcGray, IplImage *fullSrcBinary){
	if (curNode == 0) return 0;
	int numSiblings = 0;
	IplImage *board;
	
	for(CvSeq* sibling = curNode; sibling; sibling = sibling->h_next){
		numSiblings++;
		board = findBoardFromContour(sibling->v_next, fullSrcGray, fullSrcBinary);
		if (board) {
			return board;
		}
	}
	if (numSiblings >= 72 && numSiblings<=90 && (board = doesResembleBoard(curNode->v_prev, fullSrcGray, fullSrcBinary))!=0){
		//drawContour(fullSrcGray, curNode);
		return board;
	}
	return 0;
}

IplImage* doesResembleBoard(CvSeq* contours, IplImage* fullSrcGray, IplImage *fullSrcBinary){
	if (!contours){
		return 0;
	}
	IplImage *rv = 0;
	int left, right, top, bottom;
	findExtremas(contours, left, right, top, bottom);
	////////////
	// sub image
	IplImage* potentialBoardRoi = getROIAsImageRef(fullSrcBinary, left, right, top, bottom);
    IplImage* color_dst = 0;
	if (debug_showImage){
		color_dst = cvCreateImage( cvGetSize(potentialBoardRoi), 8, 3 );
		cvCvtColor(potentialBoardRoi, color_dst, CV_GRAY2BGR);
	}
    CvMemStorage* storage = cvCreateMemStorage(0);
    CvSeq *boardLines = 0;
    IplImage* roiEdges = cvCreateImage(cvGetSize(potentialBoardRoi), 8, 1);
	cvCanny(potentialBoardRoi, roiEdges, 50, 200);
	
	int houghThreshold = MIN(cvGetSize(potentialBoardRoi).width, cvGetSize(potentialBoardRoi).height) /3;
	boardLines = cvHoughLines2(roiEdges, storage, CV_HOUGH_STANDARD, 1, CV_PI/180, houghThreshold, 0, 0);
	cvReleaseImage(&roiEdges);
	if (boardLines->total >= 16) { // must have at least 20 lines to form a 9x9 grid, but do allow approximation
		CvScalar lineSlopeFreq[18]; // make 18 bins to hold the lines, so that every 10 degrees get 1 bin
		for(int i=0; i<18; i++){
			lineSlopeFreq[i] = cvScalar(0,0);
		}
		//also for every CvScalar quadruplet:
		//[0] contains the count of the number of lines that are in the bin
		//[1] contains the average degree of tilt calculated from the degrees of the individual lines
		int freqLineCount = 18;
		for(int i = 0; i < boardLines->total; i++ )
		{
			float* line = (float*)cvGetSeqElem(boardLines,i);
			float theta = line[1];
			float rho = line[0];
			float degree = radiantToDegree(theta);
			updateLineSlopeFreq(lineSlopeFreq, freqLineCount, degree);
			// show lines
			if (debug_showImage){
				CvPoint pt1, pt2;
				double a = cos(theta), b = sin(theta);
				double x0 = a*rho, y0 = b*rho;
				pt1.x = cvRound(x0 + 1000*(-b));
				pt1.y = cvRound(y0 + 1000*(a));
				pt2.x = cvRound(x0 - 1000*(-b));
				pt2.y = cvRound(y0 - 1000*(a));
				cvLine(color_dst, pt1, pt2, CV_RGB(255,0,0), 1, 8); 
			}
		}
		int highIndex=-1, secondIndex=-2;
		//debug_dump_array(lineSlopeFreq, freqLineCount, "d:\\plot\\slopeCount.txt");
		findLineOccurenceBySlope(lineSlopeFreq, freqLineCount, highIndex, secondIndex);
		// check to see if lines of highest and second highest counts (in degree) are somewhat perpendicular, and that they are not tilted too badly
		float slopeDifference = abs(lineSlopeFreq[highIndex].val[1] - lineSlopeFreq[secondIndex].val[1]);
		float degreeOfTilt = lineSlopeFreq[highIndex].val[1];
		if ( abs(slopeDifference-90) < SlopeLineToleranceInDegree && 
			(degreeOfTilt < BoardTiltTolerance || 
             degreeOfTilt > 180 - BoardTiltTolerance || 
             (degreeOfTilt > 90 - BoardTiltTolerance && degreeOfTilt < 90 + BoardTiltTolerance))){
                // pick a side (width or height) as the number to be checked against in rho distribution check
                int boardSpace;
                if (lineSlopeFreq[highIndex].val[0] == lineSlopeFreq[secondIndex].val[0]){
                    boardSpace = MAX(right-left, bottom-top);
                }else{
                    
                    boardSpace = lineSlopeFreq[highIndex] .val[1] > 45 && lineSlopeFreq[highIndex] .val[1] < 135 ? bottom - top:  right-left;
                }
                bool distributionCheck = checkLineDistributionByRho(boardLines, lineSlopeFreq[highIndex].val[1], boardSpace);
                if (distributionCheck){
                    distributionCheck = checkLineDistributionByRho(boardLines, lineSlopeFreq[secondIndex].val[1], boardSpace);
                }
                if (distributionCheck){
                    int padding = (right-left) / 18;
                    int roiLeft = MAX(left-padding, 0);
                    int roiRight = MIN(right+padding, fullSrcGray->width-1);
                    int roiTop = MAX(top-padding, 0);
                    int roiBottom = MIN(bottom+padding, fullSrcGray->height-1);
                    IplImage* potentialBoardNoBorder = getROIAsImageRef(fullSrcGray,roiLeft, roiRight, roiTop, roiBottom);
                    rv = extractAndSetBoardUpRight(contours,cvPoint(roiLeft, roiTop), potentialBoardNoBorder, degreeOfTilt);
                    cvReleaseImageHeader(&potentialBoardNoBorder);
                }
            }
	}
	showImage(color_dst, "potential board with line overlay");
	if (color_dst){
		cvReleaseImage(&color_dst);
	}
	cvReleaseMemStorage(&storage);
    cvReleaseImageHeader(&potentialBoardRoi);
    
	return rv;
}

bool checkLineDistributionByRho(CvSeq *boardLines, float pivotLineTheta, int boardSpace){
	vector<int> rhos;
	rhos.reserve(boardLines->total);
	for(int i=0; i<boardLines->total ; i++){
		float* line = (float*)cvGetSeqElem(boardLines,i);
		float theta = line[1], rho = line[0];
		if (areLinesSimilarInSlope(radiantToDegree(theta), pivotLineTheta)){
			rhos.push_back(rho);
		}
	}
	if(rhos.size() < 1){
		return false;
	}
	int firstRho=rhos[0], lastRho=rhos[0];
	for(int i=1; i<rhos.size(); i++){
		if (firstRho > rhos[i]){
			firstRho = rhos[i];
		}
		if (lastRho < rhos[i]){
			lastRho = rhos[i];
		}
	}
	// normalize so that firstRho is 0;
	int offset = -firstRho;
	for(int i=0; i<rhos.size(); i++){
		rhos[i] += offset;
	}
	firstRho += offset;
	lastRho += offset;
	if (lastRho < boardSpace /2){
		return false;
	}
	int roundingAmount = lastRho / 9 / 10;
	int averageDistance = lastRho/9;
	int numDistributionMarks = 11;
	int distributionMark[] = {0,0,0,0,0, 0,0,0,0,0, 0};
	for (int i=0; i<rhos.size(); i++){
		int markIndex = (rhos[i] + roundingAmount) / averageDistance;
		distributionMark[ markIndex ] = 1;
	}
	int matches = 0;
	for(int i=0; i<numDistributionMarks; i++){
		matches += distributionMark[i];
	}
	return matches >= 5;
}

void findLineOccurenceBySlope(CvScalar *lineSlopeFreq, int freqLineCount, int &highIndex, int &secondIndex){
	if (lineSlopeFreq[0].val[0] > lineSlopeFreq[1].val[0]){
		highIndex = 0;
		secondIndex = 1;
	}else{
		highIndex = 1;
		secondIndex = 0;
	}
	for (int i=2; i<freqLineCount; i++){
		int count = lineSlopeFreq[i].val[0];
		if (count >= lineSlopeFreq[highIndex].val[0] && 
			count > lineSlopeFreq[secondIndex].val[0]){
			secondIndex = highIndex;
			highIndex = i;
		}else if (count > lineSlopeFreq[secondIndex].val[0]){
			secondIndex = i;
		}
	}
}

IplImage *getROIAsImageRef(IplImage* img, int left, int right, int top, int bottom){
	IplImage* rv = cvCreateImageHeader(cvSize(right-left+1, bottom-top+1), img->depth, img->nChannels);
	rv->widthStep = img->widthStep;
	rv->imageData = img->imageData + top * img->widthStep + left * img->nChannels;
	return rv;
}

IplImage* extractAndSetBoardUpRight(CvSeq* contours, const CvPoint& contourOffset, IplImage* potentialBoardRoi, float degreeOfHighestCount){
	IplImage *upRight = cvCreateImage(cvGetSize(potentialBoardRoi), 8, 1);
	IplImage *mask_src = cvCreateImage(cvGetSize(potentialBoardRoi), 8, 1);
	IplImage *mask_dst = cvCreateImage(cvGetSize(potentialBoardRoi), 8, 1);
	cvZero(mask_src);
	CvPoint *points = new CvPoint[contours->total];
	cvCvtSeqToArray(contours, points);
	for(int i=0; i<contours->total; i++){
		points[i].x -= contourOffset.x;
		points[i].y -= contourOffset.y;
	}
	cvFillConvexPoly(mask_src, points, contours->total, cvScalar(255));
	
	delete points;
	Mat src = potentialBoardRoi;
	Mat dst = upRight;
	Mat mat_mask_src = mask_src;
	Mat mat_mask_dst = mask_dst;
	Point2f src_center(src.cols/2.0F, src.rows/2.0F);
    
	double angle = degreeOfHighestCount - 90; // assume horizontal
	if (degreeOfHighestCount < 45){ // somewhat horizontal
		angle = degreeOfHighestCount;
	}else if (degreeOfHighestCount>135){ // tilted counter-clockwise, re-orient by rotating clock-wise
		angle = degreeOfHighestCount - 180;
	}
	Mat rot_mat = getRotationMatrix2D(src_center, angle, 1.0);
    warpAffine(src, dst, rot_mat, src.size());
	warpAffine(mat_mask_src, mat_mask_dst, rot_mat, src.size());
	cvReleaseImage(&mask_src);
	CvRect boardRoi = findRectFromMask(mask_dst);
	cvSetImageROI(upRight, boardRoi);
	cvSetImageROI(mask_dst, boardRoi);
	IplImage *rv = cvCreateImage(cvSize(boardRoi.width, boardRoi.height), 8, 1);
	cvSet(rv, cvScalar(255));
	cvCopy(upRight, rv, mask_dst);
	cvReleaseImage(&mask_dst);
	cvReleaseImage(&upRight);
	return rv;
}

/*
 count the occurence of lines by their degree of tilt 
 */
void updateLineSlopeFreq(CvScalar* lineSlopeFreq, int lineCount, float degree){
	int bin = degree / (180/lineCount);
	lineSlopeFreq[bin].val[0] += 1;
	if (lineSlopeFreq[bin].val[1] == 0){
		lineSlopeFreq[bin].val[1] = degree;
	}else{
		lineSlopeFreq[bin].val[1] = (lineSlopeFreq[bin].val[1] + degree) /2;
	}
}

bool areLinesSimilarInSlope(float theta1, float theta2){
	//theta1 and theta2 are in degrees (as supposed to radiant)
	//return (theta1 > theta2 - SlopeLineToleranceInDegree && theta1 < theta2 + SlopeLineTolerance) || (CV_PI - abs(theta2 - theta1) < SlopeLineTolerance);
	return abs(theta1-theta2) < SlopeLineToleranceInDegree || 
    180-max(theta1, theta2) + min(theta1, theta2) < SlopeLineToleranceInDegree;
}

//inclusive
void findExtremas(CvSeq* contour, int &left, int &right, int &top, int &bottom){
	right = bottom = -1;
	left = 1 << 30;
	top = 1 << 30;
	for (int i=0; i<contour->total; i++){
		CvPoint* p = (CvPoint*) cvGetSeqElem(contour, i);
		left = MIN(left, p->x);
		right = MAX(right, p->x);
		top = MIN(top, p->y);
		bottom = MAX(bottom, p->y);
	}
}


int findCharacterShadingThreshold(IplImage* img){
	// look for 2 gray scale value with highest frequencies, the first and second highest gray values should be at least a certain distance apart
	// the first highest is most likely to be the background
	// the second highest is most likely to be the foreground character gray scale value
	// if there is only 1 extrema, it is likely that the image contains no characters at all
	int minDistance = 255/8;
	long pixSum = 0;
	IplImage *blurred = cvCreateImage(cvGetSize(img), 8, 1);
	cvSmooth(img, blurred, CV_GAUSSIAN, 3);
	//cvCopy(img, blurred);
	//showImage(blurred, "findCharacterShadingThreshold blurred");
	int freq[256] = {0};
	for(int y=0; y<blurred->height; y++){
		uchar* rowbegin = (uchar*) (blurred->imageData + y * blurred->widthStep);
		for(int x=0; x<blurred->width; x++){
			int grayValue = (int)(rowbegin[x]); 
			freq[ grayValue ] ++;
			pixSum += grayValue;
		}
	}
	int totalPix = (blurred->width)*(blurred->height);
	long avgShade = pixSum / totalPix;
	cvReleaseImage(&blurred);
	int highestIndex = 255;
	for(int i=254; i>=255/6; i--){
		if (freq[i] >= freq[highestIndex]){
			highestIndex = i;
		}
	}
	int secondHighestIndex = 0;
	for(int i=1; i<highestIndex-minDistance; i++){
		if (freq[i] >= freq[secondHighestIndex]){
			secondHighestIndex = i;
		}
	}
	int fgCount = 0;
	for(int i=0; i<(highestIndex - secondHighestIndex)/2 + secondHighestIndex; i++){
		fgCount += freq[i];
	}
	int fgThreshold = sqrt((double)totalPix);
	if (fgCount < fgThreshold){ 
		return -255;
	}
	return (avgShade - secondHighestIndex) * 0.5;
}

// if input image is exceedingly big, down size it, otherwise return null
IplImage *normalizeSourceImageSize(IplImage *sourceImage){
	IplImage *rv = 0;
	if (MAX(sourceImage->width, sourceImage->height) > InputImageNormalizeLength){
		int normalizedWidth, normalizedHeight;
		if(sourceImage->width > sourceImage->height){
			normalizedWidth = InputImageNormalizeLength;
			normalizedHeight = InputImageNormalizeLength / sourceImage->width * sourceImage->height;
		}else{
			normalizedHeight = InputImageNormalizeLength;
			normalizedWidth = InputImageNormalizeLength / sourceImage->height * sourceImage->width;
		}
		rv = cvCreateImage(cvSize(normalizedWidth, normalizedHeight), sourceImage->depth, sourceImage->nChannels);
		cvResize(sourceImage, rv);
	}
	
	return rv;
}

void drawGrids(IplImage* background, vector<CvRect> grids){
	IplImage *bg = cvCreateImage(cvGetSize(background), 8, 3);
	if(background->nChannels == 1){
		cvCvtColor(background, bg, CV_GRAY2BGR);
	}else{
		cvCopy(background, bg);
	}
	int index = 0;
	for(vector<CvRect>::iterator it = grids.begin(); it != grids.end(); it++){
		CvScalar color = cvScalar(255,0,0);
		if (index%3==1) color = cvScalar(0,255,0);
		if (index%3==2) color = cvScalar(0,0,255);
		cvRectangle(bg, cvPoint(it->x, it->y), cvPoint(it->x + it->width, it->y + it->height), color);
		index++;
	}
	showImage(bg, "draw grids", 0);
}

void findXExtramas(IplImage* mask,int* min, int* max){
	int minFound=0;
	CvMat data;
	CvScalar val=cvRealScalar(0);
	//For each col sum, if sum < width*255 then we find the min
	//then continue to end to search the max, if sum< width*255 then is new max
	for (int i=0; i< mask->width; i++){
		cvGetCol(mask, &data, i);
		val= cvSum(&data);
		if(val.val[0] >0){
			*max= i;
			if(!minFound){
				*min= i;
				minFound= 1;
			}
		}
	}
}

void findYExtremas(IplImage* mask,int* min, int* max){
	int minFound=0;
	CvScalar val=cvRealScalar(0);
	//For each col sum, if sum < width*255 then we find the min
	//then continue to end to search the max, if sum< width*255 then is new max
	for (int i=0; i< mask->height; i++){
		CvMat data;
		cvGetRow(mask, &data, i);
		val= cvSum(&data);
		if(val.val[0] > 0){
			*max=i;
			if(!minFound){
				*min= i;
				minFound= 1;
			}
		}
	}
}

CvRect findRectFromMask(IplImage* mask){
	CvRect aux;
	int xmin, xmax, ymin, ymax;
	xmin=xmax=ymin=ymax=0;
	findXExtramas(mask, &xmin, &xmax);
	findYExtremas(mask, &ymin, &ymax);
	aux=cvRect(xmin, ymin, xmax-xmin, ymax-ymin);
	return aux;
}

void debug_dump_array(int *arr, int size, char* fileName){

}

void debug_dump_array(CvScalar* arr, int count, char* fileName){

}

void showImage(IplImage* img, char* title, bool forceDisplay){

}


void drawContour(IplImage* background, CvSeq *contours, int level){

}
