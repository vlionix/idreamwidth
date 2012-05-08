//
//  ReadingViewController.m
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

#import "ReadingViewController.h"

#import "EntryCell.h"
#import "iDreamwidthAppDelegate.h"
#import "LightPostViewController.h"
#import "DWPost.h"

@implementation ReadingViewController

@synthesize tblView;
@synthesize postView;

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
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.title = @"Reading";
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    iDreamwidthAppDelegate *appDelegate = (iDreamwidthAppDelegate *)[[UIApplication sharedApplication] delegate];

    [appDelegate updateReading:self];
}

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


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    iDreamwidthAppDelegate *appDelegate = (iDreamwidthAppDelegate *)[[UIApplication sharedApplication] delegate];

    return [appDelegate.readingArray count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellID = @"ReadingCell";
    
    EntryCell *cell = (EntryCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        NSArray *newCell = [[NSBundle mainBundle] loadNibNamed:@"EntryCell" owner:nil options:nil];
        
        for (id obj in newCell) {
            if ([obj isKindOfClass:[EntryCell class]]) {
                cell = (EntryCell *)obj;
            }
        }
    }
    
    // Set up the cell...
    iDreamwidthAppDelegate *appDelegate = (iDreamwidthAppDelegate *)[[UIApplication sharedApplication] delegate];
    DWPost *post = [appDelegate.readingArray objectAtIndex:indexPath.row];
    
    cell.title.text = post.subject;
    cell.author.text = post.author;
    NSString *commTag = [[NSString alloc] initWithFormat:@"@%@", post.community];
    cell.community.text = commTag;
    [commTag release];
    cell.date.text = post.date;
    
    UIImage *userPic = nil;
    userPic = [appDelegate.userPics objectForKey:[cell.author.text lowercaseString]];
    if (userPic == nil) {
        cell.postImg.image = [UIImage imageNamed:@"Dw_icon2.png"];
    } else {
        cell.postImg.image = userPic;
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    // AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
    // [self.navigationController pushViewController:anotherViewController];
    // [anotherViewController release];
    
    iDreamwidthAppDelegate *appDelegate = (iDreamwidthAppDelegate *)[[UIApplication sharedApplication] delegate];
    DWPost *post = [appDelegate.readingArray objectAtIndex:indexPath.row];
    
    if (postView == nil) {
        LightPostViewController *newPostView = [[LightPostViewController alloc] 
                                                initWithNibName:@"LightPostViewController" 
                                                bundle:[NSBundle mainBundle]];
        self.postView = newPostView;
        [newPostView release];
    }
    postView.title = post.subject;
    [self.navigationController pushViewController:postView animated:YES];
    NSURL *lightPostURL = [NSURL URLWithString:post.url];
    NSURLRequest *request = [NSURLRequest requestWithURL:lightPostURL];
    [postView.lightPost loadRequest:request];
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
    [tblView release];
    [postView release];
    [super dealloc];
}


@end

