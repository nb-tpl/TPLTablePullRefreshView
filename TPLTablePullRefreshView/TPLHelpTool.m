//
//  TPLHelpTool.m
//  Matchmaker_LYBT
//
//  Created by NB_TPL on 14-2-22.
//  Copyright (c) 2014年 李红微. All rights reserved.
//
#define MORE_WIDTH 0
#define ANIMATION_DURATION_DEFAULT 0.5

#import <ImageIO/ImageIO.h>

#import "TPLHelpTool.h"


//#import <ShareSDK/ShareSDK.h>



@implementation TPLHelpTool



#pragma mark
#pragma mark           about System
#pragma mark
//禁止交互
+(void)ignoringInteractionEvents
{
    if (![[UIApplication sharedApplication] isIgnoringInteractionEvents])    //禁止交互
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
}
//启用交互
+(void)endIgnoringInteractionEvents
{
    if ([[UIApplication sharedApplication] isIgnoringInteractionEvents])
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
}

//获得操作系统版本号
+(NSString *)getSystemVersion
{
    return  [[UIDevice currentDevice] systemVersion];
}

#pragma mark
#pragma mark---------------about Device---------------
+(NSString*)getDeviceType
{
    return  [[UIDevice currentDevice] model];
}


//获取当前Window最前面展示的ViewController
+(UIViewController*)getFrontViewController
{
    //找到window最前面的ViewController
    UIViewController *result = nil;
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    return result;
}


#pragma mark
#pragma mark---------------about Screen---------------
//获取屏幕分辨率
+(CGRect)getScreenRect
{
    return [[UIScreen mainScreen] bounds];
}
//获取屏幕尺寸
+(int)getScreenSize
{
    CGRect bounds = [TPLHelpTool getScreenRect];
    int size = 1;
    if (bounds.size.height <= 480 || bounds.size.height <= 960)
    {
        size = 1;
    }
    else if (bounds.size.height <= 1136)
    {
        size = 0;
    }
    return size;
}

#pragma mark
#pragma mark---------------about Calculate---------------
//获得字符串占的大小
+(CGSize)sizeOfString:(NSString*)string withFont:(UIFont*)font
{
    NSString * systemString = [TPLHelpTool getSystemVersion];
    CGSize size;
    if ([systemString intValue] >= 7)
    {
        size = [string sizeWithAttributes:[NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName]];
    }
    else
    {
        size = [string sizeWithFont:font];
    }
    
    return size;
}

//获得字符串长度
+(CGFloat)lengthOfString:(NSString*)string withFont:(UIFont*)font
{
    NSString * systemString = [TPLHelpTool getSystemVersion];
    CGSize size;
    if ([systemString intValue] >= 7)
    {
        size = [string sizeWithAttributes:[NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName]];
    }
    else
    {
        size = [string sizeWithFont:font];
    }
    
    return size.width + MORE_WIDTH;
}


