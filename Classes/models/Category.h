// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <UIKit/UIKit.h>
#import "Database.h"
#import "CategoryBase.h"

@interface Category : CategoryBase {
}
@end

@interface Categories : NSObject {
    NSMutableArray *mCategories;
}

- (void)reload;
- (int)count;
- (Category*)categoryAtIndex:(int)n;
- (int)categoryIndexWithKey:(int)key;
- (NSString*)categoryStringWithKey:(int)key;

-(Category*)addCategory:(NSString *)name;
-(void)updateCategory:(Category*)category;
-(void)deleteCategoryAtIndex:(int)index;
-(void)reorderCategory:(int)from to:(int)to;
-(void)renumber;

@end
