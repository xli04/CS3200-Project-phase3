########################################################
# Sample customers blueprint of endpoints
# Remove this file if you are not using it in your project
########################################################

from flask import Blueprint, request, jsonify, make_response, current_app
import json
from src import db


orders = Blueprint('orders', __name__)

# Get all the orders from the database
@orders.route('/order', methods=['GET'])
def get_orders():
    # get a cursor object from the database
    cursor = db.get_db().cursor()

    # use cursor to query the database for a list of orders
    cursor.execute('SELECT OrderID, Cost, PlacedTime, Status FROM Orders')

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

@orders.route('/order/<id>', methods=['GET'])
def get_order_detail (id):

    query = 'SELECT OrderID, Cost, PlacedTime, Status FROM Orders WHERE OrderID = ' + str(id)
    current_app.logger.info(query)

    cursor = db.get_db().cursor()
    cursor.execute(query)
    column_headers = [x[0] for x in cursor.description]
    json_data = []
    the_data = cursor.fetchall()
    for row in the_data:
        json_data.append(dict(zip(column_headers, row)))
    return jsonify(json_data)
    


@orders.route('/order', methods=['POST'])
def add_new_order():
    
    # collecting data from the request object 
    the_data = request.json
    current_app.logger.info(the_data)

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
    current_app.logger.info(query)

    # executing and committing the insert statement 
    cursor = db.get_db().cursor()
    cursor.execute(query)
    db.get_db().commit()
    
    return 'Success!'