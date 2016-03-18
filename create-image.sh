#!/bin/bash

# This script assumes the following dependencies are installed:
# * via Yum: git python-pip PyYAML qemu-img xfsprogs xz
# * via Pip: diskimage-builder


IMAGE_NAME="CENTOS-7"
BASE_IMAGE="CentOS-7-x86_64-GenericCloud-1602.qcow2"

if [ "$BASE_IMAGE" == "" ]; then
  echo "could not identify the last centos qcow2 image from http://cloud.centos.org/centos/7/images/sha256sum.txt"
  exit 1
fi

# echo "will work with $BASE_IMAGE"
BASE_IMAGE_XZ="$BASE_IMAGE.xz"

if [ ! -f "$BASE_IMAGE_XZ" ]; then
  curl -L -O "http://cloud.centos.org/centos/7/images/$BASE_IMAGE_XZ"
fi

# Find programatively the sha256 of the selected image
IMAGE_SHA566=$(curl  http://cloud.centos.org/centos/7/images/sha256sum.txt 2>&1 \
               | grep "$BASE_IMAGE_XZ\$" \
               | awk '{print $1}')

# echo "will work with $BASE_IMAGE_XZ => $IMAGE_SHA566"
if ! sh -c "echo $IMAGE_SHA566 $BASE_IMAGE_XZ | sha256sum -c"; then
  echo "Wrong checksum for $BASE_IMAGE_XZ. Has the image changed?"
  exit 1
fi

xz --decompress --keep $BASE_IMAGE_XZ

export DIB_LOCAL_IMAGE=`pwd`/$BASE_IMAGE
export ELEMENTS_PATH=`pwd`/elements
export FS_TYPE=xfs
export LIBGUESTFS_BACKEND=direct

OUTPUT_FILE="$1"
if [ "$OUTPUT_FILE" == "" ]; then
  TMPDIR=`mktemp -d`
  mkdir -p $TMPDIR/common
  OUTPUT_FILE="$TMPDIR/common/CC-CentOS7.qcow2"
fi


ELEMENTS="vm"
if [ "$FORCE_PARTITION_IMAGE" = true ]; then
  ELEMENTS="baremetal"
fi

if [ -f "$OUTPUT_FILE" ]; then
  echo "removing existing $OUTPUT_FILE"
  rm -f "$OUTPUT_FILE"
fi

/bin/disk-image-create chameleon-common $ELEMENTS -o $OUTPUT_FILE

if [ -f "$OUTPUT_FILE.qcow2" ]; then
  mv $OUTPUT_FILE.qcow2 $OUTPUT_FILE
fi

COMPRESSED_OUTPUT_FILE="$OUTPUT_FILE-compressed"
qemu-img convert $OUTPUT_FILE -O qcow2 -c $COMPRESSED_OUTPUT_FILE
echo "mv $COMPRESSED_OUTPUT_FILE $OUTPUT_FILE"
mv $COMPRESSED_OUTPUT_FILE $OUTPUT_FILE

if [ $? -eq 0 ]; then
  echo "Image built in $OUTPUT_FILE"
  if [ -f "$OUTPUT_FILE" ]; then
    echo "to add the image in glance run the following command:"
    echo "glance image-create --name \"$IMAGE_NAME\" --disk-format qcow2 --container-format bare --file $OUTPUT_FILE"
  fi
else
  echo "Failed to build image in $OUTPUT_FOLDER"
  exit 1
fi
