//
//  ChallengeDetailsViewController.m
//  ChallengeApp
//
//  Created by Tomasz Baranowicz on 10/10/14.
//  Copyright (c) 2014 Direct Solutions. All rights reserved.
//

#import "ChallengeDetailsViewController.h"
#import "TakeTheChallengeViewController.h"
#import "CommentsViewController.h"
#import "LikesViewController.h"
#import "SolutionsViewController.h"

#import <FontAwesomeKit/FAKFontAwesome.h>
#import <NSDate+TimeAgo.h>
#import <DTAlertView/DTAlertView.h>

@interface ChallengeDetailsViewController () <DTAlertViewDelegate>
{
    Challenge *challenge;
    
    UILabel *titleLabel;
    UIImageView *imageView;
    UILabel *timeLabel;
    UILabel *commentsLabel;
    UILabel *likesLabel;
    UILabel *solutionsLabel;
    UILabel *descriptionLabel;
    
    UIButton *commentButton;
    UIButton *shareButton;
    UIButton *flagButton;
    UIButton *likeButton;
    UIButton *takeChallengeButton;
    UIButton *seeAttempsButton;
}
@end

@implementation ChallengeDetailsViewController

- (id) initWithChallenge:(Challenge *) challenge_
{
    self = [super init];
    if (self) {
        challenge = challenge_;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    scrollView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:scrollView];
    
    self.navigationItem.title = @"Challenge Details";
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectZero];
    bgView.backgroundColor = [UIColor whiteColor];
    [scrollView addSubview:bgView];
    
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, self.view.frame.size.width-20, 20)];
    titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    titleLabel.numberOfLines = 0;
    titleLabel.textColor = [UIColor darkGrayColor];
    titleLabel.text = challenge.title;
    [titleLabel sizeToFit];
    [scrollView addSubview:titleLabel];
    
    descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(titleLabel.frame)+10, screenWidth-20, 20)];
    descriptionLabel.text = challenge.details;
    descriptionLabel.font = [UIFont boldSystemFontOfSize:13.f];
    descriptionLabel.textColor = [UIColor darkGrayColor];
    descriptionLabel.numberOfLines = 0;
    [descriptionLabel sizeToFit];
    [scrollView addSubview:descriptionLabel];
    
    bgView.frame = CGRectMake(5, 5, self.view.frame.size.width-5, CGRectGetMaxY(descriptionLabel.frame)+5);
    
    //******************************************************
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(bgView.frame)+15, screenWidth-20, 60)];
    view.backgroundColor = [Utils themeColor];
    [scrollView addSubview:view];
    [view addShadow];
    
    commentsLabel = [[UILabel alloc] initWithFrame:CGRectMake(view.frame.size.width-105, 5, 100, 20)];
    commentsLabel.font = [UIFont boldSystemFontOfSize:15.0f];
    commentsLabel.textAlignment = NSTextAlignmentRight;
    commentsLabel.textColor = [UIColor whiteColor];
    FAKFontAwesome *icon = [FAKFontAwesome commentIconWithSize:15.0f];
    NSMutableAttributedString *muAtrStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@ ", [Utils abbreviateNumber:challenge.commentsCount]]];
    [muAtrStr appendAttributedString:[icon attributedString]];
    commentsLabel.attributedText = muAtrStr;
    [view addSubview:commentsLabel];
    
    solutionsLabel = [[UILabel alloc] initWithFrame:CGRectMake(view.frame.size.width-105, 35, 100, 20)];
    solutionsLabel.font = [UIFont boldSystemFontOfSize:15.0f];
    solutionsLabel.textAlignment = NSTextAlignmentRight;
    solutionsLabel.textColor = [UIColor whiteColor];
    icon = [FAKFontAwesome cameraIconWithSize:15.0f];
    muAtrStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@ ", [Utils abbreviateNumber:challenge.solutionsCount]]];
    [muAtrStr appendAttributedString:[icon attributedString]];
    solutionsLabel.attributedText = muAtrStr;
    [view addSubview:solutionsLabel];
    
    timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 150, 20)];
    timeLabel.font = [UIFont boldSystemFontOfSize:15.0f];
    timeLabel.textColor = [UIColor whiteColor];
    icon = [FAKFontAwesome clockOIconWithSize:15.0f];
    muAtrStr = [[NSMutableAttributedString alloc]initWithAttributedString:[icon attributedString]];
    [muAtrStr appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@", [challenge.createDate timeAgo]]]];
    timeLabel.attributedText = muAtrStr;
    [view addSubview:timeLabel];
    
    likesLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 35, 100, 20)];
    likesLabel.font = [UIFont boldSystemFontOfSize:15.0f];
    likesLabel.textColor = [UIColor whiteColor];
    icon = [FAKFontAwesome thumbsUpIconWithSize:15.0f];
    muAtrStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@ ", [Utils abbreviateNumber:challenge.likesCount]]];
    [muAtrStr appendAttributedString:[icon attributedString]];
    likesLabel.attributedText = muAtrStr;
    likesLabel.userInteractionEnabled = YES;
    [view addSubview:likesLabel];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(likesLabelHandler)];
    [likesLabel addGestureRecognizer:tap];
    
    //******************************************************
    
    bgView = [[UIView alloc] initWithFrame:CGRectZero];
    bgView.backgroundColor = [UIColor whiteColor];
    [scrollView addSubview:bgView];
    
    NSDictionary *titleAttributes = @{NSForegroundColorAttributeName:[Utils themeColor]};
    
    commentButton = [[UIButton alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(view.frame)+20, (screenWidth-50)/4, 30)];
    commentButton.titleLabel.font = [UIFont boldSystemFontOfSize:20.0f];
    [commentButton addTarget:self action:@selector(commentHandler) forControlEvents:UIControlEventTouchUpInside];
    icon = [FAKFontAwesome commentIconWithSize:25.0f];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithAttributedString:[icon attributedString]];
    [str addAttributes:titleAttributes range:NSMakeRange(0 , str.length)];
    [commentButton setAttributedTitle:str forState:UIControlStateNormal];
    [scrollView addSubview:commentButton];
    
    likeButton = [[UIButton alloc] initWithFrame:CGRectMake((screenWidth-50)/4+20, CGRectGetMaxY(view.frame)+20, (screenWidth-50)/4, 30)];
    
    icon = [FAKFontAwesome thumbsUpIconWithSize:25.0f];
    str = [[NSMutableAttributedString alloc] initWithAttributedString:[icon attributedString]];
    [str addAttributes:titleAttributes range:NSMakeRange(0 , str.length)];
    [likeButton setAttributedTitle:str forState:UIControlStateSelected];
    
    icon = [FAKFontAwesome thumbsOUpIconWithSize:25.0f];
    str = [[NSMutableAttributedString alloc] initWithAttributedString:[icon attributedString]];
    [str addAttributes:titleAttributes range:NSMakeRange(0 , str.length)];
    [likeButton setAttributedTitle:str forState:UIControlStateNormal];

    [likeButton addTarget:self action:@selector(likeHandler) forControlEvents:UIControlEventTouchUpInside];
    [likeButton setTitleColor:[Utils darkBlueColor] forState:UIControlStateNormal];
    likeButton.enabled = NO;
    [scrollView addSubview:likeButton];
    
    shareButton = [[UIButton alloc] initWithFrame:CGRectMake(2*(screenWidth-50)/4+30, CGRectGetMaxY(view.frame)+20, (screenWidth-50)/4, 30)];
    icon = [FAKFontAwesome shareAltIconWithSize:25.0f];
    str = [[NSMutableAttributedString alloc] initWithAttributedString:[icon attributedString]];
    [str addAttributes:titleAttributes range:NSMakeRange(0 , str.length)];
    [shareButton setAttributedTitle:str forState:UIControlStateNormal];
    [shareButton addTarget:self action:@selector(shareHandler) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:shareButton];
    
    flagButton = [[UIButton alloc] initWithFrame:CGRectMake(3*(screenWidth-50)/4+40, CGRectGetMaxY(view.frame)+20, (screenWidth-50)/4, 30)];
    icon = [FAKFontAwesome flagIconWithSize:25.0f];
    str = [[NSMutableAttributedString alloc] initWithAttributedString:[icon attributedString]];
    [str addAttributes:titleAttributes range:NSMakeRange(0 , str.length)];
    [flagButton setAttributedTitle:str forState:UIControlStateNormal];
    [flagButton addTarget:self action:@selector(flagHandler) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:flagButton];
    
    bgView.frame = CGRectMake(5, CGRectGetMaxY(view.frame)+17, self.view.frame.size.width-5, 40);

    takeChallengeButton = [[UIButton alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(bgView.frame)+15, self.view.frame.size.width-20, 40)];
    [takeChallengeButton setTitle:@"take the challenge!" forState:UIControlStateNormal];
    [takeChallengeButton addTarget:self action:@selector(takeTheChallenge) forControlEvents:UIControlEventTouchUpInside];
    [takeChallengeButton setBackgroundColor:[Utils greenColor]];
    [scrollView addSubview:takeChallengeButton];
    [takeChallengeButton addShadow];
    
    seeAttempsButton = [[UIButton alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(takeChallengeButton.frame)+15, self.view.frame.size.width-20, 40)];
    [seeAttempsButton setTitle:@"see attempts to this challenge!" forState:UIControlStateNormal];
    seeAttempsButton.titleLabel.font = [UIFont systemFontOfSize:17.0f];
    [seeAttempsButton addTarget:self action:@selector(seeAttempts) forControlEvents:UIControlEventTouchUpInside];
    [seeAttempsButton setBackgroundColor:[Utils greenColor]];
    [scrollView addSubview:seeAttempsButton];
    [seeAttempsButton addShadow];
    
    scrollView.contentSize = CGSizeMake(screenWidth, CGRectGetMaxY(seeAttempsButton.frame)+10);
    
    if (userLoggedIn) {
        if (challenge.like) {
            [likeButton setSelected:YES];
            likeButton.enabled = YES;
        } else {
            PFQuery *query = [PFQuery queryWithClassName:@"Like"];
            [query whereKey:@"challenge" equalTo:challenge.object];
            [query whereKey:@"author" equalTo:[PFUser currentUser]];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if(!error) {
                    likeButton.enabled = YES;
                    if (objects.count>0) {
                        [likeButton setSelected:YES];
                        challenge.like = [objects objectAtIndex:0];
                    }
                }
            }];
        }
    }
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    FAKFontAwesome *icon = [FAKFontAwesome commentIconWithSize:15.0f];
    NSMutableAttributedString *muAtrStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@ ", [Utils abbreviateNumber:challenge.commentsCount]]];
    [muAtrStr appendAttributedString:[icon attributedString]];
    commentsLabel.attributedText = muAtrStr;
    
    icon = [FAKFontAwesome cameraIconWithSize:15.0f];
    muAtrStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@ ", [Utils abbreviateNumber:challenge.solutionsCount]]];
    [muAtrStr appendAttributedString:[icon attributedString]];
    solutionsLabel.attributedText = muAtrStr;
}

