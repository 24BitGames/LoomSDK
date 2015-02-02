/****************************************************************************
 Copyright (c) 2010-2011 cocos2d-x.org
 Copyright (c) 2010      Ricardo Quesada
 
 http://www.cocos2d-x.org
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/

#import "RootViewController.h"
#import "loom/engine/cocos2dx/loom/CCLoomCocos2D.h"
#import <Foundation/Foundation.h>

@implementation RootViewController

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
 
*/
// Override to allow orientations other than the default portrait orientation.
// This method is deprecated on ios6
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {

    if(CCLoomCocos2d::getDisplayOrientation() == CCLoomCocos2d::OrientationLandscape)
        return UIInterfaceOrientationIsLandscape(interfaceOrientation);
    else if(CCLoomCocos2d::getDisplayOrientation() == CCLoomCocos2d::OrientationPortrait)
        return UIInterfaceOrientationIsPortrait(interfaceOrientation);
    else //auto-orientation
        return TRUE;
}


#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 60000

// For ios6, use supportedInterfaceOrientations & shouldAutorotate instead
- (NSUInteger) supportedInterfaceOrientations{
    if(CCLoomCocos2d::getDisplayOrientation() == CCLoomCocos2d::OrientationLandscape)
        return UIInterfaceOrientationMaskLandscape;
    else if(CCLoomCocos2d::getDisplayOrientation() == CCLoomCocos2d::OrientationPortrait)
        return UIInterfaceOrientationMaskPortrait;
    else //auto-orientation
        return UIInterfaceOrientationMaskAll;
}

- (BOOL) shouldAutorotate {
    return YES;
}

#endif



//Depricated in iOS 8 SDK
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
        CCLoomCocos2d::setOrientation(CCLoomCocos2d::OrientationLandscape);
    else if(UIInterfaceOrientationIsPortrait(toInterfaceOrientation))
        CCLoomCocos2d::setOrientation(CCLoomCocos2d::OrientationPortrait);
}


#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000

//iOS 8 SDK and up uses this now
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    //The device has already rotated, that's why this method is being called.
    UIInterfaceOrientation toInterfaceOrientation   = [[UIDevice currentDevice] orientation];
    
    //fixes orientation mismatch (between UIDeviceOrientation and UIInterfaceOrientation)
    if(toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        toInterfaceOrientation = UIInterfaceOrientationLandscapeLeft;
    }
    else if(toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft)
    {
        toInterfaceOrientation = UIInterfaceOrientationLandscapeRight;
    }

    //call deprecated iOS function to handle our cocos stuff!
    [self willRotateToInterfaceOrientation:toInterfaceOrientation duration:0.0];
}

#endif


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end