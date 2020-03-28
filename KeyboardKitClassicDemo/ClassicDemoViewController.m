// Douglas Hill, March 2020

#import "ClassicDemoViewController.h"
@import KeyboardKit;

#define let __auto_type const

@interface ClassicDemoViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, readonly) NSNumberFormatter *numberFormatter;
@property (nonatomic, readonly) KeyboardTableView *tableView;

@end

@implementation ClassicDemoViewController

static let cellReuseIdentifier = @"a";

@synthesize numberFormatter = _numberFormatter;
- (NSNumberFormatter *)numberFormatter {
    if (_numberFormatter == nil) {
        _numberFormatter = [[NSNumberFormatter alloc] init];
        [_numberFormatter setNumberStyle:NSNumberFormatterSpellOutStyle];
    }
    return _numberFormatter;
}

@synthesize tableView = _tableView;
- (KeyboardTableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[KeyboardTableView alloc] init];
        [_tableView setDataSource:self];
        [_tableView setDelegate:self];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellReuseIdentifier];
    }
    return _tableView;
}

- (void)loadView {
    [self setView:[self tableView]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [[self view] becomeFirstResponder];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    let cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier forIndexPath:indexPath];
    [[cell textLabel] setText:[[self numberFormatter] stringFromNumber:@(indexPath.row + 1)]];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    let detailViewController = [[UIViewController alloc] init];
    [[detailViewController view] setBackgroundColor:[UIColor grayColor]];

    let title = [[[tableView cellForRowAtIndexPath:indexPath] textLabel] text];
    [detailViewController setTitle:title];

    [[self navigationController] pushViewController:detailViewController animated:YES];
}

@end
