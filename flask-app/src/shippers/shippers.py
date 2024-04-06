########################################################
# Sample customers blueprint of endpoints
# Remove this file if you are not using it in your project
########################################################

from flask import Blueprint, request, jsonify, make_response, current_app
import json
from src import db


shippers = Blueprint('shippers', __name__)

# Get all the shippers from the database
@shippers.route('/shippers', methods=['GET'])
def get_shippers():
    # get a cursor object from the database
    cursor = db.get_db().cursor()

    # use cursor to query the database for a list of shippers
    cursor.execute('SELECT CompanyName, Rating, CompanyAddress FROM Shippers')

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

@shippers.route('/shippers/<name>', methods=['GET'])
def get_shipper_detail (name):

    query = 'SELECT CompanyName, Rating, CompanyAddress FROM Shippers WHERE CompanyName = ' + str(name)
    current_app.logger.info(query)

    cursor = db.get_db().cursor()
    cursor.execute(query)
    column_headers = [x[0] for x in cursor.description]
    json_data = []
    the_data = cursor.fetchall()
    for row in the_data:
        json_data.append(dict(zip(column_headers, row)))
    return jsonify(json_data)
    


@shippers.route('/shippers', methods=['POST'])
def add_new_shipper():
    
    # collecting data from the request object 
    the_data = request.json
    current_app.logger.info(the_data)

    #extracting the variable
    name = the_data['CompanyName']
    rating = the_data['Rating']
    address = the_data['CompanyAddress']

    # Constructing the query
    query = 'insert into shippers (CompanyName, Rating, CompanyAddress) values ("'
    query += name + '", "'
    query += rating + '", '
    query += address + ')'
    current_app.logger.info(query)

    # executing and committing the insert statement 
    cursor = db.get_db().cursor()
    cursor.execute(query)
    db.get_db().commit()
    
    return 'Success!'