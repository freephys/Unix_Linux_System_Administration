//
//  MyDocument.m
//  ReSTless
//
//  Created by Aaron Hillegass on 3/25/08.
//  Copyright __MyCompanyName__ 2008 . All rights reserved.
//

#import "MyDocument.h"

@implementation MyDocument

- (id)init
{
    if (![super init]) {
        return nil;
    }
    textStorage = [[NSTextStorage alloc] init];
    return self;
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"MyDocument";
}

- (void)prepareEditView
{
    NSLayoutManager *lm = [editView layoutManager];
    [[editView textStorage] removeLayoutManager:lm];
    [textStorage addLayoutManager:lm];
}

- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
    [super windowControllerDidLoadNib:aController];
    [self prepareEditView];
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    NSData *d = [[textStorage string] dataUsingEncoding:NSUTF8StringEncoding];
    return d;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    NSString *string = [[NSString alloc] initWithData:data
                                             encoding:NSUTF8StringEncoding];
    if (!string) {
        if (outError) {
            NSDictionary *d = [NSDictionary dictionaryWithObject:@"Corrupt file"
                                                          forKey:NSLocalizedDescriptionKey];
            *outError = [NSError errorWithDomain:@"ReSTless"
                                             code:1
                                         userInfo:d];
        }
        return NO;
    }
    [textStorage release];
    textStorage = [[NSTextStorage alloc] initWithString:string
                                             attributes:nil];
    // Is this a revert?
    if (editView) {
        [self prepareEditView];
    }
    
    return YES;
}

- (IBAction)renderRest:(id)sender
{  
    NSData *inData = [[textStorage string] dataUsingEncoding:NSUTF8StringEncoding];
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/Library/Frameworks/Python.framework/Versions/Current/bin/rst2html.py"];
    NSPipe *inPipe = [[NSPipe alloc] init];
    [task setStandardInput:inPipe];
    
    NSPipe *outPipe = [[NSPipe alloc] init];
    [task setStandardOutput:outPipe];

    [task launch];
    [[inPipe fileHandleForWriting] writeData:inData];
    [[inPipe fileHandleForWriting] closeFile];
    
    NSData *outData = [[outPipe fileHandleForReading] readDataToEndOfFile];
    NSString *htmlString = [[NSString alloc] initWithData:outData
                                                 encoding:NSUTF8StringEncoding];
    
    WebFrame *wf = [webView mainFrame];
    [wf loadHTMLString:htmlString
               baseURL:nil];
    [htmlString release];
}



@end
