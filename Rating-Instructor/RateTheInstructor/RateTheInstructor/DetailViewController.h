//
//  DetailViewController.h
//  RateTheInstructor
//
//  Created by Soumya Sreekumar on 11/6/14.
//  Copyright (c) 2014 Soumya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

//values rerceived from TtableView selection
@property (strong, nonatomic) id detailItemProfName;
@property (strong, nonatomic) id detailItemProfId;

//Lable and TextView to show the existing data
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property (weak, nonatomic) IBOutlet UITextView *detailInstructorCommentText;

//TextView,Rating and Slider to collect User Comment and Rating
@property (weak, nonatomic) IBOutlet UITextView *instructorCommentTextView;
@property (weak, nonatomic) IBOutlet UILabel *ratingLabel;
@property (weak, nonatomic) IBOutlet UISlider *slider;

//Local variables to be used for individual requests and other uses
@property UIView * activityIndicatorView;
@property UIActivityIndicatorView *activityIndicator;
@property NSURLRequest *urlRequestDetails;
@property NSURLRequest *urlRequestComments;
@property NSMutableURLRequest *submitRatingRequest;
@property NSMutableURLRequest *submitCommentRequest;

//Local storage of Instructor Deetailxsiing comments.
@property NSMutableData *instructorDetails;
@property NSMutableData *instructorComments;

//Local utility Functions
- (void) animateTextView: (UITextView*) textField up: (BOOL) up;
- (void)getConnectionForDetailsView:(NSURLRequest*)urlRequest :(NSMutableData *)dataReceived;
-(void)getInstructorDetails;
-(void)getInstructorComments;



//Actions from Submit buttons and slide move
- (IBAction)sliderMoved:(id)sender;
- (IBAction)rateSubmitButton:(id)sender;
- (IBAction)commentSubmitButton:(id)sender;

@end

