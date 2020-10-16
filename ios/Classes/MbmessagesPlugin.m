#import "MbmessagesPlugin.h"
#if __has_include(<mbmessages/mbmessages-Swift.h>)
#import <mbmessages/mbmessages-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "mbmessages-Swift.h"
#endif

@implementation MbmessagesPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftMbmessagesPlugin registerWithRegistrar:registrar];
}
@end