//限定宽度，获得字符串高度
+(CGFloat)heightOfString:(NSString*)string withFont:(UIFont*)font forWidth:(CGFloat)width lineBreakMode:(NSLineBreakMode)lineBreakMode
{
    NSString * systemString = [TPLHelpTool getSystemVersion];
    CGSize size;
    if ([systemString intValue] >= 7)
    {
        NSDictionary * dic = [NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName, nil];
        size = [string boundingRectWithSize:CGSizeMake(width, 9999) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
    }
    else
    {
        //        string = [NSString stringWithFormat:@"%@     hahaha",string];
        //        size = [string sizeWithFont:font forWidth:width lineBreakMode:lineBreakMode];
        size = [string sizeWithFont:font constrainedToSize:CGSizeMake(width, 9999) lineBreakMode:lineBreakMode];
    }
    
    return size.height;
}

//获得两点间的距离
+(CGFloat)distanceFromBeginPoint:(CGPoint)beginPoint toEndPoint:(CGPoint)endPoint
{
    return sqrt((beginPoint.x - endPoint.x)*(beginPoint.x - endPoint.x) + (beginPoint.y - endPoint.y)*(beginPoint.y - endPoint.y));
}


#pragma mark
#pragma mark---------------about color
//获得一个随机颜色
+(UIColor*)getRandomColor
{
    return [UIColor colorWithRed:arc4random()%256/255.0f green:arc4random()%256/255.0f blue:arc4random()%256/255.0f alpha:1];
}

//16进制颜色转换成UIColor
+ (UIColor *)getHexColor:(NSString *)hexColor
{
    //    unsigned int red,green,blue;
    //    NSRange range;
    //    range.length = 2;
    //    range.location = 0;
    //    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&red];
    //    range.location = 2;
    //    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&green];
    //    range.location = 4;
    //    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&blue];
    //
    //    return [UIColor colorWithRed:(float)(red/255.0f) green:(float)(green / 255.0f) blue:(float)(blue / 255.0f) alpha:1.0f];
    
    NSString *cString = [[hexColor stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) {
        return [UIColor clearColor];
    }
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return [UIColor clearColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    
    //r
    NSString *rString = [cString substringWithRange:range];
    
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:1.0f];
}

#pragma mark
#pragma mark           about image
#pragma mark

//旋转图片
+(UIImage*)rotationImage:(UIImage*)image withAngle:(CGFloat)angle
{
    CGSize size = image.size;
    UIGraphicsBeginImageContext(size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextRotateCTM(ctx, angle);
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0,0,size.width, size.height), image.CGImage);
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;
}

//压缩图片
+ (UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize
{
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    // End the context
    UIGraphicsEndImageContext();
    // Return the new image.
    return newImage;
}

+(UIImage *)image:(UIImage *)img addText:(NSString *)text1
{
    int w = img.size.width;
    int h = img.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);
    CGContextDrawImage(context, CGRectMake(0, 0, w, h), img.CGImage);
    
    char* text= (char *)[text1 cStringUsingEncoding:NSASCIIStringEncoding];
    CGContextSelectFont(context, "Arial",20, kCGEncodingMacRoman);
    CGContextSetTextDrawingMode(context, kCGTextFill);
    CGContextSetRGBFillColor(context, 0, 0, 0, 1);
    CGContextShowTextAtPoint(context,10,10,text, strlen(text));
    CGImageRef imgCombined = CGBitmapContextCreateImage(context);
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    UIImage *retImage = [UIImage imageWithCGImage:imgCombined];
    CGImageRelease(imgCombined);
    
    return retImage;
}

//获取指定GIF图片的图片数组
+(NSMutableArray*)imageArrayFromGifFile:(NSString*)gifFilePath
{
    NSData *gifData = [NSData dataWithContentsOfFile: gifFilePath];
    NSMutableArray *frames = nil;
    CGImageSourceRef src = CGImageSourceCreateWithData((__bridge CFDataRef)gifData, NULL);
    if (src)
    {
        size_t l = CGImageSourceGetCount(src);
        if (l > 1)
        {
            frames = [NSMutableArray arrayWithCapacity: l];
            for (size_t i = 0; i < l; i++)
            {
                CGImageRef img = CGImageSourceCreateImageAtIndex(src, i, NULL);
                if (img) {
                    [frames addObject: [UIImage imageWithCGImage: img]];
                    CGImageRelease(img);
                }
            }
        }
    }
    
    return frames;
}
//指定UIImageView加载GIF
+(void)imageView:(UIImageView*)imageView loadGifFilePath:(NSString*)gifFliePath
{
    NSData *gifData = [NSData dataWithContentsOfFile: gifFliePath];
    NSMutableArray *frames = nil;
    CGImageSourceRef src = CGImageSourceCreateWithData((__bridge CFDataRef)gifData, NULL);
    double total = 0;
    NSTimeInterval gifAnimationDuration;
    if (src)
    {
        size_t l = CGImageSourceGetCount(src);
        if (l > 1)
        {
            frames = [NSMutableArray arrayWithCapacity: l];
            for (size_t i = 0; i < l; i++)
            {
                CGImageRef img = CGImageSourceCreateImageAtIndex(src, i, NULL);
                CFDictionaryRef dic = CGImageSourceCopyPropertiesAtIndex(src, 0, NULL);
                NSDictionary *dict = [NSDictionary dictionaryWithDictionary:CFBridgingRelease(dic)];
                
                if (dict){
                    NSDictionary *tmpdict = [dict objectForKey: @"{GIF}"];
                    total += [[tmpdict objectForKey: @"DelayTime"] doubleValue] * 100;
                }
                if (img) {
                    [frames addObject: [UIImage imageWithCGImage: img]];
                    CGImageRelease(img);
                }
            }
            gifAnimationDuration = total / 100;
            
            imageView.animationImages = frames;
            imageView.animationDuration = gifAnimationDuration;
            [imageView startAnimating];
        }
    }
    
    CFBridgingRelease(src);
}
//搞死模糊
+(UIImage *)blurryImage:(UIImage *)image withBlurLevel:(CGFloat)blur {
    CIImage *inputImage = [CIImage imageWithCGImage:image.CGImage];
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"
                                  keysAndValues:kCIInputImageKey, inputImage,
                        @"inputRadius", @(blur), nil ,nil];
    
    CIImage *outputImage = filter.outputImage;
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef outImage = [context createCGImage:outputImage fromRect:[inputImage extent]];
    return [UIImage imageWithCGImage:outImage];
}

