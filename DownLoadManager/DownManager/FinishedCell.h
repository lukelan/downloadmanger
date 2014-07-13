//
//  FinishedCell.h


#import <UIKit/UIKit.h>


@interface FinishedCell : UITableViewCell {
}
@property(nonatomic,assign)UIViewController *delegate;
@property(nonatomic,retain) NSDictionary *fileInfo;
@property (weak, nonatomic) IBOutlet UILabel *fileTypeLab;
@property (weak, nonatomic) IBOutlet UIImageView *fileImage;
@property(nonatomic,weak)IBOutlet UILabel *fileName;
@property(nonatomic,weak)IBOutlet UILabel *fileSize;
@property (retain, nonatomic) IBOutlet UILabel *timelable;


- (IBAction)deleteFile:(id)sender;
- (IBAction)openFile:(UIButton *)sender;

@end
