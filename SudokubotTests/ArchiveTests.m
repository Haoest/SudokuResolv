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
    for(int i=0; i<1000; i++){ //time differences are sometimes a few milliseconds off, need to run this repeatedly to ensure serialization doesn't lose precision
        NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
        ArchiveEntry *e = [ArchiveEntry archiveEntryWithValues:-1
                                                solutionString: testSolution
                                                    hintString: testHints
                                              secondsSince1970:now
                                                      comments:@"you noob"];
        NSTimeInterval dateAfter = [[e getCreationDateGMT] timeIntervalSince1970];
        STAssertTrue(now == dateAfter, [NSString stringWithFormat:@"Archive entry dates must be equal after serialization. start:%.0f after:%.0f ", now, dateAfter]);
        [e release];
    }
}

-(void) testWriteDictionaryToFile{
    [self deleteArchiveFile];
    NSString *fileName = [AppConfig getArchiveFileName];
    NSMutableDictionary *d = [[NSMutableDictionary alloc] initWithCapacity:0];
    NSString *key = @"mykey";
    NSString *value = @"1	534678912 672195348 198342567 859761423 426853791 713924856 961537284 287419635 345286179	530070000 600195000 098000060 800060003 400803001 700020006 060000280 000419005 000080079	0	my comment";
    [d setObject:value forKey:key];
    [d writeToFile:fileName atomically:true];
    
    NSDictionary *d2 = [NSDictionary dictionaryWithContentsOfFile:fileName];
    STAssertTrue([d2 count] > 0, @"reloaded dicitonary should have something in it");
    STAssertTrue([[d2 objectForKey:key] isEqualToString:[d objectForKey:key]], @"dictionary values should be equal before and after");
}

-(void) testRetrieveEntryBeforeSaving{
    ArchiveEntry *entry = [[ArchiveEntry archiveEntryWithValues:-1
                                                solutionString:testSolution 
                                                    hintString:testHints
                                              secondsSince1970:0
                                                      comments:testComment] autorelease];
    [self deleteArchiveFile];
    ArchiveManager *arman = [[ArchiveManager alloc] initDefaultArchive];
    int newId = [arman addEntry:entry];
    ArchiveEntry *retrieved = [arman getEntryById:newId];
    STAssertNotNil(retrieved, @"entry should exist in dictionary");
    STAssertTrue(retrieved.entryId == entry.entryId, [NSString stringWithFormat:@"entryIds should be equal before and after retrieval %d:%d", entry.entryId, retrieved.entryId]);
}

-(void) testSaveArchive{
    int entryId = 1;
    ArchiveEntry *entry = [ArchiveEntry archiveEntryWithValues:-1
                                                solutionString:testSolution 
                                                    hintString:testHints
                                              secondsSince1970:0
                                                      comments:testComment];
    [self deleteArchiveFile];
    ArchiveManager *arman = [[ArchiveManager alloc] initDefaultArchive];
    int newEntryId = [arman addEntry:entry];
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
    ArchiveEntry *retrieved = [arman2 getEntryById:entryId];
    STAssertNotNil(retrieved,  @"archive entry should be saved");
    STAssertTrue(retrieved.entryId == newEntryId, [NSString stringWithFormat:@"entryId must be equal before and after saving %d:%d", retrieved.entryId, newEntryId]);
    STAssertTrue([retrieved.comments isEqualToString: entry.comments], [NSString stringWithFormat: @"comments wrong (%@) vs (%@)", retrieved.comments, entry.comments]);
    STAssertTrue([retrieved.sudokuSolution isEqualToString: entry.sudokuSolution], @"solution must be equal before and after saving");
    STAssertTrue([retrieved.sudokuHints isEqualToString: entry.sudokuHints], @"hints must be equal before and after saving");
    STAssertTrue(retrieved.secondsSince1970 == entry.secondsSince1970, @"seconds since 1970 must be equal");
    [arman2 release];
}

-(void) testSaveMultipleEntries{
    ArchiveEntry *entry1 = [[ArchiveEntry archiveEntryWithValues:-1
                                                 solutionString:testSolution 
                                                     hintString:testHints
                                               secondsSince1970:now 
                                                       comments:@"entry1"] autorelease];
    ArchiveEntry *entry2 = [[ArchiveEntry archiveEntryWithValues:-1
                                                 solutionString:testSolution 
                                                     hintString:testHints
                                               secondsSince1970:oneMinuteLater 
                                                       comments:@"entry2"] autorelease];
    
    ArchiveEntry *entry3 = [[ArchiveEntry archiveEntryWithValues:-1
                                                 solutionString:testSolution 
                                                     hintString:testHints
                                               secondsSince1970:twoMinutesLater 
                                                       comments:@"entry3"] autorelease];
    [self deleteArchiveFile];
    ArchiveManager *arman = [[ArchiveManager alloc] initDefaultArchive];
    int entryId2 = [arman addEntry:entry2];
    int entryId1 = [arman addEntry:entry1];
    int entryId3 = [arman addEntry:entry3];
    if (![arman saveArchive]){
        STFail(@"archive file can not save");
    }
    [arman release];
    
    ArchiveManager* arman2 = [[ArchiveManager alloc] initDefaultArchive];
    ArchiveEntry* retrieved1 = [arman2 getEntryById:entryId1];
    ArchiveEntry* retrieved2 = [arman2 getEntryById:entryId2];
    ArchiveEntry* retrieved3 = [arman2 getEntryById:entryId3];
    STAssertTrue([entry1.comments isEqualToString:retrieved1.comments], @"entries must be equal before and after saving");
    STAssertTrue([entry2.comments isEqualToString:retrieved2.comments], @"entries must be equal before and after saving");
    STAssertTrue([entry3.comments isEqualToString:retrieved3.comments], @"entries must be equal before and after saving");
    NSArray* allEntries =  [arman2 getAllEntries];
    STAssertTrue([allEntries count] == 3, @"retrieval count should be 3");
    STAssertTrue([[[allEntries objectAtIndex:2] comments] isEqualToString:@"entry1"], @"allEntries should be sorted by date");
    STAssertTrue([[[allEntries objectAtIndex:1] comments] isEqualToString:@"entry2"], @"allEntries should be sorted by date");
    STAssertTrue([[[allEntries objectAtIndex:0] comments] isEqualToString:@"entry3"], @"allEntries should be sorted by date");
    [arman2 release];
}

