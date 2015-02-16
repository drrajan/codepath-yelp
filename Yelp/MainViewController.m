//
//  MainViewController.m
//  Yelp
//
//  Created by Timothy Lee on 3/21/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "MainViewController.h"
#import "YelpClient.h"
#import "Business.h"
#import "BusinessCell.h"
#import "FiltersViewController.h"
#import "DetailViewController.h"

NSString * const kYelpConsumerKey = @"VBpXD38E4NX5yXqIWqGYIA";
NSString * const kYelpConsumerSecret = @"CYeG-XScFYnBGUdQc08c02A74JQ";
NSString * const kYelpToken = @"Zg8MT7f99KDuhhfj0VGpuq1YpDqZW7vf";
NSString * const kYelpTokenSecret = @"xuuszHt3umq2LGfwi4NnnX2mz9w";

@interface MainViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, MKMapViewDelegate, FiltersViewControllerDelegate>

@property (nonatomic, strong) YelpClient *client;
@property (nonatomic, strong) NSMutableArray *businesses;
@property (nonatomic, strong) NSMutableDictionary *filters;
@property (nonatomic, strong) NSString *queryString;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, assign) BOOL isMapView;
@property (nonatomic, assign) BOOL isMoreResults;

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.businesses = [NSMutableArray array];
        self.filters = [NSMutableDictionary dictionary];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults removeObjectForKey:@"filters"];
        
        // You can register for Yelp API keys here: http://www.yelp.com/developers/manage_api_keys
        self.client = [[YelpClient alloc] initWithConsumerKey:kYelpConsumerKey consumerSecret:kYelpConsumerSecret accessToken:kYelpToken accessSecret:kYelpTokenSecret];
        
        self.queryString = @"Restaurants";
        [self fetchBusinessesWithQuery:self.queryString params:nil];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"BusinessCell" bundle:nil] forCellReuseIdentifier:@"BusinessCell"];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 85;
    
    UIView *tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    self.loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.loadingView startAnimating];
    self.loadingView.center = tableFooterView.center;
    [tableFooterView addSubview:self.loadingView];
    self.tableView.tableFooterView = tableFooterView;
    
    self.mapView = [[MKMapView alloc] initWithFrame:self.tableView.frame];
    self.isMapView = NO;
    self.mapView.delegate = self;
    
    self.title = @"Yelp";
    
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.delegate = self;
    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.searchBar.text = self.queryString;
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.titleView = self.searchBar;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Filter" style:UIBarButtonItemStylePlain target:self action:@selector(onFilterButton)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Map" style:UIBarButtonItemStylePlain target:self action:@selector(onMapButton)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - Table view methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.businesses.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BusinessCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BusinessCell"];
    [cell setSeparatorInset:UIEdgeInsetsZero];
    cell.preservesSuperviewLayoutMargins = NO;
    [cell setLayoutMargins:UIEdgeInsetsZero];
    
    cell.business = self.businesses[indexPath.row];
    
    if (self.isMoreResults && indexPath.row == self.businesses.count - 1) {
        int offset = 20;
        if ([self.filters objectForKey:@"offset"]) {
            NSNumber *offset_num = [self.filters objectForKey:@"offset"];
            offset = [offset_num intValue] + 20;
        }
        [self.filters setValue:[NSNumber numberWithInt:offset] forKey:@"offset"];
        [self fetchBusinessesWithQuery:self.queryString params:self.filters];
    }
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    DetailViewController *vc = [[DetailViewController alloc] init];
    
    vc.business = self.businesses[indexPath.row];
  
    [self.navigationController pushViewController:vc animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if ([self.filters count] > 0) {
        NSString *sortString = [self.filters objectForKey:@"sort"] ? @"sort, " : @"";
        NSString *distanceString = [self.filters objectForKey:@"radius_filter"] ? @"distance, " : @"";
        NSString *dealsString = [self.filters objectForKey:@"deals_filter"] ? @"deals, " : @"";
        NSString *categoryString = [self.filters objectForKey:@"category_filter"] ? [self.filters objectForKey:@"category_filter"] : @"";

        if (!([sortString isEqualToString:@""] && [distanceString isEqualToString:@""] && [categoryString isEqualToString:@""])) {
            NSString *filterString = [NSString stringWithFormat:@"Filter: %@%@%@%@", sortString, distanceString, dealsString, categoryString];
            return filterString;
        }
    }
    
    return @"";
}