- (void) seeAttempts {
    SolutionsViewController *vc = [[SolutionsViewController alloc] initForChallenge:challenge];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) shareHandler {
    
    NSString *challengeTitle = [NSString stringWithFormat:@"I like \"%@\" in Let's Challenge Me app. To play with me, download the app: http://www.letschallenge.me/", challenge.title];
    
    NSMutableArray *items = [NSMutableArray new];
    [items addObject:challengeTitle];
    
    NSArray *activityItems = [NSArray arrayWithArray:items];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    [self presentViewController:activityViewController animated:YES completion:^{}];
}

- (void) flagHandler {
    DTAlertView *alertView = [DTAlertView alertViewWithTitle:@"Report inappropriate challenge" message:@"Please enter reason" delegate:self cancelButtonTitle:@"cancel" positiveButtonTitle:@"report"];
    
    [alertView setTextFieldDidChangeBlock:^(DTAlertView *_alertView, NSString *text) {
        [_alertView setPositiveButtonEnable:(text.length > 0)];
    }];
    
    [alertView setAlertViewMode:DTAlertViewModeTextInput];
    [alertView setTintColor:[Utils themeColor]];
    [alertView setPositiveButtonEnable:NO];
    [alertView showForPasswordInputWithAnimation:DTAlertViewAnimationDefault];
}

