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

// Ported to the OpenCV 4 C++ API (cv::Mat) in 2026. Recognition logic and
// tuning constants are unchanged from the original IplImage implementation.

#include <algorithm>
#include <cmath>
#include "boardRecognizer.h"
#include "basicOCR.hpp"
#include <opencv2/imgproc.hpp>

using namespace std;
using namespace cv;

static bool showOcrResult = 0;

static basicOCR *OCREngine = 0;

static Mat findBoardFromContour(int curNode, const vector<vector<Point>> &contours,
                                const vector<Vec4i> &hierarchy,
                                const Mat &fullSrcGray, const Mat &fullSrcBinary);
static Mat doesResembleBoard(const vector<Point> &contour, const Mat &fullSrcGray, const Mat &fullSrcBinary);
static void findExtremas(const vector<Point> &contour, int &left, int &right, int &top, int &bottom);
static void updateLineSlopeFreq(Vec2d *lineSlopeFreq, int lineCount, float degree);
static int findCharacterShadingThreshold(const Mat &gridGray);
static bool rectangleCmpByPositionX(const Rect &a, const Rect &b);
static bool rectangleCmpByPositionY(const Rect &a, const Rect &b);
static void findLineOccurenceBySlope(const Vec2d *lineSlopeFreq, int freqLineCount, int &highIndex, int &secondIndex);
static bool checkLineDistributionByRho(const vector<Vec2f> &boardLines, float pivotLineTheta, int boardSpace);
static bool areLinesSimilarInSlope(float theta1, float theta2);
static int **extractNumbersFromBoard(const Mat &boardGray, vector<Rect> &grids);
static vector<Rect> getSortedGridsByCoord(vector<Rect> &grids);
static Mat normalizeSourceImageSize(const Mat &sourceImage);
static Rect findRectFromMask(const Mat &mask);
static void findYExtremas(const Mat &mask, int *min, int *max);
static void findXExtramas(const Mat &mask, int *min, int *max);
inline float radiantToDegree(float radiant){ return 180.0/CV_PI * radiant; }
inline float degreeToRadiant(float degree){ return CV_PI/180 * degree; }

static void findExtremasFromSumVector(const int *sumVector, vector<int> &extremas, int lowerBound, int upperBound, int minSpace);

//find the grids by suming pixel values for every row to discover y-position of the horizontal lines
//and then suming pixel values for every column to discover x-position of the veritical lines
//crossing the x- and y- positions will ultimately form 81 grids.
static vector<Rect> findGridsByXYVectors(const Mat &boardGray, int initialThreshold);

//when summing pixel values of each row, partition the image vertically into 9 equal parts; a row of black pixels yeild very low sum value
//search is conducted to find all 10 low extremas from the resulting sum array, and these are the y positions of all the soduko boxes.
//Similar partitioning is performed when summing the pixel values of each column.
//Reason for paritioning is to offset image distortion towards corners and edges of the puzzle.
static void calcLocalizedSumVectors(const Mat &boardBinary, vector<vector<int>> &rowSum, vector<vector<int>> &colSum);

//when pixel value sum is used to find extremas, this ratio is used to calculate how far the extrema is away from
//the next extrema in order for the next to be considered a valid candidate.
// this value is uesd to multiply the expected width or height of one grid
const float ExtremaSearchMinSpaceRatio = 0.75;

static void cleanUpScatteredNoise(Mat &grid, int noiseThreshold);
//142 is a magic number found by performing blur with block size of 3 on a 2x2 square black pixel cluster contained inside white background
//each of the 4 black pixels with 0 gray scale value become 142 after blur.
//This means a small blob of black pixels is considered noise if it has less than or equal to 4 black pixels in a 3x3 island
const int NoiseThreshold = 142;

//given a binary sudoku board image and a rectangle marking 1 single grid, keep
//contracting the rectangle until the 4 sides are completely white (noiseless)
static Rect noiselessGridRect(const Mat &boardBinary, int x, int y, int width, int height);

//unprocessedBoard is the image bound by the contour, this function should return a copy of
// it with it set up-right, with the information provided by degreeOfHighestCount, which
// can be about ~0 degree or ~CV_?PI/2, plus or minus the value of SlopeLinetolerance
static Mat extractAndSetBoardUpRight(const vector<Point> &contour, const Point &contourOffset,
                                     const Mat &potentialBoardRoi, float degreeOfHighestCount);

