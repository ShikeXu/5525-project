library(readxl)
Data2000<-read_xls('C:/Users/sirius/Desktop/1995-2003/2000.xls',skip = 3)
Data2000<-Data2000[,-11]
str(Data2000[,-11])
# Reform the Area/State
attach(Data2000)

StateNA<-which(is.na(Area))
# get State Positions and Area Positions
StateNamePos<-(StateNA[seq(1,length(StateNA)-1,by=2)]+StateNA[seq(2,length(StateNA)-1,by=2)])/2
AreaPos<-which(Area %in% c('Metropolitan Statistical Area','Cities outside metropolitan areas','Rural'))
ActualPos<-which(Area =='Area actually reporting')
EstimPos<-which(Area =='Estimated totals')
TotalPos<-which(Area =='State Total')
RatePos<-which(Area =='Rate per 100,000 inhabitants')
# drop useless information and drop digits in Var names
Data2000<-Data2000[1:tail(StateNA,1)-1,]
StateName<-Area[StateNamePos]
StateName<-gsub('\\d','',StateName)
Area[StateNamePos]<-StateName
colnames(Data2000)<-gsub('[^A-Za-z]','',colnames(Data2000))
detach(Data2000)
### assign [State] & [Area] type to Actual/Estimated data
# NOTE: this code is different for different years!!!
# choose the colomns you need
Data2000_Part1<-subset(Data2000,select = -c(ModifiedCrimeIndexTotal,Area,Arson))
Data2000_Part1$State<-rep('',nrow(Data2000_Part1))
Data2000_Part1$Area<-rep('',nrow(Data2000_Part1))
Data2000_Part1$Actual<-rep('',nrow(Data2000_Part1))
for (i in 1:(length(StateNamePos)-1)){
  Data2000_Part1$State[(StateNamePos[i]+2):(StateNamePos[i+1]-2)]=StateName[i]
  Data2000_Part1$State[(tail(StateNamePos,1)+2):nrow(Data2000_Part1)]=tail(StateName,1)
}

for (i in ActualPos) {
  if(Data2000$Area[i-1]=='Metropolitan Statistical Area'){
    Data2000_Part1$Area[i]='M'
    Data2000_Part1$Actual[i]="Y"
  }
  if(Data2000$Area[i-1]=='Cities outside metropolitan areas'){
    Data2000_Part1$Area[i]='O'
    Data2000_Part1$Actual[i]="Y"
  }    
  if(Data2000$Area[i-1]=='Rural'){
    Data2000_Part1$Area[i]='R'
    Data2000_Part1$Actual[i]="Y"
  }
}

for (i in EstimPos) {
  if(Data2000$Area[i-2]=='Metropolitan Statistical Area'){
    Data2000_Part1$Area[i]='M'
    Data2000_Part1$Actual[i]="N"
  }
  if(Data2000$Area[i-2]=='Cities outside metropolitan areas'){
    Data2000_Part1$Area[i]='O'
    Data2000_Part1$Actual[i]="N"
  }    
  if(Data2000$Area[i-2]=='Rural'){
    Data2000_Part1$Area[i]='R'
    Data2000_Part1$Actual[i]="N"
  }
}

colnames(Data2000_Part1)[colnames(Data2000_Part1) == 'Population'] <- 'Percentage'
Data2000_Part1<-Data2000_Part1[sort(c(EstimPos,ActualPos)),]
Data2000_Part1<-Data2000_Part1[,c('State','Area','Actual','Percentage','CrimeIndexTotal','ViolentCrime','PropertyCrime','Murderandnonnegligentmanslaughter',
                                  'Forciblerape','Robbery','Aggravatedassault','Burglary','Larcenytheft','Motorvehicletheft')]
with(Data2000_Part1,
     {State<-as.factor(State)
     Area<-as.factor(Area)
     Actual<-as.factor(Actual)
     })
###

### 
Data2000_Part2<-subset(Data2000,select = -c(Population,ModifiedCrimeIndexTotal,Area,Arson))
Data2000_Part2<-Data2000_Part2[RatePos,]
Data2000_Part2<-cbind(State=StateName,Data2000_Part2)
###
write.csv(Data2000_Part1,"C:/Users/sirius/Desktop/1995-2003/Data2000_Part1.csv", row.names = FALSE)
write.csv(Data2000_Part2,"C:/Users/sirius/Desktop/1995-2003/Data2000_Part2.csv", row.names = FALSE)


