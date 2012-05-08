//
//  iDreamwidthAppDelegate.h
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

#import <UIKit/UIKit.h>

#import "NewEntryViewController.h"
#import "DraftsViewController.h"
#import "JournalViewController.h"
#import "AccountsViewController.h"
#import "ReadingViewController.h"
#import "SettingsViewController.h"
#import "DWProtocol.h"

// App delegate for iDreamwidth
@interface iDreamwidthAppDelegate : NSObject <UIApplicationDelegate, UIAlertViewDelegate> {
    UIWindow *window;
    UINavigationController *navigationController;
    NewEntryViewController *newEntryController;
    DraftsViewController *draftsController;
    JournalViewController *journalController;
    AccountsViewController *accountsController;
    ReadingViewController *readingController;
    SettingsViewController *settingsController;
    
    DWProtocol *dwProtocol;
    
    UIButton *newEntry;
    UIButton *drafts;
    UIButton *journal;
    UIButton *accounts;
    UIButton *reading;
    UIButton *settings;
    
    NSArray *accountsType;
    NSMutableArray *accountsArray;
    NSMutableArray *draftsArray;
    NSMutableArray *journalArray;
    NSMutableArray *readingArray;
    NSMutableArray *readingLoadArray;
    
    NSArray *moodArray;
    NSArray *moodNumArray;
    NSDictionary *moodDict;
    
    NSMutableDictionary *userPics;
    
    int readingCount;
}

// Opens up the New Entry view
- (IBAction)openNewEntry:(id)sender;

// Opens up the Drafts view
- (IBAction)openDrafts:(id)sender;

// Opens up the Journal view
- (IBAction)openJournal:(id)sender;

// Opens up the Accounts view
- (IBAction)openAccounts:(id)sender;

// Opens up the Reading view
- (IBAction)openReading:(id)sender;

// Opens up the Settings (About) view
- (IBAction)openSettings:(id)sender;

// Updates the accounts array and the corresponding table view
- (void)updateAccounts:(id)sender;

// Updates the drafts array and the corresponding table view
- (void)updateDrafts:(id)sender;

// Updates the journal array and the corresponding table view
- (void)updateJournal:(id)sender;

// Updates the reading array and the corresponding table view
- (void)updateReading:(id)sender;

// Sorts the reading page RSS feed posts by date and limits to
// at most the last 50 posts
- (void)sortReading:(id)sender;

// Once RSS feed posts are all set, load the new reading posts
- (void)reloadReading:(id)sender;

// Saves the information of the application
- (void)saveData:(id)sender;

// Loads previously saved information of the application
- (void)loadData:(id)sender;

@property(nonatomic, retain) IBOutlet UIWindow *window;
@property(nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property(nonatomic, retain) IBOutlet NewEntryViewController *newEntryController;
@property(nonatomic, retain) IBOutlet DraftsViewController *draftsController;
@property(nonatomic, retain) IBOutlet JournalViewController *journalController;
@property(nonatomic, retain) IBOutlet AccountsViewController *accountsController;
@property(nonatomic, retain) IBOutlet ReadingViewController *readingController;
@property(nonatomic, retain) IBOutlet SettingsViewController *settingsController;

@property(nonatomic, retain) DWProtocol *dwProtocol;

@property(nonatomic, retain) IBOutlet UIButton *newEntry;
@property(nonatomic, retain) IBOutlet UIButton *drafts;
@property(nonatomic, retain) IBOutlet UIButton *journal;
@property(nonatomic, retain) IBOutlet UIButton *accounts;
@property(nonatomic, retain) IBOutlet UIButton *reading;
@property(nonatomic, retain) IBOutlet UIButton *settings;

@property(nonatomic, retain) NSArray *accountsType;
@property(nonatomic, retain) NSMutableArray *accountsArray;
@property(nonatomic, retain) NSMutableArray *draftsArray;
@property(nonatomic, retain) NSMutableArray *journalArray;
@property(nonatomic, retain) NSMutableArray *readingArray;
@property(nonatomic, retain) NSMutableArray *readingLoadArray;

@property(nonatomic) int readingCount;

@property(nonatomic, retain) NSArray *moodArray;
@property(nonatomic, retain) NSArray *moodNumArray;
@property(nonatomic, retain) NSDictionary *moodDict;

@property(nonatomic, retain) NSMutableDictionary *userPics;

@end

