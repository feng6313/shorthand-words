#import <Foundation/Foundation.h>

#if __has_attribute(swift_private)
#define AC_SWIFT_PRIVATE __attribute__((swift_private))
#else
#define AC_SWIFT_PRIVATE
#endif

/// The "arrow" asset catalog image resource.
static NSString * const ACImageNameArrow AC_SWIFT_PRIVATE = @"arrow";

/// The "back" asset catalog image resource.
static NSString * const ACImageNameBack AC_SWIFT_PRIVATE = @"back";

/// The "collect_b" asset catalog image resource.
static NSString * const ACImageNameCollectB AC_SWIFT_PRIVATE = @"collect_b";

/// The "collect_w" asset catalog image resource.
static NSString * const ACImageNameCollectW AC_SWIFT_PRIVATE = @"collect_w";

/// The "parting" asset catalog image resource.
static NSString * const ACImageNameParting AC_SWIFT_PRIVATE = @"parting";

#undef AC_SWIFT_PRIVATE
