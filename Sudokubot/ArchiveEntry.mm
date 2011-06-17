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
    self.comments = nil;
    self.sudokuHints = nil;
    self.sudokuSolution = nil;
    [super dealloc];
}

-(id) initWithValues:(int)_entryId
                         solutionString:(NSString*) _solutionAsString 
                             hintString: (NSString*) _hintsAsString
                           secondsSince1970:(double)_secondsSince1970 
                               comments:(NSString*)_comments{
    self.entryId = _entryId;
    self.comments = _comments;
    self.sudokuSolution = _solutionAsString;
    self.sudokuHints = _hintsAsString;
    self.secondsSince1970 = _secondsSince1970;
    return self;
}


-(id) initWithArchiveString: (NSString*) archiveString{
    NSString *separator = [NSString stringWithFormat:@"\t"];
    NSArray *segments = [archiveString componentsSeparatedByString:separator];
    NSString *_entryId = [segments objectAtIndex:0];
    NSString *_solution = [segments objectAtIndex:1];
    NSString *_hints = [segments objectAtIndex:2];
    NSString *_secondsSince1970 = [segments objectAtIndex:3];
    NSString *_comments = [segments objectAtIndex:4];
    return [self initWithValues:[_entryId intValue]
                                 solutionString:_solution 
                                     hintString:_hints 
                               secondsSince1970:[_secondsSince1970 doubleValue]
                                       comments:_comments];
}

-(NSString*) toArchiveString{
    NSString* rv = [NSString stringWithFormat:@"%d\t%@\t%@\t%.0f\t%@", 
                    entryId,
                    sudokuSolution,
                    sudokuHints,
                    secondsSince1970,
                    comments];
    return rv;
}

-(NSDate*) getCreationDateGMT{
    return [NSDate dateWithTimeIntervalSince1970:self.secondsSince1970];
}

@end





