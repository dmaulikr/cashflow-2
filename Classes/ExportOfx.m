// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "ExportOfx.h"
#import "AppDelegate.h"
#import "ExportServer.h"

@implementation ExportOfx

- (void)dealloc
{
    [mDateFormatter release];
    [mGregCalendar release];
    [super dealloc];
}

- (BOOL)sendMail:(UIViewController *)parent
{
    // generate OFX data
    NSData *data = [self generateBody];
    if (data == nil) {
        return NO;
    }
    
    if (![MFMailComposeViewController canSendMail]) {
        return NO;
    }
    
    MFMailComposeViewController *vc = [[MFMailComposeViewController alloc] init];
    vc.mailComposeDelegate = self;
    
    [vc setSubject:@"CashFlow OFX Data"];

    [vc addAttachmentData:data mimeType:@"application/x-ofx" fileName:@"CashFlow.ofx"];
    [parent presentModalViewController:vc animated:YES];
    [vc release];
    return YES;
}

- (BOOL)sendWithWebServer
{
    NSData *body = [self generateBody];
    if (body == nil) {
        return NO;
    }
	
    [self sendWithWebServer:body contentType:@"application/x-ofx" filename:@"cashflow.ofx"];
    return YES;
}

- (NSData *)generateBody
{
    NSMutableString *data = [[[NSMutableString alloc] initWithCapacity:1024] autorelease];
    
    // get last date
    NSDate *lastDate = nil;
    for (Asset *asset in mAssets) {
        if ([asset entryCount] > 0) {
            AssetEntry *e = [asset entryAt:[asset entryCount] - 1];
            if (lastDate == nil) {
                lastDate = e.transaction.date;
            }
            else if ([lastDate compare:e.transaction.date] == NSOrderedDescending) {
                lastDate = e.transaction.date;
            }
        }
    }
    if (lastDate == nil) {
        return nil;
    }

    [data appendString:@"OFXHEADER:100\n"];
    [data appendString:@"DATA:OFXSGML\n"];
    [data appendString:@"VERSION:102\n"];
    [data appendString:@"SECURITY:NONE\n"];
    [data appendString:@"ENCODING:UTF-8\n"];
    [data appendString:@"CHARSET:CSUNICODE\n"];
    [data appendString:@"COMPRESSION:NONE\n"];
    [data appendString:@"OLDFILEUID:NONE\n"];
    [data appendString:@"NEWFILEUID:NONE\n"];
    [data appendString:@"\n"];

    /* 金融機関情報(サインオンレスポンス) */
    [data appendString:@"<OFX>\n"];
    [data appendString:@"<SIGNONMSGSRSV1>\n"];
    [data appendString:@" <SONRS>\n"];
    [data appendString:@"  <STATUS>\n"];
    [data appendString:@"   <CODE>0</CODE>\n"];
    [data appendString:@"   <SEVERITY>INFO</SEVERITY>\n"];
    [data appendString:@"  </STATUS>\n"];
    [data appendFormat:@"  <DTSERVER>%@</DTSERVER>\n", [self _dateStr:lastDate]];
	
    [data appendString:@"  <LANGUAGE>JPN</LANGUAGE>\n"];
    [data appendString:@"  <FI>\n"];
    [data appendString:@"   <ORG>000</ORG>\n"];
    [data appendString:@"  </FI>\n"];
    [data appendString:@" </SONRS>\n"];
    [data appendString:@"</SIGNONMSGSRSV1>\n"];

    for (Asset *asset in mAssets) {
        [self _bankMessageSetResponse:data asset:asset];
    }
        
    [data appendString:@"</OFX>\n"];

    const char *p = [data UTF8String];
    //const unsigned char bom[3] = {0xEF, 0xBB, 0xBF};
    NSMutableData *d = [NSMutableData dataWithLength:0];
    //[d appendBytes:bom length:sizeof(bom)];
    [d appendBytes:p length:strlen(p)];
    return d;
}

/**
 Bank Message Set Response の生成
 */
