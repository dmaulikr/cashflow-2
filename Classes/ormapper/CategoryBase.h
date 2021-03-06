// Generated by O/R mapper generator ver 1.0

#import <UIKit/UIKit.h>
#import "ORRecord.h"

@class Category;

@interface CategoryBase : ORRecord {
    NSString* mName;
    int mSorder;
}

@property(nonatomic,retain) NSString* name;
@property(nonatomic,assign) int sorder;

+ (BOOL)migrate;

// CRUD (Create/Read/Update/Delete) operations

// Create/update operations
// Note: You should use 'save' method
- (void)_insert;
- (void)_update;

// Read operations (Finder)
+ (Category *)find:(int)pid;
+ (Category *)find_by_name:(NSString*)key cond:(NSString*)cond;
+ (Category *)find_by_name:(NSString*)key;
+ (Category *)find_by_sorder:(int)key cond:(NSString*)cond;
+ (Category *)find_by_sorder:(int)key;

+ (NSMutableArray *)find_all:(NSString *)cond;

+ (dbstmt *)gen_stmt:(NSString *)cond;
+ (Category *)find_first_stmt:(dbstmt *)stmt;
+ (NSMutableArray *)find_all_stmt:(dbstmt *)stmt;

// Delete operations
- (void)delete;
+ (void)delete_cond:(NSString *)cond;
+ (void)delete_all;

// internal functions
+ (NSString *)tableName;
- (void)_loadRow:(dbstmt *)stmt;

@end
