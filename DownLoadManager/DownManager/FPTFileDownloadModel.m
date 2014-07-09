//
//  FPTFileDownloadModel.m
//  DownLoadManager
//
//  Created by TrongVM on 7/8/14.
//  Copyright (c) 2014 11 111. All rights reserved.
//

#import "FPTFileDownloadModel.h"

@implementation FPTFileDownloadModel

@synthesize fileID;
@synthesize fileName;
@synthesize fileSize;
@synthesize fileType;
@synthesize isFirstReceived;
@synthesize fileReceivedData;
@synthesize fileReceivedSize;
@synthesize fileURL;
@synthesize targetPath;
@synthesize tempPath;
@synthesize isDownloading;
@synthesize willDownloading;
@synthesize error;
@synthesize time;
@synthesize isP2P;
@synthesize post;
@synthesize PostPointer,postUrl,fileUploadSize;
@synthesize MD5,usrname,fileimage;
@synthesize downloadState;

-(id)init{
    self = [super init];
    
    return self;
}
-(void)dealloc{
    fileID = nil;
    fileName = nil;
    fileSize = nil;
    fileReceivedData = nil;
    fileURL = nil;
    time = nil;
    targetPath = nil;
    tempPath = nil;
    fileType = nil;
    postUrl = nil;
    fileUploadSize = nil;
    usrname = nil;
    MD5 = nil;
    fileimage = nil;
}
@end
