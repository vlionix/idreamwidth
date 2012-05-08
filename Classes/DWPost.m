//
//  DWPost.m
//  iDreamwidth
//
//  Copyright (c) 2010, Xerxes Botkin
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//  * Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
//  * Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in the
//    documentation and/or other materials provided with the distribution.
//  * Neither the name of iDreamwidth nor the
//    names of its contributors may be used to endorse or promote products
//    derived from this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL XERXES BOTKIN BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "DWPost.h"


@implementation DWPost

@synthesize subject;
@synthesize author;
@synthesize body;
@synthesize location;
@synthesize mood;
@synthesize music;
@synthesize adultContent;
@synthesize tags;
@synthesize comments;
@synthesize screen;
@synthesize community;
@synthesize date;
@synthesize url;
@synthesize lightPost;
@synthesize moodNum;
@synthesize privatePost;
@synthesize draftNum;
@synthesize journalNum;
@synthesize readNum;
@synthesize accountNum;
@synthesize communityNum;
@synthesize itemID;

- (id)init {
    if (self = [super init]) {
        subject = nil;
        author = nil;
        body = nil;
        location = nil;
        mood = nil;
        tags = nil;
        community = nil;
        date = nil;
        url = nil;
        
        adultContent = 0;
        comments = 0;
        screen = 0;
        moodNum = 0;
        draftNum = -1;
        journalNum = -1;
        readNum = -1;
        itemID = -1;
        
        lightPost = nil;
        privatePost = NO;
    }
    
    return self;
}

// initializes data structure from saved data
- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.subject = [aDecoder decodeObjectForKey:@"subject"];
        self.author = [aDecoder decodeObjectForKey:@"author"];
        self.body = [aDecoder decodeObjectForKey:@"body"];
        self.location = [aDecoder decodeObjectForKey:@"location"];
        self.mood = [aDecoder decodeObjectForKey:@"mood"];
        self.music = [aDecoder decodeObjectForKey:@"music"];
        self.tags = [aDecoder decodeObjectForKey:@"tags"];
        self.community = [aDecoder decodeObjectForKey:@"community"];
        self.date = [aDecoder decodeObjectForKey:@"date"];
        
        self.url = [aDecoder decodeObjectForKey:@"url"];
        
        self.moodNum = [aDecoder decodeIntForKey:@"moodNum"];
        self.comments = [aDecoder decodeIntForKey:@"comments"];
        self.screen = [aDecoder decodeIntForKey:@"screen"];
        self.privatePost = [aDecoder decodeBoolForKey:@"privatePost"];
        self.adultContent = [aDecoder decodeIntForKey:@"adultContent"];
        
        self.draftNum = [aDecoder decodeIntForKey:@"draftNum"];
        self.journalNum = [aDecoder decodeIntForKey:@"journalNum"];
        self.readNum = [aDecoder decodeIntForKey:@"readNum"];
        
        self.accountNum = [aDecoder decodeIntForKey:@"accountNum"];
        self.communityNum = [aDecoder decodeIntForKey:@"communityNum"];
        
        self.itemID = [aDecoder decodeIntForKey:@"itemID"];
    }
    
    [self fetchLightPost:self];
    
    return self;
}

// saves data structure
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:subject forKey:@"subject"];
    [aCoder encodeObject:author forKey:@"author"];
    [aCoder encodeObject:body forKey:@"body"];
    [aCoder encodeObject:location forKey:@"location"];
    [aCoder encodeObject:mood forKey:@"mood"];
    [aCoder encodeObject:music forKey:@"music"];
    [aCoder encodeObject:tags forKey:@"tags"];
    [aCoder encodeObject:community forKey:@"community"];
    [aCoder encodeObject:date forKey:@"date"];
    
    [aCoder encodeObject:url forKey:@"url"];
    
    [aCoder encodeInt:moodNum forKey:@"moodNum"];
    [aCoder encodeInt:comments forKey:@"comments"];
    [aCoder encodeInt:screen forKey:@"screen"];
    [aCoder encodeBool:privatePost forKey:@"privatePost"];
    [aCoder encodeInt:adultContent forKey:@"adultContent"];
    
    [aCoder encodeInt:draftNum forKey:@"draftNum"];
    [aCoder encodeInt:journalNum forKey:@"journalNum"];
    [aCoder encodeInt:readNum forKey:@"readNum"];
    
    [aCoder encodeInt:accountNum forKey:@"accountNum"];
    [aCoder encodeInt:communityNum forKey:@"communityNum"];
    
    [aCoder encodeInt:itemID forKey:@"itemID"];
}

// Not currently in use
- (void)fetchLightPost:(id)sender {
    // TODO
    /*
    UIWebView *webView = [[UIWebView alloc] init];
    NSURL *lightPostURL = [NSURL URLWithString:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:lightPostURL];
    self.lightPost = webView;
    [webView release];
    [lightPost loadRequest:request];
     */
}

- (NSComparisonResult)comparePost:(DWPost *)post2 {
    return (NSComparisonResult)[(NSString *)[post2 date] localizedCaseInsensitiveCompare:(NSString *)[self date]];
}

- (void)dealloc {
    [subject release];
    [author release];
    [body release];
    [location release];
    [mood release];
    [music release];
    [tags release];
    [community release];
    [date release];
    [url release];
    [super dealloc];
}

@end
