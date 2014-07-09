//
//  FPTFileDownloadManager.m
//  DownLoadManager
//
//  Created by TrongVM on 7/8/14.
//  Copyright (c) 2014 11 111. All rights reserved.
//

#import "FPTFileDownloadManager.h"
#import "Reachability.h"

#define MAXDOWNLOAD 20
#define MAXLINES  [[[NSUserDefaults standardUserDefaults] valueForKey:@"kMaxRequestCount"]integerValue]

#define TEMPPATH [CommonHelper getTempFolderPathWithBasepath:_basepath]
#define OPENFINISHLISTVIEW

@implementation FPTFileDownloadManager
@synthesize downinglist=_downinglist;
@synthesize fileInfo = _fileInfo;
@synthesize downloadDelegate=_downloadDelegate;
@synthesize finishedlist=_finishedList;
@synthesize buttonSound=_buttonSound;
@synthesize downloadCompleteSound=_downloadCompleteSound;
@synthesize isFistLoadSound=_isFirstLoadSound;
@synthesize basepath = _basepath;
@synthesize filelist = _filelist;
@synthesize targetPathArray = _targetPathArray;
@synthesize VCdelegate = _VCdelegate;
@synthesize count;
@synthesize  fileImage = _fileImage;
static   FPTFileDownloadManager *sharedFPTFileDownloadManager = nil;
NSInteger  maxcount;



