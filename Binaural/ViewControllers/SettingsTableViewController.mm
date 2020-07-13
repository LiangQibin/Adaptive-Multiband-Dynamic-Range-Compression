//
//  SettingsTableViewController.m
//  Binaural
//
//  Created by Kashyap Patel on 9/17/19.
//  Copyright © 2019 Kashyap Patel. All rights reserved.
//

#import "SettingsTableViewController.h"
//#import "ViewController.h"


@interface SettingsTableViewController ()



@end

@implementation SettingsTableViewController

int audiogramThreshold = 90;
bool isEditingMode = false;
int* Left = (int*)calloc(9, sizeof(int));
int* Right = (int*)calloc(9, sizeof(int));
int* left = (int*)calloc(9, sizeof(int));
int* right = (int*)calloc(9, sizeof(int));
Configuration* ConfigSettings = Configuration::getInstance();


-(void)viewWillAppear
{
    [self setEditing: NO animated: NO];
    
    
}



- (void)viewDidLoad {
    //setting1 = new settings;
    [super viewDidLoad];
    NSLog(@"From second VC");
    
    
    
    [self SettingsonPage];
   
    ConfigSettings->displaySetting();
   /* self.edit.action = #selector(self.toogleEditor(_:))
    self.edit.title = "Edit"
    self.setEditing(isEditingMode, animated: true)
    for (UIView *view in [self.view subviews])
    {
      
        if (view.tag==_backBtn.tag)// set your button tag that you don't wont disable
            [view setUserInteractionEnabled:YES];
        else
            [view setUserInteractionEnabled:NO];
    }*/
   
    [self interactions:NO];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
   // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
 if (section == 0)
        return 3;
    else if (section == 1)
        return 9;
    else if (section == 2)
        return 5;
    else
        return 1;
}



/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {

    return NO;

}
/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    if ([[segue identifier] isEqualToString:@"toMain"]) {
        
        // Get destination view
       // ViewController *vc = [segue destinationViewController];
       // vc.x = @"This is from segue ";
       
    }
   
    
   
}




-(void) interactions:(BOOL) editMode
{
    
    for (UISwitch *s in _Switches){
        [s setUserInteractionEnabled:editMode];
    }
    
    for (UITextField *text in _TextViews)
    {
        [text setUserInteractionEnabled:editMode];
    }
        
    [_CR setUserInteractionEnabled:editMode];
    [_gain_Setting setUserInteractionEnabled:editMode];
    
}


-(BOOL)validateAudiogramThreshold:(int) x
{
    if (x<=40 && x>=-20){
        NSLog(@"its a valid Number");
        return true;
    }
    else
        NSLog(@"Try Again");
        return false;

}

-(int)getValueAudiogram:(int) x
{
    if (x>audiogramThreshold)
        return audiogramThreshold;
    else if(x<0)
        return 0;
    else
        return x;
}


-(void)updateSettings
{
    Left[0] = [self getValueAudiogram:[_L250T.text intValue]];
    Left[1] = [self getValueAudiogram:[_L500T.text intValue]];
    Left[2] = [self getValueAudiogram:[_L1kT.text intValue]];
    Left[3] = [self getValueAudiogram:[_L1_5kT.text intValue]];
    Left[4] = [self getValueAudiogram:[_L2kT.text intValue]];
    Left[5] = [self getValueAudiogram:[_L3kT.text intValue]];
    Left[6] = [self getValueAudiogram:[_L4kT.text intValue]];
    Left[7] = [self getValueAudiogram:[_L6kT.text intValue]];
    Left[8] = [self getValueAudiogram:[_L8kT.text intValue]];
    
    
    Right[0] =[self getValueAudiogram:[_R250T.text intValue]];
    Right[1] =[self getValueAudiogram:[_R500T.text intValue]];
    Right[2] =[self getValueAudiogram:[_R1kT.text intValue]];
    Right[3] =[self getValueAudiogram:[_R1_5kT.text intValue]];
    Right[4] =[self getValueAudiogram:[_R2kT.text intValue]];
    Right[5] =[self getValueAudiogram:[_R3kT.text intValue]];
    Right[6] =[self getValueAudiogram:[_R4kT.text intValue]];
    Right[7] =[self getValueAudiogram:[_R6kT.text intValue]];
    Right[8] =[self getValueAudiogram:[_R8kT.text intValue]];
    
    ConfigSettings->setAudiogramLeft(Left);
    ConfigSettings->setAudiogramRight(Right);
    ConfigSettings->setIsCompressionOn(_is_compressionOn.isOn);
    ConfigSettings->setIsStereo(_is_stereo_Output.isOn);
    ConfigSettings->setIsAdaptive(_is_adaptive.isOn);
    ConfigSettings->setRatio(_CR.value);
    ConfigSettings->setThreshold([_Threhsold.text floatValue]);
    ConfigSettings->setNumberofChannels([_NumChannels.text intValue]);
    ConfigSettings->setReleaseTime([_RT.text floatValue]);
    ConfigSettings->setAttackTime([_AT.text floatValue]);
    ConfigSettings->setMethod(_gain_Setting.selectedSegmentIndex);
    
}



