# OSS-PS-Scripts
My Open Source Powershell scripts

#ToggleDisplayRotation.ps1
A helper script that you can use to rotate a secondary monitor. I use it attached to a keyboard macro for a monitor I have on a pan/tilt/rotate VESA mount.

The script takes either `-listDisplays` or `-displayName` as mandatory arguments.
The optional arguments are:
- `-toggleOrientation` - the rotation in degrees anti-clockwise to rotate the display. Valid values are:
    - DMO90
    - DMO180
    - DMO 270 (default)
- `alignRight` - keeps right boundary of the rotated screen at the same X coordinate instead of the left boundary (default: `False`).
- `preserveTop` - preserves the Y coordinates of the top screen boundare (default: `False`). Default behaviour maintains the height of the screen's center line.
