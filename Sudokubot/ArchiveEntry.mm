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

@synthesize comments, sudokuSolution, sudokuHints, entryId;

+(ArchiveEntry*) archiveEntryWithValues:(NSString*)entryId
                         solutionString:(NSString*) solutionAsString 
                             hintString: (NSString*) hintsAsString
                               comments:(NSString*)comments{
    ArchiveEntry* rv = [[ArchiveEntry alloc] init];
    rv.entryId = entryId;
    rv.comments = comments;
    rv.sudokuSolution = solutionAsString;
    rv.sudokuHints = hintsAsString;
    return rv;
}


+(ArchiveEntry*) archiveEntryWithArchiveString: (NSString*) archiveString{
    NSArray *segments = [archiveString componentsSeparatedByString:@"\t"];
    NSString *entryid = [segments objectAtIndex:0];
    NSString *solution = [segments objectAtIndex:1];
    NSString *hints = [segments objectAtIndex:2];
    NSString *comments = [segments objectAtIndex:3];
    return [ArchiveEntry archiveEntryWithValues:entryid solutionString:solution hintString:hints comments:comments];
}

-(NSString*) toArchiveString{
    NSString* rv = [NSString stringWithFormat:@"%@\t%@\t%@\t%@\n", 
                    self.entryId,
                    self.sudokuSolution,
                    self.sudokuHints,
                    self.comments];
    return rv;
}


-(NSDate*) getCreationDateGMT{
    return [NSDate dateWithTimeIntervalSince1970:[entryId doubleValue]];
}
@end





