//
//  SBEpisodesViewController.m
//  SickBeard
//
//  Created by Colin Humber on 8/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SBEpisodesViewController.h"
#import "SickbeardAPIClient.h"
#import "NSUserDefaults+SickBeard.h"
#import "OrderedDictionary.h"
#import "SBComingEpisode.h"
#import "PRPAlertView.h"
#import "NSDate+Utilities.h"
#import "ComingEpisodeCell.h"
#import "SBSectionHeaderView.h"

@interface SBEpisodesViewController ()
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@end

@implementation SBEpisodesViewController

@synthesize selectedIndexPath;


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use. 
}


#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {		
	self.tableView.contentInset = UIEdgeInsetsMake(0, 0, self.navigationController.toolbar.frame.size.height, 0);
	self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
	
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	[TestFlight passCheckpoint:@"Viewed coming episodes"];
	
	[super viewWillAppear:animated];
	
	if ([self.tableView.dataSource numberOfSectionsInTableView:self.tableView] > 0) {
		[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
	}
	else {
		if ([NSUserDefaults standardUserDefaults].serverHasBeenSetup) {
			if (!comingEpisodes) {
				[comingEpisodes removeAllObjects];
				[self loadData];
			}
		}		
	}
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Actions
- (IBAction)refresh:(id)sender {
	[self loadData];
}

#pragma mark - Loading
- (void)loadData {
	[super loadData];
	
	[SVProgressHUD showWithStatus:NSLocalizedString(@"Loading upcoming episodes", @"Loading upcoming episodes")];
	
	[[SickbeardAPIClient sharedClient] runCommand:SickBeardCommandComingEpisodes 
									   parameters:nil 
										  success:^(NSURLRequest *request, NSURLResponse *response, id JSON) {
											  NSString *result = [JSON objectForKey:@"result"];
											  
											  if ([result isEqualToString:RESULT_SUCCESS]) {
												  comingEpisodes = [[OrderedDictionary alloc] init];
												  
												  NSMutableArray *episodes = [NSMutableArray array];
												  NSDictionary *dataDict = [JSON objectForKey:@"data"];
												  
												  for (NSString *key in [dataDict allKeys]) {
													  for (NSDictionary *epDict in [dataDict objectForKey:key]) {
														  SBComingEpisode *ep = [SBComingEpisode itemWithDictionary:epDict];
														  [episodes addObject:ep];
													  }
												  }
												  
												  NSMutableArray *past = [NSMutableArray array];
												  NSMutableArray *today = [NSMutableArray array];
												  NSMutableArray *thisWeek = [NSMutableArray array];
												  NSMutableArray *nextWeek = [NSMutableArray array];
												  NSMutableArray *future = [NSMutableArray array];
												  
												  for (SBComingEpisode *episode in episodes) {
													  if ([episode.airDate isToday]) {
														  [today addObject:episode];
													  }
													  else if ([episode.airDate isThisWeek]) {
														  [thisWeek addObject:episode];
													  }
													  else if ([episode.airDate isNextWeek]) {
														  [nextWeek addObject:episode];
													  }
													  else if ([episode.airDate isEarlierThanDate:[NSDate date]]) {
														  [past addObject:episode];
													  }
													  else {
														  [future addObject:episode];
													  }
												  }
												  
												  if (past.count) [comingEpisodes setObject:past forKey:@"Past"];
												  if (today.count) [comingEpisodes setObject:today forKey:@"Today"];
												  if (thisWeek.count) [comingEpisodes setObject:thisWeek forKey:@"This Week"];
												  if (nextWeek.count) [comingEpisodes setObject:nextWeek forKey:@"Next Week"];
												  if (future.count) [comingEpisodes setObject:future forKey:@"Future"];												  
												  
												  [self.tableView reloadData];
												  
												  [self finishDataLoad:nil];
												  [self.refreshHeader egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];

											  }
										  }
										  failure:^(NSURLRequest *request, NSURLResponse *response, NSError *error, id JSON) {
											  [PRPAlertView showWithTitle:NSLocalizedString(@"Error retrieving episodes", @"Error retrieving episodes")
																  message:error.localizedDescription 
															  buttonTitle:NSLocalizedString(@"OK", @"OK")];			
											  [self finishDataLoad:error];
											  [self.refreshHeader egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
										  }];
}


#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
	return [[comingEpisodes allKeys] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return [[comingEpisodes allKeys] objectAtIndex:section];
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	NSString *title = [self tableView:tableView titleForHeaderInSection:section];
	
	SBSectionHeaderView *header = [[SBSectionHeaderView alloc] init];
	header.sectionLabel.text = title;
	return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 50;
}
	
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSArray *keys = [comingEpisodes allKeys];
	NSString *sectionKey = [keys objectAtIndex:section];
	
	return [[comingEpisodes objectForKey:sectionKey] count];
}


- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	ComingEpisodeCell *cell = (ComingEpisodeCell*)[tv dequeueReusableCellWithIdentifier:@"ComingEpisodeCell"];
	
	NSArray *keys = [comingEpisodes allKeys];
	NSString *sectionKey = [keys objectAtIndex:indexPath.section];
	SBComingEpisode *episode = [[comingEpisodes objectForKey:sectionKey] objectAtIndex:indexPath.row];

	cell.showNameLabel.text = episode.showName;
	cell.networkLabel.text = episode.network;
	cell.episodeNameLabel.text = episode.name;
	cell.airDateLabel.text = [NSString stringWithFormat:@"%@ (%@)", [episode.airDate displayString], episode.quality];
	[cell.showImageView setImageWithURL:[[SickbeardAPIClient sharedClient] posterURLForTVDBID:episode.tvdbID] 
					   placeholderImage:[UIImage imageNamed:@"placeholder"]];

	if (indexPath.row == [self tableView:tv numberOfRowsInSection:indexPath.section] - 1) {
		cell.lastCell = YES;
	}
	else {
		cell.lastCell = NO;
	}
	
	return cell;
}

@end
