//
//  SettingsTableViewController.h
//  Binaural
//
//  Created by Kashyap Patel on 9/17/19.
//  Copyright © 2019 Kashyap Patel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Configuration.h"
#import "dsp.h"


NS_ASSUME_NONNULL_BEGIN

@interface SettingsTableViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backBtn;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editBtn;

- (IBAction)backBtn:(id)sender;
- (IBAction)editBtn:(id)sender;

//Audio Settings

- (IBAction)isCompressionOn:(id)sender;
- (IBAction)isStereo_On:(id)sender;
@property (weak, nonatomic) IBOutlet UISwitch *is_compressionOn;
@property (weak, nonatomic) IBOutlet UISwitch *is_stereo_Output;
@property (weak, nonatomic) IBOutlet UISwitch *is_adaptive;

@property (weak, nonatomic) IBOutlet UISegmentedControl *gain_Setting;
- (IBAction)gain_Setting_action:(id)sender;

//Compression Settings
- (IBAction)CR:(id)sender;
- (IBAction)thresholdVal:(id)sender;
- (IBAction)numOfChannels:(id)sender;
- (IBAction)setReleaseTime:(id)sender;
- (IBAction)setAttackTime:(id)sender;

@property (weak, nonatomic) IBOutlet UISlider *CR;
@property (weak, nonatomic) IBOutlet UITextField *Threhsold;
@property (weak, nonatomic) IBOutlet UITextField *NumChannels;
@property (weak, nonatomic) IBOutlet UITextField *RT;
@property (weak, nonatomic) IBOutlet UITextField *AT;






//Audiogram Texts

@property (weak, nonatomic) IBOutlet UITextField *L250T;
@property (weak, nonatomic) IBOutlet UITextField *R250T;
@property (weak, nonatomic) IBOutlet UITextField *L500T;
@property (weak, nonatomic) IBOutlet UITextField *R500T;
@property (weak, nonatomic) IBOutlet UITextField *L1kT;
@property (weak, nonatomic) IBOutlet UITextField *R1kT;
@property (weak, nonatomic) IBOutlet UITextField *L1_5kT;
@property (weak, nonatomic) IBOutlet UITextField *R1_5kT;
@property (weak, nonatomic) IBOutlet UITextField *L2kT;
@property (weak, nonatomic) IBOutlet UITextField *R2kT;
@property (weak, nonatomic) IBOutlet UITextField *L3kT;
@property (weak, nonatomic) IBOutlet UITextField *R3kT;
@property (weak, nonatomic) IBOutlet UITextField *L4kT;
@property (weak, nonatomic) IBOutlet UITextField *R4kT;
@property (weak, nonatomic) IBOutlet UITextField *L6kT;
@property (weak, nonatomic) IBOutlet UITextField *R6kT;
@property (weak, nonatomic) IBOutlet UITextField *L8kT;
@property (weak, nonatomic) IBOutlet UITextField *R8kT;


@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *TextViews;

@property (strong, nonatomic) IBOutletCollection(UISwitch) NSArray *Switches;



// Audiogram Thresholds Actions
- (IBAction)L250:(id)sender;
- (IBAction)R250:(id)sender;
- (IBAction)L500:(id)sender;
- (IBAction)R500:(id)sender;
- (IBAction)L1k:(id)sender;
- (IBAction)R1k:(id)sender;
- (IBAction)L1_5k:(id)sender;
- (IBAction)R1_5k:(id)sender;
- (IBAction)L2k:(id)sender;
- (IBAction)R2k:(id)sender;
- (IBAction)L3k:(id)sender;
- (IBAction)R3k:(id)sender;
- (IBAction)L4k:(id)sender;
- (IBAction)R4k:(id)sender;
- (IBAction)L6k:(id)sender;
- (IBAction)R6k:(id)sender;
- (IBAction)L8k:(id)sender;
- (IBAction)R8k:(id)sender;











@end

NS_ASSUME_NONNULL_END