-(void)playButtonSound
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSString *audioAlert = [userDefaults valueForKey:@"kAudioAlertSetting"];
    
	if( NO == [audioAlert boolValue] )
    {
        return;
    }
    NSURL *url=[[[NSBundle mainBundle]resourceURL] URLByAppendingPathComponent:@"btnEffect.wav"];
    NSError *error;
    if(self.buttonSound==nil)
    {
        self.buttonSound=[[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        if(!error)
        {
            NSLog(@"%@",[error description]);
        }
    }
    if([audioAlert isEqualToString:@"YES"]||audioAlert==nil)//Play sound
    {
        if(!self.isFistLoadSound)
        {
            self.buttonSound.volume=1.0f;
        }
    }
    else
    {
        self.buttonSound.volume=0.0f;
    }
    [self.buttonSound play];
}

-(void)playDownloadSound
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSString *result = [userDefaults valueForKey:@"kAudioAlertSetting"];
    
	if( NO == [result boolValue] )
    {
        return;
    }
    
    NSURL *url=[[[NSBundle mainBundle]resourceURL] URLByAppendingPathComponent:@"download-complete.wav"];
    NSError *error;
    if(self.downloadCompleteSound==nil)
    {
        self.downloadCompleteSound=[[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        if(!error)
        {
            NSLog(@"%@",[error description]);
        }
    }
    if([result isEqualToString:@"YES"]||result==nil)//Play sound
    {
        if(!self.isFistLoadSound)
        {
            self.downloadCompleteSound.volume=1.0f;
        }
    }
    else
    {
        self.downloadCompleteSound.volume=0.0f;
    }
    [self.downloadCompleteSound play];
}
-(NSArray *)sortbyTime:(NSArray *)array{
    NSArray *sorteArray1 = [array sortedArrayUsingComparator:^(id obj1, id obj2){
        FPTFileDownloadModel *file1 = (FPTFileDownloadModel *)obj1;
        FPTFileDownloadModel *file2 = (FPTFileDownloadModel *)obj2;
        NSDate *date1 = [CommonHelper makeDate:file1.time];
        NSDate *date2 = [CommonHelper makeDate:file2.time];
        if ([[date1 earlierDate:date2]isEqualToDate:date2]) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        
        if ([[date1 earlierDate:date2]isEqualToDate:date1]) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        
        return (NSComparisonResult)NSOrderedSame;
    }];
    return sorteArray1;
}
-(NSArray *)sortRequestArrbyTime:(NSArray *)array{
    NSArray *sorteArray1 = [array sortedArrayUsingComparator:^(id obj1, id obj2){
        //
        FPTFileDownloadModel* file1 =   [((ASIHTTPRequest *)obj1).userInfo objectForKey:@"File"];
        FPTFileDownloadModel *file2 =   [((ASIHTTPRequest *)obj2).userInfo objectForKey:@"File"];
        
        NSDate *date1 = [CommonHelper makeDate:file1.time];
        NSDate *date2 = [CommonHelper makeDate:file2.time];
        if ([[date1 earlierDate:date2]isEqualToDate:date2]) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        
        if ([[date1 earlierDate:date2]isEqualToDate:date1]) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        
        return (NSComparisonResult)NSOrderedSame;
    }];
    return sorteArray1;
}


-(void)saveDownloadFile:(FPTFileDownloadModel*)fileinfo{
    NSData *imagedata =UIImagePNGRepresentation(fileinfo.fileimage);
    
    NSDictionary *filedic = [NSDictionary dictionaryWithObjectsAndKeys:fileinfo.fileName,@"filename",fileinfo.fileURL,@"fileurl",fileinfo.time,@"time",_basepath,@"basepath",_TargetSubPath,@"tarpath" ,fileinfo.fileSize,@"filesize",fileinfo.fileReceivedSize,@"filerecievesize",imagedata,@"fileimage",nil];
    
    NSString *plistPath = [fileinfo.tempPath stringByAppendingPathExtension:@"plist"];
    if (![filedic writeToFile:plistPath atomically:YES]) {
        NSLog(@"write plist fail");
    }
}
-(void)beginRequest:(FPTFileDownloadModel *)fileInfo isBeginDown:(BOOL)isBeginDown
{
    for(ASIHTTPRequest *tempRequest in self.downinglist)
    {
        
        /**
         Note that this interpretation is the same download method, asihttprequest three url:
         url, originalurl, redirectURL
         After practice, you should use originalurl, is the first to get to the original Download
         **/
        
        NSLog(@"%@",[tempRequest.url absoluteString]);
        if([[[tempRequest.originalURL absoluteString]lastPathComponent] isEqualToString:[fileInfo.fileURL lastPathComponent]])
        {
            if ([tempRequest isExecuting]&&isBeginDown) {
                return;
            }else if ([tempRequest isExecuting]&&!isBeginDown)
            {
                [tempRequest setUserInfo:[NSDictionary dictionaryWithObject:fileInfo forKey:@"File"]];
                [tempRequest cancel];
                [self.downloadDelegate updateCellProgress:tempRequest];
                return;
            }
        }
    }
    
    [self saveDownloadFile:fileInfo];
    
    //NSLog(@"targetPath %@",fileInfo.targetPath);
    //According to the file name to get access to the temporary file size, the size has been downloaded
    
    fileInfo.isFirstReceived=YES;
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSData *fileData=[fileManager contentsAtPath:fileInfo.tempPath];
    NSInteger receivedDataLength=[fileData length];
    fileInfo.fileReceivedSize=[NSString stringWithFormat:@"%d",receivedDataLength];
    
    NSLog(@"start down::Have downloaded：%@",fileInfo.fileReceivedSize);
    // [self limitMaxLines];
    ASIHTTPRequest *request=[[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:fileInfo.fileURL]];
    request.delegate=self;
    [request setDownloadDestinationPath:[fileInfo targetPath]];
    [request setTemporaryFileDownloadPath:fileInfo.tempPath];
    [request setDownloadProgressDelegate:self];
    [request setNumberOfTimesToRetryOnTimeout:2];
    // [request setShouldContinueWhenAppEntersBackground:YES];
    //    [request setDownloadProgressDelegate:downCell.progress];
    //Set the progress bar agents here because the download is carried out globally in AppDelegate where to download, so there is no progress bar commission comes here himself set up a commission to update the UI
    [request setAllowResumeForFileDownloads:YES];//Support for HTTP
    
    
    [request setUserInfo:[NSDictionary dictionaryWithObject:fileInfo forKey:@"File"]];//Set the context of the basic information file
    [request setTimeOutSeconds:30.0f];
    if (isBeginDown) {
        [request startAsynchronous];
    }
    
    //If duplicate file download or pause, resume, put requests in the queue to delete and re-add
    BOOL exit = NO;
    for(ASIHTTPRequest *tempRequest in self.downinglist)
    {
        //  NSLog(@"!!!!---::%@",[tempRequest.url absoluteString]);
        if([[[tempRequest.url absoluteString]lastPathComponent] isEqualToString:[fileInfo.fileURL lastPathComponent] ])
        {
            [self.downinglist replaceObjectAtIndex:[_downinglist indexOfObject:tempRequest] withObject:request ];
            
            exit = YES;
            break;
        }
    }
    
    if (!exit) {
        
        [self.downinglist addObject:request];
        NSLog(@"EXIT!!!!---::%@",[request.url absoluteString]);
    }
    [self.downloadDelegate updateCellProgress:request];
    
}

-(void)resumeRequest:(ASIHTTPRequest *)request{
    NSInteger max = maxcount;
    FPTFileDownloadModel *fileInfo =  [request.userInfo objectForKey:@"File"];
    NSInteger downingcount =0;
    NSInteger indexmax =-1;
    for (FPTFileDownloadModel *file in _filelist) {
        if (file.isDownloading) {
            downingcount++;
            if (downingcount==max) {
                indexmax = [_filelist indexOfObject:file];
            }
        }
    }//At this point the number of downloads is the largest, and get the maximum position Index
    
    if (downingcount==max) {
        FPTFileDownloadModel *file  = [_filelist objectAtIndex:indexmax];
        if (file.isDownloading) {
            file.isDownloading = NO;
            file.willDownloading = YES;
        }
    } //Kill a process to make it into the waiting
    
    for (FPTFileDownloadModel *file in _filelist) {
        if ([file.fileName isEqualToString:fileInfo.fileName]) {
            file.isDownloading = YES;
            file.willDownloading = NO;
            file.error = NO;
        }
    }//Re-start the download
    [self startLoad];
}
-(void)stopRequest:(ASIHTTPRequest *)request{
    NSInteger max = maxcount;
    if([request isExecuting])
    {
        [request cancel];
    }
    FPTFileDownloadModel *fileInfo =  [request.userInfo objectForKey:@"File"];
    for (FPTFileDownloadModel *file in _filelist) {
        if ([file.fileName isEqualToString:fileInfo.fileName]) {
            file.isDownloading = NO;
            file.willDownloading = NO;
            break;
        }
    }
    NSInteger downingcount =0;
    
    for (FPTFileDownloadModel *file in _filelist) {
        if (file.isDownloading) {
            downingcount++;
        }
    }
    if (downingcount<max) {
        for (FPTFileDownloadModel *file in _filelist) {
            if (!file.isDownloading&&file.willDownloading){
                file.isDownloading = YES;
                file.willDownloading = NO;
                break;
            }
        }
    }
    
    [self startLoad];
    //    fileInfo.isDownloading = NO;
    //    fileInfo.willDownloading = NO;
    //    [request cancel];
    //    [self startWaitingRequest];
    
}
-(void)deleteRequest:(ASIHTTPRequest *)request{
    bool isexecuting = NO;
    if([request isExecuting])
    {
        [request cancel];
        isexecuting = YES;
    }
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSError *error;
    FPTFileDownloadModel *fileInfo=(FPTFileDownloadModel*)[request.userInfo objectForKey:@"File"];
    NSString *path=fileInfo.tempPath;
    // NSInteger index=[fileInfo.fileName rangeOfString:@"."].location;
    //    NSString *name=[fileInfo.fileName substringToIndex:index];
    //    NSString *configPath=[TEMPPATH stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.rtf",name]];
    NSString *configPath=[NSString stringWithFormat:@"%@.plist",path];
    [fileManager removeItemAtPath:path error:&error];
    [fileManager removeItemAtPath:configPath error:&error];
    // [self deleteImage:fileInfo];
    
    if(!error)
    {
        NSLog(@"%@",[error description]);
    }
    
    NSInteger delindex =-1;
    for (FPTFileDownloadModel *file in _filelist) {
        if ([file.fileName isEqualToString:fileInfo.fileName]) {
            delindex = [_filelist indexOfObject:file];
            break;
        }
    }
    if (delindex!=NSNotFound)
        [_filelist removeObjectAtIndex:delindex];
    
    [_downinglist removeObject:request];
    
    if (isexecuting) {
        // [self startWaitingRequest];
        [self startLoad];
    }
    self.count = [_filelist count];
}
-(void)clearAllFinished{
    [_finishedList removeAllObjects];
}
-(void)clearAllRquests{
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSError *error;
    for (ASIHTTPRequest *request in _downinglist) {
        if([request isExecuting])
            [request cancel];
        FPTFileDownloadModel *fileInfo=(FPTFileDownloadModel*)[request.userInfo objectForKey:@"File"];
        NSString *path=fileInfo.tempPath;;
        NSString *configPath=[NSString stringWithFormat:@"%@.plist",path];
        [fileManager removeItemAtPath:path error:&error];
        [fileManager removeItemAtPath:configPath error:&error];
        //  [self deleteImage:fileInfo];
        if(!error)
        {
            NSLog(@"%@",[error description]);
        }
        
    }
    [_downinglist removeAllObjects];
    [_filelist removeAllObjects];
}

-(FPTFileDownloadManager *)getTempfile:(NSString *)path{
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:path];
    FPTFileDownloadModel *file = [[FPTFileDownloadModel alloc]init];
    file.fileName = [dic objectForKey:@"filename"];
    file.fileType = [file.fileName pathExtension ];
    file.fileURL = [dic objectForKey:@"fileurl"];
    file.fileSize = [dic objectForKey:@"filesize"];
    file.fileReceivedSize= [dic objectForKey:@"filerecievesize"];
    self.basepath = [dic objectForKey:@"basepath"];
    self.TargetSubPath = [dic objectForKey:@"tarpath"];
    NSString*  path1= [CommonHelper getTargetPathWithBasepath:_basepath subpath:_TargetSubPath];
    path1 = [path1 stringByAppendingPathComponent:file.fileName];
    file.targetPath = path1;
    NSString *tempfilePath= [TEMPPATH stringByAppendingPathComponent: file.fileName];
    file.tempPath = tempfilePath;
    file.time = [dic objectForKey:@"time"];
    file.fileimage = [UIImage imageWithData:[dic objectForKey:@"fileimage"]];
    file.isDownloading=NO;
    file.isDownloading = NO;
    file.willDownloading = NO;
    // file.isFirstReceived = YES;
    file.error = NO;
    
    NSData *fileData=[[NSFileManager defaultManager ] contentsAtPath:file.tempPath];
    NSInteger receivedDataLength=[fileData length];
    file.fileReceivedSize=[NSString stringWithFormat:@"%d",receivedDataLength];
    return file;
    
    
}
-(void)loadTempfiles
{
    
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSError *error;
    NSArray *filelist=[fileManager contentsOfDirectoryAtPath:TEMPPATH error:&error];
    if(!error)
    {
        NSLog(@"%@",[error description]);
    }
    NSMutableArray *filearr = [[NSMutableArray alloc]init];
    for(NSString *file in filelist)
    {
        NSString *filetype = [file  pathExtension];
        if([filetype isEqualToString:@"plist"])
            [filearr addObject:[self getTempfile:[TEMPPATH stringByAppendingPathComponent:file]]];
    }
    
    NSArray* arr =  [self sortbyTime:(NSArray *)filearr];
    [_filelist addObjectsFromArray:arr];
    
    [self startLoad];
    //    for (FPTFileDownloadModel *tempFile in arr) {
    //        [self beginRequest:tempFile isBeginDown:NO];
    //    }
}

-(void)loadFinishedfiles
{
    NSString *document = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *plistPath = [[document stringByAppendingPathComponent:self.basepath]stringByAppendingPathComponent:@"finishPlist.plist"];
    if ([[NSFileManager defaultManager]fileExistsAtPath:plistPath]) {
        NSMutableArray *finishArr = [[NSMutableArray alloc]initWithContentsOfFile:plistPath];
        for (NSDictionary *dic in finishArr) {
            FPTFileDownloadModel *file = [[FPTFileDownloadModel alloc]init];
            file.fileName = [dic objectForKey:@"filename"];
            file.fileType = [file.fileName pathExtension ];
            file.fileSize = [dic objectForKey:@"filesize"];
            file.targetPath = [dic objectForKey:@"filepath"];
            file.time = [dic objectForKey:@"time"];
            file.fileimage = [UIImage imageWithData:[dic objectForKey:@"fileimage"]];
            [_finishedList addObject:file];
        }
        //self.finishedlist = finishArr;
    }
    //    else
    //        [[NSFileManager defaultManager]createFileAtPath:plistPath contents:nil attributes:nil];
    
}

-(void)saveFinishedFile{
    //[_finishedList addObject:file];
    if (_finishedList==nil) {
        return;
    }
    NSMutableArray *finishedinfo = [[NSMutableArray alloc]init];
    for (FPTFileDownloadModel *fileinfo in _finishedList) {
        NSData *imagedata =UIImagePNGRepresentation(fileinfo.fileimage);
        NSDictionary *filedic = [NSDictionary dictionaryWithObjectsAndKeys:fileinfo.fileName,@"filename",fileinfo.time,@"time",fileinfo.fileSize,@"filesize",fileinfo.targetPath,@"filepath",imagedata,@"fileimage", nil];
        [finishedinfo addObject:filedic];
    }
    NSString *document = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *plistPath = [[document stringByAppendingPathComponent:self.basepath]stringByAppendingPathComponent:@"finishPlist.plist"];
    if (![finishedinfo writeToFile:plistPath atomically:YES]) {
        NSLog(@"write plist fail");
    }
}
-(void)deleteFinishFile:(FPTFileDownloadModel *)selectFile{
    [_finishedList removeObject:selectFile];
    
}
#pragma mark -- 入口 --
-(void)downFileUrl:(NSString*)url
          filename:(NSString*)name

        filetarget:(NSString *)path
         fileimage:(UIImage *)image

{
    
    //Because it is re-download, then certainly the file has been downloaded, or temporary files are to keep, so check these two places exist deleted
    self.TargetSubPath = path;
    if (_fileInfo!=nil) {
        _fileInfo = nil;
    }
    _fileInfo = [[FPTFileDownloadModel alloc]init];
    _fileInfo.fileName = name;
    _fileInfo.fileURL = url;
    
    NSDate *myDate = [NSDate date];
    _fileInfo.time = [CommonHelper dateToString:myDate];
    // NSInteger index=[name rangeOfString:@"."].location;
    _fileInfo.fileType=[name pathExtension];
    path= [CommonHelper getTargetPathWithBasepath:_basepath subpath:path];
    path = [path stringByAppendingPathComponent:name];
    _fileInfo.targetPath = path ;
    self.fileImage = image;
    _fileInfo.fileimage = image;
    _fileInfo.isDownloading=YES;
    _fileInfo.willDownloading = YES;
    _fileInfo.error = NO;
    _fileInfo.isFirstReceived = YES;
    NSString *tempfilePath= [TEMPPATH stringByAppendingPathComponent: _fileInfo.fileName]  ;
    _fileInfo.tempPath = tempfilePath;
    
    if([CommonHelper isExistFile: _fileInfo.targetPath])// Have downloaded once the file
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Tips" message:@"This file has been downloaded, do you want to re-download?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Determine", nil];
        [alert show];
        return;
    }
    //    //Exists in the temporary folder
    tempfilePath =[tempfilePath stringByAppendingString:@".plist"];
    if([CommonHelper isExistFile:tempfilePath])
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Tips" message:@"The document has been in the download list，do you want to re-download？" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Determine", nil];
        [alert show];
        return;
    }
    
    // [self saveImage:_fileInfo :image];
    //Without the existence of files and temporary files, it is a new download
    [self.filelist addObject:_fileInfo];
    // [self beginRequest:_fileInfo isBeginDown:YES ];
    
    [self startLoad];
    if(self.VCdelegate!=nil && [self.VCdelegate respondsToSelector:@selector(allowNextRequest)])
    {
        [self.VCdelegate allowNextRequest];
    }else{
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Tips" message:@"The file is successfully added to the download queue" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
    return;
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==1)//OK button
    {
        
        NSFileManager *fileManager=[NSFileManager defaultManager];
        NSError *error;
        NSInteger delindex =-1;
        if([CommonHelper isExistFile:_fileInfo.targetPath])//The file has been downloaded once
        {
            if ([fileManager removeItemAtPath:_fileInfo.targetPath error:&error]!=YES) {
                
                NSLog(@"Delete file error:%@",[error localizedDescription]);
            }
            
            
        }else{
            for(ASIHTTPRequest *request in self.downinglist)
            {
                FPTFileDownloadModel *FPTFileDownloadModel=[request.userInfo objectForKey:@"File"];
                if([FPTFileDownloadModel.fileName isEqualToString:_fileInfo.fileName])
                {
                    //[self.downinglist removeObject:request];
                    if ([request isExecuting]) {
                        [request cancel];
                    }
                    delindex = [_downinglist indexOfObject:request];
                    //  [self deleteImage:FPTFileDownloadModel];
                    break;
                }
            }
            [_downinglist removeObjectAtIndex:delindex];
            
            for (FPTFileDownloadModel *file in _filelist) {
                if ([file.fileName isEqualToString:_fileInfo.fileName]) {
                    delindex = [_filelist indexOfObject:file];
                    break;
                }
            }
            [_filelist removeObjectAtIndex:delindex];
            //Exists in the temporary folder
            NSString * tempfilePath =[_fileInfo.tempPath stringByAppendingString:@".plist"];
            if([CommonHelper isExistFile:tempfilePath])
            {
                if ([fileManager removeItemAtPath:tempfilePath error:&error]!=YES) {
                    NSLog(@"Delete temporary file error:%@",[error localizedDescription]);
                }
                
            }
            if([CommonHelper isExistFile:_fileInfo.tempPath])
            {
                if ([fileManager removeItemAtPath:_fileInfo.tempPath error:&error]!=YES) {
                    NSLog(@"Delete temporary file error:%@",[error localizedDescription]);
                }
            }
            
        }
        //    [self saveImage:_fileInfo :_fileImage];
        
        self.fileInfo.fileReceivedSize=[CommonHelper getFileSizeString:@"0"];
        [_filelist addObject:_fileInfo];
        // [self beginRequest:self.fileInfo isBeginDown:YES ];
        [self startLoad];
        //        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Tips" message:@"The document has been added to your download list it!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        //        [alert show];
        
    }
    if(self.VCdelegate!=nil && [self.VCdelegate respondsToSelector:@selector(allowNextRequest)])
    {
        [self.VCdelegate allowNextRequest];
    }
}
-(void)startLoad{
    /*Three states download, download, and wait for the download, stop downloading
     Download: isDownloading = YES; willDownloading = NO;
     Wait for the download: isDownloading = NO; willDownloading = YES;
     Stop downloading: isDownloading = NO; willDownloading = NO;
     
     Add time to sort all tasks.
     */
    
    NSInteger num = 0;
    NSInteger max = maxcount;
    for (FPTFileDownloadModel *file in _filelist) {
        if (!file.error) {
            if (file.isDownloading==YES) {
                file.willDownloading = NO;
                
                if (num>=max) {
                    file.isDownloading = NO;
                    file.willDownloading = YES;
                }else
                    num++;
                
            }
        }
    }
    if (num<max) {
        for (FPTFileDownloadModel *file in _filelist) {
            if (!file.error) {
                if (!file.isDownloading&&file.willDownloading) {
                    num++;
                    if (num>max) {
                        break;
                    }
                    file.isDownloading = YES;
                    file.willDownloading = NO;
                }
            }
        }
        
    }
    for (FPTFileDownloadModel *file in _filelist) {
        if (!file.error) {
            if (file.isDownloading==YES) {
                [self beginRequest:file isBeginDown:YES];
            }else
                [self beginRequest:file isBeginDown:NO];
        }
    }
    self.count = [_filelist count];
}

