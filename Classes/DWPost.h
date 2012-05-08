//
//  DWPost.h
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

#import <Foundation/Foundation.h>

// DWPost corresponds to entry to Dreamwidth
@interface DWPost : NSObject<NSCoding> {
    NSString *subject;
    NSString *author;
    NSString *body;
    NSString *community;
    NSString *date;
    
    // Entry meta-data
    NSString *location;
    NSString *mood;
    NSString *music;
    NSString *tags;
    int adultContent;
    int comments;
    int screen;
    int moodNum;
    BOOL privatePost;
    
    NSString *url; // URL of the light version of the post
    UIWebView *lightPost; // light version of the post
    
    // (-1 if not in that array)
    int draftNum; // corresponds to position in App Delegate's draft array
    int journalNum; // corresponds to position in App Delegate's journal array
    int readNum; // corresponds to position in App Delegate's reading array
    
    int accountNum; // corresponds to position of account in App Delegate's accounts
    int communityNum; // corresponds to position of community in account's postTo
    
    int itemID;
}

// Caches a local copy of light format version of post
- (void)fetchLightPost:(id)sender;

@property(nonatomic,retain) NSString *subject;
@property(nonatomic,retain) NSString *author;
@property(nonatomic,retain) NSString *body;
@property(nonatomic,retain) NSString *location;
@property(nonatomic,retain) NSString *mood;
@property(nonatomic,retain) NSString *music;
@property(nonatomic,retain) NSString *tags;
@property(nonatomic,retain) NSString *community;
@property(nonatomic,retain) NSString *date;
@property(nonatomic,retain) NSString *url;
@property(nonatomic,retain) UIWebView *lightPost;
@property(nonatomic) int adultContent;
@property(nonatomic) int comments;
@property(nonatomic) int screen;
@property(nonatomic) BOOL privatePost;
@property(nonatomic) int moodNum;
@property(nonatomic) int draftNum;
@property(nonatomic) int journalNum;
@property(nonatomic) int readNum;
@property(nonatomic) int accountNum;
@property(nonatomic) int communityNum;
@property(nonatomic) int itemID;

@end
