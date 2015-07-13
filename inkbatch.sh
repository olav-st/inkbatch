#!/bin/bash
# Script to batch export inkscape layers
# Copyright (C) 2015 Olav Sortland Thoresen - All Rights Reserved
# Permission to copy and modify is granted under the MIT license
set -e

FORMAT="png"
AUTOCROP=true
OUTPUT_PATH=""
EXTRA_OPTS=""

INKSCAPE_BIN="inkscape"
XMLSTARLET_BIN="xmlstarlet"
CONVERT_BIN="convert"

INFILE=$1
OUTFILES=()

#Parse command line arguments
while [[ $# > 0 ]]
do
key="$1"

case $key in
	-h|--help)
    echo "TODO: help menu goes here"
    exit 0
    shift
    ;;
    -f|--format)
    FORMAT="$2"
    shift
    ;;
    -d|--destpath|--destdir)
    OUTPUT_PATH="$2/"
    shift
    ;;
    -e|--extra|--extra-opts)
    EXTRA_OPTS="$2/"
    shift
    ;;
    -i|--inkscape|--inkscape-bin)
    INKSCAPE_BIN="$2"
    shift
    ;;
    -x|--xmlstarlet|--xmlstarlet-bin)
    XMLSTARLET_BIN="$2"
    shift
    ;;
    -c|--convert|--convert-bin)
    CONVERT_BIN="$2"
    shift
    ;;
    --no-autocrop)
    AUTOCROP=false
    ;;
    *)
	#Assume that an unknown option is the input file
	if [ -e "$key" ]; then
		INFILE=$key
	else
		echo "Uknown option $key"
		exit 1
	fi
    ;;
esac
shift
done

#Validate arguments
if [ -z "${INFILE}" ]; then
    echo "INFILE is unset!"
    exit 1
fi
if [ ! -z "${OUTPUT_PATH}" ]; then
	if [ ! -d "$OUTPUT_PATH" ]; then
		echo "Output directory '$OUTPUT_PATH' dosen't exist!"
		exit 1
	fi
fi
#Test the binaries we need
$INKSCAPE_BIN --version > /dev/null
if [[ $? -ne 0 ]]; then
	echo "Inkscape binary does not seem to work (returned a nonzero value)."
    exit 1
fi
$XMLSTARLET_BIN --version > /dev/null
if [[ $? -ne 0 ]]; then
	echo "xmlstarlet binary does not seem to work (returned a nonzero value)."
    exit 1
fi
if [ "$AUTOCROP" = true ] ; then
	$CONVERT_BIN --version > /dev/null
	if [[ $? -ne 0 ]]; then
		echo "convert binary does not seem to work (returned a nonzero value)."
    	exit 1
	fi
fi

#Export!
i=0
for LAYER in $($INKSCAPE_BIN --query-all $INFILE | grep layer | awk -F, '{print $1}') ; do
	#Parse the svg to find the inkscape layer name
	LAYER_NAME=$($XMLSTARLET_BIN sel -t -v "//*[@id='$LAYER']/@inkscape:label" $INFILE)
	if [ -z "${LAYER_NAME}" ]; then
		LAYER_NAME=$LAYER
	fi
	#Use the inkscape binary to export the layer
	echo "Exporting $LAYER ($LAYER_NAME)"
	OUTFILE_PATH="$OUTPUT_PATH$LAYER_NAME.$FORMAT"
	$INKSCAPE_BIN $INFILE -i $LAYER -j -C $EXTRA_OPTS --export-$FORMAT=$OUTFILE_PATH
	#Put the name of the generated file in the OUTFILES array
	OUTFILES[$i]="$OUTFILE_PATH"
	i=$i+1
done
#Use imagemagicks convert command to autocrop the pngs
if [ "$AUTOCROP" = true ] ; then
	echo "Autocropping images..."
	for OUTFILE in ${OUTFILES[*]}; do
		$CONVERT_BIN -verbose $OUTFILE -trim +repage $OUTFILE;
	done
fi
