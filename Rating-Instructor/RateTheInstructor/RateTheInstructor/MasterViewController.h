//
//  MasterViewController.h
//  RateTheInstructor
//
//  Created by Soumya Sreekumar on 11/6/14.
//  Copyright (c) 2014 Soumya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MasterViewController : UITableViewController{
    
NSMutableData *receivedData;
NSMutableDictionary * idNameDict;
NSMutableArray *names;
    
}
@property UIView * activityIndicatorView;
@property UIActivityIndicatorView *activityIndicator;
@end

