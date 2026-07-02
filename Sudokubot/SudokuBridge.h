#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "ArchiveEntry.h"

@interface RecognitionResult : NSObject
@property (nonatomic, strong) NSArray<NSArray<NSNumber *> *> *board;
@property (nonatomic, assign) BOOL success;
@end

@interface SudokuBridge : NSObject
+ (RecognitionResult *)recognizeBoard:(UIImage *)image;
+ (NSArray<NSArray<NSNumber *> *> * _Nullable)solve:(NSArray<NSArray<NSNumber *> *> *)hints;
+ (NSString *)serializeBoard:(NSArray<NSArray<NSNumber *> *> *)board;
+ (NSArray<NSArray<NSNumber *> *> * _Nullable)deserializeBoard:(NSString *)str;

// Archive helpers
+ (int)saveToArchiveWithSolution:(NSArray<NSArray<NSNumber *> *> *)solution
                           hints:(NSArray<NSArray<NSNumber *> *> *)hints
                         comment:(NSString *)comment;
+ (void)updateArchiveEntry:(int)entryId comment:(NSString *)comment;
+ (NSArray<ArchiveEntry *> *)loadAllArchiveEntries;
+ (void)deleteArchiveEntry:(int)entryId;
@end
