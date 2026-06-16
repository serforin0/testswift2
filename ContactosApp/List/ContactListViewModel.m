#import "ContactListViewModel.h"
#import "ContactosApp-Swift.h"

@interface ContactListViewModel () <ContactRepositoryDelegate>
@property (nonatomic, strong) ContactRepository *repository;
@property (nonatomic, copy, readwrite) NSArray<Contact *> *displayedContacts;
@end

@implementation ContactListViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _repository = ContactRepository.shared;
        _repository.delegate = self;
        _searchQuery = @"";
        _displayedContacts = @[];
        [self reload];
    }
    return self;
}

- (void)reload {
    if (self.searchQuery.length == 0) {
        self.displayedContacts = [self.repository allContacts];
    } else {
        self.displayedContacts = [self.repository filteredContactsMatching:self.searchQuery];
    }

    if (self.onDataChanged) {
        self.onDataChanged();
    }
}

- (void)setSearchQuery:(NSString *)searchQuery {
    _searchQuery = [searchQuery copy];
    [self reload];
}

- (NSInteger)count {
    return self.displayedContacts.count;
}

- (Contact *)contactAtIndex:(NSInteger)index {
    if (index < 0 || index >= (NSInteger)self.displayedContacts.count) {
        return nil;
    }
    return self.displayedContacts[index];
}

- (void)addContact:(Contact *)contact {
    [self.repository add:contact];
}

- (void)deleteContactAtIndex:(NSInteger)index {
    Contact *contact = [self contactAtIndex:index];
    if (contact == nil) { return; }
    [self.repository deleteContactsWithIDs:@[contact.id]];
}

#pragma mark - ContactRepositoryDelegate

- (void)contactRepositoryDidChange {
    [self reload];
}

@end
