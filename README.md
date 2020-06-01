# reducepdf
bash script to reduce pdf file 
# USAGE:
reducepdf.sh `<pdf-file to reduce | directory containing pdf-files to reduce>` [options]
# OPTIONS
* _-r_ <resolution in dpi> to set resolution of page images.
    
    Default resolution is 72. Values in the interval 30..300 are allowable

* _-s_ <file size in bytes> to set the maximum file size.  
    
    The script will process all the files whose size exceeds the maximum size.
    
    The default value is 3000000 bytes (files of 3000000 bytes in size and less will not be processed by default).

* _-q_ <jpeg quality, %> takes values from 1 up to 100.

    Default value is 85.

* _-m_ <number of method>: to choose a utility to compose a pdf-file: <br> 1 - this method uses pdftocairo+img2pdf<br> 2 - this method uses pdftocairo+convert(ImageMagick)<br> 3 - this method uses ghostscript(gs)<br> The default method is 3 (ghostscript).
    
