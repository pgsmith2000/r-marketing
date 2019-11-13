

k.stores <- 20     # 20 stores
k.weeks <- 104     # 2 years = 104 weeks

# create the table
store.df <- data.frame(matrix(NA, ncol=10, nrow=k.stores*k.weeks))

# name the columns
names(store.df) <- c("storeNum", "Year", "Week", "p1sales", "p2sales",
                     "p1price", "p2price", "p1prom", "p2prom", "country")
dim(store.df)

# create vectors for store number and country
store.num <- 101:(100+k.stores)
store.cty <- c(rep("US", 3), rep("DE", 5), rep("GB", 3), rep("BR", 2),
                   rep("JP", 4), rep("AU", 1), rep("CN", 2))

length(store.num) # both length = 20
length(store.cty)

# now replace the vectors using rep to expand them
store.df$storeNum <- rep(store.num, each=k.weeks)
store.df$country <- rep(store.cty, each=k.weeks)

# cleanup
rm(store.num, store.cty)

# now create week and year columns
store.df$Week <- rep(1:52, times=k.stores*2)
store.df$Year <- rep(1:2, each=k.weeks/2, times=k.stores)

# now check the structure
str(store.df)

# redefine storeNum and country as factors
store.df$storeNum <- factor(store.df$storeNum)
store.df$country <- factor(store.df$country)

# check structure again
str(store.df)

# look at the first 6 rows
head(store.df)

# look at the last 6 rows
tail(store.df)


# NOW CREATE THE STORE DATA with random data

# set the seed so we can replicate
set.seed(98250)

store.df$p1prom <- rbinom(n=nrow(store.df), size=1, p=0.1)   # 10% prob of promotion
store.df$p2prom <- rbinom(n=nrow(store.df), size=1, p=0.15)  # 15% prob of promotion

# look at it
head(store.df)

str(store.df)
# now each prod sold at 5 price pts from $2.19 to $3.19 overall
# draw a price for each week 
store.df$p1price <- sample(x=c(2.19, 2.29, 2.49, 2.79, 2.99),
                           size=nrow(store.df), replace=TRUE)
store.df$p2price <- sample(x=c(2.29, 2.49, 2.59, 2.99, 3.19),
                           size=nrow(store.df), replace=TRUE)
# look at it
str(store.df)

# set up sales data using poison (counts) distribution, rpois()
# first, the default sales in absence of promotion
tmp.sales1 <- rpois(nrow(store.df), lambda=120)
tmp.sales2 <- rpois(nrow(store.df), lambda=100)

# now scale the counts using log function, since price effects often
# follow logarithmic function rather than linear
# not assuming prices vary inversely - proce of prod1 goes up as price
# of prod2 is lower
tmp.sales1 <- tmp.sales1*log(store.df$p2price)/log(store.df$p1price)
tmp.sales2 <- tmp.sales2*log(store.df$p1price)/log(store.df$p2price)

# finally give each sales a 30% or 40% lift when promoted
# multiply promo status vector by .3 or .4 then multiply by sales
# use floor to drop fractional values
store.df$p1sales <- floor(tmp.sales1*(1 + store.df$p1prom*0.3))
store.df$p2sales <- floor(tmp.sales2*(1 + store.df$p2prom*0.4))

# look at the data.frame again
head(store.df)
str(store.df)

library(car) # for the some() function
some(store.df, 10)

# count how many times prod 1 was on sale at each of the 5 price points
p1.table <- table(store.df$p1price)
# plot it (about the same number of times at each price pt)
plot(p1.table)

# how often was p1 promoted at each price
table(store.df$p1price, store.df$p1prom)

# we set p1 to be promoted about 10% of the time
p1.table2 <- table(store.df$p1price, store.df$p1prom)

# divide the second column by the sum of the first and second columns
p1.table2[, 2]/(p1.table2[, 1] + p1.table2[, 2])

# min and max store sales
min(store.df$p1sales)
max(store.df$p1sales)
mean(store.df$p1sales)
var(store.df$p1sales)
sd(store.df$p1sales)
IQR(store.df$p1sales)   # interquartile range
mad(store.df$p1sales)   # median absolute deviation
quantile(store.df$p1sales, probs=c(0.25, 0.5, 0.75))
quantile(store.df$p1sales, probs=c(0.05, 0.95))

quantile(store.df$p1sales, probs=0:10/10) # probs=c(0, 1/10, 2/20, ...)

# create a summary of sales for prod 1 and 2 based on median and IQR
mysummary.df <- data.frame((matrix(NA, nrow=2, ncol=2)))
names(mysummary.df) <- c("Median Sales", "IQR")
rownames(mysummary.df) <- c("Product 1", "Product 2")

mysummary.df["Product 1", "Median Sales"] <- median(store.df$p1sales)
mysummary.df["Product 2", "Median Sales"] <- median(store.df$p2sales)

mysummary.df["Product 1", "IQR"] <- IQR(store.df$p1sales)
mysummary.df["Product 2", "IQR"] <- IQR(store.df$p2sales)

mysummary.df  # median sales higher and more variation for product 1

library(psych)
describe(store.df)  # note * on output for storeNum and country

# repeat describe excluding these
describe(store.df[, c(2, 4:9)])

