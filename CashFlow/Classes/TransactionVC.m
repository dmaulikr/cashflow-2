// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
  CashFlow for iPhone/iPod touch

  Copyright (c) 2008, Takuya Murakami, All rights reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are
  met:

  1. Redistributions of source code must retain the above copyright notice,
  this list of conditions and the following disclaimer. 

  2. Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the following disclaimer in the
  documentation and/or other materials provided with the distribution. 

  3. Neither the name of the project nor the names of its contributors
  may be used to endorse or promote products derived from this software
  without specific prior written permission. 

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/


#import "TransactionVC.h"
#import "AppDelegate.h"

@implementation TransactionViewController

@synthesize editingEntry, asset;

#define ROW_DATE  0
#define ROW_TYPE  1
#define ROW_VALUE 2
#define ROW_DESC  3
#define ROW_CATEGORY 4
#define ROW_MEMO  5

#define NUM_ROWS 6

- (id)init
{
    self = [super initWithNibName:@"TransactionView" bundle:nil];
    return self;
}

- (void)viewDidLoad
{
    self.title = NSLocalizedString(@"Transaction", @"");
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
                                                  initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                  target:self
                                                  action:@selector(saveAction)] autorelease];

    typeArray = [[NSArray alloc] initWithObjects:
                                     NSLocalizedString(@"Payment", @""),
                                 NSLocalizedString(@"Deposit", @""),
                                 NSLocalizedString(@"Adjustment", @"Balance adjustment"),
                                 NSLocalizedString(@"Transfer", @""),
                                 nil];
	
    // ボタン生成
    UIButton *b;
    UIImage *bg = [[UIImage imageNamed:@"redButton.png"] stretchableImageWithLeftCapWidth:12.0 topCapHeight:0];
				
    int i;
    for (i = 0; i < 2; i++) {
        b = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [b setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [b setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [b setFont:[UIFont systemFontOfSize:14.0]];
	
        [b setBackgroundImage:bg forState:UIControlStateNormal];
		
        if (i == 0) {
            [b setFrame:CGRectMake(10, 310, 300, 40)];
            [b setTitle:NSLocalizedString(@"Delete transaction", @"") forState:UIControlStateNormal];
            [b addTarget:self action:@selector(delButtonTapped) forControlEvents:UIControlEventTouchUpInside];
            delButton = [b retain];
        } else {
            [b setFrame:CGRectMake(10, 365, 300, 40)];
            [b setTitle:NSLocalizedString(@"Delete with all past transactions", @"") forState:UIControlStateNormal];
            [b addTarget:self action:@selector(delPastButtonTapped) forControlEvents:UIControlEventTouchUpInside];
            delPastButton = [b retain];
        }
    }
}

- (void)dealloc
{
    self.editingEntry = nil;
	
    [delButton release];
    [delPastButton release];
	
    [super dealloc];
}

// 処理するトランザクションをロードしておく
- (void)setTransactionIndex:(int)n
{
    transactionIndex = n;

    self.editingEntry = nil;

    if (transactionIndex < 0) {
        // 新規トランザクション
        self.editingEntry = [[[AssetEntry alloc] initWithTransaction:nil withAsset:asset] autorelease];
    } else {
        // 変更
        AssetEntry *orig = [asset entryAt:transactionIndex];
        self.editingEntry = [[orig copy] autorelease];
    }
}

// 表示前の処理
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	
    if (transactionIndex >= 0) {
        [self.view addSubview:delButton];
        [self.view addSubview:delPastButton];
    }
		
    [[self tableView] reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //[[self tableView] reloadData];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
	
    if (transactionIndex >= 0) {
        [delButton removeFromSuperview];
        [delPastButton removeFromSuperview];
    }
}

/////////////////////////////////////////////////////////////////////////////////
// TableView 表示処理

// セクション数
- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1;
}

// 行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
    return NUM_ROWS;
}

// 行の内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    return [self getCellForField:indexPath tableView:tableView];
}

