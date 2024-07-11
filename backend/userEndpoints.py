from flask import request, jsonify
from flask_cors import CORS
import database_connection
from flask import abort
from datetime import datetime


# Use the connection pool created in the app
mydb = None

def login():
    
    data = request.json
    email = data['email']
    password = data['password']
    print(email, password)
    login_result = database_connection.login(email, password)
    print(login_result)
    if login_result != None:
         return jsonify({'userid': login_result})
    else:
        abort(409, "Email or password incorrect")


def register():
    data = request.json
    email = data['email']
    password = data['password']
    print(email, password)
    register_result = database_connection.register(email, password)
    print(register_result)
    if register_result != None:
         return jsonify({'userid':register_result})
    

def addName():
    try:
        dbconn = mydb.get_connection()  # Assuming mydb is the database connection object

        # Obtain cursor from the database connection
        cur = dbconn.cursor()

        data = request.json
        # Get the name from the request
        name = data['name']
        userid = data['userid']
        # Debugging: Print the received name
        print('Received name:', name)
        print('Received userid:', userid)

        # Execute SQL query to insert username into the "name" column of the "user" table
        sql = "UPDATE user SET name = %s WHERE user_id = %s" 
        cur.execute(sql, (name, userid))
        # Commit the transaction
        dbconn.commit()

        # Close the cursor
        cur.close()

        # Return success message
        return "Username added successfully to the database."

    except Exception as e:
        # Rollback the transaction in case of an error
        dbconn.rollback()
        # Debugging: Print the error message
        print('Error:', e)
        return f"An error occurred: {str(e)}"
    
def addDob():
    try:
        # Connect to the database
        conn = mydb.get_connection()  # Assuming mydb is the database connection object

        # Obtain cursor from the database connection
        cur = conn.cursor()

        # Get the date of birth from the request
        dob = request.json['dob']
        userid=request.json['userid']
        # Parse the date string to a datetime object
        print(dob)
        dob_date = datetime.strptime(dob.split()[0], '%Y-%m-%d')
        print(dob_date)
        # Execute SQL query to insert date of birth into the "dob" column of the "user" table
        sql = "UPDATE user SET dob = %s WHERE user_id = %s"
        cur.execute(sql, (dob_date, userid))


        # Commit the transaction
        conn.commit()

        # Close the cursor and connection
        cur.close()

        # Return success message
        return jsonify({'message': 'Date of birth added successfully to the database.'}), 200

    except Exception as e:
        # Rollback the transaction in case of an error
        conn.rollback()
        # Close the cursor and connection
        cur.close()
        conn.close()
        return jsonify({'error': f"An error occurred: {str(e)}"}), 500
    

def getUserInfo():
    cursor = None  # Initialize cursor outside the try block

    try:
        dbconn = mydb.get_connection()
        cursor = dbconn.cursor(dictionary=True)

        userid = request.args.get('userid')
        query = "SELECT name FROM user WHERE user_id = %s"
        cursor.execute(query, (userid,))

        user = cursor.fetchone()

        if user:
            return jsonify(user), 200
        else:
            return jsonify({'error': 'User not found'}), 404

    except Exception as e:
        return jsonify({'error': f"An error occurred: {str(e)}"}), 500


    finally:
        if cursor:  # Check if cursor is not None before closing
            cursor.close()
        if dbconn:  # Close the database connection if it's open
            dbconn.close()


def get_selected_banned_ingredients(user_id):
    try:
        db_conn = mydb.get_connection()
        cursor = db_conn.cursor()

        query = "SELECT i.name FROM ingredients i INNER JOIN banned_ingredients bi ON i.ingredient_id = bi.ingredient_id WHERE bi.user_id = %s"
        cursor.execute(query, (user_id,))

        selected_ingredients = [row[0] for row in cursor.fetchall()]

        return jsonify(selected_ingredients), 200
    except Exception as e:
        return f"An error occurred: {str(e)}", 500
    finally:
        cursor.close()
        db_conn.close()

def save_selected_banned_ingredients(user_id):
    try:
        data = request.json
        selected_ingredients_names = data.get('selectedIngredients', [])

        db_conn = mydb.get_connection()
        cursor = db_conn.cursor()

        # Clear previous selections for the user
        cursor.execute("DELETE FROM banned_ingredients WHERE user_id = %s", (user_id,))

        # Insert new selected ingredients
        for ingredient_name in selected_ingredients_names:
            # Get the ingredient_id for the selected ingredient
            cursor.execute("SELECT ingredient_id FROM ingredients WHERE name = %s", (ingredient_name,))
            result = cursor.fetchone()
            if result:
                ingredient_id = result[0]
                cursor.execute("INSERT INTO banned_ingredients (user_id, ingredient_id) VALUES (%s, %s)", (user_id, ingredient_id))

        db_conn.commit()

        return "Selected ingredients saved successfully", 200
    except Exception as e:
        db_conn.rollback()
        return f"An error occurred: {str(e)}", 500
    finally:
        cursor.close()
        db_conn.close()

def get_selected_loved_ingredients(user_id):
    try:
        db_conn = mydb.get_connection()
        cursor = db_conn.cursor()

        query = "SELECT i.name FROM ingredients i INNER JOIN loved_ingredients bi ON i.ingredient_id = bi.ingredient_id WHERE bi.user_id = %s"
        cursor.execute(query, (user_id,))

        selected_ingredients = [row[0] for row in cursor.fetchall()]

        return jsonify(selected_ingredients), 200
    except Exception as e:
        return f"An error occurred: {str(e)}", 500
    finally:
        cursor.close()
        db_conn.close()

