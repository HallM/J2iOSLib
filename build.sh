#!/bin/bash

# where J2ObjC is located if not in PATH
J2OBJCPATH=

# directory where the source files are located
SRCDIR=src

# directory to create (any previous will be removed) for staging source
# files generated by J2ObjC
STGDIR=stg

# headerdir is the final location of the headers needed with the lib
HEADERDIR=headers

# the extra arguments to pass to J2ObjC. -d is already defined.
# please set the -d in bindir
J2OBJCARGS=

# the name of the library without the .a at the end. Can also include a path at the beginning
LIBNAME=mylib

# the iOS SDK being used to compile
IOS_BASE_SDK=8.1

# the lowest iOS version to target with the SDK
IOS_DEPLOY_TGT=7.0

# the location of XCode on the system
XCODEROOT=/Applications/Xcode.app/Contents/Developer/Platforms

# the architectures required for both simulator and device
SIMARCHS="i386 x86_64"
DEVARCHS="armv7 armv7s arm64"

# no need to change the rest
SIMDEVELROOT=$XCODEROOT/iPhoneSimulator.platform/Developer
DEVDEVELROOT=$XCODEROOT/iPhoneOS.platform/Developer

checkret() {
  if [ $? -ne 0 ]
  then
    echo $1
    exit 127
  fi
}

rm -rf ${STGDIR}
mkdir ${STGDIR}

# find all java files
echo "Searching for files in $SRCDIR"
jfiles=`find ${SRCDIR} -name "*.java"`

# transpile using defaults
echo "Translating Java code into ObjC"
if [ -z "$J2OBJCPATH" ]
then
  j2objc ${J2OBJCARGS} -d ${STGDIR} $jfiles
else
  ${J2OBJCPATH}/j2objc ${J2OBJCARGS} -d ${STGDIR} $jfiles
fi

checkret "Failed to translate code"

# use some string replace to determine the m files and eventually the o files
# also to prevent collisions with pkg1/file.java and pkg2/file.java, including pkg name in the o file
mfiles=${jfiles//.java/.m}
ofiles=${jfiles//.\//}
ofiles=${ofiles//.java/.o}
ofiles=${ofiles//\//_}

cd ${STGDIR}

allarchs="$SIMARCHS $DEVARCHS"
lipoargs=""
for outarch in $allarchs
do
  if [[ $SIMARCHS =~ $outarch ]]
  then
    DEVROOT=$SIMDEVELROOT
    SDKROOT=${DEVROOT}/SDKs/iPhoneSimulator${IOS_BASE_SDK}.sdk
  elif [[ $DEVARCHS =~ $outarch ]]
  then
	DEVROOT=$DEVDEVELROOT
  	SDKROOT=${DEVROOT}/SDKs/iPhoneOS${IOS_BASE_SDK}.sdk
  else
    echo "$outarch is not in the list of simulator nor device list. Skipping arch."
    continue
  fi
  
  CFLAGS="-arch $outarch -pipe -no-cpp-precomp -isysroot $SDKROOT -miphoneos-version-min=$IOS_DEPLOY_TGT -ObjC -I./"

  echo "Compiling for architecture: $outarch"
  for jfile in $jfiles
  do
    mfile=${jfile//.java/.m}
    ofile=${jfile//.java/.o}
    ofile=${ofile/.\//}
    ofile=${ofile//\//_}
    echo "Compiling $mfile"

    if [ -z "$J2OBJCPATH" ]
    then
      j2objcc $CFLAGS -c -o ${ofile/.\//} $mfile
    else
      ${J2OBJCPATH}/j2objcc $CFLAGS -c -o ${ofile/.\//} $mfile
    fi
    
    checkret "Failed to compile source code file"
  done

  echo "Building ${LIBNAME}_${outarch}.a"
  libtool -static -o ${LIBNAME}_${outarch}.a $ofiles
  checkret "Failed to generate static library for arch"

  lipoargs="$lipoargs -arch $outarch ${LIBNAME}_${outarch}.a"
done

rm ${LIBNAME}.a
echo "combining all into single ${LIBNAME}.a"
lipo $lipoargs -create -output ${LIBNAME}.a
checkret "Failed to generate final static library"

# clean up
rm *.o
rm *.a
rm $mfiles

cd ..
rm -rf ${HEADERDIR}

# moving to final destination
mv ${STGDIR} ${HEADERDIR}

echo "Complete."
