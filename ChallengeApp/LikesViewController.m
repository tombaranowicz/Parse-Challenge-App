//
//  LikesViewController.m
//  ChallengeApp
//
//  Created by Tomasz Baranowicz on 10/17/14.
//  Copyright (c) 2014 Direct Solutions. All rights reserved.
//

#import "LikesViewController.h"
#import "LikeTableViewCell.h"
#import "UserProfileViewController.h"

@interface LikesViewController ()
{
    Challenge *challenge;
    ChallengeSolution *challengeSolution;
}
@end

@implementation LikesViewController

- (id) initWithChallenge:(Challenge *)challenge_
{
    self = [super init];
    if (self) {
        challenge = challenge_;
    }
    return self;
}

- (id) initWithChallengeSolution:(ChallengeSolution *)challengeSolution_
{
    self = [super init];
    if (self) {
        challengeSolution = challengeSolution_;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Likes";
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

#pragma mark - PFQueryTableViewController

- (PFQuery *)queryForTable {
    PFQuery *query = [PFQuery queryWithClassName:@"Like"];
    
    if (challenge) {
        [query whereKey:@"challenge" equalTo:challenge.object];
    } else if (challengeSolution) {
        [query whereKey:@"challengeSolution" equalTo:challengeSolution.object];
    }
    [query orderByDescending:@"createdAt"];
    [query setCachePolicy:kPFCachePolicyNetworkOnly];

    return query;
}

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    DLOG(@"did load objects: %@", error);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return LIKE_CELL_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *cellID = @"likeCell";
    
    LikeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (!cell) {
        cell = [[LikeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    [cell setLike:object];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PFObject *object = [self.objects objectAtIndex:indexPath.row];
    UserProfileViewController *vc = [[UserProfileViewController alloc] initWithPFUser:object[@"author"]];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
