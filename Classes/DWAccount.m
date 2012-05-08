//
//  DWAccount.m
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

#import "DWAccount.h"

#import "iDreamwidthAppDelegate.h"
#import "SFHFKeychainUtils.h"

@implementation DWAccount

@synthesize username;
@synthesize password;
@synthesize accountNum;
@synthesize accountType;
@synthesize postToArray;
@synthesize subscriptionsArray;

- (id)initWithUsername:(NSString *)user withPassword:(NSString *)pass withType:(int)type {
    if (self = [super init]) {
        self.username = user;
        self.password = pass;
        self.accountType = type;
        NSArray *postTo = [[NSArray alloc] initWithObjects:user, nil];
        self.postToArray = postTo;
        self.subscriptionsArray = nil;
        [postTo release];
    }
    
    return self;
}

// Used for loading a data structure from a previous save
- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        iDreamwidthAppDelegate *appDelegate = (iDreamwidthAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        self.username = [aDecoder decodeObjectForKey:@"username"];
        self.postToArray = [aDecoder decodeObjectForKey:@"postToArray"];
        
        self.accountNum = [aDecoder decodeIntForKey:@"accountNum"];
        self.accountType = [aDecoder decodeIntForKey:@"accountType"];
        
        // Retrieve password from keychain
        NSError *error;
        NSString *serviceName = [[NSString alloc] initWithFormat:@"iDreamwidth.%@", [appDelegate.accountsType objectAtIndex:accountType]];
        self.password = [SFHFKeychainUtils getPasswordForUsername:username 
                                                   andServiceName:serviceName 
                                                            error:&error];
        [serviceName release];
    }
    
    return self;
}

// Used for saving the data structure
- (void)encodeWithCoder:(NSCoder *)aCoder {
    iDreamwidthAppDelegate *appDelegate = (iDreamwidthAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [aCoder encodeObject:username forKey:@"username"];
    [aCoder encodeObject:postToArray forKey:@"postToArray"];
    [aCoder encodeObject:subscriptionsArray forKey:@"subscriptionsArray"];
    
    [aCoder encodeInt:accountNum forKey:@"accountNum"];
    [aCoder encodeInt:accountType forKey:@"accountType"];
    
    // Encode password in keychain
    NSError *error;
    NSString *serviceName = [[NSString alloc] initWithFormat:@"iDreamwidth.%@", [appDelegate.accountsType objectAtIndex:accountType]];
    [SFHFKeychainUtils storeUsername:self.username 
                         andPassword:self.password 
                      forServiceName:serviceName 
                      updateExisting:YES 
                               error:&error];
    [serviceName release];
}

- (void)update:(id)sender {
    [self updatePostTo:self];
    [self updateSubscriptions:self];
}

- (void)updatePostTo:(id)sender {
    // Updates the PostTo list
    iDreamwidthAppDelegate *appDelegate = (iDreamwidthAppDelegate *)[[UIApplication sharedApplication] delegate];

    [appDelegate.dwProtocol login:self];
}

- (void)updateSubscriptions:(id)sender {
    // Updates the subscriptions
    iDreamwidthAppDelegate *appDelegate = (iDreamwidthAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [appDelegate.dwProtocol getReadingPageSubscriptions:self];
}

- (void)dealloc {
    [username release];
    [password release];
    [postToArray release];
    [subscriptionsArray release];
    [super dealloc];
}

@end
