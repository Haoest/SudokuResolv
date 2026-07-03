//
//  SudokuBridge.mm
//  Sudokubot
//

#import "SudokuBridge.h"
#import "boardRecognizer.h"
#import "cvutil.hpp"

static NSArray<NSArray<NSNumber *> *> *boardToArray(int **board) {
    NSMutableArray *rows = [NSMutableArray arrayWithCapacity:9];
    for (int i = 0; i < 9; i++) {
        NSMutableArray *cols = [NSMutableArray arrayWithCapacity:9];
        for (int j = 0; j < 9; j++) {
            [cols addObject:@(board[i][j])];
        }
        [rows addObject:[cols copy]];
    }
    return [rows copy];
}

@implementation RecognitionResult
@end

@implementation SudokuBridge

+ (RecognitionResult *)recognizeBoard:(UIImage *)image {
    RecognitionResult *result = [[RecognitionResult alloc] init];
    result.success = NO;
    cv::Mat mat = [cvutil MatFromUIImage:image];
    if (mat.empty()) {
        return result;
    }
    recognizerResultPack pack = recognizeBoardFromPhoto(mat);
    result.success = pack.success;
    if (pack.success) {
        result.board = boardToArray(pack.boardArr);
        pack.destroy();
    }
    return result;
}

@end
