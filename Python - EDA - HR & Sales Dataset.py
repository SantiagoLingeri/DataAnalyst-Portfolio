
        # Importing libraries

import pandas as pd
import numpy as np
import plotly.express as px
import seaborn as sns
from matplotlib import pyplot as plt

#%%     # Load Dataframe(df)

df = pd.read_csv('C:/Users/Home/Downloads/HR-Sales_Dataset.csv')

#%%     # Overview of df structure, features and data types

print(df.transpose())

#%%
print(df.head())

#%%
df.info()

#%%
print(df.describe)

#%%
print(df.transpose().describe())

#%%
print(df.columns)

#%%     # DATA CLEANING

        # Handling incomplete data

#%%     # Delete hidden extra spaces
df.columns = df.columns.str.strip()

#%%     # Check null values

print(df.isnull())

#%%
print(df.isnull().sum())

#%%     # Closer look at incomplete field

print(df[df['ManagerID'].isnull().sort_values(ascending=True)])

#%%     # Replace missing data when possible

df['ManagerID'] = df['ManagerID'].fillna(value=39, inplace=True)

print(df['ManagerID'].isnull().sum())

#%%

df['Absences'].fillna(value=df['Absences'].mean(), inplace=True)

#%%     # Drop empty column

df = df.drop(axis=0, columns=df['IDEmp'])

#%%     # Finally drop missing values that couldn't be replaced

df.dropna(inplace=True)

#%%     # Handling duplicate data

#%%     # Delete duplicated Index

del(df['Index'])

#%%     # Check for duplicates

print(df.duplicated().sum())

#%%

print(df.EmpID.unique())

#%%

print(df.Department.unique())

#%%

print(df.DeptID.unique())

#%%     # Drop duplicates
        
df = df.drop_duplicates(subset=['Department', 'DeptID', 'EmpID'])

#%%     # Handling inconsistent Data

        # Replace spelling errors
 
df['Position'].replace('Data Anlyst','Data Analyst',inplace=True)

#%%     # Convert data types

df['Employee_Name'] = df['Employee_Name'].astype(str)
df['Position'] = df['Position'].astype(str)
df['DateofHire'] = pd.to_datetime(df['DateofHire'])
df['DateofTermination'] = pd.to_datetime(df['DateofTermination'])
df['LastPerformanceReview_Date'] = pd.to_datetime(df['LastPerformanceReview_Date'])

#%%     # Check data consistency

print(df.dtypes)

#%%     # VISUALIZING DATA

print(df.columns)

#%%     # Gender distribution

fig = px.histogram(df, x="Gender")
fig.show

#%%     # Sentiment distribution

print(df.Sentiment.describe())
#%%
df.Sentiment.hist()

#%%     # Manager scores distribution
df.Manager rating by employees.hist()

#%%     # Bar Charts for categorical data

        # Job titles distribution

plt.figure(figsize=(12,6))
sns.countplot( x = 'Position' , data = df , palette='Set2', saturation=1, order = df['Position'].value_counts().index)

#%%     # Sales by Month-Year

plt.figure(figsize=(12,6))
sns.countplot( x = 'Month-Year of Purchase' , data = df , palette='Set2', saturation=1)

#%%     # Employee Satisfaction

plt.figure(figsize=(12,6))
sns.countplot( x = 'EmpSatisfaction' , data = df , palette='Set2', saturation=1)

#%%     # Department

plt.figure(figsize=(12,6))
sns.countplot( x = 'Department' , hue = 'Gender' , data = df , palette='Set2', saturation=1)

#%%     # Comparing 2 categorical variables

        # Targeted Campaign by Quarter

plt.figure(figsize=(30,10))
sns.countplot( x = 'Month-Year of Purchase' , hue = 'Targeted Campaign' , data = df , palette='Set2', saturation=1)

#%%     # Units sold by cateogry (by Quarter)

plt.figure(figsize=(20,10))
sns.barplot(x = 'Month-Year of Purchase', y = 'Units Sold', hue = 'Product Category' , data = df , palette='Set2', saturation=1)

#%%     # Performance by Department

plt.figure(figsize=(12,6))
sns.countplot( x = 'PerfScore' , hue = 'Department' , data = df , palette='Set2', saturation=1)

#%%     # Correlations Heatmap

correlation_matrix = df.corr()
f, ax = plt.subplots(figsize=(9, 6))

sns.heatmap(correlation_matrix, annot=True, cmap=sns.color_palette("flare"), linewidths=.5, ax=ax)

#%%     # Linear Regression Charts (Exploring Predictive power of metrics)

        # Employee Satisfaction on Performance

plt.figure(figsize=(12,6))
sns.regplot( x = df['EmpSatisfaction'] , y = df['PerfScoreID'])

#%%     # Engagement on Performance

plt.figure(figsize=(12,6))
sns.regplot(x = df['EngagementSurvey'], y = df['PerfScoreID'])

#%%        # Discount on Units Sold

plt.figure(figsize=(20,10))
sns.regplot( x = df['Discount'] , y = df['Units Sold'])

#%%     # Customer Ratings on Units Sold

plt.figure(figsize=(20,10))
sns.regplot( x = df['Customer Ratings'] , y = df['Units Sold'])

#%%     # Defects Reported on Customer Ratings

plt.figure(figsize=(20,10))
sns.regplot( x = df['Defects Reported'] , y = df['Customer Ratings'])

#%%     # Defects Reported on Units Sold

plt.figure(figsize=(20,10))
sns.regplot( x = df['Defects Reported'] , y = df['Units Sold'])

#%%     # Checking outliers found in previous plot (Defects reported between 30 y 50)

print(df['Defects Reported'])

#%% New df without outliers

df_clean = df

df_clean.drop(
    labels = [4, 9, 19],
    axis = 0,
    inplace = True
    )
#%% Now Regression Plot without outliers

# Defects Reported, Units Sold

plt.figure(figsize=(20,10))
sns.regplot( x = df_clean['Defects Reported'] , y = df_clean['Units Sold'])