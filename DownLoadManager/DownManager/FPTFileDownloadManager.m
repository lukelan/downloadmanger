//
//  FPTFileDownloadManager.m
//  DownLoadManager
//
//  Created by TrongVM on 7/8/14.
//  Copyright (c) 2014 11 111. All rights reserved.
//

#import "FPTFileDownloadManager.h"
#import "Reachability.h"
#import "AFDownloadRequestOperation.h"

#define MAXDOWNLOAD 20
#define MAXLINES  [[[NSUserDefaults standardUserDefaults] valueForKey:@"kMaxRequestCount"]integerValue]

//#define TEMPPATH [CommonHelper getTempFolderPathWithBasepath:_basepath]
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

//-(NSArray *)sortbyTime:(NSArray *)array{
//    NSArray *sorteArray1 = [array sortedArrayUsingComparator:^(id obj1, id obj2){
//        FPTFileDownloadModel *file1 = (FPTFileDownloadModel *)obj1;
//        FPTFileDownloadModel *file2 = (FPTFileDownloadModel *)obj2;
//        NSDate *date1 = [CommonHelper makeDate:file1.time];
//        NSDate *date2 = [CommonHelper makeDate:file2.time];
//        if ([[date1 earlierDate:date2]isEqualToDate:date2]) {
//            return (NSComparisonResult)NSOrderedDescending;
//        }
//        
//        if ([[date1 earlierDate:date2]isEqualToDate:date1]) {
//            return (NSComparisonResult)NSOrderedAscending;
//        }
//        
//        return (NSComparisonResult)NSOrderedSame;
//    }];
//    return sorteArray1;
//}
//-(NSArray *)sortRequestArrbyTime:(NSArray *)array{
//    NSArray *sorteArray1 = [array sortedArrayUsingComparator:^(id obj1, id obj2){
//        //
//        FPTFileDownloadModel* file1 =   [((ASIHTTPRequest *)obj1).userInfo objectForKey:@"File"];
//        FPTFileDownloadModel *file2 =   [((ASIHTTPRequest *)obj2).userInfo objectForKey:@"File"];
//        
//        NSDate *date1 = [CommonHelper makeDate:file1.time];
//        NSDate *date2 = [CommonHelper makeDate:file2.time];
//        if ([[date1 earlierDate:date2]isEqualToDate:date2]) {
//            return (NSComparisonResult)NSOrderedDescending;
//        }
//        
//        if ([[date1 earlierDate:date2]isEqualToDate:date1]) {
//            return (NSComparisonResult)NSOrderedAscending;
//        }
//        
//        return (NSComparisonResult)NSOrderedSame;
//    }];
//    return sorteArray1;
//}


