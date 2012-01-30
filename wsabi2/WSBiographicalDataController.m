//
//  WSBiographicalDataController.m
//  wsabi2
//
//  Created by Matt Aronoff on 1/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WSBiographicalDataController.h"

@implementation WSBiographicalDataController
@synthesize bioDataTable;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"Biographical Info";
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

//#pragma mark - TableView data source/delegate
//// Customize the number of sections in the table view.
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    return 3;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    switch (section) {
//        case kSectionBasic:
//            return 7;
//            break;
//        case kSectionGender:
//            return 1;
//            break;
//        default:
//            break;
//    }
//}
//
//// Customize the appearance of table view cells.
////FIXME: This should be more flexible about different cell arrangements!
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    //NSLog(@"Index path for selected row is (%d,%d)",selectedIndex.section, selectedIndex.row);
//    WSCDPerson *person = [self.fetchedResultsController objectAtIndexPath:indexPath];
//    
//    //if there are 0 items, use 1 row. Otherwise, fit to the number of items.
//    int numRows = MAX(1, ceil([person.items count] / 5.0)); 
//    
//    NSLog(@"Row %d should have %d rows",indexPath.row, numRows);
//    
//    if ([indexPath compare:selectedIndex] == NSOrderedSame) {
//        return 264 + (124.0 * numRows);
//    }
//    else return 40.0 + (124.0 * numRows);
//}
//
//- (void)configureCell:(WSPersonTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
//{
//    WSCDPerson *person = [self.fetchedResultsController objectAtIndexPath:indexPath];
//    //cell.textLabel.text = [person.timeStampCreated description];
//    //cell.textLabel.backgroundColor = [UIColor clearColor];
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    
//    cell.person = person;
//    [cell.itemGridView reloadData];
//}
//
//- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *CellIdentifier = @"WSPersonTableViewCell"; //this is also set in WSPersonTableViewCell's XIB file
//    
//    WSPersonTableViewCell *cell = (WSPersonTableViewCell*)[aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (cell == nil) {
//        NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"WSPersonTableViewCell" owner:self
//                                                        options:nil];
//        
//        cell = [nibViews objectAtIndex: 0];
//        cell.delegate = self;
//    }
//    
//    [self configureCell:cell atIndexPath:indexPath];
//    return cell;
//}
//
///*
// // Override to support conditional editing of the table view.
// - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
// {
// // Return NO if you do not want the specified item to be editable.
// return YES;
// }
// */
//
////- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
////{
////    if (editingStyle == UITableViewCellEditingStyleDelete) {
////        // Delete the managed object for the given index path
////        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
////        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
////        
////        // Save the context.
////        NSError *error = nil;
////        if (![context save:&error]) {
////            /*
////             Replace this implementation with code to handle the error appropriately.
////             
////             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
////             */
////            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
////            abort();
////        }
////
////
////    }   
////}
//
//- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    // The table view should not be re-orderable.
//    return NO;
//}
//
//- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    
//    selectedIndex = indexPath;
//    
//    [aTableView beginUpdates];
//    [aTableView endUpdates];
//    
//    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
//}
//


@end
