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
@property(nonatomic, assign) NSString* entryId; // use date time in milliseconds
@property(nonatomic, retain) NSString* comments;
@property(nonatomic, retain) NSString* sudokuSolution;
@property(nonatomic, retain) NSString* sudokuHints;

//load archive into strong-typed array of ArchiveEntry objects, sorted by date in desc order
//+(NSArray*) loadArchive;

+(ArchiveEntry*) archiveEntryWithValues:(NSString*)entryId
                         solutionString:(NSString*) solutionAsString 
                             hintString: (NSString*) hintsAsString
                               comments:(NSString*)comments;
+(ArchiveEntry*) archiveEntryWithArchiveString: (NSString*) archiveString;
//-(void) save;
-(NSString*) toArchiveString;

-(NSDate*) getCreationDateGMT;
@end


