//
//  ChallengeSolutionTableViewCell.m
//  ChallengeApp
//
//  Created by Tomasz Baranowicz on 10/27/14.
//  Copyright (c) 2014 Direct Solutions. All rights reserved.
//

#import "ChallengeSolutionTableViewCell.h"
#import <UIImageView+AFNetworking.h>
#import <NSDate+TimeAgo.h>
#import <FontAwesomeKit/FontAwesomeKit.h>
#import "UIView+Custom.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <DTAlertView/DTAlertView.h>

@interface ChallengeSolutionTableViewCell() <DTAlertViewDelegate>
{
    ChallengeSolution *solution;
    
    UILabel *challengeLabel;
    
    UILabel *userNameLabel;
    PFImageView *userImageView;
    
    UIImageView *imageView;
    
    UILabel *timeLabel;
    UILabel *commentsLabel;
    UILabel *likesLabel;
    UILabel *descriptionLabel;
    
    UIButton *commentButton;
    UIButton *shareButton;
    UIButton *flagButton;
    UIButton *likeButton;
    UILabel *playLabel;
    UIActivityIndicatorView *spinner;
    
}
@property (strong, nonatomic) MPMoviePlayerController *videoController;

@end

@implementation ChallengeSolutionTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        
        challengeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, screenWidth-20, 17)];
        challengeLabel.textColor = [UIColor darkGrayColor];
        challengeLabel.font = [UIFont boldSystemFontOfSize:15.0f];
        [self.contentView addSubview:challengeLabel];
        challengeLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(challengeHandler)];
        [challengeLabel addGestureRecognizer:tap];
        
        UIView *bgImageView = [[UIView alloc] initWithFrame:CGRectMake((screenWidth-300)/2, 35, 300, 300)];
        [self.contentView addSubview:bgImageView];
        [bgImageView addShadow];
        
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake((screenWidth-300)/2, 35, 300, 300)];
        imageView.backgroundColor = [UIColor whiteColor];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [self.contentView addSubview:imageView];
        
        userImageView = [[PFImageView alloc] initWithFrame:CGRectMake(10, 340, 40, 40)];
        userImageView.contentMode = UIViewContentModeScaleAspectFill;
        userImageView.clipsToBounds = YES;
        userImageView.layer.cornerRadius = 20.f;
        userImageView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        userImageView.layer.borderWidth = 0.5f;
        [self.contentView addSubview:userImageView];
        userImageView.userInteractionEnabled = YES;
        tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userHandler)];
        [userImageView addGestureRecognizer:tap];
        
        userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 340, screenWidth-70, 14)];
        userNameLabel.textColor = [Utils themeColor];
        userNameLabel.font = [UIFont boldSystemFontOfSize:13.0f];
        [self.contentView addSubview:userNameLabel];
        
        descriptionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        descriptionLabel.numberOfLines = 0;
        descriptionLabel.font = [UIFont boldSystemFontOfSize:12.0f];
        descriptionLabel.textColor = [UIColor grayColor];
        [self.contentView addSubview:descriptionLabel];

        commentsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        commentsLabel.font = [UIFont boldSystemFontOfSize:11.0f];
        commentsLabel.textColor = [UIColor grayColor];
        [self.contentView addSubview:commentsLabel];
        
        likesLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        likesLabel.font = [UIFont boldSystemFontOfSize:11.0f];
        likesLabel.textColor = [UIColor grayColor];
        [self.contentView addSubview:likesLabel];
        
        timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        timeLabel.font = [UIFont boldSystemFontOfSize:11.0f];
        timeLabel.textColor = [UIColor grayColor];
        timeLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:timeLabel];
        
        NSDictionary *titleAttributes = @{NSForegroundColorAttributeName:[Utils themeColor]};
        
        commentButton = [[UIButton alloc] initWithFrame:CGRectZero];
        commentButton.titleLabel.font = [UIFont boldSystemFontOfSize:20.0f];
        [commentButton addTarget:self action:@selector(commentHandler) forControlEvents:UIControlEventTouchUpInside];
        FAKFontAwesome *icon = [FAKFontAwesome commentIconWithSize:25.0f];
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithAttributedString:[icon attributedString]];
        [str addAttributes:titleAttributes range:NSMakeRange(0 , str.length)];
        [commentButton setAttributedTitle:str forState:UIControlStateNormal];
        [self.contentView addSubview:commentButton];
        
        likeButton = [[UIButton alloc] initWithFrame:CGRectZero];
        
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
        [self.contentView addSubview:likeButton];
        
        shareButton = [[UIButton alloc] initWithFrame:CGRectZero];
        icon = [FAKFontAwesome shareAltIconWithSize:25.0f];
        str = [[NSMutableAttributedString alloc] initWithAttributedString:[icon attributedString]];
        [str addAttributes:titleAttributes range:NSMakeRange(0 , str.length)];
        [shareButton setAttributedTitle:str forState:UIControlStateNormal];
        [shareButton addTarget:self action:@selector(shareHandler) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:shareButton];
        
        flagButton = [[UIButton alloc] initWithFrame:CGRectZero];
        icon = [FAKFontAwesome flagIconWithSize:25.0f];
        str = [[NSMutableAttributedString alloc] initWithAttributedString:[icon attributedString]];
        [str addAttributes:titleAttributes range:NSMakeRange(0 , str.length)];
        [flagButton setAttributedTitle:str forState:UIControlStateNormal];
        [flagButton addTarget:self action:@selector(flagHandler) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:flagButton];
    }
    
    return self;
}

