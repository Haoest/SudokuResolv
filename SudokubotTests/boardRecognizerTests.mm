//
//  boardRecognizerTests.mm
//  SudokubotTests
//
//  Created by Haoest on 5/20/11.
//  Ported to XCTest and the OpenCV 4 C++ API in 2026.
//

#import <XCTest/XCTest.h>
#import <UIKit/UIKit.h>
#include <vector>
#include "boardRecognizer.h"
#include "cvutil.hpp"

using namespace std;

@interface BoardRecognizerTests : XCTestCase
@end

struct testPack {
    const char *inputFile;
    const char *hints;
};

static const vector<testPack> &allTests() {
    static const vector<testPack> tests = {
        {"camera_book2_1.jpg",      "050609030 210000065 400000007 003941600 000000000 004728500 300000006 160000078 080305020"},
        {"camera_lcd2.jpg",         "405800900 060500201 030060708 090000006 050000070 800000030 503090080 602007090 001004605"},
        {"camera_lcd3.jpg",         "608407103 300658000 700030008 940200800 037806940 006009031 100080009 000925004 409701305"},
        {"camera_shadow2.jpg",      "015040790 080070020 200301005 037506140 100708006 026104870 900603007 060010030 051080960"},
        {"camera_verynoisy.jpg",    "049070000 060400300 005002607 090580100 050000070 006021030 608700400 001004080 000060710"},
        {"camera_shadow.jpg",       "080409070 040085103 052000600 204053000 700604009 000910804 001000230 309170080 070302060"},
        {"camera_doubleshadow.jpg", "027904350 000000000 004187900 702403809 800000003 405806201 003718400 000000000 048609130"},
        {"camera_curl.jpg",         "009005310 460200800 200170090 798320000 050000040 000086973 040061005 002003086 087400100"},
        {"camera_book1.jpg",        "409070301 200030004 080402090 503104802 040807030 807305406 010203060 600080007 908050103"},
        {"camera_book1_small.jpg",  "409070301 200030004 080402090 503104802 040807030 807305406 010203060 600080007 908050103"},
        {"camera_noisy.png",        "049070000 060400300 005002607 090580100 050000070 006021030 608700400 001004080 000060710"},
        {"shaded_colorfg.png",      "004018060 050090380 000360001 008070005 007000200 900020600 400035000 083040090 070280400"},
        {"shaded_colorfg_noisy.png","004018060 050090380 000360001 008070005 007000200 900020600 400035000 083040090 070280400"},
        {"shaded.png",              "000600908 930150700 068300010 090200804 700803006 402007050 040001320 003096041 507002000"},
        {"rotated25.jpg",           "530070000 600195000 098000060 800060003 400803001 700020006 060000280 000419005 000080079"},
        {"noisy.png",               "530070000 600195000 098000060 800060003 400803001 700020006 060000280 000419005 000080079"},
        {"rotated345.png",          "530070000 600195000 098000060 800060003 400803001 700020006 060000280 000419005 000080079"},
        {"simple.png",              "530070000 600195000 098000060 800060003 400803001 700020006 060000280 000419005 000080079"},
        {"rotated2.png",            "002067080 900030506 070000401 080002004 010000090 500700030 406000010 701020008 020190700"},

        {"camera_book3_1.jpg",      "080002307 010600002 003005900 502000000 060000080 000000704 008500100 600003020 109800030"},
        {"camera_book3_2.jpg",      "080002307 010600002 003005900 502000000 060000080 000000704 008500100 600003020 109800030"},
        {"camera_book3_3.jpg",      "080002307 010600002 003005900 502000000 060000080 000000704 008500100 600003020 109800030"},
        {"camera_book3_4.jpg",      "080002307 010600002 003005900 502000000 060000080 000000704 008500100 600003020 109800030"},
        {"camera_book3_5.jpg",      "080002307 010600002 003005900 502000000 060000080 000000704 008500100 600003020 109800030"},
        {"camera_book3_6.jpg",      "080002307 010600002 003005900 502000000 060000080 000000704 008500100 600003020 109800030"},
        {"camera_book3_7.jpg",      "080002307 010600002 003005900 502000000 060000080 000000704 008500100 600003020 109800030"},
        {"camera_book3_8.jpg",      "080002307 010600002 003005900 502000000 060000080 000000704 008500100 600003020 109800030"},
        {"camera_book3_9.jpg",      "080002307 010600002 003005900 502000000 060000080 000000704 008500100 600003020 109800030"},
        {"camera_book3_10.jpg",     "080002307 010600002 003005900 502000000 060000080 000000704 008500100 600003020 109800030"},

        {"book_lowquality_2.jpg",   "000380090 001002700 000740608 000890000 056000830 000067000 800036000 002400900 000025000"},
        {"book_lowquality_1.jpg",   "000380090 001002700 000740608 000890000 056000830 000067000 800036000 002400900 000025000"},
        {"book_demo.jpg",           "080002307 010600002 003005900 502000000 060000080 000000704 008500100 600003020 109800030"},
        {"newspaper_dotted.jpg",    "000000000 703190800 500068000 040300090 600000005 010002060 000680002 004071309 000000000"},
        {"blank.png",               "000000000 000000000 000000000 000000000 000000000 000000000 000000000 000000000 000000000"},
    };
    return tests;
}

