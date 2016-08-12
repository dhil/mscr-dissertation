# Sieve line plot
library(ggplot2)
library(gridExtra)
library(reshape2)
library(plyr)

# Load datasets

# Reshape data
SieveN = c(101,201,401,601,801,1001,1201)
Compiler = c(1,2,3,4,5,6,7)
Interpreter = c(10,20,30,40,50,60,70)
names = c("Links compiler", "Links interpreter")

myData <- data.frame(SieveN, Compiler, Interpreter)

print(myData)

data.m <- melt(myData, id.vars='SieveN', variable.name="impl")
print(data.m)

# Plot
plot1 <- ggplot(data.m, aes(x=SieveN, y=value, colour=impl)) +
  geom_line(size=2) +
  geom_point(size=4) +
  scale_x_continuous(breaks = round(seq(min(data.m$SieveN), max(data.m$SieveN), by=100),1)) +
  xlab("N") + ylab("Median run-time") +
  ggtitle("Dynamic process generation (Sieve)") +
  labs(colour="Compilation tool")
print(plot1)