- (void) updateWithChallengeSolution:(ChallengeSolution *)challengeSolution
{
    solution = challengeSolution;
    
    [self.videoController.view removeFromSuperview];
    [self.videoController stop];
    self.videoController = nil;
    
    userNameLabel.text = nil;
    
    FAKFontAwesome *userIcon = [FAKFontAwesome userIconWithSize:30.0f];
    [userIcon addAttribute:NSForegroundColorAttributeName value:[Utils themeColor]];
    userImageView.image = [userIcon imageWithSize:CGSizeMake(40, 40)];
    
    imageView.image = nil;

    [spinner removeFromSuperview];
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = imageView.center;
    [spinner startAnimating];
    [self.contentView addSubview:spinner];
    
    [playLabel removeFromSuperview];
    challengeLabel.text = nil;
    
    if (challengeSolution.imageFile) {
        DLOG(@"will download file: %@", challengeSolution.imageFile.url);
        
        [challengeSolution.imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                UIImage *image = [UIImage imageWithData:data];
                imageView.image = image;
                solution.loadedImage = image;
                [spinner removeFromSuperview];
            }
        }];
    }
    
    if(challengeSolution.videoFile) {
        
        playLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, imageView.frame.size.width, imageView.frame.size.height)];
        imageView.userInteractionEnabled = YES;
        playLabel.userInteractionEnabled = YES;
        playLabel.textAlignment = NSTextAlignmentCenter;
        [imageView addSubview:playLabel];
        
        NSDictionary *titleAttributes = @{NSForegroundColorAttributeName:[Utils themeColor]};
        FAKFontAwesome *icon = [FAKFontAwesome playCircleOIconWithSize:100.0f];
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithAttributedString:[icon attributedString]];
        [str addAttributes:titleAttributes range:NSMakeRange(0 , str.length)];
        playLabel.attributedText = str;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playHandler)];
        [playLabel addGestureRecognizer:tap];
    }
    
    PFQuery *query = [PFUser query];
    query.cachePolicy = kPFCachePolicyCacheElseNetwork;
    query.maxCacheAge = 60*60;
    [query whereKey:@"objectId" equalTo:challengeSolution.author.objectId];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        userNameLabel.text = object[@"username"];
        userImageView.file = object[@"profileImageThumb"];
        [userImageView loadInBackground];
    }];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    descriptionLabel.frame = CGRectMake(60, 360, screenWidth-70, 40);
    descriptionLabel.text = challengeSolution.comment;
    if (challengeSolution.comment.length==0) {
        descriptionLabel.text = @" ";
    }
    [descriptionLabel sizeToFit];
    
    commentsLabel.frame = CGRectMake(10, CGRectGetMaxY(descriptionLabel.frame)+10, 90, 18);
    likesLabel.frame = CGRectMake(110, CGRectGetMinY(commentsLabel.frame), 90, 18);
    timeLabel.frame = CGRectMake(210, CGRectGetMinY(commentsLabel.frame), screenWidth-220, 18);
    
    commentButton.frame = CGRectMake(10, CGRectGetMaxY(descriptionLabel.frame)+30, (screenWidth-50)/4, 30);
    likeButton.frame = CGRectMake((screenWidth-50)/4+20, CGRectGetMinY(commentButton.frame), (screenWidth-50)/4, 30);
    shareButton.frame = CGRectMake(2*(screenWidth-50)/4+30, CGRectGetMinY(commentButton.frame), (screenWidth-50)/4, 30);
    flagButton.frame = CGRectMake(3*(screenWidth-50)/4+40, CGRectGetMinY(commentButton.frame), (screenWidth-50)/4, 30);
    
    commentsLabel.text = [NSString stringWithFormat:@"%@ comments", [Utils abbreviateNumber:challengeSolution.commentsCount]];
    likesLabel.text = [NSString stringWithFormat:@"%@ likes", [Utils abbreviateNumber:challengeSolution.likesCount]];
    
    FAKFontAwesome *icon = [FAKFontAwesome clockOIconWithSize:12.0f];
    NSMutableAttributedString *muAtrStr = [[NSMutableAttributedString alloc]initWithAttributedString:[icon attributedString]];
    [muAtrStr appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@", [challengeSolution.createDate timeAgo]]]];
    timeLabel.attributedText = muAtrStr;
    
    //update like!
    [likeButton setSelected:NO];
    likeButton.enabled = NO;
    
    if ([PFUser currentUser]) {
        if (solution.like) {
            [likeButton setSelected:YES];
            likeButton.enabled = YES;
        } else {
            //look for
            PFQuery *query = [PFQuery queryWithClassName:@"Like"];
            [query whereKey:@"challengeSolution" equalTo:solution.object];
            [query whereKey:@"author" equalTo:[PFUser currentUser]];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if(!error) {
                    likeButton.enabled = YES;
                    if (objects.count>0) {
                        [likeButton setSelected:YES];
                        solution.like = [objects objectAtIndex:0];
                    }
                }
            }];
        }
    }
    
    PFObject *obj = solution.object[@"challenge"];
    query = [PFQuery queryWithClassName:@"Challenge"];
    [query whereKey:@"objectId" equalTo:obj.objectId];
    query.cachePolicy = kPFCachePolicyCacheElseNetwork;
    query.maxCacheAge = 60*60;
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        solution.challenge = [[Challenge alloc] initWithPFObject:object];
        challengeLabel.text = object[@"name"];
    }];
}

