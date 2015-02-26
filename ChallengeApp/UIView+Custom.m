//
//  UIView+Custom.m
//  ChallengeApp
//
//  Created by Tomasz Baranowicz on 10/28/14.
//  Copyright (c) 2014 Direct Solutions. All rights reserved.
//

#import "UIView+Custom.h"

@implementation UIView (Custom)

- (void) addShadow {
    self.layer.shadowOffset = CGSizeMake(1, 1);
    self.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.layer.shadowRadius = 3.0f;
    self.layer.shadowOpacity = 0.80f;
    self.layer.shadowPath = [[UIBezierPath bezierPathWithRect:self.layer.bounds] CGPath];
}

@end
