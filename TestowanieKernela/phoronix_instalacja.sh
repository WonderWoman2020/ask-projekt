#!/bin/bash

LINK="https://phoronix-test-suite.com/releases/phoronix-test-suite-10.8.0.tar.gz"
PLIK_TAR=$( printf $LINK | sed 's|.*/||' )
curl -O $LINK
tar xf $PLIK_TAR
cd "phoronix-test-suite"
sudo ./install-sh
sudo apt-get install php-xml
sudo apt-get install php-gd

