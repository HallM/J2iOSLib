#!/bin/bash

#bindir is used to stage outputs for J2ObjC
bindir=FINAL LOCATION FOR BIN

#headerdir is the final location of the headers needed with the lib
headerdir=FINAL LOCATION FOR HEADERS

# the name of the library without the .a at the end
libname=PUT LIB NAME HERE

# the iOS SDK being used to compile
IOS_BASE_SDK=8.1

# the lower iOS version to target with the SDK
IOS_DEPLOY_TGT=7.0

# the location of XCode on the system
XCODEROOT=/Applications/Xcode.app/Contents/Developer/Platforms

# no need to change the rest
SIMDEVELROOT=$XCODEROOT/iPhoneSimulator.platform/Developer
DEVDEVELROOT=$XCODEROOT/iPhoneOS.platform/Developer

rm -rf $bindir
mkdir $bindir

# find all java files
jfiles=`find . -name "*.java"`

# transpile using defaults
j2objc -d $bindir $jfiles

# use some string replace to determine the m files and eventually the o files
# also to prevent collisions with pkg1/file.java and pkg2/file.java, including pkg name in the o file
mfiles=${jfiles//.java/.m}
ofiles=${jfiles//.\//}
ofiles=${ofiles//.java/.o}
ofiles=${ofiles//\//_}

# first compiling the simulator versions
DEVROOT=$SIMDEVELROOT
SDKROOT=$DEVROOT/SDKs/iPhoneSimulator$IOS_BASE_SDK.sdk

cd $bindir

lipoargs=""
for outarch in x86_64 i386 armv7 armv7s arm64
do
  CFLAGS="-arch $outarch -pipe -no-cpp-precomp -isysroot $SDKROOT -miphoneos-version-min=$IOS_DEPLOY_TGT -ObjC -I./"

  echo "Compiling for architecture: $outarch"
  for jfile in $jfiles
  do
    mfile=${jfile//.java/.m}
    ofile=${jfile//.java/.o}
    ofile=${ofile/.\//}
    ofile=${ofile//\//_}
    echo "Compiling $mfile"
    j2objcc $CFLAGS -c -o ${ofile/.\//} $mfile
  done

  echo "Building ${libname}_${outarch}.a"
  libtool -static -o ${libname}_${outarch}.a $ofiles
  lipoargs="$lipoargs -arch $outarch ${libname}_${outarch}.a"

  # after all the simulator ones, switch to the device SDK
  if [ "$outarch" = "i386" ]
  then
	DEVROOT=$DEVDEVELROOT
  	SDKROOT=$DEVROOT/SDKs/iPhoneOS$IOS_BASE_SDK.sdk
  fi
done

echo "combining all into super libmapsforge.a"
echo "lipo $lipoargs -create -output $libname.a"
lipo $lipoargs -create -output ../${libname}.a

# clean up
rm *.o
rm *.a
rm $mfiles

cd ..
rm -rf $headerdir

# moving to final destination
mv $bindir $headerdir

echo "Complete."
