//
//  DWProtocol.h
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
#import "ASINetworkQueue.h"
#import "Queue.h"
#import "ChallengeRequest.h"
#import "DWPost.h"

// DWProtocol acts as the interface between the client and the server.  Handles the
// request for info as well as the parsing and updating of the info back to the App
// Delegate
@interface DWProtocol : NSObject {
    ASINetworkQueue *networkQueue; // Queue used for sending requests to server
    NSURL *dwFlatURL; // URL of the flat interface
    Queue *queue; // Local queue used for adding authentication information
    NSDictionary *monthNumDict; // maps month abbrev (keys) to month nums (values)
    NSMutableDictionary *userPicsDL; // maps usernames (keys) to user pics (values)
}

// Flat interface methods - sends and receives info from server and updates App Delegate
// See http://www.livejournal.com/doc/server/ljp.csp.flat.protocol.html for more info
- (void)checkFriends:(DWAccount *)dwAcct lastUpdate:(NSString *)updateTime;
- (void)consoleCommand:(DWAccount *)dwAcct;
- (void)editEvent:(DWAccount *)dwAcct withPost:(DWPost *)post;
- (void)editFriendGroups:(DWAccount *)dwAcct;
- (void)editFriends:(DWAccount *)dwAcct;
- (void)friendOf:(DWAccount *)dwAcct;
- (void)getDayCounts:(DWAccount *)dwAcct;
- (void)getEvents:(DWAccount *)dwAcct;
- (void)getFriendGroups:(DWAccount *)dwAcct;
- (void)getFriends:(DWAccount *)dwAcct;
- (void)getUserTags:(DWAccount *)dwAcct;
- (void)login:(DWAccount *)dwAcct;
- (void)postEvent:(DWAccount *)dwAcct withPost:(DWPost *)post;
- (void)sessionExpire:(DWAccount *)dwAcct;
- (void)sessionGenerate:(DWAccount *)dwAcct;
- (void)syncItems:(DWAccount *)dwAcct;

// Will download the user's default pic
- (void)downloadUserPic:(NSString *)username;

// Grabs the RSS feed URLs for the user's Reading Page and adds to 
// |dwAcct|'s |subscriptionsArray|
- (void)getReadingPageSubscriptions:(DWAccount *)dwAcct;

// Goes to RSS feed subscriptions and loads the posts in the feed
- (void)getRSSReading:(DWAccount *)dwAccount;

@end

// Private class methods
@interface DWProtocol()

// Used for creating MD5 of string |str|
+ (NSString *)md5:(NSString *)str;

// Given the response string from the servers, creates a dictionary with the names
// and values used for keys and values respectively
+ (NSDictionary *)newDictionary:(NSString *)str;

// Reconverts improper UTF8 to Unicode correctly; this is necessary for the responses
// from ASIHTTPRequest
+ (NSString *)reconvertUTF8String:(NSString *)str;

// Authenticates all flat protocol requests
- (NSString *)getChallengeResponse:(NSDictionary *)dict withPassword:(NSString *)password;

// Downloads the image given by |url| and adds to App Delegate's |userPics|
// This allows for us to know the user's default user pic and use it in the app
- (void)downloadDefaultImage:(DWAccount *)dwAcct withURL:(NSString *)url;

@end

