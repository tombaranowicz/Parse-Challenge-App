//
//  ChallengesViewController.m
//  ChallengeApp
//
//  Created by Tomasz Baranowicz on 10/27/14.
//  Copyright (c) 2014 Direct Solutions. All rights reserved.
//

#import "ChallengesViewController.h"
#import "ChallengeDetailsViewController.h"
#import "Challenge.h"
#import "ChallengeTableViewCell.h"

#define CELL_IDENTIFIER @"challengeCell"

@interface ChallengesViewController () <UITableViewDataSource, UITableViewDelegate>
{
    PFUser *user;
    
    UITableView *challengesTableView;
    NSArray *challengesArray;
    
    BOOL stopFetching;
    int pageNumber;
    UILabel *emptyLabel;
}
@end

@implementation ChallengesViewController

- (id) initForUser:(PFUser *)user_ {
    self = [super init];
    if (self) {
        user = user_;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Challenges";
    
    challengesTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.navigationController.navigationBar.frame), self.view.frame.size.width, self.view.frame.size.height-TABBAR_HEIGHT)];
    challengesTableView.dataSource = self;
    challengesTableView.delegate = self;
    challengesTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    emptyLabel = [[UILabel alloc] initWithFrame:challengesTableView.bounds];
    emptyLabel.textAlignment = NSTextAlignmentCenter;
    emptyLabel.textColor = [UIColor lightGrayColor];
    emptyLabel.text = @"No challenges ;(";
    
    [self.view addSubview:challengesTableView];
    [self forceFetchData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [challengesTableView reloadData];
}

- (void)forceFetchData
{
    forceRefresh = YES;
    stopFetching = NO;
    pageNumber=0;
    [self fetchData];
}

- (void)fetchData
{
    if (!requestInProgress && !stopFetching) {
        requestInProgress = YES;
        
        [self showIndeterminateProgressWithTitle:@"loading..."];
        
        PFQuery *query = [PFQuery queryWithClassName:@"Challenge"];
        
        if (user) {
            [query whereKey:@"author" equalTo:user];
        }
        
        query.limit = 20;
        query.skip = pageNumber*20;
        [query orderByDescending:@"createdAt"];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            if (error) {
                DLOG(@"error: %@", error);
                requestInProgress = NO;
                forceRefresh = NO;
                [self hideIndeterminateProgress];
                
            } else {
                NSMutableArray *array = [[NSMutableArray alloc] init];
                if (!forceRefresh) {
                    [array addObjectsFromArray:challengesArray];
                }
                
                for (PFObject *object in objects) {
                    [array addObject:[[Challenge alloc] initWithPFObject:object]];
                }
                
                challengesArray = [NSArray arrayWithArray:array];
                [challengesTableView reloadData];
                
                if (challengesArray.count==0) {
                    [challengesTableView addSubview:emptyLabel];
                } else {
                    [emptyLabel removeFromSuperview];
                }
                
                [self hideIndeterminateProgress];
                requestInProgress = NO;
                forceRefresh = NO;
                if (objects.count<20) {
                    stopFetching = YES;
                }
                pageNumber++;
            }
        }];
    }
}

#pragma mark UITableViewDelegate methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CHALLENGE_CELL_HEIGHT;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return challengesArray.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==challengesArray.count-1) {
        [self fetchData];
    }
    
    ChallengeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER];
    if (!cell) {
        cell = [[ChallengeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_IDENTIFIER];
    }
    
    [cell updateWithChallenge:[challengesArray objectAtIndex:indexPath.row]];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Challenge *challenge = [challengesArray objectAtIndex:indexPath.row];
    ChallengeDetailsViewController *vc = [[ChallengeDetailsViewController alloc] initWithChallenge:challenge];
    [self.navigationController pushViewController:vc animated:YES];
}

@end