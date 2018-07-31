library(ggplot2)
df <- read.csv("BlackFriday.csv")
# check if any NA
sapply(df, function(x)all(any(is.na(x))))
# check number of NA
apply(df, 2, function(x) sum(is.na(x)))
# check other columns to get a feel for the data
summary(df)
# table(unlist(df$Age))
# table(unlist(df$Gender))
# table(unlist(df$City_Category))
# table(unlist(df$Stay_In_Current_City_Years))
# table(unlist(df$Marital_Status))
# graph individual purchases
ggplot(df, aes(x = df$Purchase)) + geom_histogram(binwidth = 100)
# aggregate purchases by User_ID and graph
ap <- aggregate(Purchase ~ User_ID, df, sum)
ggplot(ap, aes(x = ap$Purchase)) + geom_histogram(binwidth = 10000) + xlim(0,5000000)
# purchases per user
counts <- data.frame(table(df$User_ID))
ggplot(counts, aes(x = counts$Freq)) + geom_histogram(binwidth = 1) + xlim(0,300)
# create new dataframe with total purchases only
merged <- merge(x = ap, y = df, by = "User_ID", all = TRUE)
total_purchase_df <- merged[-which(duplicated(merged$User_ID)), ]
total_purchase_df[ ,c('User_ID', 'Product_ID', 'Product_Category_1', 'Product_Category_2', 'Product_Category_3', 'Purchase.y')] <- list(NULL)
colnames(total_purchase_df)[colnames(total_purchase_df)=="Purchase.x"] <- "Purchased"

# Occupation and Marital_Status should be factors - the Occupation is a fixed integer from 1 to 20 indicating the occupation of the customer
total_purchase_df$Occupation <- as.factor(total_purchase_df$Occupation)
total_purchase_df$Marital_Status <- as.factor(total_purchase_df$Marital_Status)

# get training and test data (80/20)
index <- sample(1:nrow(total_purchase_df),size = 0.8*nrow(total_purchase_df))
train <- total_purchase_df[index,]
test <- total_purchase_df[-index,]

# Baseline model - predict the mean of the training data
best_guess <- mean(train$Purchased)
# Evaluate RMSE and MAE on the testing data
RMSE_baseline <- sqrt(mean((best_guess-test$Purchased)^2))
MAE_baseline <- mean(abs(best_guess-test$Purchased))

# linear model
lm_model <- lm(Purchased ~., data = train)
lm_prediction <- predict(lm_model, test)
lm_model_rmse <- sqrt(mean((lm_prediction-test$Purchased)^2))
lm_model_mae <- mean(abs(lm_prediction-test$Purchased))

# random forest
rf_model <- randomForest(Purchased ~., data = train)
rf_prediction <- predict(rf_model, test)
rf_model_rmse <- sqrt(mean((rf_prediction-test$Purchased)^2))
rf_model_mae <- mean(abs(rf_prediction-test$Purchased))

# stepwise regression
null_model <- glm(Purchased ~ 1, data = train)
full_model <- glm(Purchased ~ ., data = train)
step_model <- step(null_model, scope = list(lower = null_model, upper = full_model), direction = "forward")
stepwise_purchase_prediction <- predict(step_model)
swr_rmse <- sqrt(mean((stepwise_purchase_prediction-train$Purchased)^2))
swr_mae <- mean(abs(stepwise_purchase_prediction-train$Purchased))

# rpart 
rpart_model <- rpart(Purchased ~., train)
rpart_prediction <- predict(rpart_model, test)
rpart_rmse <- sqrt(mean((rpart_prediction-test$Purchased)^2))
rpart_mae <- mean(abs(rpart_prediction-test$Purchased))

# gxboost

# SVM

# caret package and running k-fold cross validation
library(caret)
kfold_model <- train(
  Purchased ~ ., total_purchase_df,
  method = "lm",
  trControl = trainControl(
    method = "cv", number = 10, 
    verboseIter = TRUE
  )
)
kfold_prediction <- predict(kfold_model, total_purchase_df)
kfold_model_rmse <- sqrt(mean((kfold_prediction-total_purchase_df$Purchased)^2))
kfold_model_mae <- mean(abs(kfold_prediction-total_purchase_df$Purchased))

ggplot(test, aes(x = lm_model, y = Purchased)) + geom_point(color = "blue", alpha = 0.7) + geom_abline(color = "red") + ggtitle("Linear Model Prediction vs. Real values")
ggplot(test, aes(x = rf_prediction, y = Purchased)) + geom_point(color = "blue", alpha = 0.7) + geom_abline(color = "red") + ggtitle("Random Forest Prediction vs. Real values")
ggplot(train, aes(x = stepwise_purchase_prediction, y = Purchased)) + geom_point(color = "blue", alpha = 0.7) + geom_abline(color = "red") + ggtitle("Stepwise Regression Prediction vs. Real values")
ggplot(test, aes(x = rpart_prediction, y = Purchased)) + geom_point(color = "blue", alpha = 0.7) + geom_abline(color = "red") + ggtitle("rpart Prediction vs. Real values")

# boxplots
ggplot(aes(y = Purchased, x = Gender), data = total_purchase_df) + geom_boxplot()
ggplot(aes(y = Purchased, x = Age), data = total_purchase_df) + geom_boxplot()
ggplot(aes(y = Purchased, x = Occupation), data = total_purchase_df) + geom_boxplot()
ggplot(aes(y = Purchased, x = City_Category), data = total_purchase_df) + geom_boxplot()
ggplot(aes(y = Purchased, x = Stay_In_Current_City_Years), data = total_purchase_df) + geom_boxplot()
ggplot(aes(y = Purchased, x = Marital_Status), data = total_purchase_df) + geom_boxplot()
ggplot(data = total_purchase_df, aes(x = "", y = Purchased)) + geom_boxplot()