- (void)_bankMessageSetResponse:(NSMutableString *)data asset:(Asset *)asset
{
    int max = [asset entryCount];
    
    int firstIndex = 0;
    if (mFirstDate != nil) {
        firstIndex = [asset firstEntryByDate:mFirstDate];
        if (firstIndex < 0) {
            return;
        }
    }
	
    AssetEntry *firstEntry = [asset entryAt:firstIndex];
    AssetEntry *lastEntry  = [asset entryAt:max-1];
    
    /* 口座情報(バンクメッセージレスポンス) */
    [data appendString:@"<BANKMSGSRSV1>\n"];

    /* 預金口座型明細情報作成 */
    [data appendString:@" <STMTTRNRS>\n"];
    [data appendString:@"  <TRNUID>0</TRNUID>\n"];
    [data appendString:@"  <STATUS>\n"];
    [data appendString:@"   <CODE>0</CODE>\n"];
    [data appendString:@"   <SEVERITY>INFO</SEVERITY>\n"];
    [data appendString:@"  </STATUS>\n"];

    [data appendString:@"  <STMTRS>\n"];
	
    NSNumberFormatter *fmt = [[[NSNumberFormatter alloc] init] autorelease];
    NSString *ccode = [fmt currencyCode];
    [data appendFormat:@"   <CURDEF>%@</CURDEF>\n", ccode];

    [data appendString:@"   <BANKACCTFROM>\n"];
    [data appendString:@"    <BANKID>CashFlow</BANKID>\n"];
    [data appendString:@"    <BRANCHID>000</BRANCHID>\n"];
    [data appendFormat:@"    <ACCTID>%d</ACCTID>\n", asset.pid];
    [data appendString:@"    <ACCTTYPE>SAVINGS</ACCTTYPE>\n"]; // ### Use asset.type?
    [data appendString:@"   </BANKACCTFROM>\n"];

    /* 明細情報開始(バンクトランザクションリスト) */
    [data appendString:@"   <BANKTRANLIST>\n"];
    [data appendString:@"    <DTSTART>"];
    [data appendString:[self _dateStrWithAssetEntry:firstEntry]];
    [data appendString:@"\n"];
    [data appendString:@"    <DTEND>"];
    [data appendString:[self _dateStrWithAssetEntry:lastEntry]];
    [data appendString:@"\n"];
    
    /* トランザクション */
    int i;
    for (i = firstIndex; i < max; i++) {
        AssetEntry *e = [asset entryAt:i];
		
        [data appendString:@"    <STMTTRN>\n"];
        [data appendFormat:@"     <TRNTYPE>%@</TRNTYPE>\n", [self _typeStringWithAssetEntry:e]];
        [data appendFormat:@"     <DTPOSTED>%@</DTPOSTED>\n", [self _dateStrWithAssetEntry:e]];
        [data appendFormat:@"     <TRNAMT>%.2f</TRNAMT>\n", e.value];

        /* トランザクションの ID は日付と取引番号で生成 */
        [data appendFormat:@"     <FITID>%@</FITID>\n", [self _fitIdWithAssetEntry:e]];
        [data appendFormat:@"     <NAME>%@</NAME>\n", [self _escapeXmlString:e.transaction.description]];
        if ([e.transaction.memo length] > 0) {
            [data appendFormat:@"     <MEMO>%@</MEMO>\n", [self _escapeXmlString:e.transaction.memo]];
        }
        [data appendString:@"    </STMTTRN>\n"];
    }

    [data appendString:@"   </BANKTRANLIST>\n"];

    /* 残高 */
    [data appendString:@"   <LEDGERBAL>\n"];
    [data appendFormat:@"    <BALAMT>%.2f</BALAMT>\n", lastEntry.balance];
    [data appendFormat:@"    <DTASOF>%@</DTASOF>\n", [self _dateStrWithAssetEntry:lastEntry]];
    [data appendString:@"   </LEDGERBAL>\n"];

    /* OFX 終了 */
    [data appendString:@"  </STMTRS>\n"];
    [data appendString:@" </STMTTRNRS>\n"];
    [data appendString:@"</BANKMSGSRSV1>\n"];
}

/**
 AssetEntry に対する type 文字列を返す
 */
- (NSString*)_typeStringWithAssetEntry:(AssetEntry*)e
{
    if (e.value >= 0) {
        return @"DEP";
    }
    return @"PAYMENT";
}

/**
 日付文字列を返す
 */
- (NSString*)_dateStrWithAssetEntry:(AssetEntry *)e
{
    return [self _dateStr:e.transaction.date];
}

/**
 日付文字列を返す
 */
- (NSString*)_dateStr:(NSDate *)date
{
    if (mGregCalendar == nil) {
        mGregCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        mDateFormatter = [[NSDateFormatter alloc] init];
    }
    NSTimeZone *tz = [mDateFormatter timeZone];
			  
    NSDateComponents *c = [mGregCalendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit 
                                            | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit)
                                fromDate:date];

    NSString *d = [NSString stringWithFormat:@"%04d%02d%02d%02d%02d%02d[%+d:%@]",
                            [c year], [c month], [c day], [c hour], [c minute], [c second], [tz secondsFromGMT]/3600, [tz abbreviation]];
    return d;
}

/**
 取引IDの割り当て
 */
- (NSString*)_fitIdWithAssetEntry:(AssetEntry*)e
{
    NSDateComponents *c = [mGregCalendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:e.transaction.date];
    NSString *f = [NSString stringWithFormat:@"%04d%02d%02d%d", [c year], [c month], [c day], e.transaction.pid];
    return f;
}

/**
 XML文字列のエスケープ
 */
- (NSString *)_escapeXmlString:(NSString *)s
{
    NSMutableString *str = [[[NSMutableString alloc] init] autorelease];
    [str setString:s];
    REPLACE(@"&", @"&amp;");
    REPLACE(@"<", @"&lt;");
    REPLACE(@">", @"&gt;");
    return str;
}

@end
