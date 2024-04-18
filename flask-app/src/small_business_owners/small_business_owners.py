########################################################
# Sample customers blueprint of endpoints
# Remove this file if you are not using it in your project
########################################################

from flask import Blueprint, request, jsonify, make_response, current_app
import json
from src import db


sbs = Blueprint('sbs', __name__)

# Get all the sbs from the database
@sbs.route('/sbs', methods=['GET'])
def get_sbs():
    # get a cursor object from the database
    cursor = db.get_db().cursor()

    # use cursor to query the database for a list of sbs
    cursor.execute('SELECT * FROM Small_Business_Seller')

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

# selects the business owner based on the businessID
@sbs.route('/sbs/<id>', methods=['GET'])
def get_business_detail (id):

    query = 'SELECT * FROM Small_Business_Seller WHERE BusinessID = ' + str(id)
    current_app.logger.info(query)

    cursor = db.get_db().cursor()
    cursor.execute(query)
    column_headers = [x[0] for x in cursor.description]
    json_data = []
    the_data = cursor.fetchall()
    for row in the_data:
        json_data.append(dict(zip(column_headers, row)))
    return jsonify(json_data)
    

# Get all products from a particular businessID
@sbs.route('/sbs/product/<id>', methods=['GET'])
def get_sbs_products(id):
    cursor = db.get_db().cursor()

    cursor.execute('''
                SELECT ProductName, ProductionDescription, Price, UnitsInStock, UnitsSold, OnSale, ProductID
                FROM Small_Business_Seller NATURAL JOIN Products
                WHERE Small_Business_Seller.BusinessID = {0}
                '''.format(id))
        
    row_headers = [x[0] for x in cursor.description]
    json_data = []
    theData = cursor.fetchall()
    for row in theData:
        json_data.append(dict(zip(row_headers, row)))
    the_response = make_response(jsonify(json_data))
    the_response.status_code = 200
    the_response.mimetype = 'application/json'
    return the_response

# Inserts (puts) product detail for owners with particular businessID
@sbs.route('/sbs/product/', methods=['POST'])
def add_sbs_products():
    cursor = db.get_db().cursor()
    
    the_data = request.json

    #extracting the variable
    product_name = the_data['ProductName']
    price = the_data['Price']
    units_in_stock = the_data['UnitsInStock']
    description = the_data['ProductionDescription']
    on_sale = the_data['OnSale']
    BusinessID = the_data['BusinessID']
    # Constructing the query
    query = '''
    INSERT INTO Products(ProductName, Price, UnitsInStock, ProductionDescription, UnitsSold, OnSale, BusinessID)
    VALUES (%s, %s, %s, %s, %s, %s, %s)    
    '''
    cursor.execute(query, (product_name, price, units_in_stock, description,0, on_sale, BusinessID))
    db.get_db().commit()
    
    return "product added"

# Updates product detail for owners with particular businessID
@sbs.route('/sbs/product/', methods=['PUT'])
def update_sbs_products():
    cursor = db.get_db().cursor()
    
    the_data = request.json

    #extracting the variable
    product_id = the_data['ProductID']
    price = the_data['Price']
    units_in_stock = the_data['UnitsInStock']
    description = the_data['ProductionDescription']
    units_sold = the_data['UnitsSold']
    on_sale = the_data['OnSale']

    # Constructing the query
    query = '''
    UPDATE Products
    SET Price = %s, UnitsInStock = %s, ProductionDescription = %s, UnitsSold = %s, OnSale = %s
    WHERE ProductID = %s    
    '''
    cursor.execute(query, (price, units_in_stock, description, units_sold, on_sale, product_id)) #Executing Cursor Object Query
    db.get_db().commit()
    
    return "product updated"

# Inserts a new business into the database
@sbs.route('/sbs/', methods=['POST'])
def add_new_business():
    
    # collecting data from the request object 
    the_data = request.json
    current_app.logger.info(the_data)

    #extracting the variable
    bus_id = the_data['BusinessID']
    username = the_data['UserName']
    password = the_data['PassWord']
    email = the_data['Email']
    profile = the_data['Profile']

    # Constructing the query
    query = '''
    INSERT INTO Small_Business_Seller
    (UserName, PassWord, Email, Profile)
    VALUES (%s, %s, %s, %s)    
    '''
    current_app.logger.info(query)

    # executing and committing the insert statement 
    cursor = db.get_db().cursor()
    cursor.execute(query, (username, password, email, profile))
    db.get_db().commit()
    
    return 'Success!'

# Updates a business in the database
@sbs.route('/sbs/', methods=['PUT'])
def update_business():
    
    # collecting data from the request object 
    the_data = request.json
    current_app.logger.info(the_data)

    #extracting the variable
    # bus_id = the_data['BusinessID']
    username = the_data['UserName']
    password = the_data['PassWord']
    email = the_data['Email']
    profile = the_data['Profile']
    businessID = the_data['BusinessID']

    # Constructing the query
    query = '''
    UPDATE Small_Business_Seller
        SET UserName = %s,
        PassWord = %s,
        Email = %s,
        Profile = %s
    WHERE BusinessID = %s
    '''
    current_app.logger.info(query)

    # executing and committing the insert statement 
    cursor = db.get_db().cursor()
    cursor.execute(query, (username, password, email, profile, businessID))
    db.get_db().commit()
    
    return 'Success!'

# gets the bank account for based of a specific small business owner ID
@sbs.route('/sbs/account/<id>', methods=['GET'])
def get_sbs_account(id):
    cursor = db.get_db().cursor()
    cursor.execute('''
                SELECT *
                FROM BankAccount
                WHERE OwnerID = {0}
                '''.format(id))
        
    row_headers = [x[0] for x in cursor.description]
    json_data = []
    theData = cursor.fetchall()
    for row in theData:
        json_data.append(dict(zip(row_headers, row)))
    the_response = make_response(jsonify(json_data))
    the_response.status_code = 200
    the_response.mimetype = 'application/json'
    return the_response

# Adds a bank account for a small business owner based off it's ownerID
@sbs.route('/sbs/account/', methods=['POST'])
def add_sbs_account():
    cursor = db.get_db().cursor()
    
    the_data = request.json

    #extracting the variable
    acc_num = the_data['AccountNumber']
    bank_name = the_data['BankName']
    bill = the_data['BillingAddress']
    owner_id = the_data['OwnerID']
    # Constructing the query
    query = '''
    INSERT INTO commerce.BankAccount (AccountNumber, BankName, BillAddress, OwnerID)
    VALUES (%s, %s, %s, %s)    
    '''
    cursor.execute(query, (acc_num, bank_name, bill, owner_id))
    db.get_db().commit()
    
    return "product added"

# Deletes a bank account for a small business owner
@sbs.route('/sbs/account/', methods=['DELETE'])
def delete_sbs_account():
    cursor = db.get_db().cursor()
    acc_info = request.json
    ownerID = acc_info['OwnerID']
    acc_num = acc_info['AccountNumber']
    cursor.execute('''DELETE 
                    FROM BankAccount 
                    WHERE OwnerID = %s and AccountNumber = %s
                    ''',(ownerID, acc_num))
    db.get_db().commit()
    return 'deleted'
