
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <IOSurface/IOSurface.h>
#import <QuartzCore/QuartzCore2.h>
#import <QuartzCore/QuartzCore.h>
#import <QuartzCore/CAAnimation.h>
#import <UIKit/UIGraphics.h>
#import <CoreGraphics/CoreGraphics.h>

#import <sys/types.h>
#import <sys/stat.h>

#import <objc/runtime.h>
#import <stdio.h>
#import <string.h>
#import <stdlib.h>
#import <notify.h>



@interface OverlayView : UIView
BOOL rectangle;
@property(nonatomic, assign) BOOL rectangle;
@end

@implementation OverlayView
@synthesize rectangle;
-(void)drawRect:(CGRect)rect{
		CGContextRef context = UIGraphicsGetCurrentContext();
	UIColor *blackAlphaColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.2];
	UIColor *cameraDotYellow = [UIColor colorWithRed:1 green:0.8 blue:0 alpha:1.0];
	
	if(self.rectangle){
	// Draw UpperRectangle
	CGContextSetLineWidth(context, 0.0);
	CGRect rectangle = CGRectMake(0,0,360,40);
	CGContextAddRect(context, rectangle);
	CGContextStrokePath(context);
	CGContextSetFillColorWithColor(context, blackAlphaColor.CGColor);
	CGContextFillRect(context, rectangle);

	
	// Draw BottomRectangle
	CGContextSetLineWidth(context, 0.0);
	CGRect rectangleBottom = CGRectMake(0,380,360,100);
	CGContextAddRect(context, rectangleBottom);
	CGContextStrokePath(context);
	CGContextSetFillColorWithColor(context, blackAlphaColor.CGColor);
	CGContextFillRect(context, rectangleBottom);
	//Draw yellow dot over labels
	CGContextSetFillColorWithColor(context, cameraDotYellow.CGColor);
	CGContextFillEllipseInRect(context, CGRectMake(157, 384, 6, 6));
	}
	else{
	//Draw Lines
	CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);	
	CGContextSetLineWidth(context, 0.4);
	CGContextMoveToPoint(context, (self.frame.origin.x)+105, self.frame.origin.y);
	CGContextAddLineToPoint(context, (self.frame.origin.x)+105, self.frame.size.height);
	CGContextMoveToPoint(context, (self.frame.size.width)-105, self.frame.origin.y);
	CGContextAddLineToPoint(context, (self.frame.size.width)-105, self.frame.size.height);
	CGContextMoveToPoint(context, self.frame.origin.x, (self.frame.origin.y)+160);
	CGContextAddLineToPoint(context, self.frame.size.width, (self.frame.origin.y)+160);
	CGContextMoveToPoint(context, self.frame.origin.x, (self.frame.size.height)-160);
	CGContextAddLineToPoint(context, self.frame.size.width, (self.frame.size.height)-160);
	CGContextStrokePath(context);
	}

}

@end

@interface PLCameraView : UIView
BOOL showingGridChooser;
OverlayView *overlay;
UIView *flashView;
UIButton *gridButton;
UIButton *gridOn;
UIButton *gridOff;

@end

@interface PLPreviewView : UIView
@end

%hook PLPreviewView
-(id)initWithFrame:(CGRect)frame{
return %orig(CGRectMake(0,0,480,440));
}

%end

