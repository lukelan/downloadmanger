//
//  DownloadViewController.m


#import "DownloadViewController.h"
#import "FPTFileDownloadManager.h"
#import "AFDownloadRequestOperation.h"
#define OPENFINISHLISTVIEW

@implementation DownloadViewController

@synthesize downloadingTable;
@synthesize finishedTable;
@synthesize downingList;
@synthesize finishedList;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [downingList removeAllObjects];
    [finishedList removeAllObjects];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (IBAction)goDownloadingView:(UIButton *)sender {
    downloadingTable.hidden = NO;
    finishedTable.hidden =YES;
    clearallbtn.hidden = YES;
    self.finieshedViewBtn.selected = NO;
    self.downloadingViewBtn.selected = YES;
    [self.downloadingTable reloadData];
}

- (IBAction)goFinishedView:(UIButton *)sender {
    downloadingTable.hidden = YES;
    finishedTable.hidden =NO;
    clearallbtn.hidden = NO;
    self.finieshedViewBtn.selected =YES;
    self.downloadingViewBtn.selected = NO;
    [self.finishedTable reloadData];
    self.noLoadsInfo.hidden = YES;
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)showFinished
{
    [self startFlipAnimation:0];
    self.navigationItem.rightBarButtonItem= [self makeCustomRightBarButItem:@"Download" action:@selector(showDowning)];
}

-(void)showDowning
{
    [self startFlipAnimation:1];
    self.navigationItem.rightBarButtonItem=[self makeCustomRightBarButItem:@"Downloaded" action:@selector(showFinished)];
}


-(void)startFlipAnimation:(NSInteger)type
{
    CGContextRef context=UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:1.0f];
    UIView *lastView=[self.view viewWithTag:103];
    
    if(type==0)
    {
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:lastView cache:YES];
    }
    else
    {
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:lastView cache:YES];
    }
    
    UITableView *frontTableView=(UITableView *)[lastView viewWithTag:101];
    UITableView *backTableView=(UITableView *)[lastView viewWithTag:102];
    NSInteger frontIndex=[lastView.subviews indexOfObject:frontTableView];
    NSInteger backIndex=[lastView.subviews indexOfObject:backTableView];
    [lastView exchangeSubviewAtIndex:frontIndex withSubviewAtIndex:backIndex];
    [UIView commitAnimations];
}


-(IBAction)enterEdit:(UIButton*)sender
{
//    self.navigationItem.leftBarButtonItem=[[[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(leaveEdit)]autorelease];
    sender.selected = !sender.selected;
    if (!sender.selected) {
        [self.downloadingTable setEditing:NO animated:YES];
        [self.finishedTable setEditing:NO animated:YES];
        backbtn.hidden = NO;
        clearallbtn.hidden = YES;
        
    }else{
    [self.downloadingTable setEditing:YES animated:YES];
    [self.finishedTable setEditing:YES animated:YES];
        backbtn.hidden = YES;
        clearallbtn.hidden = NO;
    }
}

-(IBAction)clearlist:(UIButton *)sender{
    if ([self.finishedList count]==0)
        return;
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Tips" message:@"Delete all the contents of the list is complete, it will not delete the corresponding file, confirm delete?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm", nil];
    [alert show];
    return;
}
-(void)clearAction{
    if (!self.downloadingTable.hidden) {
        if ([self.downingList count]>0) {
            FPTFileDownloadManager *filedownmanage = [FPTFileDownloadManager sharedFPTFileDownloadManager];
            [filedownmanage clearAllRquests];
            [self.downingList removeAllObjects];
            [self.downloadingTable reloadData];
        }
    }else if (!self.finishedTable.hidden){
        if ([self.finishedList count]>0) {
            FPTFileDownloadManager *filedownmanage = [FPTFileDownloadManager sharedFPTFileDownloadManager];
            [filedownmanage clearAllFinished];
            [self.finishedList removeAllObjects];
            [self.finishedTable reloadData];
        }
    }
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        [self clearAction];
    }
}
//-(UIImage *)getImage:(FPTFileDownloadModel *)fileinfo{
//    FPTFileDownloadManager *filedownmanage = [FPTFileDownloadManager sharedFPTFileDownloadManager];
//    return [filedownmanage getImage:fileinfo];
//}
#pragma mark - View lifecycle

