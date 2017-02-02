@protocol PreferencesData
- (void)setPreferencesData:(id)data;
- (id)preferencesData;
@end

@protocol PopupTableColumnDelegate
- (id)popUpContentForRow:(NSInteger)row;
@end

@protocol MenuForTableViewProtocol
- (NSMenu *)menuForTableView:(NSTableView *)tv column:(NSInteger)column row:(NSInteger)row;
@end
