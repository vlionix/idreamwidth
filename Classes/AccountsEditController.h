//
//  AccountsEditController.h
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

// AccountsEditController is the controller for the view seen when a user is
// editing an account
@interface AccountsEditController : UIViewController<UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource> {
    IBOutlet UIImageView *accountImg;
    IBOutlet UITextField *username;
    IBOutlet UITextField *password;
    IBOutlet UITextField *accountType;
    
    int accountNum; // corresponds to position of account in App Delegate's accounts array
    
    // Used for keeping track of account type picker
    UIPickerView *typePicker;
    NSArray *accountTypeList;
    bool typeShown;
    int accountTypeNum; // 0 = Dreamwidth; 1 = LiveJournal (planned, not active)
    
    IBOutlet UIButton *saveButton;
    BOOL newSave;
    
    // Used for moving to selected text field
    IBOutlet UIScrollView *scrollView;
    UITextField *currTextField; // ptr to current text field being edited
    UIActionSheet *actionSheet;
    BOOL kbShown;
}

// Opens up the UIPicker for the account type selector
- (void)showTypePicker;

// Saves the account's information to the App Delegate
- (void)save:(id)sender;

// Deletes the account from the App Delegate
- (IBAction)deleteAccount;

@property(nonatomic, retain) IBOutlet UIImageView *accountImg;
@property(nonatomic, retain) IBOutlet UITextField *username;
@property(nonatomic, retain) IBOutlet UITextField *password;
@property(nonatomic, retain) IBOutlet UITextField *accountType;
@property(nonatomic, retain) IBOutlet UIButton *saveButton;
@property(nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property(nonatomic, retain) UIPickerView *typePicker;
@property(nonatomic, retain) UIActionSheet *actionSheet;
@property(nonatomic, retain) NSArray *accountTypeList;
@property(nonatomic) int accountNum;
@property(nonatomic) int accountTypeNum;
@property(nonatomic) BOOL newSave;
@property(nonatomic) BOOL kbShown;

@end
