# -*- coding: utf-8 -*-

#%%
# Importing libraries

import pandas as pd
import numpy as np
import nltk
nltk.download('punkt')
from nltk.tokenize import word_tokenize
nltk.download('stopwords')
from nltk.corpus import stopwords
import matplotlib.pyplot as plt
import seaborn as sns
from textblob import TextBlob

#%%

# Extract data from Excel file

df = pd.read_excel('Text_NLP.xlsx')
#%%         # Take a general look of Dataframe(df) Structure, Columns and Data Types.

pd.set_option('display.max_columns', 50)
#%%

print(df.head())

#%%

df.info()

#%%

print(df.columns)

#%%

print(df['Appraiser_name'])

#%%                             # DATA CLEANING  

        # Check for null values

print(df.isnull().sum())

#%%     # Check for duplicates

print(df['Appraiser_name'].unique())

#%%

print(df['Sub_unit'].unique())

#%%     # Integrate to fix hidden duplicates in Sub_unit for the same country

df['Sub_unit'].replace('Canada Conservation','Canada', inplace=True)

df['Sub_unit'].replace('Mexico Travel Team','Mexico', inplace=True)

df['Sub_unit'].replace('India Recruitment','India', inplace=True)

#%%     # Verify duplicates fixed
        
print(df['Sub_unit'].unique())

#%%                             # Natural Language Processing (NLP)

        # Data Preprocessing before appling NLP Tools

        # Counting characters without spaces

df['Employee_feedback_car_count'] = df['Employee_feedback'].str.len() - df["Employee_feedback"].str.count(' ')

#%%     # Verify

print(df['Employee_feedback_car_count'])
#%%

#%%     # Tokenization of words to find patterns later

word_tokens = word_tokenize( str(df['Employee_feedback'].to_numpy() ) )

#%%     # Transforming everything to lower case

word_tokens = map(str.lower, word_tokens)

#%%     # Creating new df with tokenized words data

word_tokens = pd.DataFrame(data=word_tokens, columns=['terms'])

#%%     # Verify

print(word_tokens)

#%%     # Filter only string characters, leaving out numbers.

word_tokens = [item for item in word_tokens['terms'] if not item.isdigit()]

#%%     # Verify

print(word_tokens)

#%%     # Removing stop words from Sentiment Analysis
        # Setting Module Language

stop_words = set(stopwords.words('english'))

#%%     # Check Module's stop words

print(stop_words)

#%%     # Add other stop words that might interfere our analysis

stop_words.update(["'","...","”","``","'re","[","]","'d","'ball","''","&","%","$","also","!","would","this","get","however","'ll","a",".","'s","n't","(",")","'m","’",",","-",":",";","•","as","–","“","'ve","...","nan"])

        # Check updated stop words to remove

print(stop_words)

#%%     # Create new list of filtered words ready to analyze

filtered_words = []

for word in word_tokens:
   if word not in stop_words:
      filtered_words.append(word)

#%%     # Grouping words by frequency

freq = nltk.FreqDist(filtered_words)

df_freq = pd.DataFrame.from_dict(freq, orient='index')
df_freq.columns = ['frequency']
df_freq.index.name = 'term'

        # Verify

print(df_freq)

#%%     #   Now explore new insights using Data Visualization

        # 30 Most repeated words in Feedbacks

plt.figure(figsize=(14, 7))
freq.plot(30, cumulative=0)

#%%     # ScatterPlot associating Performance score and character count of Employee Feedback

plt.figure(figsize=(14, 7))
plt.xlabel('GENERAL PERFORMANCE SCORE')
plt.ylabel('CHARACTERS')
plt.scatter( x = df['General_performance_score'], y = df['Employee_feedback_car_count'])
plt.show()

#%%     # Character count distribution

sns.displot(data = df, x='Employee_feedback_car_count', aspect=1.5)

#%%     # Count Feedbacks by Sub Unit

