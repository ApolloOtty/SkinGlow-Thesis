import mysql.connector
import bcrypt
from flask import Flask, request, jsonify, abort
# Connect to the MySQL database
mydb = mysql.connector.connect(
    host="localhost",
    user="root",
    password="",
    database="skinglow",
    )    

def login(username, password):
    cursor = mydb.cursor()

    query = f"SELECT * FROM user WHERE email='{username}'"
    cursor.execute(query)
    
    row = cursor.fetchone()
    if row is None:
        print("Invalid username or password.")
        cursor.close()
        return None
    else:
        print(row)
        user_id = row[6]
        print(user_id)
        hashed_password = get_hashed_password(username)
        if bcrypt.checkpw(password.encode('utf-8'), hashed_password.encode('utf-8')):
            print("Login successful!")
            cursor.close()
            return user_id
        else:
            print("Invalid username or password.")
            cursor.close()
            return None


def register(username, password):
    cursor = mydb.cursor()

    query = f"SELECT email FROM user WHERE email='{username}'"
    cursor.execute(query)
    result = cursor.fetchone()
    if result is not None:
        print("User already exists in the database.")
        abort(409, "User already exists in the database.")
        return None
    
    salt = bcrypt.gensalt()

    try:
        hashed_password = bcrypt.hashpw(password.encode('utf-8'), salt)
        hashed_password_str = hashed_password.decode('utf-8')

        query = f"INSERT INTO user (email, password) VALUES ('{username}', '{hashed_password_str}')"
        cursor.execute(query)
        mydb.commit()

        user_id = cursor.lastrowid  # Get the ID of the last inserted row

        print("User registered successfully!")

        return user_id

    except ValueError as e:
        if str(e) == "Invalid salt":
            salt = bcrypt.gensalt()
            hashed_password = bcrypt.hashpw(password.encode('utf-8'), salt)
            hashed_password_str = hashed_password.decode('utf-8')

            query = f"INSERT INTO user (email, password, country) VALUES ('{username}', '{hashed_password_str}')"
            cursor.execute(query)

            mydb.commit()
            user_id = cursor.lastrowid  # Get the ID of the last inserted row
            print("User registered successfully with new salt and hashed password.")

            return user_id

        else:
            print("An error occurred while registering the user:", e)
            return None

    finally:
        # Close the cursor
        cursor.close()




def get_hashed_password(username):
    cursor = mydb.cursor()

    
    query = "SELECT password FROM user WHERE email = %s"
    cursor.execute(query, (username,))
    result = cursor.fetchone()

    cursor.close()
  
    if result is not None:
        print("Password found")
        return result[0]
       
    else:
        print("User not found")
        return None 
    

def close_connection():
  
    global mydb
    mydb.close()
    mydb = None