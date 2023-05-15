# This code will read the data for all folders containing Stata data or Rdata...
# if no Stata data or Rdata found for a folder, it will simply show an error.

rm(list = ls())
library(haven)
library(RStata)
library(tools)
library(dplyr) 
library(tidyr) #extract_numeric()
library(Hmisc) #to describe(data)
library(ggplot2) #to save plots
#options("RStata.StataPath" = "C:/Program Files/Stata17/StataBE-64")
#chooseStataBin()
#options("RStata.StataVersion" = 17)

#set the root Folder working directory:
rootFolderName <- getwd()
#or...
rootFolderName <- "C:/Users/username/FolderToFiles/PSID_Public"
setwd(rootFolderName) 

# loop/check all folders (## first for all "er" folders)
folders <- list.dirs(recursive =FALSE)# list.files()
csv_files <- list.files(pattern = "\\.csv$") #get csv files of Atlas


##########################################################
##########################################################
## DEFIONE SOME FUNCTIONS:
#FUNCTION 1:
getData<- function(folderii,rootFolderName){
  # This function gets the data for each
  # folder and their dimension:
  setwd(rootFolderName) 
  #set the folder
  setwd(folderii)
  print("------------------------------------------------------------")
  print("------------------------------------------------------------")
  print(paste("Getting data in folder: ",folderii))
  
  #get all the files that have an ending in 
  datasinFolder <- list.files(pattern = "\\.Rdata$")
  if(length(datasinFolder)!=0){ #if there is Rdata...
    print(paste("R Data found succesfully! :)"))
    for(dataSaved in datasinFolder){
      print("-----------------------------")
      print(paste("Loading data from R dataset: ",dataSaved))
      nameVar <- load(file = dataSaved)
      load(file = dataSaved)
      #need to know the name of the dataset is dataFW :O
      if(nameVar=="dataFW"){
        print(paste("nobs: ",nrow(dataFW),"  numVariables :",ncol(dataFW)))
      }else{
        print("The R data frame is not named dataFW")
        print("Cannot count ncol or nrow")
        print("Please check the name of the data in the R dataset for")
        print(paste("Folder: ",folderii,"  "))
        print(paste("& dataSaved: ",dataSaved,"  "))
        dataFW<- "error, The R data frame is not named dataFW"
      }
      print("done with this file...............")
    }
    #check if there are still Stata Datasets not matching R:
    
  }else{ #no Rdata found
    print("-----------------------------")
    print("No R dataset found, looking for Stata dataset")
    stataDatasinFolder <- list.files(pattern = "\\.dta$")
    if(length(stataDatasinFolder)!=0){ #if there is Stata data...
      for(datai in stataDatasinFolder){
        print("-----------------------------")
        print(paste("Loading data from Stata dataset: ",datai))
        #Get the Stata data and save it into R folder,
        #and show the number of columns and rows to compare with codebook/readme
        dataFW <- read_dta(datai)
        dataSaveName<- paste(file_path_sans_ext(datai),'.Rdata', sep = "")
        save(dataFW, file = dataSaveName)
        print(paste("stata Data read and saved as Rdata succesfully! :)"))
        print(paste("nobs: ",nrow(dataFW),"  numVariables :",ncol(dataFW)))
        print("done with this file...............")
      }
    }else{ #no Stata data found
      print("Sorry, no Stata dataset found in folder either")
      dataFW<- "error, no Stata dataset found in folder either"
    }
    print("----------------------")
    print(paste("Done with folder: ",folderii,"  :)"))
    print("----------------------")
    
  }
  return(dataFW)
}
##########################################################
#### FUNCTION 2:
## This function gets the attribute names of the data as a vector:
getAttributeNames <- function(ddata){
  ## This function gets the attribute names of 
  # the data as a vector:
  nn <- ncol(ddata)
  vecNames <- c()
  for(i in 1:nn){
    nameTemp <- attributes(ddata[,i])$label
    vecNames<- c(vecNames,nameTemp)
  }
  return(vecNames)
}
##########################################################
#### FUNCTION 3:
giveNames <- function(wordToSearch,vecNamess,vecCodeNames){
  # This function gets a word and searches in vecNamess,
  # a vector with all the column names of the database,
  # all the entries that are similar to the wordToSearch
  #print('-------------------------------')
  #print(paste('Looking for word: ', wordToSearch))
  sumRepfoundWord <- sum(grepl(wordToSearch, vecNamess, fixed = TRUE))
  #print(paste('Nr of times ', wordToSearch,' appeared was:', sumRepfoundWord))
  which(grepl(wordToSearch, vecNamess, fixed = TRUE))
  attrNames <- vecNamess[grepl(wordToSearch, vecNamess, fixed = TRUE)]
  #print(v)
  codNames <- vecCodeNames[which(grepl(wordToSearch, vecNamess, fixed = TRUE))]
  locations <- which(grepl(wordToSearch, vecNamess, fixed = TRUE))
  v3 <- cbind(codNames,attrNames,locations)
  #print(v3)
  #print('-------------------------------')
  return(v3)
}

