//
//  ArchiveManager.m
//  Sudokubot
//
//  Created by Haoest on 5/23/11.
//  Copyright 2011 none. All rights reserved.
//

#import "ArchiveManager.h"
#import "ArchiveEntry.h"
#import "AppConfig.h"

@implementation ArchiveManager

-(id) initDefaultArchive{
    allEntries = [NSMutableDictionary dictionaryWithContentsOfFile:[AppConfig getArchiveFileName]];
    if (!allEntries){
        allEntries = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(ArchiveEntry*) getEntryById:(NSString*) entryId{
    return [ArchiveEntry archiveEntryWithArchiveString: [allEntries objectForKey:entryId]];
}

-(void) addEntry:(ArchiveEntry*) entry{
    id key = entry.entryId;
    [allEntries setObject:[entry toArchiveString] forKey:key];
}

-(void) removeEntry:(NSString*) entryId{
    [allEntries removeObjectForKey:entryId];
}

-(bool) saveArchive{
    NSString* fileName = [AppConfig getArchiveFileName];
    return [allEntries writeToFile:fileName atomically:false];
}

-(NSArray*) getAllEntries{
    NSMutableArray* rv = [[NSMutableArray alloc] initWithCapacity:[allEntries count]];
    for(NSString* entry in [allEntries allValues]){
        [rv addObject:[ArchiveEntry archiveEntryWithArchiveString:entry]];
    }
    return [rv sortedArrayUsingFunction:sortArchiveEntryByCreationDate context:false];
}

NSInteger sortArchiveEntryByCreationDate(id entryId1, id entryId2, void *reverse){
    if (*(BOOL *)reverse){
        return [entryId2 doubleValue] > [entryId1 doubleValue];
    }
    return [entryId1 doubleValue] > [entryId2 doubleValue];
}

@end
