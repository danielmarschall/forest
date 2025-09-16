@echo off

del *.bak

rd /s /q __history
rd /s /q __recovery
del *.~*
del *.dcu
del *.identcache
del *.local