-(void) testRemoveEntry{
    ArchiveEntry *entry1 = [[ArchiveEntry archiveEntryWithValues:-1
                                                 solutionString:testSolution 
                                                     hintString:testHints
                                               secondsSince1970:now 
                                                       comments:@"entry1"] autorelease];
    ArchiveEntry *entry2 = [[ArchiveEntry archiveEntryWithValues:-1
                                                 solutionString:testSolution 
                                                     hintString:testHints
                                               secondsSince1970:oneMinuteLater 
                                                       comments:@"entry2"] autorelease];
    
    ArchiveEntry *entry3 = [[ArchiveEntry archiveEntryWithValues:-1
                                                 solutionString:testSolution 
                                                     hintString:testHints
                                               secondsSince1970:twoMinutesLater 
                                                       comments:@"entry3"] autorelease];
    [self deleteArchiveFile];
    ArchiveManager *arman = [[ArchiveManager alloc] initDefaultArchive];
    int entryId2 = [arman addEntry:entry2];
    int entryId1 = [arman addEntry:entry1];
    int entryId3 = [arman addEntry:entry3];
    if (![arman saveArchive]){
        STFail(@"archive file can not save");
    }
    [arman release];
    ArchiveManager *arman2 = [[ArchiveManager alloc] initDefaultArchive];
    [arman2 removeEntry:entryId2];
    STAssertTrue([arman2 getEntryById:entryId2] == nil, @"entry2 should be removed");
    STAssertTrue([[arman2 getAllEntries]count] == 2, @"should be only 2 entries after removal");
    [arman2 saveArchive];
    [arman2 release];
    
    ArchiveManager* arman3 = [[ArchiveManager alloc] initDefaultArchive];
    STAssertTrue([[arman3 getAllEntries]count]==2, @"should only be 2 entries after removal and reload");
    NSObject *entryObject2 = [arman3 getEntryById:entryId2];
    STAssertTrue([arman3 getEntryById:entryId2] == nil, @"entry2 should be removed");
    STAssertTrue([arman3 getEntryById:entryId1] != nil, @"entry1 should remain");
    STAssertTrue([arman3 getEntryById:entryId3] != nil, @"entry3 should remain");
    [arman3 removeEntry:entryId1];
    [arman3 removeEntry:entryId3];
    [arman3 saveArchive];
    [arman3 release];
    
    ArchiveManager* arman4 = [[ArchiveManager alloc] initDefaultArchive];
    STAssertTrue([[arman4 getAllEntries] count] == 0, @"archive should be empty");
    [arman4 release];
}

-(void) testUpdateEntry{
    ArchiveEntry *entry1 = [[ArchiveEntry archiveEntryWithValues:-1
                                                 solutionString:testSolution 
                                                     hintString:testHints
                                               secondsSince1970:now 
                                                       comments:@"entry1"] autorelease];
    ArchiveEntry *entry2 = [[ArchiveEntry archiveEntryWithValues:-1
                                                 solutionString:testSolution 
                                                     hintString:testHints
                                               secondsSince1970:oneMinuteLater 
                                                       comments:@"entry2"] autorelease];
    
    ArchiveEntry *entry3 = [[ArchiveEntry archiveEntryWithValues:-1
                                                 solutionString:testSolution 
                                                     hintString:testHints
                                               secondsSince1970:twoMinutesLater 
                                                       comments:@"entry3"] autorelease];
    [self deleteArchiveFile];
    ArchiveManager *arman = [[ArchiveManager alloc] initDefaultArchive];
    int entryId2 = [arman addEntry:entry2];
    int entryId1 = [arman addEntry:entry1];
    int entryId3 = [arman addEntry:entry3];
    if (![arman saveArchive]){
        STFail(@"archive file can not save");
    }
    [arman release];
    
    ArchiveManager *arman2 = [[ArchiveManager alloc]initDefaultArchive];
    ArchiveEntry* retrieved1 = [arman2 getEntryById:entryId1];
    NSString *newComment = @"your comment";
    retrieved1.comments = newComment;
    [arman2 updateEntry:retrieved1];
    ArchiveEntry *retrieved2 = [arman2 getEntryById:entryId1];
    STAssertTrue([retrieved1.comments isEqualToString: retrieved2.comments], @"comments should equal after update");
    STAssertTrue([retrieved1.comments isEqualToString: newComment], @"comments should equal after update");    
    [arman2 saveArchive];
    [arman2 release];
    
    ArchiveManager *arman3 = [[ArchiveManager alloc]initDefaultArchive];
    ArchiveEntry *retrieved3 = [arman3 getEntryById:entryId1];
    STAssertTrue([retrieved1.comments isEqualToString:retrieved3.comments], [NSString stringWithFormat:@"comment should be updated: %@ vs %@", retrieved1.comments, retrieved3.comments]);
    STAssertTrue([retrieved3.comments isEqualToString: newComment], @"comments should equal after update");    
    [arman3 release];
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
