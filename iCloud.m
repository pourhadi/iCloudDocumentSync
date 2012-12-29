//
//  iCloud.m
//  iCloud Document Sync
//
//  Created by iRare Media on 12/29/12.
//
//

#import "iCloud.h"

@implementation iCloud
@synthesize delegate;

+ (void)createDocumentWithData:(NSData *)data withName:(NSString *)name
{
    //Perform tasks on background thread to avoid problems on the main / UI thread
	dispatch_queue_t addDoc = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(addDoc, ^{
        //Save the file locally using the specified data and name
        NSFileManager *filemgr = [NSFileManager defaultManager];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        [filemgr createFileAtPath:[documentsDirectory stringByAppendingPathComponent:name] contents:data attributes:nil];
        
        //Move the file to iCloud
        NSURL *ubiquitousURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
        NSURL *destinationURL = [ubiquitousURL URLByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@",name]];
        NSURL *directoryURL = [[NSURL alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:name]];
        [filemgr setUbiquitous:YES itemAtURL:directoryURL destinationURL:destinationURL error:nil];
    });
    
    [[self delegate] documentWasSaved];
}

+ (void)removeDocumentWithName:(NSString *)name
{
    //Create the complete file path
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:name];
    [[self delegate] documentWasDeleted];
    
}

@end