//
//  ItemsViewController.m
//  Homepwner
//
//  Created by liupeng on 16/3/24.
//  Copyright © 2016年 liupeng. All rights reserved.
//

#import "ItemsViewController.h"
#import "LastItemCell.h"
#import "ItemStore.h"
#import "ItemCell.h"
#import "ImageStore.h"
#import "Item.h"
#import "DetailViewController.h"

@interface ItemsViewController ()

@end

@implementation ItemsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.tableView.rowHeight	= UITableViewAutomaticDimension;
	self.tableView.estimatedRowHeight	= 65;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.itemStore.allItems count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *LastCellIdentifier = @"LastItemCell";

	// The Last cell.
	if ([self indexPathIsTheLastCell:indexPath]) {
		LastItemCell *cell = [tableView dequeueReusableCellWithIdentifier:LastCellIdentifier];
		if (cell == nil) {
			cell = [[LastItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LastCellIdentifier];
		}
		cell.userInteractionEnabled	= NO;
		cell.mainLabel.text			= @"No more Item!";
		return cell;
	}
	
	ItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ItemCell" forIndexPath:indexPath];
	// Update the labels for the new prefferd text size.
	[cell updateLabels];

    // Configure the cell...
	Item *item = [self.itemStore.allItems objectAtIndex:indexPath.row];
	cell.nameLabel.text	= item.name;
	cell.serialNumberLabel.text	= item.serialNumber;
	cell.valueLabel.text	= [NSString stringWithFormat:@"%ld", (long)item.valueInDollars];
	if (item.valueInDollars < 50) {
		cell.valueLabel.textColor	= [UIColor greenColor];
	} else {
		cell.valueLabel.textColor	= [UIColor redColor];
	}
	
    return cell;
}

-(BOOL)indexPathIsTheLastCell:(NSIndexPath *)indexPath {
	if (indexPath.row == [self.itemStore.allItems count]) {
		return YES;
	} else {
		return NO;
	}
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
	if ([self indexPathIsTheLastCell:indexPath]) {
		return NO;
	} else {
    	return YES;
	}
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		Item *deleteItem = [self.itemStore.allItems objectAtIndex:indexPath.row];
		NSString *title = [[NSString alloc] initWithFormat:@"Delete %@", deleteItem.name];
		NSString *msg = @"Are you sure want to delete this item?";
		UIAlertController *ac = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleActionSheet];
		UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
		[ac addAction:cancelAction];
		UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
			// Delete the row from the data source
			[self.itemStore removeItem:deleteItem];
			[self.imageStore deleteImageForKey:deleteItem.itemKey];
			[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
		}];
		[ac addAction:deleteAction];
		[self presentViewController:ac animated:YES completion:nil];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	[self.itemStore moveItemAtIndex:fromIndexPath.row toIndex:toIndexPath.row];
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
	if ([self indexPathIsTheLastCell:indexPath]) {
		return NO;
	} else {
		return YES;
	}
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
	if ([segue.identifier isEqualToString:@"ShowItem"]) {
		NSInteger row = [self.tableView indexPathForSelectedRow].row;
		Item *item = self.itemStore.allItems[row];
		DetailViewController *detailViewController	= segue.destinationViewController;
		detailViewController.item	= item;
		detailViewController.imageStore	= self.imageStore;
	}
}

- (IBAction)addNewItem:(id)sender {
	Item *newItem = [self.itemStore createItem];
	NSInteger index = 0;
	if ((index = [self.itemStore.allItems indexOfObject:newItem]) != NSNotFound) {
		NSIndexPath *indexPath	= [NSIndexPath indexPathForRow:index inSection:0];
		[self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
	}
}

#pragma mark - UITableViewDelegate
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
	return @"Remove";
}

-(NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
	if ([self indexPathIsTheLastCell:proposedDestinationIndexPath]) {
		return sourceIndexPath;
	} else {
		return proposedDestinationIndexPath;
	}
}
@end