//when parsing lines which form a potential sudoku board, consider multiple lines
//the same degree as long as they fall in this tolerance
static double SlopeLineToleranceInDegree = 5;

//only accept images that are titled no more than this angle
static int BoardTiltTolerance = 30;

//if input image is large, try to resize it to this size proportionally. The longer leg between width and height will use this size
const double InputImageNormalizeLength = 800;

static int BoardThresholdCandidateSize = 4;
static int BoardThresholdCandidates[] = {1, 5, 10, 20};

void recognizerResultPack::destroy(){
    boardGray.release();
    if (boardArr){
        for(int i=0; i<9; i++){
            delete[] boardArr[i];
        }
        delete[] boardArr;
        boardArr = 0;
    }
}

recognizerResultPack recognizeBoardFromPhoto(const Mat &imageInput){
    recognizerResultPack rv;
    rv.success = false;
    int backgroundThresholdMark;
    Mat board = findSudokuBoard(imageInput, backgroundThresholdMark);
    if (board.empty()){
        return rv;
    }
    return recognizeFromBoard(board, backgroundThresholdMark);
}

recognizerResultPack recognizeFromBoard(const Mat &boardGray, int initialBoardThreshold){
    recognizerResultPack rv;
    rv.success = false;
    vector<Rect> grids = findGridsByXYVectors(boardGray, initialBoardThreshold);
    if (grids.size() == 81){
        grids = getSortedGridsByCoord(grids);
        if(!OCREngine){
            OCREngine = new basicOCR();
        }
        rv.boardArr = extractNumbersFromBoard(boardGray, grids);
        rv.boardGray = boardGray;
        rv.grids = grids;
        rv.success = true;
    }
    return rv;
}

static vector<Rect> findGridsByXYVectors(const Mat &boardGray, int initialThreshold){
    int blockSize = MIN(boardGray.cols, boardGray.rows) / 9 | 1; // quarter of a grid as block size
    Mat boardBinary;
    // the old C API applied its default constant of 5 when none was given
    adaptiveThreshold(boardGray, boardBinary, 255, ADAPTIVE_THRESH_GAUSSIAN_C, THRESH_BINARY, blockSize, 5);
    vector<vector<int>> rowSum, colSum;
    calcLocalizedSumVectors(boardBinary, rowSum, colSum);
    vector<int> horizontal_extremas[9];
    vector<int> vertical_extremas[9];
    bool isGridValid = true;
    //build get extremas from vector sum
    for(int i=0; i<9 && isGridValid; i++){
        horizontal_extremas[i].reserve(10);
        vertical_extremas[i].reserve(10);
        findExtremasFromSumVector(colSum[i].data(), vertical_extremas[i], 0, boardGray.cols-1, ExtremaSearchMinSpaceRatio * boardGray.cols / 9);
        sort(vertical_extremas[i].begin(), vertical_extremas[i].end());
        findExtremasFromSumVector(rowSum[i].data(), horizontal_extremas[i], 0, boardGray.rows-1, ExtremaSearchMinSpaceRatio * boardGray.rows / 9);
        sort(horizontal_extremas[i].begin(), horizontal_extremas[i].end());
        isGridValid = vertical_extremas[i].size() >= 10 && horizontal_extremas[i].size() >= 10;
    }
    vector<Rect> rv;
    if (!isGridValid){
        return rv;
    }
    rv.reserve(81);
    for(int row = 0; row < 9; row++){
        for(int col = 0; col < 9; col++){
            rv.push_back(Rect(
                              vertical_extremas[row].at(col),
                              horizontal_extremas[col].at(row),
                              vertical_extremas[row].at(col+1) - vertical_extremas[row].at(col),
                              horizontal_extremas[col].at(row+1) - horizontal_extremas[col].at(row)));
        }
    }
    return rv;
}

