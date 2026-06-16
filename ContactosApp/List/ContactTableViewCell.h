#import <UIKit/UIKit.h>

@class Contact;

@interface ContactTableViewCell : UITableViewCell

- (void)configureWithContact:(Contact *)contact;

@end
