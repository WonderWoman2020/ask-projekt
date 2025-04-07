#!/bin/bash

KATALOG_GLOWNY="testy"
PLIK="lista_testow.txt"
GRUPA_WYNIKOW="NowyKernel"
POLOZENIE=$( pwd )
TEST=""
KONT=""

sudo apt-get install expect

mkdir -p $KATALOG_GLOWNY
cd $KATALOG_GLOWNY


while read TEST <&5 ;
do 
TEST=$( printf $TEST | sed 's/#//' )
#printf "$TEST\n"

case $TEST in

Procesor | Dyski | Grafika | Pamiec | System)
cd "$POLOZENIE/$KATALOG_GLOWNY"
mkdir -p $TEST
cd $TEST
;;
*)
phoronix-test-suite install $TEST
./"$TEST.exp" $GRUPA_WYNIKOW
phoronix-test-suite result-file-to-csv "t$TEST"
gnome-terminal --command="bash -c 'cd $POLOZENIE; ./remove-test.exp $TEST; $SHELL'"
;;

esac

done 5< "$POLOZENIE/$PLIK"