static void calcLocalizedSumVectors(const Mat &boardBinary, vector<vector<int>> &rowSum, vector<vector<int>> &colSum){
    rowSum.assign(9, vector<int>(boardBinary.rows, 0));
    colSum.assign(9, vector<int>(boardBinary.cols, 0));
    float bracketSizeRow = (float) boardBinary.cols / 9;
    float bracketSizeCol = (float) boardBinary.rows / 9;
    Mat kerode_horiz = getStructuringElement(MORPH_RECT, Size(3, 1), Point(1, 0));
    Mat kerode_vert = getStructuringElement(MORPH_RECT, Size(1, 3), Point(0, 1));
    Mat eroded_hor, eroded_ver;
    erode(boardBinary, eroded_hor, kerode_horiz);
    erode(boardBinary, eroded_ver, kerode_vert);
    for(int y=0; y<boardBinary.rows; y++){
        const uchar *rowbegin_hor = eroded_hor.ptr<uchar>(y);
        const uchar *rowbegin_ver = eroded_ver.ptr<uchar>(y);
        int colBracket = (int)floor((float)y / bracketSizeCol);
        for(int x=0; x<boardBinary.cols; x++){
            int rowBracket = (int)floor((float)x / bracketSizeRow);
            rowSum[rowBracket][y] += rowbegin_ver[x];
            colSum[colBracket][x] += rowbegin_hor[x];
        }
    }
}

static void findExtremasFromSumVector(const int *sumVector, vector<int> &extremaIndice, int lowerBound, int upperBound, int minSpace){
    if (upperBound <= lowerBound){
        return;
    }
    int minIndex = lowerBound;
    int extremaThickness = 1;
    for(int i=lowerBound+1; i<upperBound; i++){
        if (sumVector[minIndex] >= sumVector[i]){
            if(i == minIndex+1 && sumVector[minIndex] == sumVector[i]){
                extremaThickness++;
            }else{
                extremaThickness = 1;
            }
            minIndex = i;
        }
    }
    minIndex -= extremaThickness / 2;
    extremaIndice.push_back(minIndex);
    findExtremasFromSumVector(sumVector, extremaIndice, lowerBound, minIndex-minSpace, minSpace);
    findExtremasFromSumVector(sumVector, extremaIndice, minSpace+minIndex, upperBound, minSpace);
}

static int **extractNumbersFromBoard(const Mat &boardGray, vector<Rect> &grids){
    int index = 0;
    int **rv = new int*[9];
    for(int i=0; i<9; i++){
        rv[i] = new int[9];
    }
    for (int i=0; i<81; i++) {
        rv[i/9][i%9] = -1;
    }
    for(vector<Rect>::iterator it = grids.begin(); it != grids.end() && index < 81; ++it, ++index){
        Rect gridRect = *it & Rect(0, 0, boardGray.cols, boardGray.rows);
        if (gridRect.width <= 2 || gridRect.height <= 2){
            rv[index/9][index%9] = 0;
            continue;
        }
        Mat cellGray = boardGray(gridRect);
        int characterGrayValue = findCharacterShadingThreshold(cellGray);
        int blockSize = MIN(cellGray.cols, cellGray.rows) | 1;
        Mat grid;
        adaptiveThreshold(cellGray, grid, 255, ADAPTIVE_THRESH_MEAN_C, THRESH_BINARY, blockSize, characterGrayValue);
        Rect roi = noiselessGridRect(grid, 0, 0, grid.cols, grid.rows);
        if (roi.width <= 0 || roi.height <= 0){
            rv[index/9][index%9] = 0;
            continue;
        }
        Mat noiselessGrid = grid(roi).clone();
        cleanUpScatteredNoise(noiselessGrid, NoiseThreshold);
        double allWhiteSum = (double)noiselessGrid.cols * noiselessGrid.rows * 255;
        double pixelSum = sum(noiselessGrid)[0];
        if (pixelSum > 0.98 * allWhiteSum || pixelSum < allWhiteSum * 0.03){
            rv[index/9][index%9] = 0;
        }else{
            int guess = (int) OCREngine->classify(noiselessGrid, showOcrResult);
            rv[index/9][index%9] = guess;
        }
    }
    return rv;
}

static void cleanUpScatteredNoise(Mat &grid, int noiseThreshold){
    blur(grid, grid, Size(3, 3));
    threshold(grid, grid, noiseThreshold, 255, THRESH_BINARY);
}

