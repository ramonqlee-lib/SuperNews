//
//  CommonHelper.m
//  Hayate
//
//  Created by 韩 国翔 on 11-12-2.
//  Copyright 2011年 山东海天软件学院. All rights reserved.
//

#import "CommonHelper.h"
#import <CommonCrypto/CommonDigest.h>
#import "Flurry.h"

@implementation CommonHelper

+(NSString *)getFileSizeString:(NSString *)size
{
    if([size floatValue]>=1024*1024)//大于1M，则转化成M单位的字符串
    {
        return [NSString stringWithFormat:@"%fM",[size floatValue]/1024/1024];
    }
    else if([size floatValue]>=1024&&[size floatValue]<1024*1024) //不到1M,但是超过了1KB，则转化成KB单位
    {
        return [NSString stringWithFormat:@"%fK",[size floatValue]/1024];
    }
    else//剩下的都是小于1K的，则转化成B单位
    {
        return [NSString stringWithFormat:@"%fB",[size floatValue]];
    }
}

+(float)getFileSizeNumber:(NSString *)size
{
    
    NSInteger indexM=[size rangeOfString:@"M"].location;
    NSInteger indexK=[size rangeOfString:@"K"].location;
    NSInteger indexB=[size rangeOfString:@"B"].location;
    if(indexM<1000)//是M单位的字符串
    {
        return [[size substringToIndex:indexM] floatValue]*1024*1024;
    }
    else if(indexK<1000)//是K单位的字符串
    {
        return [[size substringToIndex:indexK] floatValue]*1024;
    }
    else if(indexB<1000)//是B单位的字符串
    {
        return [[size substringToIndex:indexB] floatValue];
    }
    else//没有任何单位的数字字符串
    {
        return [size floatValue];
    }
}
+(NSString *)getFileSizeStringWithFileName:(NSString *)fileName
{
    NSDictionary* dict = [[NSFileManager defaultManager]attributesOfItemAtPath:fileName error:nil];
    NSNumber* fileSize = [dict objectForKey:NSFileSize];
    
    return [CommonHelper getFileSizeString:fileSize.stringValue];
}
+(NSString*) getTargetBookPath:(NSString*)bookName
{
    NSString *documentsDirectory = [CommonHelper getTargetFolderPath];
    return [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"Data/%@",bookName]];
    
}

+(NSString *)getDocumentPath
{
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches"];
}

+(NSString *)getTargetFolderPath
{
    return [self getDocumentPath];
}

+(NSString *)getTempFolderPath
{
    return [[self getDocumentPath] stringByAppendingPathComponent:@"Temp"];
}

+(BOOL)isExistFile:(NSString *)fileName
{
    if (!fileName || [fileName length]==0) {
        return NO;
    }
    NSFileManager *fileManager=[NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:fileName];
}

#define kDotString @"."
#define kZipPackage @".zip"
#define kRarPackage @".rar"
#define kTxtPackage @".txt"
//extract packaged file to desFile
//zip,rar are supported right now
+(void)extractFile:(NSString*)srcFile toFile:(NSString*)desFilePath fileType:(NSString*)fileType
{}

+(BOOL)copyFile:(NSString*)srcFile toFile:(NSString*)desFile
{
    NSMutableData *writer = [[NSMutableData alloc]init];
    [CommonHelper makesureDirExist:[desFile stringByDeletingLastPathComponent]];
    
    NSData *reader = [NSData dataWithContentsOfFile:srcFile];
    [writer appendData:reader];
    [writer writeToFile:desFile atomically:YES];
    [writer release];
    return YES;
}
+(BOOL)unzipFile:(NSString*)zipFile toFile:(NSString*)unzipFile
{
    return NO;
    //    if (!zipFile || !unzipFile ) {
    //        return NO;
    //    }
    //    if(![[NSFileManager defaultManager]fileExistsAtPath:zipFile])
    //    {
    //        return NO;
    //    }
    //
    //    BOOL ret = NO;
    //    ZipArchive* zip = [[ZipArchive alloc] init];
    //    if( [zip UnzipOpenFile:zipFile] ){
    //        ret = [zip UnzipFileTo:unzipFile overWrite:YES];
    //        if( NO==ret ){
    //            //添加代码
    //        }
    //        [zip UnzipCloseFile];
    //    }
    //    [zip release];
    //    return ret;
}

+(NSString*)retBookFileNameInDirectory:(NSString*)path
{
    NSString* bookFileName = @"";
    //TODO::find book name in this directory
    //1.get file path
    //2.assume maximum-sized file in this path what we need
    
    return bookFileName;
}
+(void)makesureDirExist:(NSString*)directory
{
    NSError* err;
    //BOOL dir = NO;
    //if(![[NSFileManager defaultManager]fileExistsAtPath:directory isDirectory:&dir])
    {
        [[NSFileManager defaultManager]createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:&err];
    }
}


