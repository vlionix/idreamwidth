//
//  DWProtocol.m
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
//  * Neither the name of iDreamwidth, Xerxes Botkin, nor the
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

#import "DWProtocol.h"

#import <CommonCrypto/CommonDigest.h>

#import "iDreamwidthAppDelegate.h"



@implementation DWProtocol

- (id)init {
    if (self = [super init]) {
        networkQueue = [[ASINetworkQueue alloc] init];
        [networkQueue setShouldCancelAllRequestsOnFailure:NO];
        [networkQueue go];
        queue = [[Queue alloc] init];
        dwFlatURL = [[NSURL alloc] initWithString:@"http://www.dreamwidth.org/interface/flat"];
        monthNumDict = [[NSDictionary alloc] initWithObjectsAndKeys:@"01",@"Jan",@"02",@"Feb",
                        @"03",@"Mar",@"04",@"Apr",@"05",@"May",@"06",@"Jun",
                        @"07",@"Jul",@"08",@"Aug",@"09",@"Sep",@"10",@"Oct",
                        @"11", @"Nov",@"12", @"Dec",nil];
        userPicsDL = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc {
    [networkQueue release];
    [queue release];
    [dwFlatURL release];
    [monthNumDict release];
    [userPicsDL release];
    [super dealloc];
}

+ (NSString *)md5:(NSString *)str {
    const char *cString = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cString, strlen(cString), result);
    NSString *md5 = [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                     result[0], result[1], result[2], result[3],
                     result[4], result[5], result[6], result[7],
                     result[8], result[9], result[10], result[11],
                     result[12], result[13], result[14], result[15]];
    return md5;
}

+ (NSDictionary *)newDictionary:(NSString *)str {
    NSArray *results = [str componentsSeparatedByString:@"\n"];
    NSMutableArray *keys = [[NSMutableArray alloc] init];
    NSMutableArray *values = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [results count] - 1; i++) {
        if (i % 2 == 0) {
            [keys addObject:[results objectAtIndex:i]];
        } else {
            [values addObject:[results objectAtIndex:i]];
        }
    }
    
    NSDictionary *dict = [[NSDictionary alloc] initWithObjects:values forKeys:keys];
    [keys release];
    [values release];
    return dict;
}

+ (NSString *)reconvertUTF8String:(NSString *)str {
    NSData *uni = [str dataUsingEncoding:NSUnicodeStringEncoding];
    char convert[100];
    const char *unicode;
    char *converted = (char *)&convert;
    
    unicode = [uni bytes];
    
    int y = 0;
    int x = 2;
    int strLen = [str length];
    while (y < strLen && x < 100) {
        if (x % 2 == 0) {
            converted[y] = unicode[x];
            y++;
        }
        x++;
    }
    convert[y] = 0x00;
    
    NSString *convertedString = [[[NSString alloc] initWithUTF8String:converted] autorelease];
    return convertedString;
}