Mat findSudokuBoard(const Mat &fullSrc, int &backgroundThresholdUsed){
    Mat fullSrcGray;
    if (fullSrc.channels() == 4){
        cvtColor(fullSrc, fullSrcGray, COLOR_RGBA2GRAY);
    }else if (fullSrc.channels() == 3){
        cvtColor(fullSrc, fullSrcGray, COLOR_BGR2GRAY);
    }else{
        fullSrcGray = fullSrc;
    }
    Mat resized = normalizeSourceImageSize(fullSrcGray);
    if (!resized.empty()){
        fullSrcGray = resized;
    }
    Mat fullSrcGrayBlurred;
    GaussianBlur(fullSrcGray, fullSrcGrayBlurred, Size(3, 3), 0);
    int blockSize = MIN(fullSrcGray.cols, fullSrcGray.rows) / 9 | 1;
    Mat rv;
    for (int i=0; i<BoardThresholdCandidateSize && rv.empty(); i++){
        backgroundThresholdUsed = BoardThresholdCandidates[i];
        Mat fullSrcInverted, fullSrcBinary;
        adaptiveThreshold(fullSrcGrayBlurred, fullSrcInverted, 255, ADAPTIVE_THRESH_MEAN_C, THRESH_BINARY_INV, blockSize, backgroundThresholdUsed);
        adaptiveThreshold(fullSrcGrayBlurred, fullSrcBinary, 255, ADAPTIVE_THRESH_MEAN_C, THRESH_BINARY, blockSize, backgroundThresholdUsed);
        vector<vector<Point>> contours;
        vector<Vec4i> hierarchy;
        findContours(fullSrcInverted, contours, hierarchy, RETR_TREE, CHAIN_APPROX_SIMPLE);
        // walk from the head of the outermost sibling chain, like the old
        // CvSeq* result of cvFindContours
        int head = -1;
        for (int c = 0; c < (int)hierarchy.size(); c++){
            if (hierarchy[c][3] < 0 && hierarchy[c][1] < 0){
                head = c;
                break;
            }
        }
        rv = findBoardFromContour(head, contours, hierarchy, fullSrcGray, fullSrcBinary);
    }
    return rv;
}

static vector<Rect> getSortedGridsByCoord(vector<Rect> &grids){
    vector<Rect> rv;
    sort(grids.begin(), grids.end(), rectangleCmpByPositionY);
    for(int i=0; i<81; i+=9){
        vector<Rect> row(grids.begin()+i, grids.begin()+9+i);
        sort(row.begin(), row.end(), rectangleCmpByPositionX);
        rv.insert(rv.end(), row.begin(), row.end());
    }
    return rv;
}

static bool rectangleCmpByPositionX(const Rect &a, const Rect &b){
    return a.x < b.x;
}

static bool rectangleCmpByPositionY(const Rect &a, const Rect &b){
    return a.y < b.y;
}

static Rect noiselessGridRect(const Mat &boardBinary, int x, int y, int width, int height){
    bool hasNoise = true;
    int limit = MIN(width/3, height/3);
    Rect roi;
    while(hasNoise && limit >= 0){
        limit--;
        hasNoise = false;
        if (width <= 0 || height <= 0){
            return Rect(0, 0, 0, 0);
        }
        roi = Rect(x, y, width, height);
        Mat view = boardBinary(roi);
        //detect noise top
        if (sum(view.row(0))[0] != roi.width * 255.0){
            hasNoise = true;
        }
        //contract bottom
        if (sum(view.row(roi.height-1))[0] != roi.width * 255.0){
            hasNoise = true;
        }
        //contract left
        if (sum(view.col(0))[0] != roi.height * 255.0){
            hasNoise = true;
        }
        //contract right
        if (sum(view.col(roi.width-1))[0] != roi.height * 255.0){
            hasNoise = true;
        }
        if (hasNoise){
            x++;
            y++;
            width -= 2;
            height -= 2;
        }
    }
    if (hasNoise && limit < 0){
        return Rect(0, 0, 0, 0);
    }
    return roi;
}

