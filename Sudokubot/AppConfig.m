//
//  AppConfig.m
//  Sudokubot
//
//  Created by Haoest on 4/12/11.
//  Copyright 2011 none. All rights reserved.
//

#import "AppConfig.h"


@implementation AppConfig

+(NSString*) getArchiveFileName{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *rv = [paths objectAtIndex:0];
    rv = [rv stringByAppendingPathComponent:@"archive"];
    return rv;
}

+(NSString*) archiveDateFormat{
    return @"yyyy-MM-dd HH:mm";
}
+(CGFloat) archiveCellFontHeight{
    return 14;
}

+(CGFloat) archiveCellHeight{
    return 35;
}

+(CGFloat) numpad_normal_alpha{
    return 0.75;
}
+(CGFloat) numpad_highlight_alpha{
    return 1.0;
}

+(CGFloat) previewImage_faded_alpha{
    return 0.65;
}

@end


