#Kaggle Titanic Project- Predicting the survival of the passengers onboard using the Training
#data and predicting the output in the test data.

test <- read.csv("test.csv", header = T)
train <- read.csv("train.csv", header = T)

rm(test.data, train.data)

#now we will start the data exploration and data preparation phase.
head(test)
head(train)

#on viewing the data sets we came to know that the test data set didn't have the survive column
# so our first priority is to create a new data frame with the survived column.

test.survived <- data.frame(Survived = rep("None", nrow(test)), test[,])

#combining the test.survived and train dataset to form a new combined 
#dataset on which we will carry out our data analysis.

data.combined <- rbind(train, test.survived)

tail(data.combined)

str(data.combined)

#converting Pclass and Survived into the factor

data.combined$Pclass <- as.factor(data.combined$Pclass)
data.combined$Survived <- as.factor(data.combined$Survived)

#now we will analyse each column seperately and determine its predictive capability, so that we can choose the accurate predictors
#while making our predictive models.

#analysing the first column, Pclass

table(data.combined$Pclass)
table(data.combined$Survived)

#now let's visualise the survival rate according to the class of the passengers.
#we will use the ggplot2 package to accomplish this task
#since the package is already installed, I just need to load it using
#the library function

library(ggplot2)

str(train)

train$Pclass <- as.factor(train$Pclass)
train$Survived <- as.factor(train$Survived)

ggplot(train, aes(x= Pclass, fill = Survived)) +
        geom_bar() +
        xlab("Pclass") +
        ylab("Count") +
        labs(fill = "Survived")
  
#visualisation clearly shows that the people in the 3rd class or with low socia-
#economic status have perished the most, whereas the we have a 50-50 situtaion for 
#2nd class and and passengers in the 1st class has the best survival rate.

#we can also conclude that Pclass is a high predictor variable.


#Now we will analyse the 2nd column which is name column.

head(train$Name)
str(train)

length(unique(data.combined$Name))

#ahaa we got the unique name length as 1307 and the total number of observations
#are 1309, hence there are two names that are duplicated or might be same.
#let's find this out.

dup.names <- data.combined[duplicated(data.combined$Name),"Name"]
dup.names

data.combined[data.combined$Name %in% dup.names,]

#after analysing this, we can say that these names are not duplicated but similar.

#let's deep dive into the titles using the string detect function fount in stringr package

install.packages("stringr")
library(stringr)

head(data.combined$Name,15)

misses <- data.combined[which(str_detect(data.combined$Name, "Miss.")),]
misses[1:5,]

mrs <- data.combined[which(str_detect(data.combined$Name, "Mrs.")),]
mrs[1:5,]

males <- data.combined[which(data.combined$Sex == "male"),]
males[1:5,]

#we can extract the titles from the name column and see if they might turn out be 
#a high predictor for our models. Creating new column is also known as feature engineering.

extractTitle <- function(name) {
  name <- as.character(name)
  
  if (length(grep("Miss.", name)) > 0) {
    return ("Miss.")
  } else if (length(grep("Master.", name)) > 0) {
    return ("Master.")
  } else if (length(grep("Mrs.", name)) > 0) {
    return ("Mrs.")
  } else if (length(grep("Mr.", name)) > 0) {
    return ("Mr.")
  } else {
    return ("Other")
  }
}

titles <- NULL
for (i in 1:nrow(data.combined)) {
  titles <- c(titles, extractTitle(data.combined[i,"Name"]))
}

data.combined$titles <- as.factor(titles)

# okay so we have created a new variable named titles which might turn out to be
# a highly predictive feature.
# lets now look at the survival rate based on this new feature.

ggplot(data.combined[1:891,], aes(x= titles, fill = Survived)) + 
  geom_bar() +
  facet_wrap(~Pclass) +
  ggtitle("Pclass") +
  xlab("titles") +
  ylab("total count") +
  labs(fill = "Survived")

#after visualisation we can say that the title is a high predictive feature

#lets now analyse the 3rd column which is sex.

table(data.combined$Sex)

ggplot(data.combined[1:891,],  aes(x = Sex, fill = Survived)) +
  geom_bar() + 
  facet_wrap(~Pclass) +
  ggtitle("Pclass") +
  xlab("Sex") +
  ylab("Total count") +
  labs(fill = "Survived")

#Analysing the next column Age

summary(data.combined$Age)
summary(data.combined[1:891,]$Age)


#let's visualise

