//
//  FPTFileDownloadModel.h
//  DownLoadManager
//
//  Created by TrongVM on 7/8/14.
//  Copyright (c) 2014 11 111. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"

enum FPTFileDownloadState : NSUInteger {
    FPTFileDownloadStateUnknown = 0,
    FPTFileDownloadStateDownload = 1,
    FPTFileDownloadStateWaiting = 2,
    FPTFileDownloadStateStop = 3,
};

@interface FPTFileDownloadModel : NSObject {
    
}

@property(nonatomic,retain)NSString *fileID;
@property(nonatomic,retain)NSString *fileName;
@property(nonatomic,retain)NSString *fileSize;
@property(nonatomic,retain)NSString *fileType; // File extension

@property(nonatomic)BOOL isFirstReceived;//Whether it is the first time to accept the data, if it is not the first time the cumulative length of the data returned, after cumulative change
@property(nonatomic,retain)NSString *fileReceivedSize;
@property(nonatomic,retain)NSMutableData *fileReceivedData;//Receiving data
@property(nonatomic,retain)NSString *fileURL;
@property(nonatomic,retain)NSString *time;
@property(nonatomic,retain)NSString *targetPath;
@property(nonatomic,retain)NSString *tempPath;
/*Download state logic is this: three states, download, and wait for the download, stop downloading
 Download: isDownloading = YES; willDownloading = NO;
 Wait for the download: isDownloading = NO; willDownloading = YES;
 Stop downloading: isDownloading = NO; willDownloading = NO;
 When it exceeds the maximum number of downloads, the download will continue to add into a wait state, when fewer than the maximum number of simultaneous downloads limit will automatically begin downloading the wait state task.
 You can download the active switching state
 Add time to sort all tasks.
 */
@property(nonatomic)BOOL isDownloading;
@property(nonatomic)BOOL  willDownloading;
@property(nonatomic)enum FPTFileDownloadState downloadState;

@property(nonatomic)BOOL error;
@property(nonatomic)BOOL isP2P;//Whether it is p2p download
@property BOOL post;
@property int PostPointer;
@property(nonatomic,retain)NSString *postUrl;
@property (nonatomic,retain)NSString *fileUploadSize;
@property(nonatomic,retain)NSString *usrname;
@property(nonatomic,retain)NSString *MD5;
@property(nonatomic,retain)UIImage *fileimage;

@end