#pragma mark -- init methods --
-(id)initWithBasepath:(NSString *)basepath
        TargetPathArr:(NSArray *)targetpaths{
    self.basepath = basepath;
    _targetPathArray = [[NSMutableArray alloc]initWithArray:targetpaths];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString * Max= [userDefaults valueForKey:@"kMaxRequestCount"];
    if (Max==nil) {
        [userDefaults setObject:[NSString stringWithFormat:@"%i",MAXDOWNLOAD] forKey:@"kMaxRequestCount"];
        Max = [NSString stringWithFormat:@"%i",MAXDOWNLOAD];
    }
    [userDefaults synchronize];
    maxcount = [Max integerValue];
    _filelist = [[NSMutableArray alloc]init];
    _downinglist=[[NSMutableArray alloc] init];
    _finishedList = [[NSMutableArray alloc] init];
    self.isFistLoadSound=YES;
    return  [self init];
}

- (id)init
{
	self = [super init];
	if (self != nil) {
        self.count = 0;
        if (self.basepath!=nil) {
            [self loadFinishedfiles];
            [self loadTempfiles];
            
        }
        
    }
	return self;
}
-(void)cleanLastInfo{
    for (ASIHTTPRequest *request in _downinglist) {
        if([request isExecuting])
            [request cancel];
    }
    [self saveFinishedFile];
    [_downinglist removeAllObjects];
    [_finishedList removeAllObjects];
    [_filelist removeAllObjects];
    
}
+(FPTFileDownloadManager *) sharedFPTFileDownloadManagerWithBasepath:(NSString *)basepath
                                         TargetPathArr:(NSArray *)targetpaths{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedFPTFileDownloadManager = [[self alloc] initWithBasepath: basepath  TargetPathArr:targetpaths];
    });
    
    if (![sharedFPTFileDownloadManager.basepath isEqualToString:basepath]) {
        
        [sharedFPTFileDownloadManager cleanLastInfo];
        sharedFPTFileDownloadManager.basepath = basepath;
        [sharedFPTFileDownloadManager loadTempfiles];
        [sharedFPTFileDownloadManager loadFinishedfiles];
    }
    sharedFPTFileDownloadManager.basepath = basepath;
    sharedFPTFileDownloadManager.targetPathArray =[NSMutableArray arrayWithArray:targetpaths];
    return  sharedFPTFileDownloadManager;
}

