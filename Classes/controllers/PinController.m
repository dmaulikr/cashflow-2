// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "PinController.h"
#import "AppDelegate.h"

@implementation PinController
@synthesize pin = mPin, newPin = mNewPin;

#define FIRST_PIN_CHECK 0
#define ENTER_CURRENT_PIN 1
#define ENTER_NEW_PIN1 2
#define ENTER_NEW_PIN2 3

static PinController *thePinController = nil;

+ (PinController *)pinController
{
    if (thePinController == nil) {
        thePinController = [[PinController alloc] init];
        return thePinController;
    }
    return nil;
}

- (id)init
{
    self = [super init];
    if (self) {
        mState = -1;
        self.newPin = nil;
        mNavigationController = nil;

        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        self.pin = [defaults stringForKey:@"PinCode"];

        if (mPin && mPin.length == 0) {
            self.pin = nil;
        }
    }
    return self;
}

- (void)dealloc
{
    [mPin release];
    [mNewPin release];
    [mNavigationController release];
    [super dealloc];
}
    
- (void)_allDone
{
    [mNavigationController dismissModalViewControllerAnimated:YES];
    [self autorelease];
    thePinController = nil;
}

- (void)firstPinCheck:(UIViewController *)currentVc
{
    ASSERT(state == -1);

    if (mPin == nil) return; // do nothing

    // get topmost modal view controller
    while (currentVc.modalViewController != nil) {
        currentVc = currentVc.modalViewController;
    }
    
    [self retain];

    // create PinViewController
    PinViewController *vc = [self _getPinViewController];
    vc.title = NSLocalizedString(@"Enter PIN", @"");
    vc.enableCancel = NO;

    mState = FIRST_PIN_CHECK;

    // show PinViewController
    mNavigationController = [[UINavigationController alloc] initWithRootViewController:vc];
    [currentVc presentModalViewController:mNavigationController animated:NO];
}

- (void)modifyPin:(UIViewController *)currentVc
{
    ASSERT(state == -1);

    [self retain];

    PinViewController *vc = [self _getPinViewController];
    
    if (mPin != nil) {
        // check current pin
        mState = ENTER_CURRENT_PIN;
        vc.title = NSLocalizedString(@"Enter PIN", @"");
    } else {
        // enter 1st pin
        mState = ENTER_NEW_PIN1;
        vc.title = NSLocalizedString(@"Enter new PIN", @"");
    }
        
    mNavigationController = [[UINavigationController alloc] initWithRootViewController:vc];
    [currentVc presentModalViewController:mNavigationController animated:YES];
}

#pragma mark PinViewDelegate

- (BOOL)pinViewCheckPin:(PinViewController *)vc
{
    return [vc.value isEqualToString:mPin];
}

- (void)pinViewFinished:(PinViewController *)vc isCancel:(BOOL)isCancel
{
    if (isCancel) {
        [self _allDone];
        return;
    }

    BOOL retry = NO;
    BOOL isBadPin = NO;
    PinViewController *newvc = nil;

    switch (mState) {
    case FIRST_PIN_CHECK:
    case ENTER_CURRENT_PIN:
        ASSERT(pin != nil);
        if (![vc.value isEqualToString:mPin]) {
            isBadPin = YES;
            retry = YES;
        }
        else if (mState == ENTER_CURRENT_PIN) {
            mState = ENTER_NEW_PIN1;
            newvc = [self _getPinViewController];        
            newvc.title = NSLocalizedString(@"Enter new PIN", @"");
        }
        break;

    case ENTER_NEW_PIN1:
        self.newPin = [NSString stringWithString:vc.value]; // TBD
        mState = ENTER_NEW_PIN2;
        newvc = [self _getPinViewController];        
        newvc.title = NSLocalizedString(@"Retype new PIN", @"");
        break;

    case ENTER_NEW_PIN2:
        NSLog(@"%@", mNewPin);
        if ([vc.value isEqualToString:mNewPin]) {
            // set new pin
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:mNewPin forKey:@"PinCode"];
            [defaults synchronize];
        } else {
            isBadPin = YES;
        }
        break;
    }

    // invalid pin
    if (isBadPin) {
        UIAlertView *v = [[UIAlertView alloc]
                             initWithTitle:NSLocalizedString(@"Invalid PIN", @"")
                             message:NSLocalizedString(@"PIN code does not match.", @"")
                             delegate:nil
                             cancelButtonTitle:@"Close"
                             otherButtonTitles:nil];
        [v show];
        [v release];
    }
    if (retry) {
        return;
    }

    // Show new vc if needed, otherwise all done.
    if (newvc) {
        [mNavigationController pushViewController:newvc animated:YES];
    } else {
        [self _allDone];
    }
}

- (PinViewController *)_getPinViewController
{
    PinViewController *vc = [[[PinViewController alloc] init] autorelease];
    vc.enableCancel = YES;
    vc.delegate = self;
    return vc;
}

@end
