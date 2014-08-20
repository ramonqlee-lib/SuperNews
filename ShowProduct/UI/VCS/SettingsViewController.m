//
//  SettingsViewController.m
//  SettingsExample
//
//  Created by Jake Marsh on 10/8/11.
//  Copyright (c) 2011 Rubber Duck Software. All rights reserved.
//

#import "SettingsViewController.h"
#import "RMFavoriteController.h"
#import "PrettyKit.h"
#import "HomeViewController.h"
#import "ScrollViewWithTopBar.h"
#import "OfflineDowloader.h"
#import "ZJTStatusBarAlertWindow.h"
#import "HTTPHelper.h"

@interface SettingsViewController ()<DownloadDelegate,UIAlertViewDelegate>

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
			cell.textLabel.text = NSLocalizedString(@"收藏", @"收藏");
            //			cell.imageView.image = [UIImage imageNamed:@"About"];
		} whenSelected:^(NSIndexPath *indexPath) {
            [self openFavoriteAction:nil];
		}];
        
		[section addCell:^(JMStaticContentTableViewCell *staticContentCell, UITableViewCell *cell, NSIndexPath *indexPath) {
			cell.textLabel.text = NSLocalizedString(@"离线下载", @"离线下载");
            //			cell.imageView.image = [UIImage imageNamed:@"About"];
		} whenSelected:^(NSIndexPath *indexPath) {
            [self offlineDownloadAction:nil];
		}];
        
        [section addCell:^(JMStaticContentTableViewCell *staticContentCell, UITableViewCell *cell, NSIndexPath *indexPath) {
			cell.textLabel.text = NSLocalizedString(@"清除缓存", @"清除缓存");
            //			cell.imageView.image = [UIImage imageNamed:@"About"];
		} whenSelected:^(NSIndexPath *indexPath) {
            [self clearCacheAction:nil];
		}];
	}];
    
	[self addSection:^(JMStaticContentTableViewSection *section, NSUInteger sectionIndex) {
        
		[section addCell:^(JMStaticContentTableViewCell *staticContentCell, UITableViewCell *cell, NSIndexPath *indexPath) {
			cell.textLabel.text = NSLocalizedString(@"关于", @"关于");
            //			cell.imageView.image = [UIImage imageNamed:@"About"];
		} whenSelected:^(NSIndexPath *indexPath) {
            [self openAboutAction:nil];
		}];
	}];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    UIBarButtonItem *BackBtn = [[UIBarButtonItem alloc] initWithTitle:@"返回"
                                                                style:UIBarButtonItemStylePlain
                                                               target:self
                                                               action:@selector(BackToFormerAction:)];
    
    self.navigationItem.leftBarButtonItem = BackBtn;
}

-(IBAction)BackToFormerAction:(id)sender
{
    UIViewController* rootController = [[[UIApplication sharedApplication]keyWindow]rootViewController];
    [rootController dismissViewControllerAnimated:YES completion:nil];
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

- (IBAction)openAboutAction:(id)sender
{
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"关于" message:NSLocalizedString(@"About", @"V1.0") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",@"确认") otherButtonTitles:nil];
    [alert show];
    [alert release];
}

- (IBAction)openFavoriteAction:(id)sender
{
    
    RMFavoriteController* vc = [[[RMFavoriteController alloc]init]autorelease];
    UINavigationController* controller = [[UINavigationController alloc]initWithNavigationBarClass:[PrettyNavigationBar class] toolbarClass:nil/*[PrettyToolbar class]*/];
    [controller setViewControllers:@[vc]];
    UIBarButtonItem *BackBtn = [[UIBarButtonItem alloc] initWithTitle:@"返回"
                                                                style:UIBarButtonItemStylePlain
                                                               target:self
                                                               action:@selector(BackAction:)];
    
    vc.navigationItem.leftBarButtonItem = BackBtn;
    [self presentViewController:controller animated:YES completion:nil];
}
-(IBAction)BackAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(IBAction)clearCacheAction:(id)sender
{
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"ClearCacheTitle", nil) message:NSLocalizedString(@"ClearCacheBody", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK",@"确认") otherButtonTitles:NSLocalizedString(@"Cancel",@"取消"),nil];
    [alert show];
    [alert release];
}

#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [HTTPHelper clearCache];
        
        [[ZJTStatusBarAlertWindow getInstance]showWithString:@"缓存清理完毕！"];
        double delayInSeconds = 2;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [[ZJTStatusBarAlertWindow getInstance] hide];
        });
    }
}
#pragma mark UIAlertViewDelegate end
-(IBAction)offlineDownloadAction:(id)sender
{
    OfflineDowloader* downloader = [OfflineDowloader sharedInstance];
    if ([downloader working]) {
        // : 下载中，状态栏弹出提示，返回
        [[ZJTStatusBarAlertWindow getInstance]showWithString:@"离线下载中，请耐心等待!!"];
        return;
    }
    
    // TODO 查看当前需要离线下载的频道，逐个下载；并在状态栏弹出提示；下载完毕，弹出提示
    // 1.查看当前需要离线下载的频道
    NSArray* mySubscriptionSavedCategories = [CommonHelper readArchiver:[HomeViewController topCategorySavePath]];
    if (mySubscriptionSavedCategories) {
        NSMutableArray* urlStringArr = [NSMutableArray array];
        [HomeViewController split:mySubscriptionSavedCategories titleArray:nil urlArray:urlStringArr];
        downloader.downloadDelegate = self;
        [downloader addTask:urlStringArr];
    }
    else
    {
        [[ZJTStatusBarAlertWindow getInstance]showWithString:@"请先订阅频道，然后离线下载"];
        double delayInSeconds = 2;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [[ZJTStatusBarAlertWindow getInstance] hide];
        });

    }
}
#pragma mark DownloadDelegate
-(void) complete
{
    [[ZJTStatusBarAlertWindow getInstance]showWithString:@"离线下载完毕！"];
    double delayInSeconds = 2;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [[ZJTStatusBarAlertWindow getInstance] hide];
    });
}
-(void) complete:(NSString*)url
{
    NSLog(@"offline dowloaded: %@",url);
    [[ZJTStatusBarAlertWindow getInstance]showWithString:@"离线下载中..."];
}
@end