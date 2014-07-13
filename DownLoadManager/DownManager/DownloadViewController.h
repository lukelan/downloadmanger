//
//  DownloadViewController.h


#import <UIKit/UIKit.h>
#import "DownloadCell.h"
#import "FinishedCell.h"
#import "DownloadDelegate.h"

//#import "Constants.h"

@interface DownloadViewController : UIViewController
<UITableViewDelegate,UITableViewDataSource,DownloadDelegate>{
    IBOutlet UIButton *backbtn;
    IBOutlet UIButton *clearallbtn;
    NSMutableArray *downingList;
    NSMutableArray *finishedList;
    float version;
}
@property (weak, nonatomic) IBOutlet UILabel *bandwithLab;
@property (weak, nonatomic) IBOutlet UILabel *noLoadsInfo;

@property (weak, nonatomic) IBOutlet UILabel *diskInfoLab;
@property (weak, nonatomic) IBOutlet UIButton *editbtn;
@property(nonatomic,weak)IBOutlet UITableView *downloadingTable;
@property(nonatomic,weak)IBOutlet UITableView *finishedTable;
@property (weak, nonatomic) IBOutlet UIButton *downloadingViewBtn;
@property (weak, nonatomic) IBOutlet UIButton *finieshedViewBtn;
@property(nonatomic,retain)NSMutableArray *downingList;
@property(nonatomic,retain)NSMutableArray *finishedList;


- (IBAction)goDownloadingView:(UIButton *)sender;
- (IBAction)goFinishedView:(UIButton *)sender;
- (void)deleteFinishedFile:(NSDictionary *)selectFile;
-(void)ReloadDownLoadingTable;

- (IBAction)back:(id)sender;
-(IBAction)enterEdit:(UIButton*)sender;
-(IBAction)clearlist:(UIButton *)sender;
-(void)showFinished;//View the downloaded file view completed
-(void)showDowning;//See Downloading the file view
-(void)startFlipAnimation:(NSInteger)type;//Play rotation animation, 0 from right to left, left to right 1
-(void)updateCellOnMainThread:(NSDictionary *)fileInfo;//The main interface of the progress bar updates and information
@end
