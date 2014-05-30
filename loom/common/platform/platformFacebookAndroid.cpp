/*
 * ===========================================================================
 * Loom SDK
 * Copyright 2011, 2012, 2013
 * The Game Engine Company, LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ===========================================================================
 */

#include "loom/common/platform/platform.h"

#if LOOM_PLATFORM == LOOM_PLATFORM_ANDROID

#include <jni.h>
#include "platformAndroidJni.h"

#include "loom/common/core/log.h"
#include "loom/common/core/assert.h"
#include "loom/common/platform/platformFacebook.h"
#include "loom/vendor/jansson/jansson.h"
#include "loom/engine/cocos2dx/cocoa/CCString.h"


lmDefineLogGroup(gAndroidFacebookLogGroup, "loom.facebook.android", 1, 0);


static SessionStatusCallback gSessionStatusCallback = NULL;


extern "C"
{
    void Java_co_theengine_loomdemo_LoomFacebook_nativeStatusCallback(JNIEnv* env, jobject thiz, jstring sessonState, jstring sessionPermissions)
    {
        const char *sessonStateString = env->GetStringUTFChars(sessonState, 0);
        const char *sessionPermissionsString = env->GetStringUTFChars(sessionPermissions, 0);

        if (gSessionStatusCallback)
        {
            gSessionStatusCallback(sessonStateString, sessionPermissionsString);
        }
        env->ReleaseStringUTFChars(sessonState, sessonStateString);
        env->ReleaseStringUTFChars(sessionPermissions, sessionPermissionsString);
    }
}


static loomJniMethodInfo gOpenSessionReadPermissions;
static loomJniMethodInfo gRequestNewPublishPermissions;
static loomJniMethodInfo gFrictionlessRequestDialog;
static loomJniMethodInfo gGetAccessToken;
static loomJniMethodInfo gCloseTokenInfo;
static loomJniMethodInfo gGetExpirationDate;


///initializes the data for the Facebook class for Android
void platform_facebookInitialize(SessionStatusCallback sessionStatusCB)
{
    lmLog(gAndroidFacebookLogGroup, "INIT ***** FACEBOOK ***** ANDROID ****");

    gSessionStatusCallback = sessionStatusCB;   
 
    // Bind to JNI entry points.
    LoomJni::getStaticMethodInfo(gOpenSessionReadPermissions,
                                    "co/theengine/loomdemo/LoomFacebook",
                                    "openSessionWithReadPermissions",
                                    "(Ljava/lang/String;)Z");
    LoomJni::getStaticMethodInfo(gRequestNewPublishPermissions,
                                    "co/theengine/loomdemo/LoomFacebook",
                                    "requestNewPublishPermissions",
                                    "(Ljava/lang/String;)Z");
    LoomJni::getStaticMethodInfo(gFrictionlessRequestDialog,
                                    "co/theengine/loomdemo/LoomFacebook",
                                    "showFrictionlessRequestDialog",
                                    "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V");
    LoomJni::getStaticMethodInfo(gGetAccessToken,
                                    "co/theengine/loomdemo/LoomFacebook",
                                    "getAccessToken",
                                    "()Ljava/lang/String;");
    LoomJni::getStaticMethodInfo(gCloseTokenInfo,
                                 "co/theengine/loomdemo/LoomFacebook",
                                 "closeAndClearTokenInformation",
                                 "()V");    
    LoomJni::getStaticMethodInfo(gGetExpirationDate,
                                    "co/theengine/loomdemo/LoomFacebook",
                                    "getExpirationDate",
                                    "(Ljava/lang/String;)Ljava/lang/String;");
}


bool platform_openSessionWithReadPermissions(const char* permissionsString)
{
    jstring jPermissionsString = gOpenSessionReadPermissions.env->NewStringUTF(permissionsString);
    jboolean result = gOpenSessionReadPermissions.env->CallStaticBooleanMethod(gOpenSessionReadPermissions.classID, 
                                                                                gOpenSessionReadPermissions.methodID, 
                                                                                jPermissionsString);
    gOpenSessionReadPermissions.env->DeleteLocalRef(jPermissionsString);
    return result;    
}


bool platform_requestNewPublishPermissions(const char* permissionsString)
{
    jstring jPermissionsString = gRequestNewPublishPermissions.env->NewStringUTF(permissionsString);
    jboolean result = gRequestNewPublishPermissions.env->CallStaticBooleanMethod(gRequestNewPublishPermissions.classID, 
                                                                                    gRequestNewPublishPermissions.methodID, 
                                                                                    jPermissionsString);
    gRequestNewPublishPermissions.env->DeleteLocalRef(jPermissionsString);
    return result;
}


void platform_showFrictionlessRequestDialog(const char* recipientsString, const char* titleString, const char* messageString)
{
    jstring jRecipientsString = gFrictionlessRequestDialog.env->NewStringUTF(recipientsString);
    jstring jTitleString = gFrictionlessRequestDialog.env->NewStringUTF(titleString);
    jstring jMessageString = gFrictionlessRequestDialog.env->NewStringUTF(messageString);
    
    gFrictionlessRequestDialog.env->CallStaticVoidMethod(gFrictionlessRequestDialog.classID, 
                                                            gFrictionlessRequestDialog.methodID, 
                                                            jRecipientsString, 
                                                            jTitleString, 
                                                            jMessageString);
    gFrictionlessRequestDialog.env->DeleteLocalRef(jRecipientsString);
    gFrictionlessRequestDialog.env->DeleteLocalRef(jTitleString);
    gFrictionlessRequestDialog.env->DeleteLocalRef(jMessageString);
}


const char* platform_getAccessToken()
{
    jstring result = (jstring)gGetAccessToken.env->CallStaticObjectMethod(gGetAccessToken.classID, 
                                                                            gGetAccessToken.methodID);
    
    cocos2d::CCString *accessToken = new cocos2d::CCString(LoomJni::jstring2string(result).c_str());
    accessToken->autorelease();
    gGetAccessToken.env->DeleteLocalRef(result);
    return accessToken->m_sString.c_str();
}


void platform_closeAndClearTokenInformation()
{       
    gCloseTokenInfo.env->CallStaticVoidMethod(gCloseTokenInfo.classID, gCloseTokenInfo.methodID);
}


const char* platform_getExpirationDate(const char* dateFormat)
{
    jstring jdateFormatString   = gGetExpirationDate.env->NewStringUTF(dateFormat);

    jstring result = (jstring)gGetExpirationDate.env->CallStaticObjectMethod(gGetExpirationDate.classID, 
                                                                                gGetExpirationDate.methodID,
                                                                                jdateFormatString);

    cocos2d::CCString *expirationDate = new cocos2d::CCString(LoomJni::jstring2string(result).c_str());
    expirationDate->autorelease();
    gGetExpirationDate.env->DeleteLocalRef(result);
    return expirationDate->m_sString.c_str();
}


#endif