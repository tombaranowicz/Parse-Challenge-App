//
//  Utils.m
//  ChallengeApp
//
//  Created by Tomasz Baranowicz on 10/26/14.
//  Copyright (c) 2014 Direct Solutions. All rights reserved.
//

#import "Utils.h"

@implementation Utils

+ (UIColor *)violetColor {
    return [UIColor colorWithRed:161.0f/255.f green:68.0f/255.f blue:235.0f/255.f alpha:1.0f];
}

+ (UIColor *)blueColor {
    return [UIColor colorWithRed:75.0f/255.f green:181.0f/255.f blue:237.0f/255.f alpha:1.0f];
}

+ (UIColor *)darkBlueColor {
    return [UIColor colorWithRed:77.0f/255.f green:116.0f/255.f blue:182.0f/255.f alpha:1.0f];
}

+ (UIColor *)greenColor {
    return [UIColor colorWithRed:73.0f/255.f green:191.0f/255.f blue:73.0f/255.f alpha:1.0f];
}

+ (UIColor *)redColor {
    return [UIColor colorWithRed:232.0f/255.f green:86.0f/255.f blue:79.0f/255.f alpha:1.0f];
}

+ (UIColor *)themeColor {
    return [Utils greenColor];
}

+ (CGSize) defaultPhotoSize {
    return CGSizeMake(600, 600);
}

+(NSString *)abbreviateNumber:(int)num {
    
    NSString *abbrevNum;
    float number = (float)num;
    
    //Prevent numbers smaller than 1000 to return NULL
    if (num >= 1000) {
        NSArray *abbrev = @[@"k", @"m", @"b"];
        
        for (int i = (int)abbrev.count - 1; i >= 0; i--) {
            
            // Convert array index to "1000", "1000000", etc
            int size = pow(10,(i+1)*3);
            
            if(size <= number) {
                // Removed the round and dec to make sure small numbers are included like: 1.1K instead of 1K
                number = number/size;
                NSString *numberString = [self floatToString:number];
                
                // Add the letter for the abbreviation
                abbrevNum = [NSString stringWithFormat:@"%@%@", numberString, [abbrev objectAtIndex:i]];
            }
            
        }
    } else {
        
        // Numbers like: 999 returns 999 instead of NULL
        abbrevNum = [NSString stringWithFormat:@"%d", (int)number];
    }
    
    DLOG(@"abbrev: %@", abbrevNum);
    return abbrevNum;
}

+ (NSString *) floatToString:(float) val {
    NSString *ret = [NSString stringWithFormat:@"%.1f", val];
    unichar c = [ret characterAtIndex:[ret length] - 1];
    
    while (c == 48) { // 0
        ret = [ret substringToIndex:[ret length] - 1];
        c = [ret characterAtIndex:[ret length] - 1];
        
        //After finding the "." we know that everything left is the decimal number, so get a substring excluding the "."
        if(c == 46) { // .
            ret = [ret substringToIndex:[ret length] - 1];
        }
    }
    
    return ret;
}

@end