-(void)viewWillAppear:(BOOL)animated
{
    // self.navigationController.navigationBar.hidden = YES;
    FPTFileDownloadManager *filedownmanage = [FPTFileDownloadManager sharedFPTFileDownloadManager];
    
    [filedownmanage startLoad];
    self.downingList = filedownmanage.downinglist;
    [self.downloadingTable reloadData];
    
    self.finishedList= filedownmanage.finishedlist;
    [self.finishedTable reloadData];

}
-(void)viewWillDisappear:(BOOL)animated{
    // self.navigationController.navigationBar.hidden = NO;
//    FPTFileDownloadManager *filedownmanage = [FPTFileDownloadManager sharedFPTFileDownloadManager];
//    [filedownmanage saveFinishedFile];
}
- (void)viewDidLoad
{
    self.title = @"Download Manager";
    [super viewDidLoad];
 
     version =[[[UIDevice currentDevice] systemVersion] floatValue];
    
    [FPTFileDownloadManager sharedFPTFileDownloadManager].downloadDelegate = self;

    downloadingTable.hidden = NO;
    finishedTable.hidden =YES;
    self.finieshedViewBtn.selected = NO;
    self.downloadingViewBtn.selected = YES;
    clearallbtn.hidden = YES;
    self.diskInfoLab.text = [CommonHelper getDiskSpaceInfo];
   
}