// Loads a test image from the test bundle (falls back to the main bundle).
static cv::Mat loadTestImage(const char *fileName) {
    NSString *fn = [NSString stringWithUTF8String:fileName];
    NSBundle *bundle = [NSBundle bundleForClass:NSClassFromString(@"BoardRecognizerTests")];
    NSString *path = [bundle pathForResource:[fn stringByDeletingPathExtension]
                                      ofType:[fn pathExtension]];
    UIImage *img = path ? [UIImage imageWithContentsOfFile:path] : [UIImage imageNamed:fn];
    return [cvutil MatFromUIImage:img];
}

// Compares OCR output against the expected hints; returns {right, wrong}.
static pair<int, int> checkResult(int **expected, const recognizerResultPack &recog) {
    int totalWrong = 0;
    int totalRight = 0;
    for (int i = 0; i < 9; i++) {
        for (int j = 0; j < 9; j++) {
            if (expected[i][j] != recog.boardArr[i][j]) {
                totalWrong++;
            } else if (expected[i][j] != 0) {
                totalRight++;
            }
        }
    }
    return {totalRight, totalWrong};
}

static void freeBoard(int **board) {
    if (!board) return;
    for (int i = 0; i < 9; i++) delete[] board[i];
    delete[] board;
}

@implementation BoardRecognizerTests

- (void)testReadBoard {
    cv::Mat img = loadTestImage("simple.png");
    XCTAssertFalse(img.empty(), @"simple.png should load from the test bundle");
    recognizerResultPack recog = recognizeBoardFromPhoto(img);
    XCTAssertTrue(recog.success, @"the board in simple.png should be recognized");
    if (!recog.success) return;
    int **actualBoard = [cvutil loadStringAsBoard:"530070000 600195000 098000060 800060003 400803001 700020006 060000280 000419005 000080079"];
    for (int i = 0; i < 9; i++) {
        for (int j = 0; j < 9; j++) {
            XCTAssertEqual(recog.boardArr[i][j], actualBoard[i][j], @"%d %d", i, j);
        }
    }
    freeBoard(actualBoard);
    recog.destroy();
}

- (void)testRunAllBoardRecognizerTests {
    int totalNumPuzzlesTried = 0;
    int numPuzzlesRecognized = 0;
    int totalNumCharactersTried = 0;
    int numCharactersRecognized = 0;
    NSDate *start = [NSDate date];
    for (const testPack &t : allTests()) {
        cv::Mat img = loadTestImage(t.inputFile);
        XCTAssertFalse(img.empty(), @"missing test image %s", t.inputFile);
        if (img.empty()) continue;
        totalNumPuzzlesTried++;
        recognizerResultPack res = recognizeBoardFromPhoto(img);
        if (res.success) {
            numPuzzlesRecognized++;
            int **hints = [cvutil loadStringAsBoard:t.hints];
            pair<int, int> rightWrong = checkResult(hints, res);
            totalNumCharactersTried += rightWrong.first + rightWrong.second;
            numCharactersRecognized += rightWrong.first;
            printf("testing %s... mistakes: %d\n", t.inputFile, rightWrong.second);
            freeBoard(hints);
            res.destroy();
        } else {
            printf("testing %s... no puzzle found\n", t.inputFile);
        }
    }
    NSTimeInterval elapsed = -[start timeIntervalSinceNow];
    printf("===========================\nRecognition Summary:\n");
    printf("Puzzles: total (%d) recognized (%d) missed (%d) accuracy (%f)\n",
           totalNumPuzzlesTried, numPuzzlesRecognized,
           totalNumPuzzlesTried - numPuzzlesRecognized,
           (float)numPuzzlesRecognized / totalNumPuzzlesTried);
    printf("Characters: total (%d) recognized (%d) missed (%d) accuracy (%f)\n",
           totalNumCharactersTried, numCharactersRecognized,
           totalNumCharactersTried - numCharactersRecognized,
           (float)numCharactersRecognized / totalNumCharactersTried);
    printf("Time elapsed: %f\n==============================\n", elapsed);

    XCTAssertGreaterThan(numPuzzlesRecognized, 0, @"the recognizer should find at least one board");
}

@end
