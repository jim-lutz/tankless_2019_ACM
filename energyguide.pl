#!/usr/bin/perl

# usage: ./energyguide.pl
# calls pdfimages to extract the images out of the AHRIEnergyGuide_xxx.pdf files as tiff files
# calls tesseract to OCR the tiff files to text
# extracts manufacturer, MaxGPM, model, yearly_cost, yearly_therms from the text file
# puts pdfname and values into a csv file for later processing.

use strict;
use warnings;

# csv file for output
open(my $out, ">",  "energyguide.csv") or die "Can't open energyguide.csv: $!";

# initialize variables
my ($basename,$file);
my ($mfr,$fuel,$Fmax,$model,$cost,$Eannual_f);
my $cost_flag=0;

# print headers to the csv file
print $out "basename,mfr,fuel,Fmax,model,cost,Eannual_f\n";


# get a list of PDF files
my @pdfns = glob("*.pdf");

# for debugging set to 1
my $debug = 0;

foreach ( @pdfns ) { # for development use [0,4,22,50]
    print "$_\n";
    
    # make the basename
    $basename = $_;
    $basename =~ s/\.pdf//;

    # initialize the variables as blank
    ($mfr,$fuel,$Fmax,$model,$cost,$Eannual_f) = ("","","","","","");

    # extract a tiff file with pdfimages
    my @args = ("pdfimages", "-tiff", "$basename.pdf", "$basename");
    system(@args) == 0 or die "system @args failed: $?";

    # use imagemagick to change the threshold
    @args = ("convert", "$basename"."-000.tif", "-threshold", "50%", "-unsharp", "10", "temp.tif" );
    system(@args) == 0 or die "system @args failed: $?";

    # make a text file version using tesseract
    @args = ("tesseract", "temp.tif" , "$basename");
    system(@args) == 0 or die "system @args failed: $?";

    # remove the *.tif file
    unlink glob "*.tif";

    # read the text file
    open(my $in,  "<",  "$basename.txt")  or die "Can't open $basename.txt: $!";

    while (<$in>) {     # assigns each line in turn to $_
        print "Just read in this line: $_" if $debug;
        
        # find the manufacturer
        if ($_ =~ /Water.+Heater.+Gas (.+)$/) {
            print "\tmanufacturer is $1\n" if $debug;
            $mfr = $1;

            # look for the fuel
            if ($_ =~ /Water Heater - (\w+ Gas) / ) {
                print "\tfuel is $1\n" if $debug;
                $fuel = $1;
            }
        }        
 
        # find the capacity and model
        if ($_ =~ /Capacity.+: (\d.\d).+Model (.+)$/) {
            print "\tFmax is $1\n" if $debug;
            $Fmax = $1;
            print "\tmodel is $2\n" if $debug;
            $model = $2;
        }        
 
        # watch for the cost
        if ( $_ =~ /Estimated Yearly Energy Cost/ ) { $cost_flag=1}

        # catch the cost
        if ($cost_flag==1 ) { 
            if ( $_ =~ /^\$(\d+)/ ) {  
                print "\tcost is $1\n" if $debug;
                $cost = $1;
            
                $cost_flag=0; # found the cost, turn off the flag
            }
        }        
 
        # find the Eannual_f
        if ($_ =~ /Estimated yearly energy use: (\d+) /) {
            print "\tEannual_f is $1\n" if $debug;
            $Eannual_f = $1;
        }        
 
   }

    # remove the *.txt file
    $file = $basename . '.txt';
    print "removing $file\n" if $debug;
    unlink $file or warn "Could not unlink $file: $!";

#    # now work on the mfr and model number
#
#    #=====================================
#    # extract the jpg image with pdfimages
#    my @args = ("pdfimages", "-all", "$basename.pdf", "temp");
#    system(@args) == 0 or die "system @args failed: $?";
#
#    # crop it with imagemagick convert command assume pdfimages always gives it the same number
#    my @args = ("convert", "temp-000.jpg", "-crop", "1200x300+2000+700", "temp.tif");
#
#    # make a text file version using tesseract
#    @args = ("tesseract", "temp-000.tif" , "temp-000");
#    system(@args) == 0 or die "system @args failed: $?";
#
#    # read the text file
#   open(my $in,  "<",  "$basename.txt")  or die "Can't open $basename.txt: $!";
#
#    while (<$in>) {     # assigns each line in turn to $_






    # add a line to the csv file
    print $out "$basename,\"$mfr\",\"$fuel\",\"$Fmax\",\"$model\",$cost,$Eannual_f\n";


}

