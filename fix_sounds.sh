#!/bin/bash

# Script to add sound files to Xcode project
cd "/Users/cemalhekimoglu/Desktop/hayalet oyunu/Shivering Ghosts"

echo "Sound files that need to be added to Xcode project:"
echo "1. Open Xcode"
echo "2. Right-click on 'Shivering Ghosts' folder in Project Navigator"
echo "3. Select 'Add Files to Shivering Ghosts...'"
echo "4. Navigate to: Shivering Ghosts/Shivering Ghosts/"
echo "5. Select all .mp3 files:"
ls -1 "Shivering Ghosts/"*.mp3
echo ""
echo "6. Make sure 'Copy items if needed' is UNCHECKED (files are already there)"
echo "7. Make sure 'Add to targets: Shivering Ghosts' is CHECKED"
echo "8. Click 'Add'"
