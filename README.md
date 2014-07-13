DownLoadManager
===============

Description: Multi-threaded download manager modules AFnetworking based support asynchronous downloads, pause and resume downloads and more. When you pause a download task, restore the download task again, do not download heavy head, but the place has been downloaded to start the download (ie breakpoints download). Specifically the following characteristics:

    1 Complete UI design can be directly used to use;

    2 asynchronous, background, multi-threaded (ASI provided);

    3The maximum number of settings while downloading;

    4 download task queue, pause, wait, continue, delete a download task;

    5 records downloaded and completed the unfinished task, and at the next boot loader;
     
    Note 1: Some download address is redirected, it will seriously affect the treatment effect of this program!

    The authors say: If you have questions, please email: vuminh.trong@gmail.com.



Tat ca link deu de trong File ViewController.m.
	
	- List Link
		NSArray *onlineBooksUr …
	- Book Link
		NSArray *bookLinks = [NSArray arrayWithObjects:@"https://s3.amazonaws.com/vongz/page/page1.zip",
                                   @"https://s3.amazonaws.com/vongz/page/page2.zip",
                                   @"https://s3.amazonaws.com/vongz/page/page3.zip",
                                   @"https://s3.amazonaws.com/vongz/page/page4.zip",
                                   @"https://s3.amazonaws.com/vongz/page/page5.zip",
                                   nil];

	Chu y: hien tai max download concurrent dang hard code la 20.

2) Integrate to tapco:
	
	+ Thu vien ben ngoai (3rd party): 
     - AFNetworking: Library nay minh co roi nen chi can check de update lai ban moi nhat, tong example co san ban moi nhat o “...DownLoadManager/AFNetworking/AFNetworking”

     - AFDownloadRequestOperation: Library nay mo rong cho AFnetworking. nam o “...DownLoadManager/AFNetworking/AFDownloadRequestOperation”

     - UIKit+AFNetworking (Optional).

	+ Download Manager: co tat ca 5 files nhu sau, chi can add 4 file nay vo la co the dung duoc.
		- CommonHelper.h
		- CommonHelper.m
		- FPTFileDownloadManager.h
		- FPTFileDownloadManager.m
		- DownloadDelegate.h: file nay chu nhung delegate, dung de nhan progress khi download va khi nap download song or bi loi. 


3) How to use:

	Download File:  

	- (void)downloadFileUrl:(NSString *)urlStr fileName:(NSString *)name fileTarget:(NSString *)path fileIndex:(NSInteger)fileIndex;

		urlStr: Link download tu server
		fileName: Ten file muon save trong local disk
		fileTarget: Ten folder chua filename
		fileIndex: Default la 0;

 	Download Book (list files) - (void)downloadFileUrls:(NSArray *)urls fileTarget:(NSString *)path;

		urls: List link download cho book
		fileTarget: Ten folder chua filename, filename tu dong lay tu link download

	
	
	Nhan status, progress thong qua nhung delegate sau:


	-(void)startDownload:(AFDownloadRequestOperation *)request;
	-(void)updateCellProgress:(AFDownloadRequestOperation *)request;
	-(void)finishedDownload:(AFDownloadRequestOperation *)request;
	
    Trong request tra ve co the lay duoc info cua file dang download .userInfo

	Thong tin tu userInfo la dictionary nhu sau:

{
    downloadState = 1;
    error = 0;
    fileIndex = 0;
    fileName = SocketRocket;
    fileReceivedSize = 6344;
    fileSize = “63440";
    fileTarget = SocketRocket;
    fileType = "";
    fileURL = "https://github.com/square/SocketRocket/archive/master.zip";
    isFirstReceived = 0;
    startSignal = 1;
    targetPath = "/Users/trongmv/Library/Application Support/iPhone Simulator/7.1/Applications/CC1A1C8A-3E6F-47BE-8030-FE725A9E43BB/Documents/DownLoad/SocketRocket/SocketRocket";
    tempPath = "/Users/trongmv/Library/Application Support/iPhone Simulator/7.1/Applications/CC1A1C8A-3E6F-47BE-8030-FE725A9E43BB/tmp/Incomplete/2f3c4aa2fa06690f2fd3b7d98ad1df20";
    time = "07-14 01:55:01";
}
	

	Download co cac status nhu sau:

enum FPTFileDownloadState : NSUInteger {
    FPTFileDownloadStateUnknown = 0,
    FPTFileDownloadStateDownloading = 1,
    FPTFileDownloadStateWaiting = 2,
    FPTFileDownloadStateStopping = 3,
    FPTFileDownloadStateCompleted = 4,
    FPTFileDownloadStateError = 5
};
