//-do- will execute the commands in the
//.do file and displays the output, while -run- executes the 
//commands but suppresses the output. 
cls

//cd "C:\Users\username\FolderToFiles\PSID_Public"
// FOLDERtoFiles, for example... \PSID_Public
// one can test running the do file for only one year, say 1969...
//run FAM1969.do
//save mydata1969, replace
//clear
//cd "C:\Users\username\FolderToFiles\PSID_Public\fam`x'"
// di "hello, world

//next, one can run the code for all the fam and wealth years data...

foreach x of numlist 1994/2019 {  *change to 1968/1993 for fam or 1994/2019 for famER
	*next three lines for fam data
	cd C:\Users\username\FolderToFiles\PSID_Public\fam`x'
	run "FAM`x'.do"
	save "mydata`x'", replace
	*next three lines for fam-ER data
	cd C:\Users\username\FolderToFiles\PSID_Public\fam`x'er
	run "FAM`x'ER.do"
	save "mydata`x'", replace
	* uncomment the following for the wealth data:
	*cd C:\Users\username\FolderToFiles\PSID_Public\wlth`x'
	*run "wlth`x'.do"
	*save "mydataWLTH`x'", replace
	clear
}