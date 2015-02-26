//
//  SolutionsViewController.m
//  ChallengeApp
//
//  Created by Tomasz Baranowicz on 10/27/14.
//  Copyright (c) 2014 Direct Solutions. All rights reserved.
//

#import "SolutionsViewController.h"
#import "ChallengeSolution.h"
#import "ChallengeSolutionTableViewCell.h"
#import "CommentsViewController.h"
#import "ChallengeDetailsViewController.h"
#import "UserProfileViewController.h"

#define CELL_IDENTIFIER @"solutionCell"

#define TABLE_PAGE_SIZE 5

@interface SolutionsViewController () <UITableViewDataSource, UITableViewDelegate, ChallengeSolutionTableViewCellDelegate>
{
    PFUser *user;
    Challenge *challenge;
    
    UITableView *solutionsTableView;
    NSArray *solutionsArray;
    
    BOOL stopFetching;
    int pageNumber;
    
    UILabel *emptyLabel;
}
@end

@implementation SolutionsViewController

- (id) initForUser:(PFUser *)user_ {
    self = [super init];
    if (self) {
        user = user_;
    }
    return self;
}

- (id) initForChallenge:(Challenge *)challenge_ {
    self = [super init];
    if (self) {
        challenge = challenge_;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Attempts";
    
    solutionsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    solutionsTableView.dataSource = self;
    solutionsTableView.delegate = self;
    solutionsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    emptyLabel = [[UILabel alloc] initWithFrame:solutionsTableView.bounds];
    emptyLabel.textAlignment = NSTextAlignmentCenter;
    emptyLabel.textColor = [UIColor lightGrayColor];
    emptyLabel.text = @"No attempts ;(";
    
    [self.view addSubview:solutionsTableView];
    [self forceFetchData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [solutionsTableView reloadData];
}

- (void)forceFetchData
{
    forceRefresh = YES;
    stopFetching = NO;
    [self fetchData];
}

- (void)fetchData
{
    if (!requestInProgress && !stopFetching) {
        requestInProgress = YES;
        
        [self showIndeterminateProgressWithTitle:@"loading..."];
        
        PFQuery *query = [PFQuery queryWithClassName:@"ChallengeSolution"];
//        query.cachePolicy = kPFCachePolicyCacheElseNetwork;
//        query.maxCacheAge = 60*60;
        
        if (user) {
            [query whereKey:@"user" equalTo:user];
        } else {
            [query whereKey:@"challenge" equalTo:challenge.object];
        }
        
        query.limit = TABLE_PAGE_SIZE;
        query.skip = pageNumber*TABLE_PAGE_SIZE;
        [query orderByDescending:@"createdAt"];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            if (error) {
                DLOG(@"error: %@", error);
                requestInProgress = NO;
                forceRefresh = NO;
                [self hideIndeterminateProgress];
                
            } else {
                DLOG(@"solution objects: %@", objects);
                NSMutableArray *array = [[NSMutableArray alloc] init];
                if (!forceRefresh) {
                    [array addObjectsFromArray:solutionsArray];
                }
                
                for (PFObject *object in objects) {
                    [array addObject:[[ChallengeSolution alloc] initWithPFObject:object]];
                }
                
                solutionsArray = [NSArray arrayWithArray:array];
                [solutionsTableView reloadData];
                
                if (solutionsArray.count==0) {
                    [solutionsTableView addSubview:emptyLabel];
                } else {
                    [emptyLabel removeFromSuperview];
                }
                
                [self hideIndeterminateProgress];
                requestInProgress = NO;
                forceRefresh = NO;
                if (objects.count<TABLE_PAGE_SIZE) {
                    stopFetching = YES;
                }
                pageNumber++;
            }
        }];
    }
}

#pragma mark UITableViewDelegate methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [ChallengeSolutionTableViewCell heightForChallengeSolution:[solutionsArray objectAtIndex:indexPath.row]];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return solutionsArray.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==solutionsArray.count-1) {
        [self fetchData];
    }
    
    ChallengeSolutionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER];
    cell.cellDelegate = self;
    if (!cell) {
        cell = [[ChallengeSolutionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_IDENTIFIER];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    [cell updateWithChallengeSolution:[solutionsArray objectAtIndex:indexPath.row]];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark ChallengeSolutionTableViewCellDelegate methods
- (void) commentButtonTappedForSolution:(ChallengeSolution *)solution {
    CommentsViewController *vc = [[CommentsViewController alloc] initWithChallengeSolution:solution];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)userButtonTappedForSolution:(ChallengeSolution *)solution {
    UserProfileViewController *vc = [[UserProfileViewController alloc] initWithPFUser:solution.author];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)challengeButtonTappedForSolution:(ChallengeSolution *)solution {
    
    if (solution.challenge) {
        ChallengeDetailsViewController *vc = [[ChallengeDetailsViewController alloc] initWithChallenge:solution.challenge];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)shareTappedForSolution:(ChallengeSolution *)solution {
    
    UIImage *imageToShare = solution.loadedImage;
    NSString *challengeTitle = [NSString stringWithFormat:@"I've found cool attempt to \"%@\" in Let's Challenge Me app. To play with me, download the app: http://letschallenge.me/", solution.challenge.title];
    
    NSMutableArray *items = [NSMutableArray new];
    [items addObject:challengeTitle];
    [items addObject:imageToShare];
    
    NSArray *activityItems = [NSArray arrayWithArray:items];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    [self presentViewController:activityViewController animated:YES completion:^{}];
}

@end