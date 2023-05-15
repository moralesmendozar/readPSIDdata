# readPSIDdata
This repository contains R code to read the downloaded data from PSID from Umich on R. It contains instructions on using Stata within R to transform the data from Stata into R (*.Rdata files), and then how to read it once it is used. It also explains a challenge of variable names.

Citations and references to this code is the best reward for me.

Requirements:
  * This was run and tested on Windows 10.
  * Stata.
  * R and Rstudio.
  * PSID Public data.

One can download the data here:
https://simba.isr.umich.edu/Zips/ZipMain.aspx
ON DOWNLOADING THE DATA:
The zip files will contain, depending on the year and version, a codebook, and files on *.txt, dofiles (Stata), sas and sps.
Unzip the folders in a master folder, for example, "PSID_Public", and then, for example, the folder "fam1968" could contain the year 1968 for family data.

In general, the public data folders contain:
    * fam data (1968-1993).
    * fam ER data (1994,1995-2019 every two years) (this will not be opened on Stata BE or SE due to the number of variables, MP works fine).
    * other data: 
        * wealth (1984 89 94 99 01 03 05-2007),
        * ActSavings89_94,
        * Childbirth and Adoption (cah85_19)
        * 2019 Relationship Matrix File (MX19REL)
        * Parent Identification File 2019 (PID19)
        * Pregnancy Intentions File 2013-2019 (PREGINT19)
  This repository will mostly focus on fam and wealth folders, but all the others can be read, even with this repository. Note that data and folders can change a little when updated in time.


ON FIRST READING THE DATA (fam 1968-1993 are the easy ones).
You should test first to see if the do-file for fam1968 is working and running properly on your Stata/computer. Note that for some reason, I needed to change the line in the do-file:    "using [path]\FAM1968.txt, clear"   to     "using FAM1968.txt, clear"  in order to make it work.
The do files in the folders (cah85_19), (MX19REL), (PID19), (PREGINT19) can also better be run individually.
    
    Once you made sure it runs fine, run the code runAllYears available in the repository, which is a do-file. This will mostly work fine for fam years 1968-1993. This will generate the corresponding Stata data files whenever it is possible to run. Be sure to change to the corresponding working folder.  
    
Then, the code read_All.R can be used to read the Stata data on R and generate an R-dataset with the variable name dataFW containing the dataset for the year.
    
    For the years 1994 onwards it might start to show some issues due to the size of variables, at which point you will have to go to the next step. 
    
    
    
READING THE DATA FOR FAM ER files is a bit trickier. If you have Stata MP, running the codes fam-yr-ER will work fine and you can skip the following step. Otherwise, you will have to work around it due to the number of variables limit.  Similarly, IND2019ER will also show an error without MP (nr. of variables).

 If you have Stata BE or SE, do the following:  copy the FAM-year-ER do file twice and rename it as: "columns.txt" and "labels.txt" The first one, 'columns' should contain the names of the variables, so the first big block of code of the do file, something like " ER2001          1 - 1         ER2002          2 - 6         ER2003          7 - 11   .... "
 
The code "scrapeCopy.txt" can be used in the command window to copy the do files twice and renaming them into 'columns.txt' and 'labels.txt' accordingly. Be sure to change the root folder correspondingly. The "scrapeCopy.txt" also can be used in the cmd window to open all the codebooks for some folders.

The second file, 'labels' should contain only the lables, so basically the second large block of the code, something like: "label variable  ER2001       "RELEASE NUMBER" ; "    Be sure to not include anything else in those text files, as this is the way that the variables will get the codename and the attribute lable in the Rdataset.

NOTE: Some of the later folders, namely fam2017ER and fam2019ER and IND2019er contain some type of varaibles "long" etc for the 'columns' file. I recommend using Excel to open the file as CSV, separate by columns, deleting the corresponding columns with the type of variables, and saving it back as text. Eventually I might upload the files columns for those folders in the repository to save time. Find it as "columns2017.txt", "columns2019.txt" and "columnsIND2019".

Finally, run the code readfamER.R: you need to change the rootFolderName to wherever your PSID public data folders are found.

The code should produce as an output the corresponding mydata-year-ER.Rdata, and the variable itself will be recovered as dataFW.

    
    
Once the ER data is saved, the code read_All.R can be revisited, and it should show the size of all the datasets for the R-data set file in each folder (if it does not have to save the R-data from the Stata dataset first). If there is no file or some variable/folder is incorrectly referenced, there will be an error message.
    
    
    
    Please write back with feedback and comments or if you encounter any error: rodmo@sas.upenn.edu
    
Also let me know if you do find it useful, and remember to cite and spread the good news of this code! I hope you find it useful.
