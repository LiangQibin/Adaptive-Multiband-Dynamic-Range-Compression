//
//  ViewController.h
//  Binaural
//
//  Created by Kashyap Patel on 9/24/19.
//  Copyright © 2019 Kashyap Patel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IosAudioController.h"
#import "dsp.h"
//#import "settings.h"
#import "Configuration.h"

NS_ASSUME_NONNULL_BEGIN


@interface ViewController : UIViewController


- (IBAction)settingsBtn:(id)sender;
@property (weak, nonatomic) IBOutlet UISwitch *audioOn;

- (IBAction)assistanceOn:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *onstate;





@end

NS_ASSUME_NONNULL_END