//-(void)saveDownloadFile:(FPTFileDownloadModel*)fileinfo{
//    NSData *imagedata =UIImagePNGRepresentation(fileinfo.fileimage);
//    
//    NSDictionary *filedic = [NSDictionary dictionaryWithObjectsAndKeys:fileinfo.fileName,@"filename",fileinfo.fileURL,@"fileurl",fileinfo.time,@"time",_basepath,@"basepath",_TargetSubPath,@"tarpath" ,fileinfo.fileSize,@"filesize",fileinfo.fileReceivedSize,@"filerecievesize",imagedata,@"fileimage",nil];
//    
//    NSString *plistPath = [fileinfo.tempPath stringByAppendingPathExtension:@"plist"];
//    if (![filedic writeToFile:plistPath atomically:YES]) {
//        NSLog(@"write plist fail");
//    }
//}
-(void)beginRequest:(NSDictionary *)fileInfo isBeginDown:(BOOL)isBeginDown
{
    for(AFDownloadRequestOperation *tempRequest in _downinglist){
        /**
         Note that this interpretation is the same download method, asihttprequest three url:
         url, originalurl, redirectURL
         After practice, you should use originalurl, is the first to get to the original Download
         **/
        
        NSLog(@"%@",tempRequest.targetPath);
        NSDictionary *tempFile = [tempRequest.userInfo objectForKey:@"File"];
        if([[[tempFile objectForKey:@"fileURL"] lastPathComponent] isEqualToString:[[fileInfo objectForKey:@"fileURL"] lastPathComponent]]) {
            if ([tempRequest isExecuting]&&isBeginDown) {
                return;
            } else if ([tempRequest isExecuting]&&!isBeginDown) {
                [tempRequest setUserInfo:[NSDictionary dictionaryWithObject:fileInfo forKey:@"File"]];
                [tempRequest pause];
                [self.downloadDelegate updateCellProgress:tempRequest];
                return;
            } else if (![tempRequest isExecuting] && isBeginDown) {
                [tempRequest setUserInfo:[NSDictionary dictionaryWithObject:fileInfo forKey:@"File"]];
                [tempRequest resume];
                [self.downloadDelegate updateCellProgress:tempRequest];
                return;
            }
            return;
        }
    }
    
    //fileInfo.isFirstReceived = YES;
    
    NSURL *url = [NSURL URLWithString:[fileInfo objectForKey:@"fileURL"]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:3600];
    
    AFDownloadRequestOperation *operation = [[AFDownloadRequestOperation alloc] initWithRequest:request targetPath:[fileInfo objectForKey:@"targetPath"] shouldResume:YES];
    
    // Mosty we don't want delete temp file on cancel.
    operation.deleteTempFileOnCancel = NO;
    
    [_downinglist addObject:operation];
    
    [operation setUserInfo:[NSDictionary dictionaryWithObject:fileInfo forKey:@"File"]];
    
    [operation pause];
//    if (isBeginDown) {
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"Successfully downloaded file to %@", [fileInfo objectForKey:@"targetPath"] );
            
            NSDictionary *fileInfo=(NSDictionary *)[operation.userInfo objectForKey:@"File"];
            
            [fileInfo setValue:@(FPTFileDownloadStateCompleted) forKey:@"downloadState"];
            
            [self saveFile:fileInfo];
            
            [_finishedList addObject:fileInfo];
            [_downinglist removeObject:operation];
            [_filedownlist removeObject:[operation.userInfo objectForKey:@"File"]];
            [self startLoad];
            if([self.downloadDelegate respondsToSelector:@selector(finishedDownload:)])
            {
                [self.downloadDelegate finishedDownload:operation];
            }

            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            
            if (error.code==4) {
                return;
            }
            if ([operation isExecuting]) {
                [operation cancel];
            }
            
            NSDictionary *fileInfo =  [operation.userInfo objectForKey:@"File"];
            [fileInfo setValue:@(FPTFileDownloadStateError) forKey:@"downloadState"];
            [self saveFile:fileInfo];
            [self.downloadDelegate updateCellProgress:operation];

        }];
    
        [operation setProgressiveDownloadProgressBlock:^(AFDownloadRequestOperation *operation, NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile) {
            
            NSDictionary *fileInfo = [operation.userInfo objectForKey:@"File"];
            //NSLog(@"%@,%lld",fileInfo.fileReceivedSize,totalBytesReadForFile);
            if ([[fileInfo objectForKey:@"isFirstReceived"] boolValue]) {
                [fileInfo setValue:@(NO) forKey:@"isFirstReceived"];
                [fileInfo setValue:[NSString stringWithFormat:@"%lld",totalBytesReadForFile] forKey:@"fileReceivedSize"];
                [fileInfo setValue:[NSString stringWithFormat:@"%lld",totalBytesExpectedToReadForFile] forKey:@"fileSize"];
                [fileInfo setValue:operation.tempPath forKey:@"tempPath"];
                
            } else {
                [fileInfo setValue:[NSString stringWithFormat:@"%lld",totalBytesReadForFile] forKey:@"fileReceivedSize"];
                [fileInfo setValue:[NSString stringWithFormat:@"%lld",totalBytesExpectedToReadForFile] forKey:@"fileSize"];
            }
            
            if([self.downloadDelegate respondsToSelector:@selector(updateCellProgress:)])
            {
                [self.downloadDelegate updateCellProgress:operation];
            }

            // TODO: need to check so do not call requently to inscrease the peformance
            [self saveFile:fileInfo];
            //[self saveState];
            
            float percentDone = totalBytesReadForFile/(float)totalBytesExpectedToReadForFile;
            //
            //        self.progressView.progress = percentDone;
            //        self.progressLabel.text = [NSString stringWithFormat:@"%.0f%%",percentDone*100];
            //
            //        self.currentSizeLabel.text = [NSString stringWithFormat:@"CUR : %lli M",totalBytesReadForFile/1024/1024];
            //        self.totalSizeLabel.text = [NSString stringWithFormat:@"TOTAL : %lli M",totalBytesExpectedToReadForFile/1024/1024];
            //
            NSLog(@"------%f",percentDone);
            NSLog(@"Operation -----%@: bytesRead: %d", operation.targetPath, bytesRead);
            NSLog(@"Operation%i: totalBytesRead: %lld", 1, totalBytesRead);
            NSLog(@"Operation%i: totalBytesExpected: %lld", 1, totalBytesExpected);
            NSLog(@"Operation%i: totalBytesReadForFile: %lld", 1, totalBytesReadForFile);
            NSLog(@"Operation%i: totalBytesExpectedToReadForFile: %lld", 1, totalBytesExpectedToReadForFile);
        }];
        [operation start];
