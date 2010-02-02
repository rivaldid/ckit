#!/bin/bash

#SET THIS PARAMETER
HOST=$(cat ../host)
USER=$(cat ../user)
PASSWORD=$(cat ../password)

PDIR="puts_files"
GDIR="gets_files"
ODIR="output"
BIN="ruFTP.rb"
LIBFOLDER=$(pwd)
BINFOLDER=$(pwd)
PARAMS="-I $LIBFOLDER $BINFOLDER/$BIN -H $HOST -u $USER -p $PASSWORD"
DIMMBFILE1=81920
DIMMBFILE2=256


usage() {
	echo "USAGE:	$0 [OPTIONS] [FILES]"
	echo
	echo "OPTIONS:"			
	echo "	-P	FILES 	upload FILES on remote ftp"
	echo "	-G	FILES	dowload FILES from remote ftp"
	echo "	-D	FILES	delete FILES from remote ftp"
	echo "	-r		generate random files"
	echo "	-l		list files on remote ftp"
	echo "	-p		print the command you'll try execute"
	echo "	-t		lauch the test"
	echo "	-c		clean the folder from the result of test"
	echo "	-h		print this help"
	echo
}

print_command() {
	[[ $HOST == "" ]] && set_var && exit 1
	[[ $USER == "" ]] && set_var && exit 1
	[[ $PASSWORD == "" ]] && set_var && exit 1
	
	echo $PARAMS
}


launch_test() {
	[[ $HOST == "" ]] && set_var && exit 1
	[[ $USER == "" ]] && set_var && exit 1
	[[ $PASSWORD == "" ]] && set_var && exit 1
	
	rm -rf $PDIR $GDIR $ODIR 
	mkdir $GDIR $ODIR

	echo "=== FIRST LS ==="
	remote_ls | tee $ODIR/first.ls

	echo "=== CREATING TEST FILES ==="
	random_files

	echo "=== UPLOADING FILE ==="
	put $PDIR/*

	echo "=== UPLOADING JUST ONE BINARY FILE ==="
	put	$PDIR/bigfile2

	echo "=== UPLOADING JUST ONE TEXT FILE ==="
	put $PDIR/textfile.txt

	echo "=== CHECKING UPLOADED FILES ==="
	remote_ls

	echo "=== DOWLOADING FILES ==="
	cd gets_files
	get bigfile2 bigfile textfile.txt
	cd ..
	
	echo "=== DELETING REMOTE FILES ==="
	delete bigfile2 bigfile textfile.txt

	echo "=== SECOND LS ==="
	remote_ls | tee $ODIR/second.ls

	ls puts_files > $ODIR/puts.ls
	ls gets_files > $ODIR/gets.ls
}

random_files() {
	[ ! -d $PDIR ] && mkdir $PDIR
	dd if=/dev/random of=$PDIR/bigfile bs=1024 count=$DIMMBFILE1
	dd if=/dev/random of=$PDIR/bigfile2 bs=1024 count=$DIMMBFILE2
	echo "ciao mare" > $PDIR/textfile.txt
}

remote_ls() {
	ruby $PARAMS -c ls
}

put() {
	ruby $PARAMS -D -P -c put $@
}

get() {
	ruby $PARAMS -c get $@
}

delete() {
	ruby $PARAMS -c delete $@
}

clean() {
	rm -rf $PDIR $GDIR $ODIR 
}

set_var() {
	echo "YOU HAVE TO SET THE HOST/USER/PASSWORD VARIABLE BEFORE RUN THE TEST"
	echo "YOU WILL FIND THE VARIABLE ON THE TOP OF THIS SCRIPT"
}

RANDOMFILE=1;
PRINTCOMMAND=1;
TEST=1;
CLEAN=1;
USAGE=1;
PUT=1;
GET=1;
DELETE=1;
LS=1;

while getopts ":P:G:D:p t c h l r" o; do
	case $o in
		P ) PUT=0;;
		G ) GET=0;;
		D ) DELETE=0;;
		p ) PRINTCOMMAND=0;;
		t ) TEST=0;;
		c ) CLEAN=0;;
		l ) LS=0;;
		r ) RANDOMFILE=0;;
		h ) USAGE=0;;
		*) USAGE=0;;
	esac
done

[ $PUT == 0 -a $GET == 0 ] && echo "ONLY ONE OF GET/PUT/DELETE CAN BE SELECTED" && exit 1
[ $PUT == 0 -a $DELETE == 0 ] && echo "ONLY ONE OF GET/PUT/DELETE CAN BE SELECTED" && exit 1
[ $DELETE == 0 -a $GET == 0 ] && echo "ONLY ONE OF GET/PUT/DELETE CAN BE SELECTED" && exit 1

[ $PUT == 0 ] && put $@ && exit $?
[ $GET == 0 ] && get $@ && exit $?
[ $DELETE == 0 ] && delete $@ && exit $?

[ $RANDOMFILE == 0 ] && random_files
[ $PRINTCOMMAND == 0 ] && print_command
[ $TEST == 0 ] && launch_test
[ $LS == 0 ] && remote_ls
[ $CLEAN == 0 ] && clean
[ $USAGE == 0 ] && usage
