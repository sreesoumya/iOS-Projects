//
//  DetailViewController.m
//  RateTheInstructor
//
//  Created by Soumya Sreekumar on 11/6/14.
//  Copyright (c) 2014 Soumya. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController (){
    NSMutableData *dataReceived;
    NSMutableDictionary *detailsDict ;
    NSMutableArray *detailsArray;
    
}

@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem {
    if (_detailItemProfName != newDetailItem) {
        _detailItemProfName = newDetailItem;
            
        // Update the view.
        [self configureView];
    }
}

- (void)configureView {
    // Update the user interface for the detail item.
    if (self.detailItemProfName) {
        self.detailDescriptionLabel.text = [NSString stringWithFormat:@"Fetching details of %@",self.detailItemProfName];
        self.title = self.detailItemProfName;
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureView];
    
    //Activity indicator being used only for oading comments as that is variable size data and could be big.
    //Activity Indicator stopped as soon as Instructor comments are loaded
    self.activityIndicator = [[UIActivityIndicatorView alloc]
                              initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.activityIndicator startAnimating];
    [self.activityIndicator setCenter:CGPointMake(150, 300)];
     self.activityIndicatorView = [[UIView alloc] initWithFrame:CGRectMake(0,0,300,300)];
    [self.activityIndicatorView addSubview:self.activityIndicator];
    [self.detailInstructorCommentText setHidden:YES];
    [self.view addSubview:self.activityIndicatorView];
    
    
    //Get Instructor Details
    [self getInstructorDetails];
    
    //Get Instructor Comments
    [self getInstructorComments];

}

//Get Instructor Comments
-(void)getInstructorComments{
    self.InstructorComments = [NSMutableData data];
    NSString * urlStringRequestComments = [NSString stringWithFormat:@"http://bismarck.sdsu.edu/rateme/comments/%@",self.detailItemProfId];
    self.urlRequestComments = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStringRequestComments]
                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                           timeoutInterval:60.0];
    
    [self getConnectionForDetailsView:self.urlRequestComments : self.instructorComments];
    
}


-(void)getConnectionForDetailsView:(NSURLRequest*) urlRequest :(NSMutableData *) dataReceived{
    
    NSURLConnection *theAsyncConnection = [[NSURLConnection alloc]initWithRequest:urlRequest delegate:self];
    if(theAsyncConnection){
        NSLog(@"Connection Successful");
    }else{
        NSLog(@"Connection Failed");
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Connection Failed" delegate:nil cancelButtonTitle:@"Exit" otherButtonTitles:nil, nil];
        [alert show];        
        
    }    
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"ConnectionDidReceiveRESPONSE");
    if([self.urlRequestDetails isEqual:[connection originalRequest]]){
        [self.instructorDetails setLength:0];
    }
    else if([self.urlRequestComments isEqual:[connection originalRequest]]){
        [self.instructorComments setLength:0];
        
    }else if([self.submitRatingRequest isEqual:[connection originalRequest]]){
        //Assuming positive response for now
        //Refresh Instructor Details
        NSLog(@"Response received for SubmitRatingRequest");
        [self getInstructorDetails];
        
    }else if([self.submitCommentRequest isEqual:[connection originalRequest]]){
        
        NSLog(@"Received Response for Submitted Comment ... Refreshing comments - respose = %@",[response description]);
        //Refresh Instructor Comments
        [self getInstructorComments];
        
    }
}