- (UITableViewCell *)getCellForField:(NSIndexPath*)indexPath tableView:(UITableView *)tableView
{
    static NSString *MyIdentifier = @"transactionViewCells";
    UILabel *name, *value;

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:MyIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

        name = [[[UILabel alloc] initWithFrame:CGRectMake(0, 6, 110, 32)] autorelease];
        name.tag = 1;
        name.font = [UIFont systemFontOfSize: 14.0];
        name.textColor = [UIColor blueColor];
        name.textAlignment = UITextAlignmentRight;
        name.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [cell.contentView addSubview:name];

        value = [[[UILabel alloc] initWithFrame:CGRectMake(90, 6, 210, 32)] autorelease];
        value.tag = 2;
        value.font = [UIFont systemFontOfSize: 16.0];
        value.textColor = [UIColor blackColor];
        value.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [cell.contentView addSubview:value];

    } else {
        name  = (UILabel *)[cell.contentView viewWithTag:1];
        value = (UILabel *)[cell.contentView viewWithTag:2];
    }

    double evalue;
    switch (indexPath.row) {
    case ROW_DATE:
        name.text = NSLocalizedString(@"Date", @"");
        value.text = [[DataModel dateFormatter] stringFromDate:editingEntry.transaction.date];
        break;

    case ROW_TYPE:
        name.text = NSLocalizedString(@"Type", @"Transaction type");
        value.text = [typeArray objectAtIndex:editingEntry.transaction.type];
        break;
		
    case ROW_VALUE:
        name.text = NSLocalizedString(@"Amount", @"");
        evalue = editingEntry.evalue;
        value.text = [DataModel currencyString:evalue];
        break;
		
    case ROW_DESC:
        name.text = NSLocalizedString(@"Name", @"Description");
        value.text = editingEntry.transaction.description;
        break;
			
    case ROW_CATEGORY:
        name.text = NSLocalizedString(@"Category", @"");
        value.text = [[DataModel categories] categoryStringWithKey:editingEntry.transaction.category];
        break;
			
    case ROW_MEMO:
        name.text = NSLocalizedString(@"Memo", @"");
        value.text = editingEntry.transaction.memo;
        break;
    }

    return cell;
}

///////////////////////////////////////////////////////////////////////////////////
// 値変更処理

// セルをクリックしたときの処理
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UINavigationController *nc = self.navigationController;

    UIViewController *vc = nil;
    EditDateViewController *editDateVC;
    EditTypeViewController *editTypeVC; // type
    EditValueViewController *editValueVC;
    EditDescViewController *editDescVC;
    //GenEditTextViewController *editMemoVC; // memo
    EditMemoViewController *editMemoVC; // memo
    CategoryListViewController *editCategoryVC;

    // view を表示

    switch (indexPath.row) {
    case ROW_DATE:
        editDateVC = [[[EditDateViewController alloc] init] autorelease];
        editDateVC.delegate = self;
        editDateVC.date = editingEntry.transaction.date;
        vc = editDateVC;
        break;

    case ROW_TYPE:
        editTypeVC = [[[EditTypeViewController alloc] init] autorelease];
        editTypeVC.delegate = self;
        editTypeVC.type = editingEntry.transaction.type;
        editTypeVC.dst_asset = [editingEntry dstAsset];
        vc = editTypeVC;
        break;

    case ROW_VALUE:
        editValueVC = [[[EditValueViewController alloc] init] autorelease];
        editValueVC.delegate = self;
        editValueVC.value = editingEntry.evalue;
        vc = editValueVC;
        break;

    case ROW_DESC:
        editDescVC = [[[EditDescViewController alloc] init] autorelease];
        editDescVC.delegate = self;
        editDescVC.description = editingEntry.transaction.description;
        editDescVC.category = editingEntry.transaction.category;
        vc = editDescVC;
        break;

    case ROW_MEMO:
        editMemoVC = [EditMemoViewController
                         editMemoViewController:self
                         title:NSLocalizedString(@"Memo", @"") 
                         identifier:0];
        editMemoVC.text = editingEntry.transaction.memo;
        vc = editMemoVC;
        break;

    case ROW_CATEGORY:
        editCategoryVC = [[[CategoryListViewController alloc] init] autorelease];
        editCategoryVC.isSelectMode = YES;
        editCategoryVC.delegate = self;
        editCategoryVC.selectedIndex = [[DataModel categories] categoryIndexWithKey:editingEntry.transaction.category];
        vc = editCategoryVC;
        break;
    }
    [nc pushViewController:vc animated:YES];
}

