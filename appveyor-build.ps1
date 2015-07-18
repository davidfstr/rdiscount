# 
# NOTE: You might need to run the following command to invoke this script:
# 
#       Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force -Scope Process
# 

$rdiscountDirpath = pwd

# Create downloads folder
md "C:\Downloads"

$downloader = new-object System.Net.WebClient

# Download 7z app (CLI)
$url = "http://7-zip.org/a/7za920.zip"
$filepath = "C:\Downloads\7za920.zip"
$downloader.DownloadFile($url, $filepath)

# Download Ruby (32-bit)
$url = "http://dl.bintray.com/oneclick/rubyinstaller/ruby-2.2.2-i386-mingw32.7z"
$filepath = "C:\Downloads\ruby-2.2.2-i386-mingw32.7z"
$downloader.DownloadFile($url, $filepath)

# Download DevKit (32-bit)
$url = "http://dl.bintray.com/oneclick/rubyinstaller/DevKit-mingw64-32-4.7.2-20130224-1151-sfx.exe"
$filepath = "C:\Downloads\DevKit-mingw64-32-4.7.2-20130224-1151-sfx.exe"
$downloader.DownloadFile($url, $filepath)

$unzipper = new-object -com shell.application

# Unzip 7z app
$zipFilepath = "C:\Downloads\7za920.zip"
$destination = "C:\Downloads\7za920"
md $destination
$zipPackage = $unzipper.NameSpace($zipFilepath)
$destinationFolder = $unzipper.NameSpace($destination)
$destinationFolder.CopyHere($zipPackage.Items())

$un7z = "C:\Downloads\7za920\7za.exe"

# Un-7z Ruby
$zipFilepath = "C:\Downloads\ruby-2.2.2-i386-mingw32.7z"
$destination = "C:\Downloads\ruby"
md $destination
cd $destination
& $un7z x $zipFilepath

# Un-7z DevKit
$zipFilepath = "C:\Downloads\DevKit-mingw64-32-4.7.2-20130224-1151-sfx.exe"
$destination = "C:\Downloads\devkit"
md $destination
cd $destination
& $un7z x $zipFilepath

$rubyRoot = "C:\Downloads\ruby\ruby-2.2.2-i386-mingw32"
$rubyBin  = "C:\Downloads\ruby\ruby-2.2.2-i386-mingw32\bin"
$ruby     = "C:\Downloads\ruby\ruby-2.2.2-i386-mingw32\bin\ruby.exe"

# Initialize DevKit
& $ruby "C:\Downloads\devkit\dk.rb" init

# Configure DevKit to point to our Ruby explicitly
Add-Content "C:\Downloads\devkit\config.yml" "`r`n- $($rubyRoot)`r`n"

# Enhance Ruby with DevKit
& $ruby "C:\Downloads\devkit\dk.rb" install

# Add DevKit to PATH
# NOTE: Assumes PowerShell execution policy allows other ps1 scripts to be run
& "C:\Downloads\devkit\devkitvars.ps1"

# Add Ruby to PATH
$env:path = $rubyBin + ";" + $env:path

# Build and install RDiscount
cd $rdiscountDirpath
rake build
gem build rdiscount.gemspec
gem install rdiscount-*.gem

# Check whether RDiscount binary works
$output = echo *hello* | rdiscount
$ok = $output -eq "<p><em>hello</em></p>"
If (-not ($ok)) {
    Throw "rdiscount binary produced unexpected output: $output"
}
