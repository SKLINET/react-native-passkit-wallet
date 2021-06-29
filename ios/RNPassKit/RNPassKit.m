//
//  RNPassKit.m
//  RNPassKit
//
//  Created by Masayuki Iwai on 2018/02/09.
//  Copyright © 2018 Masayuki Iwai. All rights reserved.
//

#import <PassKit/PassKit.h>
#import "RNPassKit.h"

@implementation RNPassKit

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(canAddPasses:(RCTPromiseResolveBlock)resolve
                  rejector:(RCTPromiseRejectBlock)reject) {
  resolve(@([PKAddPassesViewController canAddPasses]));
}

RCT_EXPORT_METHOD(addPass:(NSString *)base64Encoded
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejector:(RCTPromiseRejectBlock)reject) {
  NSData *data = [[NSData alloc] initWithBase64EncodedString:base64Encoded options:NSUTF8StringEncoding];
  NSError *error;
  PKPass *pass = [[PKPass alloc] initWithData:data error:&error];

  if (error) {
    reject(@"", @"Failed to create pass.", error);
    return;
  }
  
  dispatch_async(dispatch_get_main_queue(), ^{
    UIApplication *sharedApplication = RCTSharedApplication();
    UIWindow *window = sharedApplication.keyWindow;
    if (window) {
      UIViewController *rootViewController = window.rootViewController;
      if (rootViewController) {
        PKAddPassesViewController *addPassesViewController = [[PKAddPassesViewController alloc] initWithPass:pass];
        addPassesViewController.delegate = self;
        [rootViewController presentViewController:addPassesViewController animated:YES completion:^{
          // Succeeded
          resolve(nil);
        }];
        return;
      }
    }
    
    reject(@"", @"Failed to present PKAddPassesViewController.", nil);
  });
}


RCT_EXPORT_METHOD(addPasses:(NSArray *)arrayOfBase64Encoded
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejector:(RCTPromiseRejectBlock)reject) {

  NSMutableArray *passesMutableArray = [[NSMutableArray alloc] initWithCapacity:[arrayOfBase64Encoded count]];

  for (int i = 0; i < [arrayOfBase64Encoded count]; i++) {
    NSData *data = [[NSData alloc] initWithBase64EncodedString:[arrayOfBase64Encoded objectAtIndex:i] options:NSUTF8StringEncoding];
    NSError *error;
    PKPass *pass = [[PKPass alloc] initWithData:data error:&error];

    [passesMutableArray addObject:pass];
  }
  
  NSArray *passesArray = [passesMutableArray copy];
  
  if (error) {
    reject(@"", @"Failed to create pass.", error);
    return;
  }
  
  dispatch_async(dispatch_get_main_queue(), ^{
    UIApplication *sharedApplication = RCTSharedApplication();
    UIWindow *window = sharedApplication.keyWindow;
    if (window) {
      UIViewController *rootViewController = window.rootViewController;
      if (rootViewController) {
        PKAddPassesViewController *addPassesViewController = [[PKAddPassesViewController alloc] initWithPasses:passesArray];
        addPassesViewController.delegate = self;
        [rootViewController presentViewController:addPassesViewController animated:YES completion:^{
          // Succeeded
          resolve(nil);
        }];
        return;
      }
    }
    
    reject(@"", @"Failed to present PKAddPassesViewController.", nil);
  });
}


- (NSDictionary *)constantsToExport {
  PKAddPassButton *addPassButton = [[PKAddPassButton alloc] initWithAddPassButtonStyle:PKAddPassButtonStyleBlack];
  [addPassButton layoutIfNeeded];
  
  return @{
           @"AddPassButtonStyle": @{
               @"black": @(PKAddPassButtonStyleBlack),
               @"blackOutline": @(PKAddPassButtonStyleBlackOutline),
               },
           @"AddPassButtonWidth": @(CGRectGetWidth(addPassButton.frame)),
           @"AddPassButtonHeight": @(CGRectGetHeight(addPassButton.frame)),
           };
}

+ (BOOL)requiresMainQueueSetup {
    return YES;
}

#pragma mark - PKAddPassesViewControllerDelegate

- (void)addPassesViewControllerDidFinish:(PKAddPassesViewController *)controller {
  [controller dismissViewControllerAnimated:YES completion:^{
    [self sendEventWithName:@"addPassesViewControllerDidFinish" body:nil];
  }];
}

#pragma mark - RCTEventEmitter implementation

- (NSArray<NSString *> *)supportedEvents {
  return @[@"addPassesViewControllerDidFinish"];
}

@end
