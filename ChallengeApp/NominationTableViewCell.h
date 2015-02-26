//
//  NominationTableViewCell.h
//  ChallengeApp
//
//  Created by Tomasz Baranowicz on 10/30/14.
//  Copyright (c) 2014 Direct Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Nomination.h"

#define NOMINATION_CELL_HEIGHT 80

@interface NominationTableViewCell : UITableViewCell
{
    
}

- (void) updateWithNomination:(Nomination *)nomination;
@end
