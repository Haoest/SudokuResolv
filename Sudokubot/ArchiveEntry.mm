//
//  ArchiveEntry.m
//  Sudokubot
//
//  Created by Haoest on 4/12/11.
//  Copyright 2011 none. All rights reserved.
//

#import "cvutil.hpp"
#import "AppConfig.h"
#import "archiveEntry.h"

@implementation ArchiveEntry

@synthesize comments, sudokuSolution, sudokuHints, entryId, secondsSince1970;

-(void) dealloc{
    comments = nil;
    sudokuHints = nil;
    sudokuSolution = nil;
    [super dealloc];
}

+(ArchiveEntry*) archiveEntryWithValues:(int)entryId
                         solutionString:(NSString*) solutionAsString 
                             hintString: (NSString*) hintsAsString
                           secondsSince1970:(double)secondsSince1970 
                               comments:(NSString*)comments{
    ArchiveEntry* rv = [[[ArchiveEntry alloc] init] autorelease];
    rv.entryId = entryId;
    rv.comments = [comments stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    rv.sudokuSolution = [solutionAsString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    rv.sudokuHints = [hintsAsString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] ;
    rv.secondsSince1970 = secondsSince1970;
    return rv;
}


+(ArchiveEntry*) archiveEntryWithArchiveString: (NSString*) archiveString{
    NSArray *segments = [archiveString componentsSeparatedByString:@"\t"];
    NSString *entryId = [segments objectAtIndex:0];
    NSString *solution = [segments objectAtIndex:1];
    NSString *hints = [segments objectAtIndex:2];
    NSString *secondsSince1970 = [segments objectAtIndex:3];
    NSString *comments = [segments objectAtIndex:4];
    ArchiveEntry *rv = [ArchiveEntry archiveEntryWithValues:[entryId intValue]
                                 solutionString:solution 
                                     hintString:hints 
                               secondsSince1970:[secondsSince1970 doubleValue]
                                       comments:comments];
    return [rv retain];
}

-(NSString*) toArchiveString{
    NSString* rv = [NSString stringWithFormat:@"%d\t%@\t%@\t%.0f\t%@\n", 
                    self.entryId,
                    [self.sudokuSolution stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]],
                    self.sudokuHints,
                    self.secondsSince1970,
                    self.comments];
    return rv;
}

-(NSDate*) getCreationDateGMT{
    return [NSDate dateWithTimeIntervalSince1970:self.secondsSince1970];
}

@end