##########################################################
##########################################################
##################### Check the data size for all folders
## To print out the number of datapoints in each dataFW of each folder:
for (folderi in folders){
  getData(folderi,rootFolderName)
}

##########################################################
## To read the csv file (Social capital atlas)
## Saved in data_csv
counterf <- 0
setwd(rootFolderName) 
for(filei in csv_files){
  datasinFolder <- list.files(pattern = "\\.Rdata$")
  if(length(datasinFolder)!=0){ #if there is Rdata...
    for(dataSaved in datasinFolder){
      counterf <- counterf+1
      print("-----------------------------")
      print(paste("Loading data from R dataset: ",dataSaved))
      nameVar <- load(file = dataSaved)
      load(file = dataSaved)
    }
  }else{
    counterf <- counterf+1
    data_csv <- read.csv(filei)
    dataSaveName <- paste(file_path_sans_ext(basename(filei)),counterf,".Rdata",sep="")
    save(data_csv, file = dataSaveName)
    #load(file = dataSaveName)  #dataTest1<-  #To load data later on
  }
}

##########################################################
##########################################################
## This is the basic structure 
## To get the data of a given year:
##folders[33] # > 33 = ./fam1999"
dw1 <- getData(folders[33],rootFolderName)
#nrow(dw1)
### Get the mean of data by two variables,
## say, state (ER13004) and educ(15948),   vacations(ER13578)
MEANS <- dw1 %>%  group_by(ER13004,ER15948) %>%   summarise_at(vars(ER13043), list(name = mean))
MEANS <- dw1 %>%  group_by(ER13004,ER15948) %>%   summarise_at(vars(ER13578), mean)
head(MEANS)
attributes(dw1$ER15948)

## Get the codenames and the attributeNames of a dataset, dw1:
vecCodeNames <- colnames(dw1)
vecNamess <- getAttributeNames(dw1)
vecCodeNamess <- colnames(dw1)

##########################################################
# Check variables that contain a word, like "college" 
which(grepl("COLLEGE", vecNamess, fixed = TRUE))
vecNamess[grepl("COLLEGE", vecNamess, fixed = TRUE)]

wordToLook <- "ASSETS"
giveNames(wordToLook,vecNamess,vecCodeNamess)

#this list will contain, for every year, a list with:
 # list(year, matrixWordState, matrixtWordCounty,...)
listNamesMatrices <- list()
foldersYears <- folders[33:43]#Get only folders from years 1999 to 2019
dic1 <- c("STATE", "COUNTY","COLLEGE","EDUCATION","BUSINESS","JOBS")
dic2 <- c("AGE","INCOME","INTEREST","TRANSFER")
dic <- c(dic1,dic2)

##Get the list of year, variablesMatrix: [codName attrName location] 
for (folderi in foldersYears){
  #extract the year from the folder
  yearNum <-as.numeric(gsub("\\D", "", folderi)) #gets the year
  listinlist<- list(yearNum)
  dataTemp <- getData(folderi,rootFolderName)
  vecNamess <- getAttributeNames(dataTemp)
  vecCodeNamess <- colnames(dataTemp)
  for(wordToLook in dic){
    #giveNames(wordToLook,vecNamess) #gives the matrix with 
    # codenames and attribute names, as well as locations:
    #vecNamess changes with each dataset...
    listinlist[[length(listinlist)+1]] <- giveNames(wordToLook,vecNamess,vecCodeNamess)
  }
  listNamesMatrices[[length(listNamesMatrices)+1]] <-listinlist
}
#Gets the whole list for each year:
#listNamesMatrices[1]
#listNamesMatrices[2]
#listNamesMatrices[[2]]
#Gets the first matrix of the year 1 (1999):
#listNamesMatrices[[1]][[2]]


#Now just to look at matrices for each year, for a words in a dictionary 
#pick a word from dictionary, dic, say: "INCOME"
newMatrix<- c()
for(word in dic){  #loop over all words
  kk <- which(dic==word)
  oldMatrix<- newMatrix
  for(i in 1:length(listNamesMatrices)){  #loop over all years
    newMatrix <- listNamesMatrices[[i]][[kk+1]]
    #print(nrow(newMatrix))
    #print(nrow(oldMatrix))
    #print('checking nrow...')
    #print(nrow(newMatrix)!=nrow(oldMatrix))
    if(i==1 || nrow(newMatrix)!=nrow(oldMatrix) || sum(newMatrix[,2]!=oldMatrix[,2])>0){ #
      print("--------------------------------------")
      print('for this year, and this word, matrix changed...')
      print(word)
      print(1999+2*(i-1))
      nmin <- min(nrow(newMatrix),nrow(oldMatrix))
      print(newMatrix[newMatrix[1:nmin,2]!=oldMatrix[1:nmin,2],])
    }
    oldMatrix<- newMatrix
  }
}

## Now get for a given word all the histograms of a given variable
##   for each year, saved in a list with the structure:
## list(year, dataIncomeYear)
## maybe later... word, [codName, attrName,location], 
 ##      [histogram by education, state] ,...)