//    }
    if (!isBeginDown) {
        [operation pause];
    }
}

-(void)resumeRequest:(AFDownloadRequestOperation *)request{
    NSDictionary *fileInfo =  [request.userInfo objectForKey:@"File"];
    [fileInfo setValue:@(FPTFileDownloadStateDownloading) forKey:@"downloadState"];
    [self saveFile:fileInfo];
    [self startLoad];
}

-(void)stopRequest:(AFDownloadRequestOperation *)request {
    
    NSDictionary *fileInfo =  [request.userInfo objectForKey:@"File"];
    [request pause];
    
    //fileInfo.downloadState = FPTFileDownloadStateStopping;
    //[self saveState];
    [fileInfo setValue:@(FPTFileDownloadStateStopping) forKey:@"downloadState"];
    [self saveFile:fileInfo];
    [self startLoad];
}

-(void)deleteRequest:(AFDownloadRequestOperation *)request {
    
    NSDictionary *fileInfo =  [request.userInfo objectForKey:@"File"];
    [request cancel];
    
    [fileInfo setValue:@(FPTFileDownloadStateStopping) forKey:@"FPTFileDownloadStateUnknown"];
    
    [self deleteFile:fileInfo];
    
    [_filedownlist removeObject:fileInfo];
    [_finishedList removeObject:fileInfo];
    [_downinglist removeObject:request];
    //[self saveState];
    [self startLoad];
}

-(void)clearAllFinished{
    [_finishedList removeAllObjects];
}

-(void)clearAllRquests{
    
    for (AFDownloadRequestOperation* operation in _downinglist) {
        [operation cancel];
    }
    for (NSDictionary *fileInfo in _filedownlist) {
        [self deleteFile:fileInfo];
    }
    [_filedownlist removeAllObjects];
    [_downinglist removeAllObjects];
    [_finishedList removeAllObjects];
}

-(void)deleteFinishFile:(NSDictionary *)selectFile{
    [_finishedList removeObject:selectFile];
    [self deleteFile:selectFile];
}


#pragma mark -- download file --

