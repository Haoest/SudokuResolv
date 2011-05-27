//
//  ArchiveManager.m
//  Sudokubot
//
//  Created by Haoest on 5/23/11.
//  Copyright 2011 none. All rights reserved.
//

//first entry id is 1

#import "ArchiveManager.h"
#import "ArchiveEntry.h"
#import "AppConfig.h"

@implementation ArchiveManager

@synthesize allEntries;

-(id) initDefaultArchive{
    self.allEntries = [NSMutableDictionary dictionaryWithContentsOfFile:[AppConfig getArchiveFileName]];
    if (!self.allEntries){
        self.allEntries = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(ArchiveEntry*) getEntryById:(int) entryId{
    NSString *key = [NSString stringWithFormat:@"%d", entryId];
    NSString *rv = [self.allEntries objectForKey:key];
    if (!rv){
        return nil;
    }
    return [ArchiveEntry archiveEntryWithArchiveString: rv];
}

-(int) addEntry:(ArchiveEntry*) entry{
    int entryId = entry.entryId;
    if (entryId == -1){
        entryId = [self getNextEntryId];
    }else{
        return -1;
    }
    entry.entryId = entryId;
    NSString *key = [NSString stringWithFormat:@"%d", entryId];
    NSString *value = [entry toArchiveString];
    [self.allEntries setObject:value forKey:key];
    return entryId;
}

-(void) updateEntry:(ArchiveEntry*) entry{
    if (entry.entryId <0){
        return;
    }
    NSString *value = [entry toArchiveString];
    NSString *key = [NSString stringWithFormat:@"%d", [entry entryId]];
    [self.allEntries setValue:value forKey:key];
}

-(void) removeEntry:(int) entryId{
    NSString *key = [NSString stringWithFormat:@"%d", entryId];
    if ([self.allEntries objectForKey:key]){
        
    }
    [self.allEntries removeObjectForKey:key];
}

-(bool) saveArchive{
    NSString* fileName = [AppConfig getArchiveFileName];
    return [self.allEntries writeToFile:fileName atomically:false];
}

-(NSMutableArray*) getAllEntries{
    NSMutableArray* rv = [[NSMutableArray alloc] initWithCapacity:[self.allEntries count]];
    for(NSString* entry in [self.allEntries allValues]){
        [rv addObject:[ArchiveEntry archiveEntryWithArchiveString:entry]];
    }
    NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"secondsSince1970" ascending:NO] autorelease];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    return [NSMutableArray arrayWithArray:[rv sortedArrayUsingDescriptors:sortDescriptors]];
}

-(int) getNextEntryId{
    int rv = 0;
    for(NSNumber* key in [self.allEntries allKeys]){
        if ([key intValue] > rv){
            rv = [key intValue];
        }
    }
    return rv+1;
}

@end
