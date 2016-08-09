# This a comment
file = "4/experiments.log-compiler.transposed.csv"
# file = "2/experiments.log-interpreter.transposed.csv"
# Read data
dat = read.csv(paste("/home/dhil/projects/mscr-dissertation/experiments/results", file, sep="/"), header = TRUE)

# Consider the following columns
#cols = list("state.links.out", "monadicstate.links.out", "purestate.links.out")
cols = list("state.links", "monadicstate.links", "purestate.links")

baseline = median(dat$purestate.links)

data <- c(median(dat$state.links), median(dat$monadicstate.links), median(dat$purestate.links))

print(data)

data.medians <- sapply(data, {function(x) baseline / x})
print(data.medians)
data.stdderiv <- sapply(data, sd)

p <- barplot(data.medians, main=paste(dataset, "with normal curve\n( file:", file, ")", sep=" "), xlab="Benchmarks", ylab="Normalised execution time", col="blue")
error.bar(p, data.medians, 1.96*y.stdderiv/10)


