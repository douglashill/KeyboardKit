// Douglas Hill, January 2021

#if SWIFT_PACKAGE
#import "DiffableDataSources.h"
#else
#import <KeyboardKit/DiffableDataSources.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@implementation UICollectionView (KBDDataSource)

- (nullable UICollectionViewDiffableDataSource *)kbd_objcDiffableDataSource {
    id<UICollectionViewDataSource> dataSource = [self dataSource];
    if ([dataSource isKindOfClass:[UICollectionViewDiffableDataSource class]]) {
        return dataSource;
    } else {
        return nil;
    }
}

@end

@implementation UITableView (KBDDataSource)

- (nullable UITableViewDiffableDataSource *)kbd_objcDiffableDataSource {
    id<UITableViewDataSource> dataSource = [self dataSource];
    if ([dataSource isKindOfClass:[UITableViewDiffableDataSource class]]) {
        return dataSource;
    } else {
        return nil;
    }
}

@end

NS_ASSUME_NONNULL_END
