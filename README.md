# reducepdf
bash script to reduce pdf-file(s)
# USAGE:
reducepdf.sh `<pdf-file to reduce | directory containing pdf-files to reduce>` [options]
# OPTIONS
All parameters (options) are optional. In the most cases, the default settings are enough.

* _-r_ <resolution in dpi> to set resolution of page images.
    
    Default resolution is 72. Values in the interval 30..300 are allowable. 
    
    Setthings of resolution affect inversally on an output file's size and quality. The same way settings of quality does (bellow).

* _-q_ <jpeg quality, %> takes values from 1 up to 100.

    Default value is 85.

* _-s_ <file size in bytes> to set the maximum file size.  
    
    The script will process all the files whose size exceeds the maximum size.
    
    The default value is 3000000 bytes (files of 3000000 bytes in size and less will not be processed by default).

* _-m_ <number of method>: to choose a utility to compose a pdf-file: <br> 1 - this method uses pdftocairo+img2pdf and requires these packages (pdftocairo and img2pdf) to exist (be installed) on your system <br> 2 - this method uses pdftocairo+convert(ImageMagick) and requires these packages (pdftocairo and ImageMagick) to exist (be installed) on your system <br> 3 - this method uses ghostscript (gs) and requires this package on your system <br> **The default method is 3 (ghostscript)**.
    
# Dependencies
Depending on what method you use (see description for option "_-m_" above), you have to have installed either `pdftocairo + img2pdf`, or `pdftocaito+ImageMagick`, or `ghostscript` (`gs`) package. By default, `ghostscript` is required.

# Credits
Thanks to:
* The ImageMagick Development Team. [ImageMagick](https://imagemagick.org)
* [Ghostscript](https://www.ghostscript.com) by [Artifex Software, Inc](https://artifex.com/)
* The pdftocairo software and documentation, copyrighted by [Glyph & Cog, LLC](https://glyphandcog.com/) and [The Poppler Developers](https://poppler.freedesktop.org/),  [authors](https://github.com/freedesktop/poppler/blob/master/AUTHORS)
* img2pdf by Johannes 'josch' Schauer (on [PyPI](https://pypi.org/project/img2pdf/), [GitHUB])https://github.com/josch/img2pdf) ).

#License:
>##GPL
    
