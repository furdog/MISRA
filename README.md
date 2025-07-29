# MISRA C Checker Script
This script provides a simple way to set up cppcheck with MISRA C 2023 addons and run checks on your C source files.

## Setup
To set up the environment, including cloning cppcheck and downloading the necessary MISRA rule texts:

./misra.sh setup

## Check
To run a MISRA check on a C source or header file:

./misra.sh check <target_file.c> or ./misra.sh check <target_file.h>

(Replace <target_file.*> with the path to your C source/header file.)

This script leverages cppcheck for static analysis and a Python script (misra.py) from the cppcheck addons for MISRA rule checking.
