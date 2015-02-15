//
//  FiltersViewController.m
//  Yelp
//
//  Created by David Rajan on 2/11/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import "FiltersViewController.h"
#import "SwitchCell.h"

@interface FiltersViewController () <UITableViewDataSource, UITableViewDelegate, SwitchCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, readonly) NSDictionary *filters;
@property (nonatomic, strong) NSArray *categories;
@property (nonatomic, strong) NSArray *categories_min;
@property (nonatomic, strong) NSMutableSet *selectedCategories;

@property (nonatomic, strong) NSArray *sectionTitles;
@property (nonatomic, strong) NSArray *sorts;
@property (nonatomic, strong) NSString *sortCode;
@property (nonatomic, strong) NSArray *distances;
@property (nonatomic, strong) NSString *distanceCode;
@property (nonatomic, strong) NSArray *deals;
@property (nonatomic, strong) NSString *dealCode;

@property (nonatomic, assign) NSInteger selectedSortIndex;
@property (nonatomic, assign) NSInteger selectedDistanceIndex;
@property (nonatomic, assign) BOOL isShowingSort;
@property (nonatomic, assign) BOOL isShowingDistance;
@property (nonatomic, assign) BOOL isShowingCategories;

@end

@implementation FiltersViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        self.selectedCategories = [NSMutableSet set];
        [self initCategories];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationController.navigationBar.translucent = NO;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self
                                                                            action:@selector(onCancelButton)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Apply" style:UIBarButtonItemStylePlain target:self
                                                                            action:@selector(onApplyButton)];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    //self.tableView.layer.cornerRadius = 5;
    //self.tableView.layer.borderWidth = 0.2;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SwitchCell" bundle:nil] forCellReuseIdentifier:@"SwitchCell"];
    
    self.isShowingSort = NO;
    self.isShowingDistance = NO;
    self.isShowingCategories = NO;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    SwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SwitchCell"];
    cell.delegate = self;
    [cell setSeparatorInset:UIEdgeInsetsZero];
    cell.preservesSuperviewLayoutMargins = NO;
    [cell setLayoutMargins:UIEdgeInsetsZero];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.toggleSwitch.hidden = NO;
    
    switch (indexPath.section) {
        case 0:
        {
            cell.toggleSwitch.hidden = YES;
            if (!self.isShowingSort) {
                cell.titleLabel.text = self.sorts[self.selectedSortIndex][@"name"];
                cell.on = [self.sortCode isEqualToString:self.sorts[self.selectedSortIndex][@"code"]];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            } else {
                cell.titleLabel.text = self.sorts[indexPath.row][@"name"];
                cell.on = [self.sortCode isEqualToString:self.sorts[indexPath.row][@"code"]];
                if (indexPath.row == self.selectedSortIndex) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                } else {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
            }
            return cell;
            break;

        }
        case 1:
        {
            cell.toggleSwitch.hidden = YES;
            if (!self.isShowingDistance) {
                cell.titleLabel.text = self.distances[self.selectedDistanceIndex][@"name"];
                cell.on = [self.distanceCode isEqualToString:self.distances[self.selectedDistanceIndex][@"code"]];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            } else {
                cell.titleLabel.text = self.distances[indexPath.row][@"name"];
                cell.on = [self.distanceCode isEqualToString:self.distances[indexPath.row][@"code"]];
                if (indexPath.row == self.selectedDistanceIndex) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                } else {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
            }
            return cell;
            break;
            
        }
        case 2:
        {
            cell.titleLabel.text = self.deals[indexPath.row];
            cell.on = [self.dealCode isEqualToString:@"true"];
            return cell;
            break;
            
        }
        case 3:
        {
            if (!self.isShowingCategories && indexPath.row == [self.categories_min count]) {
                cell.toggleSwitch.hidden = YES;
                cell.titleLabel.text = @"See All";
                cell.titleLabel.textColor = [UIColor darkGrayColor];
                cell.titleLabel.frame = CGRectMake(0, 0, cell.bounds.size.width, cell.bounds.size.height);
                cell.titleLabel.textAlignment = NSTextAlignmentCenter;
            } else {
                NSArray *categoryArray = self.categories_min;
                if (self.isShowingCategories) {
                    categoryArray = self.categories;
                }
                cell.titleLabel.text = categoryArray[indexPath.row][@"name"];
                cell.on = [self.selectedCategories containsObject:categoryArray[indexPath.row]];
            }

            return cell;
            break;
        }
            
        default:
            break;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
        {
            if (self.isShowingSort) {
                self.selectedSortIndex = indexPath.row;
            }
            
            self.sortCode = self.sorts[indexPath.row][@"code"];
            self.isShowingSort = !self.isShowingSort;
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
            
            break;
        }
        case 1:
        {
            if (self.isShowingDistance) {
                self.selectedDistanceIndex = indexPath.row;
            }

            self.distanceCode = self.distances[indexPath.row][@"code"];
            self.isShowingDistance = !self.isShowingDistance;
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
            
            break;
        }
        case 3:
        {
            if (!self.isShowingCategories && indexPath.row == [self.categories_min count]) {
                self.isShowingCategories = YES;
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationNone];
            }
        }
        default:
            break;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionTitles.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.sectionTitles objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
        {
            if (!self.isShowingSort) {
                return 1;
            } else {
                return [self.sorts count];
            }
            break;
        }
        case 1:
        {
            if (!self.isShowingDistance) {
                return 1;
            } else {
                return [self.distances count];
            }
            break;
        }
        case 2:
        {
            return [self.deals count];
            break;
        }
        case 3:
        {
            if (!self.isShowingCategories) {
                return [self.categories_min count] + 1;
            } else {
                return [self.categories count];
            }
            break;
        }
        default:
            break;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 20.0;
}


