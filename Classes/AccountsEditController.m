//
//  AccountsEditController.m
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

#import "AccountsEditController.h"

#import "iDreamwidthAppDelegate.h"
#import "DWAccount.h"


// Taken from Cocoa With Love 
// (http://cocoawithlove.com/2010/07/tips-tricks-for-conditional-ios3-ios32.html)
#ifndef kCFCoreFoundationVersionNumber_iPhoneOS_2_0
#define kCFCoreFoundationVersionNumber_iPhoneOS_2_0 478.23
#endif

#ifndef kCFCoreFoundationVersionNumber_iPhoneOS_2_1
#define kCFCoreFoundationVersionNumber_iPhoneOS_2_1 478.26
#endif

#ifndef kCFCoreFoundationVersionNumber_iPhoneOS_2_2
#define kCFCoreFoundationVersionNumber_iPhoneOS_2_2 478.29
#endif

#ifndef kCFCoreFoundationVersionNumber_iPhoneOS_3_0
#define kCFCoreFoundationVersionNumber_iPhoneOS_3_0 478.47
#endif

#ifndef kCFCoreFoundationVersionNumber_iPhoneOS_3_1
#define kCFCoreFoundationVersionNumber_iPhoneOS_3_1 478.52
#endif

#ifndef kCFCoreFoundationVersionNumber_iPhoneOS_3_2
#define kCFCoreFoundationVersionNumber_iPhoneOS_3_2 478.61
#endif

#ifndef kCFCoreFoundationVersionNumber_iPhoneOS_4_0
#define kCFCoreFoundationVersionNumber_iPhoneOS_4_0 550.32
#endif

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
#define IF_IOS4_OR_GREATER(...) \
if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iPhoneOS_4_0) \
{ \
__VA_ARGS__ \
}
#else
#define IF_IOS4_OR_GREATER(...)
#endif


@implementation AccountsEditController

