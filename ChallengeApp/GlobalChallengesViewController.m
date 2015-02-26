//
//  GlobalChallengesViewController.m
//  ChallengeApp
//
//  Created by Tomasz Baranowicz on 10/12/14.
//  Copyright (c) 2014 Direct Solutions. All rights reserved.
//

#import "GlobalChallengesViewController.h"

#import "ChallengeDetailsViewController.h"
#import "Challenge.h"
#import "ChallengeTableViewCell.h"
#import "CreateChallengeViewController.h"
#import "WelcomeViewController.h"

#define CELL_IDENTIFIER @"globalChallengeCell"

@interface GlobalChallengesViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    //GLOBAL
    UITableView *globalTableView;
    NSArray *globalChallengesArray;
    UIRefreshControl *refreshControl;
    
    BOOL stopFetching;
    int pageNumber;
}

@end

@implementation GlobalChallengesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Popular Challenges";
    
    globalTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    globalTableView.dataSource = self;
    globalTableView.delegate = self;
    globalTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    refreshControl = [[UIRefreshControl alloc]init];
    [globalTableView addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(forceFetchData) forControlEvents:UIControlEventValueChanged];
    
    [self.view addSubview:globalTableView];
    [self forceFetchData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [globalTableView reloadData];
    
    if (userLoggedIn) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createChallenge)];
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    //check bool
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"presentedWelcome"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"presentedWelcome"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        WelcomeViewController *vc = [[WelcomeViewController alloc] init];
        [self showModalViewController:vc];
    }
}

- (void) createChallenge {
    CreateChallengeViewController *vc = [[CreateChallengeViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
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
        
        if (!refreshControl.isRefreshing) {
            [self showIndeterminateProgressWithTitle:@"loading..."];
        }
        
        PFQuery *query = [PFQuery queryWithClassName:@"Challenge"];
        [query orderByDescending:@"solutions"];
        query.limit = 20;
        query.skip = pageNumber*20;
        
        query.cachePolicy = kPFCachePolicyCacheElseNetwork;
        query.maxCacheAge = 60*60;

        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            if (error) {
                DLOG(@"error: %@", error);
                requestInProgress = NO;
                forceRefresh = NO;
                [refreshControl endRefreshing];
                [self hideIndeterminateProgress];

            } else {
                NSMutableArray *array = [[NSMutableArray alloc] init];
                if (!forceRefresh) {
                    [array addObjectsFromArray:globalChallengesArray];
                }
                
                for (PFObject *object in objects) {
                    [array addObject:[[Challenge alloc] initWithPFObject:object]];
                }
                
                globalChallengesArray = [NSArray arrayWithArray:array];
                [globalTableView reloadData];
                
                [refreshControl endRefreshing];
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
    return globalChallengesArray.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==globalChallengesArray.count-1) {
        [self fetchData];
    }
    
    ChallengeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER];
    if (!cell) {
        cell = [[ChallengeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_IDENTIFIER];
    }
    
    [cell updateWithChallenge:[globalChallengesArray objectAtIndex:indexPath.row]];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Challenge *challenge = [globalChallengesArray objectAtIndex:indexPath.row];
    ChallengeDetailsViewController *vc = [[ChallengeDetailsViewController alloc] initWithChallenge:challenge];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
