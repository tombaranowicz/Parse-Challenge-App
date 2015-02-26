//
//  AddNominationViewController.m
//  ChallengeApp
//
//  Created by Tomasz Baranowicz on 11/6/14.
//  Copyright (c) 2014 Direct Solutions. All rights reserved.
//

#import "AddNominationViewController.h"
#import "NominateTableViewCell.h"
#import <AFNetworking/AFNetworking.h>

@interface AddNominationViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>
{
    NSMutableArray *usersArray;
    UITableView *nominationsTableView;
    UILabel *emptyLabel;
}
@end

@implementation AddNominationViewController

//TODO add button to invite friends to use the app

- (void) showInviteAlert {
//    [[[UIAlertView alloc] initWithTitle:PROJECT_NAME message:[NSString stringWithFormat:@"Would you like to invite more your friends to use %@", PROJECT_NAME] delegate:self cancelButtonTitle:@"no" otherButtonTitles:@"yes", nil] show];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Nominate up to 3 friends";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(closeModalViewController)];
    
    nominationsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, self.view.frame.size.height)];
    nominationsTableView.delegate = self;
    nominationsTableView.dataSource = self;
    nominationsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:nominationsTableView];
    
    emptyLabel = [[UILabel alloc] initWithFrame:nominationsTableView.bounds];
    emptyLabel.textAlignment = NSTextAlignmentCenter;
    emptyLabel.textColor = [UIColor lightGrayColor];
    emptyLabel.numberOfLines = 2;
    emptyLabel.text = [NSString stringWithFormat:@"No friends using %@,\n invite them and play together!", PROJECT_NAME];
    
    self.selectedUsers = [[NSMutableArray alloc] init];
    usersArray = [[NSMutableArray alloc] init];
    
    [self getFriends];
}

- (void) getFriends {
    [self showIndeterminateProgressWithTitle:@"loading friends..."];
    
    NSMutableArray *friendUsersArray = [[NSMutableArray alloc] init];
    [FBRequestConnection startWithGraphPath:@"/me/friends" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            DLOG(@"user friends: %@", result);
            
            if ([result[@"data"] count]==0) { // no friends use the app
                [self hideIndeterminateProgress];
                [self showInviteAlert];
                return;
            }
            
            for (NSDictionary *dictionary in result[@"data"]) {
                [friendUsersArray addObject:dictionary[@"id"]];
                DLOG(@"Friend object class: %@", [dictionary[@"id"] class]);
            }
            
            PFQuery *query = [PFUser query];
            query.cachePolicy = kPFCachePolicyCacheElseNetwork;
            query.maxCacheAge = 60*60;
            [query whereKey:@"facebookId" containedIn:friendUsersArray];
            
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (error) {
                    [nominationsTableView reloadData];
                    [self hideIndeterminateProgress];
                    [self showInviteAlert];
                    return;
                } else {
                    [usersArray addObjectsFromArray:objects];
                    
                    if (result[@"paging"][@"next"]) {
                        [self getFriendsFromURL:result[@"paging"][@"next"]];
                    } else {
                        [nominationsTableView reloadData];
                        [self hideIndeterminateProgress];
                        [self showInviteAlert];
                    }
                }
            }];
        } else {
            [nominationsTableView reloadData];
            [self hideIndeterminateProgress];
            [self showInviteAlert];
            return;
        }
    }];
}

- (void) getFriendsFromURL:(NSString *)url {
    
    NSMutableArray *friendUsersArray = [[NSMutableArray alloc] init];

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];

    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        DLOG(@"request for url: %@ returned: %@", url, responseObject);
        if ([responseObject[@"data"] count]==0) { // no more friends use the app
            [nominationsTableView reloadData];
            [self hideIndeterminateProgress];
            [self showInviteAlert];
            return;
        }
        
        for (NSDictionary *dictionary in responseObject[@"data"]) {
            [friendUsersArray addObject:dictionary[@"id"]];
        }
        
        PFQuery *query = [PFUser query];
        query.cachePolicy = kPFCachePolicyCacheElseNetwork;
        query.maxCacheAge = 60*60;
        [query whereKey:@"facebookId" containedIn:friendUsersArray];// containedIn:friendUsersArray
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (error) {
                [nominationsTableView reloadData];
                [self hideIndeterminateProgress];
                [self showInviteAlert];
                return;
            } else {
                DLOG(@"returned me friends: %@", objects);
                [usersArray addObjectsFromArray:objects];
                
                if (responseObject[@"paging"][@"next"]) {
                    [self getFriendsFromURL:responseObject[@"paging"][@"next"]];
                } else {
                    [nominationsTableView reloadData];
                    [self hideIndeterminateProgress];
                    [self showInviteAlert];
                }
            }
        }];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self hideIndeterminateProgress];
        [nominationsTableView reloadData];
        [self showInviteAlert];
    }];
}

- (void) hideIndeterminateProgress {
    [HUD dismiss];
    HUD = nil;
    
    [emptyLabel removeFromSuperview];
    if (usersArray.count == 0) {
        [nominationsTableView addSubview:emptyLabel];
    }
}


#pragma mark UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return NOMINATE_CELL_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"commentCell";
    
    NominateTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (!cell) {
        cell = [[NominateTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    PFUser *user = [usersArray objectAtIndex:indexPath.row];
    [cell setUser:user];
    if ([self.selectedUsers containsObject:user]) {
        [cell setSelected:YES];
    } else {
        [cell setSelected:NO];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFUser *user = [usersArray objectAtIndex:indexPath.row];
    NominateTableViewCell *cell = (NominateTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
                                   
    if ([self.selectedUsers containsObject:user]) {        //remove and unselect
        [self.selectedUsers removeObject:user];
        [cell setSelected:NO];
    } else if(self.selectedUsers.count<3){        //set selected and add
        [self.selectedUsers addObject:user];
        [cell setSelected:YES];
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return usersArray.count;
}

#pragma mark UIAlertViewDelegate methods

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex==1) {
        DLOG(@"show facebook invite");
    }
}

@end
