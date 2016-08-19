library(ggplot2)
library(gridExtra)
library(reshape2)

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

benchmarks <- c("Handler state", "Monadic state", "Pure state")
data.medians <- sapply(data, {function(x) baseline / x})
nexec <- c(data.medians[1], data.medians[2], data.medians[3])
sds   <- c(data.sds[1], data.sds[2], data.sds[3])
stderr    <- sapply(dat, {function(x) sd(x) / length(x)})
se <- c(stderr[13], stderr[2], stderr[3])
print(se)
print(data.medians)

results <- data.frame(benchmarks, nexec, se)
#results <- data.frame(c("handler state", "monadic state", "pure state"), c(dat$state.links, dat$monadicstate.links, dat$purestate.links))



myplot <- ggplot(results, aes(x = benchmarks, y = nexec)) +
          xlab("Benchmarks") +
          ylab("Normalised execution time") +
          ylim(0.0,1.0) +
          geom_bar(stat = "identity", fill="gray60")
#          geom_errorbar(aes(ymin=nexec-se, ymax=nexec+se),
#              width=0.1,                    # Width of the error bars
#              position=position_dodge(1.9))
print(myplot)

#print(data)

#print(data.medians)
#data.stdderiv <- sapply(data, sd)

#p <- barplot(data.medians, main=paste("state", "with normal curve\n( file:", file, ")", sep=" "), xlab="Benchmarks", ylab="Normalised execution time", col="blue")

#segments(p, data.medians - data.stdderiv * 2, p,
#         data.medians + data.stdderiv * 2, lwd = 1.5)

#arrows(p, data.medians - data.stdderiv * 2, p,
#       data.medians + data.stdderiv, lwd = 1.5, angle = 90,
#       code = 3, length = 0.05)