- (NSString *)reformatEntry:(NSString *)entry {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSString *entrySpace = [entry stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    NSString *entryUnicode = [entrySpace stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *entryBreak = [entryUnicode stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n"];
    NSString *entryQuote = [entryBreak stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    NSString *entryApos = [entryQuote stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
    NSString *entryLess = [entryApos stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    NSString *entryGreat = [entryLess stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    [entryGreat retain];
    [pool release];
    NSString *entryAmp = [entryGreat stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    [entryGreat release];
    return entryAmp;
}

// getChallenge

- (void)getChallenge {
    ASIFormDataRequest *req = [ASIFormDataRequest requestWithURL:dwFlatURL];
    [req setPostValue:@"getchallenge" forKey:@"mode"];
    [req setDidFinishSelector:@selector(challengeFinished:)];
    [req setDidFailSelector:@selector(challengeFailed:)];
    [req setDelegate:self];
    [self retain];
    [networkQueue addOperation:req];
}

- (void)challengeFinished:(ASIHTTPRequest *)request {
    NSString *responseString = [request responseString];
    // NSLog(@"%@", responseString);
    NSDictionary *dict = [DWProtocol newDictionary:responseString];
    
    NSString *success = [dict objectForKey:@"success"];
    
    if (success != nil && [success isEqualToString:@"OK"]) {
        ChallengeRequest *chalReq = [queue pop];
        ASIFormDataRequest *req = [chalReq request];
        NSString *username = [req.dwAccount username];
        NSString *password = [req.dwAccount password];
        
        NSString *response = [self getChallengeResponse:dict withPassword:password];
        
        [req addPostValue:username forKey:@"user"];
        [req addPostValue:@"challenge" forKey:@"auth_method"];
        [req addPostValue:[dict objectForKey:@"challenge"] forKey:@"auth_challenge"];
        [req addPostValue:response forKey:@"auth_response"];
        [req addPostValue:@"1" forKey:@"ver"];
        [networkQueue addOperation:req];
    }
    
    [dict release];
    [self release];
}

- (void)challengeFailed:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    NSLog(@"Error: challenge - %@", [error localizedDescription]);
    [self release];
}

- (NSString *)getChallengeResponse:(NSDictionary *)dict withPassword:(NSString *)password {
    NSString *challenge = [dict objectForKey:@"challenge"];
    
    // MD5 in library comes out upper case, while Dreamwidth requires lowercase to pass
    NSString *passwordHex = [DWProtocol md5:password];
    NSString *lowercasePassHex = [passwordHex lowercaseString];
    NSString *res = [NSString stringWithFormat:@"%@%@", challenge, lowercasePassHex];
    NSString *response = [DWProtocol md5:res];
    NSString *finalResponse = [response lowercaseString];
    
    return finalResponse;
}

// Check Friends

- (void)checkFriends:(DWAccount *)dwAcct lastUpdate:(NSString *)updateTime {
    ASIFormDataRequest *req = [ASIFormDataRequest requestWithURL:dwFlatURL];
    [req setPostValue:@"checkfriends" forKey:@"mode"];
    [req setPostValue:updateTime forKey:@"lastupdate"];
    // [req setPostValue:@"" forKey:@"mask"];
    
    // TODO - add mask support to limit to certain friend groups
    req.dwAccount = dwAcct;
    [req setDidFinishSelector:@selector(checkFriendsFinished:)];
    [req setDidFailSelector:@selector(checkFriendsFailed:)];
    [req setDelegate:self];
    
    // Add to the queue
    ChallengeRequest *challReq = [[ChallengeRequest alloc] initWithRequest:req];
    [queue push:challReq];
    [challReq release];
    [self retain];
    [self getChallenge];
}

- (void)checkFriendsFinished:(ASIHTTPRequest *)request {
    NSString *responseString = [request responseString];
    // NSLog(@"%@", responseString);
    NSDictionary *dict = [DWProtocol newDictionary:responseString];
    
    NSString *success = [dict objectForKey:@"success"];
    
    if (success != nil && [success isEqualToString:@"OK"]) {
        /*
        NSString *lastUpdate = [dict objectForKey:@"lastupdate"];
        NSString *new = [dict objectForKey:@"new"];
        NSString *interval = [dict objectForKey:@"interval"];
         */
        // TODO - Store lastUpdate to delegate
        // Have it so that a 1 in new turns off polling
        // interval - use to determine how often to poll (NEED OPTION TO TURN OFF TOO!)
    }
    
    [dict release];
    [self release];
}

- (void)checkFriendsFailed:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    NSLog(@"Error: checkFriends - %@", [error localizedDescription]);
    [self release];
}

// Console Command

- (void)consoleCommand:(DWAccount *)dwAcct {
    ASIFormDataRequest *req = [ASIFormDataRequest requestWithURL:dwFlatURL];
    [req setPostValue:@"consolecommand" forKey:@"mode"];
    
    req.dwAccount = dwAcct;
    [req setDidFinishSelector:@selector(consoleCommandFinished:)];
    [req setDidFailSelector:@selector(consoleCommandFailed:)];
    [req setDelegate:self];
    
    // Add to the queue
    ChallengeRequest *challReq = [[ChallengeRequest alloc] initWithRequest:req];
    [queue push:challReq];
    [challReq release];
    [self retain];
    
    [self getChallenge];
}

- (void)consoleCommandFinished:(ASIHTTPRequest *)request {
    NSString *responseString = [request responseString];
    // NSLog(@"%@", responseString);
    NSDictionary *dict = [DWProtocol newDictionary:responseString];
    
    NSString *success = [dict objectForKey:@"success"];
    
    if (success != nil && [success isEqualToString:@"OK"]) {
        // Nothing is returned if done correct
    } else if ([success isEqualToString:@"FAIL"]) {
        // Something went wrong - should update as some sort of notification
        NSString *errmsg = [dict objectForKey:@"errmsg"];
        NSLog(@"FAIL - consoleCommand - %@", errmsg);
        // TODO
    } else {
        // Utter defeat! Server error
        NSLog(@"Server Error - please try again later");
        // TODO
    }
    
    [dict release];
    [self release];
}

- (void)consoleCommandFailed:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    NSLog(@"Error: consoleCommand - %@", [error localizedDescription]);
    [self release];
}

// Edit Event

- (void)editEvent:(DWAccount *)dwAcct withPost:(DWPost *)post {
    ASIFormDataRequest *req = [ASIFormDataRequest requestWithURL:dwFlatURL];
    [req setPostValue:@"editevent" forKey:@"mode"];
    [req setPostValue:[NSNumber numberWithInt:[post itemID]] forKey:@"itemid"];
    [req setPostValue:[post subject] forKey:@"subject"];
    [req setPostValue:[post body] forKey:@"event"];
    [req setPostValue:@"unix" forKey:@"lineendings"];
    // [req setPostValue:@"" forKey:@"security"];
    // [req setPostValue:@"" forKey:@"allowmask"];
    
    // Meta-data
    // [req setPostValue:cords forKey:@"prop_current_coords"];
    [req setPostValue:[post location] forKey:@"prop_current_location"];
    
    if (![[post mood] isEqualToString:@""]) {
        [req setPostValue:[post mood] forKey:@"prop_current_mood"];
    }
    NSString *moodNum = [[NSString alloc] initWithFormat:@"%i", post.moodNum];
    [req setPostValue:moodNum forKey:@"prop_current_moodid"];
    [moodNum release];
    if (![[post music] isEqualToString:@""]) {
        [req setPostValue:[post music] forKey:@"prop_current_music"];
    }
    
    NSString *adultContentChoice;
    
    switch ([post adultContent]) {
        case 0:
            adultContentChoice = @"";
            break;
        case 1:
            adultContentChoice = @"none";
            break;
        case 2:
            adultContentChoice = @"concepts";
            break;
        case 3:
            adultContentChoice = @"explicit";
            break;
        default:
            adultContentChoice = @"";
            break;
    }
    
    [req setPostValue:adultContentChoice forKey:@"prop_adult_content"];
    
    if (![[post tags] isEqualToString:@""]) {
        [req setPostValue:[post tags] forKey:@"prop_taglist"];
    }
    
    switch ([post comments]) {
        case 1:
            // Comments disabled
            [req setPostValue:@"1" forKey:@"prop_opt_nocomments"];
            break;
        case 2:
            // No email for comments
            [req setPostValue:@"1" forKey:@"prop_opt_noemail"];
            break;
        default:
            break;
    }
    
    NSString *screening;
    
    switch ([post screen]) {
        case 1:
            // Disabled
            screening = @"N";
            break;
        case 2:
            // Anonymous Only
            screening = @"R";
            break;
        case 3:
            // Non-access list
            screening = @"F";
            break;
        case 4:
            // All Comments
            screening = @"A";
            break;
        default:
            // Journal Default
            screening = @"";
            break;
    }
    
    [req setPostValue:screening forKey:@"prop_opt_screening"];
    
    if (post.privatePost) {
        [req setPostValue:@"private" forKey:@"security"];
    }
    
    // [req setPostValue:@"true" forKey:@"prop_used_rte"];
    [req setPostValue:@"iDreamwidth" forKey:@"prop_useragent"];
    
    NSCharacterSet *dateChars = [NSCharacterSet characterSetWithCharactersInString:@"- :"];
    NSArray *dateParse = [post.date componentsSeparatedByCharactersInSet:dateChars];
    

    NSString *year = [dateParse objectAtIndex:0];
    [req setPostValue:year forKey:@"year"];
    
    NSString *month = [dateParse objectAtIndex:1];
    [req setPostValue:month forKey:@"mon"];
    
    NSString *day = [dateParse objectAtIndex:2];
    [req setPostValue:day forKey:@"day"];
    
    NSString *hour = [dateParse objectAtIndex:3];
    [req setPostValue:hour forKey:@"hour"];
    
    NSString *minute = [dateParse objectAtIndex:4];
    [req setPostValue:minute forKey:@"min"];
    
    // [req setPostValue:@"" forKey:@"prop_name"];
    [req setPostValue:post.community forKey:@"usejournal"];
    
    // TODO
    req.dwAccount = dwAcct;
    [req setDidFinishSelector:@selector(editEventFinished:)];
    [req setDidFailSelector:@selector(editEventFailed:)];
    [req setDelegate:self];
    
    // Add to the queue
    ChallengeRequest *challReq = [[ChallengeRequest alloc] initWithRequest:req];
    [queue push:challReq];
    [challReq release];
    [self retain];
    [self getChallenge];
}

- (void)editEventFinished:(ASIHTTPRequest *)request {
    NSString *responseString = [request responseString];
    // NSLog(@"%@", responseString);
    NSDictionary *dict = [DWProtocol newDictionary:responseString];
    
    NSString *success = [dict objectForKey:@"success"];
    
    if (success != nil && [success isEqualToString:@"OK"]) {
        NSLog(@"SUCCESS!");
        // TODO
    }
    
    [dict release];
    [self release];
}

- (void)editEventFailed:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    NSLog(@"Error: authEditEvent - %@", [error localizedDescription]);
    [self release];
}

// Edit Friend Groups

- (void)editFriendGroups:(DWAccount *)dwAcct {
    ASIFormDataRequest *req = [ASIFormDataRequest requestWithURL:dwFlatURL];
    [req setPostValue:@"editfriendgroups" forKey:@"mode"];
    
    // TODO
    req.dwAccount = dwAcct;
    [req setDidFinishSelector:@selector(editFriendGroupsFinished:)];
    [req setDidFailSelector:@selector(editFriendGroupsFailed:)];
    [req setDelegate:self];
    
    // Add to the queue
    ChallengeRequest *challReq = [[ChallengeRequest alloc] initWithRequest:req];
    [queue push:challReq];
    [challReq release];
    [self retain];
    [self getChallenge];
}

- (void)editFriendGroupsFinished:(ASIHTTPRequest *)request {
    NSString *responseString = [request responseString];
    // NSLog(@"%@", responseString);
    NSDictionary *dict = [DWProtocol newDictionary:responseString];
    
    NSString *success = [dict objectForKey:@"success"];
    
    if (success != nil && [success isEqualToString:@"OK"]) {
        NSLog(@"SUCCESS!");
    }
    
    [dict release];
    [self release];
}

- (void)editFriendGroupsFailed:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    NSLog(@"Error: authEditFriendGroups - %@", [error localizedDescription]);
    [self release];
}

// Edit Friends

- (void)editFriends:(DWAccount *)dwAcct {
    ASIFormDataRequest *req = [ASIFormDataRequest requestWithURL:dwFlatURL];
    [req setPostValue:@"editfriends" forKey:@"mode"];
    
    // TODO
    req.dwAccount = dwAcct;
    [req setDidFinishSelector:@selector(editFriendsFinished:)];
    [req setDidFailSelector:@selector(editFriendsFailed:)];
    [req setDelegate:self];
    
    // Add to the queue
    ChallengeRequest *challReq = [[ChallengeRequest alloc] initWithRequest:req];
    [queue push:challReq];
    [challReq release];
    [self retain];
    [self getChallenge];
}

- (void)editFriendsFinished:(ASIHTTPRequest *)request {
    NSString *responseString = [request responseString];
    // NSLog(@"%@", responseString);
    NSDictionary *dict = [DWProtocol newDictionary:responseString];
    
    NSString *success = [dict objectForKey:@"success"];
    
    if (success != nil && [success isEqualToString:@"OK"]) {
        NSLog(@"SUCCESS!");
    }
    
    [dict release];
    [self release];
}

- (void)editFriendsFailed:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    NSLog(@"Error: authEditFriends - %@", [error localizedDescription]);
    [self release];
}

// Friend Of

- (void)friendOf:(DWAccount *)dwAcct {
    ASIFormDataRequest *req = [ASIFormDataRequest requestWithURL:dwFlatURL];
    [req setPostValue:@"friendof" forKey:@"mode"];
    
    /*
     * Uncomment this in to limit number of friends returned
     */
    // [req setPostValue:@"10" forKey:@"friendoflimit"];
    
    // TODO
    req.dwAccount = dwAcct;
    [req setDidFinishSelector:@selector(friendOfFinished:)];
    [req setDidFailSelector:@selector(friendOfFailed:)];
    [req setDelegate:self];
    
    // Add to the queue
    ChallengeRequest *challReq = [[ChallengeRequest alloc] initWithRequest:req];
    [queue push:challReq];
    [challReq release];
    [self retain];
    [self getChallenge];
}

- (void)friendOfFinished:(ASIHTTPRequest *)request {
    NSString *responseString = [request responseString];
    // NSLog(@"%@", responseString);
    NSDictionary *dict = [DWProtocol newDictionary:responseString];
    
    NSString *success = [dict objectForKey:@"success"];
    
    if (success != nil && [success isEqualToString:@"OK"]) {
        // TODO
    }
    
    [dict release];
    [self release];
}

- (void)friendOfFailed:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    NSLog(@"Error: authFriendOf - %@", [error localizedDescription]);
    [self release];
}

// Get Day Counts

/**
 *  This mode retrieves the number of journal entries per day. 
 *  Useful for populating calendar widgets in GUI clients.
 */
- (void)getDayCounts:(DWAccount *)dwAcct {
    ASIFormDataRequest *req = [ASIFormDataRequest requestWithURL:dwFlatURL];
    [req setPostValue:@"getdaycounts" forKey:@"mode"];
    
    req.dwAccount = dwAcct;
    [req setDidFinishSelector:@selector(getDayCountsFinished:)];
    [req setDidFailSelector:@selector(getDayCountsFailed:)];
    [req setDelegate:self];
    
    // Add to the queue
    ChallengeRequest *challReq = [[ChallengeRequest alloc] initWithRequest:req];
    [queue push:challReq];
    [challReq release];
    [self retain];
    [self getChallenge];
}

- (void)getDayCounts:(DWAccount *)dwAcct forUser:(NSString *)user {
    ASIFormDataRequest *req = [ASIFormDataRequest requestWithURL:dwFlatURL];
    [req setPostValue:@"getdaycounts" forKey:@"mode"];
    [req setPostValue:user forKey:@"usejournal"];
    
    // TODO - figure out a way to hold username for details
    req.dwAccount = dwAcct;
    [req setDidFinishSelector:@selector(getDayCountsFinished:)];
    [req setDidFailSelector:@selector(getDayCountsFailed:)];
    [req setDelegate:self];
    
    // Add to the queue
    ChallengeRequest *challReq = [[ChallengeRequest alloc] initWithRequest:req];
    [queue push:challReq];
    [challReq release];
    [self retain];
    [self getChallenge];
}

- (void)getDayCountsFinished:(ASIHTTPRequest *)request {
    NSString *responseString = [request responseString];
    // NSLog(@"%@", responseString);
    NSDictionary *dict = [DWProtocol newDictionary:responseString];
    
    NSString *success = [dict objectForKey:@"success"];
    
    if (success != nil && [success isEqualToString:@"OK"]) {
        NSLog(@"SUCCESS!");
    }
    
    [dict release];
    [self release];
}

- (void)getDayCountsFailed:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    NSLog(@"Error: getDayCounts - %@", [error localizedDescription]);
    [self release];
}

