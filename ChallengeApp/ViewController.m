//
//  ViewController.m
//  ChallengeApp
//
//  Created by Tomasz Baranowicz on 10/10/14.
//  Copyright (c) 2014 Direct Solutions. All rights reserved.
//

#import "ViewController.h"
#import "Challenge.h"
#import "ChallengeDetailsViewController.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>
{
    //GLOBAL
    UITableView *globalTableView;
    NSArray *globalChallengesArray;
    
    //MY
    UITableView *myTableView;
    NSArray *myChallengesArray;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Popular Challenges";
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    scrollView.contentSize = CGSizeMake(2*self.view.frame.size.width, self.view.frame.size.height);
    scrollView.pagingEnabled = YES;
    [self.view addSubview:scrollView];
    
    globalTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, scrollView.frame.size.width, scrollView.frame.size.height)];
    globalTableView.dataSource = self;
    globalTableView.delegate = self;
    [scrollView addSubview:globalTableView];
    
    myTableView = [[UITableView alloc] initWithFrame:CGRectMake(scrollView.frame.size.width, 0, scrollView.frame.size.width, scrollView.frame.size.height)];
    myTableView.dataSource = self;
    myTableView.delegate = self;
    [scrollView addSubview:myTableView];
    
    [self refreshGlobalTable];
    [self refreshMyTable];
}

- (void) refreshMyTable
{
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        PFQuery *query = [PFQuery queryWithClassName:@"Nomination"];
        query.limit = 20;
        [query whereKey:@"to" equalTo:[PFUser currentUser]];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            if (error) {
                NSLog(@"error: %@", error);
            } else {
                NSLog(@"returned my: %lu", (unsigned long)objects.count);

                NSMutableArray *array = [[NSMutableArray alloc] init];
                for (PFObject *object in objects) {
                    PFObject *obj = [object objectForKey:@"challenge"];
                    [array addObject:obj.objectId];
                }
  
                PFQuery *query = [PFQuery queryWithClassName:@"Challenge"];
                [query whereKey:@"objectId" containedIn:array];
                query.limit = 20;
                //    query.skip
                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {

                    if (error) {
                        NSLog(@"error: %@", error);
                    } else {
                        NSMutableArray *array = [[NSMutableArray alloc] init];
                        for (PFObject *object in objects) {
                            [array addObject:[[Challenge alloc] initWithPFObject:object]];
                        }
                        
                        myChallengesArray = [NSArray arrayWithArray:array];
                        [myTableView reloadData];
                    }
                }];
            }
        }];
    }
}

- (void) refreshGlobalTable
{
    PFQuery *query = [PFQuery queryWithClassName:@"Challenge"];
    query.limit = 20;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (error) {
            NSLog(@"error: %@", error);
        } else {
            
            NSMutableArray *array = [[NSMutableArray alloc] init];
            for (PFObject *object in objects) {
                [array addObject:[[Challenge alloc] initWithPFObject:object]];
            }
            
            globalChallengesArray = [NSArray arrayWithArray:array];
            [globalTableView reloadData];
        }
    }];
}

#pragma mark UITableViewDelegate methods
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView==myTableView) {
        return myChallengesArray.count;
    } else {
        return globalChallengesArray.count;
    }
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    Challenge *challenge = nil;
    
    if (tableView==myTableView) {
        challenge = [myChallengesArray objectAtIndex:indexPath.row];
    } else {
        challenge = [globalChallengesArray objectAtIndex:indexPath.row];
    }
    
    cell.textLabel.text = challenge.title;
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Challenge *challenge = nil;
    
    if (tableView==myTableView) {
        challenge = [myChallengesArray objectAtIndex:indexPath.row];
    } else {
        challenge = [globalChallengesArray objectAtIndex:indexPath.row];
    }
    
    ChallengeDetailsViewController *vc = [[ChallengeDetailsViewController alloc] initWithChallenge:challenge];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
