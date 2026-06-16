#import "ContactTableViewCell.h"
#import "ContactosApp-Swift.h"

@interface ContactTableViewCell ()
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *phoneLabel;
@end

@implementation ContactTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    self.avatarImageView = [[UIImageView alloc] init];
    self.avatarImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.avatarImageView.clipsToBounds = YES;
    self.avatarImageView.layer.cornerRadius = 28.0;

    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.nameLabel.font = [UIFont boldSystemFontOfSize:17.0];

    self.phoneLabel = [[UILabel alloc] init];
    self.phoneLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.phoneLabel.font = [UIFont systemFontOfSize:14.0];
    self.phoneLabel.textColor = [UIColor secondaryLabelColor];

    UIStackView *textStack = [[UIStackView alloc] initWithArrangedSubviews:@[self.nameLabel, self.phoneLabel]];
    textStack.translatesAutoresizingMaskIntoConstraints = NO;
    textStack.axis = UILayoutConstraintAxisVertical;
    textStack.spacing = 4.0;

    [self.contentView addSubview:self.avatarImageView];
    [self.contentView addSubview:textStack];

    [NSLayoutConstraint activateConstraints:@[
        [self.avatarImageView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16.0],
        [self.avatarImageView.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
        [self.avatarImageView.widthAnchor constraintEqualToConstant:56.0],
        [self.avatarImageView.heightAnchor constraintEqualToConstant:56.0],

        [textStack.leadingAnchor constraintEqualToAnchor:self.avatarImageView.trailingAnchor constant:12.0],
        [textStack.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
        [textStack.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16.0]
    ]];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.avatarImageView.image = nil;
    self.nameLabel.text = nil;
    self.phoneLabel.text = nil;
}

- (void)configureWithContact:(Contact *)contact {
    self.nameLabel.text = contact.fullName;
    self.phoneLabel.text = contact.phone;
    [self loadImageFromURLString:contact.imageURL];
}

- (void)loadImageFromURLString:(NSString *)urlString {
    NSURL *url = [NSURL URLWithString:urlString];
    if (url == nil) {
        self.avatarImageView.image = [UIImage systemImageNamed:@"person.circle"];
        return;
    }

    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url
                                                             completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data == nil || error != nil) { return; }

        UIImage *image = [UIImage imageWithData:data];
        if (image == nil) { return; }

        dispatch_async(dispatch_get_main_queue(), ^{
            self.avatarImageView.image = image;
        });
    }];
    [task resume];
}

@end
