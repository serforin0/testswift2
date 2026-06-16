#import "ContactListViewController.h"
#import "ContactListViewModel.h"
#import "ContactTableViewCell.h"
#import "ContactosApp-Swift.h"

static NSString * const kContactCellIdentifier = @"ContactCell";
static const CGFloat kSearchBarHeight = 56.0;

@interface ContactListViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) ContactListViewModel *viewModel;
@property (nonatomic, strong) UIBarButtonItem *deleteButton;
@property (nonatomic, strong) UIBarButtonItem *addContactBarButton;

@end

@implementation ContactListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Contactos";
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    self.viewModel = [[ContactListViewModel alloc] init];

    __weak typeof(self) weakSelf = self;
    self.viewModel.onDataChanged = ^{
        [weakSelf reloadTable];
    };

    [self setupNavigationBar];
    [self setupTableView];
    [self setupSearchBar];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.viewModel reload];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self layoutSearchBarHeaderIfNeeded];
}

#pragma mark - Setup

- (void)setupNavigationBar {
    self.addContactBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Nuevo"
                                                      style:UIBarButtonItemStylePlain
                                                     target:self
                                                     action:@selector(newContactTapped)];
    self.addContactBarButton.accessibilityIdentifier = @"newContactButton";

    self.deleteButton = [[UIBarButtonItem alloc] initWithTitle:@"Borrar"
                                                         style:UIBarButtonItemStylePlain
                                                        target:self
                                                        action:@selector(toggleDeleteMode)];

    self.navigationItem.leftBarButtonItem = self.addContactBarButton;
    self.navigationItem.rightBarButtonItem = self.deleteButton;
}

- (void)setupSearchBar {
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, kSearchBarHeight)];
    self.searchBar.placeholder = @"Buscar por nombre, apellido o teléfono";
    self.searchBar.delegate = self;
    self.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.searchBar.returnKeyType = UIReturnKeySearch;
    self.searchBar.accessibilityIdentifier = @"contactSearchBar";
    self.tableView.tableHeaderView = self.searchBar;
}

- (void)layoutSearchBarHeaderIfNeeded {
    UIView *header = self.tableView.tableHeaderView;
    if (header == nil) { return; }

    CGFloat width = self.tableView.bounds.size.width;
    if (width <= 0) { return; }

    if (fabs(header.frame.size.width - width) > 0.5) {
        header.frame = CGRectMake(0, 0, width, kSearchBarHeight);
        self.tableView.tableHeaderView = header;
    }
}

- (void)setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 72.0;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.tableView.accessibilityIdentifier = @"contactsTable";
    [self.tableView registerClass:[ContactTableViewCell class] forCellReuseIdentifier:kContactCellIdentifier];

    [self.view addSubview:self.tableView];

    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
}

#pragma mark - Actions

- (void)newContactTapped {
    AddContactViewController *addViewController = [[AddContactViewController alloc] init];

    __weak typeof(self) weakSelf = self;
    addViewController.onCancel = ^{
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    };

    addViewController.onSave = ^(Contact *contact) {
        [weakSelf.viewModel addContact:contact];
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    };

    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:addViewController];
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)toggleDeleteMode {
    BOOL isEditing = !self.tableView.isEditing;
    [self.tableView setEditing:isEditing animated:YES];
    self.deleteButton.title = isEditing ? @"Listo" : @"Borrar";
    self.addContactBarButton.enabled = !isEditing;
}

#pragma mark - Search

- (void)updateSearchWithQuery:(NSString *)query {
    self.viewModel.searchQuery = query ?: @"";
}

- (void)reloadTable {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self updateSearchWithQuery:searchText];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [self updateSearchWithQuery:searchBar.text];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = @"";
    [searchBar resignFirstResponder];
    [self updateSearchWithQuery:@""];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kContactCellIdentifier forIndexPath:indexPath];
    Contact *contact = [self.viewModel contactAtIndex:indexPath.row];
    [cell configureWithContact:contact];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.viewModel deleteContactAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.isEditing) { return; }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
