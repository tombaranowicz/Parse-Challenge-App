//
//  CommentsViewController.m
//  ChallengeApp
//
//  Created by Tomasz Baranowicz on 10/14/14.
//  Copyright (c) 2014 Direct Solutions. All rights reserved.
//

#import "CommentsViewController.h"
#import "CommentTableViewCell.h"
#import "Comment.h"
#import "UserProfileViewController.h"

@interface CommentsViewController () <UITableViewDataSource, UITableViewDelegate>
{
    Challenge *challenge;
    ChallengeSolution *challengeSolution;
    
    UIView *responseView;
    UITextField *responseTextField;
    UIButton *sendButton;
    
    UITableView* commentsTableView;
    NSArray *commentsArray;
    int pageNumber;
    BOOL stopFetching;
}
@end

@implementation CommentsViewController

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
    
    self.navigationItem.title = @"Comments";
    commentsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, self.view.frame.size.height-40)];
    commentsTableView.delegate = self;
    commentsTableView.dataSource = self;
    commentsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:commentsTableView];
    
    responseView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(commentsTableView.frame)-49, self.view.frame.size.width, 40)];
    responseView.backgroundColor = [Utils greenColor];
    [self.view addSubview:responseView];
    
    responseTextField = [[UITextField alloc] initWithFrame:CGRectMake(5, 5, responseView.frame.size.width-70, 30)];
    responseTextField.placeholder = @"Write a comment";
    responseTextField.backgroundColor = [UIColor whiteColor];
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    responseTextField.leftView = paddingView;
    responseTextField.leftViewMode = UITextFieldViewModeAlways;
    [responseView addSubview:responseTextField];
    
    sendButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(responseTextField.frame)+5, 5, 55, 30)];
    [sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sendButton setTitle:@"send" forState:UIControlStateNormal];
    [sendButton addTarget:self action:@selector(sendComment) forControlEvents:UIControlEventTouchUpInside];
    [responseView addSubview:sendButton];
    
    if (![PFUser currentUser]) {
        responseView.userInteractionEnabled = NO;
        responseTextField.userInteractionEnabled = NO;
        sendButton.userInteractionEnabled = NO;
    }
    
    [self fetchData];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Register Keyboard Notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)fetchData
{
    if (!requestInProgress && !stopFetching) {
        requestInProgress = YES;
        
        [self showIndeterminateProgressWithTitle:@"loading..."];
        
        PFQuery *query = [PFQuery queryWithClassName:@"Comment"];
        if (challenge) {
            [query whereKey:@"challenge" equalTo:challenge.object];
        } else if (challengeSolution) {
            [query whereKey:@"challengeSolution" equalTo:challengeSolution.object];
        }
        [query orderByDescending:@"createdAt"];
        query.limit = 20;
        query.skip = pageNumber*20;

        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            if (error) {
                NSLog(@"error: %@", error);
                requestInProgress = NO;
                [self hideIndeterminateProgress];
            } else {
                
                if (objects.count<20) {
                    stopFetching = YES;
                }
                
                NSMutableArray *array = [[NSMutableArray alloc] initWithArray:commentsArray];
                for (PFObject *object in objects) {
                    [array addObject:[[Comment alloc] initWithPFObject:object]];
                }
                
                commentsArray = [NSArray arrayWithArray:array];
                [commentsTableView reloadData];
                
                [self hideIndeterminateProgress];
                requestInProgress = NO;
                pageNumber++;
            }
        }];
    }
}

- (void) sendComment {
    if (responseTextField.text.length>0 && [PFUser currentUser]) {
        [self showIndeterminateProgressWithTitle:@"sending..."];
        PFObject *comment = [PFObject objectWithClassName:@"Comment"];
        comment[@"comment"] = responseTextField.text;
        comment[@"author"] = [PFUser currentUser];
        if (challenge) {
            comment[@"challenge"] = challenge.object;
        } else {
            comment[@"challengeSolution"] = challengeSolution.object;
        }

        [comment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                NSLog(@"error: %@", error);
                [self hideIndeterminateProgress];
            } else {
                
                if (challenge) {
                    challenge.commentsCount++;
                } else {
                    challengeSolution.commentsCount++;
                }
                
                responseTextField.text = @"";
                [responseTextField resignFirstResponder];
                
                NSMutableArray *array = [[NSMutableArray alloc] init];
                [array addObject:[[Comment alloc] initWithPFObject:comment]];
                [array addObjectsFromArray:commentsArray];
                commentsArray = [NSArray arrayWithArray:array];
                [commentsTableView reloadData];
                [self hideIndeterminateProgress];
            }
        }];
    }
}

#pragma mark UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Comment *comment = [commentsArray objectAtIndex:indexPath.row];
    return [CommentTableViewCell heightForComment:comment cellWidth:screenWidth];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"commentCell";
    
    if (indexPath.row==commentsArray.count-1) {
        [self fetchData];
    }
    
    CommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (!cell) {
        cell = [[CommentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    Comment *comment = [commentsArray objectAtIndex:indexPath.row];
    [cell setComment:comment];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [responseTextField resignFirstResponder];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Comment *comment = [commentsArray objectAtIndex:indexPath.row];
    UserProfileViewController *vc = [[UserProfileViewController alloc] initWithPFUser:comment.author];
    [self.navigationController pushViewController:vc animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return commentsArray.count;
}

#pragma mark KEYBOARD NOTIFICATIONS

- (void) keyboardWillShow:(NSNotification *)note
{
    NSDictionary *keyboardAnimationDetail = [note userInfo];
    UIViewAnimationCurve animationCurve = [keyboardAnimationDetail[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    CGFloat duration = [keyboardAnimationDetail[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    NSValue* keyboardFrameBegin = [keyboardAnimationDetail valueForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    int keyboardHeight = (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication]statusBarOrientation])) ? keyboardFrameBeginRect.size.height : keyboardFrameBeginRect.size.width;

    [UIView animateWithDuration:duration delay:0.0 options:(animationCurve << 16) animations:^{
        commentsTableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-keyboardHeight);
        responseView.frame = CGRectMake(0, self.view.frame.size.height-40-keyboardHeight, self.view.frame.size.width, 40);
    } completion:^(BOOL finished) {
        [commentsTableView scrollRectToVisible:CGRectMake(0, commentsTableView.contentSize.height-1, 1, 1) animated:YES];
    }];
}

- (void) keyboardWillHide:(NSNotification *)note
{
    NSDictionary *keyboardAnimationDetail = [note userInfo];
    UIViewAnimationCurve animationCurve = [keyboardAnimationDetail[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    CGFloat duration = [keyboardAnimationDetail[UIKeyboardAnimationDurationUserInfoKey] floatValue];

    [UIView animateWithDuration:duration delay:0.0 options:(animationCurve << 16) animations:^{
        commentsTableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-40);
        responseView.frame = CGRectMake(0, CGRectGetMaxY(commentsTableView.frame)-49, self.view.frame.size.width, 40);
    } completion:^(BOOL finished) {
        [commentsTableView scrollRectToVisible:CGRectMake(0, commentsTableView.contentSize.height-1, 1, 1) animated:YES];
    }];
}

@end