//Get Instructor Details
-(void)getInstructorDetails{
    
    self.InstructorDetails = [NSMutableData data];
    NSString * urlStringRequestDetails = [NSString stringWithFormat:@"http://bismarck.sdsu.edu/rateme/instructor/%@",self.detailItemProfId];
    self.urlRequestDetails = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStringRequestDetails] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    [self getConnectionForDetailsView:self.urlRequestDetails : self.instructorDetails ];
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
     if([self.urlRequestDetails isEqual:[connection originalRequest]]){
         [self.instructorDetails appendData:data];
     }
     else if([self.urlRequestComments isEqual:[connection originalRequest]]){
         [self.instructorComments appendData:data];
         
     }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    
    NSLog(@"Connection Failed here");
    //Stop the activity indicator,do not remove ,since showing failed condition
    [self.activityIndicator stopAnimating];		
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Connection Failed" delegate:nil cancelButtonTitle:@"Exit" otherButtonTitles:nil, nil];
    [alert show];
    
    }

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if([self.urlRequestDetails isEqual:[connection originalRequest]]){
        NSLog(@"connectionDidFinishLoading  - Instructor Details");
        NSDictionary *dictionaryData = [NSJSONSerialization JSONObjectWithData:self.instructorDetails options:0 error:nil];
        //NSLog(@"%@",[dictionaryData description]);
        NSDictionary *ratingObject = [dictionaryData objectForKey:@"rating"];
    
        NSString * detailsString = [NSString stringWithFormat:@" Email    : %@ \n Office   : %@ \n Phone  : %@ \n\n Avg Rating :   %@ \n Total number of Ratings : %@ ",
                                [dictionaryData objectForKey:@"email"],
                                [dictionaryData objectForKey:@"office"],
                                [dictionaryData objectForKey:@"phone"],
                                [ratingObject objectForKey:@"average"],
                                [ratingObject objectForKey:@"totalRatings"]];
        
        NSLog(@"Total Ratings = %@",[ratingObject objectForKey:@"totalRatings"]);
        [self.detailDescriptionLabel setText:detailsString];
        [self.detailDescriptionLabel reloadInputViews];
        
    }
    else if([self.urlRequestComments isEqual:[connection originalRequest]]){
        NSLog(@"connectionDidFinishLoading  - Instructor Comments");
        NSDictionary *dictionaryData = [NSJSONSerialization JSONObjectWithData:self.instructorComments options:0 error:nil];
        NSMutableString *commentsString = [NSMutableString stringWithFormat:@""];
        
        for(id element in dictionaryData){
            [commentsString appendString:[NSString stringWithFormat:@" %@ \t %@\n",
             [element objectForKey:@"date"],[element objectForKey:@"text"]]];
        }
        
        //Stop the activity indicator and hide it,unhide the textView
        [self.detailInstructorCommentText setHidden:NO];
        [self.activityIndicator stopAnimating];
        [self.activityIndicatorView setHidden:YES];
        
        //Now display Comments
        [self.detailInstructorCommentText setText:commentsString];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sliderMoved:(id)sender {
    if ([self.slider value] < 1) {
        [[self ratingLabel] setText:@""];
        
    }else{
        
        [[self ratingLabel] setText:[NSString stringWithFormat:@"%ld",lroundf([self.slider value])]];
    
    }
}

- (IBAction)rateSubmitButton:(id)sender {
    if([[self.ratingLabel text] isEqualToString:@""]){
        NSLog(@"Attempt to Submit EMPTY Rating");
        
    }else{
        NSLog(@"Attempt to Submit Rating of %@",[self.ratingLabel text]);
        self.submitRatingRequest = [[NSMutableURLRequest alloc] init];
        NSString * urlStringRating =[NSString stringWithFormat:@"%@/%@/%@",@"http://bismarck.sdsu.edu/rateme/rating",self.detailItemProfId,[self.ratingLabel text]];
        [self.submitRatingRequest setURL:[NSURL URLWithString:urlStringRating] ];
        [self.submitRatingRequest setHTTPMethod:@"POST"];
        [self.submitRatingRequest setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
        [self.submitRatingRequest setHTTPBody:nil];
        
        NSURLConnection *theAsyncConnection = [[NSURLConnection alloc]initWithRequest:self.submitRatingRequest delegate:self];
        if(theAsyncConnection){
            NSLog(@"Connection Successful");
        }else{
            NSLog(@"Connection Failed");
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Title" message:@"Connection Failed" delegate:nil cancelButtonTitle:@"Exit" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
}

- (IBAction)commentSubmitButton:(id)sender {
    if([[self.instructorCommentTextView text] isEqualToString:@""]){
        NSLog(@"Attempt to send EMPTY Comment");
    }
    else{
        NSMutableString * commentString = [NSMutableString stringWithFormat:@"%@",[self.instructorCommentTextView text]];
    
    
        self.submitCommentRequest = [[NSMutableURLRequest alloc] init];
        NSString * urlStringComment =[NSString stringWithFormat:@"%@/%@",@"http://bismarck.sdsu.edu/rateme/comment",self.detailItemProfId];
        [self.submitCommentRequest setURL:[NSURL URLWithString:urlStringComment] ];
        [self.submitCommentRequest setHTTPMethod:@"POST"];
        [self.submitCommentRequest setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
        [self.submitCommentRequest setHTTPBody:[commentString dataUsingEncoding:NSUTF8StringEncoding]];
    
    
        NSURLConnection *theAsyncConnection = [[NSURLConnection alloc]initWithRequest:self.submitCommentRequest delegate:self];
        if(theAsyncConnection){
            NSLog(@"Connection Successful");
        }else{
            NSLog(@"Connection Failed");
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Connection Failed" delegate:nil cancelButtonTitle:@"Exit" otherButtonTitles:nil, nil];
            [alert show];
        
        }
        [self.instructorCommentTextView setText:@""];
        [self.instructorCommentTextView resignFirstResponder];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
     [self.instructorCommentTextView resignFirstResponder];
}

-(BOOL) textViewShouldBeginEditing:(UITextView *)textView{
    [self animateTextView: textView up:YES];
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    [textView resignFirstResponder];
    [self animateTextView:textView up:NO];
    return YES;
}


- (void) animateTextView: (UITextView*) textField up: (BOOL) up
{
    const int movementDistance = 250;
    const float movementDuration = 0.3f;
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}


@end
