@echo off
rem This script expects a command line argument that should the
rem name of the server whose CPU info you want to retrieve.

perl getSrvCpuMem.pl %1
