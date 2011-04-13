//
//  ArchiveEntry.m
//  Sudokubot
//
//  Created by Haoest on 4/12/11.
//  Copyright 2011 none. All rights reserved.
//

#import "cvutil.hpp"
#import "AppConfig.h"
#import "ArchiveEntry.h"

@implementation ArchiveEntry

@synthesize creationDate, comments, sudokuSolution;

+(ArchiveEntry*) archiveEntryWithValues:(NSString*)creationDateString comments:(NSString*)comments solutionString:(NSString*)serializedSolutionString {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:[NSString stringWithCString:archiveDateFormat encoding:NSASCIIStringEncoding]];
    ArchiveEntry* rv = [[ArchiveEntry alloc] init];
    rv.creationDate = [dateFormatter dateFromString:creationDateString];
    rv.comments = comments;
    rv.sudokuSolution = [cvutil DeserializedBoard:serializedSolutionString];
    return rv;
}

+(NSArray*) loadArchive{
    NSMutableArray* rv = [NSMutableArray arrayWithCapacity:0];
    NSString *archiveContent = [NSString stringWithContentsOfFile:
                                [NSString stringWithCString:archiveFileName encoding:NSASCIIStringEncoding] 
                                encoding:NSUTF8StringEncoding error:Nil];
    NSArray *archiveEntries = [archiveContent componentsSeparatedByString:@"\n"];
    for (int i=0; i<[archiveEntries count]; i++){
        NSArray *archiveSegments = [[archiveEntries objectAtIndex:i] componentsSeparatedByString:@"\t"];
        if ([archiveSegments count] == 3){
            NSString *creationDateString = [archiveSegments objectAtIndex:0];
            NSString *solution = [archiveSegments objectAtIndex:1];
            NSString *comments = [archiveSegments objectAtIndex:2];
            ArchiveEntry *e = [ArchiveEntry archiveEntryWithValues:creationDateString comments:comments solutionString:solution];
            [rv insertObject:e atIndex:0];// new ones at front
        }
    }
    return [NSArray arrayWithArray:rv];
}

-(NSString*) toArchiveString{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:[NSString stringWithCString:archiveDateFormat encoding:NSASCIIStringEncoding]];
    NSString *serializedBoard = [cvutil SerializeBoard:self.sudokuSolution];
    NSString* rv = [NSString stringWithFormat:@"%@\t%@\t%@\n", 
                    [dateFormatter stringFromDate:self.creationDate],
                    serializedBoard,
                    self.comments];
    [dateFormatter release];
    return rv;
}

-(void) save{
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:[NSString stringWithCString:archiveFileName encoding:NSASCIIStringEncoding]];
    NSString *archiveString = [self toArchiveString];
    NSData *data = [archiveString dataUsingEncoding:NSUTF8StringEncoding];
    if (fileHandle == Nil){
        NSFileManager* fileManager = [NSFileManager defaultManager];
        [fileManager createFileAtPath:[NSString stringWithCString:archiveFileName encoding:NSASCIIStringEncoding] 
                             contents:data
                           attributes:Nil];
    }else{
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:data];
        [fileHandle closeFile];
    }
}


@end





