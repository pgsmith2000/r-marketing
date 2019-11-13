

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
