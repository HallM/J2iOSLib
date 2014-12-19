J2iOSLib
========

A bash script to translate Java code using J2ObjC then compile into a single static library that can be used on iOS devices and simulator.

Usage:

J2OBJCPATH
Set to the J2ObjC path, relative or absolute, if J2ObjC is not in the PATH already.
If J2ObjC is in the PATH, this may be left blank or commented out.

SRCDIR
Set to the root directory of the Java source files. If your Java page is com.example.myapp, then the SRCDIR should be the directory which contains the com directory. This may be set to "." as well.

STGDIR
Directory to create in order to stage intermediate files such as source files and single-architecture libraries. This folder is created new at the beginning and removed at the end.

HEADERDIR
HEADERDIR is the where the header files needed for the static library will be placed after the script is finished. This directory will be overwriten by performing a delete prior to moving the header files.

J2OBJCARGS
Place any extra arguments for J2ObjC in this variable which may be left blank for defauls. See J2ObjC documentation for arguments. The -d argument for destination directory should not be included as it is set elsewhere.

LIBNAME
The name of the library without the .a at the end. Can also include a path at the beginning

IOS_BASE_SDK
The base SDK is the iOS SDK version installed and will be used to compile the application.

IOS_DEPLOY_TGT
The deploy target is the minimum iOS version you wish to support

XCODEROOT
XCODEROOT is the location of XCode on the system. The included path is the default path for XCode 5+ installations from the appstore.

SIMARCHS
Architectures required for the simulator. Currently, i386 and x86_64 are used in the iOS simulator. These architectures will be compiled using the iPhoneSimulator.platform SDK

DEVARCHS
Architectures required for the device. These architectures will be compiled using the iPhoneOS.platform SDK