// Get Events

- (void)getEvents:(DWAccount *)dwAcct {
    ASIFormDataRequest *req = [ASIFormDataRequest requestWithURL:dwFlatURL];
    [req setPostValue:@"getevents" forKey:@"mode"];
    // [req setPostValue:@"10" forKey:@"truncate"];
    [req setPostValue:@"0" forKey:@"prefersubject"];
    [req setPostValue:@"0" forKey:@"noprops"];
    [req setPostValue:@"lastn" forKey:@"selecttype"];
    [req setPostValue:@"" forKey:@"lastsync"];
    [req setPostValue:@"" forKey:@"year"];
    [req setPostValue:@"" forKey:@"month"];
    [req setPostValue:@"" forKey:@"day"];
    [req setPostValue:@"25" forKey:@"howmany"];
    [req setPostValue:@"-1" forKey:@"itemid"];
    [req setPostValue:@"unix" forKey:@"lineendings"];
    // [req setPostValue:@"" forKey:@"usejournal"];
    
    // TODO
    req.dwAccount = dwAcct;
    [req setDidFinishSelector:@selector(getEventsFinished:)];
    [req setDidFailSelector:@selector(getEventsFailed:)];
    [req setDelegate:self];
    
    // Add to the queue
    ChallengeRequest *challReq = [[ChallengeRequest alloc] initWithRequest:req];
    [queue push:challReq];
    [challReq release];
    [self retain];
    [self getChallenge];
}

