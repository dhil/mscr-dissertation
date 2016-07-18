# Boxplot

file = "2/experiments.log-compiler.transposed.csv"
# file = "2/experiments.log-interpreter.transposed.csv"
# Read data
dat = read.csv(paste("/home/dhil/projects/mscr-dissertation/experiments/results", file, sep="/"), header = TRUE)

x = dat

normalized = (x-min(x))/(max(x)-min(x))
x = normalized
print(x)

pure <- x$purestate.links.out
monadic <- x$monadicstate.links.out
handler <- x$state.links.out

data <- data.frame(pure=pure)
boxplot(data)

meanPure <- mean(pure)
meanMonadic <- mean(monadic)
meanHandler <- mean(handler)

print(meanPure)
print(meanMonadic)
print(meanHandler)
