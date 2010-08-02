//
//  MyDocument.h
//  ReSTless
//
//  Created by Aaron Hillegass on 3/25/08.
//  Copyright __MyCompanyName__ 2008 . All rights reserved.
//


#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface MyDocument : NSDocument
{
    IBOutlet NSTextView *editView;
    IBOutlet WebView *webView;
    
    NSTextStorage *textStorage;
}
- (IBAction)renderRest:(id)sender;
@end