#pragma mark
#pragma mark           about View
#pragma mark
//创建一个指定颜色和宽度的线视图
+(UIView*)createALineViewWithLineColor:(UIColor*)lineColor lineWidth:(CGFloat)lineWidth
{
    UIView * lineView = [[UIView alloc] init];
    lineView.layer.borderColor = lineColor.CGColor;
    lineView.layer.borderWidth = lineWidth;
    return lineView;
}

//给指定view上的所有view附上随即颜色
+(void)setRandomColorToSubviewsForView:(UIView*)view
{
    view.backgroundColor = [TPLHelpTool getRandomColor];
    if (view.subviews.count > 0)
    {
        for (UIView * subview in view.subviews)
        {
            [TPLHelpTool setRandomColorToSubviewsForView:subview];
        }
    }
}
//判断某个点是否在圆范围内 0为否，1为是
+(int)circleCenter:(CGPoint)center radius:(CGFloat)radius containsPoint:(CGPoint)point
{
    //    圆心到这个点的距离小于圆的半径，则这个点在圆内
    //    圆心到这个点的距离等于圆的半径，则这个点在圆周上
    //    圆心到这个点的距离大于圆的半径，则这个点在圆外
    int result = 0;
    NSLog(@"cha = %f",(point.x - center.x)*(point.x - center.x) + (point.y - center.y)*(point.y - center.y) - radius*radius);
    if((point.x - center.x)*(point.x - center.x) + (point.y - center.y)*(point.y - center.y) <= radius*radius)
    {
        result = 1;
    }
    else
    {
        result = 0;
    }
    return result;
}
//复制一个UIView
+(id)duplicate:(id)view
{
    NSData * tempArchive = [NSKeyedArchiver archivedDataWithRootObject:view];
    return [NSKeyedUnarchiver unarchiveObjectWithData:tempArchive];
}

//回到首页
+(void)backToWindow;
{
    void (^completionBlock)() = ^{
        
        UIViewController *result = nil;
        UIWindow * window = [[UIApplication sharedApplication] keyWindow];
        if (window.windowLevel != UIWindowLevelNormal)
        {
            NSArray *windows = [[UIApplication sharedApplication] windows];
            for(UIWindow * tmpWin in windows)
            {
                if (tmpWin.windowLevel == UIWindowLevelNormal)
                {
                    window = tmpWin;
                    break;
                }
            }
        }
        UIView *frontView = [[window subviews] objectAtIndex:0];
        id nextResponder = [frontView nextResponder];
        BOOL animation = YES;
        if ([nextResponder isKindOfClass:[UIViewController class]])
        {
            result = nextResponder;
        }
        else
            result = window.rootViewController;
        
        if([result.nextResponder isKindOfClass:[UIWindow class]])
        {
            return;
        }
        else
        {
            [result
             dismissViewControllerAnimated:animation completion:completionBlock];
        }
    };
    completionBlock();
}


