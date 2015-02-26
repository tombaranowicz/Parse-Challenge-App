//
//  MyProfileViewController.m
//  ChallengeApp
//
//  Created by Tomasz Baranowicz on 10/30/14.
//  Copyright (c) 2014 Direct Solutions. All rights reserved.
//

#import "MyProfileViewController.h"
#import "LoginViewController.h"
#import "ChallengesViewController.h"
#import "SolutionsViewController.h"
#import "NominationTableViewCell.h"
#import "Nomination.h"
#import "ChallengeDetailsViewController.h"
#import <Parse/Parse.h>
#import <DTAlertView/DTAlertView.h>
#import <FontAwesomeKit/FontAwesomeKit.h>

#define CELL_IDENTIFIER @"nominationCell"

@interface MyProfileViewController () <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, DTAlertViewDelegate>
{
    PFUser *user;
    
    UILabel *userNameLabel;
    UILabel *challengesLabel;
    UILabel *solutionsLabel;
    PFImageView *userImageView;
    
    UITableView *nominationsTableView;
    NSArray *nominationsArray;
    
    BOOL stopFetching;
    int pageNumber;
    DTAlertView *alertView;
    UILabel *emptyLabel;
}
@end

@implementation MyProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"My account";
    
    userImageView = [[PFImageView alloc] initWithFrame:CGRectMake(10, 75, 70, 70)];
    userImageView.contentMode = UIViewContentModeScaleAspectFill;
    userImageView.clipsToBounds = YES;
    userImageView.layer.cornerRadius = 35.f;
    userImageView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    userImageView.layer.borderWidth = 0.5f;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userImageViewHandler)];
    userImageView.userInteractionEnabled = YES;
    [userImageView addGestureRecognizer:tap];
    [self.view addSubview:userImageView];
    
    userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 75, screenWidth-110, 17)];
    userNameLabel.textColor = [UIColor darkGrayColor];
    userNameLabel.font = [UIFont boldSystemFontOfSize:15.0f];
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(usernameLabelViewHandler)];
    userNameLabel.userInteractionEnabled = YES;
    [userNameLabel addGestureRecognizer:tap];
    [self.view addSubview:userNameLabel];
    
    challengesLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 100, 75, 40)];
    challengesLabel.numberOfLines = 2;
    challengesLabel.textColor = [UIColor darkGrayColor];
    challengesLabel.font = [UIFont boldSystemFontOfSize:12.0f];
    challengesLabel.textAlignment = NSTextAlignmentCenter;
    challengesLabel.userInteractionEnabled = YES;
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(challengesLabelHandler)];
    [challengesLabel addGestureRecognizer:tap];
    [self.view addSubview:challengesLabel];
    
    solutionsLabel = [[UILabel alloc] initWithFrame:CGRectMake(190, 100, 75, 40)];
    solutionsLabel.numberOfLines = 2;
    solutionsLabel.textColor = [UIColor darkGrayColor];
    solutionsLabel.font = [UIFont boldSystemFontOfSize:12.0f];
    solutionsLabel.textAlignment = NSTextAlignmentCenter;
    solutionsLabel.userInteractionEnabled = YES;
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(solutionsLabelHandler)];
    [solutionsLabel addGestureRecognizer:tap];
    [self.view addSubview:solutionsLabel];

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(userImageView.frame)+15, screenWidth-20, 20)];
    label.textColor = [UIColor darkGrayColor];
    label.font = [UIFont boldSystemFontOfSize:15.f];
    label.text = @"Pending nominations:";
    [self.view addSubview:label];
    
    nominationsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(label.frame)+10, screenWidth, self.view.frame.size.height - CGRectGetMaxY(label.frame) - 70)];
    nominationsTableView.dataSource = self;
    nominationsTableView.delegate = self;
    nominationsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:nominationsTableView];
    
    emptyLabel = [[UILabel alloc] initWithFrame:nominationsTableView.bounds];
    emptyLabel.textAlignment = NSTextAlignmentCenter;
    emptyLabel.textColor = [UIColor lightGrayColor];
    emptyLabel.text = @"You have no pending nominations :)";
}

- (void) usernameLabelViewHandler {

    alertView = [DTAlertView alertViewWithTitle:@"Change username" message:@"Please enter new username" delegate:self cancelButtonTitle:@"cancel" positiveButtonTitle:@"save"];
    [alertView setTextFieldDidChangeBlock:^(DTAlertView *_alertView, NSString *text) {
        [_alertView setPositiveButtonEnable:(text.length > 0)];
        alertView.textField.text = text.lowercaseString;
    }];
    
    [alertView setAlertViewMode:DTAlertViewModeTextInput];
    [alertView setTintColor:[Utils themeColor]];
    [alertView setPositiveButtonEnable:NO];
    [alertView showForPasswordInputWithAnimation:DTAlertViewAnimationDefault];
}

