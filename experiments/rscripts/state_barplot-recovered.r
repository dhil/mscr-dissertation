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

# Read data
compilerDataset = read.csv(paste("/home/dhil/projects/mscr-dissertation/experiments/results", compilerfile, sep="/"), header = TRUE)
interpreterDataset = read.csv(paste("/home/dhil/projects/mscr-dissertation/experiments/results", interpreterfile, sep="/"), header = TRUE)
ocamloptDataset = read.csv(paste("/home/dhil/projects/mscr-dissertation/experiments/results", ocamloptfile, sep="/"), header = TRUE)
compilerOptDataset = read.csv(paste("/home/dhil/projects/mscr-dissertation/experiments/results", compilerOptFile, sep="/"), header = TRUE)

# Interpreter data
myIData <- list(c(interpreterDataset$state.links), c(interpreterDataset$monadicstate.links), c(interpreterDataset$purestate.links))
myIData <- sapply(myIData, median)

# Compiler data
myCData <- list(c(compilerDataset$state.links), c(compilerDataset$monadicstate.links), c(compilerDataset$purestate.links))
myCData <- sapply(myCData, median)

# OCamlopt data
myOData <- list(c(ocamloptDataset$state.ml), c(ocamloptDataset$monadicstate.ml), c(ocamloptDataset$purestate.ml))
myOData <- sapply(myOData, median)

# Compiler recovered data
myCOData <- list(c(compilerOptDataset$state.links), c(compilerOptDataset$monadicstate.links), c(compilerOptDataset$purestate.links))
myCOData <- sapply(myCOData, median)

# Data normalisation
baseline = myOData[3]

myIData.normalised <- sapply(myIData, {function(x) baseline / x})
print(myIData.normalised)

myCData.normalised <- sapply(myCData, {function(x) baseline / x})
print(myCData.normalised)

myOData.normalised <- sapply(myOData, {function(x) baseline / x})

myCOData.normalised <- sapply(myCOData, {function(x) baseline / x})


# Reshape data
Handler = c(myCData.normalised[1], myIData.normalised[1], myOData.normalised[1], myCOData.normalised[1])
Monadic = c(myCData.normalised[2], myIData.normalised[2], myOData.normalised[2], myCOData.normalised[2])
Pure = c(myCData.normalised[3], myIData.normalised[3], myOData.normalised[3], myCOData.normalised[3])
names = c("Links compiler", "Links interpreter", "ocamlopt", "Links compiler/lin+eq")
data <- data.frame(names, Handler, Monadic, Pure)
#data = data[,c(1,2,3,4)]
print(data)

data.m <- melt(data, id.vars='names', variable.name="statetype")
print(data.m)
# plot everything
pdf("/home/dhil/projects/mscr-dissertation/thesis/plots/stateAll_recovered.pdf", width = 10, height = 7)
plot1 <- ggplot(data.m, aes(x=reorder(names,value), y=value)) +   
  geom_bar(aes(fill = statetype), position = "dodge", stat="identity") +
  ylab("Relative speed") +
  xlab("Compilation tool") + 
  ggtitle("State interpretation comparison\nacross compilation tools (with optimisations)") + 
  labs(fill="State impl.") + theme_gray(base_size = 16)
print(plot1)
dev.off()
