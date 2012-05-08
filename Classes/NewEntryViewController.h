//
//  NewEntryViewController.h
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

#import "DWPost.h"

// Controller for the New Entry view
@interface NewEntryViewController : UIViewController<UITextFieldDelegate, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIActionSheetDelegate> {
    IBOutlet UITextField *postAsText;
    IBOutlet UITextField *postToText;
    IBOutlet UITextField *subjectText;
    IBOutlet UITextView *entryView;
    IBOutlet UITextField *tagsText;
    IBOutlet UITextField *moodSelText;
    IBOutlet UITextField *moodText;
    IBOutlet UITextField *locationText;
    IBOutlet UITextField *musicText;
    IBOutlet UITextField *commentsText;
    IBOutlet UITextField *screenText;
    IBOutlet UITextField *ageRestrictText;
    IBOutlet UITextField *accessText;
    
    // Picker for accounts in client
    UIPickerView *postAsPick;
    BOOL postAsShown;
    
    // Picker for journal access
    UIPickerView *postToPick;
    NSArray *postToArray;
    BOOL postToShown;
    
    // Picker for moods
    IBOutlet UIPickerView *moodPick;
    BOOL moodShown;

    // Picker for comments
    IBOutlet UIPickerView *commentsPick;
    NSArray *commentsArray;
    BOOL commentsShown;
    
    // Picker for comment screening
    IBOutlet UIPickerView *screenPick;
    NSArray *screenArray;
    BOOL screenShown;
    
    // Picker for age restrictions
    IBOutlet UIPickerView *ageRestrictPick;
    NSArray* ageRestrictArray;
    BOOL ageRestrictShown;
    
    // Picker for access
    IBOutlet UIPickerView *accessPick;
    NSArray* accessArray;
    BOOL accessShown;
    
    // Used for scrolling touched text field
    IBOutlet UIScrollView *scrollView;
    BOOL kbShown;
    UITextField *currTextField;
    UIActionSheet *actionSheet;
    
    // Relevant info on the post
    DWPost *post;
    int accountNum;
    int postToNum;
    int commentsNum;
    int screenNum;
    int adultContentNum;
    int moodNum;
    BOOL accessSel;
    
    IBOutlet UIButton *submitButton;
}

// Saves the post to the drafts
- (void)save:(id)sender;

// Submits the post to the server
- (IBAction)submit;

// Clears the view and controller of any post information
- (void)clear;

// Loads the post into the view and controller
- (void)loadPost:(DWPost *)newPost;

// Exposes relevant picker
- (void)showPostAsPicker;
- (void)showPostToPicker;
- (void)showMoodPicker;
- (void)showCommentsPicker;
- (void)showScreenPicker;
- (void)showAgeRestrictPicker;
- (void)showAccessPicker;


@property(nonatomic, retain) IBOutlet UITextField *postAsText;
@property(nonatomic, retain) IBOutlet UITextField *postToText;
@property(nonatomic, retain) IBOutlet UITextField *subjectText;
@property(nonatomic, retain) IBOutlet UITextView *entryView;
@property(nonatomic, retain) IBOutlet UITextField *tagsText;
@property(nonatomic, retain) IBOutlet UITextField *moodSelText;
@property(nonatomic, retain) IBOutlet UITextField *moodText;
@property(nonatomic, retain) IBOutlet UITextField *locationText;
@property(nonatomic, retain) IBOutlet UITextField *musicText;
@property(nonatomic, retain) IBOutlet UITextField *commentsText;
@property(nonatomic, retain) IBOutlet UITextField *screenText;
@property(nonatomic, retain) IBOutlet UITextField *ageRestrictText;
@property(nonatomic, retain) IBOutlet UITextField *accessText;

@property(nonatomic, retain) IBOutlet UIPickerView *postAsPick;
@property(nonatomic, retain) UIPickerView *postToPick;
@property(nonatomic, retain) IBOutlet UIPickerView *moodPick;
@property(nonatomic, retain) IBOutlet UIPickerView *commentsPick;
@property(nonatomic, retain) IBOutlet UIPickerView *ageRestrictPick;
@property(nonatomic, retain) IBOutlet UIPickerView *screenPick;
@property(nonatomic, retain) IBOutlet UIPickerView *accessPick;
@property(nonatomic, retain) UIActionSheet *actionSheet;

@property(nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property(nonatomic) BOOL kbShown;

@property(nonatomic, retain) DWPost *post;

@property(nonatomic, retain) IBOutlet UIButton *submitButton;

@end