#pragma mark
#pragma mark---------------about String
//修改接收的字符串，返回符合iOS系统的....主要是换行符不同
+(NSString *)htmlToString:(NSString *)str
{
    
    NSString *tempStr;
    //    tempStr = [str stringByReplacingOccurrencesOfString:@"<br />" withString:@""];
    
    
    
    if (str == nil)
    {
        return nil;
    }
    else
    {
        //tempStr = [str stringByReplacingOccurrencesOfString:@"&lt;p" withString:@""];
        //tempStr = [tempStr stringByReplacingOccurrencesOfString:@"&gt;" withString:@""];
        //            tempStr = [tempStr stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
        //            tempStr = [tempStr stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@""];
        //            tempStr = [tempStr stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
        
        tempStr = [str stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
        tempStr = [tempStr stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
        tempStr = [tempStr stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
        tempStr = [tempStr stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@""];
        tempStr = [tempStr stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
        
        
    }
    return tempStr;
}

//生成指定颜色指定font的富文本字符串
+(NSAttributedString*)creatAttributedString:(NSString*)text WithTextFont:(UIFont*)textFont textColor:(UIColor*)textColor
{
    NSAttributedString * attributeString = [[NSAttributedString alloc] initWithString:text attributes:[NSDictionary dictionaryWithObjectsAndKeys:textFont,NSFontAttributeName,textColor,NSForegroundColorAttributeName, nil]];
    
    
    return attributeString;
}

////去掉开始的空格
//+(NSString*)deleteFirstLineBlankForString:(NSString*)string
//{
//    NSMutableString * tempString = [NSMutableString stringWithString:string];
//    
//    
//    
//    return tempString;
//}

#pragma mark
#pragma mark           about Time
#pragma mark
//获取当年
+(NSInteger)currentYear
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDate *now;
    
    NSDateComponents *comps  ;
    
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit |
    NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    
    now=[NSDate date];
    
    comps = [calendar components:unitFlags fromDate:now];
    
    int year = (int)[comps year];
    
    
    return year;
}
//由日期获得星座
+(NSString *)getAstroWithMonth:(int)m day:(int)d{
    NSString *astroString = @"魔羯水瓶双鱼白羊金牛双子巨蟹狮子处女天秤天蝎射手魔羯";
    NSString *astroFormat = @"102123444543";
    NSString *result;
    if (m<1||m>12||d<1||d>31){
        return @"错误日期格式!";
    }
    if(m==2 && d>29)
    {
        return @"错误日期格式!!";
    }else if(m==4 || m==6 || m==9 || m==11) {
        if (d>30) {
            return @"错误日期格式!!!";
        }
    }
    result=[NSString stringWithFormat:@"%@",[astroString substringWithRange:NSMakeRange(m*2-(d < [[astroFormat substringWithRange:NSMakeRange((m-1), 1)] intValue] - (-19))*2,2)]];
    return result;
}
//由年份获得生肖
+(NSString *)getShengXiaoFromYear:(NSString*)year
{
    int i=[year intValue]%12;
    NSArray * shengXiaoArray = @[@"猴",@"鸡",@"狗",@"猪",@"鼠",@"牛",@"虎",@"兔",@"龙",@"蛇",@"马",@"羊"];
    return shengXiaoArray[i];
}
//获取距今时间差
+(NSString*)intervalSinceNow: (NSString*) theDate
{
    if ([theDate isKindOfClass:[NSNull class]])
    {
        return nil;
    }
    NSDateFormatter*date=[[NSDateFormatter alloc] init];
    [date setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate* d=[date dateFromString:theDate];
    NSTimeInterval late=[d timeIntervalSince1970]*1;
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval now=[dat timeIntervalSince1970]*1;
    NSString*timeString=@"";
    NSTimeInterval cha=now-late;
    //发表在一小时之内
    if(cha/3600<1) {
        if(cha/60<1) {
            timeString = @"1";
        }
        else
        {
            timeString = [NSString stringWithFormat:@"%f", cha/60];
            timeString = [timeString substringToIndex:timeString.length-7];
        }
        
        timeString=[NSString stringWithFormat:@"%@分钟前", timeString];
    }
    //在一小时以上24小以内
    else if(cha/3600>1&&cha/86400<1)
    {
        timeString = [NSString stringWithFormat:@"%f", cha/3600];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[NSString stringWithFormat:@"%@小时前", timeString];
    }
    //发表在24以上10天以内
    else if(cha/86400>1&&cha/864000<1)
    {
        timeString = [NSString stringWithFormat:@"%f", cha/86400];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[NSString stringWithFormat:@"%@天前", timeString];
    }
    //发表时间大于10天
    else
    {
        //        timeString = [NSString stringWithFormat:@"%d-%"]
        NSArray*array = [theDate componentsSeparatedByString:@" "];
        //        return [array objectAtIndex:0];
        timeString = [array objectAtIndex:0];
        timeString = [timeString substringWithRange:NSMakeRange(5, [timeString length]-5)];
    }
    return timeString;
}
//获得日期是今天昨天还是明天
+(NSString *)compareDate:(NSString *)date
{
    
    NSTimeInterval secondsPerDay = 24 * 60 * 60;
    NSDate *today = [[NSDate alloc] init];
    NSDate *tomorrow, *yesterday;
    
    tomorrow = [today dateByAddingTimeInterval: secondsPerDay];
    yesterday = [today dateByAddingTimeInterval: -secondsPerDay];
    
    // 10 first characters of description is the calendar date:
    NSString * todayString = [[today description] substringToIndex:10];
    NSString * yesterdayString = [[yesterday description] substringToIndex:10];
    NSString * tomorrowString = [[tomorrow description] substringToIndex:10];
    
    NSString * dateString = date;//[[date description] substringToIndex:10];
    
    if ([dateString isEqualToString:todayString])
    {
        return @"今天";
    } else if ([dateString isEqualToString:yesterdayString])
    {
        return @"昨天";
    }else if ([dateString isEqualToString:tomorrowString])
    {
        return @"明天";
    }
    else
    {
        return dateString;
    }
}
//将秒时间段换算成市场字典，key = week，day，hour，miniute,second
+(NSMutableDictionary*)covertTimeIntervalToDict:(NSUInteger)timeInterval
{
    NSMutableDictionary * timeDict = [NSMutableDictionary dictionaryWithCapacity:0];
    NSUInteger temp = timeInterval;
    //秒
    [timeDict setObject:[NSNumber numberWithUnsignedLong:temp%60] forKey:@"second"];
    //分
    temp = temp/60;
    if (temp > 0)
    {
        [timeDict setObject:[NSNumber numberWithUnsignedLong:temp%60] forKey:@"miniute"];
    }
    //时
    temp = temp/60;
    if (temp > 0)
    {
        [timeDict setObject:[NSNumber numberWithUnsignedLong:temp%24] forKey:@"hour"];
    }
    //天
    temp = temp/24;
    if (temp > 0)
    {
        [timeDict setObject:[NSNumber numberWithUnsignedLong:temp%7] forKey:@"day"];
    }
    
    temp = temp/7;
    if (temp > 0)
    {
        [timeDict setObject:[NSNumber numberWithUnsignedLong:temp] forKey:@"week"];
    }
    //
    return timeDict;
}

//获得年龄，key = year，month，day
+(NSMutableDictionary*)ageForBirthDay:(NSDate*)birthDay
{
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:0];
    
    // 出生日期转换 年月日
    NSDateComponents *components1 = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:birthDay];
    NSInteger birthDateYear  = [components1 year];
    NSInteger birthDateDay   = [components1 day];
    NSInteger birthDateMonth = [components1 month];
    
    // 获取系统当前 年月日
    NSDateComponents *components2 = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:[NSDate date]];
    NSInteger currentDateYear  = [components2 year];
    NSInteger currentDateDay   = [components2 day];
    NSInteger currentDateMonth = [components2 month];
    
    // 计算岁
    NSInteger year = currentDateYear - birthDateYear - 1;
    if ((currentDateMonth > birthDateMonth) || (currentDateMonth == birthDateMonth && currentDateDay >= birthDateDay)) {
        year++;
    }
    //岁
    [dict setObject:[NSNumber numberWithInteger:year] forKey:@"year"];
    //计算月
    NSInteger month = 0;
    if (currentDateMonth >= birthDateMonth)
    {
        month = currentDateMonth - birthDateMonth;
        if (currentDateDay < birthDateDay)
        {
            month--;
        }
    }
    else if (currentDateMonth < birthDateMonth)
    {
        month = 12 - birthDateMonth - currentDateMonth;
        if (currentDateDay < birthDateDay)
        {
            month--;
        }
    }
    [dict setObject:[NSNumber numberWithInteger:month] forKey:@"month"];
    
    //计算日
    NSInteger day = 0;
    if (currentDateDay >= birthDateDay)
    {
        day = currentDateDay - birthDateDay;
    }
    else if (currentDateDay < birthDateDay)
    {
        day = currentDateDay;
    }
    [dict setObject:[NSNumber numberWithInteger:day] forKey:@"day"];

    return dict;
}

#pragma mark
#pragma mark           about location distance
#pragma mark
#define PI 3.1415926
+(double) distanceForLongtitude1:(double)lon1 latitude1:(double)lat1 longtitude2:(double)lon2 latitude2:(double)lat2
{
    double er = 6378137; // 6378700.0f;
    //ave. radius = 6371.315 (someone said more accurate is 6366.707)
    //equatorial radius = 6378.388
    //nautical mile = 1.15078
    double radlat1 = PI*lat1/180.0f;
    double radlat2 = PI*lat2/180.0f;
    //now long.
    double radlong1 = PI*lon1/180.0f;
    double radlong2 = PI*lon2/180.0f;
    if( radlat1 < 0 ) radlat1 = PI/2 + fabs(radlat1);// south
    if( radlat1 > 0 ) radlat1 = PI/2 - fabs(radlat1);// north
    if( radlong1 < 0 ) radlong1 = PI*2 - fabs(radlong1);//west
    if( radlat2 < 0 ) radlat2 = PI/2 + fabs(radlat2);// south
    if( radlat2 > 0 ) radlat2 = PI/2 - fabs(radlat2);// north
    if( radlong2 < 0 ) radlong2 = PI*2 - fabs(radlong2);// west
    //spherical coordinates x=r*cos(ag)sin(at), y=r*sin(ag)*sin(at), z=r*cos(at)
    //zero ag is up so reverse lat
    double x1 = er * cos(radlong1) * sin(radlat1);
    double y1 = er * sin(radlong1) * sin(radlat1);
    double z1 = er * cos(radlat1);
    double x2 = er * cos(radlong2) * sin(radlat2);
    double y2 = er * sin(radlong2) * sin(radlat2);
    double z2 = er * cos(radlat2);
    double d = sqrt((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2)+(z1-z2)*(z1-z2));
    //side, side, side, law of cosines and arccos
    double theta = acos((er*er+er*er-d*d)/(2*er*er));
    double dist  = theta*er;
    return dist;
}


#pragma mark
#pragma mark           about Expression
#pragma mark
//返回表情字典
+(NSDictionary * )expressionDict;
{
    NSDictionary *  expressionDic = @{@"呲牙":@"000",@"调皮":@"001",@"冷汗":@"002",@"偷笑":@"003",@"再见":@"004",@"敲打":@"005",@"擦汗":@"006",@"猪头":@"007",@"玫瑰":@"008",@"流泪":@"009",@"大哭":@"010",@"嘘...":@"011", @"酷":@"012",@"抓狂":@"013", @"委屈":@"014", @"便便":@"015", @"炸弹":@"016", @"可爱":@"018",@"色":@"019",@"害羞":@"020",@"得意":@"021",@"吐":@"022",@"微笑":@"023",@"发怒":@"024",@"尴尬":@"025",@"惊恐":@"026",@"冷汗":@"027",@"爱心":@"028",@"示爱":@"029",@"白眼":@"030",@"傲慢":@"031",@"难过":@"032",@"惊讶":@"033",@"疑问":@"034",@"睡":@"035",@"亲亲":@"036",@"憨笑":@"037",@"爱情":@"038",@"衰":@"039",@"撇嘴":@"040",@"阴险":@"041",@"奋斗":@"042",@"发呆":@"043",@"右哼哼":@"044",@"拥抱":@"045",@"坏笑":@"046",@"飞吻":@"047",@"鄙视":@"048",@"晕":@"049",@"大兵":@"050",@"可怜":@"051",@"强":@"052",@"弱":@"053",@"握手":@"054",@"胜利":@"055",@"抱拳":@"056",@"凋谢":@"057",@"饭":@"058",@"蛋糕":@"059",@"西瓜":@"060",@"啤酒":@"061",@"瓢虫":@"062",@"勾引":@"063",@"OK":@"064",@"爱你":@"065",@"咖啡":@"066",@"钞票":@"067",@"月亮":@"068",@"菜刀":@"070",@"发抖":@"071",@"差 劲":@"072",@"拳头":@"073",@"心碎":@"074",@"太阳":@"075",@"礼物":@"076",@"足球":@"077",@"骷髅":@"078",@"挥手":@"079",@"闪电":@"080",@"撇嘴":@"081",@"困":@"082",@"惊讶":@"083",@"抓狂":@"084",@"抠鼻":@"085",@"鼓掌":@"086",@"糗大了":@"087", @"左哼哼":@"088",@"哈欠":@"089",@"快哭了":@"090",@"吓":@"091",@"篮球":@"092",@"乒乓":@"093",@"NO":@"094",@"跳跳":@"095",@"磕头":@"096",@"转圈":@"097",@"磕头":@"098",@"回头":@"099", @"跳绳":@"100",@"激动":@"101",@"怄火":@"102",@"献吻":@"103",@"左太极":@"104",@"右太极":@"105",@"闭嘴":@"106",@"双喜":@"108",@"鞭炮":@"109",@"灯笼":@"110",@"发财":@"111",@"K歌":@"112",@"购物":@"113", @"邮件":@"114",@"帅":@"115",@"喝彩":@"116",@"祈祷":@"117",@"爆筋":@"118",@"棒棒糖":@"119",@"喝奶":@"120",@"下面":@"121",@"香蕉":@"122",@"飞机":@"123",@"开车":@"124",@"高铁左车头":@"125",@"车厢":@"126",@"高铁右车头":@"127",@"多云":@"128",@"下雨":@"129",@"钞票":@"130",@"熊猫":@"131",@"灯泡":@"132",@"风车":@"133",@"闹钟":@"134",@"打伞":@"135",@"彩球":@"136",@"钻戒":@"137",@"沙发":@"138", @"纸巾":@"139",@"药":@"140",@"手枪":@"141",@"青蛙":@"142"};
    return expressionDic;
}


//返回表情数值数组
+(NSArray*)expressionArray
{
    NSArray *  expressionArray = @[@"000",@"001",@"002",@"003",@"004",@"005",@"006",@"007",@"008",@"009",@"010",@"011",@"012",@"013",@"014",@"015",@"016",@"018",@"019",@"020",@"021",@"022",@"023",@"024",@"025",@"026",@"027",@"028",@"029",@"030",@"031",@"032",@"033",@"034",@"035",@"036",@"037",@"038",@"039",@"040",@"041",@"042",@"043",@"044",@"045",@"046",@"047",@"048",@"049",@"050",@"051",@"052",@"053",@"054",@"055",@"056",@"057",@"058",@"059",@"060",@"061",@"062",@"063",@"064",@"065",@"066",@"067",@"068",@"070",@"071",@"072",@"073",@"074",@"075",@"076",@"077",@"078",@"079",@"080",@"081",@"082",@"083",@"084",@"085",@"086",@"087",@"088",@"089",@"090",@"091",@"092",@"093",@"094",@"095",@"096",@"097",@"098",@"099",@"100",@"101",@"102",@"103",@"104",@"105",@"106",@"108",@"109",@"110",@"111",@"112",@"113",@"114",@"115",@"116",@"117",@"118",@"119",@"120",@"121",@"122",@"123",@"124",@"125",@"126",@"127",@"128",@"129",@"130",@"131",@"132",@"133",@"134",@"135",@"136",@"137",@"138",@"139",@"140",@"141",@"142"];
    return expressionArray;
    
}

//返回表情名字数组
+(NSArray*)expressionNameArray
{
    return   [NSArray arrayWithObjects:@"呲牙",@"调皮",@"冷汗",@"偷笑",@"再见",@"敲打",@"擦汗",@"猪头",@"玫瑰",@"流泪",@"大哭",@"嘘...", @"酷",@"抓狂",@"委屈",@"便便",@"炸弹",@"可爱",@"色",@"害羞",@"得意",@"吐",@"微笑",@"发怒",@"尴尬",@"惊恐",@"冷汗",@"爱心",@"示爱",@"白眼",@"傲慢",@"难过",@"惊讶",@"疑问",@"睡",@"亲亲",@"憨笑",@"爱情",@"衰",@"撇嘴",@"阴险",@"奋斗",@"发呆",@"右哼哼",@"拥抱",@"坏笑",@"飞吻",@"鄙视",@"晕",@"大兵",@"可怜",@"强",@"弱",@"握手",@"胜利",@"抱拳",@"凋谢",@"饭",@"蛋糕",@"西瓜",@"啤酒",@"瓢虫",@"勾引",@"OK",@"爱你",@"咖啡",@"钞票",@"月亮",@"菜刀",@"发抖",@"差 劲",@"拳头",@"心碎",@"太阳",@"礼物",@"足球",@"骷髅",@"挥手",@"闪电",@"撇嘴",@"困",@"惊讶",@"抓狂",@"抠鼻",@"鼓掌",@"糗大了",@"左哼哼",@"哈欠",@"快哭了",@"吓",@"篮球",@"乒乓",@"NO",@"跳跳",@"磕头",@"转圈",@"磕头",@"回头",@"跳绳",@"激动",@"怄火",@"献吻",@"左太极",@"右太极",@"闭嘴", @"双喜",@"鞭炮",@"灯笼",@"发财",@"K歌",@"购物",@"邮件",@"帅",@"喝彩",@"祈祷",@"爆筋",@"棒棒糖",@"喝奶",@"下面",@"香蕉",@"飞机",@"开车",@"高铁左车头",@"车厢",@"高铁右车头",@"多云",@"下雨",@"钞票",@"熊猫",@"灯泡",@"风车",@"闹钟",@"打伞",@"彩球",@"钻戒",@"沙发",@"纸巾",@"药",@"手枪",@"青蛙",nil];
}


#pragma mark
#pragma mark           about animation
#pragma mark
//视图从一个frame扩大全屏再缩小到指定frame
+(void)animationfromNormalToBigToNormalView:(UIView*)animationView fromFrame:(CGRect)fromFrame  toFrame:(CGRect)toFrame midCompletion:(void(^)(BOOL finished))midCompletion completion:(void(^)(BOOL finished))completion
{
    //        UIView * copy_cicleView = [TPLHelpTool duplicate:animationView];
    
    animationView.frame = fromFrame;
    [[UIApplication sharedApplication].keyWindow addSubview:animationView];
    //禁止交互
    [TPLHelpTool ignoringInteractionEvents];
    [UIView animateWithDuration:0.2f animations:^{
        animationView.frame = CGRectMake(-200, -60, 800, 800);
        //                copy_cicleView.borderWidth = 8;
        //                copy_cicleView.borderColor = [UIColor colorWithRed:0.760 green:0.745 blue:0.774 alpha:1.000];
        //                copy_cicleView.fillColor = [UIColor colorWithRed:0.088 green:0.659 blue:0.887 alpha:1.000];
        
    } completion:^(BOOL finished)
     {
         midCompletion(finished);
         [UIView animateWithDuration:0.3f animations:^
          {
              animationView.frame = toFrame;
          }
                          completion:^(BOOL finished)
          {
              [animationView removeFromSuperview];
              completion(finished);
              //启用交互
              [TPLHelpTool endIgnoringInteractionEvents];
              //                copy_cicleView.frame = beginRect;
          }];
     }];
}
//视图从一个Frame动画到另一个frame
+(void)animationformNormalToNormalView:(UIView*)animationView fromFrame:(CGRect)fromFrame  toFrame:(CGRect)toFrame completion:(void (^)(BOOL finished))completion
{
    
    animationView.frame = fromFrame;
    [[UIApplication sharedApplication].keyWindow addSubview:animationView];
    //禁止交互
    [TPLHelpTool ignoringInteractionEvents];
    [UIView animateWithDuration:0.2 animations:^{
        animationView.frame = toFrame;
    } completion:^(BOOL finished)
     {
         //         [animationView removeFromSuperview];
         //启用交互
         [TPLHelpTool endIgnoringInteractionEvents];
         if (nil != completion)
         {
             completion(finished);
         }
     }];
}

//视图从一个点蹦出
+ (void)animationView:(UIView *)animationView appearAt:(CGPoint)location withDalay:(CGFloat)delay duration:(CGFloat)duration{
    animationView.center = location;
    CAKeyframeAnimation *scaleAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    scaleAnimation.duration = duration;
    scaleAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1)],[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.3, 1.3, 1)],[NSValue valueWithCATransform3D:CATransform3DMakeScale(1, 1, 1)]];
    scaleAnimation.calculationMode = kCAAnimationLinear;
    scaleAnimation.keyTimes = @[[NSNumber numberWithFloat:0.0f],[NSNumber numberWithFloat:delay],[NSNumber numberWithFloat:1.0f]];
    animationView.layer.anchorPoint = CGPointMake(0.5f, 0.5f);
    [animationView.layer addAnimation:scaleAnimation forKey:@"viewAppear"];
}

