#!/bin/sh

#Development
WORKSPACE_NAME="iHappy.xcworkspace"
SCHEME_NAME="iHappy"
ARCHIVE_FILE_NAME="iHappy_debug"
CONFIGURATION="Debug"
BUILD_PATH="build_debug"

#clean
rm -rf build
rm -rf "${BUILD_PATH}"
xcodebuild clean -configuration "${CONFIGURATION}" -alltargets
#app-store, ad-hoc, package, enterprise, development, and developer-id

#签名只需修改CODE_SIGN_IDENTITY即可，系统会根据CODE_SIGN_IDENTITY与工程中的bundle identifier自动匹配PROVISIONING_PROFILE

#exportOptionsPlist   method = enterprise  企业发布证书 -->
#exportOptionsPlist   method = ad-hoc  企业发布证书 -->
#exportOptionsPlist   method = development  个人开发证书  -->EXPORT SUCCESS 成功
#exportOptionsPlist   method = enterprise  个人开发证书 --> EXPORT FAILED 失败
#exportOptionsPlist   method = app-store  个人开发证书 -->EXPORT FAILED 失败
#exportOptionsPlist   method = app-store  个人发布证书 -->

#CODE_SIGN_IDENTITY="iPhone Developer: mu he (FX98SJ5KRZ)"
#PROVISIONING_PROFILE="1a41a70c-a26e-4d3d-91bf-889445490895"
#企业发布证书
#CODE_SIGN_IDENTITY="iPhone Distribution: SHANGHAI ZENDAI INVESTMENT & CONSULTING CO., LTD."
#PROVISIONING_PROFILE="fc5b32f1-f96d-40bb-953c-27f751e0eab2"


CODE_SIGN_IDENTITY="iPhone Developer: dosom xu (RPYJA8EBQM)"
#PROVISIONING_PROFILE="b4693833-d4cb-4a6b-a877-3210769128a7"
XCARCHIVE_PATH="${BUILD_PATH}/${ARCHIVE_FILE_NAME}.xcarchive"

xcodebuild -workspace "$WORKSPACE_NAME" -scheme "$SCHEME_NAME" -configuration "$CONFIGURATION"  -archivePath "$XCARCHIVE_PATH" CODE_SIGN_IDENTITY="$CODE_SIGN_IDENTITY" archive

EXPORT_OPTIONS_PLIST_PATH="BuildScript/Dev_ExportOptions.plist"
IPA_PATH="${BUILD_PATH}"
xcodebuild -exportArchive -archivePath "$XCARCHIVE_PATH" -exportPath "$IPA_PATH" -exportOptionsPlist "$EXPORT_OPTIONS_PLIST_PATH"
CODE_SIGN_IDENTITY="$CODE_SIGN_IDENTITY" PROVISIONING_PROFILE="$PROVISIONING_PROFILE"

###################################
#发布到fim.im
###################################

firApiToken="a29be0d51c2bfb85b53d1f6cf67fb2e5"
fir publish "${IPA_PATH}/${SCHEME_NAME}.ipa" -T "$firApiToken"
osascript -e 'display notification "Release To Fir.im" with title "Upload Complete!"'
