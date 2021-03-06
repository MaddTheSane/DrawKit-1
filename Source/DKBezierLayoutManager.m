/**
 @author Contributions from the community; see CONTRIBUTORS.md; see CONTRIBUTORS
 @date 2005-2016
 @copyright This software is released subject to licensing conditions as detailed in LICENSE, which must accompany this source file.
 */

#import "DKBezierLayoutManager.h"

@implementation DKBezierLayoutManager
@synthesize textPath = mPath;

- (NSArray*)glyphPathsForContainer:(NSTextContainer*)container usedSize:(NSSize*)aSize
{
	// this method can be used to return a list of bezier paths, each representing one glyph. The relative positions of the paths are as laid out by the layout manager
	// in the given container. If <usedSize> isn't nil, the size actually used by the laid out text is returned also. This has limited utility, but is used for example
	// by DKTextShape to return glyphs separately so they can be converted to a grouped shape, allowing the individual glyphs to be recovered and manipulated individually
	// as graphics. Note that <container> should already belong to the layout manager's list of containers; prior to calling, its size should be set as required.

	NSMutableArray* array = [NSMutableArray array];
	NSRange glyphRange;

	// lay out the text and find out how much of it fits in the container.

	glyphRange = [self glyphRangeForTextContainer:container];

	if (aSize)
		*aSize = [self usedRectForTextContainer:container].size;

	NSBezierPath* temp;
	NSRect fragRect;
	NSRange grange;
	NSUInteger glyphIndex = 0;

	if (glyphRange.length > 0) {
		while (glyphIndex < glyphRange.length) {
			// look at the formatting applied to individual glyphs so that the path applies that formatting as necessary.

			@autoreleasepool {

				NSUInteger g;
				NSPoint gloc, ploc;
				NSFont* font;

				fragRect = [self lineFragmentRectForGlyphAtIndex:glyphIndex
												  effectiveRange:&grange];

				for (g = grange.location; g < grange.location + grange.length; ++g) {
					temp = [NSBezierPath bezierPath];
					ploc = gloc = [self locationForGlyphAtIndex:g];

					ploc.x -= fragRect.origin.x;
					ploc.y = fragRect.origin.y;

					font = [[[self textStorage] attributesAtIndex:g
												   effectiveRange:NULL] objectForKey:NSFontAttributeName];

					[temp moveToPoint:ploc];
					if (@available(macOS 10.13, *)) {
						[temp appendBezierPathWithCGGlyph:[self CGGlyphAtIndex:g]
												   inFont:font];
					} else {
						[temp appendBezierPathWithGlyph:[self glyphAtIndex:g]
												 inFont:font];
					}
					// need to vertically flip and offset each glyph as it is created. The glyph is flipped around its given location to
					// ensure that any unusual baseline requirements are taken into consideration.

					NSAffineTransform* xform = [NSAffineTransform transform];
					[xform translateXBy:ploc.x
									yBy:ploc.y];
					[xform scaleXBy:1.0
								yBy:-1.0];
					[xform translateXBy:-ploc.x
									yBy:-ploc.y];
					[temp transformUsingAffineTransform:xform];

					[array addObject:temp];
				}
				// next line:
				glyphIndex += grange.length;
			}
		}
	}

	return array;
}

#pragma mark -
#pragma mark - as a NSLayoutManager

- (void)showCGGlyphs:(const CGGlyph *)glyphs
		   positions:(const NSPoint *)positions
			   count:(NSUInteger)glyphCount
				font:(NSFont *)font
			  matrix:(NSAffineTransform *)textMatrix
		  attributes:(NSDictionary<NSAttributedStringKey,id> *)attributes
		   inContext:(NSGraphicsContext *)graphicsContext
{
#pragma unused(attributes)

	[NSGraphicsContext saveGraphicsState];
	NSGraphicsContext.currentContext = graphicsContext;
	NSBezierPath *newPath = [NSBezierPath bezierPath];
	if (@available(macOS 10.13, *)) {
		for (NSUInteger i = 0; i < glyphCount; i++) {
			[newPath moveToPoint:positions[i]];
			CGGlyph currentGlyph = glyphs[i];
			[newPath appendBezierPathWithCGGlyph:currentGlyph inFont:font];
		}
	} else {
		for (NSUInteger i = 0; i < glyphCount; i++) {
			[newPath moveToPoint:positions[i]];
			CGGlyph currentGlyph = glyphs[i];
			NSGlyph theGlyph = currentGlyph;
			[newPath appendBezierPathWithGlyph:theGlyph inFont:font];
		}
	}
	// Commenting out the following line makes the text the right side, but flipped.
	// TODO: flip it but have it be the right size.
	[newPath transformUsingAffineTransform:textMatrix];
	[mPath appendBezierPath:newPath];
	[NSGraphicsContext restoreGraphicsState];
	
	// debug:
	/*
	 [mPath setLineWidth:1.0];
	 [[NSColor blackColor] set];
	 [mPath stroke];
	 */
}

- (void)drawUnderlineForGlyphRange:(NSRange)glyphRange
					 underlineType:(NSUnderlineStyle)underlineVal
					baselineOffset:(CGFloat)baselineOffset
				  lineFragmentRect:(NSRect)lineRect
			lineFragmentGlyphRange:(NSRange)lineGlyphRange
				   containerOrigin:(NSPoint)containerOrigin
{
#pragma unused(glyphRange, underlineVal, baselineOffset, lineRect, lineGlyphRange, containerOrigin)

	// no-op
}

- (void)drawStrikethroughForGlyphRange:(NSRange)glyphRange
					 strikethroughType:(NSUnderlineStyle)strikethroughVal
						baselineOffset:(CGFloat)baselineOffset
					  lineFragmentRect:(NSRect)lineRect
				lineFragmentGlyphRange:(NSRange)lineGlyphRange
					   containerOrigin:(NSPoint)containerOrigin
{
#pragma unused(glyphRange, strikethroughVal, baselineOffset, lineRect, lineGlyphRange, containerOrigin)
	// no-op
}

#pragma mark -
#pragma mark - as a NSObject

- (instancetype)init
{
	self = [super init];
	if (self)
		mPath = [[NSBezierPath alloc] init];

	return self;
}

@end
