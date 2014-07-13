//
//  ViewController.m
//  DownLoadManager
//
//  Created by chunyu.wang on 13-12-4.
//  Copyright (c) 2013年 11 111. All rights reserved.
//

#import "ViewController.h"
#include "FPTFileDownloadManager.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [FPTFileDownloadManager sharedFPTFileDownloadManagerWithBasepath:@"DownLoad" TargetPathArr:[NSArray arrayWithObject:@"DownLoad/mp3"]];
    NSArray *onlineBooksUrl = [NSArray arrayWithObjects:@"http://219.239.26.20/download/53546556/76795884/2/dmg/232/4/1383696088040_516/QQ_V3.0.1.dmg",
                               @"book",
                               @"http://free2.macx.cn:81/Tools/Office/UltraEdit-v4-0-0-7.dmg",
                               @"http://dldir1.qq.com/qqfile/tm/TM2013Preview1.exe",
                               @"http://dldir1.qq.com/invc/tt/QQBrowserSetup.exe",
                               @"http://dldir1.qq.com/music/clntupate/QQMusic_Setup_100.exe",
                               @"http://dl_dir.qq.com/invc/qqpinyin/QQPinyin_Setup_4.6.2028.400.exe",
                               @"https://github.com/oarrabi/Download-Manager/archive/master.zip",
                               @"https://github.com/square/SocketRocket/archive/master.zip",nil];
    NSArray *names = [NSArray arrayWithObjects:@"MacQQ", @"book",@"UltraEdit",@"TM2013",@"QQBrowser",@"QQMusic",@"QQPinyin",@"Download-Manager",@"SocketRocket",nil];
    
    downContentDatas = [[NSMutableArray alloc]initWithArray:names];
    downURLArr = [[NSArray alloc]initWithArray:onlineBooksUrl];

}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [downURLArr count];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"contentCell";     UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    // Configure the cell...
    //Add the following cell configuration, so that the display list data marked as "myCell" in the cell
    NSInteger row = [indexPath row];
    UILabel* lab = (UILabel*)[cell viewWithTag:10];
    lab.text = [downContentDatas objectAtIndex:row];
    UIButton *but = (UIButton*)[cell viewWithTag:11];
    [but setTag:row];
    [but addTarget:self action:@selector(ClickDownBut:) forControlEvents:UIControlEventTouchDown];
    return cell;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    _theTable = nil;
}
- (void)ClickDownBut:(UIButton *)sender {
    
    NSString* urlStr = [downURLArr objectAtIndex:sender.tag];
    NSString* name =  [downContentDatas objectAtIndex:sender.tag];
    NSLog(@"Url:%@,Name:%@",urlStr,name);
    
    
    // HARD CODED to download book
    if ([urlStr isEqualToString:@"book"]) {
        
        NSArray *bookLinks = [NSArray arrayWithObjects:@"https://s3.amazonaws.com/vongz/page/page1.zip",
                                   @"https://s3.amazonaws.com/vongz/page/page2.zip",
                                   @"https://s3.amazonaws.com/vongz/page/page3.zip",
                                   @"https://s3.amazonaws.com/vongz/page/page4.zip",
                                   @"https://s3.amazonaws.com/vongz/page/page5.zip",
                                   nil];

        
        [[FPTFileDownloadManager sharedFPTFileDownloadManager] downloadFileUrls:bookLinks fileTarget:name];
    } else {
        [[FPTFileDownloadManager sharedFPTFileDownloadManager] downloadFileUrl:urlStr fileName:name fileTarget:name fileIndex:0];
    }
    
//    [ [FPTFileDownloadManager sharedFPTFileDownloadManager]downFileUrl:urlStr filename:name filetarget:@"mp3" fileimage:nil];
}
@end
