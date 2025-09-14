@echo off

del *.bak

rd /s /q __history
rd /s /q __recovery
del *.~*
del *.dcu
del *.identcache
del *.local

rd /s /q mapgen\__history
rd /s /q mapgen\__recovery
del mapgen\*.~*
del mapgen\*.dcu
del mapgen\*.identcache
del mapgen\*.local
