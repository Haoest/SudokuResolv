//
//  AppConfig.h
//  Sudokubot
//
//  Created by Haoest on 4/12/11.
//  Copyright 2011 none. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AppConfig : NSObject {
    
}

+(NSString*) getArchiveFileName;
+(NSString*) archiveDateFormat;
+(CGFloat) archiveCellFontHeight;
+(CGFloat) archiveCellHeight;
+(CGFloat) numpad_normal_alpha;
+(CGFloat) numpad_highlight_alpha;
+(CGFloat) previewImage_faded_alpha;

+(float) normalizedBoardImageSize;
@end