#pragma mark - Switch cell delegate methods

- (void)switchCell:(SwitchCell *)cell didUpdateValue:(BOOL)value {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    switch (indexPath.section) {
        case 0:
        {
            NSDictionary *sort = self.sorts[indexPath.row];
            self.sortCode = sort[@"code"];
            break;
        }
        case 1:
        {
            NSDictionary *distance = self.distances[indexPath.row];
            self.sortCode = distance[@"code"];
            break;
        }
        case 2:
        {
            if (value) {
                self.dealCode = @"true";
            } else {
                self.dealCode = @"false";
            }
            break;
        }
        case 3:
        {
            NSArray *categoryArray = self.categories_min;
            if (self.isShowingCategories) {
                categoryArray = self.categories;
            }
            
            if (value) {
                [self.selectedCategories addObject:categoryArray[indexPath.row]];
            } else {
                [self.selectedCategories removeObject:categoryArray[indexPath.row]];
            }
            break;
        }
        default:
            break;
    }
    
}

#pragma mark - Private methods

- (NSDictionary *)filters {
    NSMutableDictionary *filters = [NSMutableDictionary dictionary];
    
    if (self.sortCode ) {
        [filters setObject:self.sortCode forKey:@"sort"];
    }
    if (self.distanceCode ) {
        [filters setObject:self.distanceCode forKey:@"radius_filter"];
    }
    if (self.dealCode ) {
        [filters setObject:self.dealCode forKey:@"deals_filter"];
    }

    if (self.selectedCategories.count > 0) {
        NSMutableArray *names = [NSMutableArray array];
        for (NSDictionary *category in self.selectedCategories) {
            [names addObject:category[@"code"]];
        }
        NSString *categoryFilter = [names componentsJoinedByString:@","];
        [filters setObject:categoryFilter forKey:@"category_filter"];
    }
    return filters;
}

