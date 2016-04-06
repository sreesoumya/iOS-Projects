//
//  ViewController.m
//  FinalProjectStart
//
//  Created by Soumya Sreekumar on 11/24/14.
//  Copyright (c) 2014 Soumya. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController


/*********************************************************************************
Main Flow of the code starts with connectionDidFinishLoading 
which calls the following 3 main functions

 -(void)connectionDidFinishLoading:(NSURLConnection *)connection

    [self handleParkingInfoData];
    [self handleParkingStatusData];
    [self handleParkingGeoData];
*********************************************************************************/

//(Code Indentation using X-Code's structure->Re-Indent)

    - (void)viewDidLoad {
        [super viewDidLoad];
    
        //initializations.
        self.parkingDecals            = [[NSMutableArray alloc] init];
        self.associatedParkingLots   = [[NSMutableArray alloc] init];
        self.parkingDecalDescription  = [[NSMutableArray alloc]init];
        self.parkingLotGeoInfoArray   = [[NSMutableArray alloc] init];
        self.enteringActivityArray    = [[NSMutableArray alloc]init];
        self.exitActivityArray        = [[NSMutableArray alloc]init];
        self.LotEnteringDateTime      = nil;
        self.enteringMotionType       = UNKNOWN;
        self.exitMotionType           = UNKNOWN;
        self.updateParkingLotStatus   = NO;
    

        //Checking for Permissions and Resource Availability
        if([CMMotionActivityManager isActivityAvailable]){
        
            NSLog(@"Motion Data is AVAILABLE");
        }else{
            NSLog(@"Motion Data is UNAVAILABLE");
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"ERROR" message:@"Motion Activity Not Availabe on this Device!! Automatic Updating of Parking info to database will not work." delegate:nil
                                                cancelButtonTitle:@"Back" otherButtonTitles:nil, nil];
            [alert show];
        }
    
        if([self CanDeviceSupportAppBackgroundRefresh]){
            NSLog(@"Device can support AppBackgroundRefresh");
        }else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"ERROR" message:@"Turn ON APP Background Refresh in Settings and restart the APP for this APP to work properly. " delegate:nil
                                                cancelButtonTitle:@"Back" otherButtonTitles:nil, nil];
            [alert show];
        }
        // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [self.locationManager requestAlwaysAuthorization];
        }
    
    
        //setup Location Manager properties
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.delegate = self;
        
        //Start App by getting parking lot Info
        [self.activityIndicator startAnimating];
        [self getParkingLotInfo];

    }



    -(BOOL)CanDeviceSupportAppBackgroundRefresh
    {
        // Override point for customization after application launch.
        if ([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusAvailable) {
            NSLog(@"Background updates are available for the app.");
            return YES;
        }else if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusDenied)
        {
            NSLog(@"The user explicitly disabled background behavior for this app or for the whole system.");
            return NO;
        }else if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusRestricted){
            
            NSLog(@"Background updates are unavailable and the user cannot enable them again.");
            return NO;
        }
        else{
            return NO;
        }
    }


    - (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
    {
        if (![CLLocationManager locationServicesEnabled]) {
            NSLog(@"Couldn't turn on ranging: Location services are not enabled.");
        }
    
        if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways) {
            NSLog(@"Couldn't turn on monitoring: Location services not authorised.");
        }
    
    }

    -(void) getParkingLotInfo{
        self.parkingLotInfo = [NSMutableData data];
    
        NSString * urlStringRequestparkingLotInfo = [NSString stringWithFormat:@"http://smy.iriscouch.com/parking/parkinglotinfo"];
        self.urlRequestParkingLotInfo = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStringRequestparkingLotInfo]
                                                     cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                 timeoutInterval:60.0];
    
        NSURLConnection *theAsyncConnection = [[NSURLConnection alloc]initWithRequest:self.urlRequestParkingLotInfo delegate:self];
        if(theAsyncConnection){
            NSLog(@"Connection Successful");
        }else{
            NSLog(@"Connection Failed");
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Connection Failed" delegate:nil cancelButtonTitle:@"Exit" otherButtonTitles:nil, nil];
            [alert show];
        }
    }

    -(void)getParkingLotGeoInfo{
        self.parkingLotGeoInfo = [NSMutableData data];
    
        NSString * urlStringRequestparkingLotGeoInfo = [NSString stringWithFormat:@"http://smy.iriscouch.com/parking/ParkingLotGeoFenceInfo"];
        self.urlRequestParkingLotGeoInfo = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStringRequestparkingLotGeoInfo]
                                                        cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                    timeoutInterval:60.0];
    
        NSURLConnection *theAsyncConnection = [[NSURLConnection alloc]initWithRequest:self.urlRequestParkingLotGeoInfo delegate:self];
        if(theAsyncConnection){
            NSLog(@"Connection Successful");
        }else{
            NSLog(@"Connection Failed");
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Connection Failed" delegate:nil cancelButtonTitle:@"Exit" otherButtonTitles:nil, nil];
            [alert show];
        }
    }

    //Collect activities on entry/exit of region
    -(void)collectAndReportActivityDatainArray:(NSMutableArray *)activityArray forExit:(BOOL)didExitRegion{
        //Collect Data from 1 minute before and for upto 10 samples after now for entry.For exit just collect 10 samples after exit.
    
        NSLog(@"collectAndReportActivityDatainArray enter/exit %d",didExitRegion);
    
        self.motionActivityManager = [[CMMotionActivityManager alloc]init];
        
        NSTimeInterval seconds = 60;
        NSDate *now = [[NSDate alloc] initWithTimeIntervalSinceNow:0];
        NSDate *earlier = [[NSDate alloc]
                       initWithTimeIntervalSinceNow:-seconds];
    
        [self.motionActivityManager queryActivityStartingFromDate:earlier toDate:now toQueue:[NSOperationQueue mainQueue] withHandler:^(NSArray *activities, NSError *error){
        
                NSInteger activityCount;
        
                if(error){
                    NSLog(@"%@",error.debugDescription);
                    return;
                }else{
                    //if no error and if entred the region then store last 1 minute data.
                    //do not collect past data for region exit.will collect data for exit case below.
                    if(didExitRegion == NO){
                        for (CMMotionActivity *actItem in activities){
                            //store last 60 seconds of activity information
                            [activityArray addObject:actItem];
                        }
                    }
                }
                activityCount = [activityArray count];
                NSLog(@"1 minute activity count = %ld",(long)activityCount);
                //after collecting the items in the array start active monitoring for 10 more indications
                [self.motionActivityManager startActivityUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMMotionActivity *activity){
                if([activityArray count] < activityCount + 10){
                    //10 activities not received keep adding to array
                    //if 10 updates not received before this block gets called for exit then as per document updates are passed to the new block
                    // our assumption that there will be an exit followed by an entry makes sure we dont get stuck here for exit.
                    [activityArray addObject:activity];
                    NSLog(@"Adding activity to array :: %@",[activity description]);
                }else{
                    //10 activities collected, now stop active monitoring
                    [self.motionActivityManager stopActivityUpdates];
                    NSLog(@"Stopping activity Updates");
                    if(didExitRegion == YES){
                        NSLog(@"Call evaluate report");
                        [self evaluateAndReportStatus];
                    }
                }
            }];
        }];
    }

    //Usee the Arrays where activities are stored, evaluate entr/exit type and update the database
    -(void)evaluateAndReportStatus{
    
        self.enteringMotionType = [self evaluateMotionType:self.enteringActivityArray];
        NSLog(@" EVALUATED ENTRY TYPE = %@",(self.enteringMotionType ==0?@"WALKING":@"DRIVING"));
        self.exitMotionType   = [self evaluateMotionType:self.exitActivityArray];
        NSLog(@" EVALUATED EXIT TYPE = %@",(self.exitMotionType ==0?@"WALKING":@"DRIVING"));
        NSLog(@" entry type = %d, exit type = %d",self.enteringMotionType,self.exitMotionType);
        //after evaluating cleanup the entering and exit array
        [self.enteringActivityArray removeAllObjects];
        [self.exitActivityArray removeAllObjects];
        //update result to Database
        [self reportParkingStatususingEntryMotionType:self.enteringMotionType ExitMotionType:self.exitMotionType];
    }

    //Decide Activity based on the inputs in Array
    -(motionActivityType) evaluateMotionType:(NSMutableArray *)activityArray{
    
        NSInteger walkingCount = 0;
        NSInteger walkingConfidence =0;
        NSInteger runningCount = 0;
        NSInteger drivingCount = 0;
        NSInteger drivingConfidence =0;
        NSInteger actionItemCount = 0;
    
        //Evaluate Entry activity
        for (CMMotionActivity *actItem in activityArray){
        
            if (actItem.walking == 1){
                walkingCount++;
                walkingConfidence += actItem.confidence;
            }
            if (actItem.running == 1)
                runningCount++;
            if (actItem.automotive == 1){
                drivingCount++;
                drivingConfidence += actItem.confidence;
            }
            //ignore stationary
        
            actionItemCount++;
        }
    
        //not using confidence value for now maybe later update of algo will use it
        //based on experience with testing "automotive" is not reported very easily.
        //if reported it is safe to consider user as driving.
        if((actionItemCount != 0) && (drivingCount > 0)){
            return DRIVING;
        }
        if((actionItemCount !=0) && ((walkingCount >0) || (runningCount >0))){
        
            return WALKING;
        }
        //for now
        return UNKNOWN;
    
    }

    //updates the server based on entry and exit motion activity type
    //uses self.region to update to server : it needs to be set before calling this function
    -(void) reportParkingStatususingEntryMotionType:(motionActivityType)enteringMotionType ExitMotionType:(motionActivityType)exitMotionType{
    
        //other combinations left as is for now.
        if((enteringMotionType == UNKNOWN)  && (exitMotionType == DRIVING)){
            //for some reason we couldnt dertermine the way user entered the lot
            //set it as walking as if user exits driving we know there could be vacany spot.
            enteringMotionType = WALKING;
        }
    
        if ((enteringMotionType == DRIVING) && (exitMotionType == WALKING)) {
            //enter driving exit walking - Parked = YES
            [self updateParkingLotwithRegion:self.currentRegion andParked:YES isFull:NO];
        }
        else if((enteringMotionType == WALKING) && (exitMotionType == DRIVING)){
            //enter walking and exit driving - Parked = NO
            [self updateParkingLotwithRegion:self.currentRegion andParked:NO isFull:NO];
        }
        else if((enteringMotionType == WALKING) && (exitMotionType == WALKING)){
            //Leave the database not updated, based on our assumtion this could happen if
            //we fail to collect enterig and exiting motion activities, so better not to
            //update the DB at this point.
            NSLog(@"Entering Walking Exit Walking: not updating Database");
        }
        else if((enteringMotionType == DRIVING) && (exitMotionType == DRIVING)){
            //Entering Driving and exiting Driving, assume the lot is full
            [self updateParkingLotwithRegion:self.currentRegion andParked:NO isFull:YES];
        }else{
            //UNKNOWN activity type
            NSLog(@"Unexpected combination of motion activity types: not updating Database");
        }
    
        //reset the entering and exit activities to UNKNOWN;
        enteringMotionType = UNKNOWN;
        exitMotionType = UNKNOWN;
    
    }

    //Implements 3 algorithms   LOT_ENTRY_EXIT_COLLECT_IN_ARRAY_ALGO
    //                          LOT_ENTRY_EXIT_TWO_MINUTE_PRIOR_ALGO
    //                          LOT_ENTRY_EXIT_TIME_BASED_ALGO
    //Assumption: User will enter a rgion and exit the same region .
    //As of now since no two regions overlap we are assuming the exit is from the same region user entered before.

    - (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region{
        NSLog(@"didEnterRegion %@",region.description);
        [self.parkingLotStatusLabel setText:[NSString stringWithFormat:@"Entered Parking Lot : %@",region.identifier]];
    
#ifdef LOT_ENTRY_EXIT_COLLECT_IN_ARRAY_ALGO
        [self collectAndReportActivityDatainArray:self.enteringActivityArray forExit:NO];
#endif
    
#ifdef LOT_ENTRY_EXIT_TIME_BASED_ALGO
        self.LotEnteringDateTime = [[NSDate alloc] initWithTimeIntervalSinceNow:0];
#endif
    
    
#ifdef LOT_ENTRY_EXIT_TWO_MINUTE_PRIOR_ALGO
        self.motionActivityManager = nil;
        self.motionActivityManager = [[CMMotionActivityManager alloc]init];
    
        NSTimeInterval seconds = 2*60;
        NSDate *now = [[NSDate alloc] initWithTimeIntervalSinceNow:0];
        NSDate *earlier = [[NSDate alloc]
                       initWithTimeIntervalSinceNow:-seconds];
        NSLog(@"Collecting motionActivity Data for past 2 mins");
    
        [self.motionActivityManager queryActivityStartingFromDate:earlier toDate:now toQueue:[NSOperationQueue mainQueue] withHandler:^(NSArray *activities, NSError *error){
        if(error){
            
            NSLog(@"%@",error.debugDescription);
            return;
        }
        
        NSInteger walkingCount = 0;
        NSInteger walkingConfidence =0;
        NSInteger runningCount = 0;
        NSInteger drivingCount = 0;
        NSInteger drivingConfidence =0;
        NSInteger staticCount = 0;
        NSInteger actionItemCount = 0;
        
        for (CMMotionActivity *actItem in activities){
            
            if (actItem.walking == 1){
                walkingCount++;
                walkingConfidence += actItem.confidence;
            }
            if (actItem.running == 1)
                runningCount++;
            if (actItem.automotive == 1){
                drivingCount++;
                drivingConfidence += actItem.confidence;
            }
            if (actItem.stationary == 1)
                staticCount++;
            
            actionItemCount++;
            
            NSLog(@"actItem.description %@",actItem.description);
        }
        NSLog(@"Total Number of Items Received = %ld",(long)actionItemCount);
        
        
        //Entry Activity evaluation Logic
        //On entering reset the exit and entry to UNKNOWN.
        
        if((actionItemCount != 0) && (drivingCount == 0)){
            
            //if entring the parking lot walking
            self.enteringMotionType = WALKING;
        }
        else if((actionItemCount != 0)&& (walkingCount == 0) && (runningCount == 0) && (staticCount == 0)){
            //intentionally skipping staticCount as it may be non zero even if driving.
            //if entering the parking lot Driving
            self.enteringMotionType = DRIVING;
        }
        else{
            //other cases
            if((actionItemCount != 0) && (drivingCount !=0) && (walkingCount!=0)){
                
                // in case both walking and driving are indicated .. go for the one with higher confidence
                if(drivingConfidence > walkingConfidence){
                    self.enteringMotionType = DRIVING;
                }
                else{
                    self.enteringMotionType = WALKING;
                }
            }
            else{
                    //any other corner condition.. assume walking..
                    //(reason to assume walking: we consider
                    //driving IN to a parking lot and driving OUT => parking lot is full)
                    //if we are unsure it is safer to indicate a non full parking lot
                
                    //let the entering motion type remain UNKNOWN, it will be handled later
                    //placeholder for modification later
                }
            }
        
            if(self.enteringMotionType != UNKNOWN){
                //Debug Print
                [self.parkingLotStatusLabel setText:[NSString stringWithFormat:@" Entering: %@",
                                                 ((self.enteringMotionType == DRIVING)?@"DRIVING":@"WALKING")]];
            }else{
                [self.parkingLotStatusLabel setText:@"FAILED to Determine Entering Activity"];
            }
        
        }];
    
#endif //LOT_ENTRY_EXIT_TWO_MINUTE_PRIOR_ALGO
    }

    //Implements 3 algorithms   LOT_ENTRY_EXIT_COLLECT_IN_ARRAY_ALGO
    //                          LOT_ENTRY_EXIT_TWO_MINUTE_PRIOR_ALGO
    //                          LOT_ENTRY_EXIT_TIME_BASED_ALGO
    //Assumption: User will enter a rgion and exit the same region .
    //As of now since no two regions overlap we are assuming the exit is from the same region user entered before.

    - (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region{
    
        NSLog(@"didExitRegion %@",region.description);
        self.currentRegion = region;
    
        [self.parkingLotStatusLabel setText:[NSString stringWithFormat:@"Exit Parking Lot : %@",region.identifier]];
    
#ifdef LOT_ENTRY_EXIT_COLLECT_IN_ARRAY_ALGO
        [self collectAndReportActivityDatainArray:self.exitActivityArray forExit:YES];
#endif
    
#ifdef LOT_ENTRY_EXIT_TWO_MINUTE_PRIOR_ALGO
    
        self.motionActivityManager = nil;
        self.motionActivityManager = [[CMMotionActivityManager alloc]init];
    
        NSTimeInterval seconds = 2*60;
        NSDate *now = [[NSDate alloc] initWithTimeIntervalSinceNow:0];
        NSDate *earlier = [[NSDate alloc]
                       initWithTimeIntervalSinceNow:-seconds];
        NSLog(@"Collecting motionActivity Data for past 2 minutes");
    
        [self.motionActivityManager queryActivityStartingFromDate:earlier toDate:now toQueue:[NSOperationQueue mainQueue] withHandler:^(NSArray *activities, NSError *error){
        if(error){
            
            NSLog(@"%@",error.debugDescription);
            return;
        }
        
        NSInteger walkingCount = 0;
        NSInteger walkingConfidence =0;
        NSInteger runningCount = 0;
        NSInteger drivingCount = 0;
        NSInteger drivingConfidence =0;
        NSInteger staticCount = 0;
        NSInteger actionItemCount = 0;
        
        for (CMMotionActivity *actItem in activities){
            
            if (actItem.walking == 1){
                walkingCount++;
                walkingConfidence += actItem.confidence;
            }
            if (actItem.running == 1)
                runningCount++;
            if (actItem.automotive == 1){
                drivingCount++;
                drivingConfidence += actItem.confidence;
            }
            if (actItem.stationary == 1)
                staticCount++;
            
            actionItemCount++;
            
            NSLog(@"actItem.description %@",actItem.description);
        }
        NSLog(@"Total Number of Items Received = %ld",(long)actionItemCount);
        
        /*****Exiting and Reporting Logic (update and enhance as we go)***********/
        
        if(actionItemCount != 0){
            if(drivingCount == 0){
                // we have not been driving for the past 2 minutes
                self.exitMotionType = WALKING;
            }
            else if((walkingCount ==0) && (runningCount ==0 )){
                //we have been not been walking or running
                self.exitMotionType = DRIVING;
            }
            else if(((walkingCount != 0)|| (runningCount !=0 )) && (drivingCount !=0)){
                //activity indicates both walking and driving in the last 2 minutes
                //decide based on total confidence collected
                if(drivingConfidence > walkingConfidence){
                    self.exitMotionType = DRIVING;
                }else{
                    self.exitMotionType = WALKING;
                }
            }
            else{
                //some corner case assume walking out
                self.exitMotionType = WALKING;
            }
        }
        
#endif  //LOT_ENTRY_EXIT_TWO_MINUTE_PRIOR_ALGO
        
        
#ifdef LOT_ENTRY_EXIT_TIME_BASED_ALGO
        
        self.enteringMotionType =UNKNOWN;
        self.exitMotionType = UNKNOWN;
        self.motionActivityManager = nil;
        self.motionActivityManager = [[CMMotionActivityManager alloc]init];
        
        NSDate *now = [[NSDate alloc] initWithTimeIntervalSinceNow:0];
        NSDate *earlier = [[NSDate alloc] initWithTimeIntervalSinceNow:-60*60];
        
        NSLog(@"Collecting motionActivity Data for past 1 hr");
        
        [self.motionActivityManager queryActivityStartingFromDate:earlier toDate:now toQueue:[NSOperationQueue mainQueue] withHandler:^(NSArray *activities, NSError *error){
            
            
            if(error){
                
                NSLog(@"%@",error.debugDescription);
                return;
            }
            
            NSInteger actionItemCount = 0;
            if(self.LotEnteringDateTime == nil){
                //we didnt get a LotEntry time for some reason.
                //assume we entered 10 minutes before
                self.LotEnteringDateTime =[[NSDate alloc] initWithTimeIntervalSinceNow:-10*60];
            }
            NSLog(@"Lot entered at %@",[self.LotEnteringDateTime description]);
            for (CMMotionActivity *actItem in activities){
                  NSLog(@"activity %@",[actItem description]);
                if([actItem.startDate timeIntervalSinceDate:self.LotEnteringDateTime] >= 0){
                    //startDate is after entering the lot
                    if(actItem.automotive  ==1 ){
                        NSLog(@"activity after entry = DRIVING");
                        self.exitMotionType = DRIVING;
                    }else{
                        NSLog(@"activity after entry = WALKING");
                        self.exitMotionType = WALKING;
                    }
                    
                }else{
                    //activity is before entry time.
                    if( actItem.automotive ==1){
                        NSLog(@"activity before entry = DRIVING");
                        self.enteringMotionType = DRIVING;
                    }else if( (actItem.walking ==1) || (actItem.running == 1)){
                        NSLog(@"activity before entry (Walk/Run) = WALKING");
                        self.enteringMotionType  = WALKING;
                    }
                }
                
                actionItemCount++;
                
            }
            
            //we have determined entr/exit type now reset the lot entry time.
            self.LotEnteringDateTime = nil;
            
#endif //LOT_ENTRY_EXIT_TIME_BASED_ALGO
            
            
#if defined(LOT_ENTRY_EXIT_TIME_BASED_ALGO) || defined(LOT_ENTRY_EXIT_TWO_MINUTE_PRIOR_ALGO)
            
            /*
             [self.parkingLotStatusLabel setText:[NSString stringWithFormat:@"Enter:%@ ,EXIT:%@, COUNT:%lu",
             ((self.enteringMotionType == 0)?@"WALKING":@"DRIVING"),
             ((self.exitMotionType ==0)?@"WALKING":@"DRIVING"),
             actionItemCount] ];
             
             */
            //--------------based on entry and exit condition decide if park/leave or lot full---------//

            if((self.enteringMotionType == UNKNOWN) &&(self.exitMotionType == DRIVING)){
                //for some reason we couldnt dertermine the way user entered the lot
                //for now set it as walking since we are exiting DRIVING
                self.enteringMotionType = WALKING;
            }
            
            if ((self.enteringMotionType == DRIVING) && (self.exitMotionType == WALKING)) {
                //enter driving exit walking - Parked = YES
                [self updateParkingLotwithRegion:self.currentRegion andParked:YES isFull:NO];
            }
            else if((self.enteringMotionType == WALKING) && (self.exitMotionType == DRIVING)){
                //enter walking and exit driving - Parked = NO
                [self updateParkingLotwithRegion:self.currentRegion andParked:NO isFull:NO];
            }
            else if((self.enteringMotionType == WALKING) && (self.exitMotionType == WALKING)){
                //Leave the database not updated, based on our assumtion this could happen if
                //we fail to collect enterig and exiting motion activities, so better not to
                //update the DB at this point.
            }
            else if((self.enteringMotionType == DRIVING) && (self.exitMotionType == DRIVING)){
                //Entering Driving and exiting Driving, assume the lot is full
                [self updateParkingLotwithRegion:self.currentRegion andParked:NO isFull:YES];
            }
            
            //reset the entering and exit activities to UNKNOWN;
            self.enteringMotionType = UNKNOWN;
            self.exitMotionType = UNKNOWN;
            
        }];
        
#endif //LOT_ENTRY_EXIT_TWO_MINUTE_PRIOR_ALGO  || LOT_ENTRY_EXIT_TIME_BASED_ALGO
        
    }


     //updating the data in the server is a two step process
     // 1. Read(GET) the latest file(filename = region.identifier by design) and store the "_rev" value
     // 2. Update(PUT) the file using the revision and new values that need to be updated
     
     -(void) updateParkingLotwithRegion:(CLRegion*)currentRegion andParked:(BOOL)parked isFull:(BOOL)isFull{
         
         //Step1. we can reuse the GET parkinglot status method to read the parking lot file
         //store the "parked" and "isFull" values so they can be used to update the file
         //set a flag to TRUE so that when we get the response we know we need to hadle it to update(POST) the file.
         self.isParked = parked;
         self.isFull   = isFull;
         
         //this variable will be reset after data is received for the satus
         self.updateParkingLotStatus = YES;
         
         NSLog(@"update ParkingLotwithregion");
         [self getParkingLotStatusofParkingLotName:currentRegion.identifier];
     }
     

     - (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region
                                                    withError:(NSError *)error{
                                                        NSLog(@"Region:%@ Error:%@",region.identifier,error.description);
                                                    }


     - (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
         
         //Store the current GEOLocation for reference and stop location updates
         NSLog(@"location update received accuracy = %f",manager.location.horizontalAccuracy);
         if (manager.location.horizontalAccuracy <= 10.00) {
             self.currentGeoLocation = manager.location.coordinate;
             //we have all of the geo locations start monitoring them
             [self geofenceParkingLotsUsing:self.parkingLotGeoInfoArray];
             NSLog(@"current location = %@",[manager.location description]);
             [self.locationManager stopUpdatingLocation];
         }
     }



     - (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
         
         NSLog(@"ConnectionDidReceiveRESPONSE %@",response.description);
         if([self.urlRequestParkingLotInfo isEqual:[connection originalRequest]]){
             [self.parkingLotInfo setLength:0];
         }
         if([self.urlRequestParkingLotStatus isEqual:[connection originalRequest]]){
             [self.parkingLotStatus setLength:0];
         }
         if([self.urlRequestParkingLotGeoInfo isEqual:[connection originalRequest]]){
             [self.parkingLotGeoInfo setLength:0];
         }
         if([self.urlSubmitUpdateParkingLotStatusRequest isEqual:[connection originalRequest]]){
             [self.parkingLotStatusUpdateInfo setLength:0];
         }
         
     }

     - (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
         NSLog(@"connectiondDidReceiveData");
         if([self.urlRequestParkingLotInfo isEqual:[connection originalRequest]]){
             [self.parkingLotInfo appendData:data];
         }
         if([self.urlRequestParkingLotStatus isEqual:[connection originalRequest]]){
             [self.parkingLotStatus appendData:data];
         }
         if([self.urlRequestParkingLotGeoInfo isEqual:[connection originalRequest]]){
             [self.parkingLotGeoInfo appendData:data];
         }
         if([self.urlSubmitUpdateParkingLotStatusRequest isEqual:[connection originalRequest]]){
             NSLog(@"Status Update Response append data =%lu",(unsigned long)data.length);
             [self.parkingLotStatusUpdateInfo appendData:data];
         }
         
     }


     - (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
         
         NSLog(@"Connection Failed");
         UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Connection Failed" delegate:nil cancelButtonTitle:@"Exit" otherButtonTitles:nil, nil];
         [alert show];
         
     }

     -(void)connectionDidFinishLoading:(NSURLConnection *)connection{
         NSLog(@"connectionDidFinishLoading ");
         
         //Handle the ParkingInfo
         if([self.urlRequestParkingLotInfo isEqual:[connection originalRequest]]){
             [self handleParkingInfoData];
         }
         
         //Handle Parking status of the selected Parking Lot
         if([self.urlRequestParkingLotStatus isEqual:[connection originalRequest]]){
             [self handleParkingStatusData];
         }
         
         //Handle GeoData of Parking Lots (start monitoring them in background)
         if([self.urlRequestParkingLotGeoInfo isEqual:[connection originalRequest]]){
             
             [self handleParkingGeoData];
         }
         
         //Handle ParkingLotStatus Update Response to see everything is updated ok or if thre has been a conflict
         if([self.urlSubmitUpdateParkingLotStatusRequest isEqual:[connection originalRequest]]){
             NSDictionary *dictionaryData = [NSJSONSerialization JSONObjectWithData:self.parkingLotStatusUpdateInfo options:0 error:nil];
             NSLog(@" updateResponse :%@",[dictionaryData description]);
         }
         
         
     }
     

     //Send Request to GET parking lot status for a particular parking lot.
     -(void) getParkingLotStatusofParkingLotName:(NSString*)parkinglotName{
         
         self.parkingLotStatus = [NSMutableData data];
         
         NSString * urlStringRequestparkingLotStatus = [NSString stringWithFormat:@"http://smy.iriscouch.com/parking/%@",parkinglotName];
         self.urlRequestParkingLotStatus = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStringRequestparkingLotStatus]
                                                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                        timeoutInterval:60.0];
         
         NSURLConnection *theAsyncConnection = [[NSURLConnection alloc]initWithRequest:self.urlRequestParkingLotStatus delegate:self];
         if(theAsyncConnection){
             NSLog(@"Connection Successful");
         }else{
             NSLog(@"Connection Failed");
             UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Connection Failed" delegate:nil cancelButtonTitle:@"Exit" otherButtonTitles:nil, nil];
             [alert show];
         }
         
     }
     
     
     //Read Parking Lot Info from Database and populate the UI with information.
     -(void)handleParkingInfoData{
         NSDictionary *dictionaryData = [NSJSONSerialization JSONObjectWithData:self.parkingLotInfo options:0 error:nil];
         NSDictionary *decalData = [dictionaryData objectForKey:@"decals"];
         int i=0;
         for(id element in decalData){
             //NSLog(@" elment is %@",[element description]);
             self.parkingDecals[i] = [element objectForKey:@"decal_name"];
             self.associatedParkingLots[i] = [element objectForKey:@"lots_associated"];
             self.parkingDecalDescription[i] = [element objectForKey:@"decal_info"];
             i++;
         }
         
         NSLog(@"reloading all components of pickerView");
         [self.parkingLotPicker reloadAllComponents];
         [self.activityIndicator stopAnimating];
         //Now get the locations to monitor
         //Get Parking Lot Geo Info
         [self getParkingLotGeoInfo];
     }
     
     
     //Get Status of a particular Parking Lot. If updateParkingLotStatus is YES then update the Database else show result to user.
     -(void) handleParkingStatusData{
         
         
         //NSLog(@"%@",dictionaryData.description);
         
         if(self.updateParkingLotStatus == YES){
             NSLog(@"update parking lot status == YES");
             [self handleParkingStatusUpdate];
             
             self.updateParkingLotStatus = NO;
             
         }else{
             NSDictionary *dictionaryData = [NSJSONSerialization JSONObjectWithData:self.parkingLotStatus options:0 error:nil];
             //status read to dislay to user
             [self.activityIndicator stopAnimating];
             NSString *status = [NSString stringWithFormat:@"Is Parking Lot Full now : %@",
                                 [dictionaryData objectForKey:@"is_full"]];
             NSString *statusDetail = [NSString stringWithFormat:@"Last Updated : %@ \n total Size = %@ \n currently parked = %@ \n Is full now : %@",
                                       [dictionaryData objectForKey:@"date_time_last_updated"],
                                       [dictionaryData objectForKey:@"total_size"],
                                       [dictionaryData objectForKey:@"current_number"],
                                       [dictionaryData objectForKey:@"is_full"]  ];
             
             
             NSString *lotName = [dictionaryData objectForKey:@"_id"];
             for(CLCircularRegion *region in self.parkingLotGeoInfoArray){
                 if([region.identifier isEqualToString:lotName]){
                     self.gotoLocation = region.center;
                     self.gotoLocationName = region.identifier;
                     
                     break;
                 }
             }
             
             [self.parkingLotStatusLabel setText:status];
             
             UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Parking Lot Status" message:statusDetail delegate:self
                                                  cancelButtonTitle:@"Back" otherButtonTitles:@"Get Driving Drirections", nil];
             [alert show];
             
             
         }
     }
     
     
#pragma mark - Alert view delegate
     - (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:
     (NSInteger)buttonIndex{
         switch (buttonIndex) {
             case 0:
                 break;
             case 1:
             {
                 NSLog(@"OPENING MAP with destination LAT = %f, LONG = %f",self.gotoLocation.latitude,self.gotoLocation.longitude);
                 
                 
                 CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(self.gotoLocation.latitude,self.gotoLocation.longitude);
                 MKPlacemark* placeMark = [[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:nil];
                 MKMapItem* destination =  [[MKMapItem alloc] initWithPlacemark:placeMark];
                 destination.name = [NSString stringWithFormat:@"Parking Lot %@",self.gotoLocationName];
                 
                 if([destination respondsToSelector:@selector(openInMapsWithLaunchOptions:)]){
                     
                     //using iOS6 native maps app
                     [destination openInMapsWithLaunchOptions:@{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving}];
                 }
                 else
                 {
                     //using iOS 5 which has the Google Maps application
                     NSString* mapUrl = [NSString stringWithFormat: @"http://maps.google.com/maps?saddr=Current+Location&daddr=%f,%f",  self.gotoLocation.latitude, self.gotoLocation.longitude];
                     [[UIApplication sharedApplication] openURL: [NSURL URLWithString: mapUrl]];
                 }
             }
                 
                 break;
                 
             default:
                 break;
         }
     }
     
     //Update the status of Parking Lot to the database
     -(void)handleParkingStatusUpdate{
         
         NSDictionary *dictionaryData = [NSJSONSerialization JSONObjectWithData:self.parkingLotStatus options:0 error:nil];         //status read to update the file
         self.parkingLotStatusUpdateInfo = [NSMutableData data];
         
         NSMutableDictionary *updateLotStatus = [[NSMutableDictionary alloc]init];
         [updateLotStatus setObject:[dictionaryData objectForKey:@"_rev"] forKey:@"_rev"];
         [updateLotStatus setObject:[dictionaryData objectForKey:@"total_size"] forKey:@"total_size"];
         [updateLotStatus setObject:[dictionaryData objectForKey:@"_id"] forKey:@"_id"];
         
         NSDate *now = [[NSDate alloc] init];
         NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
         [dateFormat setDateStyle:NSDateFormatterShortStyle];
         [dateFormat setTimeStyle:NSDateFormatterShortStyle];
         [updateLotStatus setObject:[dateFormat stringFromDate:now] forKey:@"date_time_last_updated"];
         
         NSInteger currentParkedNumber = [[dictionaryData objectForKey:@"current_number"] integerValue];
         NSInteger maxParkingAvailable = [[dictionaryData objectForKey:@"total_size"] integerValue];
         
         if(self.isParked){
             currentParkedNumber++;
             if(currentParkedNumber > maxParkingAvailable)
                 currentParkedNumber = maxParkingAvailable;
         }else{
             currentParkedNumber--;
         }
         if((currentParkedNumber == maxParkingAvailable) || (self.isFull == YES)){
             currentParkedNumber = maxParkingAvailable;
             [updateLotStatus setObject:[NSString stringWithFormat:@"%ld",(long)currentParkedNumber] forKey:@"current_number"];
             [updateLotStatus setObject:@"YES" forKey:@"is_full"];
         }else{
             [updateLotStatus setObject:[NSString stringWithFormat:@"%ld",(long)currentParkedNumber] forKey:@"current_number"];
             [updateLotStatus setObject:@"NO" forKey:@"is_full"];               }
         
         
         NSString * serverPathtoUpdate = [NSString stringWithFormat:@"http://smy.iriscouch.com/parking/%@",self.currentRegion.identifier];
         [self postDataToServerPath:serverPathtoUpdate UsingObject:updateLotStatus];
         
         //reset the parking update variables
         self.isParked = NO;
         self.isFull = NO;
         self.currentRegion = NULL;
         
     }
     
     //read the GeoInfo from Database - only One time at startup.
     -(void)handleParkingGeoData{
         
         NSString *lot_name;
         CLLocationCoordinate2D centre;
         CLLocationDistance regionRadius;
         int i = 0;
         NSDictionary *dictionaryData = [NSJSONSerialization JSONObjectWithData:self.parkingLotGeoInfo options:0 error:nil];
         NSDictionary *lotGeoInfo = [dictionaryData objectForKey:@"Lots_geo_info"];
         for(id element in lotGeoInfo){
             centre.latitude = [[element objectForKey:@"lot_geo_lat"] floatValue];
             centre.longitude = [[element objectForKey:@"lot_geo_long"] floatValue];
             regionRadius = [[element objectForKey:@"lot_geo_radius"] floatValue];
             lot_name = [element objectForKey:@"lot_name"];
             CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:centre radius:regionRadius identifier:lot_name];
             self.parkingLotGeoInfoArray[i] = region;
             i++;
         }
         
         //start using GPS for gathering current geo location and then start monitoring for the geofences
         NSLog(@"Starting GPS to get current location, received number of regions = %lu",(unsigned long)[self.parkingLotGeoInfoArray count]);
         [self.locationManager startUpdatingLocation];
         
     }
     
     

     //Implements the PUT HTTP method to post data to database server
     -(void)postDataToServerPath:(NSString *)path UsingObject:(NSMutableDictionary *)object{
         
         NSError *error;
         NSData * updateJsonData =  [NSJSONSerialization dataWithJSONObject:object
                                                                    options:NSJSONWritingPrettyPrinted
                                                                      error:&error];
         if (! updateJsonData) {
             NSLog(@"ERROR getting JSON data to update Parking Lot Status : %@", error);
             return;
             
         }else{
             NSString *updateJsonString = [[NSString alloc] initWithData:updateJsonData encoding:NSUTF8StringEncoding];
             NSLog(@"updating Parking lot ino to server : %@",updateJsonString);
         }
         
         
         self.urlSubmitUpdateParkingLotStatusRequest = [[NSMutableURLRequest alloc] init];
         [self.urlSubmitUpdateParkingLotStatusRequest setURL:[NSURL URLWithString:path] ];
         [self.urlSubmitUpdateParkingLotStatusRequest setHTTPMethod:@"PUT"];
         [self.urlSubmitUpdateParkingLotStatusRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
         [self.urlSubmitUpdateParkingLotStatusRequest setHTTPBody:updateJsonData];
         
         NSLog(@"PUT REQ : %@",[self.urlSubmitUpdateParkingLotStatusRequest debugDescription]);

         NSURLConnection *theAsyncConnection = [[NSURLConnection alloc]initWithRequest:self.urlSubmitUpdateParkingLotStatusRequest delegate:self];
         if(theAsyncConnection){
             NSLog(@"Connection Successful");
         }else{
             NSLog(@"Connection Failed");
             UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Connection Failed" delegate:nil cancelButtonTitle:@"Exit" otherButtonTitles:nil, nil];
             [alert show];
         }
         
     }


     -(void) geofenceParkingLotsUsing:(NSMutableArray *)parkingLotGeoInfoArray{
         
         int i=0;
         
         //allowed to monitor a max of 20 locations monitoring
         for(CLCircularRegion *region in parkingLotGeoInfoArray){
             if(i<20){
                 [self.locationManager startMonitoringForRegion:region];
                 NSLog(@"Starting monitoring lot %@",region.identifier);
                 i++;
             }
         }
     }
     

     
     
//UI Elements and Functions  (Code Indentation using X-Code's structure->Re-Indent)

#pragma mark -
#pragma mark Picker Data Source Methods
     -(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
         
         //1 col for decals
         return 1;
     }
     
     -(NSInteger)pickerView:(UIPickerView*)pickerView
                                      numberOfRowsInComponent:(NSInteger)component{
                                          return [self.parkingDecals count];
                                          
                                      }
         
     
     - (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
         UILabel* tView = (UILabel*)view;
         if (!tView){
             tView = [[UILabel alloc] init];
             // Setup label properties - frame, font, colors etc
             tView.adjustsFontSizeToFitWidth = YES;
             tView.backgroundColor = [UIColor colorWithRed:191.0/255.0 green:221.0/255.0 blue:255.0/255.0 alpha:1.0];
             //tView.alpha =0.8;
             tView.font = [UIFont fontWithName:@"Helvetica-BoldOblique" size:20.0];
         }
         // Fill the label text here
         [tView setText:self.parkingDecals[row]];
         return tView;
     }
     
     
     -(void)pickerView:(UIPickerView*)pickerView
                                                didSelectRow :(NSInteger)row
                                                 inComponent :(NSInteger)component{
                                                     
                                                     //load the table with its data
                                                     self.selectedParkingDecal = row;
                                                     [self.parkingLotStatusLabel setText:@""];
                                                     [self.parkingLotTable reloadData];
                                                     [self.decalDescriptionTextView setText:self.parkingDecalDescription[self.selectedParkingDecal]];
                                                 }
     
         
        
          
     
     //Parking Lot selected, now get its current status
     - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
         NSLog(@" Selected Row : %ld",(long)indexPath.row);
         self.selectedParkingLot = indexPath.row;
         NSArray * parkingLots = self.associatedParkingLots[self.selectedParkingDecal];
         NSString *parkinglotName = parkingLots[self.selectedParkingLot];
         [self.activityIndicator startAnimating];
         [self getParkingLotStatusofParkingLotName:parkinglotName];
     }
     
         
         
     
     - (NSInteger)tableView:(UITableView *)tableView
                                        numberOfRowsInSection:(NSInteger)section{
                                            
                                            NSLog(@"numberOfRowsInSection");
                                            if([self.associatedParkingLots count] > 0){
                                                NSLog(@"%lu",(unsigned long)[self.associatedParkingLots[self.selectedParkingDecal] count]);
                                                return [self.associatedParkingLots[self.selectedParkingDecal] count];
                                            }else{
                                                return 0;
                                            }
                                        }
     
     
     
     - (UITableViewCell *)tableView:(UITableView *)tableView
                                        cellForRowAtIndexPath:(NSIndexPath *)indexPath{
                                            
                                            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"parkingLotTableElement"];
                                            if (cell == nil) {
                                                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"parkingLotTableElement"];
                                                
                                            }
                                            
                                            NSArray * parkingLots = self.associatedParkingLots[self.selectedParkingDecal];
                                            cell.textLabel.text = parkingLots[indexPath.row];
                                            
                                            return cell;
                                            
                                            
                                        }
     
     
     
     - (void)didReceiveMemoryWarning {
         [super didReceiveMemoryWarning];
         // Dispose of any resources that can be recreated.
     }

    
@end
