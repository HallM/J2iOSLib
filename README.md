J2iOSLib
========

A bash script to translate Java code using J2ObjC then compile into a single static library that can be used on iOS devices and simulator.

bindir
bindir is used as the output for the ObjC code from J2ObjC. This is also where the o files and some temporary libs are staged as well.

headerdir
headerdir is the where the header files needed for the static library will be placed after the script is finished. This directory will be overwriten by performing a delete prior to moving the header files.

libname
libname is the desired static library name, ${libname}.a for example.

IOS_BASE_SDK
The base SDK is the iOS SDK version installed and will be used to compile the application.

IOS_DEPLOY_TGT
The deploy target is the minimum iOS version you wish to support

XCODEROOT
XCODEROOT is the location of XCode on the system. The included path is the default path for XCode 5+ installations from the appstore.
