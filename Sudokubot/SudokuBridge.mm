#import "SudokuBridge.h"
#import "boardRecognizer.h"
#import "solver.hpp"
#import "cvutil.hpp"
#import "ArchiveManager.h"

static int** arrayToBoard(NSArray<NSArray<NSNumber *> *> *array) {
    int** board = new int*[9];
    for (int i = 0; i < 9; i++) {
        board[i] = new int[9];
        for (int j = 0; j < 9; j++) {
            board[i][j] = [array[i][j] intValue];
        }
    }
    return board;
}

static NSArray<NSArray<NSNumber *> *> *boardToArray(int** board) {
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

static void freeBoard(int** board) {
    if (!board) return;
    for (int i = 0; i < 9; i++) delete board[i];
    delete board;
}

@implementation RecognitionResult
@end

@implementation SudokuBridge

+ (RecognitionResult *)recognizeBoard:(UIImage *)image {
    RecognitionResult *result = [[RecognitionResult alloc] init];
    IplImage *ipl = [cvutil CreateIplImageFromUIImage:image ignoreUIOrientation:false];
    if (!ipl) {
        result.success = NO;
        return result;
    }
    recognizerResultPack pack = recognizeBoardFromPhoto(ipl);
    cvReleaseImage(&ipl);
    result.success = pack.success;
    if (pack.success) {
        result.board = boardToArray(pack.boardArr);
        pack.destroy();
    }
    return result;
}

+ (NSArray<NSArray<NSNumber *> *> *)solve:(NSArray<NSArray<NSNumber *> *> *)hints {
    int** hintBoard = arrayToBoard(hints);
    solver *s = [solver solverWithHints:hintBoard];
    int** solution = [s trySolve];
    NSArray *result = nil;
    if (solution) {
        result = boardToArray(solution);
    }
    freeBoard(hintBoard);
    return result;
}

+ (NSString *)serializeBoard:(NSArray<NSArray<NSNumber *> *> *)board {
    int** b = arrayToBoard(board);
    NSString *result = [cvutil SerializeBoard:b];
    freeBoard(b);
    return result;
}

+ (NSArray<NSArray<NSNumber *> *> *)deserializeBoard:(NSString *)str {
    int** board = [cvutil DeserializedBoard:str];
    if (!board) return nil;
    NSArray *result = boardToArray(board);
    freeBoard(board);
    return result;
}

+ (int)saveToArchiveWithSolution:(NSArray<NSArray<NSNumber *> *> *)solution
                           hints:(NSArray<NSArray<NSNumber *> *> *)hints
                         comment:(NSString *)comment {
    NSString *solStr = [self serializeBoard:solution];
    NSString *hintStr = [self serializeBoard:hints];
    ArchiveManager *arman = [[ArchiveManager alloc] initDefaultArchive];
    ArchiveEntry *entry = [[ArchiveEntry alloc] initWithValues:-1
                                               solutionString:solStr
                                                   hintString:hintStr
                                             secondsSince1970:[[NSDate date] timeIntervalSince1970]
                                                     comments:comment ?: @""];
    int newId = [arman addEntry:entry];
    return [arman saveArchive] ? newId : -1;
}

+ (void)updateArchiveEntry:(int)entryId comment:(NSString *)comment {
    ArchiveManager *arman = [[ArchiveManager alloc] initDefaultArchive];
    ArchiveEntry *e = [arman getEntryById:entryId];
    if (e) {
        e.comments = comment ?: @"";
        [arman updateEntry:e];
        [arman saveArchive];
    }
}

+ (NSArray<ArchiveEntry *> *)loadAllArchiveEntries {
    ArchiveManager *arman = [[ArchiveManager alloc] initDefaultArchive];
    return [arman getAllEntries];
}

+ (void)deleteArchiveEntry:(int)entryId {
    ArchiveManager *arman = [[ArchiveManager alloc] initDefaultArchive];
    [arman removeEntry:entryId];
    [arman saveArchive];
}

@end
