//
//  PushManagerController.m
//  SuperNews
//
//  Created by ramonqlee on 8/22/14.
//  Copyright (c) 2014 IDreems. All rights reserved.
//

#import "PushManagerController.h"
#import "RMDefaults.h"
#import "BPush.h"

@interface PushManagerController ()
{
    NSMutableArray* tagSwitchFlags;
}
@end

@implementation PushManagerController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"管理推送通知";
    
    // Do any additional setup after loading the view.
    UIBarButtonItem *BackBtn = [[UIBarButtonItem alloc] initWithTitle:@"返回"
                                                                style:UIBarButtonItemStylePlain
                                                               target:self
                                                               action:@selector(BackToFormerAction:)];
    
    self.navigationItem.leftBarButtonItem = BackBtn;
    
    NSString* allTags = [RMDefaults stringForKey:kAllTags];
    NSArray* tags = [allTags componentsSeparatedByString:kComma];
    
    NSString* stringSwitchFlag = [RMDefaults stringForKey:kAllTagsSwitchFlag];
    NSArray* switchArr = [stringSwitchFlag componentsSeparatedByString:kComma];
    
    if (!tagSwitchFlags) {
        tagSwitchFlags = [[NSMutableArray alloc]initWithCapacity:switchArr.count];
        [tagSwitchFlags addObjectsFromArray:switchArr];
    }
    
    for (NSInteger i = 0;i < tags.count; ++i) {
        NSString* title  = [tags objectAtIndex:i];
        [self addSection:^(JMStaticContentTableViewSection *section, NSUInteger sectionIndex) {
            [section addCell:^(JMStaticContentTableViewCell *staticContentCell, UITableViewCell *cell, NSIndexPath *indexPath) {
                staticContentCell.reuseIdentifier = @"UIControlCell";
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                cell.textLabel.text = title;
                UISwitch* switchview = [[UISwitch alloc] initWithFrame:CGRectZero];
                switchview.tag = i;
                //- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;
                [switchview addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
                
                //on or not
                if (i<tagSwitchFlags.count) {
                    NSNumber* flag = [tagSwitchFlags objectAtIndex:i];
                    switchview.on = flag.boolValue;
                }
                
                cell.accessoryView = switchview;
                [switchview release];
                
            } whenSelected:^(NSIndexPath *indexPath) {
                //            [self openFavoriteAction:nil];
            }];
            
        }];
    }
}

-(IBAction)switchAction:(id)sender
{
    if (sender && [sender isKindOfClass:[UISwitch class]]) {
        UISwitch* switchView = (UISwitch*)sender;
        
        NSInteger pos = switchView.tag;
        if ( tagSwitchFlags && pos < tagSwitchFlags.count) {
            // reverse its value
            NSNumber* flag = [tagSwitchFlags objectAtIndex:pos];
            [tagSwitchFlags setObject:[NSNumber numberWithBool:!flag.boolValue] atIndexedSubscript:pos];
        }
    }
}

-(IBAction)BackToFormerAction:(id)sender
{
    // TODO 保存结果
//    [BPush setTags:tagArr];
    //delete tags
    NSString* allTags = [RMDefaults stringForKey:kAllTags];
    NSArray* tags = [allTags componentsSeparatedByString:kComma];
    
    NSMutableArray* delTagArr = [NSMutableArray array];
    NSMutableArray* keepTagArr = [NSMutableArray array];
    for (NSInteger i = 0; i < tagSwitchFlags.count; ++i) {
        NSNumber* flag = [tagSwitchFlags objectAtIndex:i];
        if (tags && i < tags.count) {
            if(!flag.boolValue)
            {
                [delTagArr addObject:[tags objectAtIndex:i]];
            }
            else
            {
                [keepTagArr addObject:[tags objectAtIndex:i]];
            }
        }
    }
    [BPush setTags:keepTagArr];
    [BPush delTags:delTagArr];
    
    [RMDefaults saveString:kAllTagsSwitchFlag withValue:[tagSwitchFlags componentsJoinedByString:kComma]];// 记录所有已经上传的tag
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
