//
//  AppConfig.h
//  Sudokubot
//
//  Created by Haoest on 4/12/11.
//  Copyright 2011 none. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppConfig : NSObject {
    
}

+(NSString*) getArchiveFileName;

@end

static char archiveDateFormat[] = "yyyy-MM-dd HH:mm";
static float archiveCellFontHeight = 16;
static float archiveCellHeight = 50;