#pragma mark - Search bar methods

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar resignFirstResponder];
    self.queryString = self.searchBar.text;
    [self.businesses removeAllObjects];
    [self.filters removeAllObjects];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"filters"];
    [self.tableView reloadData];
    [self fetchBusinessesWithQuery:self.queryString params:nil];
    NSLog(@"search: %@", searchBar.text);
}

#pragma mark - Filter delegate methods

-(void)filtersViewController:(FiltersViewController *)filtersViewController didChangeFilters:(NSDictionary *)filters {
    self.filters = (NSMutableDictionary *)filters;
    [self.businesses removeAllObjects];
    [self fetchBusinessesWithQuery:self.queryString params:self.filters];

    NSLog(@"filter query: %@ withFilters: %@", self.queryString, self.filters);
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
        
        annotationView.rightCalloutAccessoryView     = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    }
    else
    {
        annotationView.annotation = annotation;
    }
    
    return annotationView;
    
}

#pragma mark - Private methods

- (void)fetchBusinessesWithQuery:(NSString *)query params:(NSDictionary *)params {
    NSLog(@"query: %@ withFilters: %@", query, params);
    [self.client searchWithTerm:query params:params success:^(AFHTTPRequestOperation *operation, id response) {
        NSArray *businessDictionaries = response[@"businesses"];
        if ([businessDictionaries count]) {
            self.isMoreResults = YES;
            [self.loadingView startAnimating];
        } else {
            self.isMoreResults = NO;
            [self.loadingView stopAnimating];
        }

        [self.businesses addObjectsFromArray:[Business businessesWithDictionaries:businessDictionaries]];
        
        NSMutableArray * annotationsToRemove = [self.mapView.annotations mutableCopy];
        [annotationsToRemove removeObject:self.mapView.userLocation];
        [self.mapView removeAnnotations:annotationsToRemove];
        NSDictionary *regionDict = response[@"region"];
        CLLocationCoordinate2D center = CLLocationCoordinate2DMake([[regionDict valueForKeyPath:@"center.latitude"] doubleValue], [[regionDict valueForKeyPath:@"center.longitude"] doubleValue]);
        MKCoordinateSpan span = MKCoordinateSpanMake([[regionDict valueForKeyPath:@"span.latitude_delta"] doubleValue], [[regionDict valueForKeyPath:@"span.longitude_delta"] doubleValue]);
        MKCoordinateRegion region = MKCoordinateRegionMake(center, span);
        [self.mapView setRegion:region animated:YES];
        for (NSDictionary *business in businessDictionaries) {
            MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
            annotation.title = business[@"name"];
            annotation.subtitle = [NSString stringWithFormat:@"%@ reviews", business[@"review_count"]];
            annotation.coordinate = CLLocationCoordinate2DMake([[business valueForKeyPath:@"location.coordinate.latitude"] doubleValue], [[business valueForKeyPath:@"location.coordinate.longitude"] doubleValue]);
            [self.mapView addAnnotation:annotation];
        }
        
        [self.tableView reloadData];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error: %@", [error description]);
    }];

}

- (void)onFilterButton {
    FiltersViewController *vc = [[FiltersViewController alloc] init];
    vc.delegate = self;
    
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nvc animated:YES completion:nil];
    
}

- (void)onMapButton {
    NSLog(@"map clicked");
    UIView *fromView, *toView;
    
    if (self.isMapView)
    {
        fromView = self.mapView;
        toView = self.tableView;
        NSLog(@"switching to table");
        self.navigationItem.rightBarButtonItem.title = @"Map";
    }
    else
    {
        fromView = self.tableView;
        toView = self.mapView;
        NSLog(@"switching to map");
        self.navigationItem.rightBarButtonItem.title = @"List";
    }
    
    [toView setHidden: YES];
    [self.view addSubview: toView];
    if (self.isMapView ) {
        [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"|[toView]|" options: 0 metrics: nil views: NSDictionaryOfVariableBindings(self.view, toView)]];
        [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"V:|[toView]|" options: 0 metrics: nil views: NSDictionaryOfVariableBindings(self.view, toView)]];
    }
    
    [UIView transitionFromView: fromView toView: toView duration: 1.0 options: UIViewAnimationOptionTransitionFlipFromRight | UIViewAnimationOptionShowHideTransitionViews completion:^(BOOL finished) {
        [fromView removeFromSuperview];
    }];
    
    self.isMapView = !self.isMapView;
}

@end
