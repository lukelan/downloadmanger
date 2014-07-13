//
//  DownloadCell.h


#import <UIKit/UIKit.h>
//#import "Constants.h"
#import "AFDownloadRequestOperation.h"


@interface DownloadCell : UITableViewCell {
}
@property(nonatomic,assign)UIViewController *delegate;
@property (weak, nonatomic) IBOutlet UILabel *fileTypeLab;
@property (weak, nonatomic) IBOutlet UIImageView *fileImage;
@property (weak, nonatomic) IBOutlet UILabel *averagebandLab;
@property (weak, nonatomic) IBOutlet UILabel *sizeinfoLab;

@property (weak, nonatomic) IBOutlet UIImageView *typeImage;
@property(nonatomic,weak)IBOutlet UIProgressView *progress1;
@property(nonatomic,weak)IBOutlet UILabel *fileName;
@property(nonatomic,weak)IBOutlet UILabel *fileCurrentSize;
@property(nonatomic,weak)IBOutlet UILabel *fileSize;
@property (weak, nonatomic) IBOutlet UILabel *timelable;
@property(nonatomic,weak)IBOutlet UIButton *operateButton;

@property(nonatomic,retain)AFDownloadRequestOperation *request;//The document initiated request
@property(nonatomic,retain)NSDictionary *fileInfo;


- (IBAction)deleteRquest:(id)sender;

-(IBAction)operateTask:(id)sender;//Operations (pause, resume) files being downloaded
@end
