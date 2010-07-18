// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-

#import "TestCommon.h"
#import "AssetListVC.h"

@interface AssetListViewControllerTest : UINavigationBarBasedTest {
    AssetListViewController *vc;
}
@end

@implementation AssetListViewControllerTest

- (UIViewController *)rootViewController
{
    vc = [[[AssetListViewController alloc] initWithNibName:@"AssetListView" bundle:nil] autorelease];
    return vc;
}

- (void)setUp
{
    [TestCommon installDatabase:@"testdata1"];

    // AssetView を表示させないようにガードする
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:-1 forKey:@"firstShowAssetIndex"];
    
    [super setUp];
 }

- (void)tearDown
{
    [super tearDown];
}

- (NSString *)cellText:(int)row section:(int)section
{
    NSIndexPath *index = [NSIndexPath indexPathForRow:row inSection:section];
    UITableViewCell *cell = [vc tableView:vc.tableView cellForRowAtIndexPath:index];
    NSLog(@"'%@'", cell.textLabel.text);
    return cell.textLabel.text;
}

- (void)testNormal
{
    // test number of rows
    ASSERT_EQUAL_INT(3, [vc tableView:vc.tableView numberOfRowsInSection:0]);

    // test cell
    ASSERT_EQUAL(@"Cash : ￥9,000", [self cellText:0 section:0]);
    ASSERT_EQUAL(@"Bank : ￥195,000", [self cellText:1 section:0]);
    ASSERT_EQUAL(@"Card : -￥12,100", [self cellText:2 section:0]);
    //ASSERT_EQUAL(@"計 : 10000", [self cellText:0 section:1]);
}

@end