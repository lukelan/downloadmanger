//
//  CommonHelper.h


#import <Foundation/Foundation.h>

@interface CommonHelper : NSObject {
    
}

+(uint64_t)getFreeDiskspace;
+(uint64_t)getTotalDiskspace;
+(NSString *)getDiskSpaceInfo;
////M bytes into the unit, not with M
//+(NSString *)transformToM:(NSString *)size;
////M will not be converted into a string of bytes
//+(float)transformToBytes:(NSString *)size;
//The file size into M units or B units
+(NSString *)getFileSizeString:(NSString *)size;
//By file size without units ied into digital
+(float)getFileSizeNumber:(NSString *)size;
+(NSDate *)makeDate:(NSString *)birthday;
+(NSString *)dateToString:(NSDate*)date;
+(NSString *)getTempFolderPathWithBasepath:(NSString *)name;//Get the path to the temporary file storage folder
+(NSArray *)getTargetFloderPathWithBasepath:(NSString *)name subpatharr:(NSArray *)arr;
+(NSString *)getTargetPathWithBasepath:(NSString *)name subpath:(NSString *)subpath;
+(BOOL)isExistFile:(NSString *)fileName;//Check the file name exists
+(NSMutableArray *)getAllFinishFilesListWithPatharr:(NSArray *)patharr;
+ (NSString *)md5StringForData:(NSData*)data;
+ (NSString *)md5StringForString:(NSString*)str;
//The total size of the incoming file and the current size of the file to get the download progress
+(CGFloat) getProgress:(float)totalSize currentSize:(float)currentSize;


@end