- (void) commentHandler {
    [self.cellDelegate commentButtonTappedForSolution:solution];
}

- (void) likeHandler {
    if ([PFUser currentUser]) {
        if (solution.like) {
            //remove
            [solution.like deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    solution.like = nil;
                    solution.likesCount--;
                    [likeButton setSelected:NO];
                    likesLabel.text = [NSString stringWithFormat:@"%ld likes", solution.likesCount];
                }
            }];
        } else {
            PFObject *like = [PFObject objectWithClassName:@"Like"];
            like[@"author"] = [PFUser currentUser];
            like[@"challengeSolution"] = solution.object;
            
            [like saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error) {
                    NSLog(@"like error: %@", error);
                } else {
                    solution.like = like;
                    solution.likesCount++;
                    [likeButton setSelected:YES];
                    likesLabel.text = [NSString stringWithFormat:@"%ld likes", solution.likesCount];
                }
            }];
        }
    }
}

- (void) challengeHandler {
    [self.cellDelegate challengeButtonTappedForSolution:solution];
}

- (void) userHandler {
    [self.cellDelegate userButtonTappedForSolution:solution];
}

- (void) shareHandler {
    [self.cellDelegate shareTappedForSolution:solution];
}

- (void) flagHandler {
    DTAlertView *alertView = [DTAlertView alertViewWithTitle:@"Report inappropriate post" message:@"Please enter reason" delegate:self cancelButtonTitle:@"cancel" positiveButtonTitle:@"report"];
    
    [alertView setTextFieldDidChangeBlock:^(DTAlertView *_alertView, NSString *text) {
        [_alertView setPositiveButtonEnable:(text.length > 0)];
    }];
    
    [alertView setAlertViewMode:DTAlertViewModeTextInput];
    [alertView setTintColor:[Utils themeColor]];
    [alertView setPositiveButtonEnable:NO];
    [alertView showForPasswordInputWithAnimation:DTAlertViewAnimationDefault];
}

- (void) playHandler {
    
    [playLabel removeFromSuperview];
    
    NSURL *videoURL = [NSURL URLWithString:solution.videoFile.url];
    self.videoController = [[MPMoviePlayerController alloc] init];
    [self.videoController setContentURL:videoURL];
    [self.videoController.view setFrame:imageView.frame];
    self.videoController.controlStyle = MPMovieControlStyleEmbedded;
    [self.contentView addSubview:self.videoController.view];
    [self.videoController play];
}

+ (float) heightForChallengeSolution:(ChallengeSolution *)challengeSolution {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    
    UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 365, screenWidth-70, 40)];
    descriptionLabel.numberOfLines = 0;
    descriptionLabel.font = [UIFont boldSystemFontOfSize:12.0f];
    descriptionLabel.text = challengeSolution.comment;
    if (challengeSolution.comment.length==0) {
        descriptionLabel.text = @" ";
    }
    [descriptionLabel sizeToFit];
    
    return descriptionLabel.frame.size.height + 365 + 70;
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
            flagRequest[@"author"] = [PFUser currentUser];
            flagRequest[@"challengeSolution"] = solution.object;
            flagRequest[@"reason"] = alertView.textField.text;
            [flagRequest saveInBackground];
            [alertView dismiss];
        }
        return;
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

@end