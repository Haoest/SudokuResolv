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

@interface ArchiveManager ()

@property(nonatomic, retain) NSMutableDictionary *allEntries;

-(int) getNextEntryId;

@end

@implementation ArchiveManager

@synthesize allEntries;

-(void) dealloc{
    [self.allEntries removeAllObjects];
    self.allEntries = nil;
    [super dealloc];
}

-(id) initDefaultArchive{
    self.allEntries = [[NSMutableDictionary alloc] initWithContentsOfFile:[AppConfig getArchiveFileName]];
    if (!self.allEntries){
        self.allEntries = [[[NSMutableDictionary alloc] init] autorelease];
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
    [allEntries setObject:value forKey:key];
    return entryId;
}

-(void) updateEntry:(ArchiveEntry*) entry{
    if (entry.entryId <0){
        return;
    }
    NSString *value = [entry toArchiveString];
    NSString *key = [NSString stringWithFormat:@"%d", [entry entryId]];
    [allEntries setValue:value forKey:key];
}

-(void) removeEntry:(int) entryId{
    NSString *key = [NSString stringWithFormat:@"%d", entryId];
    [allEntries removeObjectForKey:key];
}

-(bool) saveArchive{
    NSString* fileName = [AppConfig getArchiveFileName];
    return [allEntries writeToFile:fileName atomically:false];
}

-(NSMutableArray*) getAllEntries{
    NSMutableArray* arr = [[NSMutableArray alloc] initWithCapacity:[allEntries count]];
    for(NSString* entry in [self.allEntries allValues]){
        ArchiveEntry*e = [ArchiveEntry archiveEntryWithArchiveString:entry];
        [arr addObject:e];
    }
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"secondsSince1970" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSMutableArray* rv = [NSMutableArray arrayWithArray:[arr sortedArrayUsingDescriptors:sortDescriptors]];
    [arr removeAllObjects];
    [arr release];
    [sortDescriptor release];
    return rv;
}

-(int) getNextEntryId{
    int rv = 0;
    for(NSNumber* key in [allEntries allKeys]){
        if ([key intValue] > rv){
            rv = [key intValue];
        }
    }
    return rv+1;
}

@end
