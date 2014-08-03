//
//  SettingsViewController.m
//  SettingsExample
//
//  Created by Jake Marsh on 10/8/11.
//  Copyright (c) 2011 Rubber Duck Software. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@property (nonatomic, retain) UISwitch *airplaneModeSwitch;

@end

@implementation SettingsViewController
- (id) init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (!self) return nil;

	self.title = NSLocalizedString(@"设置", @"设置");

	return self;
}

#pragma mark - View lifecycle

- (void) viewDidLoad {
    [super viewDidLoad];

	[self addSection:^(JMStaticContentTableViewSection *section, NSUInteger sectionIndex) {
		[section addCell:^(JMStaticContentTableViewCell *staticContentCell, UITableViewCell *cell, NSIndexPath *indexPath) {
			cell.textLabel.text = NSLocalizedString(@"关于", @"关于");
//			cell.imageView.image = [UIImage imageNamed:@"About"];
		} whenSelected:^(NSIndexPath *indexPath) {
            [self modalViewAction:nil];
		}];
	}];
}
- (void) viewDidUnload {
    [super viewDidUnload];

	self.airplaneModeSwitch = nil;
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)modalViewAction:(id)sender
{
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"关于" message:NSLocalizedString(@"About", @"V1.0") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",@"确认") otherButtonTitles:nil];
    [alert show];
    [alert release];
}
@end