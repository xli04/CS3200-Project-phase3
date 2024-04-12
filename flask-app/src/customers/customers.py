########################################################
# Sample customers blueprint of endpoints
# Remove this file if you are not using it in your project
########################################################
from flask import Blueprint, request, jsonify, make_response
import json
from src import db


customers = Blueprint('customers', __name__)

# Get all customers from the DB
@customers.route('/customers', methods=['GET'])
def get_customers():
    cursor = db.get_db().cursor()
    cursor.execute('select CustomerID, UserName, PassWord,\
        Email, Address from Customers')
    print("Statement executed")
    row_headers = [x[0] for x in cursor.description]
    json_data = []
    theData = cursor.fetchall()
    for row in theData:
        json_data.append(dict(zip(row_headers, row)))
    the_response = make_response(jsonify(json_data))
    the_response.status_code = 200
    the_response.mimetype = 'application/json'
    return the_response

@customers.route('/customers',methods=['POST'])
def add_customer():
    cust_info = request.json
    # current_app.logger.infor(cust_info)
    
    cust_id = cust_info['CustomerID']
    username = cust_info['UserName']
    password = cust_info['PassWord']
    email = cust_info['Email']
    address = cust_info['Address']
    
    query = '''
    INSERT INTO Customers 
    VALUES (%s,%s,%s,%s)
    '''
    
    data = (username, password,email,address)
    cursor = db.get_db().cursor()
    cursor.execute(query,data)
    db.get_db().commit()
    return 'customer aaddddeeed!'


@customers.route('/customers/<id>',methods=['PUT'])
def update_customer():
    cust_info = request.json
    # current_app.logger.infor(cust_info)
    cust_id = cust_info['CustomerID']
    username = cust_info['UserName']
    password = cust_info['PassWord']
    email = cust_info['Email']
    address = cust_info['Address']
    
    query = '''
    UPDATE Customers 
    SET UserName = %s, PassWord = %s, Email = %s, Address = %s 
    WHERE CustomerID = %s
    '''
    data = (username, password,email,address,cust_id)
    cursor = db.get_db().cursor()
    r = cursor.execute(query,data)
    db.get_db().commit()
    return 'customer updated!'

@customers.route('/customers/<userID>', methods=['GET'])
def get_customer(userID):
    cursor = db.get_db().cursor()
    cursor.execute('select * from Customers where CustomerID = {0}'.format(userID))
    row_headers = [x[0] for x in cursor.description]
    json_data = []
    theData = cursor.fetchall()
    for row in theData:
        json_data.append(dict(zip(row_headers, row)))
    the_response = make_response(jsonify(json_data))
    the_response.status_code = 200
    the_response.mimetype = 'application/json'
    return the_response

@customers.route('/customers/<userID>', methods=['DELETE'])
def delete_customer(userID):
    cursor = db.get_db().cursor()
    cursor.execute('''
                   DELETE FROM Customers where CustomerID = {0}
                   '''.format(userID))
    row_headers = [x[0] for x in cursor.description]
    json_data = []
    theData = cursor.fetchall()
    for row in theData:
        json_data.append(dict(zip(row_headers, row)))
    the_response = make_response(jsonify(json_data))
    the_response.status_code = 200
    the_response.mimetype = 'application/json'
    db.get_db().commit()
    return the_response

