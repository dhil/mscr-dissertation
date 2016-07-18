# This a comment
file = "2/experiments.log-compiler.transposed.csv"
# file = "2/experiments.log-interpreter.transposed.csv"
# Read data
dat = read.csv(paste("/home/dhil/projects/mscr-dissertation/experiments/results", file, sep="/"), header = TRUE)

# Consider the following columns
cols = list("state.links.out", "monadicstate.links.out", "purestate.links.out")

for (i in 1:length(cols)) {
  dataset = cols[[i]]

  # Project data
  x <- dat[[dataset]]
  #normalized = (x-min(x))/(max(x)-min(x))
  #x = normalized
  
  # Create histogram
  h <- hist(x, breaks=10, col="blue", xlab="Exeuction time (milliseconds)",main=paste(dataset, "with normal curve\n( file:", file, ")", sep=" "))
  # Add normal curve
  xfit<-seq(min(x),max(x),length=40)
  yfit<-dnorm(xfit,mean=mean(x),sd=sd(x))
  yfit <- yfit*diff(h$mids[1:2])*length(x)
  lines(xfit, yfit, col="red", lwd=2) 
  
  # Compute median, mean and std. derivation
  myMean <- mean(x)
  myMedian <- median(x)
  mySd <- sd(x)
  # Display median, mean and std. derivation
  mtext(paste("Mean =", round(myMean, 1), "\nMedian =", 
               round(myMedian, 1), "\nStd.Dev =", round(mySd, 1), "\n N =", length(x)),
        adj = 1)
}