# Adobe

This script isn't exactly SysAdmin material however in my environment it was needed to allow users to change their Media Cache Location for Adobe products in the CC2017 and CC2018 family, my guess is you need to add:

`"HKCU:\Software\Adobe\Common 13.0\Media Cache"`

For this script to work with Adobe CC2019, however we have not deployed that at my work as of yet, I will update the script if this is the case. 

You just need to change the `$Path` variable for this to work, make sure it's a valid directory or create it from within the script.

#### Functionsrk
N/A
