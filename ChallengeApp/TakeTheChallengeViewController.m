//
//  TakeTheChallengeViewController.m
//  ChallengeApp
//
//  Created by Tomasz Baranowicz on 10/14/14.
//  Copyright (c) 2014 Direct Solutions. All rights reserved.
//

#import "TakeTheChallengeViewController.h"
#import "PlaceholderTextView.h"
#import <FontAwesomeKit/FAKFontAwesome.h>
#import "AddNominationViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

// Degrees to radians
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

@interface TakeTheChallengeViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, UITextViewDelegate>
{
    Challenge *challenge;
    UILabel *titleLabel;
    UILabel *catchLabel;
    
    UIImage *solutionImage;
    UIImageView *solutionView;
    UIImagePickerController *imagePicker;
    
    PlaceholderTextView *descriptionTextView;
    
    UIScrollView *scrollView;
    
    AddNominationViewController *nominationViewController;
    UIButton *nominationButton;
    
    NSURL *moviePath;
}

@property (strong, nonatomic) MPMoviePlayerController *videoController;
@end

@implementation TakeTheChallengeViewController

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
 
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:scrollView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(postHandler)];
    
    self.navigationItem.title = @"Show your attempt";
    
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, self.view.frame.size.width-20, 20)];
    titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    titleLabel.numberOfLines = 0;
    titleLabel.textColor = [UIColor darkGrayColor];
    titleLabel.text = challenge.title;
    [titleLabel sizeToFit];
    [scrollView addSubview:titleLabel];
    
    solutionView = [[UIImageView alloc] initWithFrame:CGRectMake((screenWidth-300)/2, CGRectGetMaxY(titleLabel.frame)+10, 300, 300)];
    solutionView.contentMode = UIViewContentModeScaleAspectFit;
    solutionView.backgroundColor = [UIColor whiteColor];
    solutionView.userInteractionEnabled = YES;
    catchLabel = [[UILabel alloc] initWithFrame:solutionView.bounds];
    catchLabel.textAlignment = NSTextAlignmentCenter;

    NSDictionary *titleAttributes = @{NSForegroundColorAttributeName:[Utils themeColor]};
    FAKFontAwesome *icon = [FAKFontAwesome cameraIconWithSize:100.0f];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithAttributedString:[icon attributedString]];
    [str addAttributes:titleAttributes range:NSMakeRange(0 , str.length)];
    catchLabel.attributedText = str;

    [solutionView addSubview:catchLabel];
    [scrollView addSubview:solutionView];
    [solutionView addShadow];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addSolution)];
    [solutionView addGestureRecognizer:tap];
    
    UIView *descriptionBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(solutionView.frame)+10, self.view.frame.size.width-20, 50)];
    [scrollView addSubview:descriptionBackgroundView];
    [descriptionBackgroundView addShadow];
    
    descriptionTextView = [[PlaceholderTextView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(solutionView.frame)+10, self.view.frame.size.width-20, 50)];
    descriptionTextView.delegate = self;
    descriptionTextView.placeholder = @"Comment...";
    descriptionTextView.placeholderColor = [UIColor darkGrayColor];
    [scrollView addSubview:descriptionTextView];

    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:descriptionTextView action:@selector(resignFirstResponder)];
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [toolbar setItems:[NSArray arrayWithObjects:flexibleSpace, barButton, nil]];
    descriptionTextView.inputAccessoryView = toolbar;
    
    nominationButton = [[UIButton alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(descriptionTextView.frame)+10, self.view.frame.size.width-20, 40)];
    [nominationButton setTitle:@"nominated 0 friends" forState:UIControlStateNormal];
    [nominationButton addTarget:self action:@selector(addNomination) forControlEvents:UIControlEventTouchUpInside];
    [nominationButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [nominationButton setBackgroundColor:[Utils greenColor]];
    [scrollView addSubview:nominationButton];
    [nominationButton addShadow];
    
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, CGRectGetMaxY(nominationButton.frame)+20);
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
    
    
    NSString *buttonTitle = [NSString stringWithFormat:@"nominated %d friends", nominationViewController.selectedUsers.count];
    if (nominationViewController.selectedUsers.count==1) {
        buttonTitle = @"nominated 1 friend";
    }
    [nominationButton setTitle:buttonTitle forState:UIControlStateNormal];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void) postHandler {
    if (solutionImage || moviePath) {

        [self showIndeterminateProgressWithTitle:@"sending..."];
        
        if (moviePath) {
            AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:moviePath options:nil];
            AVAssetImageGenerator *generate1 = [[AVAssetImageGenerator alloc] initWithAsset:asset];
            generate1.appliesPreferredTrackTransform = YES;
            NSError *err = NULL;
            CMTime time = CMTimeMake(1, 2);
            CGImageRef oneRef = [generate1 copyCGImageAtTime:time actualTime:NULL error:&err];
            solutionImage = [[UIImage alloc] initWithCGImage:oneRef];
        }
        
        NSData *imageData = UIImageJPEGRepresentation(solutionImage, 0.9f);
        
        PFFile *imageFile = [PFFile fileWithName:@"solutionimage.jpg" data:imageData];
        [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                if (moviePath) {
                    NSData *videoData = [NSData dataWithContentsOfURL:moviePath];
                    
                    PFFile *videoFile = [PFFile fileWithName:@"movie.mp4" data:videoData];
                    [videoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if (!error) {
                            [self submitWithImage:imageFile video:videoFile];
                        } else {
                            [self showAlertWithMessage:@"Some problem occured, please check your internet connection."];
                            DLOG(@"error while uploading: %@", error);
                            [self hideIndeterminateProgress];
                        }
                    }];
                } else {
                    [self submitWithImage:imageFile video:nil];
                }
            } else {
                [self showAlertWithMessage:@"Some problem occured, please check your internet connection."];
                DLOG(@"error while uploading: %@", error);
                [self hideIndeterminateProgress];
            }
        }];
    } else {
        [self showAlertWithMessage:@"Please add photo/movie to continue"];
    }
}

