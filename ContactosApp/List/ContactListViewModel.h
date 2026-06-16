#import <Foundation/Foundation.h>

@class Contact;

NS_ASSUME_NONNULL_BEGIN

@interface ContactListViewModel : NSObject

@property (nonatomic, copy, nullable) NSString *searchQuery;
@property (nonatomic, copy, readonly) NSArray<Contact *> *displayedContacts;
@property (nonatomic, copy, nullable) void (^onDataChanged)(void);

- (void)reload;
- (NSInteger)count;
- (nullable Contact *)contactAtIndex:(NSInteger)index;
- (void)addContact:(Contact *)contact;
- (void)deleteContactAtIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