- (void)getEventsFinished:(ASIHTTPRequest *)request {
    NSString *responseString = [request responseString];
    // NSLog(@"%@", responseString);
    NSDictionary *dict = [DWProtocol newDictionary:responseString];
    
    NSString *success = [dict objectForKey:@"success"];
    
    if (success != nil && [success isEqualToString:@"OK"]) {
        int eventCount = [[dict objectForKey:@"events_count"] intValue];
        NSMutableDictionary *propDicts = [[NSMutableDictionary alloc] init];
        
        int propCount = [[dict objectForKey:@"prop_count"] intValue];
        
        for (int i = 1; i <= propCount; i++) {
            NSString *propKeyID = [[NSString alloc] initWithFormat:@"prop_%i_itemid", i];
            NSString *propKeyName = [[NSString alloc] initWithFormat:@"prop_%i_name", i];
            NSString *propKeyValue = [[NSString alloc] initWithFormat:@"prop_%i_value", i];
            
            NSString *propIDStr = [dict objectForKey:propKeyID];
            NSString *propName = [dict objectForKey:propKeyName];
            NSString *propValue = [dict objectForKey:propKeyValue];
            
            [propKeyID release];
            [propKeyName release];
            [propKeyValue release];
            
            NSMutableDictionary *propDict = [propDicts objectForKey:propIDStr];
            if (propDict == nil) {
                NSMutableDictionary *newDict = [[NSMutableDictionary alloc] init];
                [propDicts setObject:newDict forKey:propIDStr];
                [newDict release];
                propDict = [propDicts objectForKey:propIDStr];
            }
            
            [propDict setObject:propValue forKey:propName];
        }
        
        // Create the DWPost objects from the entries
        iDreamwidthAppDelegate *appDelegate = (iDreamwidthAppDelegate *)[[UIApplication sharedApplication] delegate];
        NSMutableArray *newJournal = [[NSMutableArray alloc] initWithCapacity:5];
        
        for (int i = 1; i <= eventCount; i++) {
            DWPost *newPost = [[DWPost alloc] init];
            
            NSString *subjectKey = [[NSString alloc] initWithFormat:@"events_%i_subject", i];
            NSString *subject = [dict objectForKey:subjectKey];
            
            NSString *convertedString = [DWProtocol reconvertUTF8String:subject];
            
            newPost.subject = convertedString;
            [subjectKey release];
            
            NSString *bodyKey = [[NSString alloc] initWithFormat:@"events_%i_event", i];
            NSString *body = [dict objectForKey:bodyKey];
            body = [self reformatEntry:body];
            newPost.body = body;
            [bodyKey release];
            
            NSString *dateKey = [[NSString alloc] initWithFormat:@"events_%i_eventtime", i];
            newPost.date = [dict objectForKey:dateKey];
            [dateKey release];
            
            NSString *itemIDKey = [[NSString alloc] initWithFormat:@"events_%i_itemid", i];
            newPost.itemID = [[dict objectForKey:itemIDKey] intValue];
            [itemIDKey release];
            
            NSString *itemIDReformat = [[NSString alloc] initWithFormat:@"%i", newPost.itemID];
            
            // Prop additions
            NSMutableDictionary *propDict = [propDicts objectForKey:itemIDReformat];
            [itemIDReformat release];
            
            
            if (propDict != nil) {
                NSString *location = [propDict objectForKey:@"current_location"];
                if (location != nil) {
                    newPost.location = location;
                }
                
                NSString *music = [propDict objectForKey:@"current_music"];
                if (music != nil) {
                    newPost.music = music;
                }
                
                NSString *mood = [propDict objectForKey:@"current_mood"];
                if (mood != nil) {
                    newPost.mood = mood;
                }
                
                NSString *moodID = [propDict objectForKey:@"current_moodid"];
                if (moodID != nil) {
                    newPost.moodNum = [moodID intValue];
                }
                
                NSString *tags = [propDict objectForKey:@"taglist"];
                if (tags != nil) {
                    newPost.tags = tags;
                }
                
                NSString *adultContent = [propDict objectForKey:@"adult_content"];
                if (adultContent != nil) {
                    if ([adultContent isEqualToString:@"none"]) {
                        newPost.adultContent = 1;
                    } else if ([adultContent isEqualToString:@"concepts"]) {
                        newPost.adultContent = 2;
                    } else if ([adultContent isEqualToString:@"explicit"]) {
                        newPost.adultContent = 3;
                    }
                }
                
                NSString *noComment = [propDict objectForKey:@"opt_nocomments"];
                if (noComment != nil) {
                    switch ([noComment intValue]) {
                        case 1:
                            newPost.comments = 1;
                            break;
                        default:
                            break;
                    }
                }
                
                NSString *noEmail = [propDict objectForKey:@"opt_noemail"];
                if (noEmail != nil) {
                    switch ([noComment intValue]) {
                        case 1:
                            newPost.comments = 2;
                            break;
                        default:
                            break;
                    }
                }
                
                NSString *screen = [propDict objectForKey:@"opt_screening"];
                if (screen != nil) {
                    if ([screen isEqualToString:@"N"]) {
                        newPost.screen = 1;
                    } else if ([screen isEqualToString:@"R"]) {
                        newPost.screen = 2;
                    } else if ([screen isEqualToString:@"F"]) {
                        newPost.screen = 3;
                    } else if ([screen isEqualToString:@"A"]) {
                        newPost.screen = 4;
                    }
                }
            }
            
            newPost.accountNum = request.dwAccount.accountNum;
            newPost.journalNum = i-1;
            
            // EDIT THIS
            newPost.communityNum = 0;
            newPost.community = [request.dwAccount.postToArray objectAtIndex:newPost.communityNum];
            
            [newJournal addObject:newPost];
            [newPost release];
        }
        [propDicts release];
        
        appDelegate.journalArray = newJournal;
        [newJournal release];
        [appDelegate updateJournal:self];
    }
    
    [dict release];
    [self release];
}

- (void)getEventsFailed:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    NSLog(@"Error: getEvents - %@", [error localizedDescription]);
    [self release];
}