plt.figure(figsize=(20, 5))
chart = sns.countplot(x='Sub_unit',data=df,palette='Set2',saturation=1,order=df['Sub_unit'].value_counts().index)
chart.set_xticklabels(chart.get_xticklabels(), rotation=45, horizontalalignment='right')

#%%     # SENTIMENT ANALYSIS
        # Creating function to calculate sentiment in feedbacks

def sent_analysis(text):
    try:
        return TextBlob(text).sentiment.polarity
    except:
        return None
    
#%%     # Use function to analyze feedbacks and store results in a new column

df['sent'] = df['Employee_feedback'].apply(sent_analysis)

        # Verify results

print(df['sent'])

#%%     # SENTIMENT ANALYSIS VISUALIZATION

        # Repeat previous ScatterPlot now Adding color indicating Sentiment perceived

plt.figure(figsize=(14, 7))
plt.xlabel('GENERAL PERFORMANCE SCORE')
plt.ylabel('CHARACTERS')
plt.scatter(x=df['General_performance_score'], y=df['Employee_feedback_car_count'], c=df['sent'], cmap='RdYlGn')
plt.show()

#%%     # Add Index column to new visualizations

df['Employee_ID'] = df.index.to_numpy()+1

        # Verify Index
        
print(df.Employee_ID)

#%%     # Scatterplot with All Sentiment scores

plt.figure(figsize=(14, 7),dpi=100)

plt.xlabel('SENTIMENT')
plt.ylabel('ID')

plt.scatter( x = df['sent'], y = df['Employee_ID'], c = df['sent'], cmap = 'RdYlGn' )

#%%     # Sentiment distribution

sns.displot(data = df, x='sent', aspect=2)

#%%     # Explore correlations between Sentiment and Performance

plt.figure(figsize=(14, 7),dpi=100)

plt.ylabel('SENTIMENT')
plt.xlabel('General_performance_score')

plt.scatter(y=df['sent'], x=df['General_performance_score'], c=df['sent'], cmap='RdYlGn')

#%%     # Explore correlations between Sentiment and character count

plt.figure(figsize=(14, 7),dpi=100)

plt.xlabel('SENTIMENT')
plt.ylabel('CHARACTERS')

plt.scatter(x=df['sent'], y=df['Employee_feedback_car_count'], c=df['sent'], cmap='RdYlGn')

#%%     # Order Feedback words by Frequency

print(df_freq.sort_values(by='frequency', ascending=False))

#%%     # Creating function to Categorize Sentiment Score

sent_categories = []

for row in df['sent']:
    if row > 0 : sent_categories.append('Positive')
    elif row == 0 : sent_categories.append('Neutral')
    elif row < 0 : sent_categories.append('Negative')
    else : sent_categories.append('Not_Rated_No_Text')
    
#%%     # Store result in new column

df['sent_categories'] = sent_categories

        # Verify
        
print(df['sent_categories'])

#%%     # Visualize Data using Sentiment Categories

        # Count Feedbacks by Category

plt.figure(figsize=(12, 8))
sns.countplot(x='sent_categories',data=df,palette=['tab:green', 'tab:blue', 'tab:red','tab:gray'],saturation=1,order=df['sent_categories'].value_counts().index)
plt.title('Feedbacks by Category')

#%%     # Count Sentiment by Leader

plt.figure(figsize=(15, 6))
chart = sns.countplot(x='Appraiser_name',data=df,hue='sent_categories',palette=['tab:red', 'tab:blue', 'tab:green', 'tab:gray'], saturation=1,order=df['Appraiser_name'].value_counts().index)

chart.set_xticklabels(chart.get_xticklabels(), rotation=45, horizontalalignment='right')

plt.title('Sentiment by Leader')

#%%     # Export File with new Dataset including Clean Data and Sentiment Analysis

export_excel = df.to_excel (r'D:\Hogar\Descargas\NLP-Processed-Dataset.xlsx', index = None, header=True)