//
//  FPTFileDownloadManager.h
//  DownLoadManager
//
//  Created by TrongVM on 7/8/14.
//  Copyright (c) 2014 11 111. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonHelper.h"
#import "DownloadDelegate.h"
#import "AFDownloadRequestOperation.h"
#import <AVFoundation/AVAudioPlayer.h>

enum FPTFileDownloadState : NSUInteger {
    FPTFileDownloadStateUnknown = 0,
    FPTFileDownloadStateDownloading = 1,
    FPTFileDownloadStateWaiting = 2,
    FPTFileDownloadStateStopping = 3,
    FPTFileDownloadStateCompleted = 4,
    FPTFileDownloadStateError = 5
};

extern NSInteger  maxcount;

@interface FPTFileDownloadManager : NSObject
{
    NSInteger type;
    int count;
    int currentState;
}
@property(nonatomic,retain)UIImage *fileImage;
@property int count;
@property(nonatomic,retain)id<DownloadDelegate> VCdelegate;//Get download events vc, such as used in the post-election picture batch download multiple situations, when required to meet allowNextRequest protocol method
@property(nonatomic,retain)id<DownloadDelegate> downloadDelegate;///Download a list of delegate

@property(nonatomic,retain)NSString *basepath;
@property(nonatomic,retain)NSString *TargetSubPath;
@property(nonatomic,retain)NSMutableArray *finishedlist;//List file has finished downloading (file object)

@property(nonatomic,retain)NSMutableArray *downinglist;//Downloading a file list (ASIHttpRequest object)
@property(nonatomic,retain)NSMutableArray *downloadFiles;//Downloading a file list (ASIHttpRequest object)
@property(nonatomic,retain)NSMutableArray *filedownlist;

@property(nonatomic,retain)NSMutableArray *filelist;
@property(nonatomic,retain)NSMutableArray *targetPathArray;

@property(nonatomic,retain)AVAudioPlayer *buttonSound;

@property(nonatomic,retain)AVAudioPlayer *downloadCompleteSound;//The download is complete voice
@property(nonatomic,retain)NSDictionary *fileInfo;
@property(nonatomic)BOOL isFistLoadSound;//Is first loaded sounds, mute
//-(void)limitMaxLines;
//-(void)limitMaxCount;
//-(void)reload:(FPTFileDownloadModel *)fileInfo;
-(void)clearAllRquests;
-(void)clearAllFinished;
-(void)resumeRequest:(AFDownloadRequestOperation *)request;
-(void)deleteRequest:(AFDownloadRequestOperation *)request;
-(void)stopRequest:(AFDownloadRequestOperation *)request;
-(void)saveFinishedFile;
-(void)deleteFinishFile:(NSDictionary *)selectFile;
-(void)downFileUrl:(NSString*)url
          filename:(NSString*)name
        filetarget:(NSString *)path
         fileimage:(UIImage *)image
;
-(void)loadTempfiles;//Temporary files will be loaded locally are not downloaded to the download list, but do not then start the download
-(void)loadFinishedfiles;//The load local files have been downloaded to the completion of the downloaded list
-(id)initWithBasepath:(NSString *)basepath;
+(FPTFileDownloadManager *) sharedFPTFileDownloadManagerWithBasepath:(NSString *)basepath;
+(FPTFileDownloadManager *) sharedFPTFileDownloadManager;
// *** *** Initialization is first used to set the cache folder and use the downloaded folder, and build a list of downloaded files to download list
+(FPTFileDownloadManager *) sharedFPTFileDownloadManagerWithBasepath:(NSString *)basepath
                                         TargetPathArr:(NSArray *)targetpaths;
// 1. Click Baidu potatoes or download a request to conduct a new queue
// 2. Whether then start the download
-(void)beginRequest:(NSDictionary *)fileInfo isBeginDown:(BOOL)isBeginDown ;
-(void)startLoad;
-(void)restartAllRquests;


- (void)downloadFileUrl:(NSString *)urlStr fileName:(NSString *)name fileTarget:(NSString *)path fileIndex:(NSInteger)fileIndex;
- (void)downloadFileUrls:(NSArray *)urls fileTarget:(NSString *)path;

-(void)saveState;
-(void)loadState;
-(NSArray*) getDownloadingList;
-(NSArray*) getCompletedList;
@end

