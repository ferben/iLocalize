
#import "ImageAndTextCell.h"

@implementation ImageAndTextCell

#define kIconImageSize		16.0

#define kImageOriginXOffset 3
#define kImageOriginYOffset 1

- (id)init
{
	if(self = [super init]) {
		[self setFont:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]]];		
		[self setLineBreakMode:NSLineBreakByWordWrapping];
		[self setTruncatesLastVisibleLine:YES];
	}
	return self;
}

- (void)dealloc
{
    image = nil;
}

- (id)copyWithZone:(NSZone*)zone
{
    ImageAndTextCell *cell = (ImageAndTextCell*)[super copyWithZone:zone];
    cell->image = image;
    return cell;
}

- (void)setImage:(NSImage*)anImage
{
    if (anImage != image)
	{
        image = anImage;
		[image setSize:NSMakeSize(kIconImageSize, kIconImageSize)];
    }
}

- (NSImage*)image
{
    return image;
}

- (BOOL)isGroupCell
{
    return ([self image] == nil && [[self title] length] > 0);
}

- (void)editWithFrame:(NSRect)aRect inView:(NSView*)controlView editor:(NSText*)textObj delegate:(id)anObject event:(NSEvent*)theEvent
{
	NSRect textFrame = [self titleRectForBounds:aRect];
	[super editWithFrame:textFrame inView:controlView editor:textObj delegate:anObject event:theEvent];
}

- (void)selectWithFrame:(NSRect)aRect inView:(NSView*)controlView editor:(NSText*)textObj delegate:(id)anObject start:(NSInteger)selStart length:(NSInteger)selLength
{
	NSRect textFrame = [self titleRectForBounds:aRect];
	[super selectWithFrame:textFrame inView:controlView editor:textObj delegate:anObject start:selStart length:selLength];
}

- (NSRect)titleRectForBounds:(NSRect)theRect {
	
    NSSize titleSize = [[self attributedStringValue] size];
	double delta = (theRect.size.height - titleSize.height)/2.0;
	theRect.origin.x += image?3:0;
    theRect.origin.y += delta;
	theRect.size.height -= 2*delta;	
    return theRect;
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView*)controlView
{
	if (image != nil)
	{
		// the cell has an image: draw the normal item cell
		NSSize imageSize;
        NSRect imageFrame;

        imageSize = [image size];
        NSDivideRect(cellFrame, &imageFrame, &cellFrame, 3 + imageSize.width, NSMinXEdge);
 
        imageFrame.size = imageSize;
        [image drawInRect:imageFrame fraction:1];

		NSRect newFrame = [self titleRectForBounds:cellFrame];
		[super drawWithFrame:newFrame inView:controlView];
    }
	else
	{
		if ([self isGroupCell])
		{
			[super drawWithFrame:[self titleRectForBounds:cellFrame] inView:controlView];
		}
	}
}

- (NSSize)cellSize
{
    NSSize cellSize = [super cellSize];
    cellSize.width += (image ? [image size].width : 0) + 3;
    return cellSize;
}

@end

