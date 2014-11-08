
@protocol PreferencesData
- (void)setPreferencesData:(id)data;
- (id)preferencesData;
@end

@protocol PopupTableColumnDelegate
- (id)popUpContentForRow:(int)row;
@end

@protocol MenuForTableViewProtocol
- (NSMenu*)menuForTableView:(NSTableView*)tv column:(int)column row:(int)row;
@end

