//
//  SettingViewController.h
//  DownLoadManager
//
//  Created by chunyu.wang on 13-12-4.
//  Copyright (c) 2013年 11 111. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingViewController : UIViewController
{
 
}
@property (weak, nonatomic) IBOutlet UIStepper *countStepper;
@property (weak, nonatomic) IBOutlet UILabel *countLab;
- (IBAction)valueChange:(UIStepper *)sender;
- (IBAction)validchange:(id)sender;

@end
