//
//  SecondViewController.m
//  SamplerApp
//
//  Created by Soumya Sreekumar on 10/22/14.
//  Copyright (c) 2014 Soumya. All rights reserved.
//

#import "SecondViewController.h"

@interface SecondViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //loading google by default for user's convenience
    NSURL *url = [NSURL URLWithString:@"http://www.google.com"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:request];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)goButtonPressed:(id)sender {
    [self webLoad];
   

}

- (BOOL)textFieldShouldReturn:(UITextField*)textField{
    [self webLoad];
    [textField resignFirstResponder];
    return  YES;
    
    
}

//Loading the web page
-(void)webLoad{
    
    NSString *urlString = _textField.text;
    NSURL *url = [NSURL URLWithString:urlString];
    if (![[url scheme]length]){
        url = [NSURL URLWithString:[@"http://" stringByAppendingString:urlString]];
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:request];
    [_textField resignFirstResponder];
    
}
@end
