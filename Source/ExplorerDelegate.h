
@class ExplorerItem;

@protocol ExplorerDelegate

- (void)explorerItemDidAdd:(ExplorerItem *)filter;
- (void)explorerItemDidChange:(ExplorerItem *)filter;
- (void)explorerItemDidRemove:(ExplorerItem *)filter;

@end
