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


@customers.route('/customers',methods=['PUT'])
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


# Get customer detail for customer with particular userID
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

# Get customer detail for customer with particular userID
@customers.route('/customers/cart/<id>', methods=['GET'])
def get_customer_cart(id):
    cursor = db.get_db().cursor()
    cursor.execute('''
                   SELECT * FROM 
                   Customers NATURAL JOIN Cart
                   WHERE Customer.CustomerID = {0}
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

# Get cart detail for customer with particular userID
@customers.route('/customers/cart/<id>', methods=['GET'])
def get_customer_cart(id):
    cursor = db.get_db().cursor()
    cursor.execute('''
                   SELECT * FROM 
                   Customers NATURAL JOIN Cart
                   WHERE Customer.CustomerID = {0}
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
@customers.route('/customers/card/<id>', methods=['GET'])
def get_customer_card(id):
    cursor = db.get_db().cursor()
    cursor.execute('''
                   SELECT * FROM 
                   Customers NATURAL JOIN Card
                   WHERE Customer.CustomerID = {0}
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

# Get shipping detail for customer with particular userID
@customers.route('/customers/shipping/<id>', methods=['GET'])
def get_customer_shipments(id):
    cursor = db.get_db().cursor()
    cursor.execute('''
                   SELECT Destination, Estimated_Shipping_Time, Actual_Shipping_Time, PackageSize
                   FROM Customers NATURAL JOIN Shipping_Detail
                   WHERE Customer.CustomerID = {0}
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
@customers.route('/customers/orders/<id>', methods=['GET'])
def get_customer_orders(id):
    cursor = db.get_db().cursor()
    cursor.execute('''
                   SELECT Status, Cost, PlacedTime 
                   FROM Shipping_Detail NATURAL JOIN Orders
                   WHERE Customer.CustomerID = {0}
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