ggplot(data.combined[1:891,], aes(x= Age, fill = Survived)) +
  geom_histogram(binwidth = 10) + 
  facet_wrap(~Sex + Pclass) +
  xlab("Age") +
  ylab("Total count")

#to validate that the titles are apt and appropriate according to the ages

boys <- data.combined[data.combined$titles == "Master.",]
summary(boys$Age)

missess <- data.combined[data.combined$titles == "Miss.",]
misses[1:5,]

summary(missess)

ggplot(missess[missess$Survived != "None" & !is.na(missess$Age),], aes(x= Age, fill = Survived)) +
  facet_wrap(~Pclass) +
  geom_histogram(binwidth = 5) +
  ggtitle("Age for Miss by Pclass") +
  xlab("Age") +
  ylab("total count")

#moving on to the sibsp variable, lets try to find out its predictive
#capability

summary(data.combined$SibSp)
table(data.combined$SibSp)
length(unique(data.combined$SibSp))

data.combined$SibSp <- as.factor(data.combined$SibSp)


ggplot(data.combined[1:891,], aes(x= SibSp, fill= Survived)) +
  geom_bar() +
  facet_wrap(~Pclass + titles) +
  ggtitle("Pclass", "Title") +
  xlab("Sibsp") +
  ylab("Total count") +
  ylim(0,300) +
  labs(fill = "Survived")

#looking at the parch variable

data.combined$Parch <- as.factor(data.combined$Parch)

ggplot(data.combined[1:891,], aes(x = Parch, fill = Survived)) +
  geom_bar() +
  facet_wrap(~Pclass + titles) + 
  ggtitle("Pclass, Title") +
  xlab("ParCh") +
  ylab("Total Count") +
  ylim(0,300) +
  labs(fill = "Survived")

#here we can create another feature by combining the the person along
#with sibsp and parch
#Feature Engineering

temp.sibsp <- c(test$SibSp, train$SibSp)
temp.Parch <- c(test$Parch, train$Parch)

data.combined$family.size <- as.factor(temp.sibsp + temp.Parch + 1)

#visualise our new feature/variable

ggplot(data.combined[1:891,], aes(x = family.size, fill = Survived)) +
  geom_bar() +
  facet_wrap(~Pclass + titles) + 
  ggtitle("Pclass, Title") +
  xlab("family.size") +
  ylab("Total Count") +
  ylim(0,300) +
  labs(fill = "Survived")

#4 Variables are left, let's analyse each one of them

str(data.combined$Ticket)
data.combined$Ticket[1:20]

#let's have a look at the first character of ticket syntax
ticket.first.char <- ifelse(data.combined$Ticket == "", " ", substr(data.combined$Ticket, 1, 1))
unique(ticket.first.char)

data.combined$ticket.first.char <- as.factor(ticket.first.char) 

ggplot(data.combined[1:891,], aes(x = ticket.first.char, fill = Survived)) +
  geom_bar() +
  ggtitle("Survivability by ticket.first.char") +
  xlab("ticket.first.char") +
  ylab("Total Count") +
  ylim(0,350) +
  labs(fill = "Survived")

#Lets split it according to the Pclass

ggplot(data.combined[1:891,], aes(x = ticket.first.char, fill = Survived)) +
  geom_bar() +
  facet_wrap(~Pclass) + 
  ggtitle("Pclass") +
  xlab("ticket.first.char") +
  ylab("Total Count") +
  ylim(0,300) +
  labs(fill = "Survived")

#creating facets based on both Pclass and Title

ggplot(data.combined[1:891,], aes(x = ticket.first.char, fill = Survived)) +
  geom_bar() +
  facet_wrap(~Pclass + titles) + 
  ggtitle("Pclass, Title") +
  xlab("ticket.first.char") +
  ylab("Total Count") +
  ylim(0,200) +
  labs(fill = "Survived")

#Let's now have a look at the fare variable

summary(data.combined$Fare)
length(unique(data.combined$Fare))

ggplot(data.combined, aes(x = Fare)) +
  geom_histogram(binwidth = 5) +
  ggtitle("Combined Fare Distribution") +
  xlab("Fare") +
  ylab("Total Count") +
  ylim(0,200)

ggplot(data.combined[1:891,], aes(x = Fare, fill = Survived)) +
  geom_histogram(binwidth = 5) +
  facet_wrap(~Pclass + titles) + 
  ggtitle("Pclass, titles") +
  xlab("fare") +
  ylab("Total Count") +
  ylim(0,50) + 
  labs(fill = "Survived")


