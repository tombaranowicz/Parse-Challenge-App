//
//  CreateChallengeViewController.m
//  ChallengeApp
//
//  Created by Tomasz Baranowicz on 10/23/14.
//  Copyright (c) 2014 Direct Solutions. All rights reserved.
//

#import "CreateChallengeViewController.h"
#import "PlaceholderTextView.h"

@interface CreateChallengeViewController () <UIImagePickerControllerDelegate, UIActionSheetDelegate, UITextViewDelegate>
{
    UITextField *titleTextField;
    PlaceholderTextView *descriptionTextView;
}

@end

@implementation CreateChallengeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Challenge Creator";
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:scrollView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(publish)];
    
    //TITLE
    UIView *titleBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, self.view.frame.size.width-20, 30)];
    [scrollView addSubview:titleBackgroundView];
    [titleBackgroundView addShadow];
    
    titleTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, self.view.frame.size.width-20, 30)];
    titleTextField.textColor = [UIColor darkGrayColor];
    titleTextField.placeholder = @"Challenge title";
    titleTextField.backgroundColor = [UIColor whiteColor];
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    titleTextField.leftView = paddingView;
    titleTextField.leftViewMode = UITextFieldViewModeAlways;
    [scrollView addSubview:titleTextField];
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:titleTextField action:@selector(resignFirstResponder)];
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [toolbar setItems:[NSArray arrayWithObjects:flexibleSpace, barButton, nil]];
    titleTextField.inputAccessoryView = toolbar;
    
    //DESCRIPTION
    UIView *descriptionBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(titleTextField.frame)+15, self.view.frame.size.width-20, 100)];
    [scrollView addSubview:descriptionBackgroundView];
    [descriptionBackgroundView addShadow];
    
    descriptionTextView = [[PlaceholderTextView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(titleTextField.frame)+15, self.view.frame.size.width-20, 100)];
    descriptionTextView.placeholder = @"Challenge description";
    [scrollView addSubview:descriptionTextView];
    
    flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    barButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:descriptionTextView action:@selector(resignFirstResponder)];
    toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [toolbar setItems:[NSArray arrayWithObjects:flexibleSpace, barButton, nil]];
    descriptionTextView.inputAccessoryView = toolbar;
}

- (void) publish {
    if (titleTextField.text.length==0) {
        [self showAlertWithMessage:@"You probably forgot about title, please add it."];
        return;
    } else if (descriptionTextView.text.length==0) {
        [self showAlertWithMessage:@"Please describe challenge, let others know how to pass it."];
        return;
    }
    
    [self showIndeterminateProgressWithTitle:@"sending..."];
    
    PFObject *challenge = [PFObject objectWithClassName:@"Challenge"];
    challenge[@"name"] = titleTextField.text;
    challenge[@"description"] = descriptionTextView.text;
    challenge[@"author"] = [PFUser currentUser];
    
    [challenge saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
            [self showAlertWithMessage:@"Some problem occured, please check your internet connection."];
            [self hideIndeterminateProgress];
        } else {
    
            PFUser *currentUser = [PFUser currentUser];
            [currentUser incrementKey:@"challenges" byAmount:[NSNumber numberWithInt:1]];
            [currentUser saveInBackground];
            
            [self hideIndeterminateProgress];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}
@end
