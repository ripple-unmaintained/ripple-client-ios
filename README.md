ripple-client-ios
=================

Ripple iOS Client

### Instructions:

```
git clone git@github.com:ripple/ripple-client-ios.git
cd ripple-client-ios
pod install
open Ripple.xcworkspace
```


### Disable Apple App store digital currency restrictions:

Change flag to NO in the RPGlobals.h file 

https://github.com/ripple/ripple-client-ios/blob/master/Ripple/RPGlobals.h#L18

```
// Required for the Apple App Store
#define GLOBAL_RESTRICT_DIGITAL_CURRENCIES       NO
```