- (void) userImageViewHandler {
    NSString *other1 = @"take a photo";
    NSString *other2 = @"choose from library";
    NSString *cancelTitle = @"cancel";
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:cancelTitle
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:other1, other2, nil];
    [actionSheet showInView:self.view];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (![PFUser currentUser] || ![PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        [self showLogin];
    } else {
        user = [PFUser currentUser];
        
        FAKFontAwesome *icon = [FAKFontAwesome userIconWithSize:50.0f];
        [icon addAttribute:NSForegroundColorAttributeName value:[Utils themeColor]];
        userImageView.image = [icon imageWithSize:CGSizeMake(70, 70)];
        
        PFQuery *query = [PFUser query];
        query.cachePolicy = kPFCachePolicyCacheElseNetwork;
        query.maxCacheAge = 60*60;
        [query whereKey:@"objectId" equalTo:user.objectId];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            NSLog(@"GOT USER DATA: %@", object);
            userNameLabel.text = object[@"username"];
            userImageView.file = object[@"profileImageThumb"];
            challengesLabel.text = [NSString stringWithFormat:@"%d\nchallenges", [object[@"challenges"] intValue]];
            solutionsLabel.text = [NSString stringWithFormat:@"%d\nattempts", [object[@"solutions"] intValue]];
            [userImageView loadInBackground];
        }];
        
        [self forceFetchData];
    }
}

// A function for parsing URL parameters returned by the Feed Dialog.
- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}

- (void) showLogin
{
    [self showModalViewController:[[LoginViewController alloc] init]];
}

- (void) challengesLabelHandler {
    ChallengesViewController *vc = [[ChallengesViewController alloc] initForUser:user];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) solutionsLabelHandler {
    SolutionsViewController *vc = [[SolutionsViewController alloc] initForUser:user];
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
        
        PFQuery *query = [PFQuery queryWithClassName:@"Nomination"];
        query.limit = 20;
        query.skip = pageNumber*20;
        [query whereKey:@"to" equalTo:user];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            if (error) {
                DLOG(@"error: %@", error);
                requestInProgress = NO;
                forceRefresh = NO;
                [self hideIndeterminateProgress];
                
            } else {
                NSMutableArray *array = [[NSMutableArray alloc] init];
                if (!forceRefresh) {
                    [array addObjectsFromArray:nominationsArray];
                }
                
                for (PFObject *object in objects) {
                    [array addObject:[[Nomination alloc] initWithPFObject:object]];
                }
                
                nominationsArray = [NSArray arrayWithArray:array];
                [nominationsTableView reloadData];
                
                if (nominationsArray.count==0) {
                    [nominationsTableView addSubview:emptyLabel];
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
    return NOMINATION_CELL_HEIGHT;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return nominationsArray.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==nominationsArray.count-1) {
        [self fetchData];
    }
    
    NominationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER];
    if (!cell) {
        cell = [[NominationTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_IDENTIFIER];
    }
    
    [cell updateWithNomination:[nominationsArray objectAtIndex:indexPath.row]];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Nomination *nomination = [nominationsArray objectAtIndex:indexPath.row];
    if (nomination.challenge) {
        ChallengeDetailsViewController *vc = [[ChallengeDetailsViewController alloc] initWithChallenge:nomination.challenge];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

# pragma mark UIActionSheetDelegate method
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIImagePickerController *imagePicker = nil;
    imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    
    switch (buttonIndex) {
        case 1:
            imagePicker.sourceType=UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            [self presentViewController:imagePicker animated:YES completion:NULL];
            break;
        case 0:
            if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
                imagePicker.sourceType=UIImagePickerControllerSourceTypeCamera;
                [self presentViewController:imagePicker animated:YES completion:NULL];
            }
            break;
        default:
            break;
    }
}

#pragma UIImagePickerControllerDelegate methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *image = info[UIImagePickerControllerEditedImage];
    image = [self imageWithImage:image scaledToSize:CGSizeMake(100, 100)];
    
    NSData *imageData = UIImageJPEGRepresentation(image, 0.9f);

    PFFile *imageFile = [PFFile fileWithName:@"profileimage.png" data:imageData];
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            DLOG(@"uploaded user photo");
            [user setObject:imageFile forKey:@"profileImageThumb"];
            [user setObject:imageFile forKey:@"profileImage"];
            [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error) {
                    DLOG(@"error while saving: %@", error);
                } else {
                    DLOG(@"updated user photo");
                    userImageView.image = image;
                }
            }];
        } else {
            DLOG(@"error while uploading: %@", error);
        }
    }];
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - DTAlertView Delegate Methods

- (void)alertView:(DTAlertView *)alertView_ clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.textField != nil) {
        if (buttonIndex == alertView.cancelButtonIndex) {
            [alertView dismiss];
            return;
        }
        
        if (alertView.textField.text.length>0) {
            
            [user setUsername:alertView.textField.text.lowercaseString];
            [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error) {
                    DLOG(@"error %@", error);
                    [alertView shakeAlertView];
                    alertView.message = [NSString stringWithFormat:@"%@ is taken.", alertView.textField.text];
                } else {
                    DLOG(@"changed");
                    userNameLabel.text = alertView.textField.text;
                    [alertView dismiss];
                }
            }];
        }

        return;
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

@end