static Mat findBoardFromContour(int curNode, const vector<vector<Point>> &contours,
                                const vector<Vec4i> &hierarchy,
                                const Mat &fullSrcGray, const Mat &fullSrcBinary){
    if (curNode < 0) return Mat();
    int numSiblings = 0;
    // hierarchy entries are [next, previous, firstChild, parent]
    for(int sibling = curNode; sibling >= 0; sibling = hierarchy[sibling][0]){
        numSiblings++;
        Mat board = findBoardFromContour(hierarchy[sibling][2], contours, hierarchy, fullSrcGray, fullSrcBinary);
        if (!board.empty()) {
            return board;
        }
    }
    int parent = hierarchy[curNode][3];
    if (numSiblings >= 72 && numSiblings <= 90 && parent >= 0){
        Mat board = doesResembleBoard(contours[parent], fullSrcGray, fullSrcBinary);
        if (!board.empty()){
            return board;
        }
    }
    return Mat();
}

static Mat doesResembleBoard(const vector<Point> &contour, const Mat &fullSrcGray, const Mat &fullSrcBinary){
    if (contour.empty()){
        return Mat();
    }
    Mat rv;
    int left, right, top, bottom;
    findExtremas(contour, left, right, top, bottom);
    ////////////
    // sub image
    Mat potentialBoardRoi = fullSrcBinary(Rect(left, top, right-left+1, bottom-top+1));
    Mat roiEdges;
    Canny(potentialBoardRoi, roiEdges, 50, 200);

    int houghThreshold = MIN(potentialBoardRoi.cols, potentialBoardRoi.rows) / 3;
    vector<Vec2f> boardLines;
    HoughLines(roiEdges, boardLines, 1, CV_PI/180, houghThreshold);
    if ((int)boardLines.size() >= 16) { // must have at least 20 lines to form a 9x9 grid, but do allow approximation
        Vec2d lineSlopeFreq[18]; // make 18 bins to hold the lines, so that every 10 degrees get 1 bin
        for(int i=0; i<18; i++){
            lineSlopeFreq[i] = Vec2d(0, 0);
        }
        //for every Vec2d pair:
        //[0] contains the count of the number of lines that are in the bin
        //[1] contains the average degree of tilt calculated from the degrees of the individual lines
        int freqLineCount = 18;
        for(size_t i = 0; i < boardLines.size(); i++)
        {
            float theta = boardLines[i][1];
            float degree = radiantToDegree(theta);
            updateLineSlopeFreq(lineSlopeFreq, freqLineCount, degree);
        }
        int highIndex = -1, secondIndex = -2;
        findLineOccurenceBySlope(lineSlopeFreq, freqLineCount, highIndex, secondIndex);
        // check to see if lines of highest and second highest counts (in degree) are somewhat perpendicular, and that they are not tilted too badly
        float slopeDifference = abs(lineSlopeFreq[highIndex][1] - lineSlopeFreq[secondIndex][1]);
        float degreeOfTilt = lineSlopeFreq[highIndex][1];
        if ( abs(slopeDifference-90) < SlopeLineToleranceInDegree &&
            (degreeOfTilt < BoardTiltTolerance ||
             degreeOfTilt > 180 - BoardTiltTolerance ||
             (degreeOfTilt > 90 - BoardTiltTolerance && degreeOfTilt < 90 + BoardTiltTolerance))){
                // pick a side (width or height) as the number to be checked against in rho distribution check
                int boardSpace;
                if (lineSlopeFreq[highIndex][0] == lineSlopeFreq[secondIndex][0]){
                    boardSpace = MAX(right-left, bottom-top);
                }else{
                    boardSpace = lineSlopeFreq[highIndex][1] > 45 && lineSlopeFreq[highIndex][1] < 135 ? bottom - top : right - left;
                }
                bool distributionCheck = checkLineDistributionByRho(boardLines, lineSlopeFreq[highIndex][1], boardSpace);
                if (distributionCheck){
                    distributionCheck = checkLineDistributionByRho(boardLines, lineSlopeFreq[secondIndex][1], boardSpace);
                }
                if (distributionCheck){
                    int padding = (right-left) / 18;
                    int roiLeft = MAX(left-padding, 0);
                    int roiRight = MIN(right+padding, fullSrcGray.cols-1);
                    int roiTop = MAX(top-padding, 0);
                    int roiBottom = MIN(bottom+padding, fullSrcGray.rows-1);
                    Mat potentialBoardNoBorder = fullSrcGray(Rect(roiLeft, roiTop, roiRight-roiLeft+1, roiBottom-roiTop+1));
                    rv = extractAndSetBoardUpRight(contour, Point(roiLeft, roiTop), potentialBoardNoBorder, degreeOfTilt);
                }
            }
    }
    return rv;
}

