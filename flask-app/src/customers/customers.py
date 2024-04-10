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
    print("Reached GET")
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
    
    query = 'UPDATE customers SET UserName = %s, PassWord = %s, Email = %s, Address = %s where id = %s'
    data = (username, password,email,address,cust_id)
    cursor = db.get_db().cursor()
    r = cursor.execute(query,data)
    db.get_db().commit()
    return 'customer updated!'


# Get customer detail for customer with particular userID
@customers.route('/customers/<userID>', methods=['GET'])
def get_customer(userID):
    cursor = db.get_db().cursor()
    cursor.execute('select * from customers where id = {0}'.format(userID))
    row_headers = [x[0] for x in cursor.description]
    json_data = []
    theData = cursor.fetchall()
    for row in theData:
        json_data.append(dict(zip(row_headers, row)))
    the_response = make_response(jsonify(json_data))
    the_response.status_code = 200
    the_response.mimetype = 'application/json'
    return the_response

# Get representative assigned to the customer
@customers.route('/customers/rep/<ID>', methods=['GET'])
def get_customer_rep_info(userID):
    cursor = db.get_db().cursor()
    cursor.execute('select * from customers where id = {0}'.format(userID))
    row_headers = [x[0] for x in cursor.description]
    json_data = []
    theData = cursor.fetchall()
    for row in theData:
        json_data.append(dict(zip(row_headers, row)))
    the_response = make_response(jsonify(json_data))
    the_response.status_code = 200
    the_response.mimetype = 'application/json'
    return the_response