- (void) submitWithImage:(PFFile *)imageFile video:(PFFile *)videoFile {
    
    DLOG(@"uploaded solution image");
    
    PFObject *challengeSolution = [PFObject objectWithClassName:@"ChallengeSolution"];
    challengeSolution[@"challenge"] = challenge.object;
    challengeSolution[@"comment"] = descriptionTextView.text;
    challengeSolution[@"user"] = [PFUser currentUser];
    challengeSolution[@"image"] = imageFile;
    if (videoFile) {
        challengeSolution[@"movie"] = videoFile;
    }
    
    [challengeSolution saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
            [self showAlertWithMessage:@"Some problem occured, please check your internet connection."];
            [self hideIndeterminateProgress];
        } else {
            DLOG(@"added solution");
            [self hideIndeterminateProgress];
            challenge.solutionsCount++;
            
            for (PFUser *user in nominationViewController.selectedUsers) {
                PFObject *nomination = [PFObject objectWithClassName:@"Nomination"];
                nomination[@"from"] = [PFUser currentUser];
                nomination[@"to"] = user;
                nomination[@"challenge"] = challenge.object;
                [nomination saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (error) {
                        DLOG(@"error adding nomination %@", error);
                    } else {
                        DLOG(@"successfully added nomination");
                    }
                }];
            }
            
            PFUser *currentUser = [PFUser currentUser];
            [currentUser incrementKey:@"solutions" byAmount:[NSNumber numberWithInt:1]];
            [currentUser saveInBackground];
            
            PFObject *challengeObject = challenge.object;
            [challengeObject incrementKey:@"solutions" byAmount:[NSNumber numberWithInt:1]];
            [challengeObject saveInBackground];
            
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

- (void) addNomination
{
    if (!nominationViewController) {
        nominationViewController = [[AddNominationViewController alloc] init];
    }
    
    [self showModalViewController:nominationViewController];
}

- (void)addSolution
{
    if (self.videoController) {
        [self.videoController play];
        return;
    }
    
    NSString *other1 = @"take a photo";
    NSString *other2 = @"choose photo";
    NSString *other3 = @"record video";
    NSString *other4 = @"choose video";
    NSString *cancelTitle = @"cancel";
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:cancelTitle
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:other1, other2, other3, other4, nil];
    [actionSheet showInView:self.view];
}

# pragma mark UIActionSheetDelegate method
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    imagePicker = nil;
    imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    imagePicker.videoMaximumDuration = MAX_VIDEO_LENGTH;
    imagePicker.videoQuality = UIImagePickerControllerQualityTypeMedium;
    
    [self.videoController stop];
    
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
        case 2:
            if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
                imagePicker.sourceType=UIImagePickerControllerSourceTypeCamera;
                imagePicker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
                [self presentViewController:imagePicker animated:YES completion:NULL];
            }
            break;
        case 3:
            //select from library
            imagePicker.sourceType=UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            imagePicker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
            [self presentViewController:imagePicker animated:YES completion:NULL];
            break;
    }
}

