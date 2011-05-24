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

@end

static NSString* ArchiveFileName = @"archive.dict";
static NSString* ArchiveTempFileName = @"archive_temp.dict"; // used as temp file to help saving archive file
static char archiveDateFormat[] = "yyyy-MM-dd HH:mm";
static float archiveCellFontHeight = 16;
static float archiveCellHeight = 50;