# Good practice to load data and convert it to data.frame
# examin dim(); use head and tail to check first few/last few rows
# use some() from car to randomly select rows
# check data.frame structure with str(); esp look for vars that should be factors
# run summary()
# run describe() from psych; note n is same, check trimmed mean and skew (for outliers)

# now check means of columns 2 through 9 (MARGIN=1 - rows; MARGIN=2 - columns)
apply(store.df[, 2:9], MARGIN=2, FUN=mean)

# find sum()
apply(store.df[, 2:9], MARGIN=2, FUN=sum)

# or sd()
apply(store.df[, 2:9], MARGIN=2, FUN=sd)

# want to find difference between mean and meadian for each column (to look for skew)
# note the large + value for p1sales and p2sales suggests a right-hand skew
apply(store.df[, 2:9], MARGIN=2, function(x) {mean(x)-median(x)})

# look at histogram to confirm
hist(store.df$p1sales)
hist(store.df$p2sales)

# clean it up a bit
hist(store.df$p1sales,
     main="Product 1 Weekly Sales Frequencies, All Stores",
     xlab="Product 1 Sales (units)",
     ylab="Count")

# add more columns (breaks or bins) and color the bars
hist(store.df$p1sales,
     main="Product 1 Weekly Sales Frequencies, All Stores",
     xlab="Product 1 Sales (units)",
     ylab="Count",
     breaks=30,
     col="lightblue")

# use density instead of counts on y, and remove the x-axis
hist(store.df$p1sales,
     main="Product 1 Weekly Sales Frequencies, All Stores",
     xlab="Product 1 Sales (units)",
     ylab="Relative Frequency",
     breaks=30,
     col="lightblue",
     freq = FALSE,         # plot density instead of counts
     )             # means set x-axis tick marks == no

# use density instead of counts on y, and remove the x-axis
hist(store.df$p1sales,
     main="Product 1 Weekly Sales Frequencies, All Stores",
     xlab="Product 1 Sales (units)",
     ylab="Relative Frequency",
     breaks=30,
     col="lightblue",
     freq = FALSE, 
     xaxt="n",
     ) 

axis(side=1, at=seq (60 , 300 , by =20))    # add "60" , "80" , ...)

lines(density(store.df$p1sales , bw =10) , # "bw = ..." adjusts the smoothing
      type="l" , col="darkred" , lwd =2) # lwd = line width

# a boxplot of p2sales for all store
boxplot(store.df$p2sales , 
        xlab="Weekly sales" , 
        ylab="P2",
        main="Weekly sales of P2 , All stores", 
        horizontal=TRUE)

# a separate boxplot for each store
boxplot(store.df$p2sales ~ store.df$storeNum, 
        horizontal=TRUE,
        ylab="Store", 
        xlab="Weekly unit sales", 
        las=1,                                  # las=1 forces axis text to horizontal
        main="Weekly Sales of P2 by Store")

# using data= can make variables easier to enter
# promotion makes a difference!
boxplot(p2sales ~ p2prom, data=store.df , 
        horizontal=TRUE, 
        yaxt="n",
        ylab="P2 promoted in store?", 
        xlab="Weekly sales",
        main="Weekly sales of P2 with and without promotion")

axis(side=2, at=c(1,2) , labels=c("No", "Yes"))

# beanplots
library(beanplot)
beanplot(p2sales ~ p2prom , data=store.df , horizontal=TRUE , yaxt="n",
         what=c(0,1,1,0) , log="" , side="second",
         ylab="P2 promoted in store?" , xlab="Weekly sales",
         main="Weekly sales of P2 with and without promotion")

axis(side=2, at=c(1,2) , labels=c("No", "Yes"))

# QQ Plot to check normality

# first compare data to a normal distribution
qqnorm(store.df$p1sales)
# then add normal line to plot
# note the upward skew (deviation from normality)
qqline(store.df$p1sales)

# try same after transforming the data
qqnorm(log(store.df$p1sales))
qqline(log(store.df$p1sales))

# empirical cumulative distribution function (ecdf)
# shows the cumulative proportion of data values in your sample
ecdf(store.df$p1sales)

# now plot it
plot(ecdf(store.df$p1sales),
     main="Cumulative distribution of P1 Weekly Sales",
     ylab="Cumulative proportion",
     xlab=c("P1 weekly sales, all stores", 
            "90% of weeks sold <= 171 units"),
     yaxt="no")

# add custom y-axis
axis(side=2, at=seq(0, 1, by =0.1) , las=1,
     labels=paste(seq(0,100,by =10) , "%" , sep=""))

# Where would 90% of sales occur - the 90th percentile of P1 weekly sales
# add horizontal dotted line at 90%
abline(h=0.9 , lty =3) # "h=" for horizontal line ; " lty =3" for dotted

# add a vertical dotted line at the 90th percentile
abline(v=quantile(store.df$p1sales , pr =0.9) , lty =3) # "v=" vertical line

# Note on chart above: Cumulative distribution plot with lines to 
# emphasize the 90th percentile. The chart identifies that 90% of weekly 
# sales are lower than or equal to 171 units. Other values are easy to 
# read off the chart. For instance, roughly 10% of weeks sell less than 
# 100 units, and fewer than than 5% sell more than 200 units