- (void)viewDidUnload
{

    [self setDownloadingViewBtn:nil];
    [self setFinieshedViewBtn:nil];
    
    [self setEditbtn:nil];
    clearallbtn = nil;
    backbtn = nil;
    [self setDiskInfoLab:nil];
    [self setBandwithLab:nil];
    [self setNoLoadsInfo:nil];
   
    self.downloadingTable=nil;
    self.finishedTable=nil;
     [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
-(UIBarButtonItem*)makeCustomRightBarButItem:(NSString *)titlestr action:(SEL)action{
    CGRect frame_1= CGRectMake(0, 0, 45, 27);
    UIImage* image= [UIImage imageNamed:@"顶部按钮背景.png"];
    UIButton* showfinishbtn= [[UIButton alloc] initWithFrame:frame_1];
    [showfinishbtn setBackgroundImage:image forState:UIControlStateNormal];
    [showfinishbtn setTitle:titlestr forState:UIControlStateNormal];
    [showfinishbtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    showfinishbtn.titleLabel.font=[UIFont systemFontOfSize:14];
    [showfinishbtn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem* showFinishedBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:showfinishbtn];
    return showFinishedBarButtonItem;
}
#pragma mark ---UITableView Delegate---

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView==self.downloadingTable)
    {
        if (self.downingList.count==0) {
            if (self.downloadingTable.hidden) {
                self.noLoadsInfo.hidden = YES;
            }else
            self.noLoadsInfo.hidden = NO;
        }else
            self.noLoadsInfo.hidden = YES;
        return [self.downingList count];
    }
    else
    {
        return [self.finishedList count];
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView==self.downloadingTable)//List of files being downloaded
    {
        static NSString *downCellIdentifier=@"DownloadCell";
        DownloadCell *cell=(DownloadCell *)[tableView dequeueReusableCellWithIdentifier:downCellIdentifier];
        cell.delegate = self;
        [cell.progress1 setTrackImage:[UIImage imageNamed:@"下载管理进度条背景.png"]];
        [cell.progress1 setProgressImage:[UIImage imageNamed:@"下载管理进度背景点九.png"]];


        AFDownloadRequestOperation *theRequest=[self.downingList objectAtIndex:indexPath.row];
        if (theRequest==nil) {
            return cell=Nil;
        }
        NSDictionary *fileInfo=[theRequest.userInfo objectForKey:@"File"];
        NSString *currentsize = [CommonHelper getFileSizeString:[fileInfo objectForKey:@"fileReceivedSize"]];
        NSString *totalsize = [CommonHelper getFileSizeString:[fileInfo objectForKey:@"fileSize"]];
        cell.fileName.text=[fileInfo objectForKey:@"fileName"];
        cell.fileCurrentSize.text=currentsize;
        if ([totalsize longLongValue]<=0) {
            cell.fileSize.text=@"Unknown";
        }else
        cell.fileSize.text=[NSString stringWithFormat:@"Size:%@",totalsize];
       // cell.sizeinfoLab.text = [NSString stringWithFormat:@"%@/%@",currentsize,totalsize];
        cell.fileInfo=fileInfo;
        cell.request=theRequest;
        cell.fileTypeLab.text  =[NSString stringWithFormat:@"Format:%@",[fileInfo objectForKey:@"fileType"]] ;
        cell.timelable.text =[NSString stringWithFormat:@"%@",[fileInfo objectForKey:@"time"]] ;
        cell.timelable.hidden = YES;
        //cell.fileImage.image = fileInfo.fileimage;//[self getImage:fileInfo];

        if ([currentsize longLongValue]==0) {
            [cell.progress1 setProgress:0.0f];
        }else
            [cell.progress1 setProgress:[CommonHelper getProgress:[[fileInfo objectForKey:@"fileSize"] longLongValue] currentSize:[[fileInfo objectForKey:@"fileReceivedSize"] longLongValue]]];
        cell.sizeinfoLab.text =[NSString stringWithFormat:@"%0.0f%@",100*(cell.progress1.progress),@"%"];
       // NSLog(@"process:%@",cell.sizeinfoLab.text);
        if ([[fileInfo objectForKey:@"error"]boolValue])
        {
            [cell.operateButton setBackgroundImage:[UIImage imageNamed:@"下载管理-开始按钮.png"] forState:UIControlStateNormal];
            cell.sizeinfoLab.text = @"Error";
        } else {
            if([[fileInfo objectForKey:@"downloadState"] integerValue] == FPTFileDownloadStateDownloading)//文件正在下载
            {
                [cell.operateButton setBackgroundImage:[UIImage imageNamed:@"下载管理-暂停按钮.png"] forState:UIControlStateNormal];
            }
            else if([[fileInfo objectForKey:@"downloadState"] integerValue] == FPTFileDownloadStateStopping)
            {
                [cell.operateButton setBackgroundImage:[UIImage imageNamed:@"下载管理-开始按钮.png"] forState:UIControlStateNormal];
                cell.sizeinfoLab.text = @"Timeout";
            }else if([[fileInfo objectForKey:@"downloadState"] integerValue] == FPTFileDownloadStateWaiting)
            {
                [cell.operateButton setBackgroundImage:[UIImage imageNamed:@"下载管理-开始按钮.png"] forState:UIControlStateNormal];
                cell.sizeinfoLab.text = @"Wait";
            }
        }
        return cell;
    }

    else if(tableView==self.finishedTable)//已完成下载的列表
    {
      
        static NSString *finishedCellIdentifier=@"FinishedCell";
        FinishedCell *cell=(FinishedCell *)[self.finishedTable dequeueReusableCellWithIdentifier:finishedCellIdentifier];
          cell.delegate = self;

        NSDictionary *fileInfo=[self.finishedList objectAtIndex:indexPath.row];
        cell.fileName.text=[fileInfo objectForKey:@"fileName"];
        
        cell.fileSize.text=[CommonHelper getFileSizeString:[fileInfo objectForKey:@"fileSize"]];
        cell.fileInfo=fileInfo;
        cell.fileTypeLab.text  =[NSString stringWithFormat:@"Format:%@",fileInfo.fileType] ;
        cell.timelable.text =[NSString stringWithFormat:@"%@",[fileInfo objectForKey:@"time"]] ;
        cell.fileImage.image = [fileInfo objectForKey:@"fileimage"];
        return cell;
    }

    return nil;
    
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}
//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 80;
//}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"Delete Task";
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle==UITableViewCellEditingStyleDelete)//Click the Delete button to delete the information note of the view of the list, they still updating UI APPDelegate in the list and
    {
        if(tableView.tag==101)//Downloading forms
        {
            AFDownloadRequestOperation *theRequest=[self.downingList objectAtIndex:indexPath.row];
            [[FPTFileDownloadManager sharedFPTFileDownloadManager] deleteRequest:theRequest];
            [self.downingList removeObjectAtIndex:indexPath.row];
            [self.downloadingTable reloadData];
        }
#ifdef OPENFINISHLISTVIEW
        else//Download the form has been completed
        {
            NSDictionary *selectFile=[self.finishedList objectAtIndex:indexPath.row];
            [[FPTFileDownloadManager sharedFPTFileDownloadManager]  deleteFinishFile:selectFile];
            [self.finishedTable reloadData];
        }
#endif
    }
}