// イベントリスナ (下位 ViewController からの変更通知)
- (void)editDateViewChanged:(EditDateViewController *)vc
{
    editingEntry.transaction.date = vc.date;
}

- (void)editTypeViewChanged:(EditTypeViewController*)vc
{
    [self.navigationController popToViewController:self animated:YES]; // ###

    if (![editingEntry changeType:vc.type assetKey:asset.pkey dstAssetKey:vc.dst_asset]) {
        return;
    }

    switch (editingEntry.transaction.type) {
    case TYPE_ADJ:
        editingEntry.transaction.description = [typeArray objectAtIndex:editingEntry.transaction.type];
        break;

    case TYPE_TRANSFER:
        {
            Asset *from, *to;
            Ledger *ledger = [DataModel ledger];
            from = [ledger assetWithKey:editingEntry.transaction.asset];
            to = [ledger assetWithKey:editingEntry.transaction.dst_asset];

            editingEntry.transaction.description = 
                [NSString stringWithFormat:@"%@/%@", from.name, to.name];
        }
        break;

    default:
        break;
    }
}

- (void)editValueViewChanged:(EditValueViewController *)vc
{
    [editingEntry setEvalue:vc.value];
}

- (void)editDescViewChanged:(EditDescViewController *)vc
{
    editingEntry.transaction.description = vc.description;

    if (editingEntry.transaction.category < 0) {
        // set category from description
        editingEntry.transaction.category = [[DataModel instance] categoryWithDescription:editingEntry.transaction.description];
    }
}

- (void)editMemoViewChanged:(EditMemoViewController*)vc identifier:(int)id
{
    editingEntry.transaction.memo = vc.text;
}

- (void)categoryListViewChanged:(CategoryListViewController*)vc;
{
    if (vc.selectedIndex < 0) {
        editingEntry.transaction.category = -1;
    } else {
        Category *c = [[DataModel categories] categoryAtIndex:vc.selectedIndex];
        editingEntry.transaction.category = c.pkey;
    }
}

////////////////////////////////////////////////////////////////////////////////
// 削除処理
- (void)delButtonTapped
{
    [asset deleteEntryAt:transactionIndex];
    self.editingEntry = nil;
	
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)delPastButtonTapped
{
    UIActionSheet *as = [[UIActionSheet alloc]
                            initWithTitle:nil delegate:self
                            cancelButtonTitle:@"Cancel"
                            destructiveButtonTitle:NSLocalizedString(@"Delete with all past transactions", @"")
                            otherButtonTitles:nil];
    as.actionSheetStyle = UIActionSheetStyleDefault;
    [as showInView:self.view];
    [as release];
}

- (void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != 0) {
        //[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
        return; // cancelled;
    }

    AssetEntry *e = [asset entryAt:transactionIndex];
	
    NSDate *date = e.transaction.date;
    [asset deleteOldEntriesBefore:date];
	
    self.editingEntry = nil;
	
    [self.navigationController popViewControllerAnimated:YES];
}

////////////////////////////////////////////////////////////////////////////////
// 保存処理
- (void)saveAction
{
    //editingEntry.transaction.asset = asset.pkey;

    if (transactionIndex < 0) {
        [asset insertEntry:editingEntry];
    } else {
        [asset replaceEntryAtIndex:transactionIndex withObject:editingEntry];
        //[asset sortByDate];
    }

    self.editingEntry = nil;
	
    [self.navigationController popViewControllerAnimated:YES];
}

@end