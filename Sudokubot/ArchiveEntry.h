//
//  ArchiveEntry.h
//  Sudokubot
//
//  Created by Haoest on 4/12/11.
//  Copyright 2011 none. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ArchiveEntry : NSObject {
    
}

@property(nonatomic, assign) int entryId; 
@property(nonatomic, retain) NSString* comments;
@property(nonatomic, retain) NSString* sudokuSolution;
@property(nonatomic, retain) NSString* sudokuHints;
@property(nonatomic, assign) double secondsSince1970;

//load archive into strong-typed array of ArchiveEntry objects, sorted by date in desc order

+(ArchiveEntry*) archiveEntryWithValues:(int)entryId
                         solutionString:(NSString*) solutionAsString 
                             hintString: (NSString*) hintsAsString
                           secondsSince1970:(double) secondsSince1970
                               comments:(NSString*)comments;

+(ArchiveEntry*) archiveEntryWithArchiveString: (NSString*) archiveString;

-(NSString*) toArchiveString;

-(NSDate*) getCreationDateGMT;

@end


