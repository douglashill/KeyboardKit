// Douglas Hill, January 2021

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UICollectionView (KBDDataSource)

/// The data source of the collection view if it’s a diff-able data source
/// created in Objective-C. This property is nil if the data source is not
/// a diff-able data source or is a diff-able data source created in Swift.
@property (nonatomic, nullable, readonly) UICollectionViewDiffableDataSource *kbd_objcDiffableDataSource API_AVAILABLE(ios(13.0));

@end

@interface UITableView (KBDDataSource)

/// The data source of the table view if it’s a diff-able data source
/// created in Objective-C. This property is nil if the data source is not
/// a diff-able data source or is a diff-able data source created in Swift.
@property (nonatomic, nullable, readonly) UITableViewDiffableDataSource *kbd_objcDiffableDataSource API_AVAILABLE(ios(13.0));

@end

NS_ASSUME_NONNULL_END
