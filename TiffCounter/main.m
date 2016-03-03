//
//  main.m
//  TiffCounter
//
//  Created by Matt Shepherd on 3/1/16.
//  Copyright © 2016 Matt Shepherd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        //you could implement handling any path by using arguments like below
        //NSString *path = [NSString stringWithUTF8String:argv[1]];
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        NSURL *directoryURL = [NSURL fileURLWithPath:@"some path to url"];
        NSArray *keys = [NSArray arrayWithObject:NSURLIsDirectoryKey];
        
        NSDirectoryEnumerator *enumerator = [fileManager
                                             enumeratorAtURL:directoryURL
                                             includingPropertiesForKeys:keys
                                             options:0
                                             errorHandler:^(NSURL *url, NSError *error) {
                                                 // Handle the error.
                                                 // Return YES if the enumeration should continue after the error.
                                                 return YES;
                                             }];
        int numPages = 0;
        int numfiles = 0;
        for (NSURL *url in enumerator) { 
            NSError *error;
            NSNumber *isDirectory = nil;
            if (! [url getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:&error]) {
                // handle error
                NSLog(@"%@",error.description);
            }
            else if (! [isDirectory boolValue]) {
                // No error and it’s not a directory; do something with the file
                if([url.pathExtension.uppercaseString isEqualToString:@"TIF"] || [url.pathExtension.uppercaseString isEqualToString:@"TIFF"]){
                    //extra autorelease pool to keep memory from growing in for loop
                    @autoreleasepool {
                        NSImage *tiffImage = [[NSImage alloc] initWithContentsOfURL:url];
                        int tiffPages = (int)[[tiffImage representations] count];
                        tiffImage = nil;
                        numPages = numPages + tiffPages;
                        //NSLog(@"num pages is %d", numPages);
                        NSString *outputString = [NSString stringWithFormat:@"%@,%d",[url path],tiffPages];
                        printf("%s\n", [outputString UTF8String]);
                        outputString = nil;
                    }
                    numfiles++;
                }else{
                    //NSLog(@"%@ not tiff",url.path);
                    //do nothing for now, we only care about tiffs
                }
                
            }
        }
        NSString *summaryString = [NSString stringWithFormat:@"%d tiffs processed, total of %d",numfiles,numPages];
        printf("%s\n", [summaryString UTF8String]);
    }
    return 0;
}
