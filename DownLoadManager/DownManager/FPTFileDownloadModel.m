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

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.fileID = [aDecoder decodeObjectForKey:@"fileID"];
        self.fileName = [aDecoder decodeObjectForKey:@"fileName"];
        self.fileSize = [aDecoder decodeObjectForKey:@"fileSize"];
        self.fileType = [aDecoder decodeObjectForKey:@"fileType"];
        self.isFirstReceived = [aDecoder decodeBoolForKey:@"isFirstReceived"];
        self.fileURL = [aDecoder decodeObjectForKey:@"fileURL"];
        self.time = [aDecoder decodeObjectForKey:@"time"];
        self.targetPath = [aDecoder decodeObjectForKey:@"targetPath"];
        self.tempPath = [aDecoder decodeObjectForKey:@"tempPath"];
        self.downloadState = [aDecoder decodeIntegerForKey:@"downloadState"];
        self.error = [aDecoder decodeBoolForKey:@"error"];
        self.isP2P = [aDecoder decodeBoolForKey:@"isP2P"];
        self.PostPointer = [aDecoder decodeIntegerForKey:@"PostPointer"];
        self.postUrl = [aDecoder decodeObjectForKey:@"postUrl"];
        self.fileUploadSize = [aDecoder decodeObjectForKey:@"fileUploadSize"];
        self.usrname = [aDecoder decodeObjectForKey:@"usrname"];
        self.MD5 = [aDecoder decodeObjectForKey:@"MD5"];
        self.fileimage = [aDecoder decodeObjectForKey:@"fileimage"];
    }
    return self;
}
                       
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:@"fileID"];
    [aCoder encodeObject:@"fileName"];
    [aCoder encodeObject:@"fileSize"];
    [aCoder encodeObject:@"fileType"];
    [aCoder encodeObject:@"isFirstReceived"];
    [aCoder encodeObject:@"fileURL"];
    [aCoder encodeObject:@"time"];
    [aCoder encodeObject:@"targetPath"];
    [aCoder encodeObject:@"tempPath"];
    [aCoder encodeObject:@"downloadState"];
    [aCoder encodeObject:@"error"];
    [aCoder encodeObject:@"isP2P"];
    [aCoder encodeObject:@"PostPointer"];
    [aCoder encodeObject:@"postUrl"];
    [aCoder encodeObject:@"fileUploadSize"];
    [aCoder encodeObject:@"usrname"];
    [aCoder encodeObject:@"MD5"];
    [aCoder encodeObject:@"fileimage"];
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
