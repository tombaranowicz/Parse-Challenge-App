//
//  Utils.h
//  ChallengeApp
//
//  Created by Tomasz Baranowicz on 10/26/14.
//  Copyright (c) 2014 Direct Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define MAX_VIDEO_LENGTH 10.0f

@interface Utils : NSObject

+ (UIColor *)violetColor;
+ (UIColor *)blueColor;
+ (UIColor *)darkBlueColor;
+ (UIColor *)greenColor;
+ (UIColor *)redColor;

+ (UIColor *)themeColor;

+ (CGSize) defaultPhotoSize;
+(NSString *)abbreviateNumber:(int)num;
@end
