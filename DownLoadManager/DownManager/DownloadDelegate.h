//
//  DownloadDelegate.h


#import <Foundation/Foundation.h>
#import "AFDownloadRequestOperation.h"

@protocol DownloadDelegate <NSObject>

-(void)startDownload:(AFDownloadRequestOperation *)request;
-(void)updateCellProgress:(AFDownloadRequestOperation *)request;
-(void)finishedDownload:(AFDownloadRequestOperation *)request;
-(void)allowNextRequest;//Handle continuous download multiple files in one window and repeat downloading case
@end
