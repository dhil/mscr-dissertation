# State barplot
library(ggplot2)
library(gridExtra)
library(reshape2)
library(plyr)

# This a comment
compilerfile = "19/compiler.transposed.csv"
interpreterfile = "19/interpreter.transposed.csv"
ocamloptfile = "19/ocamlopt.transposed.csv"
#compilerOptFile = "18/compiler.transposed-state.csv"

# Read data
compilerDataset = read.csv(paste("/home/dhil/projects/mscr-dissertation/experiments/results", compilerfile, sep="/"), header = TRUE)
interpreterDataset = read.csv(paste("/home/dhil/projects/mscr-dissertation/experiments/results", interpreterfile, sep="/"), header = TRUE)
ocamloptDataset = read.csv(paste("/home/dhil/projects/mscr-dissertation/experiments/results", ocamloptfile, sep="/"), header = TRUE)
#compilerOptDataset = read.csv(paste("/home/dhil/projects/mscr-dissertation/experiments/results", compilerOptFile, sep="/"), header = TRUE)

# Queens 8 data
myQueens8 <- list(c(compilerDataset$queens8.links), c(compilerDataset$queens8_nohandler.links), c(interpreterDataset$queens8.links), c(interpreterDataset$queens8_nohandler.links), c(ocamloptDataset$queens8.ml))
myQueens8 <- sapply(myQueens8, median)
myQueens8B = myQueens8[4]
myQueens8 <- sapply(myQueens8, {function(x) myQueens8B / x})

# Queens 12 data
myQueens12 <- list(c(compilerDataset$queens12.links), c(compilerDataset$queens12_nohandler.links), c(interpreterDataset$queens12.links), c(interpreterDataset$queens12_nohandler.links), c(ocamloptDataset$queens12.ml))
myQueens12 <- sapply(myQueens12, median)
myQueens12B = myQueens12[4]
myQueens12 <- sapply(myQueens12, {function(x) myQueens12B / x})

# Queens 16 data
myQueens16 <- list(c(compilerDataset$queens16.links), c(compilerDataset$queens16_nohandler.links), c(interpreterDataset$queens16.links), c(interpreterDataset$queens16_nohandler.links), c(ocamloptDataset$queens16.ml))
myQueens16 <- sapply(myQueens16, median)
myQueens16B = myQueens16[4]
myQueens16 <- sapply(myQueens16, {function(x) myQueens16B / x})

# Queens 20 data
myQueens20 <- list(c(compilerDataset$queens20.links), c(compilerDataset$queens20_nohandler.links), c(interpreterDataset$queens20.links), c(interpreterDataset$queens20_nohandler.links), c(ocamloptDataset$queens20.ml))
myQueens20 <- sapply(myQueens20, median)
myQueens20B = myQueens20[4]
myQueens20 <- sapply(myQueens20, {function(x) myQueens20B / x})

# Reshape data
i = 1
Compiler = c(myQueens8[i], myQueens12[i], myQueens16[i], myQueens20[i])
i = 2
CompilerNH = c(myQueens8[i], myQueens12[i], myQueens16[i], myQueens20[i])
i = 3
Interpreter = c(myQueens8[i], myQueens12[i], myQueens16[i], myQueens20[i])
i = 4
InterpreterNH = c(myQueens8[i], myQueens12[i], myQueens16[i], myQueens20[i])
i = 5
OCamlopt = c(myQueens8[i], myQueens12[i], myQueens16[i], myQueens20[i])
names = c("8x8", "12x12", "16x16", "20x20")
data <- data.frame(names, Interpreter, InterpreterNH, Compiler, CompilerNH, OCamlopt)
#data = data[,c(1,2,3,4)]
print(data)

data.m <- melt(data, id.vars='names', variable.name="tool")
print(data.m)
# plot everything
pdf("/home/dhil/projects/mscr-dissertation/thesis/plots/nqueens_all.pdf", width = 10, height = 7)
plot1 <- ggplot(data.m, aes(x=reorder(names,value), y=value)) +   
  geom_bar(aes(fill = tool), position = "dodge", stat="identity") +
  ylab("Relative speed up") +
  xlab("Board size") + 
  ggtitle("N-Queens") + 
  labs(fill="Compilation tool/program") + theme_gray(base_size = 16) +
  scale_fill_discrete(name="Compilation tool/impl.",
                      breaks=c("Interpreter", "InterpreterNH", "Compiler", "CompilerNH", "OCamlopt"),
                      labels=c("Interpreter/handlers", "Interpreter/no handlers", "Compiler/handlers", "Compiler/no handlers", "ocamlopt/handlers"))
print(plot1)
dev.off()