//
//  ArchiveManager.h
//  Sudokubot
//
//  Created by Haoest on 5/23/11.
//  Copyright 2011 none. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ArchiveEntry.h"

@interface ArchiveManager : NSObject {
    NSMutableDictionary* allEntries;
}
-(id) initDefaultArchive;
-(ArchiveEntry*) getEntryById:(NSString*) entryId;
-(void) addEntry:(ArchiveEntry*) entry;
-(void) removeEntry:(NSString*) entryId;
-(void) saveArchive;
-(NSArray*) getAllEntries;

NSInteger sortArchiveEntryByCreationDate(id entryId1, id entryId2, void *reverse);
@end