@synthesize accountImg;
@synthesize username;
@synthesize password;
@synthesize accountType;
@synthesize saveButton;
@synthesize accountNum;
@synthesize accountTypeNum;
@synthesize accountTypeList;
@synthesize newSave;
@synthesize scrollView;
@synthesize kbShown;
@synthesize typePicker;
@synthesize actionSheet;

 // The designated initializer.  Override if you create the controller programmatically 
 // and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
        iDreamwidthAppDelegate *appDelegate = (iDreamwidthAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        self.accountTypeList = appDelegate.accountsType;
        newSave = YES;
        saveButton.hidden = YES;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave 
                                                                                               target:self 
                                                                                               action:@selector(save:)];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
                                                                                              target:self 
                                                                                              action:@selector(cancel:)];
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    scrollView.contentSize = CGSizeMake(320,430);
    self.navigationItem.title = @"New Account";
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)save:(id)sender {
    iDreamwidthAppDelegate *appDelegate = (iDreamwidthAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (newSave) {
        DWAccount *newAccount = [[DWAccount alloc] initWithUsername:username.text 
                                                       withPassword:password.text 
                                                           withType:accountTypeNum];
        [appDelegate.accountsArray addObject:newAccount];
        [newAccount release];
    } else {
        DWAccount *account = [appDelegate.accountsArray objectAtIndex:accountNum];
        account.username = username.text;
        account.password = password.text;
        account.accountType = accountTypeNum;
    }
    
    [appDelegate updateAccounts:self];
    
    if (currTextField != nil) {
        [currTextField resignFirstResponder];
        currTextField = nil;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)cancel:(id)sender {
    if (currTextField != nil) {
        [currTextField resignFirstResponder];
        currTextField = nil;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)deleteAccount {
    iDreamwidthAppDelegate *appDelegate = (iDreamwidthAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [appDelegate.accountsArray removeObjectAtIndex:accountNum];
        
    [appDelegate updateAccounts:self];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    currTextField = textField;
    
    if (textField == accountType) {
        [self showTypePicker];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    currTextField = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(kbShown:) 
                                                 name:UIKeyboardDidShowNotification 
                                               object:self.view.window]; 
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(kbHidden:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
}


- (void) kbShown:(NSNotification *) notification {
    if (kbShown) return;
    
    // iOS 3 Code
    NSDictionary* info = [notification userInfo];
    
    NSValue *kb = [info objectForKey:UIKeyboardBoundsUserInfoKey];
    CGSize kbSize = [kb CGRectValue].size;
    CGFloat kbHeight = kbSize.height;
    
    IF_IOS4_OR_GREATER
    (
     CGRect kbEndFrame;
     [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&kbEndFrame];
     if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait || 
         [[UIDevice currentDevice] orientation] == UIDeviceOrientationPortraitUpsideDown) {
         kbHeight = kbEndFrame.size.height;
     } else {
         kbHeight = kbEndFrame.size.width;
     }
     );
    
    CGRect viewFrame = [scrollView frame];
    viewFrame.size.height -= kbHeight;
    scrollView.frame = viewFrame;
    
    CGRect textFieldRect = [currTextField frame];
    [scrollView scrollRectToVisible:textFieldRect animated:YES];
    
    kbShown = YES;
}

- (void) kbHidden:(NSNotification *) notification {
    if (!kbShown) return;
    
    // iOS 3 Code
    NSDictionary* info = [notification userInfo];
    
    NSValue* kb = [info objectForKey:UIKeyboardBoundsUserInfoKey];
    CGSize kbSize = [kb CGRectValue].size;
    CGFloat kbHeight = kbSize.height;
    
    IF_IOS4_OR_GREATER
    (
     CGRect kbEndFrame;
     [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&kbEndFrame];
     CGFloat kbHeight;
     if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait || 
         [[UIDevice currentDevice] orientation] == UIDeviceOrientationPortraitUpsideDown) {
         kbHeight = kbEndFrame.size.height;
     } else {
         kbHeight = kbEndFrame.size.width;
     }
     );
    
    CGRect viewFrame = [scrollView frame];
    viewFrame.size.height += kbHeight;
    scrollView.frame = viewFrame;
    
    kbShown = NO;
}

- (void)showTypePicker {
    typeShown = YES;
    
    UIActionSheet *aSheet = [[UIActionSheet alloc] initWithTitle:@"Account Type"
                                                        delegate:nil 
                                               cancelButtonTitle:nil
                                          destructiveButtonTitle:nil
                                               otherButtonTitles:nil];
    [aSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    CGRect pickerFrame = CGRectMake(0, 40, 0, 0);
    
    UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:pickerFrame];
    pickerView.showsSelectionIndicator = YES;
    pickerView.dataSource = self;
    pickerView.delegate = self;
    
    [aSheet addSubview:pickerView];
    [pickerView release];
    
    UISegmentedControl *closeButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"Close"]];
    closeButton.momentary = YES; 
    closeButton.frame = CGRectMake(260, 7.0f, 50.0f, 30.0f);
    closeButton.segmentedControlStyle = UISegmentedControlStyleBar;
    closeButton.tintColor = [UIColor blackColor];
    [closeButton addTarget:self action:@selector(dismissPicker:) forControlEvents:UIControlEventValueChanged];
    [aSheet addSubview:closeButton];
    [closeButton release];
    
    [aSheet showInView:self.view];
    
    [aSheet setBounds:CGRectMake(0, 0, 320, 485)];
    
    [pickerView selectRow:self.accountTypeNum inComponent:0 animated:NO];
    
    self.typePicker = pickerView;
    self.actionSheet = aSheet;
}

- (void)dismissPicker:(id)sender {
    if (typeShown) {
        [actionSheet dismissWithClickedButtonIndex:-1 animated:YES];
        NSInteger n = [typePicker selectedRowInComponent:0];
        self.accountType.text = [accountTypeList objectAtIndex:n];
        [accountType resignFirstResponder];
        currTextField = nil;
        accountTypeNum = n;
        typeShown = NO;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return (NSString *)[accountTypeList objectAtIndex:row];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if (typeShown) {
        return [accountTypeList count];
    } else {
        return 0;
    }
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    currTextField = nil;
    
    [accountImg release];
    [username release];
    [password release];
    [accountType release];
    [saveButton release];
    [accountTypeList release];
    [typePicker release];
    [actionSheet release];
    [self.navigationItem.rightBarButtonItem release];
    [self.navigationItem.leftBarButtonItem release];
    
    [super dealloc];
}


@end
