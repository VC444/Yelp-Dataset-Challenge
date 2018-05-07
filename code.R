install.packages("aws.s3")
library(SparkR)
library("aws.s3")
Sys.setenv("AWS_ACCESS_KEY_ID" = "XXXXXXXXXXXXXXXXXXXX",
           "AWS_SECRET_ACCESS_KEY" = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
           "AWS_DEFAULT_REGION" = "us-east-1")
bucketlist()
get_bucket('yelpdatasetchallengebigdataproject')
obj <- get_object("s3://yelpdatasetchallengebigdataproject/yelp_review.csv")

yelpData <- read.csv(text = rawToChar(obj)) #storing csv data from Amazon s3 to a yelp data variable
display(yelpData) # preview of the dataset
sum(is.na(yelpData)) # checking if there is any NA's or data is clean 
nrow(yelpData) # Number of rows in dataset
str(yelpData) # structure of the dataset
names(yelpData) # mainly used for seeing for column numbers

yelpData <- yelpData[,c(4,6,7,8,9)]
head(yelpData)
display(yelpData) # Making sure whether it extracted the right columns
pairs(yelpData) # seeing if there is any correlation visually between variables
yelpData$textLength <- nchar(as.character(yelpData$text)) # Adding text length column to yelpData which calculates length of the review text
display(yelpData) #Checking to see if new column is added and has text  length

#Installing sentimentr package
if (!require("pacman")) install.packages("pacman")
pacman::p_load_current_gh("trinker/lexicon", "trinker/sentimentr")

yelpData$text <- as.character(yelpData$text) #Coverting factor to character type
yelp <- sentiment_by(yelpData$text) # getting sentiment scores
yelpData$textSentimentScore <- yelp$ave_sentiment # adding each text sentimental score to new column called textSentimentScore
correlations <- cor(yelpData[,c(1,3,4,5,6,7)], use="pairwise", method="spearman") # Calculating Correlation for selected columns

install.packages("corrplot") #installing corrplot package
library(corrplot)
corrplot.mixed(correlations, order="hclust", tl.col="black") #plotting the correlation graph between variable
attach(yelpData) #attaching the Yelp data for reproducibility
boxplot(textSentimentScore~stars,data=yelpData, main="Sentimental Score Vs Stars", 
  	xlab="Stars", ylab="Sentimental Score") # box plot between Sentimental score and stars
# Higher the ratings (stars), the review is more positive. Therefore sentimental score and stars are directly related. 

# Splitting the data into train and test data for regression analysis
set.seed(2017)
i <- base::sample(1:nrow(yelpData), nrow(yelpData)*0.75, replace=FALSE)
train_yelpData <- yelpData[i,]
test_yelpData <- yelpData[-i,]

# Creating a linear regression model
lm1 <- lm(stars ~ useful+funny+cool+textLength+textSentimentScore, data = train_yelpData)
summary(lm1)
predictions <- predict(lm1, newdata=test_yelpData) # using the linear regression model to predict ratings against test values
cor(predictions, test_yelpData$stars) # calculating the correlation accuracy for the linear regression model

install.packages("dplyr")
par(mfrow=c(2,2))
plot(lm1)
plot(stars ~ useful+funny+cool+textLength+textSentimentScore, data=yelpData)
abline(lm1, col="red")

