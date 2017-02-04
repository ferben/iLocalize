//
//  TableViewCustomDefaultDelegate.h
//  iLocalize
//
//  Created by Jean on 1/10/09.
//  Copyright 2009 Arizona Software. All rights reserved.
//

#import "Protocols.h"

@class TableViewCustom;
@class TextViewCustom;

@protocol AZTableViewDelegate

@optional
- (BOOL)textView:(NSTextView *)tv shouldChangeTextInRange:(NSRange)affectedCharRange replacementString:(NSString *)replacementString;
- (void)tableViewTextDidBeginEditing:(NSTableView*)tv columnIdentifier:(NSString*)identifier rowIndex:(NSInteger)rowIndex textView:(TextViewCustom*)textView;
- (void)tableViewDeleteSelectedRows:(NSTableView*)tv;
- (void)customTableView:(NSTableView *)aTableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
- (void)tableViewTextDidEndEditing:(NSTableView*)tv;
- (void)tableViewTextDidEndEditing:(NSTableView*)tv textView:(TextViewCustom*)textView;
- (void)tableViewDidHitEnterKey:(NSTableView*)tv;
@end

@interface TableViewCustomDefaultDelegate : NSObject<NSTableViewDelegate>
{
}

@property (weak) TableViewCustom *tableView;
@property (weak) id<NSTableViewDelegate,AZTableViewDelegate> childDelegate;

- (void)customTableView:(NSTableView *)aTableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
- (BOOL)textView:(NSTextView *)tv shouldChangeTextInRange:(NSRange)affectedCharRange replacementString:(NSString *)replacementString;

- (void)tableViewTextDidBeginEditing:(NSTableView*)tv columnIdentifier:(NSString*)identifier rowIndex:(NSInteger)rowIndex textView:(TextViewCustom*)textView;

- (void)tableViewDeleteSelectedRows:(NSTableView*)tableView;
- (void)tableViewTextDidEndEditing:(NSTableView*)tv;
- (void)tableViewTextDidEndEditing:(NSTableView*)tv textView:(TextViewCustom*)textView;
- (void)tableViewDidHitEnterKey:(NSTableView*)tv;

@end
