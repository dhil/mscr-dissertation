# Sieve line plot
library(ggplot2)
library(gridExtra)
library(reshape2)
library(plyr)

# Load datasets
compilerfile = "14/compiler.transposed.csv"
interpreterfile = "14/interpreter.transposed-sieve.csv"
interpreterBuiltinFile = "14/interpreter.transposed-builtin.csv"
# Read data
compilerDataset = read.csv(paste("/home/dhil/projects/mscr-dissertation/experiments/results", compilerfile, sep="/"), header = TRUE)
interpreterDataset = read.csv(paste("/home/dhil/projects/mscr-dissertation/experiments/results", interpreterfile, sep="/"), header = TRUE)
interpreterBuiltinDataset = read.csv(paste("/home/dhil/projects/mscr-dissertation/experiments/results", interpreterBuiltinFile, sep="/"), header = TRUE)

# Prepare data
myCData = list(c(compilerDataset$sieve101.links),c(compilerDataset$sieve201.links),c(compilerDataset$sieve401.links),c(compilerDataset$sieve601.links),c(compilerDataset$sieve801.links),c(compilerDataset$sieve1001.links))
myCData = sapply(myCData, median)

print(myCData)

myIData = list(c(interpreterDataset$sieve101.links),c(interpreterDataset$sieve201.links),c(interpreterDataset$sieve401.links),c(interpreterDataset$sieve601.links),c(interpreterDataset$sieve801.links),c(interpreterDataset$sieve1001.links))
myIData = sapply(myIData, median)

print(myIData)

myBData = list(c(interpreterBuiltinDataset$builtin101.links),c(interpreterBuiltinDataset$builtin201.links),c(interpreterBuiltinDataset$builtin401.links),c(interpreterBuiltinDataset$builtin601.links),c(interpreterBuiltinDataset$builtin801.links),c(interpreterBuiltinDataset$builtin1001.links))
myBData = sapply(myBData, median)

print(myBData)

# Reshape data
SieveN = c(27,47,80,111,140,169) #c(101,201,401,601,801,1001)
Compiler = myCData #c(1,2,3,4,5,6)
Interpreter = myIData #c(10,20,30,40,50,60)
Builtin     = myBData #c(11,22,33,44,55,66)
names = c("Compiler/handlers", "Interpreter/built-in", "Interpreter/handlers")
#names = c("Compiler", "Interpreter/built-in")

myData <- data.frame(SieveN, Compiler, Builtin, Interpreter)
#myData <- data.frame(SieveN, Compiler, Builtin)

print(myData)

data.m <- melt(myData, id.vars='SieveN', variable.name="impl")
#print(data.m)

# Plot
pdf("/home/dhil/projects/mscr-dissertation/thesis/plots/sieve.pdf", width = 10, height = 7)
plot1 <- ggplot(data.m, aes(x=SieveN, y=value, colour=factor(impl, labels=names))) +
  geom_line(size=2) +
  geom_point(size=4) +
  scale_x_continuous(breaks = round(seq(min(data.m$SieveN)-7, max(data.m$SieveN), by=20),1)) +
  xlab("Number of processes") + ylab("Median execution time [ms]") +
  ggtitle("Dynamic process generation (Sieve)") +
  labs(colour="Concurrency impl.") + theme_gray(base_size = 16)
print(plot1)
dev.off()