-(void)SettingsonPage
{
    // Switches
    [_is_adaptive setOn: ConfigSettings->getIsAdaptive()];
    [_is_compressionOn setOn: ConfigSettings->getIsCompressionOn()];
    [_is_stereo_Output setOn: ConfigSettings->getIsStereo()];
    
    
    // Compression
    [_CR setValue:ConfigSettings->getRatio() animated:YES ];
    //[_Threhsold setText:[NSString stringWithFormat:@"%f",ConfigSettings->getThreshold()]];
    [_Threhsold setText:@(ConfigSettings->getThreshold()).stringValue];
    [_RT setText:@(ConfigSettings->getRleaseTime()).stringValue];
    [_AT setText:@(ConfigSettings->getAttackTime()).stringValue];
    [_NumChannels setText:@(ConfigSettings->getNumberofChannel()).stringValue];
    [_gain_Setting setSelectedSegmentIndex:ConfigSettings->getMethod()];
     

    left = ConfigSettings->getAudiogramLeft();
    right = ConfigSettings->getAudiogramRight();
    
    //Audiogram
    
    
    [_L250T setText:@(left[0]).stringValue];
    [_L500T setText:@(left[1]).stringValue];
    [_L1kT setText:@(left[2]).stringValue];
    [_L1_5kT setText:@(left[3]).stringValue];
    [_L2kT setText:@(left[4]).stringValue];
    [_L3kT setText:@(left[5]).stringValue];
    [_L4kT setText:@(left[6]).stringValue];
    [_L6kT setText:@(left[7]).stringValue];
    [_L8kT setText:@(left[8]).stringValue];
    
    [_R250T setText:@(right[0]).stringValue];
    [_R500T setText:@(right[1]).stringValue];
    [_R1kT setText:@(right[2]).stringValue];
    [_R1_5kT setText:@(right[3]).stringValue];
    [_R2kT setText:@(right[4]).stringValue];
    [_R3kT setText:@(right[5]).stringValue];
    [_R4kT setText:@(right[6]).stringValue];
    [_R6kT setText:@(right[7]).stringValue];
    [_R8kT setText:@(right[7]).stringValue];
    
    
}



//Navigation

- (IBAction)backBtn:(id)sender {
     [self performSegueWithIdentifier:@"toMain" sender:sender];
}

- (IBAction)editBtn:(id)sender {
    
    
   // [self toggleEditingMode];
    if ([_editBtn.title  isEqual: @"Edit"]){
        _editBtn.title = @"Save";
        [self interactions:YES];
        
    
    }
    else{
        
        [self updateSettings];
        
        
        NSLog(@"Settings have been changed.");
        //NSString *X = [NSString stringWithFormat:@"%d", setting1->audiogramThresholdLeft[0]];
       // NSLog(X);
        NSLog(@"Before");
        //[self performSegueWithIdentifier:@"toMain" sender:sender];
        [self interactions:NO];
        _editBtn.title = @"Edit";
        
    }
   
}








//Audio Settings

- (IBAction)isCompressionOn:(id)sender {
    
    
}

- (IBAction)isStereo_On:(id)sender {
}


// Compression Settings

- (IBAction)CR:(id)sender {
}

- (IBAction)thresholdVal:(id)sender {
}

- (IBAction)numOfChannels:(id)sender {
}

- (IBAction)setReleaseTime:(id)sender {
}

- (IBAction)setAttackTime:(id)sender {
}



//Audiogram Settings

- (IBAction)L250:(id)sender {
    
     
        
}
- (IBAction)R250:(id)sender {
    
    
}
    
- (IBAction)L500:(id)sender {
   
    
}

- (IBAction)R500:(id)sender {
    
   
}

- (IBAction)L1k:(id)sender {
   
   
}

- (IBAction)R1k:(id)sender {
    
}

- (IBAction)L1_5k:(id)sender {
    
    
}

- (IBAction)R1_5k:(id)sender {
    
    
}

- (IBAction)L2k:(id)sender {
    
}

- (IBAction)R2k:(id)sender {
    
    
}

- (IBAction)L3k:(id)sender {
    
}

- (IBAction)R3k:(id)sender {
  
    
}

- (IBAction)L4k:(id)sender {
   
}

- (IBAction)R4k:(id)sender {
    
}

- (IBAction)L6k:(id)sender {
    
}

- (IBAction)R6k:(id)sender {
   
}

- (IBAction)L8k:(id)sender {
    
}

- (IBAction)R8k:(id)sender {
   
}



- (IBAction)gain_Setting_action:(id)sender {
    
}
@end
