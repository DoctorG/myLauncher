//
//  MyLauncherItem.m
//  @rigoneri
//
//  Copyright 2010 Rodrigo Neri
//  Copyright 2011 David Jarrett
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "MyLauncherItem.h"

@implementation MyLauncherItem

@synthesize targetController;
@synthesize delegate;
@synthesize title;
@synthesize image;
@synthesize badge;
@synthesize iPadImage;
@synthesize closeButton;
@synthesize controllerStr;
@synthesize controllerTitle;

#pragma mark - Lifecycle

-(id)initWithTitle:(NSString *)_title image:(NSString *)_image target:(NSString *)_targetControllerStr deletable:(BOOL)_deletable {
	return [self initWithTitle:_title 
                   iPhoneImage:_image 
                     iPadImage:_image 
                        target:_targetControllerStr 
                   targetTitle:_title 
                         badge:nil
                     deletable:_deletable];
}

-(id)initWithTitle:(NSString *)_title iPhoneImage:(NSString *)_image iPadImage:(NSString *)_iPadImage target:(NSString *)_targetControllerStr targetTitle:(NSString *)_targetTitle badge:(NSString *)_targetBadge deletable:(BOOL)_deletable {
    
    if((self = [super init]))
	{ 
		dragging = NO;
		deletable = _deletable;
		
		[self setTitle:_title];
		[self setImage:_image];
        [self setIPadImage:_iPadImage];
		[self setControllerStr:_targetControllerStr];
        [self setBadge:_targetBadge];
        [self setControllerTitle:_targetTitle];
		
		[self setCloseButton:[[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 0)] autorelease]];
		self.closeButton.hidden = YES;
	}
	return self;
}

- (void)dealloc 
{
	self.delegate = nil;
    self.title = nil;
    self.image = nil;
    self.badge = nil;
    self.controllerStr = nil;
    self.closeButton = nil;
	[super dealloc];
}

#pragma mark - Layout

-(void)layoutItem
{
	if(!self.image)
		return;
	
	for(id subview in [self subviews]) 
		[subview removeFromSuperview];
	
    UIImage *layoutImage = nil;
    if ([[UIDevice currentDevice].model hasPrefix:@"iPad"] && [self iPadImage]) {
        layoutImage = [UIImage imageNamed:self.iPadImage];
    } else {
        layoutImage = [UIImage imageNamed:self.image];
    }
    
	UIImageView *itemImage = [[UIImageView alloc] initWithImage:layoutImage];
    //center image in item space    
	CGFloat itemImageX = (self.bounds.size.width/2) - (itemImage.bounds.size.width/2);
	CGFloat itemImageY = (self.bounds.size.height/2) - (itemImage.bounds.size.height/2);
	itemImage.frame = CGRectMake(itemImageX, itemImageY, itemImage.bounds.size.width, itemImage.bounds.size.height);
	[self addSubview:itemImage];
	[itemImage release];
	
	if(deletable) {
		self.closeButton.frame = CGRectMake(itemImageX-10, itemImageY-10, 30, 30);
		[self.closeButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
		self.closeButton.backgroundColor = [UIColor clearColor];
		[self.closeButton addTarget:self action:@selector(closeItem:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:self.closeButton];
	}
    
    if ([self.badge length]) {
        CustomBadge *customBadge = [CustomBadge customBadgeWithString:self.badge]; 
        //Set Position of Badge 
        //put badge 15x15 from top right corner
        customBadge.frame = CGRectMake(itemImageX+itemImage.bounds.size.width+10-customBadge.frame.size.width,itemImageY-15, customBadge.frame.size.width, customBadge.frame.size.height);    
        [self addSubview:customBadge];
	}
	
    //icon Label
    //make label fixed distance from bottom of image (I think this looks odd when icon images not all uniform size)
	//CGFloat itemLabelY = itemImageY + itemImage.bounds.size.height;
    //CGFloat itemLabelHeight = self.bounds.size.height - itemLabelY;
    
    //make label fixed distance from bottom of item bounds (titles are always in same position despite size of icon)
    CGFloat itemLabelHeight = 34;
    CGFloat itemLabelY = self.bounds.size.height - itemLabelHeight - 4;
    
    //center title below image
	UILabel *itemLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, itemLabelY, self.bounds.size.width, itemLabelHeight)];
	itemLabel.backgroundColor = [UIColor clearColor];
	itemLabel.font = [UIFont boldSystemFontOfSize:12.5];
	itemLabel.textColor = COLOR(46, 46, 46);
	itemLabel.textAlignment = UITextAlignmentCenter;
	itemLabel.lineBreakMode = UILineBreakModeTailTruncation;
	itemLabel.text = self.title;
	itemLabel.numberOfLines = 2;
	[self addSubview:itemLabel];
	[itemLabel release];
}

#pragma mark - Touch

-(void)closeItem:(id)sender
{
	[UIView animateWithDuration:0.1 
						  delay:0 
						options:UIViewAnimationOptionCurveEaseIn 
					 animations:^{	
						 self.alpha = 0;
						 self.transform = CGAffineTransformMakeScale(0.00001, 0.00001);
					 }
					 completion:nil];
	
	[[self delegate] didDeleteItem:self];
}

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent *)event 
{
	[super touchesBegan:touches withEvent:event];
	[[self nextResponder] touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent *)event 
{
	[super touchesMoved:touches withEvent:event];
	[[self nextResponder] touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent *)event 
{
	[super touchesEnded:touches withEvent:event];
	[[self nextResponder] touchesEnded:touches withEvent:event];
}

#pragma mark - Setters and Getters

-(void)setFrame:(CGRect)frame
{
	[super setFrame:frame];
}

-(void)setDragging:(BOOL)flag
{
	if(dragging == flag)
		return;
	
	dragging = flag;
	
	[UIView animateWithDuration:0.1
						  delay:0 
						options:UIViewAnimationOptionCurveEaseIn 
					 animations:^{
						 if(dragging) {
							 self.transform = CGAffineTransformMakeScale(1.4, 1.4);
							 self.alpha = 0.7;
						 }
						 else {
							 self.transform = CGAffineTransformIdentity;
							 self.alpha = 1;
						 }
					 }
					 completion:nil];
}

-(BOOL)dragging
{
	return dragging;
}

-(BOOL)deletable
{
	return deletable;
}

@end