+(FPTFileDownloadManager *) sharedFPTFileDownloadManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedFPTFileDownloadManager = [[self alloc] init];
    });
    return  sharedFPTFileDownloadManager;
}
+(id) allocWithZone:(NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
            sharedFPTFileDownloadManager = [super allocWithZone:zone];
    });
    return  sharedFPTFileDownloadManager;
}
- (void)dealloc
{
    [_targetPathArray removeAllObjects];
    _downloadCompleteSound = nil;
    _buttonSound = nil;
    [_finishedList removeAllObjects];
    _downloadDelegate = nil;
    [_downinglist removeAllObjects];
    [_filelist removeAllObjects];
    _fileInfo  = nil;
    _fileImage = nil;
    _VCdelegate = nil;
}

#pragma mark - ASIHttpRequest callback delegate -
// Error, if it is waiting for a timeout, then continue to download
-(void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error=[request error];
    NSLog(@"ASIHttpRequest出错了!%@",error);
    if (error.code==4) {
        return;
    }
    if ([request isExecuting]) {
        [request cancel];
    }
    FPTFileDownloadModel *fileInfo =  [request.userInfo objectForKey:@"File"];
    fileInfo.isDownloading = NO;
    fileInfo.willDownloading = NO;
    fileInfo.error = YES;
    for (FPTFileDownloadModel *file in _filelist) {
        if ([file.fileName isEqualToString:fileInfo.fileName]) {
            file.isDownloading = NO;
            file.willDownloading = NO;
            file.error = YES;
        }
    }
    [self.downloadDelegate updateCellProgress:request];
}

