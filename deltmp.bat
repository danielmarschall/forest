@echo off

rd /s /q dll_resize\__history
del dll_resize\*.~*
del dll_resize\*.dcu

rd /s /q mapgen\__history
del mapgen\*.~*
del mapgen\*.dcu

rd /s /q cfgread\__history
del cfgread\*.~*
del cfgread\*.dcu