static bool checkLineDistributionByRho(const vector<Vec2f> &boardLines, float pivotLineTheta, int boardSpace){
    vector<int> rhos;
    rhos.reserve(boardLines.size());
    for(size_t i=0; i<boardLines.size(); i++){
        float rho = boardLines[i][0];
        float theta = boardLines[i][1];
        if (areLinesSimilarInSlope(radiantToDegree(theta), pivotLineTheta)){
            rhos.push_back(rho);
        }
    }
    if(rhos.size() < 1){
        return false;
    }
    int firstRho = rhos[0], lastRho = rhos[0];
    for(size_t i=1; i<rhos.size(); i++){
        if (firstRho > rhos[i]){
            firstRho = rhos[i];
        }
        if (lastRho < rhos[i]){
            lastRho = rhos[i];
        }
    }
    // normalize so that firstRho is 0;
    int offset = -firstRho;
    for(size_t i=0; i<rhos.size(); i++){
        rhos[i] += offset;
    }
    firstRho += offset;
    lastRho += offset;
    if (lastRho < boardSpace / 2){
        return false;
    }
    int roundingAmount = lastRho / 9 / 10;
    int averageDistance = lastRho / 9;
    int numDistributionMarks = 11;
    int distributionMark[] = {0,0,0,0,0, 0,0,0,0,0, 0};
    for (size_t i=0; i<rhos.size(); i++){
        int markIndex = (rhos[i] + roundingAmount) / averageDistance;
        distributionMark[markIndex] = 1;
    }
    int matches = 0;
    for(int i=0; i<numDistributionMarks; i++){
        matches += distributionMark[i];
    }
    return matches >= 5;
}

static void findLineOccurenceBySlope(const Vec2d *lineSlopeFreq, int freqLineCount, int &highIndex, int &secondIndex){
    if (lineSlopeFreq[0][0] > lineSlopeFreq[1][0]){
        highIndex = 0;
        secondIndex = 1;
    }else{
        highIndex = 1;
        secondIndex = 0;
    }
    for (int i=2; i<freqLineCount; i++){
        int count = lineSlopeFreq[i][0];
        if (count >= lineSlopeFreq[highIndex][0] &&
            count > lineSlopeFreq[secondIndex][0]){
            secondIndex = highIndex;
            highIndex = i;
        }else if (count > lineSlopeFreq[secondIndex][0]){
            secondIndex = i;
        }
    }
}

static Mat extractAndSetBoardUpRight(const vector<Point> &contour, const Point &contourOffset,
                                     const Mat &potentialBoardRoi, float degreeOfHighestCount){
    Mat mask_src = Mat::zeros(potentialBoardRoi.size(), CV_8UC1);
    vector<Point> points(contour);
    for(size_t i=0; i<points.size(); i++){
        points[i].x -= contourOffset.x;
        points[i].y -= contourOffset.y;
    }
    fillConvexPoly(mask_src, points, Scalar(255));

    Point2f src_center(potentialBoardRoi.cols/2.0F, potentialBoardRoi.rows/2.0F);

    double angle = degreeOfHighestCount - 90; // assume horizontal
    if (degreeOfHighestCount < 45){ // somewhat horizontal
        angle = degreeOfHighestCount;
    }else if (degreeOfHighestCount > 135){ // tilted counter-clockwise, re-orient by rotating clock-wise
        angle = degreeOfHighestCount - 180;
    }
    Mat rot_mat = getRotationMatrix2D(src_center, angle, 1.0);
    Mat upRight, mask_dst;
    warpAffine(potentialBoardRoi, upRight, rot_mat, potentialBoardRoi.size());
    warpAffine(mask_src, mask_dst, rot_mat, potentialBoardRoi.size());
    Rect boardRoi = findRectFromMask(mask_dst);
    if (boardRoi.width <= 0 || boardRoi.height <= 0){
        return Mat();
    }
    Mat rv(boardRoi.size(), CV_8UC1, Scalar(255));
    upRight(boardRoi).copyTo(rv, mask_dst(boardRoi));
    return rv;
}

