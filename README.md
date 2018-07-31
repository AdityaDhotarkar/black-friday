# black-friday
Trying various machine learning methods to predict sales volume per customer. This is using the dataset at https://www.kaggle.com/mehdidag/regularization-and-cross-validation-from-scratch, which was apparently first used in a competition from Analytics Vidhya. The following steps are applied:

1) Clean and cast the data properly (minimal for this dataset - the only NA's are in columns Product_Category_2 and Product_Category_3, which I'll be getting rid of, as these refer to individual purchases when I'm only looking at total sales volume per customer)
2) Make a new dataframe with aggregated sales volume per customer
3) Divide the data into training and test subsets (using an 80/20 split)
4) Make a baseline model which is simply the average of total sales volume per customer, and check the RMSE and MAE if predicting that the total sales volume per customer is the average. Of course, this would result in a high RMSE and MAE and we'd expect any machine learning model would perform much better
5) Try a basic <b>linear model, random forest, stepwise regression, rpart model and k-fold cross-validation</b>, storing the RMSE and MAE of each of these
6) Plot some graphs comparing model predictions to actual values, as well as boxplots to visualize each variable