- (void)downloadFileUrl:(NSString *)urlStr filename:(NSString *)name filetarget:(NSString *)path fileimage:(UIImage *)image {
    
    path= [CommonHelper getTargetPathWithBasepath:_basepath subpath:path];
    path = [path stringByAppendingPathComponent:name];
    
    //Because it is re-download, then certainly the file has been downloaded, or temporary files are to keep, so check these two places exist deleted
    self.TargetSubPath = path;
    if (_fileInfo!=nil) {
        _fileInfo = nil;
    }
    _fileInfo = [[NSMutableDictionary alloc]init];
    [_fileInfo setValue:name forKey:@"fileName"];
    [_fileInfo setValue:urlStr forKey:@"fileURL"];
    
    NSDate *myDate = [NSDate date];
    [_fileInfo setValue:[CommonHelper dateToString:myDate] forKey:@"time"];
    [_fileInfo setValue:[name pathExtension] forKey:@"fileType"];
    path = [CommonHelper getTargetPathWithBasepath:_basepath subpath:path];
    path = [path stringByAppendingPathComponent:name];
    [_fileInfo setValue:path forKey:@"targetPath"];
    [_fileInfo setValue:@(FPTFileDownloadStateWaiting) forKey:@"downloadState"];
    [_fileInfo setValue:@(NO) forKey:@"error"];
    [_fileInfo setValue:@(YES) forKey:@"isFirstReceived"];
//    NSString *tempfilePath= [TEMPPATH stringByAppendingPathComponent: [_fileInfo objectForKey:@"fileName"]]  ;
//    [_fileInfo setValue:tempfilePath forKey:@"tempPath"];
//    
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"targetPath == %@", [_fileInfo objectForKey:@"targetPath"]];
    NSArray *filteredArray = [_filedownlist filteredArrayUsingPredicate:predicate];
    NSDictionary *fileObject = [filteredArray firstObject];
    
    if (!fileObject) {
        predicate = [NSPredicate predicateWithFormat:@"targetPath == %@", [_fileInfo objectForKey:@"targetPath"]];
        filteredArray = [_finishedList filteredArrayUsingPredicate:predicate];
        fileObject = [filteredArray firstObject];
    }
    
    if (fileObject) {
        if ([[fileObject objectForKey:@"downloadState"] integerValue] == FPTFileDownloadStateCompleted) { // Have downloaded once the file
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Tips" message:@"This file has been downloaded, do you want to re-download?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Comfirm", nil];
            [alert show];
            return;
        } else {  //Exists in the temporary folder
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Tips" message:@"The document has been in the download list，do you want to re-download？" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm", nil];
            [alert show];
            return;
        }
    }
   
    //Without the existence of files and temporary files, it is a new download
    [_filedownlist addObject:_fileInfo];
    [self saveFile:_fileInfo];
    [self startLoad];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==1)//OK button
    {
        [self deleteFile:_fileInfo];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"targetPath == %@", [_fileInfo objectForKey:@"targetPath"]];
        NSArray *filteredArray = [_finishedList filteredArrayUsingPredicate:predicate];
        NSDictionary *fileObject = [filteredArray firstObject];
        if(fileObject) {
            [_finishedList removeObject:fileObject];
        }
        
        predicate = [NSPredicate predicateWithFormat:@"targetPath == %@", [_fileInfo objectForKey:@"targetPath"]];
        filteredArray = [_downinglist filteredArrayUsingPredicate:predicate];
        AFDownloadRequestOperation *operation = [filteredArray firstObject];
        [_downinglist removeObject:operation];
        
        
        predicate = [NSPredicate predicateWithFormat:@"targetPath == %@", [_fileInfo objectForKey:@"targetPath"]];
        filteredArray = [_filedownlist filteredArrayUsingPredicate:predicate];
        fileObject = [filteredArray firstObject];
        if(fileObject) {
            [_filedownlist removeObject:fileObject];
        }
        
        [_filedownlist addObject:_fileInfo];
        
        [self saveFile:_fileInfo];
        [self startLoad];

    }
    if(self.VCdelegate!=nil && [self.VCdelegate respondsToSelector:@selector(allowNextRequest)])
    {
        [self.VCdelegate allowNextRequest];
    }
}
-(void)startLoad {
    /*Three states download, download, and wait for the download, stop downloading
     Download: isDownloading = YES; willDownloading = NO;
     Wait for the download: isDownloading = NO; willDownloading = YES;
     Stop downloading: isDownloading = NO; willDownloading = NO;
     
     Add time to sort all tasks.
     */
    
//    NSInteger num = 0;
    NSInteger max = maxcount;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"downloadState == %i", FPTFileDownloadStateDownloading];
    NSArray *downloadingFiles = [_filedownlist filteredArrayUsingPredicate:predicate];
    
    if (downloadingFiles.count >= max) {
        
    } else {
        // start download extra files
        int numExtraDownload = max - downloadingFiles.count;
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"downloadState == %i", FPTFileDownloadStateWaiting];
        NSArray *stoppingFiles = [_filedownlist filteredArrayUsingPredicate:predicate];
        
        for (NSDictionary *file in stoppingFiles) {
            [file setValue:@(FPTFileDownloadStateDownloading) forKey:@"downloadState"];
            numExtraDownload --;
            if (numExtraDownload == 0) break;
        }
    }
    for (NSDictionary *file in _filedownlist) {
        if (![[file objectForKey:@"error"] boolValue]) {
            if ([[file objectForKey:@"downloadState"] integerValue] == FPTFileDownloadStateDownloading) {
                [self beginRequest:file isBeginDown:YES];
            } else if ([[file objectForKey:@"downloadState"] integerValue] == FPTFileDownloadStateStopping) {
                [self beginRequest:file isBeginDown:NO];
            }
        }
    }
    self.count = [_filedownlist count];
}

