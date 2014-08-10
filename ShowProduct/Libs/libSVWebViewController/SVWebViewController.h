//
//  SVWebViewController.h
//
//  Created by Sam Vermette on 08.11.10.
//  Copyright 2010 Sam Vermette. All rights reserved.
//
//  https://github.com/samvermette/SVWebViewController

#import <MessageUI/MessageUI.h>

#import "SVModalWebViewController.h"

@interface SVWebViewController : UIViewController

- (id)initWithAddress:(NSString*)urlString;
- (id)initWithURL:(NSURL*)URL;

@property (nonatomic, copy) NSString* titleString;
@property (nonatomic, copy) NSString* htmlBody;
@property (nonatomic, assign ) CGRect webviewFrame;

- (void)goHome;// 返回主页
- (void)zoomIn;// 放大文字
- (void)zoomOut;// 缩小文字

@end