word<- "INCOME"
listIncomes <- list()
loc_w <- which(dic==word)
count_y <- 0
##Get the list of year, variablesMatrix: [codName attrName location] 
for (folderi in foldersYears){
  count_y <- count_y + 1  #counter of the year
  #extract the year from the folder
  yearNum <-as.numeric(gsub("\\D", "", folderi)) #gets the year
  listinlist<- list(yearNum)
  matrTemp<-listNamesMatrices[[count_y]][[loc_w+1]] #this is the matrix of attr names
  #from matrix get column 3, location of variable:
  iiii<- which(grepl("total family", matrTemp[,2], ignore.case = TRUE))
  print(paste("year=",yearNum," , variable:",matrTemp[iiii,2]))
  if(length(iiii)>1){
    iiii <- iiii[length(iiii)]
  }
  print(matrTemp[iiii,3])
  locM<-as.numeric(matrTemp[iiii,3]) #location of variable in database:
  print(locM)
  #download the database:
  dataTemp <- getData(folderi,rootFolderName)
  
  #get the variable with location on the database
  listinlist[[length(listinlist)+1]] <- dataTemp[,locM]
  #hist(dataTemp[,locM],main =yearNum,breaks =50))
  ## Could get for all word in the dictionary:
  #for(wordToLook in dic){
  #  listinlist[[length(listinlist)+1]] <- dataTemp[,locM_w]
  #}
  listIncomes[[length(listIncomes)+1]] <-listinlist
  
  
}
count_y<- 0
graphics.off() #close all previous plots
for (folderi in foldersYears){
  count_y <- count_y + 1  #counter of the year
  #extract the year from the folder
  yearNum <-as.numeric(gsub("\\D", "", folderi)) #gets the year
  
  dataVecTempIncome <- listIncomes[[count_y]][[2]]
  dataVecTempIncome = ifelse(dataVecTempIncome > 1000000, 1000000, dataVecTempIncome)
  dataVecTempIncome = ifelse(dataVecTempIncome < -10000, -10000, dataVecTempIncome)
  #p<- ggplot(dataWlth1,aes(x_new2)) +  geom_histogram(bins=100, col = "black", fill = "white")
  p2<- tibble(val =dataVecTempIncome ) %>% ggplot(.,aes(dataVecTempIncome)) +  geom_histogram(bins=100, col = "black", fill = "white")
  
  #plot=hist(listIncomes[[count_y]][[2]],main =yearNum,breaks =50)
  #saveName<- paste(rootFolderName,"/plots/",word,"_",yearNum,".pdf",sep="")
  saveName<- paste(rootFolderName,"/plots/",word,"_",yearNum,".png",sep="")
  ggsave(p2,file=saveName)
}

#Gets the whole list for each year:
#listIncomes[1]
#listIncomes[2]
#listIncomes[[2]]
#Gets the first matrix of the year 1 (1999):
#listIncomes[[1]][[2]]

#library(Hmisc)
describe(listIncomes[[1]][[2]]) 






################################################################
#from wealth data collect s16 and s17 (total) for the years: 
#some data on Wealth, only available from 1984 89 94 99 01 03 05-2007
#yearsWealth <- c(1984 89 94 99 01 03 05-2007)
foldersWealth <- folders[51:58]

dataWlth1<- getData(folders[51],rootFolderName)
vecNamessWlth <- getAttributeNames(dataWlth1)
wlth16 <- dataWlth1$S416
wlth17 <- dataWlth1$S417
describe(wlth16)
#plot=hist(wlth16,main ="1999",breaks =50) #cannot be saved :(

#dataWlth1  %>% mutate(x_new  = ifelse(S416 > 1000000, 1000000, S416)) %>% 
  #mutate(x_new2  = ifelse(x_new < -10000, -10000, x_new)) %>%
  #ggplot(aes(x_new2)) +  geom_histogram(bins=100, col = "black", fill = "white")

dataWlth1$xnew = ifelse(dataWlth1$S416 > 1000000, 1000000, dataWlth1$S416)
dataWlth1$x_new2 = ifelse(dataWlth1$xnew < -10000, -10000, dataWlth1$xnew)
p<- ggplot(dataWlth1,aes(x_new2)) +  geom_histogram(bins=100, col = "black", fill = "white")
saveName<- paste(rootFolderName,"/plots/","Wealth2","_",yearNum,".pdf",sep="")
#dir.create(file.path(dirname(saveName)))
ggsave(p,file=saveName)


dataVecTempIncome <- ifelse(dataWlth1$S416 > 1000000, 1000000, dataWlth1$S416)
dataVecTempIncome2 = ifelse(dataVecTempIncome > 1000000, 1000000, dataVecTempIncome)
dataVecTempIncome3 = ifelse(dataVecTempIncome2 < -10000, -10000, dataVecTempIncome2)
p<- tibble(val =dataVecTempIncome3 ) %>% ggplot(.,aes(dataVecTempIncome3)) +  geom_histogram(bins=100, col = "black", fill = "white")







