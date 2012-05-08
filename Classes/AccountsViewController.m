//
//  AccountsViewController.m
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

#import "AccountsViewController.h"

#import "DWAccount.h"
#import "iDreamwidthAppDelegate.h"
#import "AccountsCell.h"
#import "AccountsEditController.h"

@implementation AccountsViewController

@synthesize editor;
@synthesize tblView;

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd 
                                                                                           target:self 
                                                                                           action:@selector(addAccount:)];
    self.navigationItem.title = @"Accounts";
}

- (void)addAccount:(id)sender {
    iDreamwidthAppDelegate *appDelegate = (iDreamwidthAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (editor == nil) {
        AccountsEditController *editController = [[AccountsEditController alloc] initWithNibName:@"AccountsEditController" bundle:nil];
        self.editor = editController;
        [editController release];
        [editor.saveButton setBackgroundImage:[[UIImage imageNamed:@"delete_button.png"] 
                                               stretchableImageWithLeftCapWidth:10.0 
                                               topCapHeight:0.0] 
                                     forState:UIControlStateNormal];
    }
    [self.navigationController pushViewController:self.editor animated:YES];
    editor.accountNum = [appDelegate.accountsArray count];
    editor.username.text = @"";
    editor.password.text = @"";
    editor.accountTypeNum = 0;
    editor.newSave = YES;
    editor.saveButton.hidden = YES;
    editor.accountType.text = [editor.accountTypeList objectAtIndex:0];
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    iDreamwidthAppDelegate *appDelegate = (iDreamwidthAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    return [appDelegate.accountsArray count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellID = @"AccountsCell";
    
    AccountsCell *cell = (AccountsCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        NSArray *newCell = [[NSBundle mainBundle] loadNibNamed:@"AccountsCell" owner:nil options:nil];
        
        for (id obj in newCell) {
            if ([obj isKindOfClass:[AccountsCell class]]) {
                cell = (AccountsCell *)obj;
            }
        }
    }
    
    // Set up the cell...
    iDreamwidthAppDelegate *appDelegate = (iDreamwidthAppDelegate *)[[UIApplication sharedApplication] delegate];
    DWAccount *acct = [appDelegate.accountsArray objectAtIndex:indexPath.row];
    
    cell.accountName.text = acct.username;
    
    UIImage *userPic = nil;
    userPic = [appDelegate.userPics objectForKey:[acct.username lowercaseString]];
    if (userPic == nil) {
        cell.accountImg.image = [UIImage imageNamed:@"Dw_icon2.png"];
    } else {
        cell.accountImg.image = userPic;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    // AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
    // [self.navigationController pushViewController:anotherViewController];
    // [anotherViewController release];
    iDreamwidthAppDelegate *appDelegate = (iDreamwidthAppDelegate *)[[UIApplication sharedApplication] delegate];
    DWAccount *acct = [appDelegate.accountsArray objectAtIndex:indexPath.row];
    
    if (editor == nil) {
        AccountsEditController *editController = [[AccountsEditController alloc] initWithNibName:@"AccountsEditController" bundle:nil];
        self.editor = editController;
        [self.navigationController pushViewController:self.editor animated:YES];
        [editController release];
        [editor.saveButton setBackgroundImage:[[UIImage imageNamed:@"delete_button.png"] 
                                               stretchableImageWithLeftCapWidth:10.0 
                                               topCapHeight:0.0] 
                                     forState:UIControlStateNormal];
    } else {
        [self.navigationController pushViewController:self.editor animated:YES];
    }
    
    editor.accountNum = indexPath.row;
    editor.username.text = acct.username;
    editor.password.text = acct.password;
    editor.accountTypeNum = acct.accountType;
    editor.newSave = NO;
    editor.saveButton.hidden = NO;
    editor.accountType.text = [editor.accountTypeList objectAtIndex:acct.accountType];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView beginUpdates];
    
    iDreamwidthAppDelegate *appDelegate = (iDreamwidthAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.accountsArray removeObjectAtIndex:indexPath.row];
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    [tableView endUpdates];
    [appDelegate updateAccounts:self];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


- (void)dealloc {
    [editor release];
    [tblView release];
    [self.navigationItem.rightBarButtonItem release];
    [super dealloc];
}


@end

