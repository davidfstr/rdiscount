# 
# Installs all platform dependencies of RDiscount, builds RDiscount,
# and tests RDiscount on a Windows-based operating system.
# 
# This script can be run manually to check whether RDiscount works on a
# particular Windows OS, or automatically through the Appveyor continuous
# integration platform.
# 
# NOTE: You might need to run the following command to invoke this script:
# 
#       Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force -Scope Process
# 

# Log everything this script does to file
Start-Transcript -path appveyor-build.log
echo ""

# Assume that we start in the RDiscount source directory,
# so save its location for later
$rdiscountDirpath = pwd

# Detect whether running in Appveyor environment
if (Get-Command "Push-AppveyorArtifact" -errorAction SilentlyContinue)
{
    $appveyor = $true
} else {
    $appveyor = $false
}

# Create downloads folder
md "C:\Downloads" > $null

$downloader = new-object System.Net.WebClient

# Download 7z app (CLI)
echo "Downloading 7z..."
$url = "http://7-zip.org/a/7za920.zip"
$filepath = "C:\Downloads\7za920.zip"
$downloader.DownloadFile($url, $filepath)

# Download Ruby (32-bit)
echo "Downloading Ruby..."
$url = "http://dl.bintray.com/oneclick/rubyinstaller/ruby-2.2.2-i386-mingw32.7z"
$filepath = "C:\Downloads\ruby-2.2.2-i386-mingw32.7z"
$downloader.DownloadFile($url, $filepath)

# Download DevKit (32-bit)
echo "Downloading DevKit..."
$url = "http://dl.bintray.com/oneclick/rubyinstaller/DevKit-mingw64-32-4.7.2-20130224-1151-sfx.exe"
$filepath = "C:\Downloads\DevKit-mingw64-32-4.7.2-20130224-1151-sfx.exe"
$downloader.DownloadFile($url, $filepath)

if ($appveyor) {
    Push-AppveyorArtifact "appveyor-build.log"
}

$unzipper = new-object -com shell.application

# Unzip 7z app
echo "Unzipping 7z..."
$zipFilepath = "C:\Downloads\7za920.zip"
$destination = "C:\Downloads\7za920"
md $destination > $null
$zipPackage = $unzipper.NameSpace($zipFilepath)
$destinationFolder = $unzipper.NameSpace($destination)
$destinationFolder.CopyHere($zipPackage.Items())

$un7z = "C:\Downloads\7za920\7za.exe"

# Un-7z Ruby
echo "Un7zing Ruby..."
$zipFilepath = "C:\Downloads\ruby-2.2.2-i386-mingw32.7z"
$destination = "C:\Downloads\ruby"
md $destination > $null
cd $destination
& $un7z x $zipFilepath > $null

# Un-7z DevKit
echo "Un7zing DevKit..."
$zipFilepath = "C:\Downloads\DevKit-mingw64-32-4.7.2-20130224-1151-sfx.exe"
$destination = "C:\Downloads\devkit"
md $destination > $null
cd $destination
& $un7z x $zipFilepath > $null

if ($appveyor) {
    Push-AppveyorArtifact "appveyor-build.log"
}

$rubyRoot = "C:\Downloads\ruby\ruby-2.2.2-i386-mingw32"
$rubyBin  = "C:\Downloads\ruby\ruby-2.2.2-i386-mingw32\bin"
$ruby     = "C:\Downloads\ruby\ruby-2.2.2-i386-mingw32\bin\ruby.exe"

# Initialize DevKit and point to our Ruby explicitly
echo "Initializing DevKit..."
& $ruby "C:\Downloads\devkit\dk.rb" init
Add-Content "C:\Downloads\devkit\config.yml" "`r`n- $($rubyRoot)`r`n"
echo ""

# Enhance Ruby with DevKit
echo "Installing DevKit..."
& $ruby "C:\Downloads\devkit\dk.rb" install
echo ""

if ($appveyor) {
    Push-AppveyorArtifact "appveyor-build.log"
}

# Add DevKit to PATH
# NOTE: Assumes PowerShell execution policy allows other ps1 scripts to be run
& "C:\Downloads\devkit\devkitvars.ps1"
echo ""

# Add Ruby to PATH
$env:path = $rubyBin + ";" + $env:path

# Build and install RDiscount
cd $rdiscountDirpath
echo "Building RDiscount..."
rake build
echo ""
echo "Building RDiscount gem..."
gem build rdiscount.gemspec
echo ""
echo "Installing RDiscount gem..."
gem install rdiscount-*.gem
echo ""

if ($appveyor) {
    Push-AppveyorArtifact "appveyor-build.log"
}

# Check whether RDiscount binary works
echo "Checking RDiscount binary..."
$output = echo *hello* | rdiscount
$ok = $output -eq "<p><em>hello</em></p>"
If (-not ($ok)) {
    Throw "rdiscount binary produced unexpected output: $output"
}
echo ""

echo "OK"

if ($appveyor) {
    Push-AppveyorArtifact "appveyor-build.log"
}

Stop-Transcript
# The above command should be the last command.
# Do not insert new commands below this line.