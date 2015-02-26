//
//  ExploreChallengesViewController.m
//  ChallengeApp
//
//  Created by Tomasz Baranowicz on 10/12/14.
//  Copyright (c) 2014 Direct Solutions. All rights reserved.
//

#import "ExploreChallengesViewController.h"
#import "Challenge.h"
#import "ChallengeTableViewCell.h"
#import "ChallengeDetailsViewController.h"
#import "NominateTableViewCell.h"
#import "UserProfileViewController.h"

#define CELL_IDENTIFIER @"exploreChallengeCell"

@interface ExploreChallengesViewController () <UITableViewDataSource, UITableViewDelegate>
{
    UIView *searchView;
    UITextField *searchTextField;
    UIButton *searchButton;
    
    NSString *searchTerm;
    
    UIButton *button1;
    UIButton *button2;
    
    UITableView* resultsTableView;
    NSArray *resultsArray;
    
    int pageNumber;
    BOOL stopFetching;
    
    NSString *lastChallengesRequest;
    NSString *lastUsersRequest;
    
    UILabel *emptyLabel;
}
@end

@implementation ExploreChallengesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Explore";
    
    button1 = [[UIButton alloc] initWithFrame:CGRectMake(5, CGRectGetMaxY(self.navigationController.navigationBar.frame)+5, screenWidth/2-5, 30)];
    [button1 setTitle:@"challenges" forState:UIControlStateNormal];
    [button1 setTitleColor:[Utils themeColor] forState:UIControlStateNormal];
    [button1 setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [button1 setBackgroundColor:[Utils themeColor]];
    [button1 setSelected:YES];
    [button1 addTarget:self action:@selector(switchHandler:) forControlEvents:UIControlEventTouchUpInside];
    button1.layer.borderWidth = 0.5f;
    button1.layer.borderColor = [[Utils themeColor] CGColor];
    [self.view addSubview:button1];
    
    button2 = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth/2, CGRectGetMaxY(self.navigationController.navigationBar.frame)+5, screenWidth/2-5, 30)];
    [button2 setTitle:@"users" forState:UIControlStateNormal];
    [button2 setTitleColor:[Utils themeColor] forState:UIControlStateNormal];
    [button2 setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [button2 setBackgroundColor:[UIColor whiteColor]];
    [button2 setSelected:NO];
    [button2 addTarget:self action:@selector(switchHandler:) forControlEvents:UIControlEventTouchUpInside];
    button2.layer.borderWidth = 0.5f;
    button2.layer.borderColor = [[Utils themeColor] CGColor];
    [self.view addSubview:button2];
    
    searchView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(button1.frame)+5, self.view.frame.size.width, 40)];
    searchView.backgroundColor = [Utils greenColor];
    
    searchTextField = [[UITextField alloc] initWithFrame:CGRectMake(5, 5, searchView.frame.size.width-70, 30)];
    searchTextField.placeholder = @"Search...";
    searchTextField.textColor = [UIColor darkGrayColor];
    searchTextField.backgroundColor = [UIColor whiteColor];
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    searchTextField.leftView = paddingView;
    searchTextField.leftViewMode = UITextFieldViewModeAlways;
    [searchView addSubview:searchTextField];
    
    searchButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(searchTextField.frame)+5, 5, 55, 30)];
    [searchButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [searchButton setTitle:@"search" forState:UIControlStateNormal];
    [searchButton addTarget:self action:@selector(search) forControlEvents:UIControlEventTouchUpInside];
    [searchView addSubview:searchButton];
    
    [self.view addSubview:searchView];
    
    resultsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(searchView.frame), screenWidth, self.view.frame.size.height-CGRectGetMaxY(searchView.frame)-TABBAR_HEIGHT)];
    resultsTableView.delegate = self;
    resultsTableView.dataSource = self;
    resultsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:resultsTableView];
    
    emptyLabel = [[UILabel alloc] initWithFrame:resultsTableView.bounds];
    emptyLabel.textAlignment = NSTextAlignmentCenter;
    emptyLabel.textColor = [UIColor lightGrayColor];
    emptyLabel.text = @"No results ;(";
}

- (void)switchHandler:(UIButton *)sender {
    if (sender==button1) {
        
        if (!button1.selected) {
            [button1 setSelected:YES];
            [button2 setSelected:NO];
            [self search];
        }
        
        [button1 setBackgroundColor:[Utils themeColor]];
        [button1 setSelected:YES];
        [button2 setBackgroundColor:[UIColor whiteColor]];
        [button2 setSelected:NO];
    } else {
        
        if (!button2.selected) {
            [button2 setSelected:YES];
            [button1 setSelected:NO];
            [self search];
        }
        
        [button1 setBackgroundColor:[UIColor whiteColor]];
        [button1 setSelected:NO];
        [button2 setBackgroundColor:[Utils themeColor]];
        [button2 setSelected:YES];
    }
}

- (void)search {
    if (searchTextField.text.length>0) {
        searchTerm = searchTextField.text;
        [searchTextField resignFirstResponder];
        forceRefresh = YES;
        stopFetching = NO;
        [self fetchData];
    }
}

- (void)fetchData
{
    if (!requestInProgress && !stopFetching) {
        requestInProgress = YES;
        
        if (forceRefresh) {
            pageNumber = 0;
        }
        
        [self showIndeterminateProgressWithTitle:@"loading..."];
        
        PFQuery *query = [PFQuery queryWithClassName:@"Challenge"];
        [query whereKey:@"name" matchesRegex:searchTerm modifiers:@"i"];
        
        if (button2.selected) {
            query = [PFUser query];
            query.cachePolicy = kPFCachePolicyCacheElseNetwork;
            query.maxCacheAge = 60*60;
            [query whereKey:@"username" containsString:searchTerm.lowercaseString];
            DLOG(@"query %@", query);
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
                DLOG(@"returned %@", objects);
                NSMutableArray *array = [[NSMutableArray alloc] init];
                if (!forceRefresh) {
                    [array addObjectsFromArray:resultsArray];
                }
                
                if (button2.selected) {
                    [array addObjectsFromArray:objects];
                } else {
                    for (PFObject *object in objects) {
                        [array addObject:[[Challenge alloc] initWithPFObject:object]];
                    }
                }
                
                resultsArray = [NSArray arrayWithArray:array];
                [resultsTableView reloadData];
                
                [emptyLabel removeFromSuperview];
                if (resultsArray.count==0) {
                    [resultsTableView addSubview:emptyLabel];
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
    
    if (button2.selected) {
        return NOMINATE_CELL_HEIGHT;
    }
    
    return CHALLENGE_CELL_HEIGHT;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return resultsArray.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==resultsArray.count-1) {
        [self fetchData];
    }
    
    if (button2.selected) {
        static NSString *cellID = @"commentCell";
        NominateTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell) {
            cell = [[NominateTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        }
        PFUser *user = [resultsArray objectAtIndex:indexPath.row];
        [cell setUser:user];
        return cell;
    }
    
    ChallengeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER];
    if (!cell) {
        cell = [[ChallengeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_IDENTIFIER];
    }
    [cell updateWithChallenge:[resultsArray objectAtIndex:indexPath.row]];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (button2.selected) {
        PFUser *user = [resultsArray objectAtIndex:indexPath.row];
        UserProfileViewController *vc = [[UserProfileViewController alloc] initWithPFUser:user];
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Challenge *challenge = [resultsArray objectAtIndex:indexPath.row];
    ChallengeDetailsViewController *vc = [[ChallengeDetailsViewController alloc] initWithChallenge:challenge];
    [self.navigationController pushViewController:vc animated:YES];
}


@end
