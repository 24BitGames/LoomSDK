# On OSX, only build for i386.
if (NOT LOOM_BUILD_IOS EQUAL 1)
  set(CMAKE_OSX_ARCHITECTURES "i386")
endif()

project(${APPLICATION_NAME})

include_directories( ${LOOM_INCLUDE_FOLDERS} )

set (APPLICATION_SRC
    common/AppDelegate.cpp
    common/embeddedAssets.cpp
)

set (APPLICATION_HDR
    common/AppDelegate.h
)

if (MSVC)
    set (APPLICATION_SRC
      ${APPLICATION_SRC}
      windows/main.cpp
    )

endif()

if (LINUX)
    set (APPLICATION_SRC
      ${APPLICATION_SRC}
      linux/main.cpp
    )
endif()

if (APPLE)
    if (LOOM_BUILD_IOS EQUAL 1)
        
        set(APPLE_ICON_FILES ios/Icon-144.png ios/Icon-114.png ios/Icon-72.png ios/Icon-57.png)
        set (APPLICATION_SRC
          ${APPLICATION_SRC}
          ios/Default.png
          ios/main.m
          ios/AppController.mm
          ios/RootViewController.mm
        )
        
        SET_SOURCE_FILES_PROPERTIES(ios/Default.png PROPERTIES MACOSX_PACKAGE_LOCATION Resources )

    else()
        
        set(APPLE_ICON_FILES osx/Application.icns)
        set (APPLICATION_SRC
          ${APPLICATION_SRC}
          osx/Application.icns
          osx/Info.plist
          osx/main.m
          osx/AppController.mm
          osx/en.lproj/MainMenu.xib
        )

        SET_SOURCE_FILES_PROPERTIES(osx/en.lproj/MainMenu.xib  PROPERTIES MACOSX_PACKAGE_LOCATION Resources )
    endif()

    # Configure the app's icon.
    set (APPLICATION_SRC ${APPLICATION_SRC} ${APPLE_ICON_FILES})
    set_source_files_properties( ${APPLE_ICON_FILES} PROPERTIES MACOSX_PACKAGE_LOCATION Resources)
endif() 



if (ANDROID)
    add_library(${PROJECT_NAME} SHARED ${APPLICATION_HDR} ${APPLICATION_SRC})
elseif(APPLE)
    add_executable(${PROJECT_NAME} MACOSX_BUNDLE ${APPLICATION_HDR} ${APPLICATION_SRC})
elseif(MSVC)
    add_executable(${PROJECT_NAME} WIN32 ${APPLICATION_HDR} ${APPLICATION_SRC})
else()
    add_executable(${PROJECT_NAME} ${APPLICATION_HDR} ${APPLICATION_SRC})
endif(ANDROID)

