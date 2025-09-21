@echo off

del *.bak

rd /s /q __history
rd /s /q __recovery
del *.~*
del *.dcu
del *.identcache
del *.local

rd /s /q ext\__history
rd /s /q ext\__recovery
del ext\*.~*
del ext\*.dcu
del ext\*.identcache
del ext\*.local
