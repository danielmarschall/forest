@echo off

rd /s /q dll_resize\__history
del dll_resize\*.~*
del dll_resize\*.dcu
del dll_resize\*.identcache
del dll_resize\*.local

rd /s /q mapgen\__history
del mapgen\*.~*
del mapgen\*.dcu
del mapgen\*.identcache
del mapgen\*.local

rd /s /q cfgread\__history
del cfgread\*.~*
del cfgread\*.dcu
del cfgread\*.identcache
del cfgread\*.local
