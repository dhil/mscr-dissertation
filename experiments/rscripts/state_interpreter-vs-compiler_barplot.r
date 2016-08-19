# State barplot
library(ggplot2)
library(gridExtra)
library(reshape2)
library(plyr)

# This a comment
compilerfile = "12/compiler.transposed.csv"
interpreterfile = "12/interpreter.transposed.csv"
# Read data
compilerDataset = read.csv(paste("/home/dhil/projects/mscr-dissertation/experiments/results", compilerfile, sep="/"), header = TRUE)
interpreterDataset = read.csv(paste("/home/dhil/projects/mscr-dissertation/experiments/results", interpreterfile, sep="/"), header = TRUE)

# Interpreter data
myIData <- list(c(interpreterDataset$state.links), c(interpreterDataset$monadicstate.links), c(interpreterDataset$purestate.links))
myIData <- sapply(myIData, median)

# Compiler data
myCData <- list(c(compilerDataset$state.links), c(compilerDataset$monadicstate.links), c(compilerDataset$purestate.links))
myCData <- sapply(myCData, median)

# Data normalisation
baseline = myIData[3]

myIData.normalised <- sapply(myIData, {function(x) baseline / x})
print(myIData.normalised)

myCData.normalised <- sapply(myCData, {function(x) baseline / x})
print(myCData.normalised)

# Reshape data
Handler = c(myCData.normalised[1], myIData.normalised[1])
Monadic = c(myCData.normalised[2], myIData.normalised[2])
Pure = c(myCData.normalised[3], myIData.normalised[3])
names = c("Links compiler", "Links interpreter")
data <- data.frame(names, Handler, Monadic, Pure)
#data = data[,c(1,2,3,4)]
print(data)

data.m <- melt(data, id.vars='names', variable.name="statetype")
print(data.m)
# plot everything
plot1 <- ggplot(data.m, aes(names, value)) +   
  geom_bar(aes(fill = statetype), position = "dodge", stat="identity") +
  ylab("Relative speed") +
  xlab("Compilation tool") + 
  ggtitle("State interpretation comparison\ninterpreter vs compiler") + 
  labs(fill="State impl.") + theme_gray(base_size = 16)
print(plot1)

# Reshape
#baseline = median(interpreterDataset$purestate.links)
#stateData <- c(median(compilerDataset$state.links), median(compilerDataset$monadicstate.links), median(dataset$purestate.links))