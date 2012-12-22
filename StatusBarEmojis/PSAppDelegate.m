//
//  PSAppDelegate.m
//  StatusBarEmojis
//
//  Created by Patrick on 21.12.12.
//  Copyright (c) 2012 Patrick. All rights reserved.
//

#import "PSAppDelegate.h"

@implementation PSAppDelegate
@synthesize mainMenu;

- (void)awakeFromNib
{
    emojiCategoryNames = [[NSMutableArray alloc] initWithObjects:nil];
    emojiStrings = [[NSMutableArray alloc] initWithObjects:nil];
    [self setupMainMenu];
    
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    NSString *emoji = [NSString stringWithFormat:@"\U0001F604"];
    [statusItem setTitle:emoji];
    [statusItem setMenu:mainMenu];
    [statusItem setHighlightMode:YES];
}

- (void)setupMainMenu
{
    [self readPlist];
    [mainMenu removeAllItems];
    
    if ([emojiCategoryNames count] == [emojiStrings count]) {
        for (NSUInteger i = 0; i < [emojiCategoryNames count]; i++) {
            [mainMenu addItem: [self setupEmojiMenuWithName:[emojiCategoryNames objectAtIndex:i]
                                                  andString:[emojiStrings objectAtIndex:i]]];
        }
    } else {
        NSLog(@"ERROR: Something went wrong, categorynames and emojistrings have different count");
    }
}

- (NSMenuItem *)setupEmojiMenuWithName:(NSString *)name andString:(NSString *)strings
{
    NSArray *emojiString = [self splitStringDataintoStrings:strings];
    NSMenu *emojiMenu = [[NSMenu alloc] init];
    
    for (NSString *code in emojiString) {
        NSScanner *scanner = [NSScanner scannerWithString:code];
        unsigned int val = 0;
        (void) [scanner scanHexInt:&val];
        NSString *emoji = [[NSString alloc] initWithBytes:&val length:sizeof(val) encoding:NSUTF32LittleEndianStringEncoding];
        
        if ([emoji length] > 0) {
            NSMenuItem *newItem = [[NSMenuItem alloc] initWithTitle:emoji action:@selector(MenuItemSelected:) keyEquivalent:@""];
            [newItem setTarget:self];
            [emojiMenu addItem:newItem];
        }
    }
    
    NSMenuItem *emojiGroupMenuItem = [[NSMenuItem alloc] initWithTitle:name action:NULL keyEquivalent:@""];
    [emojiGroupMenuItem setSubmenu: emojiMenu];
    
    return emojiGroupMenuItem;
}

- (void)MenuItemSelected:(id)argument
{
    NSMenuItem *item = argument;
    //NSLog(@"DBG: Selected emoji: %@", item.title);
    [self writeStringToPasteboard:item.title];
}

- (BOOL)writeStringToPasteboard:(NSString *)string
{
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    [pasteboard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:nil];
    
    return [pasteboard setString:string forType:NSStringPboardType];
}

- (void)readPlist
{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Category-Emoji" ofType:@"plist"];
    NSDictionary *emojiDictionary = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    
    NSArray *emojiDataArray = [emojiDictionary objectForKey:@"EmojiDataArray"];
    
    for (NSDictionary *dic in emojiDataArray) {
        // extract emoji category name
        NSString *title = [dic objectForKey:@"CVDataTitle"];
        [emojiCategoryNames addObject:[self getTitleFromPlistString:title]];
        
        // extract emoji string name
        NSDictionary *dicData = [dic objectForKey:@"CVCategoryData"];
        NSString *emojiString = [dicData objectForKey:@"Data"];
        [emojiStrings addObject:emojiString];
    }
}

- (NSString *) getTitleFromPlistString:(NSString *)title
{
    NSString *subString = [[title componentsSeparatedByString:@"-"] lastObject];
    
    return subString;
}

- (NSArray *)splitStringDataintoStrings:(NSString *)stringData
{
    NSArray *strings = [stringData componentsSeparatedByString:@","];

    return strings;
}

@end