// Get Friend Groups

- (void)getFriendGroups:(DWAccount *)dwAcct {
    ASIFormDataRequest *req = [ASIFormDataRequest requestWithURL:dwFlatURL];
    [req setPostValue:@"getfriendgroups" forKey:@"mode"];
    
    // TODO
    req.dwAccount = dwAcct;
    [req setDidFinishSelector:@selector(getFriendGroupsFinished:)];
    [req setDidFailSelector:@selector(getFriendGroupsFailed:)];
    [req setDelegate:self];
    
    // Add to the queue
    ChallengeRequest *challReq = [[ChallengeRequest alloc] initWithRequest:req];
    [queue push:challReq];
    [challReq release];
    [self retain];
    [self getChallenge];
}

- (void)getFriendGroupsFinished:(ASIHTTPRequest *)request {
    NSString *responseString = [request responseString];
    // NSLog(@"%@", responseString);
    NSDictionary *dict = [DWProtocol newDictionary:responseString];
    
    NSString *success = [dict objectForKey:@"success"];
    
    if (success != nil && [success isEqualToString:@"OK"]) {
        NSLog(@"SUCCESS!");
    }
    
    [dict release];
    [self release];
}

- (void)getFriendGroupsFailed:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    NSLog(@"Error: getFriendGroups - %@", [error localizedDescription]);
    [self release];
}

// Get Friends

- (void)getFriends:(DWAccount *)dwAcct {
    ASIFormDataRequest *req = [ASIFormDataRequest requestWithURL:dwFlatURL];
    [req setPostValue:@"getfriends" forKey:@"mode"];
    
    // TODO
    req.dwAccount = dwAcct;
    [req setDidFinishSelector:@selector(getFriendsFinished:)];
    [req setDidFailSelector:@selector(getFriendsFailed:)];
    [req setDelegate:self];
    
    // Add to the queue
    ChallengeRequest *challReq = [[ChallengeRequest alloc] initWithRequest:req];
    [queue push:challReq];
    [challReq release];
    [self retain];
    [self getChallenge];
}

- (void)getFriendsFinished:(ASIHTTPRequest *)request {
    NSString *responseString = [request responseString];
    // NSLog(@"%@", responseString);
    NSDictionary *dict = [DWProtocol newDictionary:responseString];
    
    NSString *success = [dict objectForKey:@"success"];
    
    if (success != nil && [success isEqualToString:@"OK"]) {
        NSLog(@"SUCCESS!");
    }
    
    [dict release];
    [self release];
}

- (void)getFriendsFailed:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    NSLog(@"Error: getFriends - %@", [error localizedDescription]);
    [self release];
}

// Get User Tags

- (void)getUserTags:(DWAccount *)dwAcct {
    ASIFormDataRequest *req = [ASIFormDataRequest requestWithURL:dwFlatURL];
    [req setPostValue:@"getusertags" forKey:@"mode"];
    
    // TODO
    req.dwAccount = dwAcct;
    [req setDidFinishSelector:@selector(getUserTagsFinished:)];
    [req setDidFailSelector:@selector(getUserTagsFailed:)];
    [req setDelegate:self];
    
    // Add to the queue
    ChallengeRequest *challReq = [[ChallengeRequest alloc] initWithRequest:req];
    [queue push:challReq];
    [challReq release];
    [self retain];
    [self getChallenge];
}

- (void)getUserTagsFinished:(ASIHTTPRequest *)request {
    NSString *responseString = [request responseString];
    // NSLog(@"%@", responseString);
    NSDictionary *dict = [DWProtocol newDictionary:responseString];
    
    NSString *success = [dict objectForKey:@"success"];
    
    if (success != nil && [success isEqualToString:@"OK"]) {
        NSLog(@"SUCCESS!");
    }
    
    [dict release];
    [self release];
}

- (void)getUserTagsFailed:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    NSLog(@"Error: getUserTags - %@", [error localizedDescription]);
    [self release];
}

// Login

- (void)login:(DWAccount *)dwAcct {
    // TODO : edit this to conform to the rest
    ASIFormDataRequest *req = [ASIFormDataRequest requestWithURL:dwFlatURL];
    
    NSString *clientVersion = @"iPhone-iDW/0.1.0";
    
    [req addPostValue:@"login" forKey:@"mode"];
    [req addPostValue:clientVersion forKey:@"clientversion"];
    // [req addPostValue:@"0" forKey:@"getmoods"];
    // TODO
    [req addPostValue:@"1" forKey:@"getmenus"];
    
    req.dwAccount = dwAcct;
    [req setDidFinishSelector:@selector(loginFinished:)];
    [req setDidFailSelector:@selector(loginFailed:)];
    [req setDelegate:self];
    
    // Add to the queue
    ChallengeRequest *challReq = [[ChallengeRequest alloc] initWithRequest:req];
    [queue push:challReq];
    [challReq release];
    [self retain];
    [self getChallenge];
}

