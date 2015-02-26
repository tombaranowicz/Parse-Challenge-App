//
//  NominateTableViewCell.h
//  ChallengeApp
//
//  Created by Tomasz Baranowicz on 11/6/14.
//  Copyright (c) 2014 Direct Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

#define NOMINATE_CELL_HEIGHT 50.0f

@interface NominateTableViewCell : UITableViewCell
{
    
}

@property (nonatomic, strong) PFUser *user;
@end
