//
//  ArchiveTableViewController.m
//  Sudokubot
//
//  Created by Haoest on 4/12/11.
//  Copyright 2011 none. All rights reserved.
//

#import "ArchiveTableViewController.h"
#import "AppConfig.h"
#import "ArchiveEntry.h"
#import "BoardViewController.h"

@implementation ArchiveTableViewController

@synthesize archiveContents;


- (void)dealloc
{
    [super dealloc];
}

-(void) viewDidLoad{
    [super viewDidLoad];
}

+(ArchiveTableViewController*) archiveTableViewControllerFromDefaultArchive{
    ArchiveTableViewController* rv = [[ArchiveTableViewController alloc] initWithStyle:UITableViewStylePlain];
    rv.archiveContents = [ArchiveEntry loadArchive];
    return rv;
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger rv = [archiveContents count]; // exclude last row
    return rv;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	NSString *rowId = [NSString stringWithFormat:@"myRowId_%d", indexPath.row];
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:rowId];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:rowId] autorelease];
	}
    ArchiveEntry *archiveEntry = [archiveContents objectAtIndex:indexPath.row];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:[NSString stringWithCString:archiveDateFormat encoding:NSASCIIStringEncoding]];
	NSString *label = [NSString stringWithFormat:@"%@ : %@", [dateFormatter stringFromDate:archiveEntry.creationDate], archiveEntry.comments ];
    [dateFormatter release];
	cell.textLabel.text = label;
    UIFont* font = cell.textLabel.font;
    cell.textLabel.font = [font fontWithSize:archiveCellFontHeight];
	return cell;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return archiveCellHeight;
}

-(void) tableView: (UITableView*) tableView didSelectRowAtIndexPath:(NSIndexPath*) indexPath{
    NSArray *archive = [ArchiveEntry loadArchive];
    NSInteger index = indexPath.row;
    ArchiveEntry* entry = [archive objectAtIndex:index];
    BoardViewController *boardViewController = [BoardViewController boardWithArchiveEntry:entry];
    boardViewController.comments = entry.comments;
    boardViewController.superArchiveView = self.view.superview;
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    [self.view.superview addSubview:boardViewController.view];
}

@end