- (void)loginFinished:(ASIHTTPRequest *)request {
    NSString *responseString = [request responseString];
    NSDictionary *dict = [DWProtocol newDictionary:responseString];
    // NSLog(@"%@", responseString);
    
    NSString *success = [dict objectForKey:@"success"];
    DWAccount *acct = request.dwAccount;
    
    if (success != nil && [success isEqualToString:@"OK"]) {
        // Update postTo permissions
        int maxAccess = [(NSString *)[dict objectForKey:@"access_count"] intValue];
        NSMutableArray *newPostTo = [[NSMutableArray alloc] initWithCapacity:5];
        [newPostTo addObject:acct.username];
        
        for (int i = 1; i <= maxAccess; i++) {
            NSString *access = [[NSString alloc] initWithFormat:@"access_%i", i];
            NSString *postTo = [dict objectForKey:access];
            [newPostTo addObject:postTo];
            [access release];
        }
        
        NSArray *finalPostTo = [[NSArray alloc] initWithArray:newPostTo];
        acct.postToArray = finalPostTo;
        [finalPostTo release];
        [newPostTo release];
    } else if (success != nil && [success isEqualToString:@"FAIL"]) {
        NSString *errorToPrint;
        NSString *errmsg = [dict objectForKey:@"errmsg"];
        if ([errmsg isEqualToString:@"Invalid password"]) {
            errorToPrint = [[NSString alloc] initWithFormat:@"%@ for %@", errmsg, acct.username];
        } else {
            errorToPrint = errmsg;
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
                                                        message:errorToPrint
                                                       delegate:nil 
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
        
        if (errorToPrint != errmsg) {
            [errorToPrint release];
        }
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Server Error" 
                                                        message:@"Check your network settings & try again later"
                                                       delegate:nil 
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    
    [dict release];
    [self release];
}

- (void)loginFailed:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    NSLog(@"Error: login - %@", error);
    [self release];
}

// Post Event

- (void)postEvent:(DWAccount *)dwAcct withPost:(DWPost *)post {
    ASIFormDataRequest *req = [ASIFormDataRequest requestWithURL:dwFlatURL];
    [req setPostValue:@"postevent" forKey:@"mode"];
    [req setPostValue:[post subject] forKey:@"subject"];
    [req setPostValue:[post body] forKey:@"event"];
    [req setPostValue:@"unix" forKey:@"lineendings"];
    // [req setPostValue:@"" forKey:@"security"];
    // [req setPostValue:@"" forKey:@"allowmask"];
    
    // Meta-data
    // [req setPostValue:cords forKey:@"prop_current_coords"];
    [req setPostValue:[post location] forKey:@"prop_current_location"];
    
    if (![[post mood] isEqualToString:@""]) {
        [req setPostValue:[post mood] forKey:@"prop_current_mood"];
    }
    NSString *moodNum = [[NSString alloc] initWithFormat:@"%i", post.moodNum];
    [req setPostValue:moodNum forKey:@"prop_current_moodid"];
    [moodNum release];
    if (![[post music] isEqualToString:@""]) {
        [req setPostValue:[post music] forKey:@"prop_current_music"];
    }
    
    NSString *adultContentChoice;
    
    switch ([post adultContent]) {
        case 0:
            adultContentChoice = @"";
            break;
        case 1:
            adultContentChoice = @"none";
            break;
        case 2:
            adultContentChoice = @"concepts";
            break;
        case 3:
            adultContentChoice = @"explicit";
            break;
        default:
            adultContentChoice = @"";
            break;
    }
    
    [req setPostValue:adultContentChoice forKey:@"prop_adult_content"];
    
    if (![[post tags] isEqualToString:@""]) {
        [req setPostValue:[post tags] forKey:@"prop_taglist"];
    }
    
    switch ([post comments]) {
        case 1:
            // Comments disabled
            [req setPostValue:@"1" forKey:@"prop_opt_nocomments"];
            break;
        case 2:
            // No email for comments
            [req setPostValue:@"1" forKey:@"prop_opt_noemail"];
            break;
        default:
            break;
    }
    
    NSString *screening;
    
    switch ([post screen]) {
        case 1:
            // Disabled
            screening = @"N";
            break;
        case 2:
            // Anonymous Only
            screening = @"R";
            break;
        case 3:
            // Non-access list
            screening = @"F";
            break;
        case 4:
            // All Comments
            screening = @"A";
            break;
        default:
            // Journal Default
            screening = @"";
            break;
    }
    
    [req setPostValue:screening forKey:@"prop_opt_screening"];
    
    if (post.privatePost) {
        [req setPostValue:@"private" forKey:@"security"];
    }
    
    // [req setPostValue:@"true" forKey:@"prop_used_rte"];
    [req setPostValue:@"iDreamwidth" forKey:@"prop_useragent"];
    
    
    NSDate *currTime = [NSDate date];
    NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
    
    [timeFormat setDateFormat:@"yyyy"];
    NSString *year = [timeFormat stringFromDate:currTime];
    [req setPostValue:year forKey:@"year"];
    
    [timeFormat setDateFormat:@"MM"];
    NSString *month = [timeFormat stringFromDate:currTime];
    [req setPostValue:month forKey:@"mon"];
    
    [timeFormat setDateFormat:@"dd"];
    NSString *day = [timeFormat stringFromDate:currTime];
    [req setPostValue:day forKey:@"day"];
    
    [timeFormat setDateFormat:@"HH"];
    NSString *hour = [timeFormat stringFromDate:currTime];
    [req setPostValue:hour forKey:@"hour"];
    
    [timeFormat setDateFormat:@"mm"];
    NSString *minute = [timeFormat stringFromDate:currTime];
    [req setPostValue:minute forKey:@"min"];
    
    [timeFormat release];
    
    
    // [req setPostValue:@"" forKey:@"prop_name"];
    [req setPostValue:post.community forKey:@"usejournal"];
    
    // TODO
    req.dwAccount = dwAcct;
    [req setDidFinishSelector:@selector(postEventFinished:)];
    [req setDidFailSelector:@selector(postEventFailed:)];
    [req setDelegate:self];
    
    // Add to the queue
    ChallengeRequest *challReq = [[ChallengeRequest alloc] initWithRequest:req];
    [queue push:challReq];
    [challReq release];
    [self retain];
    [self getChallenge];
}

- (void)postEventFinished:(ASIHTTPRequest *)request {
    NSString *responseString = [request responseString];
    NSLog(@"%@", responseString);
    NSDictionary *dict = [DWProtocol newDictionary:responseString];
    
    NSString *success = [dict objectForKey:@"success"];
    
    if (success != nil && [success isEqualToString:@"OK"]) {
        // Remove the draft
        // TODO
    }
    
    [dict release];
    [self release];
}

- (void)postEventFailed:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    NSLog(@"Error: authPostEvent - %@", [error localizedDescription]);
    [self release];
}

// Session Expire

- (void)sessionExpire:(DWAccount *)dwAcct {
    ASIFormDataRequest *req = [ASIFormDataRequest requestWithURL:dwFlatURL];
    [req setPostValue:@"sessionexpire" forKey:@"mode"];
    
    // TODO
    req.dwAccount = dwAcct;
    [req setDidFinishSelector:@selector(sessionExpireFinished:)];
    [req setDidFailSelector:@selector(sessionExpireFailed:)];
    [req setDelegate:self];
    
    // Add to the queue
    ChallengeRequest *challReq = [[ChallengeRequest alloc] initWithRequest:req];
    [queue push:challReq];
    [challReq release];
    [self retain];
    [self getChallenge];
}

- (void)sessionExpireFinished:(ASIHTTPRequest *)request {
    NSString *responseString = [request responseString];
    // NSLog(@"%@", responseString);
    NSDictionary *dict = [DWProtocol newDictionary:responseString];
    
    NSString *success = [dict objectForKey:@"success"];
    
    if (success != nil && [success isEqualToString:@"OK"]) {
        NSLog(@"SUCCESS!");
    }
    
    [dict release];
    [self release];
}

- (void)sessionExpireFailed:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    NSLog(@"Error: authSessionExpire - %@", [error localizedDescription]);
    [self release];
}

// Session Generate

- (void)sessionGenerate:(DWAccount *)dwAcct {
    ASIFormDataRequest *req = [ASIFormDataRequest requestWithURL:dwFlatURL];
    [req setPostValue:@"sessiongenerate" forKey:@"mode"];
    [req setPostValue:@"short" forKey:@"expiration"];
    
    req.dwAccount = dwAcct;
    [req setDidFinishSelector:@selector(sessionGenerateFinished:)];
    [req setDidFailSelector:@selector(sessionGenerateFailed:)];
    [req setDelegate:self];
    
    // Add to the queue
    ChallengeRequest *challReq = [[ChallengeRequest alloc] initWithRequest:req];
    [queue push:challReq];
    [challReq release];
    [self retain];
    [self getChallenge];
}

