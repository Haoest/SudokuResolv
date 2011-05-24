//
//  ArchiveTests.h
//  Sudokubot
//
//  Created by Haoest on 5/23/11.
//  Copyright 2011 none. All rights reserved.
//
//  See Also: http://developer.apple.com/iphone/library/documentation/Xcode/Conceptual/iphone_development/135-Unit_Testing_Applications/unit_testing_applications.html

//  Application unit tests contain unit test code that must be injected into an application to run correctly.
//  Define USE_APPLICATION_UNIT_TEST to 0 if the unit test code is designed to be linked into an independent test executable.

#import "ArchiveEntry.h"
#import "ArchiveManager.h"
#import <SenTestingKit/SenTestingKit.h>

//#import "application_headers" as required


@interface ArchiveTests : SenTestCase {

    
}
-(void) deleteArchiveFile;

@end