#We will now have a look at the Cabin variable real quick

str(data.combined$Cabin)
data.combined$Cabin <- as.character(data.combined$Cabin)
data.combined$Cabin[1:100]

data.combined[which(data.combined$Cabin == ""), "Cabin"] <- "U"
data.combined$Cabin[1:100]

#fetching the first character of Cabin values

cabin.first.char <- as.factor(substr(data.combined$Cabin, 1, 1))
str(cabin.first.char)
levels(cabin.first.char)
data.combined$cabin.first.char <- cabin.first.char

#visualising

ggplot(data.combined[1:891,], aes(x = cabin.first.char, fill = Survived)) +
  geom_bar() +
  facet_wrap(~Pclass + titles) +
  ggtitle("Pclass, Title") +
  xlab("cabin.first.char") +
  ylab("Total Count") +
  ylim(0,500) +
  labs(fill = "Survived")

#Lastly embarked variable

str(data.combined$Embarked)
levels(data.combined$Embarked)

#Viewing the structure and level of embarked variable.

ggplot(data.combined[1:891,], aes(x = Embarked, fill = Survived)) +
  geom_bar() +
  facet_wrap(~Pclass + titles) +
  ggtitle("Pclass, Title") +
  xlab("embarked") +
  ylab("Total Count") +
  ylim(0,300) +
  labs(fill = "Survived")

#end of data analysis and exploration

#so now we are going to do the exploratory Modeling(creating models using a particular Algorithm)
#in this project we will be using the random forest algorithm.
#so let's load the library for RFA  

install.packages("randomForest")
library(randomForest)

# Train a Random Forest model with the default parameters using pclass & title

rf.train.1 <- data.combined[1:891, c("Pclass", "titles")]
rf.label <- as.factor(train$Survived)

set.seed(1234)
rf.1 <- randomForest(x = rf.train.1, y = rf.label, importance = TRUE, ntree = 1000)
rf.1
varImpPlot(rf.1)


# Train a Random Forest using pclass, title, & sibsp
rf.train.2 <- data.combined[1:891, c("Pclass", "titles", "SibSp")]

set.seed(1234)
rf.2 <- randomForest(x = rf.train.2, y = rf.label, importance = TRUE, ntree = 1000)
rf.2
varImpPlot(rf.2)

#MODEL NO 3
rf.train.3 <- data.combined[1:891, c("Pclass", "titles", "Parch")]

set.seed(1234)
rf.3 <- randomForest(x = rf.train.3, y = rf.label, importance = TRUE, ntree = 1000)
rf.3
varImpPlot(rf.3)

#Model 4 including both Parch and Sibsp

rf.train.4 <- data.combined[1:891, c("Pclass", "titles", "SibSp", "Parch")]

set.seed(1234)
rf.4 <- randomForest(x = rf.train.4, y = rf.label, importance = TRUE, ntree = 1000)
rf.4
varImpPlot(rf.4)

#Model5 including the family.size

rf.train.5 <- data.combined[1:891, c("Pclass", "titles", "family.size")]

set.seed(1234)
rf.5 <- randomForest(x = rf.train.5, y = rf.label, importance = TRUE, ntree = 1000)
rf.5
varImpPlot(rf.5)

#Model 6

rf.train.6 <- data.combined[1:891, c("Pclass", "titles", "SibSp", "family.size")]

set.seed(1234)
rf.6 <- randomForest(x = rf.train.6, y = rf.label, importance = TRUE, ntree = 1000)
rf.6

#model 7

# Train a Random Forest using pclass, title, parch, & family.size

rf.train.7 <- data.combined[1:891, c("Pclass", "titles", "Parch", "family.size")]

set.seed(1234)
rf.7 <- randomForest(x = rf.train.7, y = rf.label, importance = TRUE, ntree = 1000)
rf.7
varImpPlot(rf.7)


#SUBMIT PROCESS

test.submit.df <- data.combined[892:1309, c("Pclass", "titles", "family.size")]

rf.5.preds <- predict(rf.5, test.submit.df)
table(rf.5.preds)

submit.df <- data.frame(PassengerId = rep(892:1309), Survived = rf.5.preds)
write.csv(submit.df, file = "RF_SUB_20200531_1.csv", row.names = FALSE)

#Submission was at 77% accuracy at Kaggle- voilla  :)