def save_selected_loved_ingredients(user_id):
    try:
        data = request.json
        selected_ingredients_names = data.get('selectedIngredients', [])

        db_conn = mydb.get_connection()
        cursor = db_conn.cursor()

        # Clear previous selections for the user
        cursor.execute("DELETE FROM loved_ingredients WHERE user_id = %s", (user_id,))

        # Insert new selected ingredients
        for ingredient_name in selected_ingredients_names:
            # Get the ingredient_id for the selected ingredient
            cursor.execute("SELECT ingredient_id FROM ingredients WHERE name = %s", (ingredient_name,))
            result = cursor.fetchone()
            if result:
                ingredient_id = result[0]
                cursor.execute("INSERT INTO loved_ingredients (user_id, ingredient_id) VALUES (%s, %s)", (user_id, ingredient_id))

        db_conn.commit()

        return "Selected ingredients saved successfully", 200
    except Exception as e:
        db_conn.rollback()
        return f"An error occurred: {str(e)}", 500
    finally:
        cursor.close()
        db_conn.close()

def updateSkinProfile():
    try:
        dbconn = mydb.get_connection()  # Assuming mydb is the database connection object

        # Obtain cursor from the database connection
        cur = dbconn.cursor()

        data = request.json
        # Get the skin profile details from the request
        oily = data['oily']
        dry = data['dry']
        normal = data['normal']
        combination = data['combination']
        sensitivity = data['sensitivity']
        tone = data['tone']
        occasional_breakout = data['occasional_breakout']
        congested = data['congested']
        clear = data['clear']
        userid = data['userid']

        # Execute SQL query to update the user's skin profile in the "user" table
        sql = """UPDATE user 
                 SET oily = %s, dry = %s, normal = %s, combination = %s,
                     sensitivity = %s, tone = %s,
                     occasional_breakout = %s, congested = %s, clear = %s
                 WHERE user_id = %s"""
        cur.execute(sql, (oily, dry, normal, combination, sensitivity, tone, occasional_breakout, congested, clear, userid))
        # Commit the transaction
        dbconn.commit()

        # Close the cursor
        cur.close()

        # Return success message
        return "Skin profile updated successfully in the database."

    except Exception as e:
        # Rollback the transaction in case of an error
        dbconn.rollback()
        # Debugging: Print the error message
        print('Error:', e)
        return f"An error occurred: {str(e)}"


def getSkinProfile():
    try:
        dbconn = mydb.get_connection()
        cur = dbconn.cursor(dictionary=True)

        data = request.json
        userid = data['userid']

        sql = "SELECT oily, dry, normal, combination, sensitivity, tone, occasional_breakout, congested, clear FROM user WHERE user_id = %s"
        cur.execute(sql, (userid,))
        result = cur.fetchone()

        cur.close()
        dbconn.close()

        if result:
            return jsonify(result)
        else:
            return "No data found for the user.", 404

    except Exception as e:
        print('Error:', e)
        return f"An error occurred: {str(e)}", 500

def getUserInsights(user_id):
    try:
        dbconn = mydb.get_connection()
        cur = dbconn.cursor(dictionary=True)

        # Fetch user profile
        user_sql = """
        SELECT oily, dry, normal, combination, sensitivity, tone, occasional_breakout, congested, clear 
        FROM user WHERE user_id = %s
        """
        cur.execute(user_sql, (user_id,))
        user_profile = cur.fetchone()

        if not user_profile:
            return "No data found for the user.", 404

        # Determine user skin types
        conditions = []
        if user_profile['oily']:
            conditions.append("oily = 1")
        if user_profile['dry']:
            conditions.append("dry = 1")
        if user_profile['occasional_breakout'] or user_profile['congested']:
            conditions.append("acne = 1")
        if user_profile['tone']:
            conditions.append("uneven_tone = 1")
        if user_profile['sensitivity']:
            conditions.append("'sensitive' = 1")
        if user_profile['normal'] or user_profile['combination'] or user_profile['clear']:
            conditions.append("balanced = 1")

        # Include general insights for everyone
        conditions.append("general = 1")

        conditions_sql = " OR ".join(conditions)

        # Fetch 3 random insights based on user profile
        insights_sql = f"""
        SELECT insight_id, title, text FROM insights WHERE {conditions_sql} ORDER BY RAND() LIMIT 3
        """
        print(insights_sql)
        cur.execute(insights_sql)
        insights = cur.fetchall()

        cur.close()
        dbconn.close()

        return jsonify(insights)

    except Exception as e:
        print('Error:', e)
        return f"An error occurred: {str(e)}", 500


def getAllUserInsights():
    try:
        dbconn = mydb.get_connection()
        cur = dbconn.cursor(dictionary=True)

        # Fetch all insights regardless of user profile
        insights_sql = """
        SELECT insight_id, title, text FROM insights
        """
        cur.execute(insights_sql)
        insights = cur.fetchall()

        cur.close()
        dbconn.close()

        return jsonify(insights)

    except Exception as e:
        print('Error:', e)
        return f"An error occurred: {str(e)}", 500