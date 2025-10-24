# Copyright

Other than any prior works of which it is a derivative, the copyright in this work is owned by La Trobe University.

# Licenses

Rights of use and distribution are granted under the terms of the GNU Affero General Public License version 3 (AGPL-3.0). You should find a copy of this license in the root of the repository.

# Acknowledgements

La Trobe University Library is grateful to all who have contributed to this prooject. You can see who they are are at [ACKNOWLEDGEMENTS.md](ACKNOWLEDGEMENTS.md)

# Contact

The maintainer of this repository is Hugh Rundle, who can be contacted at h.rundle@latrobe.edu.au

# Description 

These scripts can be used if you need to convert a batch of large TIFF files to one or more PDF access copies. They were originally used for the Sandhurst Collection Digitisation Project to convert directories of scanned pages into one PDF per book. The scripts are relatively simple PowerShell scripts that loop through a directory structure and run imagemagick over a given directory.

Generally speaking LTU staff should prefer to scan to both TIFF and JPG simultaneously using the software in the LTU Library digitisation labs, but if you only have TIFFs, these scripts can be used.

These are designed for use in La Trobe's computing environment so some installation details may differ for non-La Trobe users.

## Prerequisites and preparation

To use the scripts you will need:

* PowerShell
* ImageMagick

### Installing PowerShell