-(void)updateCellOnMainThread:(NSDictionary *)fileInfo
{
//    self.bandwithLab.text = [NSString stringWithFormat:@"%@/S",[CommonHelper getFileSizeString:[NSString stringWithFormat:@"%lu",[ASIHTTPRequest averageBandwidthUsedPerSecond]]]] ;
    NSArray* cellArr = [self.downloadingTable visibleCells];
    for(id obj in cellArr)
    {
        if([obj isKindOfClass:[DownloadCell class]])
        {
            DownloadCell *cell=(DownloadCell *)obj;
            if([[cell.fileInfo objectForKey:@"fileURL"] isEqualToString: [fileInfo objectForKey:@"fileURL"]])
            {
                NSString *currentsize;
                if ([fileInfo objectForKey:@"post"]) {
                    currentsize = [fileInfo objectForKey:@"fileUploadSize"];
                    
                }else
                   currentsize = [fileInfo objectForKey:@"fileReceivedSize"];
                NSString *totalsize = [CommonHelper getFileSizeString:[fileInfo objectForKey:@"fileSize"]];
                cell.fileCurrentSize.text=[CommonHelper getFileSizeString:currentsize];;
                cell.fileSize.text = [NSString stringWithFormat:@"Size:%@",totalsize];
//                cell.sizeinfoLab.text = [NSString stringWithFormat:@"%@/%@",currentsize,totalsize];
//                NSLog(@"%@",cell.sizeinfoLab.text);
                
                [cell.progress1 setProgress:[CommonHelper getProgress:[[fileInfo objectForKey:@"fileSize"] floatValue] currentSize:[currentsize floatValue]]];
                NSLog(@"%f",cell.progress1 .progress);

                 cell.sizeinfoLab.text =[NSString stringWithFormat:@"%.0f%@",100*(cell.progress1.progress),@"%"];
//                cell.averagebandLab.text =[NSString stringWithFormat:@"%@/s",[CommonHelper getFileSizeString:[NSString stringWithFormat:@"%lu",[ASIHTTPRequest averageBandwidthUsedPerSecond]]]] ;
                if ([[fileInfo objectForKey:@"error"]boolValue])
                {
                    [cell.operateButton setBackgroundImage:[UIImage imageNamed:@"下载管理-开始按钮.png"] forState:UIControlStateNormal];
                    cell.sizeinfoLab.text = @"Error";
                } else {
                    if([[fileInfo objectForKey:@"downloadState"] integerValue] == FPTFileDownloadStateDownloading)//文件正在下载
                    {
                        [cell.operateButton setBackgroundImage:[UIImage imageNamed:@"下载管理-暂停按钮.png"] forState:UIControlStateNormal];
                    }
                    else if([[fileInfo objectForKey:@"downloadState"] integerValue] == FPTFileDownloadStateStopping)
                    {
                        [cell.operateButton setBackgroundImage:[UIImage imageNamed:@"下载管理-开始按钮.png"] forState:UIControlStateNormal];
                        cell.sizeinfoLab.text = @"Timeout";
                    }else if([[fileInfo objectForKey:@"downloadState"] integerValue] == FPTFileDownloadStateWaiting)
                    {
                        [cell.operateButton setBackgroundImage:[UIImage imageNamed:@"下载管理-开始按钮.png"] forState:UIControlStateNormal];
                        cell.sizeinfoLab.text = @"Wait";
                    }
                }
            }
        }
    }
}

#pragma mark --- updateUI delegate ---
-(void)startDownload:(AFDownloadRequestOperation *)request;
{
    NSLog(@"-------Start downloading!");
}

-(void)updateCellProgress:(AFDownloadRequestOperation *)request;
{
    NSDictionary *fileInfo=[request.userInfo objectForKey:@"File"];
    [self performSelectorOnMainThread:@selector(updateCellOnMainThread:) withObject:fileInfo waitUntilDone:YES];
}

-(void)finishedDownload:(AFDownloadRequestOperation *)request;
{

     self.downingList = [FPTFileDownloadManager sharedFPTFileDownloadManager].downinglist;
    [self.downloadingTable reloadData];
     self.bandwithLab.text = @"0.00K/S";

    [self.finishedTable reloadData];

}
- (void)deleteFinishedFile:(NSDictionary *)selectFile
{
    self.finishedList = [FPTFileDownloadManager sharedFPTFileDownloadManager].finishedlist;
    [self.finishedTable reloadData];
}
-(void)ReloadDownLoadingTable
{
    self.downingList = [FPTFileDownloadManager sharedFPTFileDownloadManager].downinglist;
    
    [self.downloadingTable reloadData];
}
//-(BOOL) respondsToSelector:(SEL)aSelector {
//    printf("SELECTOR: %s\n", [NSStringFromSelector(aSelector) UTF8String]);
//    return [super respondsToSelector:aSelector];
//}
@end