# Get customer detail for customer with particular userID
@customers.route('/customers/cart/<id>', methods=['GET'])
def get_customer_cart(id):
    cursor = db.get_db().cursor()
    cursor.execute('''
                   SELECT Products.*, Cart.*
                   FROM Cart NATURAL JOIN Product_In_Cart NATURAL JOIN Products
                   WHERE Cart.CustomerID = {0}
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


# Get card detail for customer with particular userID
@customers.route('/customers/card/<id>', methods=['GET','POST'])
def get_customer_card(id):
    cursor = db.get_db().cursor()
    if request.method == 'GET':
        cursor.execute('''
                    SELECT * 
                    FROM Customers NATURAL JOIN Card
                    WHERE Customers.CustomerID = {0}
                    '''.format(id))
    elif request.method == 'POST':
        card_info = request.json
        # current_app.logger.infor(cust_info)
        card_number = card_info['CardNumber']
        cus_id = card_info['CustomerID']
        exp_date = card_info['ExpirationDate']
        billing_address = card_info['BillingAddress']
        cursor.execute('''
                    INSERT INTO Card (CardNumber, CustomerID, ExpirationDate, BillingAddress)
                    VALUE (%s, %s, %s, %s)
                    ''',(card_number,id,exp_date,billing_address))
        db.get_db().commit()
        
    row_headers = [x[0] for x in cursor.description]
    json_data = []
    theData = cursor.fetchall()
    for row in theData:
        json_data.append(dict(zip(row_headers, row)))
    the_response = make_response(jsonify(json_data))
    the_response.status_code = 200
    the_response.mimetype = 'application/json'
    
    
    return the_response

@customers.route('/customers/cards/<customer_id>/<card_number>', methods=['PUT', 'DELETE'])
def handle_customer_card(customer_id, card_number):
    cursor = db.get_db().cursor()
    if request.method == 'PUT':
        # Update the card details for the given card number
        card_info = request.json
        exp_date = card_info['ExpirationDate']
        billing_address = card_info['BillingAddress']
        cursor.execute('''
            UPDATE Card
            SET ExpirationDate = %s, BillingAddress = %s
            WHERE CardNumber = %s AND CustomerID = %s
            ''', (exp_date, billing_address, card_number, customer_id))
        
    elif request.method == 'DELETE':
        # Delete the card with the given card number
        cursor.execute('''
            DELETE FROM Card
            WHERE CardNumber = %s AND CustomerID = %s
            ''', (card_number, customer_id))
        
    row_headers = [x[0] for x in cursor.description]
    json_data = []
    the_data = cursor.fetchall()
    for row in the_data:
        json_data.append(dict(zip(row_headers, row)))
    the_response = make_response(jsonify(json_data))
    the_response.status_code = 200
    the_response.mimetype = 'application/json'
    db.get_db().commit()
    return the_response

# Get shipping detail for customer with particular userID
@customers.route('/customers/shipping/<id>', methods=['GET'])
def get_customer_shipments(id):
    cursor = db.get_db().cursor()
    cursor.execute('''
                   SELECT Destination, Estimated_Shipping_Time, Actual_Shipping_Time, PackageSize
                   FROM Customers NATURAL JOIN Shipping_Detail
                   WHERE Customers.CustomerID = {0}
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

# Get orders detail for customer with particular userID
@customers.route('/customers/orders/<id>', methods=['GET', 'POST'])
def get_customer_orders(id):
    cursor = db.get_db().cursor()
    
    if request.method == 'GET':
        cursor.execute('''
                    SELECT Status, Cost, PlacedTime 
                    FROM Shipping_Detail NATURAL JOIN Orders
                    WHERE Customers.CustomerID = {0}
                    '''.format(id))
    elif request.method == 'POST':
        # collecting data from the request object 
        the_data = request.json

        #extracting the variable
        orderId = the_data['OrderID']
        cost = the_data['Cost']
        placedTime = the_data['PlacedTime']
        status = the_data['Status']
        address = the_data['ShippingAddress']

        # Constructing the query
        query = 'insert into Orders (CompanyName, Rating, CompanyAddress) values ("'
        query += orderId + '", "'
        query += cost + '", '
        query += placedTime + '", '
        query += status + '", '
        query += address + ')'
        
        cursor.execute(query)
        db.get_db().commit()
        
    row_headers = [x[0] for x in cursor.description]
    json_data = []
    theData = cursor.fetchall()
    for row in theData:
        json_data.append(dict(zip(row_headers, row)))
    the_response = make_response(jsonify(json_data))
    the_response.status_code = 200
    the_response.mimetype = 'application/json'
    return the_response