//
//  DetailViewController.m
//  Yelp
//
//  Created by David Rajan on 2/15/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import "DetailViewController.h"
#import "BusinessCell.h"
#import "UIImageView+AFNetworking.h"

@interface DetailViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"BusinessCell" bundle:nil] forCellReuseIdentifier:@"BusinessCell"];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 85;
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - Table view methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        BusinessCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BusinessCell"];
        [cell setSeparatorInset:UIEdgeInsetsZero];
        cell.preservesSuperviewLayoutMargins = NO;
        [cell setLayoutMargins:UIEdgeInsetsZero];
        
        cell.business = self.business;
        return cell;
    }
    
 
    return nil;
}

@end
