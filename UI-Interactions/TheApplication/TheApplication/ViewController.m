//
//  ViewController.m
//  TheApplication
//
//  Created by Soumya Sreekumar on 9/30/14.
//  Copyright (c) 2014 Soumya. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *inputText;
@property (weak, nonatomic) IBOutlet UITextField *inputX;
@property (weak, nonatomic) IBOutlet UITextField *inputY;
@property (weak, nonatomic) IBOutlet UILabel *movingLabel;

@end

@implementation ViewController

//ViewController is delegate for all textFileds.
//Process the pressing of return button to close the keypad
-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}


- (IBAction)updateButton:(id)sender {
    
    //Read contents from TextFields
    NSString *contents = [[self inputText] text];
    NSString *xStringValue = [[self inputX] text];
    NSString *yStringValue = [[self inputY]text];
    
    //Save it in  UserDefaults to use later in case the app is cloased.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    
    //Get the Float coordinates
    if ((![xStringValue  isEqual: @""]) && (![yStringValue  isEqual: @""])){
        CGFloat xValue = [xStringValue floatValue];
        CGFloat yValue = [yStringValue floatValue];
        
        //Set Values in Label
        [self.movingLabel setCenter:CGPointMake(xValue,yValue)];

        [defaults setObject:xStringValue forKey:@"xStringValue"];
        [defaults setObject:yStringValue forKey:@"yStringValue"];
    }
    
    [defaults setObject:contents forKey:@"contents"];
    [self.movingLabel setText:contents];
    [self.movingLabel sizeToFit];
    
    [defaults synchronize];
    
    
    //resigning first responder after clicking the update button
    [self.inputText resignFirstResponder];
    [self.inputX resignFirstResponder];
    [self.inputY resignFirstResponder];

}


//force giving up first responder when touch any where in the screen
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    [self.view endEditing:YES];

    //Move the Label to the location touched
    UITouch *atouch = [touches anyObject];
    CGPoint location = [atouch locationInView: self.view];
    [self.movingLabel setCenter:CGPointMake(location.x,location.y)];
    
    //update in the UserDefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSString stringWithFormat:@"%f",location.x] forKey:@"xStringValue"];
    [defaults setObject:[NSString stringWithFormat:@"%f",location.y] forKey:@"yStringValue"];
    NSLog(@"saved ::  x = %f y = %f",location.x,location.y);
    [defaults synchronize];
    
    //update the textFields with the new location
    [[self inputX]setText:[NSString stringWithFormat:@"%f",location.x]];
    [[self inputY]setText:[NSString stringWithFormat:@"%f",location.y]];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //restore the values as they were last available.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString * contents = [defaults objectForKey:@"contents"];
    NSString * xStringValue = [defaults objectForKey:@"xStringValue"];
    NSString * yStringValue = [defaults objectForKey:@"yStringValue"];
    
    if((contents != nil) && (xStringValue != nil) &&(yStringValue != nil)){
        //Restore Values in the textFields
        [self.inputText setText:contents];
        [self.inputX setText:xStringValue];
        [self.inputY setText:yStringValue];
    
        //Restore Values and position of Label
        CGFloat xValue = [xStringValue floatValue];
        CGFloat yValue = [yStringValue floatValue];
        [self.movingLabel setText:contents];
        [self.movingLabel sizeToFit];
        [self.movingLabel setCenter:CGPointMake(xValue,yValue)];
        NSLog(@"restored ::  x = %f y = %f",xValue,yValue);
       
    }
    
    NSLog(@" viewDidLoad ");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Required values already saved, application is ready to be terminated anytime.
}

@end
