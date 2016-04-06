//
//  FirstViewController.m
//  SamplerApp
//
//  Created by Soumya Sreekumar on 10/22/14.
//  Copyright (c) 2014 Soumya. All rights reserved.
//

#import "FirstViewController.h"

#define kCountryComponent 0
#define kFoodComponent 1


@interface FirstViewController ()

@property (weak, nonatomic) IBOutlet UIPickerView *customPicker;
@property (weak, nonatomic) IBOutlet UISlider *slider;

@property NSDictionary *countryAndFood;//Dictionary read from plist file
@property NSArray *country;         //Sorted list of keys from countryAndFood
@property NSArray *food;            //Food for current selected country
@property float sliderPostion;      //store the current position of the slider
@end

@implementation FirstViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    //Reading food.plist
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *plistPath = [bundle pathForResource:@"food" ofType:@"plist"];
    NSDictionary *dictionary = [[NSDictionary alloc]initWithContentsOfFile:plistPath];
    self.countryAndFood = dictionary;

    NSArray *components = [self.countryAndFood allKeys];
    NSLog(@" _countryAndFood = %@", [_countryAndFood description]);
    NSArray *sorted = [components sortedArrayUsingSelector:@selector(compare:)];
    self.country = sorted;
    
    NSString *selectType = [self.country objectAtIndex:0];
    self.food = [_countryAndFood objectForKey:selectType];
    
    self.customPicker.delegate = self;
    self.customPicker.dataSource = self;
    
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark Picker Data Source Methods
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    
    // 2 columns, 1 for Country and 1 for Food
    return 2;
}

-(NSInteger)pickerView:(UIPickerView*)pickerView
numberOfRowsInComponent:(NSInteger)component{
    
    if (component == kCountryComponent){
        return [self.country count];
    }
    else if(component == kFoodComponent){
        return [self.food count];
    }
    else{
        return 0;
    }
}

#pragma mark Picker Delegate Methods
//Returning the data for each column
- (NSString *)pickerView:(UIPickerView *)pickerView
   titleForRow:(NSInteger)row
   forComponent:(NSInteger)component{
    
    if (component == kCountryComponent){
        return [self.country objectAtIndex:row];
    }
    else if(component == kFoodComponent){
        return [self.food objectAtIndex:row];
    }
    else{
        return 0;
    }
        
}

//Updating View when user selects country
-(void)pickerView:(UIPickerView*)pickerView
    didSelectRow :(NSInteger)row
     inComponent :(NSInteger)component{
    
    if(component == kCountryComponent)
    {
        NSString *selectType  = [self.country objectAtIndex:row];
        NSArray *array = [_countryAndFood objectForKey:selectType];
        self.food = array;
        [_customPicker selectRow:0 inComponent:kFoodComponent animated :YES];
        [_customPicker reloadComponent :kFoodComponent];
        [_slider setValue:0 animated:YES];
    }
    else if(component == kFoodComponent){
        NSLog(@" pickerposition=%ld",(lroundf(((float)([_customPicker selectedRowInComponent:kFoodComponent]+1)/[_food count])*100)));
        if([_customPicker selectedRowInComponent:kFoodComponent] == 0){
            //to make slider reach left end while coming backwards
            [_slider setValue:0 animated:YES];
        }
        else{
            //+1 to make slider reach right end when going forward
            [_slider setValue:(lroundf(((float)([_customPicker selectedRowInComponent:kFoodComponent]+1)/[_food count])*100)) animated:YES];
        }
    }
}

//updating slider as picker postion is changed
- (IBAction)sliderMoved:(UISlider *)sender {
    
    _sliderPostion = lroundf(sender.value);
    [_customPicker selectRow:lroundf((_sliderPostion/100)*[_food count]) inComponent:kFoodComponent animated :YES];
    [_customPicker reloadComponent :kFoodComponent];
}

@end
