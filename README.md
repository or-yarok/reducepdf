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

* _-m_ <number of method>: to choose a utility to compose a pdf-file: <br> 1 - this method uses pdftocairo+img2pdf and requires these packages (pdftocairo and img2pdf) to exist (be installed) on your system <br> 2 - this method uses pdftocairo+convert(ImageMagick) and requires these packages (pdftocairo and ImageMagick) to exist (be installed) on your system <br> 3 - this method uses ghostscript (gs) and requires this paxkage on your system <br> **The default method is 3 (ghostscript)**.
    
    You 
    