%hook PLCameraView
-(id)initWithFrame:(CGRect)frame{
	
	//frame = CGRectMake(0,0,320,480);
	self = %orig(CGRectMake(0,0,320,480));
	if(self){
	//	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		overlay = [[OverlayView alloc] initWithFrame:CGRectMake(0,0, self.frame.size.width, self.frame.size.height)];
		overlay.rectangle = FALSE;
		overlay.backgroundColor = [UIColor clearColor];
		overlay.userInteractionEnabled = FALSE;

		OverlayView *rectangleView = [[OverlayView alloc] initWithFrame:CGRectMake(0,0, self.frame.size.width, self.frame.size.height)];
		rectangleView.rectangle = TRUE;
		rectangleView.backgroundColor = [UIColor clearColor];
		rectangleView.userInteractionEnabled = FALSE;
		//UIView *view = [self valueForKey:@"previewView"];
		//[view addSubview:overlay];
		[self addSubview:overlay];
		[self addSubview:rectangleView];
		[rectangleView release];
		[overlay release];
id cameraController = [self valueForKey:@"cameraController"];
[self setAllowsMultipleCameraModes:TRUE];
		//[cameraController setFocusDisabled:NO];
		//[cameraController setCaptureAtFullResolution:YES];
		//[cameraController setDontShowFocus:YES];
		[cameraController _setCameraMode:0 force:TRUE];
//[self setCaptureAtFullResolution:TRUE];
gridButton = [[UIButton alloc] init];
//gridButton.buttonType = UIButtonTypeCustom;
gridButton.frame = CGRectMake(10, 10, 60, 20);
[gridButton setTitle:@"Grid" forState:UIControlStateNormal];  
[gridButton setBackgroundImage:nil forState:UIControlStateNormal];
[gridButton addTarget:self action:@selector(showGridChooser) forControlEvents:UIControlEventTouchUpInside];
  
[self addSubview:gridButton];
[gridButton release];

gridOn = [[UIButton alloc] init];
//gridOn.buttonType = UIButtonTypeCustom;
gridOn.frame = CGRectMake(10, 10, 40, 20);
[gridOn setTitle:@"On" forState:UIControlStateNormal];  
[gridOn setBackgroundImage:nil forState:UIControlStateNormal];
[gridOn addTarget:self action:@selector(showGrid) forControlEvents:UIControlEventTouchUpInside];
gridOn.alpha = 0.0;
[self addSubview:gridOn];
[gridOn release];

gridOff = [[UIButton alloc] init];
//gridOff.buttonType = UIButtonTypeCustom;
gridOff.frame = CGRectMake(10, 10, 40, 20);
[gridOff setTitle:@"Off" forState:UIControlStateNormal];  
[gridOff setBackgroundImage:nil forState:UIControlStateNormal];
[gridOff addTarget:self action:@selector(hideGrid) forControlEvents:UIControlEventTouchUpInside];
gridOff.alpha = 0.0;
[self addSubview:gridOff];
[gridOff release];

UIView *iris = [self valueForKey:@"irisView"];
iris.hidden = TRUE;

UIView *staticIris = [self valueForKey:@"staticIrisView"];
staticIris.hidden = TRUE;

[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(volumeChanged:) 
													 name:@"AVSystemController_SystemVolumeDidChangeNotification" 
												   object:nil];	

//[pool drain];
	}
	return self;
}


%new(v@:)
- (void)volumeChanged:(NSNotification *)notification{
	[self pressShutterButton];
	
	
}


%new(v@:)
-(void)showGridChooser{
	if(!showingGridChooser){
[UIView beginAnimations:nil context:nil]; 
[UIView setAnimationDelegate:nil];
[UIView setAnimationDuration:.4f];
gridOn.alpha = 1.0;
gridOn.frame = CGRectMake(80, 10, 40, 20);
gridOff.alpha = 1.0;
gridOff.frame = CGRectMake(140, 10, 40, 20);
[UIView commitAnimations];
showingGridChooser = TRUE;
}
else{
	[self hideGridChooser];
}
}

%new(v@:)
-(void)hideGridChooser{
[UIView beginAnimations:nil context:nil]; 
[UIView setAnimationDelegate:nil];
[UIView setAnimationDuration:.4f];
gridOn.alpha = 0.0;
gridOn.frame = CGRectMake(10, 10, 40, 20);
gridOff.alpha = 0.0;
gridOff.frame = CGRectMake(10, 10, 40, 20);
[UIView commitAnimations];
showingGridChooser = FALSE;
}

%new(v@:)
-(void)showGrid{
overlay.hidden = FALSE;
//[gridButton setTitle:@"Grid: On" forState:UIControlStateNormal];  
[self hideGridChooser];
}

%new(v@:)
-(void)hideGrid{
overlay.hidden = TRUE;
//[gridButton setTitle:@"Grid: Off" forState:UIControlStateNormal];  
[self hideGridChooser];
}



%end

@interface PLCameraButtonBar : UIToolbar
UILabel *photoTitle;
UILabel *videoTitle;
BOOL loadedTitles;
@end

%hook PLCameraButtonBar

-(id)initInView:(id)view withItems:(id)items withCount:(int)count{
	loadedTitles = FALSE;
	return %orig;
}

