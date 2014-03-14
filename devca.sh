#!/bin/bash

CADIR=~/.devca

usage()
{
  echo "$0 [init|cert <hostname>]";
  echo "init: creates a dev CA in $CADIR"
  echo "cert <hostname>: creates a cert for hostname (can start *.)"
  exit;
}

CAKEY=$CADIR/devca.key
CACRT=$CADIR/devca.crt
CAPFX=$CADIR/devca.pfx
CASERIAL=$CADIR/serial.txt
HOSTNAME_PART='[^*/,:[:space:]]+'
HOSTNAME_REGEX="^(\*\.)?($HOSTNAME_PART\.)*$HOSTNAME_PART$"

if [ "$1" = "init" ];
then
  if [ ! -e $CADIR ]
  then
    mkdir $CADIR
  fi
  if [ ! -e "$CAKEY" ];
  then
    openssl genrsa -out $CAKEY 2048 >/dev/null 2>&1
  fi
  if [ $? -eq 0 -a ! -e "$CACRT" ];
  then
    openssl req -new -x509 -days 3650 -key $CAKEY -out $CACRT -batch -subj '/CN=Dev CA' > /dev/null 2>&1
  fi
  if [ $? -eq 0 -a ! -e "$CAPFX" ];
  then
    openssl pkcs12 -export -out $CAPFX -inkey $CAKEY -in $CACRT
  fi
  if [ $? -eq 0 ];
  then
    echo "Done. Install $CACRT in your browser as a trusted root CA."
  fi
  exit
elif [ "$1" = "cert" ]
then
  if [ ! -e "$CAKEY" -o ! -e "$CACRT" ] 
  then
    echo "First run $0 init" 1>&2
  elif [[ "$2" =~ $HOSTNAME_REGEX ]]
  then
    CN="$2" # this goes in the cert
    BASE_FILENAME="$CADIR/${2/#\*/star}" # this goes in the file
    KEY="$BASE_FILENAME.key"
    if [ ! -e "$KEY" ]
    then
      openssl genrsa -out "$KEY" 2048 >/dev/null 2>&1
    fi
    CSR="$BASE_FILENAME.csr"
    if [ $? -eq 0 -a ! -e "$CSR" ]
    then
      openssl req -batch -subj "/CN=$2" -new -key $KEY -out $CSR >/dev/null 2>&1
    fi
    CRT="$BASE_FILENAME.crt"
    if [ $? -eq 0 -a ! -e "$CRT" ]
    then
      openssl x509 -req -CAcreateserial -CAserial $CASERIAL -days 3650 -in "$CSR" -CA $CACRT -CAkey $CAKEY -out $CRT >/dev/null 2>&1
    fi
    rm -f "'$CSR'"
    if [ $? -eq 0 ];
    then
      echo "Done. Install $KEY and $CRT in your webserver."
    else
      echo "An unknown error occurred." 1>&2
    fi
    exit
  else
    echo "Invalid hostname" 1>&2
  fi
  exit
fi

usage