[PowerShell](https://learn.microsoft.com/en-us/powershell/scripting/overview) is Microsoft's modern command line scripting shell. You should be able to install this directly from the Windows App Store. At the time of writing, the latest PowerShell is version 7. You _might_ need to enact a "local admin" privilege escalation if prompted.

Once installed, you should be able to open PowerShell from your taskbar search menu, or click on the desktop icon if one was added.

### Installing ImageMagick

[ImageMagick](https://imagemagick.org) is a command line tool and software library for manipulating images. It is very powerful and can therefore be a little confusing. Luckily for you, most of the hard work of experimenting with configurations has already been done.

Installing ImageMagick is slightly more complicated. Go to [the ImageMagick downloads page](https://imagemagick.org/script/download.php#windows) and click on the latest `Q16-HDRI-x64-dll.exe` version. This is likely to be at the top of the Windows download options and will be described as _Win64 dynamic at 16 bits-per-pixel component with High-dynamic-range imaging enabled_. Wait for the file to download, then double click to run through the installation process. La Trobe users will be prompted to complete a local admin prompt justifying why you are installing the software. It is very important that you only install ImageMagick from the official site linked in these docs, to avoid accidentally downloading malware pretending to be the real thing.

One you have installed both PowerShell and ImageMagick, you will be able to run the `magick` command to check that everything is properly installed. Open Powershell and type:

```ps
magick --version
```

Press `Enter` and you should receive output something like this:

```sh
Version: ImageMagick 7.1.1-30 Q16-HDRI x64 dd459b0:20240407 https://imagemagick.org
Copyright: (C) 1999 ImageMagick Studio LLC
License: https://imagemagick.org/script/license.php
Features: Channel-masks(64-bit) Cipher DPC HDRI Modules OpenCL OpenMP(2.0)
Delegates (built-in): bzlib cairo flif freetype gslib heic jng jp2 jpeg jxl lcms lqr lzma openexr pangocairo png ps raqm raw rsvg tiff webp xml zip zlib
Compiler: Visual Studio 2022 (193833135)
```

If you instead receive a message stating that `The term 'magick' is not recognized...`, you have not correctly installed ImageMagick.

An alternative way to install is using `winget` directly from Powershell:

```sh
winget install ImageMagick.Q16-HDRI
```

## Scripts

There are three scripts. Each script will run through every subdirectory of every subdirectory in a given directory and, if it matches a given naming convention:

1. convert all TIFF files in the directory to PDF
2. compress the images using a JPG algorithm
3. gather together all the PDF images in order to create a single, multi-page PDF file

The primary difference between the scripts is in how they identify which directories to look at.

### `process_all.ps1`

This script attempts to convert every subdirectory if it matches a given naming convention:

[] _all-books-originals_ <-- $collectionPath>
   - [] _book-1_
        - [] _docs_ <-- this directory will be ignored
        - [] _ignored-folder_ <-- this directory will be ignored
        - [] **Renamed TIFF** <-- this directory will be processed
   - [] _book-2_
        - [] _docs_ <-- this directory will be ignored
        - [] _jpgs_ <-- this directory will be ignored
        - [] **TIFFs renamed** <-- this directory will be processed

You would use this script to process everything in a directory (e.g. all the books from a digitisation project).

### `process_included.ps1`

This script attempts to convert every subdirectory if it matches a given naming convention, only if the first child directory is in a given set:


[] _all-books-originals_ <-- $collectionPath>
   - [] _book-1_
        - [] _docs_ <-- this directory will be ignored
        - [] _ignored-folder_ <-- this directory will be ignored
        - [] **Renamed TIFF** <-- this directory will be processed
   - [] _book-2_ <-- this whole parent directory is ignored because it is not in the inclusion set
   - [] _book-3_
        - [] _docs_ <-- this directory will be ignored
        - [] _jpgs_ <-- this directory will be ignored
        - [] **TIFFs renamed** <-- this directory will be processed

You would use this if you want to only process a smaller batch from a directory (e.g. as a test run, or if an earlier run missed some books in a project)

### `process_all_except_excluded.ps1`

This script attempts to convert every subdirectory it finds if it matches a given naming convention, _unless_ the first child directory is in a given set:

[] _all-books-originals_ <-- $collectionPath
   - [] _book-1_
        - [] _docs_ <-- this directory will be ignored
        - [] _ignored-folder_ <-- this directory will be ignored
        - [] **Renamed TIFF** <-- this directory will be processed
   - [] _book-2_ <-- this whole parent directory is ignored because it is in the exclusion set
   - [] _book-3_
        - [] _docs_ <-- this directory will be ignored
        - [] _jpgs_ <-- this directory will be ignored
        - [] **TIFFs renamed** <-- this directory will be processed

You would use this if you want to process every subdirectory except for certain ones. (e.g. books from an earlier run using the inclusion set, or files that need to be re-scanned)

## Adjusting the scripts for your use

### Determining which subdirectories are processed

If using `process_all.ps1` you may wish to adjust the starting point for your loop. This might be necessary if you have a very large number of digitisations to process and your run falls over for some reason partway through. You can do this by changing the counter check on line 25:

```sh
    if ($counter -gt -1) {
```
Change `-1` to the number corresponding to the next item you want to be processed, e.g.

```sh
    if ($counter -gt 23) {
```
Note that the loop is zero-indexed so the line above would start processing the twenty-third subdirectory in `$collectionPath`, not the twenty-fourth. By default, subdirectories will be processed in alphabetic order by name.

If using `process_included.ps1` or `process_all_except_excluded.ps1` you need to enter your own values for the lists in `$Records` or `$RecordsToExclude` respectively. These should be the names of directories within your `$collectionPath`.

### Adjusting the ImageMagick configuration 

ImageMagick is where the uh, magic happens, on this line:

```sh
magick -quiet $resolvedPath\*.tif -resample 200 -unsharp 1.5x1+0.7+0.02 -compress JPEG -quality 60 -depth 8 $pdfDir\$parentName.pdf
```

You can adjust the ImageMagick flags to change how the image files are processed. The settings in these scripts were chosen for the best balance of quality and file size when processing very large TIFFs for the Sandhurst Collection, but your needs may differ. You can read [the full ImageMagick documentation](https://imagemagick.org/script/command-line-processing.php#option) but it can be a little intimidating. The key things to play with are:

* resample

[Resize the image](https://imagemagick.org/script/command-line-options.php#resample) so that its rendered size remains the same as the original at the specified target resolution.

* unsharp

Sharpen the image [with an unsharp mask operator](https://imagemagick.org/script/command-line-options.php#unsharp).

* quality

Control the [compression quality of image files](https://imagemagick.org/script/command-line-options.php#quality) when you are creating or saving them. This option is important for managing the trade-off between image quality and file size.

* depth

Color depth is the [number of bits per channel](https://imagemagick.org/script/command-line-options.php#depth) for each pixel.