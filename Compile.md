
# How to compile

# Forest.exe

1. Open Forest.dbpro with DarkBASIC Professional and build the executable. Make sure the build mode is "alone" (otherwise signing the EXE is not possible)

2. Edit Forest.exe with Resource Hacker (only cosmetics):

- Fix icon by replacing icon resource 105 (Reason: DBPro fails with replacing the icon due to a bug)

- Fix version info (Reasons: Copyright is cut off; Original Filename contains the full path instead of just the file name; Version Number is always reset to v1.0)

3. Sign the EXE using Authenticode

You can keep Forest.exe for future builds (unless you change the DBPro version), since only the .pck file changes.

# ext/ForestDLL.dll

1. Open ext/ForestDLL.dproj with Embarcadero Delphi and build the executable.

2. Sign the EXE using Authenticode
