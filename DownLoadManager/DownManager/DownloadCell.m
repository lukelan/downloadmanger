//
//  DownloadCell.m


#import "DownloadCell.h"

#import "FPTFileDownloadManager.h"
#import "DownloadViewController.h"
@implementation DownloadCell
@synthesize fileInfo;
@synthesize progress1;
@synthesize fileName;
@synthesize fileCurrentSize;
@synthesize fileSize;
@synthesize timelable;
@synthesize operateButton;
@synthesize request;
@synthesize averagebandLab;
@synthesize sizeinfoLab;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}
- (void)dealloc
{
    request = nil;
    fileInfo = nil;
}

- (IBAction)deleteRquest:(id)sender {
    FPTFileDownloadManager *filedownmanage = [FPTFileDownloadManager sharedFPTFileDownloadManager];
    [filedownmanage deleteRequest:request];
       if ([self.delegate respondsToSelector:@selector(ReloadDownLoadingTable)]) 
    [((DownloadViewController*)self.delegate) ReloadDownLoadingTable];
}

-(IBAction)operateTask:(UIButton*)sender
{
	//During operation should be banned in response to the key may cause abnormal
    sender.userInteractionEnabled = NO;
    NSDictionary *downFile=self.fileInfo;
    FPTFileDownloadManager *filedownmanage = [FPTFileDownloadManager sharedFPTFileDownloadManager];
    if([[downFile objectForKey:@"downloadState"] integerValue] == FPTFileDownloadStateDownloading)//File is being downloaded, and then click the pause downloads are likely to enter the wait state
    {
        [operateButton setBackgroundImage:[UIImage imageNamed:@"下载管理-开始按钮.png"] forState:UIControlStateNormal];
        [filedownmanage stopRequest:request];
    }
    else
    {
            [operateButton setBackgroundImage:[UIImage imageNamed:@"下载管理-暂停按钮.png"] forState:UIControlStateNormal];
            if ([[downFile objectForKey:@"post"] boolValue]) {
            }else
                [filedownmanage resumeRequest:request];
    }
    //Pause means that the Cell has been released in the ASIHttprequest to update table data, so that the latest ASIHttpreqst Control Cell
    if ([self.delegate respondsToSelector:@selector(ReloadDownLoadingTable)]) {
           [((DownloadViewController*)self.delegate) ReloadDownLoadingTable];
    }
    sender.userInteractionEnabled = YES;
}
@end
