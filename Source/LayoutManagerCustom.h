//
//  LayoutManagerCustom.h
//  iLocalize3
//
//  Created by Jean on 28.03.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

@interface LayoutManagerCustom : NSLayoutManager {    
    NSString *spaceCharacter;
    NSString *tabCharacter;
    NSString *newLineCharacter;
        
    BOOL showInvisibleCharacters;
}
- (void)setShowInvisibleCharacters:(BOOL)flag;
@end
