########################################################
# Sample customers blueprint of endpoints
# Remove this file if you are not using it in your project
########################################################

from flask import Blueprint, request, jsonify, make_response, current_app
import json
from src import db


orderdetails = Blueprint('orderdetails', __name__)

# Get all the orderdetails from the database
@orderdetails.route('/orderdetails', methods=['GET'])
def get_orderdetails():
    # get a cursor object from the database
    cursor = db.get_db().cursor()

    # use cursor to query the database for a list of orderdetails
    cursor.execute('SELECT * FROM OrderDetails')

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

@orderdetails.route('/orderdetails/<id>', methods=['GET'])
def get_details (id):

    query = 'SELECT * FROM OrderDetails WHERE OrderID = ' + str(id)
    current_app.logger.info(query)

    cursor = db.get_db().cursor()
    cursor.execute(query)
    column_headers = [x[0] for x in cursor.description]
    json_data = []
    the_data = cursor.fetchall()
    for row in the_data:
        json_data.append(dict(zip(column_headers, row)))
    return jsonify(json_data)
    
