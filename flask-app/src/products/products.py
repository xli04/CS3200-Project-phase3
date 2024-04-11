########################################################
# Sample customers blueprint of endpoints
# Remove this file if you are not using it in your project
########################################################

from flask import Blueprint, request, jsonify, make_response, current_app
import json
from src import db


products = Blueprint('products', __name__)

# Get all the products from the database
@products.route('/products', methods=['GET'])
def get_products():
    # get a cursor object from the database
    cursor = db.get_db().cursor()

    # use cursor to query the database for a list of products
    cursor.execute('SELECT * FROM Products')

    # grab the column headers from the returned data
    column_headers = [x[0] for x in cursor.description]

    # create an empty dictionary object to use in 
    # putting column headers together with data
    json_data = []

    # fetch all the data from the cursor
    theData = cursor.fetchall()

    # for each of the rows, zip the data elements together with
    # the column headers. 
    for row in theData:
        json_data.append(dict(zip(column_headers, row)))

    return jsonify(json_data)

@products.route('/product/<id>', methods=['GET'])
def get_product_detail(id):

    query = 'SELECT * FROM Products WHERE ProductID = ' + str(id)
    current_app.logger.info(query)

    cursor = db.get_db().cursor()
    cursor.execute(query)
    column_headers = [x[0] for x in cursor.description]
    json_data = []
    the_data = cursor.fetchall()
    for row in the_data:
        json_data.append(dict(zip(column_headers, row)))
    return jsonify(json_data)
    
# Get products on sale
@products.route('/products/onsale', methods=['GET'])
def get_product_detail_onsale():

    query = '''
    SELECT * 
    FROM Products 
    WHERE OnSale = 1
    '''
    current_app.logger.info(query)

    cursor = db.get_db().cursor()
    cursor.execute(query)
    column_headers = [x[0] for x in cursor.description]
    json_data = []
    the_data = cursor.fetchall()
    for row in the_data:
        json_data.append(dict(zip(column_headers, row)))
    return jsonify(json_data)

@products.route('/product', methods=['POST'])
def add_new_product():
    
    # collecting data from the request object 
    the_data = request.json
    current_app.logger.info(the_data)

    #extracting the variable
    product_id = the_data['ProductID']
    product_name = the_data['ProductName']
    price = the_data['Price']
    units_in_stock = the_data['UnitsInStock']
    description = the_data['ProductionDescription']
    units_sold = the_data['UnitsSold']
    on_sale = the_data['OnSale']

    # Constructing the query
    query = '''
    INSERT INTO PRODUCTS(ProductName, Price, UnitsInStock, ProductionDescription, UnitsSold, OnSale)
    VALUES (%s, %s, %s, %s, %s, %s)    
    '''
    current_app.logger.info(query)

    # executing and committing the insert statement 
    cursor = db.get_db().cursor()
    cursor.execute(query, (product_name, price, units_in_stock, description, units_sold, on_sale, product_id))
    db.get_db().commit()
    
    return 'Success!'

@products.route('/product/<id>', methods=['PUT'])
def update_product(id):
    
    # collecting data from the request object 
    the_data = request.json
    current_app.logger.info(the_data)

    #extracting the variable
    # product_id = the_data['ProductID']
    price = the_data['Price']
    units_in_stock = the_data['UnitsInStock']
    product_name = the_data['ProductName']
    description = the_data['ProductionDescription']
    units_sold = the_data['UnitsSold']
    on_sale = the_data['OnSale']
    
    # Constructing the query
    query = f"""
        UPDATE Products
        SET ProductName = %s,
            Price = %s,
            UnitsInStock = %s,
            ProductDescription = %s,
            UnitsSold = %s,
            OnSale = %s
        WHERE ProductID = {id}
    """
    
    current_app.logger.info(query)

    # executing and committing the insert statement 
    cursor = db.get_db().cursor()
    cursor.execute(query, (product_name, price, units_in_stock, description, units_sold, on_sale))
    db.get_db().commit()
    
    return 'Success!'


@products.route('/product/<id>', methods=['DELETE'])
def delete_product(id):

    query = '''
    DELETE FROM Products
    WHERE ProductID = 
    ''' + str(id)
    current_app.logger.info(query)

    cursor = db.get_db().cursor()
    cursor.execute(query)
    column_headers = [x[0] for x in cursor.description]
    json_data = []
    the_data = cursor.fetchall()
    for row in the_data:
        json_data.append(dict(zip(column_headers, row)))
    return f'Product {id} was deleted :O'