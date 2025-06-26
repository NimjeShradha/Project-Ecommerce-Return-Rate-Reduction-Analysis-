import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LogisticRegression
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import classification_report

df = pd.read_csv('flipkart_clean.csv')

# Return Rate by Category
print("Return % by Category:")
print(df.groupby('Category')['Return_Risk'].mean().sort_values(ascending=False) * 100)

# Return Rate by State
print("\nReturn % by State:")
print(df.groupby('State')['Return_Risk'].mean().sort_values(ascending=False) * 100)

# Return Rate by Company (Supplier)
print("\nReturn % by Company:")
print(df.groupby('Company')['Return_Risk'].mean().sort_values(ascending=False) * 100)

#Predictive Model (Logistic Regression)
# Select features
features = ['Category', 'Company', 'Product_Price', 'Quantity', 'Customer_Age',
            'Customer_Gender', 'State', 'Product_Rating', 'Shipping_Mode', 'Payment_Method', 'Discount_Applied']
target = 'Return_Risk'

# Encode categorical variables
df_encoded = pd.get_dummies(df[features], drop_first=True)
X = df_encoded
y = df[target]

# Train/Test split
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Scaling numeric features
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)

# Train model
model = LogisticRegression(max_iter=1000,class_weight='balanced')
model.fit(X_train_scaled, y_train)
y_pred = model.predict(X_test_scaled)

# Evaluate model
print("\nModel Performance:")
print(classification_report(y_test, y_pred))

# Predict return probability
df['Return_Risk'] = model.predict_proba(scaler.transform(X))[:, 1]

# Flag high risk (adjust threshold if needed)
df['High_Risk'] = df['Return_Risk'].apply(lambda x: 1 if x > 0.5 else 0)

# Export high-risk products
df[df['High_Risk'] == 1].to_csv('High_Risk_Products.csv', index=False)
print("\nHigh_Risk_Products.csv exported.")
