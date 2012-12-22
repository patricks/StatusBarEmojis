//
//  PSAppDelegate.h
//  StatusBarEmojis
//
//  Created by Patrick on 21.12.12.
//  Copyright (c) 2012 Patrick. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PSAppDelegate : NSObject <NSApplicationDelegate> {
    NSStatusItem *statusItem;
    NSMutableArray *emojiCategoryNames;
    NSMutableArray *emojiStrings;
}

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSMenu *mainMenu;

@end
