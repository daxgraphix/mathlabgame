cd /d "C:\Users\CYBER SWAHILI\Documents\mathlab\android"
gradlew.bat assembleDebug 2>&1 > "C:\\Users\\CYBER SWAHILI\\Documents\\mathlab\\android_build.log"
find "C:\\Users\\CYBER SWAHILI\\Documents\\mathlab\\android_build.log" "BUILD" || echo "Build check done"