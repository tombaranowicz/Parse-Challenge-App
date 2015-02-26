//
//  ChallengeSolutionTableViewCell.h
//  ChallengeApp
//
//  Created by Tomasz Baranowicz on 10/27/14.
//  Copyright (c) 2014 Direct Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChallengeSolution.h"

@protocol ChallengeSolutionTableViewCellDelegate
- (void)commentButtonTappedForSolution:(ChallengeSolution *)solution;
- (void)userButtonTappedForSolution:(ChallengeSolution *)solution;
- (void)challengeButtonTappedForSolution:(ChallengeSolution *)solution;
- (void)shareTappedForSolution:(ChallengeSolution *)solution;

@end

@interface ChallengeSolutionTableViewCell : UITableViewCell
{
    
}

- (void) updateWithChallengeSolution:(ChallengeSolution *)challengeSolution;
+ (float) heightForChallengeSolution:(ChallengeSolution *)challengeSolution;

@property (nonatomic, weak) id<ChallengeSolutionTableViewCellDelegate> cellDelegate;

@end