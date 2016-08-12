# State barplot
library(ggplot2)
library(gridExtra)
library(reshape2)
library(plyr)

# This a comment
compilerfile = "3/compiler.transposed.csv"
interpreterfile = "3/interpreter.transposed.csv"
# Read data
compilerDataset = read.csv(paste("/home/dhil/projects/mscr-dissertation/experiments/results", compilerfile, sep="/"), header = TRUE)
interpreterDataset = read.csv(paste("/home/dhil/projects/mscr-dissertation/experiments/results", interpreterfile, sep="/"), header = TRUE)

# Interpreter data
myIData <- list(c(interpreterDataset$state.links), c(interpreterDataset$monadicstate.links), c(interpreterDataset$purestate.links))
myIData <- sapply(myIData, median)

baseline = myIData[3]
myIData.normalised <- sapply(myIData, {function(x) baseline / x})

print(myIData.normalised)

# Compiler data
myCData <- list(c(compilerDataset$state.links), c(compilerDataset$monadicstate.links), c(compilerDataset$purestate.links))
myCData <- sapply(myCData, median)

#baseline = myIData[3]
myCData.normalised <- sapply(myCData, {function(x) baseline / x})
print(myCData.normalised)

#myCStateData <- as.data.frame(list(variable=stateLabels, executiontime=myCData.normalised))
#myCStateData = melt(myCStateData, id.var="variable", variable.name="status")
#print(comp.data.normalised)

#employee <- c('John Doe','Peter Gynn','Jolie Hope')
#salary <- c(21000, 23400, 26800)
#startdate <- as.Date(c('2010-11-1','2008-3-25','2007-3-14'))

#employ.data <- data.frame(employee, salary, startdate)
#print(employ.data)

# Reshape data
benchmarks = c("Handler", "Monadic", "Pure")
handler = c(myCData.normalised[1], myIData.normalised[1], 0.0)
monadic = c(myCData.normalised[2], myIData.normalised[2], 0.0)
pure = c(myCData.normalised[3], myIData.normalised[3], 0.0)
names = c("compiler", "interpreter", "ocamlopt")
data <- data.frame(names, handler, monadic, pure)
#data = data[,c(1,2,3,4)]
print(data)

data.m <- melt(data, id.vars='names', variable.name="Benchmark")
print(data.m)
# plot everything
plot1 <- ggplot(data.m, aes(names, value)) +   
  geom_bar(aes(fill = Benchmark), position = "dodge", stat="identity") +
  ylab("Normalised execution time") +
  xlab("Compilation tool") + scale_linetype_discrete(name = "Fancy Title")
print(plot1)

# Reshape
#baseline = median(interpreterDataset$purestate.links)
#stateData <- c(median(compilerDataset$state.links), median(compilerDataset$monadicstate.links), median(dataset$purestate.links))