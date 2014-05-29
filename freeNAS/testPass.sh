#! /bin/bash
ldapwhoami -x -D "uid=$1,ou=People,dc=company,dc=com,dc=mx" -W
