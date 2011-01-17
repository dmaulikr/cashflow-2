// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-

#import "CurrencyManager.h"

@implementation CurrencyManager

@synthesize baseCurrency;
@synthesize currencies;

+ (CurrencyManager *)instance
{
    static CurrencyManager *theInstance = nil;
    if (theInstance == nil) {
        theInstance = [[CurrencyManager alloc] init];
    }
    return theInstance;
}

- (id)init
{
    [super init];

    NSNumberFormatter *nf;

    nf = [[NSNumberFormatter alloc] init];
    [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
    [nf setLocale:[NSLocale currentLocale]];
    numberFormatter = nf;

    self.currencies =
        [NSArray arrayWithObjects:
         @"AED",
         @"AUD",
         @"BHD",
         @"BND",
         @"BRL",
         @"CAD", 
         @"CHF",
         @"CLP",
         @"CNY",
         @"CYP",
         @"CZK",
         @"DKK",
         @"EUR",
         @"GBP",
         @"HKD",
         @"HUF",
         @"IDR",
         @"ILS",
         @"INR",
         @"ISK",
         @"JPY",
         @"KRW",
         @"KWD",
         @"KZT",
         @"LKR",
         @"MTL",
         @"MUR",
         @"MXN",
         @"MYR",
         @"NOK",
         @"NPR",
         @"NZD",
         @"OMR",
         @"PKR",
         @"QAR",
         @"RUB",
         @"SAR",
         @"SEK",
         @"SGD",
         @"SKK",
         @"THB",
         @"TWD",
         @"USD",
         @"ZAR",
         nil];

    self.baseCurrency = [[NSUserDefaults standardUserDefaults] objectForKey:@"BaseCurrency"];

    return self;
}

+ (NSString *)systemCurrency
{
    NSNumberFormatter *nf = [[[NSNumberFormatter alloc] init] autorelease];
    [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
    return [nf currencyCode];
}

- (void)setBaseCurrency:(NSString *)currency
{
    if (baseCurrency != currency) {
        [baseCurrency release];
        baseCurrency = currency;
        [baseCurrency retain];
        
        if (currency == nil) {
            currency = [CurrencyManager systemCurrency];
        }
        [numberFormatter setCurrencyCode:currency];
        
        [[NSUserDefaults standardUserDefaults] setObject:baseCurrency forKey:@"BaseCurrency"];
    }
}

+ (NSString *)formatCurrency:(double)value
{
    return [[CurrencyManager instance] _formatCurrency:value];
}

- (NSString *)_formatCurrency:(double)value
{
    NSNumber *n = [NSNumber numberWithDouble:value];
    return [numberFormatter stringFromNumber:n];
}

@end
        
