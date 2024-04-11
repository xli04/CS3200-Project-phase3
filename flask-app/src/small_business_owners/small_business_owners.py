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
    

# Get product detail for owners with particular businessID
@sbs.route('/sbs/product/<id>', methods=['GET'])
def get_sbs_products(id):
    cursor = db.get_db().cursor()
    cursor.execute('''
                   SELECT ProductName, ProductionDesciption, Price, UnitsInStock, UnitsSold, OnSale
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