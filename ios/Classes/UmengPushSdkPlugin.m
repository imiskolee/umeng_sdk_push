#import "UmengPushSdkPlugin.h"

#import <UMPush/UMessage.h>
#include <arpa/inet.h>

@interface UMengflutterpluginForPush : NSObject
@end
@implementation UMengflutterpluginForPush : NSObject

+ (BOOL)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result{
    BOOL resultCode = YES;
    if ([@"register" isEqualToString:call.method]){
        ////设置注册的参数，如果不需要自定义的特殊功能可以直接在registerForRemoteNotificationsWithLaunchOptions的Entity传入一个nil.
        UMessageRegisterEntity * entity = [[UMessageRegisterEntity alloc] init];
        //type是对推送的几个参数的选择，可以选择一个或者多个。默认是三个全部打开，即：声音，弹窗，角标
        entity.types = UMessageAuthorizationOptionBadge|UMessageAuthorizationOptionAlert|UMessageAuthorizationOptionSound;
        //友盟推送的注册方法
        [UMessage registerForRemoteNotificationsWithLaunchOptions:nil Entity:entity completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
                //点击允许
                //result(@(YES));
            } else {
                //点击不允许
                //result(@(NO));
            }
        }];
    }
    else if([@"getDeviceToken" isEqualToString:call.method]){
        NSData* deviceToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"kUMessageUserDefaultKeyForDeviceToken"];
        NSString* resultStr = NULL;
        if ([deviceToken isKindOfClass:[NSData class]]){
            const unsigned *tokenBytes = (const unsigned *)[deviceToken bytes];
            NSString *hexToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                                  ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                                  ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                                  ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
            resultStr = hexToken;
        }
        else{
            resultStr = @"";
        }
        result(resultStr);
        
    }
    else if([@"addAlias" isEqualToString:call.method]){
        NSDictionary* arguments = (NSDictionary *)call.arguments;
        NSString* name = [arguments valueForKey:@"alias"];
        NSString* type = [arguments valueForKey:@"type"];
        [UMessage addAlias:name type:type response:^(id  _Nonnull responseObject, NSError * _Nonnull error) {
            //NSMutableDictionary* resultDic = [[NSMutableDictionary alloc] init];
            NSNumber* resultNum = NULL;
            if (error) {
                NSLog(@"error:%@",error);
                //[resultDic setValue:error.description forKey:@"error"];
                resultNum = [NSNumber numberWithBool:NO];
            }
            else{
                NSLog(@"responseObject:%@",responseObject);
//                if ([responseObject isKindOfClass:[NSDictionary class]]) {
//                    [resultDic addEntriesFromDictionary:responseObject];
//                }
                resultNum = [NSNumber numberWithBool:YES];
            }
            //NSString* resultStr =  jsonStringForPlugin(resultDic);
            dispatch_async(dispatch_get_main_queue(), ^{
                result(resultNum);
            });
        }];
        
    }
    else if([@"setAlias" isEqualToString:call.method]){
        NSDictionary* arguments = (NSDictionary *)call.arguments;
        NSString* name = [arguments valueForKey:@"alias"];
        NSString* type = [arguments valueForKey:@"type"];
        [UMessage setAlias:name type:type response:^(id  _Nonnull responseObject, NSError * _Nonnull error) {
            NSNumber* resultNum = NULL;
            if (error) {
                NSLog(@"error:%@",error);
                resultNum = [NSNumber numberWithBool:NO];
            }
            else{
                NSLog(@"responseObject:%@",responseObject);
                resultNum = [NSNumber numberWithBool:YES];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                result(resultNum);
            });
        }];
        
    }
    else if([@"removeAlias" isEqualToString:call.method]){
        NSDictionary* arguments = (NSDictionary *)call.arguments;
        NSString* name = [arguments valueForKey:@"alias"];
        NSString* type = [arguments valueForKey:@"type"];
        [UMessage removeAlias:name type:type response:^(id  _Nonnull responseObject, NSError * _Nonnull error) {
            NSNumber* resultNum = NULL;
            if (error) {
                NSLog(@"error:%@",error);
                resultNum = [NSNumber numberWithBool:NO];
            }
            else{
                NSLog(@"responseObject:%@",responseObject);
                resultNum = [NSNumber numberWithBool:YES];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                result(resultNum);
            });
        }];
    }
    else if([@"addTag" isEqualToString:call.method]){
        NSArray* arguments = (NSArray *)call.arguments;
        [UMessage addTags:arguments response:^(id  _Nonnull responseObject, NSInteger remain, NSError * _Nonnull error) {
            NSNumber* resultNum = NULL;
            if (error) {
                NSLog(@"error:%@",error);
                resultNum = [NSNumber numberWithBool:NO];
            }
            else{
                NSLog(@"responseObject:%@",responseObject);
                resultNum = [NSNumber numberWithBool:YES];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                result(resultNum);
            });
        }];
    }
    else if([@"removeTag" isEqualToString:call.method]){
        NSArray* arguments = (NSArray *)call.arguments;
        [UMessage deleteTags:arguments response:^(id  _Nonnull responseObject, NSInteger remain, NSError * _Nonnull error) {
            NSNumber* resultNum = NULL;
            if (error) {
                NSLog(@"error:%@",error);
                resultNum = [NSNumber numberWithBool:NO];
            }
            else{
                NSLog(@"responseObject:%@",responseObject);
                resultNum = [NSNumber numberWithBool:YES];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                result(resultNum);
            });
        }];
    }
    else if([@"getTags" isEqualToString:call.method]){
        NSArray* arguments = (NSArray *)call.arguments;
        [UMessage getTags:^(NSSet * _Nonnull responseTags, NSInteger remain, NSError * _Nonnull error) {
            NSArray<NSString*>* resultArr = NULL;
            if (error) {
                NSLog(@"error:%@",error);
                resultArr = [NSArray array];
            }
            else{
                NSLog(@"responseTags:%@",responseTags);
                NSArray* tempResultArr = [responseTags allObjects];
                resultArr = [[NSArray alloc] initWithArray:tempResultArr];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                result(resultArr);
            });
        }];
    }
    else if([@"log_enable" isEqualToString:call.method]){
        NSLog(@"log_enable is a empty function。see [UMConfigure setLogEnabled:YES]");
    }
    else if([@"enable" isEqualToString:call.method]){
        NSLog(@"push enable is a empty function");
    }
    else{
        resultCode = NO;
    }
    
    return resultCode;
}
@end

@implementation UmengPushSdkPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"u-push"
            binaryMessenger:[registrar messenger]];
  UmengPushSdkPlugin* instance = [[UmengPushSdkPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else {
    //result(FlutterMethodNotImplemented);
  }
    
    
  BOOL resultCode = [UMengflutterpluginForPush handleMethodCall:call result:result];
  if (resultCode) return;

  result(FlutterMethodNotImplemented);
}

@end