+(NSStringEncoding)dataEncoding:(const Byte*) header
{
    NSStringEncoding encoding = NSUTF8StringEncoding;
    if(header)
    {
        if ( !(header[0]==0xff || header[0] == 0xfe) ) {
            encoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        }
    }
    return encoding;
}
// 比较oldVersion和newVersion，如果oldVersion比newVersion旧，则返回YES，否则NO
// Version format[X.X.X]
+(BOOL)CompareVersionFromOldVersion : (NSString *)oldVersion
                         newVersion : (NSString *)newVersion
{
    NSArray*oldV = [oldVersion componentsSeparatedByString:@"."];
    NSArray*newV = [newVersion componentsSeparatedByString:@"."];
    NSUInteger len = MAX(oldV.count,newV.count);
    
    for (NSInteger i = 0; i < len; i++) {
        NSInteger old = (i<oldV.count)?[(NSString *)[oldV objectAtIndex:i] integerValue]:0;
        NSInteger new = (i<newV.count)?[(NSString *)[newV objectAtIndex:i] integerValue]:0;
        if (old != new) {
            return (new>old);
        }
    }
    return NO;
}

#pragma multiple params
+(id)performSelector:(NSObject*)obj selector:(SEL)selector withObject:(id)p1 withObject:(id)p2 withObject:(id)p3
{
    
    NSMethodSignature *sig = [obj methodSignatureForSelector:selector];
    
    if (sig)
    {
        NSInvocation* invo = [NSInvocation invocationWithMethodSignature:sig];
        
        [invo setTarget:obj];
        
        [invo setSelector:selector];
        
        [invo setArgument:&p1 atIndex:2];
        
        [invo setArgument:&p2 atIndex:3];
        
        [invo setArgument:&p3 atIndex:4];
        
        
        [invo invoke];
        
        if (sig.methodReturnLength) {
            
            id anObject;
            
            [invo getReturnValue:&anObject];
            
            return anObject;
        }
        else {
            return nil;
        }
    }
    else {
        return nil;
    }
}
+ (UIViewController *)getCurrentRootViewController {
    
    UIViewController *result = nil;
    //    if (rootViewController)
    //    {
    //        // If developer provieded a root view controler, use it
    //        result = rootViewController;
    //    }
    //    else
	{
		// Try to find the root view controller programmically
        
		// Find the top window (that is not an alert view or other window)
		UIWindow *topWindow = [[UIApplication sharedApplication] keyWindow];
		if (topWindow.windowLevel != UIWindowLevelNormal)
		{
			NSArray *windows = [[UIApplication sharedApplication] windows];
			for(topWindow in windows)
			{
				if (topWindow.windowLevel == UIWindowLevelNormal)
					break;
			}
		}
        
		UIView *rootView = [[topWindow subviews] objectAtIndex:0];
		id nextResponder = [rootView nextResponder];
        
		if ([nextResponder isKindOfClass:[UIViewController class]])
			result = nextResponder;
		else if ([topWindow respondsToSelector:@selector(rootViewController)] && topWindow.rootViewController != nil)
            result = topWindow.rootViewController;
		else
			NSAssert(NO, @"ShareKit: Could not find a root view controller.  You can assign one manually by calling [[SHK currentHelper] setRootViewController:YOURROOTVIEWCONTROLLER].");
	}
    return result;
}

+(NSString*)xor_string:(NSString*)stream key:(int)key
{
    NSMutableString* temp =[[[NSMutableString alloc]initWithCapacity:0]autorelease];
    for (int i = 0; i<temp.length; ++i) {
        [temp appendString:[NSString stringWithFormat:@"%d",[stream characterAtIndex:i]^key]];
    }
    return temp;
}

+(BOOL)sameApp:(NSString*)bundleID
{
    return [[[[NSBundle mainBundle]infoDictionary]objectForKey:(NSString*)kCFBundleIdentifierKey] isEqual:bundleID];
}
+ (NSString *)cachePathForKey:(NSString *)key
{
    const char *str = [key UTF8String];
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
    
    return filename;
}

+(BOOL)saveDefaultsForInt:(NSString*)key withValue:(NSInteger)value
{
    NSUserDefaults* setting = [NSUserDefaults standardUserDefaults];
    [setting setInteger:value forKey:key];
    return [setting synchronize];
}
+(NSInteger)defaultsForInt:(NSString*)key
{
    NSUserDefaults* setting = [NSUserDefaults standardUserDefaults];
    return [setting integerForKey:key];
}

+(BOOL)saveDefaultsForString:(NSString*)key withValue:(NSString*)value
{
    NSUserDefaults* setting = [NSUserDefaults standardUserDefaults];
    [setting setValue:value forKey:key];
    return [setting synchronize];
}
+(NSString*)defaultsForString:(NSString*)key
{
    NSUserDefaults* setting = [NSUserDefaults standardUserDefaults];
    return [setting valueForKey:key];
}