- (void)onCancelButton {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onApplyButton {
    [self.delegate filtersViewController:self didChangeFilters:self.filters];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)initCategories {
    self.sectionTitles = @[@"Sort", @"Distance", @"Most Popular", @"Category"];

    self.sorts = @[@{@"name" : @"Best Match", @"code": @"0"},
                   @{@"name" : @"Distance", @"code": @"1"},
                   @{@"name" : @"Rating", @"code": @"2"}];

    self.distances = @[@{@"name" : @"Best Match", @"code": @""},
                       @{@"name" : @"0.3 mi", @"code": @"482.803"},
                       @{@"name" : @"1 mi", @"code": @"1609.34"},
                       @{@"name" : @"5 mi", @"code": @"8046.72"},
                       @{@"name" : @"20 mi", @"code": @"32186.9"}];
    
    self.deals = @[@"Offering a Deal"];
    
    self.categories_min = @[@{@"name" : @"American, New", @"code": @"newamerican" },
                            @{@"name" : @"Breakfast & Brunch", @"code": @"breakfast_brunch" },
                            @{@"name" : @"Chinese", @"code": @"chinese" },
                            @{@"name" : @"Fast Food", @"code": @"hotdogs" },
                            @{@"name" : @"French", @"code": @"french" },
                            @{@"name" : @"Indian", @"code": @"indpak" },
                            @{@"name" : @"Japanese", @"code": @"japanese" },
                            @{@"name" : @"Pizza", @"code": @"pizza" },
                            @{@"name" : @"Steakhouses", @"code": @"steak" },
                            @{@"name" : @"Thai", @"code": @"thai" }];

    self.categories = @[@{@"name" : @"Afghan", @"code": @"afghani" },
                        @{@"name" : @"African", @"code": @"african" },
                        @{@"name" : @"Senegalese", @"code": @"senegalese" },
                        @{@"name" : @"South African", @"code": @"southafrican" },
                        @{@"name" : @"American, New", @"code": @"newamerican" },
                        @{@"name" : @"American, Traditional", @"code": @"tradamerican" },
                        @{@"name" : @"Arabian", @"code": @"arabian" },
                        @{@"name" : @"Argentine", @"code": @"argentine" },
                        @{@"name" : @"Armenian", @"code": @"armenian" },
                        @{@"name" : @"Asian Fusion", @"code": @"asianfusion" },
                        @{@"name" : @"Australian", @"code": @"australian" },
                        @{@"name" : @"Austrian", @"code": @"austrian" },
                        @{@"name" : @"Bangladeshi", @"code": @"bangladeshi" },
                        @{@"name" : @"Barbeque", @"code": @"bbq" },
                        @{@"name" : @"Basque", @"code": @"basque" },
                        @{@"name" : @"Belgian", @"code": @"belgian" },
                        @{@"name" : @"Brasseries", @"code": @"brasseries" },
                        @{@"name" : @"Brazilian", @"code": @"brazilian" },
                        @{@"name" : @"Breakfast & Brunch", @"code": @"breakfast_brunch" },
                        @{@"name" : @"British", @"code": @"british" },
                        @{@"name" : @"Buffets", @"code": @"buffets" },
                        @{@"name" : @"Burgers", @"code": @"burgers" },
                        @{@"name" : @"Burmese", @"code": @"burmese" },
                        @{@"name" : @"Cafes", @"code": @"cafes" },
                        @{@"name" : @"Cafeteria", @"code": @"cafeteria" },
                        @{@"name" : @"Cajun/Creole", @"code": @"cajun" },
                        @{@"name" : @"Cambodian", @"code": @"cambodian" },
                        @{@"name" : @"Caribbean", @"code": @"caribbean" },
                        @{@"name" : @"Dominican", @"code": @"dominican" },
                        @{@"name" : @"Haitian", @"code": @"haitian" },
                        @{@"name" : @"Puerto Rican", @"code": @"puertorican" },
                        @{@"name" : @"Trinidadian", @"code": @"trinidadian" },
                        @{@"name" : @"Catalan", @"code": @"catalan" },
                        @{@"name" : @"Cheesesteaks", @"code": @"cheesesteaks" },
                        @{@"name" : @"Chicken Shop", @"code": @"chickenshop" },
                        @{@"name" : @"Chicken Wings", @"code": @"chicken_wings" },
                        @{@"name" : @"Chinese", @"code": @"chinese" },
                        @{@"name" : @"Cantonese", @"code": @"cantonese" },
                        @{@"name" : @"Dim Sum", @"code": @"dimsum" },
                        @{@"name" : @"Shanghainese", @"code": @"shanghainese" },
                        @{@"name" : @"Szechuan", @"code": @"szechuan" },
                        @{@"name" : @"Comfort Food", @"code": @"comfortfood" },
                        @{@"name" : @"Corsican", @"code": @"corsican" },
                        @{@"name" : @"Creperies", @"code": @"creperies" },
                        @{@"name" : @"Cuban", @"code": @"cuban" },
                        @{@"name" : @"Czech", @"code": @"czech" },
                        @{@"name" : @"Delis", @"code": @"delis" },
                        @{@"name" : @"Diners", @"code": @"diners" },
                        @{@"name" : @"Fast Food", @"code": @"hotdogs" },
                        @{@"name" : @"Filipino", @"code": @"filipino" },
                        @{@"name" : @"Fish & Chips", @"code": @"fishnchips" },
                        @{@"name" : @"Fondue", @"code": @"fondue" },
                        @{@"name" : @"Food Court", @"code": @"food_court" },
                        @{@"name" : @"Food Stands", @"code": @"foodstands" },
                        @{@"name" : @"French", @"code": @"french" },
                        @{@"name" : @"Gastropubs", @"code": @"gastropubs" },
                        @{@"name" : @"German", @"code": @"german" },
                        @{@"name" : @"Gluten-Free", @"code": @"gluten_free" },
                        @{@"name" : @"Greek", @"code": @"greek" },
                        @{@"name" : @"Halal", @"code": @"halal" },
                        @{@"name" : @"Hawaiian", @"code": @"hawaiian" },
                        @{@"name" : @"Himalayan/Nepalese", @"code": @"himalayan" },
                        @{@"name" : @"Hong Kong Style Cafe", @"code": @"hkcafe" },
                        @{@"name" : @"Hot Dogs", @"code": @"hotdog" },
                        @{@"name" : @"Hot Pot", @"code": @"hotpot" },
                        @{@"name" : @"Hungarian", @"code": @"hungarian" },
                        @{@"name" : @"Iberian", @"code": @"iberian" },
                        @{@"name" : @"Indian", @"code": @"indpak" },
                        @{@"name" : @"Indonesian", @"code": @"indonesian" },
                        @{@"name" : @"Irish", @"code": @"irish" },
                        @{@"name" : @"Italian", @"code": @"italian" },
                        @{@"name" : @"Japanese", @"code": @"japanese" },
                        @{@"name" : @"Ramen", @"code": @"ramen" },
                        @{@"name" : @"Teppanyaki", @"code": @"teppanyaki" },
                        @{@"name" : @"Korean", @"code": @"korean" },
                        @{@"name" : @"Kosher", @"code": @"kosher" },
                        @{@"name" : @"Laotian", @"code": @"laotian" },
                        @{@"name" : @"Latin American", @"code": @"latin" },
                        @{@"name" : @"Colombian", @"code": @"colombian" },
                        @{@"name" : @"Salvadorean", @"code": @"salvadorean" },
                        @{@"name" : @"Venezuelan", @"code": @"venezuelan" },
                        @{@"name" : @"Live/Raw Food", @"code": @"raw_food" },
                        @{@"name" : @"Malaysian", @"code": @"malaysian" },
                        @{@"name" : @"Mediterranean", @"code": @"mediterranean" },
                        @{@"name" : @"Falafel", @"code": @"falafel" },
                        @{@"name" : @"Mexican", @"code": @"mexican" },
                        @{@"name" : @"Middle Eastern", @"code": @"mideastern" },
                        @{@"name" : @"Egyptian", @"code": @"egyptian" },
                        @{@"name" : @"Lebanese", @"code": @"lebanese" },
                        @{@"name" : @"Modern European", @"code": @"modern_european" },
                        @{@"name" : @"Mongolian", @"code": @"mongolian" },
                        @{@"name" : @"Moroccan", @"code": @"moroccan" },
                        @{@"name" : @"Pakistani", @"code": @"pakistani" },
                        @{@"name" : @"Persian/Iranian", @"code": @"persian" },
                        @{@"name" : @"Peruvian", @"code": @"peruvian" },
                        @{@"name" : @"Pizza", @"code": @"pizza" },
                        @{@"name" : @"Polish", @"code": @"polish" },
                        @{@"name" : @"Portuguese", @"code": @"portuguese" },
                        @{@"name" : @"Poutineries", @"code": @"poutineries" },
                        @{@"name" : @"Russian", @"code": @"russian" },
                        @{@"name" : @"Salad", @"code": @"salad" },
                        @{@"name" : @"Sandwiches", @"code": @"sandwiches" },
                        @{@"name" : @"Scandinavian", @"code": @"scandinavian" },
                        @{@"name" : @"Scottish", @"code": @"scottish" },
                        @{@"name" : @"Seafood", @"code": @"seafood" },
                        @{@"name" : @"Singaporean", @"code": @"singaporean" },
                        @{@"name" : @"Slovakian", @"code": @"slovakian" },
                        @{@"name" : @"Soul Food", @"code": @"soulfood" },
                        @{@"name" : @"Soup", @"code": @"soup" },
                        @{@"name" : @"Southern", @"code": @"southern" },
                        @{@"name" : @"Spanish", @"code": @"spanish" },
                        @{@"name" : @"Sri Lankan", @"code": @"srilankan" },
                        @{@"name" : @"Steakhouses", @"code": @"steak" },
                        @{@"name" : @"Sushi Bars", @"code": @"sushi" },
                        @{@"name" : @"Taiwanese", @"code": @"taiwanese" },
                        @{@"name" : @"Tapas Bars", @"code": @"tapas" },
                        @{@"name" : @"Tapas/Small Plates", @"code": @"tapasmallplates" },
                        @{@"name" : @"Tex-Mex", @"code": @"tex-mex" },
                        @{@"name" : @"Thai", @"code": @"thai" },
                        @{@"name" : @"Turkish", @"code": @"turkish" },
                        @{@"name" : @"Ukrainian", @"code": @"ukrainian" },
                        @{@"name" : @"Uzbek", @"code": @"uzbek" },
                        @{@"name" : @"Vegan", @"code": @"vegan" },
                        @{@"name" : @"Vegetarian", @"code": @"vegetarian" },
                        @{@"name" : @"Vietnamese", @"code": @"vietnamese" }];
}

@end
