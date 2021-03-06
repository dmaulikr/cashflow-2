// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <UIKit/UIKit.h>
#import "TransactionVC.h"
#import "ExportVC.h"
#import "DataModel.h"
#import "CalcVC.h"

#if FREE_VERSION
#import "GADAdViewController.h"
#import "GADAdSenseParameters.h"
#endif

@class AssetListViewController;

@interface TransactionListViewController : UIViewController 
    <UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate, CalculatorViewDelegate, UISplitViewControllerDelegate
#if FREE_VERSION
, GADAdViewControllerDelegate
#endif
>
{
    IBOutlet UITableView *mTableView;
    IBOutlet UIBarButtonItem *mBarBalanceLabel;
    IBOutlet UIBarButtonItem *mBarActionButton;
	
    Asset *mAsset;
#if FREE_VERSION
    GADAdViewController *mAdViewController;
#endif
    
    BOOL mAsDisplaying;
    
    // for Split view
    IBOutlet AssetListViewController *mSplitAssetListViewController;
    UIPopoverController *mPopoverController;
}

//- (UITableView*)tableView;
@property(nonatomic,retain) UITableView *tableView;
@property(nonatomic,assign) Asset *asset;
@property(nonatomic,retain) UIPopoverController *popoverController;

- (int)entryIndexWithIndexPath:(NSIndexPath *)indexPath;
- (AssetEntry *)entryWithIndexPath:(NSIndexPath *)indexPath;
- (void)reload;
- (void)updateBalance;
- (void)addTransaction;

- (IBAction)showReport:(id)sender;
- (IBAction)doAction:(id)sender;
//- (IBAction)showHelp:(id)sender;

- (void)_replaceAd;

@end