- (void) likeHandler {
    if (userLoggedIn) {
        if (challenge.like) {
            //remove
            [challenge.like deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    challenge.like = nil;
                    challenge.likesCount--;
                    [likeButton setSelected:NO];
                    likesLabel.text = [NSString stringWithFormat:@"%ld likes", challenge.likesCount];
                }
            }];
        } else {
            PFObject *like = [PFObject objectWithClassName:@"Like"];
            like[@"author"] = [PFUser currentUser];
            like[@"challenge"] = challenge.object;
            
            [like saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error) {
                    NSLog(@"like error: %@", error);
                } else {
                    challenge.like = like;
                    challenge.likesCount++;
                    [likeButton setSelected:YES];
                    likesLabel.text = [NSString stringWithFormat:@"%ld likes", challenge.likesCount];
                }
            }];
            
        }
    }
}

- (void) commentHandler {
    CommentsViewController *vc = [[CommentsViewController alloc] initWithChallenge:challenge];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)takeTheChallenge {
    if (userLoggedIn) {
        TakeTheChallengeViewController *vc = [[TakeTheChallengeViewController alloc] initWithChallenge:challenge];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        [self showAlertWithMessage:@"Please sign in to continue"];
    }
}

- (void)likesLabelHandler {
    LikesViewController *vc = [[LikesViewController alloc] initWithChallenge:challenge];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - DTAlertView Delegate Methods

- (void)alertView:(DTAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.textField != nil) {
        if (buttonIndex == alertView.cancelButtonIndex) {
            [alertView dismiss];
            return;
        }
        
        if (alertView.textField.text.length>0) {
            PFObject *flagRequest = [PFObject objectWithClassName:@"FlagRequest"];
            if (userLoggedIn) {
                flagRequest[@"author"] = [PFUser currentUser];
            }
            flagRequest[@"challenge"] = challenge.object;
            flagRequest[@"reason"] = alertView.textField.text;
            [flagRequest saveInBackground];
            [alertView dismiss];
        }
        return;
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

@end