- (void)sessionGenerateFinished:(ASIHTTPRequest *)request {
    NSString *responseString = [request responseString];
    // NSLog(@"%@", responseString);
    NSDictionary *dict = [DWProtocol newDictionary:responseString];
    
    
    NSString *success = [dict objectForKey:@"success"];
    
    if (success != nil && [success isEqualToString:@"OK"]) {
        NSLog(@"SUCCESS!");
        
        // Pulls the Reading Page - cookie not needed
        NSDictionary *cookDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  @"dreamwidth.org", NSHTTPCookieDomain,
                                  @"\\", NSHTTPCookiePath,
                                  @"ljsession", NSHTTPCookieName,
                                  [dict objectForKey:@"ljsession"], NSHTTPCookieValue, nil];
        NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookDict];
        
        NSURL *url = [NSURL URLWithString:@"http://i-xerxes.dreamwidth.org/read?format=light"];
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
        [ASIHTTPRequest addSessionCookie:cookie];
        [request setDelegate:self];
        [request startSynchronous];
        NSLog(@"%@", [request responseString]);
    }
    
    [dict release];
    [self release];
}

- (void)sessionGenerateFailed:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    NSLog(@"Error: authSessionGenerate - %@", [error localizedDescription]);
    [self release];
}

// Sync Items

- (void)syncItems:(DWAccount *)dwAcct {
    ASIFormDataRequest *req = [ASIFormDataRequest requestWithURL:dwFlatURL];
    [req setPostValue:@"syncitems" forKey:@"mode"];
    // [req setPostValue:@"" forKey:@"lastsync"];
    
    // TODO
    req.dwAccount = dwAcct;
    [req setDidFinishSelector:@selector(syncItemsFinished:)];
    [req setDidFailSelector:@selector(syncItemsFailed:)];
    [req setDelegate:self];
    
    // Add to the queue
    ChallengeRequest *challReq = [[ChallengeRequest alloc] initWithRequest:req];
    [queue push:challReq];
    [challReq release];
    [self retain];
    [self getChallenge];
}

- (void)syncItemsFinished:(ASIHTTPRequest *)request {
    NSString *responseString = [request responseString];
    // NSLog(@"%@", responseString);
    NSDictionary *dict = [DWProtocol newDictionary:responseString];
    
    NSString *success = [dict objectForKey:@"success"];
    
    if (success != nil && [success isEqualToString:@"OK"]) {
        NSLog(@"SUCCESS!");
    }
    
    [dict release];
    [self release];
}

- (void)syncItemsFailed:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    NSLog(@"Error: authSyncItems - %@", [error localizedDescription]);
    [self release];
}

- (void)downloadUserPic:(NSString *)username {
    // Dummy account for the userpic
    DWAccount *dummyUser = [[DWAccount alloc] initWithUsername:username withPassword:@"" withType:0];
    
    NSString *urlString = [[NSString alloc] initWithFormat:@"http://%@.dreamwidth.org/data/userpics", username];
    
    ASIHTTPRequest *req = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlString]];
    [urlString release];
    req.dwAccount = dummyUser;
    [req setTimeOutSeconds:40];
    [req setNumberOfTimesToRetryOnTimeout:1];
    [req setDidFinishSelector:@selector(downloadUserPicFinished:)];
    [req setDidFailSelector:@selector(downloadUserPicFailed:)];
    [req setDelegate:self];
    
    [dummyUser release];
    [self retain];
    
    [networkQueue addOperation:req];
}

- (void)downloadUserPicFinished:(ASIHTTPRequest *)request {
    NSString *response = [request responseString];
    
    NSArray *userPics = [response componentsSeparatedByString:@"<content src=\""];
    
    if ([userPics count] > 1) {
        // TODO - This is just grabbing first pic right now - switch to default later
        NSArray *defaultPic = [[userPics objectAtIndex:1] componentsSeparatedByString:@"\""];
        NSString *defaultPicURL = [[NSString alloc] initWithFormat:@"%@", [defaultPic objectAtIndex:0]];
        DWAccount *acct = request.dwAccount;
        [self downloadDefaultImage:acct withURL:defaultPicURL];
        [defaultPicURL release];
    }
    
    [self release];
}

- (void)downloadUserPicFailed:(ASIHTTPRequest *)request {
    NSLog(@"Failed to get userpic Atom feed for %@ - ", [request.dwAccount username], [[request error] localizedDescription]);
    [self release];
}

- (void)downloadDefaultImage:(DWAccount *)dwAcct withURL:(NSString *)url {
    // NSLog(@"%@", url);
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    request.dwAccount = dwAcct;
    [request setTimeOutSeconds:40];
    [request setNumberOfTimesToRetryOnTimeout:1];
    [request setDownloadDestinationPath:[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:dwAcct.username]];
    [request setDidFinishSelector:@selector(downloadDefaultImageFinished:)];
    [request setDidFailSelector:@selector(downloadDefaultImageFailed:)];
    [request setDelegate:self];
    
    [self retain];
    
    [networkQueue addOperation:request];
}