-(void)requestStarted:(ASIHTTPRequest *)request
{
    NSLog(@"Here we go!");
}

-(void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders
{
    NSLog(@"Received a reply!");
    
    FPTFileDownloadModel *fileInfo=[request.userInfo objectForKey:@"File"];
    
    NSString *len = [responseHeaders objectForKey:@"Content-Length"];//
    // NSLog(@"%@,%@,%@",fileInfo.fileSize,fileInfo.fileReceivedSize,len);
    // This message header, the total size of the received first, then the size of the received HTTP was certainly less than or equal to the first value, it is ignored
    if ([fileInfo.fileSize longLongValue]> [len longLongValue])
    {
        return;
    }
    
    fileInfo.fileSize = [NSString stringWithFormat:@"%lld",  [len longLongValue]];
    [self saveDownloadFile:fileInfo];
    
}


-(void)request:(ASIHTTPRequest *)request didReceiveBytes:(long long)bytes
{
    FPTFileDownloadModel *fileInfo=[request.userInfo objectForKey:@"File"];
    NSLog(@"%@,%lld",fileInfo.fileReceivedSize,bytes);
    if (fileInfo.isFirstReceived) {
        fileInfo.isFirstReceived=NO;
        fileInfo.fileReceivedSize =[NSString stringWithFormat:@"%lld",bytes];
    }
    else if(!fileInfo.isFirstReceived)
    {
        
        fileInfo.fileReceivedSize=[NSString stringWithFormat:@"%lld",[fileInfo.fileReceivedSize longLongValue]+bytes];
    }
    
    if([self.downloadDelegate respondsToSelector:@selector(updateCellProgress:)])
    {
        [self.downloadDelegate updateCellProgress:request];
    }
    
}

// The request ASIHttpRequest being downloaded file is removed from the queue and delete its configuration file, and then add the file has been downloaded to the target list
-(void)requestFinished:(ASIHTTPRequest *)request
{
    [self playDownloadSound];
    FPTFileDownloadModel *fileInfo=(FPTFileDownloadModel *)[request.userInfo objectForKey:@"File"];
    
    [_finishedList addObject:fileInfo];
    NSString *configPath=[fileInfo.tempPath stringByAppendingString:@".plist"];
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSError *error;
    if([fileManager fileExistsAtPath:configPath])// If there is a temporary file configuration file
    {
        [fileManager removeItemAtPath:configPath error:&error];
        if(!error)
        {
            NSLog(@"%@",[error description]);
        }
    }
    
    
    //    NSInteger delindex;
    //    for (FPTFileDownloadModel *file in _filelist) {
    //        if ([file.fileName isEqualToString:fileInfo.fileName]) {
    //            delindex = [_filelist indexOfObject:file];
    //            break;
    //        }
    //    }
    //    [_filelist removeObjectAtIndex:delindex];
    [_filelist removeObject:fileInfo];
    [_downinglist removeObject:request];
    [self saveFinishedFile];
    [self startLoad];
    
    if([self.downloadDelegate respondsToSelector:@selector(finishedDownload:)])
    {
        [self.downloadDelegate finishedDownload:request];
    }
}
//-(BOOL) respondsToSelector:(SEL)aSelector {
//    printf("SELECTOR: %s\n", [NSStringFromSelector(aSelector) UTF8String]);
//    return [super respondsToSelector:aSelector];
//}
@end
