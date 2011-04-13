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
@property(nonatomic, retain) NSDate* creationDate;
@property(nonatomic, retain) NSString* comments;
@property(nonatomic, assign) int** sudokuSolution;

//load archive into strong-typed array of ArchiveEntry objects, sorted by date in desc order
+(NSArray*) loadArchive;

+(ArchiveEntry*) archiveEntryWithValues:(NSString*)creationDateString comments:(NSString*)comments solutionString:(NSString*) serializedSolutionString;
-(void) save;
-(NSString*) toArchiveString;

@end