- (void)downloadDefaultImageFinished:(ASIHTTPRequest *)request {
    UIImage *userPic = [UIImage imageWithContentsOfFile:[request downloadDestinationPath]];
    iDreamwidthAppDelegate *appDelegate = (iDreamwidthAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *username = [[[request downloadDestinationPath] lastPathComponent] lowercaseString];
    [appDelegate.userPics setObject:userPic forKey:username];
    
    if (appDelegate.readingController != nil && appDelegate.readingController.tblView != nil) {
        [appDelegate.readingController.tblView reloadData];
    }
    
    [self release];
}

- (void)downloadDefaultImageFailed:(ASIHTTPRequest *)request {
    // Do nothing
    NSLog(@"Failed to find default image for %@", [request.dwAccount username]);
    [self release];
}

- (void)getReadingPageSubscriptions:(DWAccount *)dwAcct {
    NSString *url = [[NSString alloc] initWithFormat:@"http://www.dreamwidth.org/tools/opml.bml?user=%@", dwAcct.username];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    request.dwAccount = dwAcct;
    
    [request setDidFinishSelector:@selector(getReadingPageSubscriptionsFinished:)];
    [request setDidFailSelector:@selector(getReadingPageSubscriptionsFailed:)];
    [request setDelegate:self];
    
    [url release];
    [self retain];
    [networkQueue addOperation:request];
}

- (void)getReadingPageSubscriptionsFinished:(ASIHTTPRequest *)request {
    NSString *response = [request responseString];
    
    NSArray *subscripts = [response componentsSeparatedByString:@"<outline text=\""];
    NSMutableArray *rssFeeds = [[NSMutableArray alloc] initWithCapacity:10];
    
    if ([subscripts count] > 1) {
        for (int i = 1; i < [subscripts count]; i++) {
            NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
            
            NSArray *getXML = [[subscripts objectAtIndex:i] componentsSeparatedByString:@"xmlUrl=\""];
            NSArray *getXMLEnd = [[getXML objectAtIndex:1] componentsSeparatedByString:@"\" />"];
            
            NSString *xmlUrl = [[NSString alloc] initWithFormat:@"%@", [getXMLEnd objectAtIndex:0]];
            [rssFeeds addObject:xmlUrl];
            
            [pool release];
            [xmlUrl release];
        }
    }
    
    NSArray *finalSubscripts = [[NSArray alloc] initWithArray:rssFeeds];
    [rssFeeds release];
    request.dwAccount.subscriptionsArray = finalSubscripts;
    [finalSubscripts release];
    
    [self getRSSReading:request.dwAccount];
    [self release];
}

- (void)getReadingPageSubscriptionsFailed:(ASIHTTPRequest *) request {
    [self release];
}

- (void)getRSSReading:(DWAccount *)dwAcct {
    iDreamwidthAppDelegate *appDelegate = (iDreamwidthAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSMutableArray *loadArray = [[NSMutableArray alloc] initWithCapacity:40];
    appDelegate.readingLoadArray = loadArray;
    [loadArray release];
    
    for (int i = 0; i < [dwAcct.subscriptionsArray count]; i++) {
        NSString *rssUrl = [dwAcct.subscriptionsArray objectAtIndex:i];
        NSString *url = [[NSString alloc] initWithFormat:@"%@", rssUrl];
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
        [url release];
        request.dwAccount = dwAcct;
        
        [request setDidFinishSelector:@selector(getRSSReadingFinished:)];
        [request setDidFailSelector:@selector(getRSSReadingFailed:)];
        [request setDelegate:self];
        
        appDelegate.readingCount++;
        [self retain];
        [networkQueue addOperation:request];
    }
}

- (void)getRSSReadingFinished:(ASIHTTPRequest *)request {
    NSMutableString *response = [[NSMutableString alloc] initWithFormat:@"%@", [request responseString]];
    
    iDreamwidthAppDelegate *appDelegate = (iDreamwidthAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSRange journal = [response rangeOfString:@"<lj:journal>"];
    NSString *community = @"";
    if (journal.location != NSNotFound) {
        NSRange remove;
        remove.location = 0;
        remove.length = journal.location + journal.length;
        [response deleteCharactersInRange:remove];
        
        journal = [response rangeOfString:@"</lj:journal>"];
        community = [[NSString alloc] initWithFormat:@"%@", [response substringToIndex:journal.location]];
        remove.length = journal.location + journal.length;
        [response deleteCharactersInRange:remove];
    }
    
    NSArray *posts = [response componentsSeparatedByString:@"<item>"];
    [response release];
    int numOfPosts = [posts count];
    
    if (numOfPosts > 1) {
        for (int i = 1; i < [posts count]; i++) {
            NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
            
            DWPost *newPost = [[DWPost alloc] init];
            NSString *postURL;
            
            NSMutableString *postString = [[NSMutableString alloc] initWithFormat:@"%@", [posts objectAtIndex:i]];
            NSRange cutRange;
            cutRange.location = 0;
            
            // Parses the post's URL and saves the light format version
            NSRange urlTag = [postString rangeOfString:@"<guid isPermaLink='true'>"];
            if (urlTag.location != NSNotFound) {
                cutRange.length = urlTag.location + urlTag.length;
                [postString deleteCharactersInRange:cutRange];
                urlTag = [postString rangeOfString:@"</guid>"];
                postURL = [[NSString alloc] initWithFormat:@"%@?format=light", [postString substringToIndex:urlTag.location]];
                cutRange.length = urlTag.location + urlTag.length;
                [postString deleteCharactersInRange:cutRange];
            } else {
                postURL = [[NSString alloc] init];
            }
            newPost.url = postURL;
            
            // Parses date
            NSRange dateTag = [postString rangeOfString:@"<pubDate>"];
            if (dateTag.location != NSNotFound) {
                cutRange.length = dateTag.location + dateTag.length;
                [postString deleteCharactersInRange:cutRange];
                dateTag = [postString rangeOfString:@"</pubDate>"];
                
                NSString *unformatDate = [[NSString alloc] initWithFormat:@"%@", [postString substringToIndex:dateTag.location]];
                NSCharacterSet *splitters = [NSCharacterSet characterSetWithCharactersInString:@" :"];
                NSArray *splitDate = [unformatDate componentsSeparatedByCharactersInSet:splitters];
                NSString *year = [splitDate objectAtIndex:3];
                NSString *month = [monthNumDict objectForKey:[splitDate objectAtIndex:2]];
                NSString *day = [splitDate objectAtIndex:1];
                NSString *hour = [splitDate objectAtIndex:4];
                NSString *minute = [splitDate objectAtIndex:5];
                NSString *second = [splitDate objectAtIndex:6];
                NSString *formatedDate = [[NSString alloc] initWithFormat:@"%@-%@-%@ %@:%@:%@",
                                          year,month,day,hour,minute,second];
                newPost.date = formatedDate;
                [unformatDate release];
                [formatedDate release];
                
                cutRange.length = dateTag.location + dateTag.length;
                [postString deleteCharactersInRange:cutRange];
            } else {
                newPost.date = @"";
            }
            
            // Gets the title of the post
            NSRange titleTag = [postString rangeOfString:@"<title>"];
            if (titleTag.location != NSNotFound) {
                cutRange.length = titleTag.location + titleTag.length;
                [postString deleteCharactersInRange:cutRange];
                titleTag = [postString rangeOfString:@"</title>"];
                newPost.subject = [postString substringToIndex:titleTag.location];
                cutRange.length = titleTag.location + titleTag.length;
                [postString deleteCharactersInRange:cutRange];
            } else {
                newPost.subject = @"";
            }
            
            NSRange authorTag = [postString rangeOfString:@"<lj:poster>"];
            if (authorTag.location != NSNotFound) {
                cutRange.length = authorTag.location + authorTag.length;
                [postString deleteCharactersInRange:cutRange];
                authorTag = [postString rangeOfString:@"</lj:poster>"];
                newPost.author = [postString substringToIndex:authorTag.location];
                cutRange.length = authorTag.location + authorTag.length;
                [postString deleteCharactersInRange:cutRange];
            } else {
                newPost.author = community;
            }
            
            if ([appDelegate.userPics objectForKey:[newPost.author lowercaseString]] == nil
                && [userPicsDL objectForKey:newPost.author] == nil) {
                [self downloadUserPic:newPost.author];
                [userPicsDL setObject:@"1" forKey:newPost.author];
            }
            
            newPost.community = community;
            
            NSMutableArray *readingPage = appDelegate.readingLoadArray;
            
            [readingPage addObject:newPost];
            
            [pool release];
            [postString release];
            [postURL release];
            [newPost release];
        }
    }
    
    [community release];
    appDelegate.readingCount--;
    [appDelegate reloadReading:self];
    [self release];
}

- (void)getRSSReadingFailed:(ASIHTTPRequest *)request {
    [self release];
}

@end
