from flask import request, jsonify
from flask_cors import CORS
import regex as re

# Use the connection pool created in the app
mydb = None

def decode_ingredients():
    data = request.json
    # Get the string from the request
    ingredient_string = data['ingredients']
    
    # Remove parentheses and their contents
    ingredient_string = re.sub(r'\([^)]*\)', '', ingredient_string)
    
    # Remove hyphens at line breaks
    ingredient_string = re.sub(r'(\w)-\n(\w)', r'\1\2', ingredient_string)
    
    # Replace line breaks with spaces
    ingredient_string = ingredient_string.replace('\n', ' ')

    ingredient_string = ingredient_string.replace('.', ',')
    
    # Merge words split across lines with hyphens
    ingredient_string = re.sub(r'(\w+-)\s*\n\s*(\w+)', r'\1\2', ingredient_string)
    
    # Split the string into individual ingredients using regular expressions
    ingredients = re.split(r', (?=\d)|, |, (?=\w+\.?$)', ingredient_string)

    # Prepare the response dictionary to maintain the order
    response = {ingredient: None for ingredient in ingredients}

    # Create a connection from the pool
    dbconn = mydb.get_connection()

    # Create a cursor
    cursor = dbconn.cursor(dictionary=True)

    # Prepare the query to get ingredient details for all ingredients
    query = """
    SELECT i.*, n.oily_skin, n.dry_skin, n.acne_prone_skin, n.sensitive_skin, n.fungal_acne, 
           n.anti_aging, n.wound_heal, n.brightening, n.antioxidant 
    FROM ingredients i
    LEFT JOIN ingredient_notes n ON i.ingredient_id = n.ingredient_id
    WHERE i.name IN ({})
    ORDER BY FIELD(i.name, {})
    """.format(
        ', '.join(['%s'] * len(ingredients)),
        ', '.join(['%s'] * len(ingredients))
    )

    # Execute the query with the ingredients list
    cursor.execute(query, ingredients + ingredients)

    # Fetch all results
    results = cursor.fetchall()

    # Process each result
    for result in results:
        ingredient = result['name']
        ingredient_info = {
            'Function': result['Function']
        }
        
        # Add additional properties if they are not null
        if result['oily_skin'] is not None:
            ingredient_info['oily_skin'] = result['oily_skin']
        if result['dry_skin'] is not None:
            ingredient_info['dry_skin'] = result['dry_skin']
        if result['acne_prone_skin'] is not None:
            ingredient_info['acne_prone_skin'] = result['acne_prone_skin']
        if result['sensitive_skin'] is not None:
            ingredient_info['sensitive_skin'] = result['sensitive_skin']
        if result['fungal_acne'] is not None:
            ingredient_info['fungal_acne'] = result['fungal_acne']
        if result['anti_aging'] is not None:
            ingredient_info['anti_aging'] = result['anti_aging']
        if result['wound_heal'] is not None:
            ingredient_info['wound_heal'] = result['wound_heal']
        if result['brightening'] is not None:
            ingredient_info['brightening'] = result['brightening']
        if result['antioxidant'] is not None:
            ingredient_info['antioxidant'] = result['antioxidant']
            
        response[ingredient] = ingredient_info

    # Close the cursor and connection
    cursor.close()
    dbconn.close()
    
    # Filter out any ingredients that were not found in the database
    response = {k: v for k, v in response.items() if v is not None}

    print(response)
    # Return the response as JSON
    return jsonify(response)



def viewIngredient(ingredient):
    try:
        dbconn = mydb.get_connection()

        # Create a cursor
        cursor = dbconn.cursor(dictionary=True)
        query = """SELECT Description from ingredients WHERE name LIKE %s OR name = %s 
                   ORDER BY CASE WHEN name = %s THEN 0 ELSE 1 END 
                   LIMIT 1"""

        cursor.execute(query, ('%' + ingredient.strip(), ingredient.strip(), ingredient.strip(),))
        
        # Fetch the result
        result = cursor.fetchone()


        if result:
            description = result['Description']
            return f"{description}"
        else:
            return f"No information found for {ingredient}"
    except Exception as e:
        return f"An error occurred: {str(e)}"
    finally:
        # Close the cursor and database connection
        cursor.close()
        dbconn.close()



def fetchIngredients():
    try:
        page = request.args.get('page', default=1, type=int)
        page_size = request.args.get('page_size', default=10, type=int)  # Adjust as needed

        dbconn = mydb.get_connection()
        cursor = dbconn.cursor()
        cursor.execute("SELECT name FROM ingredients LIMIT %s OFFSET %s", (page_size, (page-1)*page_size))
        results = cursor.fetchall()
        ingredients = [result[0] for result in results]
        cursor.close()
        dbconn.close()
        return jsonify(ingredients)
    except Exception as e:
        return f"An error occurred: {str(e)}"