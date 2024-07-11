from flask import Flask
from flask_cors import CORS
import mysql.connector
import os
import userEndpoints
import ingredientsEndpoints
import melanom_rec

app = Flask(__name__)
UPLOAD_FOLDER = 'uploads/'
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)
CORS(app)

app.json.sort_keys = False

try:
    mydb = mysql.connector.pooling.MySQLConnectionPool(
        pool_name="my_pool",
        pool_size=32,
        user='root',
        password='', 
        host='localhost',
        database='skinglow'
    )
except mysql.connector.Error as e:
    print("MySQL connection pool error:", e)

# Inject the database connection pool into the endpoints
userEndpoints.mydb = mydb
ingredientsEndpoints.mydb = mydb

#User focused endpoints
app.add_url_rule('/login', view_func=userEndpoints.login, methods=['POST'])

app.add_url_rule('/register', view_func=userEndpoints.register, methods=['POST'])

app.add_url_rule('/postname', view_func=userEndpoints.addName, methods=['POST'])

app.add_url_rule('/postdob', view_func=userEndpoints.addDob, methods=['POST'])

app.add_url_rule('/getuserinfo', view_func=userEndpoints.getUserInfo, methods=['GET'])

app.add_url_rule('/updateSkinProfile', view_func=userEndpoints.updateSkinProfile, methods=['POST'])

app.add_url_rule('/getSkinProfile', view_func=userEndpoints.getSkinProfile, methods=['POST'])

app.add_url_rule('/getAllUserInsights', view_func=userEndpoints.getAllUserInsights, methods=['GET'])

@app.route('/user/<int:user_id>/getUserInsights', methods=['GET'])
def getUserInsights(user_id):
    return userEndpoints.getUserInsights(user_id)

@app.route('/user/<int:user_id>/selectedBannedIngredients', methods=['GET'])
def get_selected_banned_ingredients_route(user_id):
    return userEndpoints.get_selected_banned_ingredients(user_id)

@app.route('/user/<int:user_id>/selectedBannedIngredients', methods=['POST'])
def save_selected_banned_ingredients(user_id):
    return userEndpoints.save_selected_banned_ingredients(user_id)

@app.route('/user/<int:user_id>/selectedLovedIngredients', methods=['GET'])
def get_selected_loved_ingredients(user_id):
    return userEndpoints.get_selected_loved_ingredients(user_id)

@app.route('/user/<int:user_id>/selectedLovedIngredients', methods=['POST'])
def save_selected_loved_ingredients(user_id):
    return userEndpoints.save_selected_loved_ingredients(user_id)

#Ingredients focused endpoints
app.add_url_rule('/decode', view_func=ingredientsEndpoints.decode_ingredients, methods=['POST'])

@app.route('/viewingredient/<ingredient>', methods=['GET'])
def viewIngredient(ingredient):
    return ingredientsEndpoints.viewIngredient(ingredient)

app.add_url_rule('/fetchingredients', view_func=ingredientsEndpoints.fetchIngredients, methods=['GET'])
    
#CNN focused endpoint
app.add_url_rule('/evalimage', view_func=melanom_rec.evalimage, methods=['POST'])


if __name__ == '__main__':
    app.run(debug=True)