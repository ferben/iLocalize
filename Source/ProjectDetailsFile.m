//
//  ProjectDetailsFile.m
//  iLocalize
//
//  Created by Jean on 12/28/08.
//  Copyright 2008 Arizona Software. All rights reserved.
//

#import "ProjectDetailsFile.h"
#import "FileController.h"

static NSDateFormatter *MediumStyleDateFormatter = nil;
static NSDateFormatter *NoStyleDateFormatter = nil;

@implementation ProjectDetailsFile

+ (void)initialize {
    if (self == [ProjectDetailsFile class]) {
        MediumStyleDateFormatter = [[NSDateFormatter alloc] init];
        [MediumStyleDateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [MediumStyleDateFormatter setTimeStyle:NSDateFormatterShortStyle];
        
        NoStyleDateFormatter = [[NSDateFormatter alloc] init];
        [NoStyleDateFormatter setDateStyle:NSDateFormatterNoStyle];
        [NoStyleDateFormatter setTimeStyle:NSDateFormatterShortStyle];
    }
}

- (NSTextStorage*)textStorage
{
    return [mTextView textStorage];
}

- (NSString*)stringForDate:(NSDate*)date
{
    if (nil == date) {
        return @"?";
    }
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay
                                               fromDate:date];    
    NSDateComponents *today = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay
                                               fromDate:[NSDate date]];    
    if([components year] == [today year] && [components month] == [today month] && [components day] == [today day]) {
        return [NSString stringWithFormat:NSLocalizedString(@"Today at %@", nil), [NoStyleDateFormatter stringFromDate:date]];
    } else {
        return [MediumStyleDateFormatter stringFromDate:date];
    }
}

- (void)update
{
    [self begin];

    NSArray *fcs = [self.projectWC selectedFileControllers];
    FileController *fc = [fcs firstObject];
    switch([fcs count]) {
        case 0:
            [self addDetail:NSLocalizedString(@"(no file selected)", @"File Information")];
            break;
        case 1:
            if([fc totalContentCount] >= 0) {
                [self addDetail:NSLocalizedString(@"Strings", @"File Information") value:[NSString stringWithFormat:@"%ld", [[fc stringControllers] count]]];                    
            }
            if(![fc isLocal] && [fc supportsEncoding]) {
                [self addDetail:NSLocalizedString(@"Encoding", @"File Information") value:[fc encodingName]];                
            }
            [self addDetail:NSLocalizedString(@"Path", @"File Information") value:[fc relativeFilePath]];
            [self addDetail:NSLocalizedString(@"Modified", @"File Information") value:[self stringForDate:[[fc absoluteFilePath] pathModificationDate]]];    
            break;
        default:
            [self addDetail:NSLocalizedString(@"(multiple files selected)", @"File Information")];
            break;
    }
    
    [self commit];
}

@end
