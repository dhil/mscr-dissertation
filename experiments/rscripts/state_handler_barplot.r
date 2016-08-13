# State barplot
library(ggplot2)
library(gridExtra)
library(reshape2)
library(plyr)

# This a comment
compilerfile = "12/compiler.transposed.csv"
interpreterfile = "12/interpreter.transposed.csv"
ocamloptfile = "12/ocamlopt.transposed.csv"
compilerOptFile = "18/compiler.transposed-state.csv"
compilerOpt0File = "17/compiler.transposed-state.csv"
# Read data
compilerDataset = read.csv(paste("/home/dhil/projects/mscr-dissertation/experiments/results", compilerfile, sep="/"), header = TRUE)
interpreterDataset = read.csv(paste("/home/dhil/projects/mscr-dissertation/experiments/results", interpreterfile, sep="/"), header = TRUE)
ocamloptDataset = read.csv(paste("/home/dhil/projects/mscr-dissertation/experiments/results", ocamloptfile, sep="/"), header = TRUE)
compilerOptDataset = read.csv(paste("/home/dhil/projects/mscr-dissertation/experiments/results", compilerOptFile, sep="/"), header = TRUE)
compilerOpt0Dataset = read.csv(paste("/home/dhil/projects/mscr-dissertation/experiments/results", compilerOpt0File, sep="/"), header = TRUE)

# Interpreter data
myData = list(c(interpreterDataset$state.links), c(compilerDataset$state.links), c(ocamloptDataset$state.ml), c(compilerOpt0Dataset$state.links), c(compilerOptDataset$state.links))
myData = sapply(myData, median)

# Data normalisation
baseline = myData[3]

myNormalisedData = sapply(myData, {function(x) baseline / x})

# Reshape data
names = c("Links interpreter", "Links compiler", "ocamlopt", "Links compiler/lin", "Links compiler/lin+eq")
data <- data.frame(names, myNormalisedData)
#data = data[,c(1,2,3,4)]
print(data)

data.m <- melt(data, id.vars='names', variable.name="statetype")
print(data.m)
# plot everything
pdf("/home/dhil/projects/mscr-dissertation/thesis/plots/statehandlerAll.pdf", width = 10, height = 7)
plot1 <- ggplot(data.m, aes(x=reorder(names, value), y=value)) +   
  geom_bar(aes(fill = statetype), position = "dodge", stat="identity") +
  ylab("Relative speed") +
  xlab("Compilation tool") + 
  ggtitle("State handler comparison cross compilation tools\n(with optimisations)") + 
  labs(fill=NULL) + theme_gray(base_size = 16) + theme(legend.position = 'none')
print(plot1)
dev.off()