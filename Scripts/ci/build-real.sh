#!/bin/bash

xcodebuild clean build-for-testing \
  -project WebDriverAgent.xcodeproj \
  -derivedDataPath $DERIVED_DATA_PATH \
  -scheme $SCHEME \
  -destination "$DESTINATION" \
  CODE_SIGNING_ALLOWED=NO ARCHS=arm64

pushd $WD

# The reason why here excludes several frameworks are:
# - to remove test packages to refer to the device local instead of embedded ones
#   XCTAutomationSupport.framework, XCTest.framewor, XCTestCore.framework,
#   XCUIAutomation.framework, XCUnit.framework.
#   This can be excluded only for real devices.
# - Xcode 16 started generating 5.9MB of 'Testing.framework', but it might not be necessary for WDA.
# - libXCTestSwiftSupport is used for Swift testing. WDA doesn't include Swift stuff, thus this is not needed.
zip -r $ZIP_PKG_NAME $SCHEME-Runner.app \
    -x "$SCHEME-Runner.app/Frameworks/XC*.framework*" \
       "$SCHEME-Runner.app/Frameworks/Testing.framework*" \
       "$SCHEME-Runner.app/Frameworks/libXCTestSwiftSupport.dylib"
popd
mv $WD/$ZIP_PKG_NAME ./
