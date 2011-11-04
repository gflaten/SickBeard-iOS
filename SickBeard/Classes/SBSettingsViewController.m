//
//  SBSettingsViewController.m
//  SickBeard
//
//  Created by Colin Humber on 8/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SBSettingsViewController.h"


@implementation SBSettingsViewController

@synthesize initialQualityLabel;
@synthesize archiveQualityLabel;
@synthesize statusLabel;
@synthesize seasonFolderSwitch;

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	NSString *identifier = segue.identifier;
	
	if ([identifier isEqualToString:@"InitialQualitySegue"]) {
		SBQualityViewController *vc = segue.destinationViewController;
		vc.qualityType = QualityTypeInitial;
		vc.delegate = self;
	}
	else if ([identifier isEqualToString:@"ArchiveQualitySegue"]) {
		SBQualityViewController *vc = segue.destinationViewController;
		vc.qualityType = QualityTypeInitial;
		vc.delegate = self;
	}
	else if ([identifier isEqualToString:@"StatusSegue"]) {
		SBStatusViewController *vc = segue.destinationViewController;
		vc.delegate = self;
	}
	else if ([identifier isEqualToString:@"ServerSegue"]) {
		
	}
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		
	self.initialQualityLabel.text = [NSString stringWithFormat:@"%d", defaults.initialQualities.count];
	self.archiveQualityLabel.text = [NSString stringWithFormat:@"%d", defaults.archiveQualities.count];
	self.statusLabel.text = defaults.status;
	self.seasonFolderSwitch.on = defaults.useSeasonFolders;
}

- (void)viewDidUnload
{
	self.initialQualityLabel = nil;
	self.archiveQualityLabel = nil;
	self.statusLabel = nil;
	self.seasonFolderSwitch = nil;
	
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Actions
- (IBAction)done:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)seasonFolderSwitched:(id)sender {
	[NSUserDefaults standardUserDefaults].useSeasonFolders = self.seasonFolderSwitch.on; 
}

#pragma mark - Quality and Status
- (void)statusViewController:(SBStatusViewController *)controller didSelectStatus:(NSString *)stat {
	[NSUserDefaults standardUserDefaults].status = stat;
	self.statusLabel.text = stat;
}

- (void)qualityViewController:(SBQualityViewController *)controller didSelectQualities:(NSMutableArray *)qualities {
	if (controller.qualityType == QualityTypeInitial) {
		[NSUserDefaults standardUserDefaults].initialQualities = qualities;
		self.initialQualityLabel.text = [NSString stringWithFormat:@"%d", qualities.count];
	}
	else if (controller.qualityType == QualityTypeArchive) {
		[NSUserDefaults standardUserDefaults].archiveQualities = qualities;
		self.archiveQualityLabel.text = [NSString stringWithFormat:@"%d", qualities.count];
	}
}


@end