+(id)backgroundImage{
	return nil;
}

-(void)layoutSubviews{
	%orig;
	UIView *cameraButton = [self valueForKey:@"cameraButton"];
	CGRect cameraFrame = CGRectMake(cameraButton.frame.origin.x, cameraButton.frame.origin.y + 15, cameraButton.frame.size.width, cameraButton.frame.size.height);
	cameraButton.frame = cameraFrame;
	[cameraButton _setIcon:[UIImage imageWithContentsOfFile:@"/var/mobile/Whited00r/resources/ShutterWhite.png"]];
	self.backgroundColor = [UIColor clearColor];
	self.translucent = TRUE;
	[cameraButton setBackgroundImage:nil];
	[cameraButton setPressedBackgroundImage:nil];
	//[cameraButton _stopWatchingDeviceOrientationChanges];

if(!loadedTitles && !photoTitle){
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		UIView *modeChanger = [[UIView alloc] initWithFrame:CGRectMake(0,5,320, 40)];
	

	photoTitle = [[UILabel alloc] init];
	photoTitle.textAlignment = UITextAlignmentLeft;
	photoTitle.font = [UIFont boldSystemFontOfSize:12];
	photoTitle.frame = CGRectMake(139, 5, 60, 20);
	photoTitle.backgroundColor = [UIColor clearColor];
	photoTitle.text = @"PHOTO";
	photoTitle.textColor = [UIColor colorWithRed:1 green:0.8 blue:0 alpha:1.0];

	[modeChanger addSubview:photoTitle];
	[photoTitle release];


	videoTitle = [[UILabel alloc] init];
	videoTitle.textAlignment = UITextAlignmentLeft;
	videoTitle.font = [UIFont boldSystemFontOfSize:12];
	videoTitle.frame = CGRectMake(79, 5, 60, 20);
	videoTitle.backgroundColor = [UIColor clearColor];
	videoTitle.text = @"VIDEO";
	videoTitle.textColor = [UIColor whiteColor];
	[modeChanger addSubview:videoTitle];
	[videoTitle release];
		
UIButton *videoButton = [UIButton buttonWithType:UIButtonTypeCustom];
videoButton.frame = CGRectMake(79, 5, 60, 20);
[videoButton setTitle:nil forState:UIControlStateNormal];  
[videoButton setBackgroundImage:nil forState:UIControlStateNormal];
[videoButton addTarget:self action:@selector(openVideo) forControlEvents:UIControlEventTouchUpInside];

[modeChanger addSubview:videoButton];
modeChanger.userInteractionEnabled = TRUE;
	[self addSubview:modeChanger];
	[pool drain];
	loadedTitles = TRUE;
}

}

%new(v@:)
-(void)openVideo{
	[[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"whited00rvideo://"]];
}

+(float)defaultHeight{
	return 100.0;
}


%end

%hook PLCameraButton
-(void)_setIcon:(id)icon{
	%orig([UIImage imageWithContentsOfFile:@"/var/mobile/Whited00r/resources/ShutterWhite.png"]);
}

-(void)setBackgroundImage:(id)image{
	%orig(nil);
}

-(void)setPressedBackgroundImage:(id)image{
	%orig(nil);
}

-(void)setDontShowDisabledState:(BOOL)state{
	%orig(TRUE);
}

-(id)initWithFrame:(CGRect)frame{

	return %orig(CGRectMake(frame.origin.x, frame.origin.y - 20, frame.size.width, frame.size.height - 20));
}

-(void)_deviceOrientationChanged:(id)changed{
	%orig;
	UIImageView *icon = [self valueForKey:@"iconView"];
	icon.image = [UIImage imageWithContentsOfFile:@"/var/mobile/Whited00r/resources/ShutterWhite.png"];
}
%end

@interface PLCameraVideoSwitch : UIView

@end

%hook PLCameraVideoSwitch
-(void)layoutSubviews{
%orig;
self.hidden = TRUE;

}

-(void)_loadImages{
%orig;
self.hidden = TRUE;	
}

-(void)setEnabled:(BOOL)enabled{
%orig;
self.hidden = TRUE;	
}

-(void)setFrame:(CGRect)frame{
%orig;
self.hidden = TRUE;		
}
%end