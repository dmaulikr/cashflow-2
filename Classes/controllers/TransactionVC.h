// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "Transaction.h"

#import "EditTypeVC.h"
#import "EditDescVC.h"
#import "CalcVC.h"
#import "EditDateVC.h"
#import "EditMemoVC.h"
#import "CategoryListVC.h"

@interface TransactionViewController : UITableViewController 
    <UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate,
    EditMemoViewDelegate, EditTypeViewDelegate,
    EditDateViewDelegate, CalculatorViewDelegate,
    EditDescViewDelegate, CategoryListViewDelegate,
    UIPopoverControllerDelegate>
{
    int mTransactionIndex;
    AssetEntry *mEditingEntry;
    Asset *mAsset;

    BOOL mIsModified;

    NSArray *mTypeArray;
	
    UIButton *mDelButton;
    UIButton *mDelPastButton;

    UIActionSheet *mAsDelPast;
    UIActionSheet *mAsCancelTransaction;
    
    UIPopoverController *mCurrentPopoverController;
}

@property(nonatomic,assign) Asset *asset;
@property(nonatomic,retain) AssetEntry *editingEntry;

- (void)setTransactionIndex:(int)n;
- (void)saveAction;
- (void)cancelAction;

- (void)delButtonTapped;
- (void)delPastButtonTapped;

// private
- (void)_asDelPast:(int)buttonIndex;
- (void)_asCancelTransaction:(int)buttonIndex;

- (UITableViewCell *)getCellForField:(NSIndexPath*)indexPath tableView:(UITableView *)tableView;
//- (UITableViewCell *)getCellForDelButton:(UITableView *)tableView isDeleteAll:(Boolean)flag;

- (void)_dismissPopover;

@end
