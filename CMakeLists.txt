cmake_minimum_required(VERSION 3.16)

project(DashBeam VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)

qt_standard_project_setup(REQUIRES 6.5)

qt_add_executable(DashBeamApp
    src/main.cpp
    src/UdpListener.h
    src/UdpListener.cpp
    src/NetInfo.h
    src/NetInfo.cpp

)

qt_add_qml_module(DashBeamApp
    URI DashBeam
    VERSION 1.0
    QML_FILES Main.qml CircleMeter.qml
    RESOURCES assets/Aldrich-Regular.ttf assets/signal_l.png assets/signal_r.png
    RESOURCES android/AndroidManifest.xml android/build.gradle android/res/values/libs.xml android/res/xml/qtprovider_paths.xml android/gradle/wrapper/gradle-wrapper.jar android/gradle/wrapper/gradle-wrapper.properties android/gradle.properties android/gradlew android/gradlew.bat

)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(DashBeamApp PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.DashBeamApp
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(DashBeamApp PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::Concurrent
)

include(GNUInstallDirs)
install(TARGETS DashBeamApp
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# Android
if (ANDROID)
    set_target_properties(DashBeamApp PROPERTIES
        QT_ANDROID_PACKAGE_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/android
    )
    qt6_android_generate_deployment_settings(DashBeamApp)
    qt_android_add_apk_target(DashBeamApp)
endif ()
