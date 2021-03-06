include.newdata <- function(today="2009-01-01", pricecoffee=-1, pricemilk=-1, totcount=-1, milkout=-1){

  ## LOAD info AND people DATA
  info <- read.csv("data/info.csv", as.is=TRUE,comment.char="#")
  people <- read.csv("data/people.csv", as.is=TRUE, na.strings="")
  date <- info$Date
  nd <- length(date)

  ## UPDATE THE INFO FILE
  ## By asking for manual entries

  # Date of the new file
  if(today=="2009-01-01"){
    cat('\nEnter the date (\"YYYY-MM-DD\") you want for today\n')
    today <- scan(nmax=1, what=character())
  }
  if(as.Date(date[nd])>=as.Date(today)){
    stop('Today\'s date is posterior or equal to the last date in the info.csv file. \nAre you trying a rerun? If so, you do not need to include new data.\n\n')
  }
  
  if(info[nd,]$Date == "Future"){
    cat('Using the data in the Future line of the info.csv file.\n')
    pricecoffee <- info[nd,]$CostBlack
    pricemilk <- info[nd,]$CostMilk
    totcount <- info[nd,]$Count
    milkout <- info[nd,]$MilkOutgoing
  }

  if (pricecoffee==-1 | is.na(pricecoffee) | pricecoffee==""){
    cat('\nEnter the price of black coffee (was $',info$CostBlack[nd],')\n')
    pricecoffee <- scan(nmax=1, what=double())
  }

  if (pricemilk==-1 | is.na(pricemilk) | pricemilk==""){
    cat('\nEnter the price of milk (was $',info$CostMilk[nd],')\n')
    pricemilk <- scan(nmax=1, what=double())
  }

  if (totcount==-1 | is.na(totcount) | totcount==""){
    cat('\nEnter the official number of coffees made by the machine in total (was ',info$Count[nd],'). This can be NA.\n')
    totcount <- scan(nmax=1, what=double());
  }

  if (milkout==-1 | is.na(milkout) | milkout==""){
    cat('\nEnter the total amount of milk gone (was ',info$MilkOutgoing[nd],')\n')
    milkout<- scan(nmax=1, what=double());
  }

## LOAD THE NEW DATA THAT IS STORED IN THE "Future.csv" FILE
  d <- read.csv('data/Future.csv', stringsAsFactors=FALSE)

  # Obtain the coop ID number of a member who is identified by his/her name in the Future file
  get.id <- function(name){
    people[match(name,people$Name),]$ID
  }

  # Obtain the "real name" of this member, if it changed over time
  get.realname <- function(id){
    people[match(id, people$ID),]$Printed.Name
  }

  # Quality check for the Future.csv file
  cols <- c("Name", "Payment", "Payment.Date", "Milk", "Coffee", "Tea")
  if ( !all(cols %in% names(d)) )
    stop(sprintf("Missing columns in %s: %s", filename,
                 paste(setdiff(cols, names(d)), collapse=", ")))

  # List all IDs of the people in the Future.csv file
  theid <- unlist(lapply(d$Name, get.id))
  
  # Quality check: all members must have an ID, even the new ones.
  # The ID of the new ones must have been entered previously in the people.csv file.
  # This step is manual to prevent duplications due to typos. 
  if(any(is.na(theid))){sapply(which(is.na(theid)), function(x){cat(toString(d[x,]$Name), 'is an unregistered new coop member\n')}); stop('-> Add them first to the people.csv file and give them an ID; then rerun.\n')}
  
  # Add the ID info to the Future data
  dd <- cbind(ID=theid, d)
  
  # Add 0 to absent data (coffee and tea counts mainly)
  dd[is.na(dd)] <- 0

  # Write a new data file under the name 'today'.csv,
  # where 'today' is the previously entered date
  cat('== Saving the new data/today.csv file ==\n')
  write.csv(dd, paste('data/',today,'.csv',sep=''), row.names=FALSE)

  # Save the new info.csv file
  cat('== Saving the new info.csv file ==\n')
  system('mv data/info.csv data/oldinfo.csv')
  info <- rbind(info,c(0, pricecoffee, pricemilk, totcount, NA, NA, milkout))
  info[nrow(info),]$Date <- today
  write.csv(info, paste('data/info.csv',sep=''), row.names=FALSE)
  
  date <- info$Date
  nd <- length(date)
}