//视图蹦大蹦小
+ (void)animationScaleView:(UIView*)view{
    CAKeyframeAnimation *centerZoom = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    centerZoom.duration = 1.0f;
    centerZoom.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(1, 1, 1)],[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.5, 1.5, 1)],[NSValue valueWithCATransform3D:CATransform3DMakeScale(1, 1, 1)],[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1)],[NSValue valueWithCATransform3D:CATransform3DMakeScale(1, 1, 1)]];
    centerZoom.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [view.layer addAnimation:centerZoom forKey:@"viewScale"];
}


#pragma mark
#pragma mark           about file
#pragma mark
//创建原始图文件路径
+(NSString *)findUniqueSavePathImageWithDateString:(NSString*)dateString
{
    NSString *path1;
    do {
        path1 = [NSString stringWithFormat:@"%@/Documents/%@.jpg", NSHomeDirectory(), dateString];
    } while ([[NSFileManager defaultManager] fileExistsAtPath:path1]);
    return path1;
}


#pragma mark
#pragma mark---------------Util
+(void)clearAllSubviews:(UIView*)view
{
    for (UIView * subview in view.subviews)
    {
        subview.backgroundColor = [UIColor clearColor];
    }
}


#pragma mark
#pragma mark           share
#pragma mark
//+(void)share
//{
//        //构造分享内容
//        id<ISSContent> publishContent = [ShareSDK content:@"   有爱，母婴推荐NO.1"
//                                           defaultContent:@"用有爱，好妈妈"
//                                                    image:[ShareSDK pngImageWithImage:[UIImage imageNamed:@"icon.png"]]
//                                                    title:@"有爱，真有爱！"
//                                                      url:@"http://www.pgyer.com/gi9g"
//                                              description:@"有爱，母婴推荐NO.1"
//                                                mediaType:SSPublishContentMediaTypeApp];
//        
//        
//        //开始分享
//        //            [ShareSDK shareContent:publishContent
//        //                              type:ShareTypeWeixiSession
//        //                       authOptions:nil
//        //                     statusBarTips:YES
//        //                            result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end){
//        //
//        //                                if (state == SSPublishContentStateSuccess)
//        //                                {
//        //                                    //                            NSLog( @"分享成功!");
//        //                                }
//        //                                else if (state == SSPublishContentStateFail)
//        //                                {
//        //                                    //                            NSLog(@"分享失败,错误码:%d,错误描述:%@", [error errorCode], [error errorDescription]);
//        //                                }
//        //
//        //                            }];
//        [ShareSDK showShareActionSheet:nil
//                             shareList:nil
//                               content:publishContent
//                         statusBarTips:YES
//                           authOptions:nil
//                          shareOptions: nil
//                                result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end)
//         {
//             if (state == SSResponseStateSuccess)
//             {
//                 NSLog(@"分享成功");
//             }
//             else if (state == SSResponseStateFail)
//             {
//                 NSLog(NSLocalizedString(@"TEXT_SHARE_FAI", @"发布失败!error code == %d, error code == %@"), [error errorCode], [error errorDescription]);
//             }
//         }];
//}



@end

