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

//
//  cvutil.mm
//  Sudokubot
//
//  Created by Haoest on 3/10/11.
//  Ported to the OpenCV 4 C++ API (cv::Mat + UIImageToMat) in 2026.
//

#import "cvutil.hpp"
#import <opencv2/imgproc.hpp>
#import <opencv2/imgcodecs/ios.h>

@implementation cvutil

// Re-render the image so its pixel buffer matches its display orientation.
// UIImageToMat reads the raw CGImage and ignores imageOrientation, which is
// how camera photos ended up rotated 90 degrees in the original code.
static UIImage *normalizeOrientation(UIImage *image) {
    if (image.imageOrientation == UIImageOrientationUp) {
        return image;
    }
    UIGraphicsImageRendererFormat *format = [[UIGraphicsImageRendererFormat alloc] init];
    format.scale = 1;
    CGSize size = image.size;
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:size format:format];
    return [renderer imageWithActions:^(UIGraphicsImageRendererContext *context) {
        [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    }];
}

+ (cv::Mat)MatFromUIImage:(UIImage *)image {
    if (!image) {
        return cv::Mat();
    }
    cv::Mat rgba;
    UIImageToMat(normalizeOrientation(image), rgba, true);
    return rgba;
}

+ (UIImage *)UIImageFromMat:(const cv::Mat &)mat {
    if (mat.empty()) {
        return nil;
    }
    return MatToUIImage(mat);
}

+ (cv::Mat)LoadUIImageAsMat:(NSString *)fileName asGrayscale:(BOOL)asGrayscale {
    UIImage *img = [UIImage imageNamed:fileName];
    if (!img) {
        for (NSBundle *bundle in [NSBundle allBundles]) {
            img = [UIImage imageNamed:fileName inBundle:bundle compatibleWithTraitCollection:nil];
            if (img) break;
        }
    }
    cv::Mat rgba = [cvutil MatFromUIImage:img];
    if (rgba.empty() || !asGrayscale) {
        return rgba;
    }
    cv::Mat gray;
    cv::cvtColor(rgba, gray, cv::COLOR_RGBA2GRAY);
    return gray;
}

+ (int **)ReadBoardFromFile:(NSString *)fileName {
    NSString *s = [NSString stringWithContentsOfFile:fileName encoding:NSASCIIStringEncoding error:nil];
    return [cvutil DeserializedBoard:s];
}

//board must contain a valid solution or nil is returned
+ (int **)DeserializedBoard:(NSString *)board {
    board = [board stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSArray *rawBoard = [board componentsSeparatedByString:@" "];
    if ([rawBoard count] != 9) {
        return nil;
    }
    int **a = new int *[9];
    for (int i = 0; i < 9; i++) {
        a[i] = new int[9];
    }
    for (int i = 0; i < 9; i++) {
        NSString *line = [rawBoard objectAtIndex:i];
        if ([line length] != 9) {
            for (int k = 0; k < 9; k++) {
                delete[] a[k];
            }
            delete[] a;
            return nil;
        }
        for (int j = 0; j < 9; j++) {
            a[i][j] = ((int)[line characterAtIndex:j]) - 48;
            if (a[i][j] < 0 || a[i][j] > 9) {
                for (int k = 0; k < 9; k++) {
                    delete[] a[k];
                }
                delete[] a;
                return nil;
            }
        }
    }
    return a;
}

+ (NSString *)SerializeBoard:(int **)board {
    NSMutableString *rv = [[NSMutableString alloc] initWithString:@""];
    for (int i = 0; i < 9; i++) {
        for (int j = 0; j < 9; j++) {
            [rv appendFormat:@"%d", board[i][j]];
        }
        [rv appendString:@" "];
    }
    return [NSString stringWithString:rv];
}

//load complete solution or incomplete board as a 2D array
+ (int **)loadStringAsBoard:(const char *)boardAsString {
    int **rv = new int *[9];
    for (int i = 0; i < 9; i++) {
        rv[i] = new int[9];
    }
    int index = 0;
    int stringIndexOffset = 0;
    while (index < 81) {
        rv[index / 9][index % 9] = boardAsString[index + stringIndexOffset] - 48;
        index++;
        if (index % 9 == 0) {
            stringIndexOffset++;
        }
    }
    return rv;
}

@end