if (APPLE)

    if (LOOM_BUILD_JIT EQUAL 1)        
          #FIXME: This is to satisfy some jit specific symbols
          set (LOOM_IOS_LIB_GCC "/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/llvm-gcc-4.2/lib/gcc/arm-apple-darwin10/4.2.1/v7/libgcc.a")
    endif()

    if (LOOM_BUILD_IOS EQUAL 1)

        target_link_libraries(${PROJECT_NAME}
    
          ${LOOM_IOS_LIB_GCC}
          LoomVendor
          LoomCommon
          LoomScript
          LoomGraphics
          LoomCore
          
          "-framework CoreGraphics"
          "-framework CoreFoundation"
          "-framework CoreMotion"
          "-framework Foundation"
          "-framework UIKit"
          "-framework IOKit"
          "-framework GLKit"  
          "-framework OpenGLES"
          "-framework StoreKit"
          "-framework OpenGLES"
          "-framework MessageUI"
          "-framework SystemConfiguration"
          "-framework AdSupport"

          # For CocosDenshion
          "-framework AVFoundation"
          "-framework AudioToolbox"
          "-framework OpenAL"  

          # Admob SDK
          ${CMAKE_SOURCE_DIR}/loom/vendor/admob/lib/ios/libGoogleAdMobAds.a
          "-ObjC"
          )

        #iPhone app bundle
        set_target_properties(${PROJECT_NAME} PROPERTIES
          MACOSX_BUNDLE_GUI_IDENTIFIER ${APPLICATION_PACKAGE}
          XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "iPhone Developer"
          XCODE_ATTRIBUTE_DEBUG_INFORMATION_FORMAT "dwarf-with-dsym"
          XCODE_ATTRIBUTE_INFOPLIST_PREPROCESS YES
          XCODE_ATTRIBUTE_IPHONEOS_DEPLOYMENT_TARGET 5.1
          XCODE_ATTRIBUTE_TARGETED_DEVICE_FAMILY "1,2" # Build a universal (iPad/iPhone) app.
        )
        # Use our own Info.plist.
        CONFIGURE_FILE("${CMAKE_CURRENT_LIST_DIR}/ios/Info.plist" "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.plist")
        SET_TARGET_PROPERTIES(${PROJECT_NAME} PROPERTIES MACOSX_BUNDLE_INFO_PLIST "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.plist")

    else()
        target_link_libraries(${PROJECT_NAME} 
           LoomVendor
           LoomCommon
           LoomScript
           LoomGraphics
           LoomCore
           "-framework IOKit"
           "-framework CoreFoundation"
           "-framework Cocoa"
           "-framework OpenGL"
           "-framework WebKit"

          # For CocosDenshion
          "-framework AudioToolbox"
          "-framework OpenAL"  
        )

        # Use our own Info.plist.
        set_target_properties(${PROJECT_NAME} PROPERTIES MACOSX_BUNDLE_INFO_PLIST "${CMAKE_CURRENT_SOURCE_DIR}/osx/Info.plist")

        # Process our XIB wth ibtool.
        
        # TODO: This works fine under xcode but we might not always want it, it
        # appears that CMAKE_GENERATOR holds the current generator and could be 
        # used to filter this.

        # Make sure we can find the 'ibtool' program. If we can NOT find it we
        # skip generation of this project
        find_program(IBTOOL ibtool HINTS "/usr/bin" "${OSX_DEVELOPER_ROOT}/usr/bin")
        if (${IBTOOL} STREQUAL "IBTOOL-NOTFOUND")
          message(SEND_ERROR "ibtool can not be found and is needed to compile the .xib files. It should have been installed with 
                            the Apple developer tools. The default system paths were searched in addition to ${OSX_DEVELOPER_ROOT}/usr/bin")
        endif()

        # Locate the .app and process the XIB into it.
        get_target_property(APPLICATION_BIN ${APPLICATION_NAME} LOCATION)
        get_dotapp_dir(${APPLICATION_BIN} APPLICATION_APP_LOCATION)
        add_custom_command (TARGET ${PROJECT_NAME} POST_BUILD 
                          COMMAND ${IBTOOL} --errors --warnings --notices --output-format human-readable-text 
                                  --compile ${APPLICATION_APP_LOCATION}/Contents/Resources/MainMenu.nib 
                                 ${CMAKE_CURRENT_SOURCE_DIR}/osx/en.lproj/MainMenu.xib
                          COMMENT "Compiling osx/MainMenu.xib")

        # OSX app bundle
        set_target_properties(${PROJECT_NAME} PROPERTIES
          MACOSX_BUNDLE_GUI_IDENTIFIER ${APPLICATION_PACKAGE}
          XCODE_ATTRIBUTE_DEBUG_INFORMATION_FORMAT "dwarf-with-dsym"
          XCODE_ATTRIBUTE_INFOPLIST_PREPROCESS YES
        )

    endif()
    
    if (LOOM_BUILD_JIT EQUAL 1)
        target_link_libraries(${PROJECT_NAME} ${LOOM_LUAJIT_LIB})
    endif()
    
elseif(MSVC)	


    target_link_libraries(${PROJECT_NAME} 
       LoomVendor
       LoomCommon
       LoomScript
       LoomGraphics
       LoomCore
       "kernel32" "advapi32" "COMCTL32" "COMDLG32" "USER32" "ADVAPI32" "GDI32" "WINMM" "WSOCK32" "Ws2_32" 
       ${CMAKE_SOURCE_DIR}/loom/vendor/zlib/lib/win32/zlibstatic.lib
    )

    if (LOOM_BUILD_JIT EQUAL 1)
        target_link_libraries(${PROJECT_NAME} ${LOOM_LUAJIT_LIB})
    endif()

    if (LOOM_TELEMETRY)
        target_link_libraries(${PROJECT_NAME} "telemetry32.link" "telemetry64.link")
    endif()

    get_target_property(DEMOBIN ${PROJECT_NAME} LOCATION)
     
    add_custom_command(TARGET ${PROJECT_NAME}
        POST_BUILD
        COMMAND echo f | xcopy /F /Y \"${DEMOBIN}\" \"${CMAKE_SOURCE_DIR}/artifacts/windows/LoomDemo.exe\"
    )
    
    
elseif(ANDROID)

    target_link_libraries(${PROJECT_NAME}
       LoomVendor
       LoomCommon
       LoomScript
       LoomCore
       "GLESv2" "EGL" "dl" "log" "android"
    )
    
    get_target_property(ANDROID_SO ${PROJECT_NAME} LOCATION)
     
    add_custom_command(TARGET ${PROJECT_NAME}
        POST_BUILD
        set(ANDROID_SO_COPY_SRC, "${ANDROID_SO}")
        set(ANDROID_SO_COPY_DST, "${CMAKE_SOURCE_DIR}/application/android/libs/armeabi-v7a")
        string(REPLACE, "/", "\", ANDROID_SO_COPY_SRC_WIN32 ${ANDROID_SO_COPY_SRC})
        string(REPLACE, "/", "\", ANDROID_SO_COPY_DST_WIN32 ${ANDROID_SO_COPY_DST})
        if(WIN32)
          COMMAND mkdir ${ANDROID_SO_COPY_DST_WIN32}
          COMMAND xcopy /I /Y ${ANDROID_SO_COPY_SRC_WIN32} ${ANDROID_SO_COPY_DST_WIN32}
        else()
          COMMAND mkdir -p ${ANDROID_SO_COPY_DST}
          COMMAND cp ${ANDROID_SO_COPY_SRC} ${ANDROID_SO_COPY_DST_WIN32}
      endif()
      )

elseif(LINUX)

    target_link_libraries(${PROJECT_NAME}
       LoomVendor
       LoomCommon
       LoomScript
       LoomGraphics
       LoomCore
       -lGL -lGLEW -lGLU -lglfw -lcurl
    )

    if (LOOM_BUILD_JIT EQUAL 1)
        target_link_libraries(${PROJECT_NAME} ${LOOM_LUAJIT_LIB} -ldl)
    endif()
    
    get_target_property(DEMOBIN ${PROJECT_NAME} LOCATION)
     
    add_custom_command(TARGET ${PROJECT_NAME}
        POST_BUILD
        COMMAND mkdir -p ${CMAKE_SOURCE_DIR}/artifacts/ubuntu
        COMMAND cp ${DEMOBIN} ${CMAKE_SOURCE_DIR}/artifacts/ubuntu/LoomDemo
    )    
endif()