//
//  DetailViewController.m
//  Yelp
//
//  Created by David Rajan on 2/15/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "DetailViewController.h"
#import "BusinessCell.h"
#import "UIImageView+AFNetworking.h"

@interface DetailViewController () <UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"BusinessCell" bundle:nil] forCellReuseIdentifier:@"BusinessCell"];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 85;
    
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake([self.business.latitude doubleValue], [self.business.longitude doubleValue]);
    MKCoordinateSpan span = MKCoordinateSpanMake(0, 0);
    MKCoordinateRegion region = MKCoordinateRegionMake(center, span);
    [self.mapView setRegion:region animated:YES];
    
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.title = self.business.name;
    annotation.subtitle = [NSString stringWithFormat:@"%@✻ %ld reviews", self.business.rating, self.business.numReviews];
    annotation.coordinate = center;
    [self.mapView addAnnotation:annotation];
    
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

#pragma mark - Map delegate methods

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    
    static NSString *identifier = @"myannotation";
    MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    
    if (annotationView == nil)
    {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        annotationView.canShowCallout = YES;
        annotationView.animatesDrop = YES;
    }
    else
    {
        annotationView.annotation = annotation;
    }
    
    return annotationView;
    
}


@end