/*
 count the occurence of lines by their degree of tilt
 */
static void updateLineSlopeFreq(Vec2d *lineSlopeFreq, int lineCount, float degree){
    int bin = degree / (180/lineCount);
    lineSlopeFreq[bin][0] += 1;
    if (lineSlopeFreq[bin][1] == 0){
        lineSlopeFreq[bin][1] = degree;
    }else{
        lineSlopeFreq[bin][1] = (lineSlopeFreq[bin][1] + degree) / 2;
    }
}

static bool areLinesSimilarInSlope(float theta1, float theta2){
    //theta1 and theta2 are in degrees (as supposed to radiant)
    return abs(theta1-theta2) < SlopeLineToleranceInDegree ||
    180 - max(theta1, theta2) + min(theta1, theta2) < SlopeLineToleranceInDegree;
}

//inclusive
static void findExtremas(const vector<Point> &contour, int &left, int &right, int &top, int &bottom){
    right = bottom = -1;
    left = 1 << 30;
    top = 1 << 30;
    for (size_t i=0; i<contour.size(); i++){
        const Point &p = contour[i];
        left = MIN(left, p.x);
        right = MAX(right, p.x);
        top = MIN(top, p.y);
        bottom = MAX(bottom, p.y);
    }
}

static int findCharacterShadingThreshold(const Mat &img){
    // look for 2 gray scale value with highest frequencies, the first and second highest gray values should be at least a certain distance apart
    // the first highest is most likely to be the background
    // the second highest is most likely to be the foreground character gray scale value
    // if there is only 1 extrema, it is likely that the image contains no characters at all
    int minDistance = 255/8;
    long pixSum = 0;
    Mat blurred;
    GaussianBlur(img, blurred, Size(3, 3), 0);
    int freq[256] = {0};
    for(int y=0; y<blurred.rows; y++){
        const uchar *rowbegin = blurred.ptr<uchar>(y);
        for(int x=0; x<blurred.cols; x++){
            int grayValue = (int)(rowbegin[x]);
            freq[grayValue]++;
            pixSum += grayValue;
        }
    }
    int totalPix = blurred.cols * blurred.rows;
    long avgShade = pixSum / totalPix;
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

// if input image is exceedingly big, down size it, otherwise return an empty Mat
static Mat normalizeSourceImageSize(const Mat &sourceImage){
    Mat rv;
    if (MAX(sourceImage.cols, sourceImage.rows) > InputImageNormalizeLength){
        int normalizedWidth, normalizedHeight;
        if(sourceImage.cols > sourceImage.rows){
            normalizedWidth = InputImageNormalizeLength;
            normalizedHeight = InputImageNormalizeLength / sourceImage.cols * sourceImage.rows;
        }else{
            normalizedHeight = InputImageNormalizeLength;
            normalizedWidth = InputImageNormalizeLength / sourceImage.rows * sourceImage.cols;
        }
        resize(sourceImage, rv, Size(normalizedWidth, normalizedHeight));
    }
    return rv;
}

static void findXExtramas(const Mat &mask, int *min, int *max){
    int minFound = 0;
    //For each col sum, if sum > 0 then we find the min
    //then continue to end to search the max
    for (int i=0; i<mask.cols; i++){
        double val = sum(mask.col(i))[0];
        if(val > 0){
            *max = i;
            if(!minFound){
                *min = i;
                minFound = 1;
            }
        }
    }
}

static void findYExtremas(const Mat &mask, int *min, int *max){
    int minFound = 0;
    for (int i=0; i<mask.rows; i++){
        double val = sum(mask.row(i))[0];
        if(val > 0){
            *max = i;
            if(!minFound){
                *min = i;
                minFound = 1;
            }
        }
    }
}

static Rect findRectFromMask(const Mat &mask){
    int xmin, xmax, ymin, ymax;
    xmin = xmax = ymin = ymax = 0;
    findXExtramas(mask, &xmin, &xmax);
    findYExtremas(mask, &ymin, &ymax);
    return Rect(xmin, ymin, xmax-xmin, ymax-ymin);
}