#define kInitLaunch @"kInitLaunch"
#define kNotInitLauchFlag 2
#define kInitLauchFlag 0

+(void)setInitLaunch
{
    NSUserDefaults* setting = [NSUserDefaults standardUserDefaults];
    [setting setInteger:kInitLauchFlag forKey:kInitLaunch];
    [setting synchronize];
}
+(void)setNotInitLaunch
{
    NSUserDefaults* setting = [NSUserDefaults standardUserDefaults];
    [setting setInteger:kNotInitLauchFlag forKey:kInitLaunch];
    [setting synchronize];
}
+(BOOL)initLaunch
{
    NSUserDefaults* setting = [NSUserDefaults standardUserDefaults];
    return ([setting integerForKey:kInitLaunch]==kInitLauchFlag);
}

+(NSString*)sqliteEscape:(NSString*) keyWord
{
    NSMutableString* r = [keyWord mutableCopy];
    NSArray* TEMP = @[@"/", @"//",@"'", @"''",@"[", @"/[",@"]", @"/]",@"%", @"/%",@"&",@"/&",@"_", @"/_",@"(", @"/(",@")", @"/)"];
    for (int i = 0; i<TEMP.count/2; i+=2) {
        [r replaceOccurrencesOfString:[TEMP objectAtIndex:i] withString:[TEMP objectAtIndex:(i+1)] options:NSCaseInsensitiveSearch range:NSMakeRange(0, r.length)];
    }
    return r;
}


/*由于在应用中有分享微博功能，文字较长时需要截断，导致不完整，
所以必须自动转成图片，发长微博来解决问题。先将方法分享如下，以下方法经过实际应用，没有问题。
*/
//#define CONTENT_MAX_WIDTH   300.0f
+(UIImage *)imageFromText:(NSArray*) arrContent withFont: (CGFloat)fontSize withMaxWidth:(CGFloat)width
{
    // set the font type and size
    UIFont *font = [UIFont systemFontOfSize:fontSize];
    NSMutableArray *arrHeight = [[NSMutableArray alloc] initWithCapacity:arrContent.count];
    
    CGFloat fHeight = 0.0f;
    for (NSString *sContent in arrContent) {
        CGSize stringSize = [sContent sizeWithFont:font constrainedToSize:CGSizeMake(width, 10000) lineBreakMode:NSLineBreakByWordWrapping];
        [arrHeight addObject:[NSNumber numberWithFloat:stringSize.height]];
        
        fHeight += stringSize.height;
    }
    
    
    CGSize newSize = CGSizeMake(width+20, fHeight+50);
    
    UIGraphicsBeginImageContextWithOptions(newSize,NO,0.0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetCharacterSpacing(ctx, 10);
    CGContextSetTextDrawingMode (ctx, kCGTextFillStroke);
    CGContextSetRGBFillColor (ctx, 0.1, 0.2, 0.3, 1); // 6
    CGContextSetRGBStrokeColor (ctx, 0, 0, 0, 1);
    
    int nIndex = 0;
    CGFloat fPosY = 20.0f;
    for (NSString *sContent in arrContent) {
        NSNumber *numHeight = [arrHeight objectAtIndex:nIndex];
        CGRect rect = CGRectMake(10, fPosY, width , [numHeight floatValue]);
        
        
        [sContent drawInRect:rect withFont:font lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentLeft];
        
        fPosY += [numHeight floatValue];
        nIndex++;
    }
    // transfer image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [arrHeight release];
    
    
    
    return image;
    
}
+(NSString*)displayName
{
    return [[[NSBundle mainBundle] localizedInfoDictionary]objectForKey:@"CFBundleDisplayName"];
}

//获取当前屏幕内容
+ (UIImage *)imageFromView:(UIView *)view
{
    // Draw a view’s contents into an image context
    UIGraphicsBeginImageContext(view.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}
//获得某个范围内的屏幕图像
+ (UIImage *)imageFromView: (UIView *) theView   atFrame:(CGRect)r
{
    UIGraphicsBeginImageContext(theView.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    UIRectClip(r);
    [theView.layer renderInContext:context];
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return  theImage;//[self getImageAreaFromImage:theImage atFrame:r];
}

#pragma mark 频道分类数据的保存和读取
// 保存分类
+(void)saveArchiver:(NSArray*)data path:(NSString*)filePath
{
    if (!data || !filePath) {
        return;
    }
    NSData * ret = [NSKeyedArchiver archivedDataWithRootObject:data];
    [ret writeToFile:filePath atomically:YES];
}

// 获取分类
+(NSArray*)readArchiver:(NSString*)filePath
{
    return [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
}

@end
