//
//  SudokuBridge.h
//  Sudokubot
//
//  Thin Objective-C++ bridge exposing the C++ OpenCV board recognizer to
//  Swift. Solving, serialization, and archiving live in Swift.

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RecognitionResult : NSObject
@property (nonatomic, strong, nullable) NSArray<NSArray<NSNumber *> *> *board;
@property (nonatomic, assign) BOOL success;
@end

@interface SudokuBridge : NSObject
+ (RecognitionResult *)recognizeBoard:(UIImage *)image;
@end

NS_ASSUME_NONNULL_END
