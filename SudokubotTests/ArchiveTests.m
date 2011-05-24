//
//  ArchiveTests.m
//  Sudokubot
//
//  Created by Haoest on 5/23/11.
//  Copyright 2011 none. All rights reserved.
//

#import "ArchiveTests.h"
#import "AppConfig.h"

@implementation ArchiveTests

NSString *testSolution;
NSString *testHints;
NSTimeInterval now, oneMinuteLater, twoMinutesLater;
NSString *testComment;


- (void)setUp
{
    [super setUp];
    now = [[NSDate date] timeIntervalSince1970];
    oneMinuteLater = now + 60;
    twoMinutesLater = now + 120;
    testHints = @"530070000 600195000 098000060 800060003 400803001 700020006 060000280 000419005 000080079";
    testSolution = @"534678912 672195348 198342567 859761423 426853791 713924856 961537284 287419635 345286179";
    testComment = @"my comment";
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    [super tearDown];
}

-(void) testArchiveEntryDate{
    for(int i=0; i<1000; i++){
        NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
        ArchiveEntry *e = [ArchiveEntry archiveEntryWithValues:[NSString stringWithFormat:@"%f", now] 
                                                solutionString: testSolution
                                                    hintString: testHints
                                                      comments:@"you noob"];
        NSTimeInterval dateAfter = [[e getCreationDateGMT] timeIntervalSince1970];
        STAssertTrue(now == dateAfter, [NSString stringWithFormat:@"Archive entry dates must be equal after serialization. Difference: %e ", dateAfter-now]);
    }
}

-(void) testWriteDictionaryToFile{
    [self deleteArchiveFile];
    NSString *fileName = [AppConfig getArchiveFileName];
    NSMutableDictionary *d = [[NSMutableDictionary alloc] initWithCapacity:0];
    NSString *key = @"mykey";
    NSString *value = @"myvalue";
    [d setObject:value forKey:key];
    [d writeToFile:fileName atomically:true];
    
    NSDictionary *d2 = [NSDictionary dictionaryWithContentsOfFile:fileName];
    NSLog([NSString stringWithFormat:@"testWriteDictionaryToFile: key (%@) : value(%@)", @"mykey", [d2 objectForKey:key]]);
    STAssertTrue([d2 count] > 0, @"reloaded dicitonary should have something in it");
    STAssertTrue([[d2 objectForKey:key] isEqualToString:[d objectForKey:key]], @"dictionary values should be equal before and after");
}

-(void) testRetrieveEntryBeforeSaving{
    ArchiveEntry *entry = [ArchiveEntry archiveEntryWithValues:[NSString stringWithFormat:@"%f", now]
                                                solutionString:testSolution 
                                                    hintString:testHints
                                                      comments:testComment];
    [self deleteArchiveFile];
    ArchiveManager *arman = [[ArchiveManager alloc] initDefaultArchive];
    [arman addEntry:entry];
    ArchiveEntry *retrieved = [arman getEntryById:[NSString stringWithFormat:@"%f", now]];
    STAssertNotNil(retrieved, @"entry should exist in dictionary");
    STAssertTrue([retrieved.entryId isEqualToString: entry.entryId], @"entryIds should be equal before and after retrieval");
}

-(void) testSaveArchive{
    ArchiveEntry *entry = [ArchiveEntry archiveEntryWithValues:[NSString stringWithFormat:@"%f", now]
                                                solutionString:testSolution 
                                                    hintString:testHints
                                                      comments:testComment];
    [self deleteArchiveFile];
    ArchiveManager *arman = [[ArchiveManager alloc] initDefaultArchive];
    [arman addEntry:entry];
    if(![arman saveArchive]){
        STFail(@"archive file not saved");
    }
    [arman release];
    NSFileManager *fileman = [NSFileManager defaultManager];
    if (![fileman fileExistsAtPath:[AppConfig getArchiveFileName]]){
        STFail(@"dictionary file should have been saved");
    }
    [fileman release];
    ArchiveManager *arman2 = [[ArchiveManager alloc]initDefaultArchive];
    ArchiveEntry *retrieved = [arman2 getEntryById:[NSString stringWithFormat:@"%f", now]];
    STAssertNotNil(retrieved,  @"archive entry should be saved");
    STAssertTrue([retrieved.entryId isEqualToString: entry.entryId], @"entryId must be equal before and after saving");
    STAssertTrue([retrieved.comments isEqualToString: entry.comments], [NSString stringWithFormat: @"comments wrong (%@) vs (%@)", retrieved.comments, entry.comments]);
    NSLog([NSString stringWithFormat: @"======================comments wrong (%@) vs (%@)", retrieved.comments, entry.comments]);
    STAssertTrue([retrieved.sudokuSolution isEqualToString: entry.sudokuSolution], @"solution must be equal before and after saving");
    STAssertTrue([retrieved.sudokuHints isEqualToString: entry.sudokuHints], @"hints must be equal before and after saving");
    [arman2 release];
}

-(void) deleteArchiveFile{
    NSFileManager *fileman = [NSFileManager defaultManager];
    if ([fileman fileExistsAtPath:[AppConfig getArchiveFileName]]){
        [fileman removeItemAtPath:[AppConfig getArchiveFileName] error:nil];
    }
    STAssertFalse([fileman fileExistsAtPath: [AppConfig getArchiveFileName]], @"failed to clean archive");
    [fileman release];
}

@end
