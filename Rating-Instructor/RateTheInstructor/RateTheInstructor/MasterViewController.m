//
//  MasterViewController.m
//  RateTheInstructor
//
//  Created by Soumya Sreekumar on 11/6/14.
//  Copyright (c) 2014 Soumya. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"

@interface MasterViewController ()

@property NSMutableArray *objects;

@end

@implementation MasterViewController

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Assign an activity Indicator to the Header of the TableView
    
    self.activityIndicator = [[UIActivityIndicatorView alloc]
                                   initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.activityIndicator startAnimating];
    [self.activityIndicator setCenter:CGPointMake(150, 150)];
    self.activityIndicatorView = [[UIView alloc] initWithFrame:CGRectMake(0,0,300,300)];
    [self.activityIndicatorView addSubview:self.activityIndicator];
    self.tableView.tableHeaderView = self.activityIndicatorView;

    
    //Setup Connection and get Instructor List
    [self getConnection];
    
}

-(void)getConnection{
    
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://bismarck.sdsu.edu/rateme/list"] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
   
    NSURLConnection *theAsyncConnection = [[NSURLConnection alloc]initWithRequest:theRequest delegate:self];
    if(theAsyncConnection){
        receivedData = [NSMutableData data];
        NSLog(@"Connection Successful");
    }else{
        NSLog(@"Connection Failed");
        //On error stop activity indicator
        [self.activityIndicator stopAnimating];
        self.activityIndicatorView = nil;
        self.tableView.tableHeaderView = nil;
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Connection Failed" delegate:nil cancelButtonTitle:@"Exit" otherButtonTitles:nil, nil];
        [alert show];
    }
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    
    NSLog(@"Connection Failed");
    //On error stop activity indicator
    [self.activityIndicator stopAnimating];
    self.activityIndicatorView = nil;
    self.tableView.tableHeaderView = nil;
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Title" message:@"Connection Failed" delegate:nil cancelButtonTitle:@"Exit" otherButtonTitles:nil, nil];
    [alert show];
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"connectionDidFinishLoading");
    NSDictionary *dictionaryData = [NSJSONSerialization JSONObjectWithData:receivedData options:0 error:nil];
    
    //Keep a Dictionary of the full name and Id for reference later
    idNameDict = [[NSMutableDictionary alloc]init];
    names = [[NSMutableArray alloc]init];
    int i =0;
    
    for(id element in dictionaryData){
        
        NSString *id = [element objectForKey:@"id"];
        NSString *firstName = [element objectForKey:@"firstName"];
        NSString *lastname = [element objectForKey:@"lastName"];
        //store it in dictionary for lookup before requesting details.
        //this is to cover the case where the ids are not in ascending order in the JSON list.
        //with this if the id is changed later the display order remains the same and the new id will be used while requesting details.
        [idNameDict setValue:id forKey:[NSString stringWithFormat:@"%@ %@",firstName,lastname]];
        names[i] = [NSString stringWithFormat:@"%@ %@",firstName,lastname];
        i++;
    }


    //On Receiving Data stop animating and clear the header
    [self.activityIndicator stopAnimating];
    self.activityIndicatorView = nil;
    self.tableView.tableHeaderView = nil;
    self.objects = names;
    [self.tableView reloadData];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender {
    if (!self.objects) {
        self.objects = [[NSMutableArray alloc] init];
    }
    [self.objects insertObject:[NSDate date] atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        
        //getting the index path
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        NSString *profName = self.objects[indexPath.row];
        NSString *profId = [idNameDict  objectForKey:(self.objects[indexPath.row])];
        
       [[segue destinationViewController] setDetailItemProfName:profName];
       [[segue destinationViewController] setDetailItemProfId:profId];
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.objects.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    NSDate *object = self.objects[indexPath.row];
    cell.textLabel.text = [object description];
    return cell;
}

@end
