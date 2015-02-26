//
//  ChallengeTableViewCell.h
//  ChallengeApp
//
//  Created by Tomasz Baranowicz on 10/13/14.
//  Copyright (c) 2014 Direct Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Challenge.h"

#define CHALLENGE_CELL_HEIGHT 95

@interface ChallengeTableViewCell : UITableViewCell
{
    
}

- (void) updateWithChallenge:(Challenge *)challenge;
@end
