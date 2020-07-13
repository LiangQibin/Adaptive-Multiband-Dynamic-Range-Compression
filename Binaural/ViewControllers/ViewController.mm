//
//  ViewController.m
//  Binaural
//
//  Created by Kashyap Patel on 9/24/19.
//  Copyright © 2019 Kashyap Patel. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
Configuration* Configuration::_instance = NULL;
Configuration* Config = Configuration::getInstance();

//setting2 = new settings;

- (void)viewDidLoad {
    [super viewDidLoad];
   
    initializeDSP();
    
    
    iosAudio = [[IosAudioController alloc] init];
    [iosAudio start];
    
    
   
    //NSString *X = [NSString stringWithFormat:@"%d", setting1->audiogramThresholdLeft[0]];
    //NSLog(X);
    
    
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
}




- (IBAction)settingsBtn:(id)sender {
    
    [iosAudio stop];
    [self performSegueWithIdentifier:@"toSettings" sender:sender];
    
}

- (IBAction)assistanceOn:(id)sender {
    
    if(_audioOn.isOn){
        [iosAudio start];
        _onstate.text = @"ON";
        
    }
    if(!_audioOn.isOn){
        [iosAudio stop];
        _onstate.text = @"OFF";
    }
    
    
}
@end
