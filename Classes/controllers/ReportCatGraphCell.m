// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */
// ReportCatGraphCell.m

#import "ReportCatGraphCell.h"

#define CELL_HEIGHT     120   /* iOS, not retina */

@implementation ReportCatGraphCell

+ (ReportCatGraphCell *)reportCatGraphCell:(UITableView *)tableView
{
    NSString *identifier = @"ReportCatGraphCell";

    ReportCatGraphCell *cell = (ReportCatGraphCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[[ReportCatGraphCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
    }
    return cell;
}

+ (CGFloat)cellHeight
{
    return CELL_HEIGHT;
}

- (void)dealloc
{
    [mCatReports release];
    [super dealloc];
}

/**
   レポート設定
*/
- (void)setReport:(ReportEntry*)reportEntry isOutgo:(BOOL)isOutgo
{
    NSMutableArray *ary;

    if (isOutgo) {
        ary = reportEntry.outgoCatReports;
        mTotal = reportEntry.totalOutgo;
    } else {
        ary = reportEntry.incomeCatReports;
        mTotal = reportEntry.totalIncome;
    }

    if (mCatReports != ary) {
        [mCatReports release];
        mCatReports = ary;
        [mCatReports retain];
    }
}

/**
   セル描画
*/
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();

    // 左上原点にしておく
    //CGContextTranslateCTM(context, 0, rect.size.height);
    //CGContextScaleCTM(context, 1.0, -1.0);

    // 背景消去
    [[UIColor whiteColor] set];
    UIRectFill(rect);

    [self _drawCircleGraph:context];
    [self _drawLegend:context];
}

#define PI 3.14159265358979323846

static inline double radians(double deg)
{
    return deg * PI / 180.0;
}

/*
  円グラフ描画
*/
- (void)_drawCircleGraph:(CGContextRef)context
{
    /* 中心座標を計算 */
    double width = self.frame.size.width;
    double graph_x = width * 0.3;
    double graph_y = CELL_HEIGHT / 2;
    double graph_r = CELL_HEIGHT / 2 * 0.9;

    double sum = 0.0, prev = 0.0;
    int n = -1;

    for (CatReport *cr in mCatReports) {
        n++;
        sum += cr.sum;

        // context, x, y, R, start rad, end rad, direction
        double start_rad = radians(-90 + prev / mTotal * 360);
        double end_rad   = radians(-90 + sum  / mTotal * 360);

        // 色設定
        UIColor *color = [ReportCatGraphCell getGraphColor:n];
        CGContextSetFillColorWithColor(context, [color CGColor]);

        // 円弧の描画
        CGContextMoveToPoint(context, graph_x, graph_y);
        CGContextAddArc(context, graph_x, graph_y, graph_r, start_rad, end_rad, 0);
        CGContextFillPath(context);

        prev = sum;
    }
}

/*
  凡例描画
*/
- (void)_drawLegend:(CGContextRef)context
{
    const int LegendHeight = 14;
    
    double width = self.frame.size.width;

    int n = -1;
    for (CatReport *cr in mCatReports) {
        n++;
        if (n >= 8) break;

        // 色設定
        UIColor *color = [ReportCatGraphCell getGraphColor:n];
        CGContextSetFillColorWithColor(context, [color CGColor]);

        // ■を描画
        CGContextAddRect(context, CGRectMake(width * 0.6, n * LegendHeight + 5, LegendHeight * 0.8, LegendHeight * 0.8));
        CGContextFillPath(context);
    }

    // 黒のフォント
    UIColor *color = [UIColor blackColor];
    [color set];
    UIFont *font = [UIFont systemFontOfSize:9];
    
    n = -1;
    for (CatReport *cr in mCatReports) {
        n++;

        // 文字を描画
        [[cr title] drawInRect:CGRectMake(width * 0.6 + LegendHeight, n * LegendHeight + 5, width * 0.6 - LegendHeight, LegendHeight) withFont:font];
    }
}

/**
   円グラフ用の色を生成する

   Hue の値を一定角度で回転する。
*/
+ (UIColor *)getGraphColor:(int)index
{
    CGFloat hue = ((30 + index * 78) % 360) / 360.0;
    CGFloat satulation = 0.8;
    CGFloat brightness = 0.9;
    
    return [UIColor colorWithHue:hue saturation:satulation brightness:brightness alpha:1.0];
}

@end
