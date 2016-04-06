//
//  ViewController.h
//  FinalProjectStart
//
//  Created by Soumya Sreekumar on 11/24/14.
//  Copyright (c) 2014 Soumya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CoreMotion.h>
#import <CoreLocation/CLLocation.h>

//# possible algorithms.. currently enabled best based on tests.
//#define LOT_ENTRY_EXIT_COLLECT_IN_ARRAY_ALGO
#define LOT_ENTRY_EXIT_TIME_BASED_ALGO
//#define LOT_ENTRY_EXIT_TWO_MINUTE_PRIOR_ALGO

@interface ViewController : UIViewController <CLLocationManagerDelegate,UIAlertViewDelegate>
//UI Elements
@property (weak, nonatomic) IBOutlet UIPickerView *parkingLotPicker;
@property (weak, nonatomic) IBOutlet UITableView *parkingLotTable;
@property (weak, nonatomic) IBOutlet UITextView *decalDescriptionTextView;
@property (weak, nonatomic) IBOutlet UILabel *parkingLotStatusLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property(nonatomic, assign) id< UIPickerViewDelegate > delegate;
@property(nonatomic, assign) id< UIPickerViewDataSource > dataSource;

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region;

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region;

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region
              withError:(NSError *)error;

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations;

-(BOOL)CanDeviceSupportAppBackgroundRefresh;
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status;


typedef enum {
    WALKING=0,
    DRIVING,
    UNKNOWN
}motionActivityType;

//Web related functions
-(void) getParkingLotInfo;
-(void) getParkingLotStatusofParkingLotName:(NSString*)parkinglotName;
-(void) getParkingLotGeoInfo;
-(void) geofenceParkingLotsUsing:(NSMutableArray *)parkingLotGeoInfoArray;
-(void) updateParkingLotwithRegion:(CLRegion*)currentRegion andParked:(BOOL)parked isFull:(BOOL)isFull;
-(void) postDataToServerPath:(NSString *)path UsingObject:(NSMutableDictionary *)object;
-(void) handleParkingInfoData;
-(void) handleParkingStatusData;
-(void) handleParkingStatusUpdate;
-(void) handleParkingGeoData;
//Logic Functions
-(void)evaluateAndReportStatus;
-(void) collectAndReportActivityDatainArray:(NSMutableArray *)activityArray forExit:(BOOL)didExitRegion;
-(motionActivityType) evaluateMotionType:(NSMutableArray *)activitArray;
-(void) reportParkingStatususingEntryMotionType:(motionActivityType)enteringMotionType ExitMotionType:(motionActivityType)exitMotionType;
//Variables
@property NSURLRequest *urlRequestParkingLotInfo;
@property NSURLRequest *urlRequestParkingLotStatus;
@property NSURLRequest *urlRequestParkingLotGeoInfo;
@property NSMutableURLRequest *urlSubmitUpdateParkingLotStatusRequest;
@property NSMutableData *parkingLotInfo;
@property NSMutableData *parkingLotStatus;
@property NSMutableData *parkingLotGeoInfo;
@property NSMutableData *parkingLotStatusUpdateInfo;
@property NSMutableData *tempParkingLotFileToUpdate;
@property NSMutableArray *parkingDecals;
@property NSMutableArray *parkingDecalDescription;
@property NSMutableArray *associatedParkingLots;
@property NSMutableArray *parkingLotGeoInfoArray;
@property NSMutableArray *enteringActivityArray;
@property NSMutableArray *exitActivityArray;
@property NSInteger selectedParkingDecal;
@property NSInteger selectedParkingLot;
@property BOOL updateParkingLotStatus;
@property BOOL isParked;
@property BOOL isFull;
@property CLLocationCoordinate2D currentGeoLocation;
@property CLLocationCoordinate2D gotoLocation;
@property NSString * gotoLocationName;
@property motionActivityType enteringMotionType;
@property motionActivityType exitMotionType;
@property CLRegion *currentRegion;
@property NSDate *LotEnteringDateTime;
@property (strong, nonatomic)NSOperationQueue *activityQueue;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CMMotionActivityManager *motionActivityManager;

@end

