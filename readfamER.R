# This code will read the data for all folders in 1995ER to 2019ER
# from the txt files adn save into Rdata files...

rm(list = ls())
library(haven)
library(RStata)
## the following 3 commands not needed if reading data directly from the txt files...
#options("RStata.StataPath" = "C:/Program Files/Stata17/StataBE-64")
#chooseStataBin()
#options("RStata.StataVersion" = 17)

#set the root Folder working directory:
rootFolderName <- getwd()
#or...
rootFolderName <- "C:/Users/username/FolderToFiles/PSID_Public"
setwd(rootFolderName) 

# loop/check all folders, first for all "er" folders
folders <- list.files()
#years <- c(1994,1995,1996)
#years <- c(years,seq(1997,2015,by=2)) # 17 and 19 have "long" in some columns :O
years <- seq(2019,2019,by=2) # 17 and 19 have "long" in some columns :O

start_time_total = Sys.time()
#yeari <- 2017
for (yeari in years){
  start_time = Sys.time()
  
  ##stata("FAM1968.do")  # will not save dta unless older version of stata
  statadataname <- paste('mydata',yeari,'ER', sep = "")
  # first check if stata file exist, use it...
  if(file.exists(statadataname)){ #if data exists from stata, save in R mode:
    dataFW <- read_dta(statadataname)#"mydata1968.dta") # stata hasnt enugh mmry
    dataSaveName <- paste('mydata',yeari,'ER.Rdata', sep = "")
    save(dataFW, file = dataSaveName)
  }else{
    #enter the folder:
    currentFolderName <- paste(rootFolderName,'/fam',yeari,'er', sep = "")
    setwd(currentFolderName)
    print(paste('working on year: ', yeari,sep=""))
    print('reading columns')
    #columns <-read.fwf("columns.txt", header=FALSE,widths=c(4,7,4,1,4,4,7,4,1,4,4,7,4,1,4))
    #columns <- read.table("columns.txt", 
    #                      sep ="", header = FALSE, dec =".")
    columns <- read.csv(file = "columns1.csv", header = FALSE)
    print('columns read')
    #save the columns to use in vec
    vec <- c()
    labals1 <- c()
    for (i in 1:nrow(columns)) {
      for (j in 1:3) {
        d <- 1+columns[i,5*j]-columns[i,5*j-2]
        namecolij <- columns[i,2+5*(j-1)]
        if(!is.null(d)&!is.na(d)){
          vec <- append(vec,d)
          labals1 <- append(labals1,namecolij)
        }
      }
    }
    colClassesi <- rep("numeric",length(labals1))
    for (i in 1:nrow(columns)) {
      for (j in 1:3) {
        colcl <- columns[i,1+5*(j-1)]
        d <- 1+columns[i,5*j]-columns[i,5*j-2]
        if(!is.null(d)&!is.na(d)&!is.na(colcl)&!is.null(colcl)){
          colClassesi[i] <- colcl
        }
      }
    }
    
    print('... reading data text')
    dataFile <- paste('FAM',yeari,'ER.txt', sep = "")
    # can use colClasses=c("character",rep("numeric",5)), 
    # but need to define that earlier :)
    dataFW <-read.fwf(dataFile, header=FALSE,widths=vec)
    #dataFW <-read.fwf(dataFile, header=FALSE,widths=vec,colClasses=colClassesi)
    print('data text read')
    colnames(dataFW)<- labals1
    #read lables
    print('... reading labels')
    labls <- read.table("labels.txt", 
                        sep ="", header = FALSE, dec =".")
    print('labels read')
    for (j in 1:ncol(dataFW)) {
      attributes(dataFW[,j])$label = labls[j,4]
    }
    
    
    #save data as r 
    dataSaveName <- paste('mydata',yeari,'ER.Rdata', sep = "")
    save(dataFW, file = dataSaveName)
    # load(file = dataSaveName)
  }
  
  end_time = Sys.time()
  time_yeari <- end_time - start_time
  print(paste('year(', yeari, ') took: ',time_yeari, ' seconds to run'))
  
}

end_time_total = Sys.time()


