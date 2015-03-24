//
//  LZThread.m
//  HiPDA
//
//  Created by leizh007 on 15/3/23.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "LZThread.h"

@interface LZThread()

@end

@implementation LZThread

/**
 *  初始化并设置LZThread
 *
 *  @param attributes fid(NSInteger),tid(NSString),title(NSString),user(LZUser),titleColor(UIColor),dateString(NSString),date(NSDate),
 *                    replyCount(NSInteger),openCount(NSInteger),pageCount(NSInteger),hasImage(BOOL),hasAttach(BOOL)
 *
 *  @return self
 */
-(id)initWithAttributes:(NSDictionary *)attributes{
    self=[super init];
    if (!self) {
        return nil;
    }
    NSNumber *fidNumber=[attributes objectForKey:@"fid"];
    self.fid=[fidNumber integerValue];
    self.tid=[attributes objectForKey:@"tid"];
    self.title=[attributes objectForKey:@"title"];
    self.user=[attributes objectForKey:@"user"];
    NSNumber *hasReadNumber=[attributes objectForKey:@"hasRead"];
    self.hasRead=[hasReadNumber boolValue];
    self.dateString=[attributes objectForKey:@"dateString"];
    self.date=[attributes objectForKey:@"date"];
    NSNumber *replyCountNumber=[attributes objectForKey:@"replyCount"];
    self.replyCount=[replyCountNumber integerValue];
    NSNumber *openCountNumber=[attributes objectForKey:@"openCount"];
    self.openCount=[openCountNumber integerValue];
    NSNumber *pageCountNumber=[attributes objectForKey:@"pageCountNumber"];
    self.pageCount=[pageCountNumber integerValue];
    NSNumber *hasImageNumber=[attributes objectForKey:@"hasImage"];
    self.hasImage=[hasImageNumber boolValue];
    NSNumber *hasAttachNumber=[attributes objectForKey:@"hasAttach"];
    self.hasAttach=[hasAttachNumber boolValue];
    return self;
}

#pragma mark - NSCoding
-(id)initWithCoder:(NSCoder *)aDecoder{
    self=[super init];
    if (!self) {
        return nil;
    }
    self.fid=[aDecoder decodeIntegerForKey:@"fid"];
    self.tid=[aDecoder decodeObjectForKey:@"tid"];
    self.title=[aDecoder decodeObjectForKey:@"title"];
    self.user=[aDecoder decodeObjectForKey:@"user"];
    self.hasRead=[aDecoder decodeBoolForKey:@"hasRead"];
    self.dateString=[aDecoder decodeObjectForKey:@"dateString"];
    self.date=[aDecoder decodeObjectForKey:@"date"];
    self.replyCount=[aDecoder decodeIntegerForKey:@"replyCount"];
    self.openCount=[aDecoder decodeIntegerForKey:@"openCount"];
    self.pageCount=[aDecoder decodeIntegerForKey:@"pageCount"];
    self.hasImage=[aDecoder decodeBoolForKey:@"hasImage"];
    self.hasAttach=[aDecoder decodeBoolForKey:@"hasAttach"];
    
    return nil;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeInteger:self.fid forKey:@"fid"];
    [aCoder encodeObject:self.tid forKey:@"tid"];
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.user forKey:@"user"];
    [aCoder encodeBool:self.hasRead forKey:@"hasRead"];
    [aCoder encodeObject:self.dateString forKey:@"dateString"];
    [aCoder encodeObject:self.date forKey:@"date"];
    [aCoder encodeInteger:self.replyCount forKey:@"replyCount"];
    [aCoder encodeInteger:self.openCount forKey:@"openCount"];
    [aCoder encodeInteger:self.pageCount forKey:@"pageCount"];
    [aCoder encodeBool:self.hasImage forKey:@"hasImage"];
    [aCoder encodeBool:self.hasAttach forKey:@"hasAttach"];
}

@end
