library(ggplot2)
library(gridExtra)
library(reshape2)

# This a comment
file = "4/experiments.log-compiler.transposed.csv"
# file = "2/experiments.log-interpreter.transposed.csv"
# Read data
dataset = read.csv(paste("/home/dhil/projects/mscr-dissertation/experiments/results", file, sep="/"), header = TRUE)

# Reshape
baseline = median(dataset$purestate.links)
stateData <- c(median(dataset$state.links), median(dataset$monadicstate.links), median(dataset$purestate.links))

stateData.labels     <- c("Handler", "Monadic", "Pure")
stateData.normalised <- sapply(stateData, {function(x) baseline / x})

myStateData <- as.data.frame(list(variable=stateData.labels, executiontime=stateData.normalised))
data = melt(myStateData, id.var="variable", variable.name="status")

print(data)

# By manually specifying the levels in the factor, you can control
# the stacking order of the associated fill colors.
#data$status = factor(as.character(data$status), 
#                    levels=c("compiler"))

print(data)

# Create a named character vector that relates factor levels to colors.
grays = c(compiler="gray85")

plot_1 <- ggplot(data, aes(x=variable, y=value)) +
  ylab("Normalised execution time") +
  xlab("State benchmarks") +
  geom_bar(stat="identity", position="dodge") +
  scale_fill_manual(values=grays)

print(plot_1)