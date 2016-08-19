# State barplot
library(ggplot2)
library(gridExtra)
library(reshape2)
library(plyr)

# This a comment
compilerfile = "12/compiler.transposed.csv"
interpreterfile = "12/interpreter.transposed.csv"
ocamloptfile = "12/ocamlopt.transposed.csv"
# Read data
compilerDataset = read.csv(paste("/home/dhil/projects/mscr-dissertation/experiments/results", compilerfile, sep="/"), header = TRUE)
interpreterDataset = read.csv(paste("/home/dhil/projects/mscr-dissertation/experiments/results", interpreterfile, sep="/"), header = TRUE)
ocamloptDataset = read.csv(paste("/home/dhil/projects/mscr-dissertation/experiments/results", ocamloptfile, sep="/"), header = TRUE)

# Interpreter data
myIData <- list(c(interpreterDataset$state.links), c(interpreterDataset$monadicstate.links), c(interpreterDataset$purestate.links))
myIData <- sapply(myIData, median)

# Compiler data
myCData <- list(c(compilerDataset$state.links), c(compilerDataset$monadicstate.links), c(compilerDataset$purestate.links))
myCData <- sapply(myCData, median)

# OCamlopt data
myOData <- list(c(ocamloptDataset$state.ml), c(ocamloptDataset$monadicstate.ml), c(ocamloptDataset$purestate.ml))
myOData <- sapply(myOData, median)

# Data normalisation
baseline = myOData[3]

myIData.normalised <- sapply(myIData, {function(x) baseline / x})
print(myIData.normalised)

myCData.normalised <- sapply(myCData, {function(x) baseline / x})
print(myCData.normalised)

myOData.normalised <- sapply(myOData, {function(x) baseline / x})


#employee <- c('John Doe','Peter Gynn','Jolie Hope')
#salary <- c(21000, 23400, 26800)
#startdate <- as.Date(c('2010-11-1','2008-3-25','2007-3-14'))

#employ.data <- data.frame(employee, salary, startdate)
#print(employ.data)

# Reshape data
Handler = c(myCData.normalised[1], myIData.normalised[1], myOData.normalised[1])
Monadic = c(myCData.normalised[2], myIData.normalised[2], myOData.normalised[2])
Pure = c(myCData.normalised[3], myIData.normalised[3], myOData.normalised[3])
names = c("Links compiler", "Links interpreter", "ocamlopt")
data <- data.frame(names, Handler, Monadic, Pure)
#data = data[,c(1,2,3,4)]
print(data)

data.m <- melt(data, id.vars='names', variable.name="statetype")
print(data.m)
# plot everything
pdf("/home/dhil/projects/mscr-dissertation/thesis/plots/stateAll.pdf", width = 10, height = 7)
plot1 <- ggplot(data.m, aes(x=reorder(names,value), y=value)) +   
  geom_bar(aes(fill = statetype), position = "dodge", stat="identity") +
  ylab("Relative speed up") +
  xlab("Compilation tool") + 
  ggtitle("State interpretation comparison\nacross compilation tools") + 
  labs(fill="State impl.") + theme_gray(base_size = 16)
print(plot1)
dev.off()

# Reshape
#baseline = median(interpreterDataset$purestate.links)
#stateData <- c(median(compilerDataset$state.links), median(compilerDataset$monadicstate.links), median(dataset$purestate.links))