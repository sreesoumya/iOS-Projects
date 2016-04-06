//
//  ThirdViewController.m
//  SamplerApp
//
//  Created by Soumya Sreekumar on 10/22/14.
//  Copyright (c) 2014 Soumya. All rights reserved.
//

#import "ThirdViewController.h"
@interface ThirdViewController ()

@property (weak, nonatomic) IBOutlet UISwitch *switchController;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segment;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (weak, nonatomic) IBOutlet UIButton *buttonAlert;
@end

@implementation ThirdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //make sure the view is clean on load.
    self.switchController.hidden = YES;
    self.activityIndicator.hidden = YES;
    self.textView.hidden = YES;
    self.buttonAlert.hidden = YES;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Handling activity indicator animation here.
- (IBAction)switchChanged:(id)sender {
    
    
    if(_switchController.isOn == YES){
        [self.activityIndicator startAnimating];
        
    }
    else if (_switchController.isOn == NO)
    {
        [self.activityIndicator stopAnimating];
    }

    
}

//Handling the Individual segments here.
- (IBAction)segmantControls:(id)sender {

    if([@"Progress"  isEqual: [_segment titleForSegmentAtIndex:_segment.selectedSegmentIndex]]){
        
        self.switchController.hidden = NO;
        self.activityIndicator.hidden = NO;
        self.textView.hidden = YES;
        self.buttonAlert.hidden = YES;
        
    }
    else if([@"Text"  isEqual: [_segment titleForSegmentAtIndex:_segment.selectedSegmentIndex]]) {
        
        self.textView.hidden = NO;
        [self.textView resignFirstResponder];
        self.switchController.hidden = YES;
        self.activityIndicator.hidden = YES;
        self.buttonAlert.hidden = YES;
    }
    else if([@"Alert"  isEqual: [_segment titleForSegmentAtIndex:_segment.selectedSegmentIndex]]){
        
        self.buttonAlert.hidden = NO;
        [self.textView resignFirstResponder];
        self.switchController.hidden = YES;
        self.activityIndicator.hidden = YES;
        self.textView.hidden = YES;
        
        
    }
    else{
        NSLog(@"Unexpected Segment number");
         @throw ([NSException exceptionWithName:@"Wrong Segment Index" reason:@"Error in Segment" userInfo:nil]);
    }
}

//Handling the keyboard hidding during touch
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

//Handling the keyboard hidding when return key is pressed
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

//Function for handling the Alert Button press (show Alert to user)
- (IBAction)buttonAlertPressed:(id)sender {
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Title" message:@"Do you like the iphone" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes",@"No", nil];
    [alert show];
}

@end