#pragma mark -- init methods --
    
-(id)initWithBasepath:(NSString *)basepath
        TargetPathArr:(NSArray *)targetpaths {
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
    _downloadFiles = [[NSMutableArray alloc] init];
    _filedownlist = [[NSMutableArray alloc] init];
    self.isFistLoadSound=YES;
    return  [self init];
}

- (id)init
{
	self = [super init];
	if (self != nil) {
        self.count = 0;
        if (self.basepath!=nil) {
            [self loadFiles];
            //[self loadFinishedfiles];
            //[self loadTempfiles];
            
        }
        
    }
	return self;
}
-(void)cleanLastInfo{
    for (ASIHTTPRequest *request in _downinglist) {
        if([request isExecuting])
            [request cancel];
    }
    [_downinglist removeAllObjects];
    [_finishedList removeAllObjects];
    [_filedownlist removeAllObjects];
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
        [sharedFPTFileDownloadManager loadFiles];
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

#pragma mark - NSData

- (void) deleteFile:(NSDictionary*)data
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* key = [NSString stringWithFormat:@"FILEINDICATOR-%@",[data objectForKey:@"fileURL"]];
    [defaults removeObjectForKey:key];
    
    NSFileManager *fileManager=[NSFileManager defaultManager];
    
    NSError *error;
    [fileManager removeItemAtPath:[data objectForKey:@"targetPath"] error:&error];
    [fileManager removeItemAtPath:[data objectForKey:@"tempPath"] error:&error];
    
    [defaults synchronize];
}


- (void) saveFile:(NSDictionary*)data
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* key = [NSString stringWithFormat:@"FILEINDICATOR-%@",[data objectForKey:@"fileURL"]];
    [defaults setObject:data forKey:key];
    [defaults synchronize];
}

- (NSDictionary*) loadFile:(NSString*)url
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* key = [NSString stringWithFormat:@"FILEINDICATOR-%@",url];
    return [defaults objectForKey:key];
}

- (NSMutableArray*) loadFiles
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *defaultAsDic = [defaults dictionaryRepresentation];
    NSArray *keyArr = [defaultAsDic allKeys];
    
    NSMutableArray *files = [NSMutableArray array];
    [_filedownlist removeAllObjects];
    [_finishedList removeAllObjects];
    for (NSString *key in keyArr)
    {
        NSLog(@"key [%@] => Value [%@]",key,[defaultAsDic valueForKey:key]);
        if ([key rangeOfString:@"FILEINDICATOR"].location != NSNotFound) {
            NSDictionary *fileInfo = [defaultAsDic valueForKey:key];
            if([[fileInfo objectForKey:@"downloadState"] integerValue] == FPTFileDownloadStateCompleted) {
                [_finishedList addObject:fileInfo];
            } else {
                [_filedownlist addObject:fileInfo];
            }
            
        }
    }
    return files;
}

@end