#pragma UIImagePickerControllerDelegate methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    
    // Handle a movie capture
    if (CFStringCompare ((__bridge_retained CFStringRef)mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
        
        NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];

        NSData *data = [NSData dataWithContentsOfURL:videoURL];
        DLOG(@"VIDEO DATA SIZE %.2f",(float)data.length/1024.0f/1024.0f);
        
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
        CGSize size = [[[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] naturalSize];
        DLOG(@"video image size %@", NSStringFromCGSize(size));
        
        NSTimeInterval durationInSeconds = 0.0;
        if (asset) durationInSeconds = CMTimeGetSeconds(asset.duration);
        DLOG(@"movie length %f", durationInSeconds);

        if (size.width>640 || size.height>480) {
            [self showIndeterminateProgressWithTitle:@"processing video..."];
            [self cropVideoAtURL:videoURL toWidth:480 height:360 completion:^(NSURL *resultURL, NSError *error) {
                if (error) {
                    DLOG(@"crop error %@", error);
                    [self hideIndeterminateProgress];
                } else {
                    moviePath = resultURL;
                    
                    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:moviePath options:nil];
                    CGSize size = [[[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] naturalSize];
                    DLOG(@"video size after %@", NSStringFromCGSize(size));
                    
                    NSData *data = [NSData dataWithContentsOfURL:moviePath];
                    DLOG(@"VIDEO SIZE %.2f",(float)data.length/1024.0f/1024.0f);
                    
                    [self hideIndeterminateProgress];
                    solutionImage = nil;
                    [self refreshSolutionView];
                }
            }];
        } else if (durationInSeconds<MAX_VIDEO_LENGTH+1) {
            DLOG(@"will add movie");
            moviePath = videoURL;
            solutionImage = nil;
            [self refreshSolutionView];
        }
    } else {
        moviePath = nil;
        solutionImage = info[UIImagePickerControllerEditedImage];
        solutionImage = [self imageWithImage:solutionImage scaledToSize:[Utils defaultPhotoSize]];
        [self refreshSolutionView];
    }
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)cropVideoAtURL:(NSURL *)videoURL toWidth:(CGFloat)width height:(CGFloat)height completion:(void(^)(NSURL *resultURL, NSError *error))completionHander {
    
    /* asset */
    
    AVAsset *asset = [AVAsset assetWithURL:videoURL];
    
    AVAssetTrack *assetVideoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] lastObject];
    
    /* sizes/scales/offsets */
    
    CGSize originalSize = assetVideoTrack.naturalSize;
    
    CGFloat scale;
    
    if (originalSize.width < originalSize.height) {
        scale = width / originalSize.width;
    } else {
        scale = height / originalSize.height;
    }
    
    CGSize scaledSize = CGSizeMake(originalSize.width * scale, originalSize.height * scale);
    
    CGPoint topLeft = CGPointMake(width * .5 - scaledSize.width * .5, height  * .5 - scaledSize.height * .5);
    
    /* Layer instruction */
    
    AVMutableVideoCompositionLayerInstruction *layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:assetVideoTrack];
    
    CGAffineTransform orientationTransform = assetVideoTrack.preferredTransform;
    
    /* fix the orientation transform */
    
    if (orientationTransform.tx == originalSize.width || orientationTransform.tx == originalSize.height) {
        orientationTransform.tx = width;
    }
    
    if (orientationTransform.ty == originalSize.width || orientationTransform.ty == originalSize.height) {
        orientationTransform.ty = height;
    }
    
    /* -- */
    
    CGAffineTransform transform = CGAffineTransformConcat(CGAffineTransformConcat(CGAffineTransformMakeScale(scale, scale),  CGAffineTransformMakeTranslation(topLeft.x, topLeft.y)), orientationTransform);
    
    [layerInstruction setTransform:transform atTime:kCMTimeZero];
    
    /* Instruction */
    
    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    
    instruction.layerInstructions = @[layerInstruction];
    instruction.timeRange = assetVideoTrack.timeRange;
    
    /* Video composition */
    
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    
    videoComposition.renderSize = CGSizeMake(width, height);
    videoComposition.renderScale = 1.0;
    videoComposition.frameDuration = CMTimeMake(1, 30);
    
    videoComposition.instructions = @[instruction];
    
    /* Export */
    
    AVAssetExportSession *export = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetMediumQuality];
    
    export.videoComposition = videoComposition;
    export.outputURL = [NSURL fileURLWithPath:[[NSTemporaryDirectory() stringByAppendingPathComponent:[NSUUID new].UUIDString] stringByAppendingPathExtension:@"MOV"]];
    export.outputFileType = AVFileTypeQuickTimeMovie;
    export.shouldOptimizeForNetworkUse = YES;
    
    [export exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (export.status == AVAssetExportSessionStatusCompleted) {
                
                completionHander(export.outputURL, nil);
                
            } else {
                
                completionHander(nil, export.error);
                
            }
        });
    }];    
}

- (void) refreshSolutionView {
    [catchLabel removeFromSuperview];
    solutionView.image = nil;
    [self.videoController stop];
    self.videoController = nil;
    [self.videoController.view removeFromSuperview];
    
    if (solutionImage) { //it's image
        solutionView.image = solutionImage;
    } else { //it's video
        
        self.videoController = [[MPMoviePlayerController alloc] init];
        [self.videoController setContentURL:moviePath];
        [self.videoController.view setFrame:solutionView.bounds];
        self.videoController.view.clipsToBounds = YES;
        self.videoController.controlStyle = MPMovieControlStyleEmbedded;
        [solutionView addSubview:self.videoController.view];
    }
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
        scrollView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-keyboardHeight);
    } completion:^(BOOL finished) {
        [scrollView scrollRectToVisible:descriptionTextView.frame animated:YES];
    }];
}

- (void) keyboardWillHide:(NSNotification *)note
{
    NSDictionary *keyboardAnimationDetail = [note userInfo];
    UIViewAnimationCurve animationCurve = [keyboardAnimationDetail[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    CGFloat duration = [keyboardAnimationDetail[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    [UIView animateWithDuration:duration delay:0.0 options:(animationCurve << 16) animations:^{
        scrollView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    } completion:^(BOOL finished) {
    }];
}

@end
