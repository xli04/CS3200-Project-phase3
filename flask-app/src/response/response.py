########################################################
# Sample customers blueprint of endpoints
# Remove this file if you are not using it in your project
########################################################

from flask import Blueprint, request, jsonify, make_response, current_app
import json
from src import db


response = Blueprint('response', __name__)

# Get all the response from the database
@response.route('/response', methods=['GET'])
def get_response():
    # get a cursor object from the database
    cursor = db.get_db().cursor()

    # use cursor to query the database for a list of response
    cursor.execute('SELECT * FROM Response')

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

@response.route('/response/<id>', methods=['GET'])
def get_response_detail (id):

    query = 'SELECT r.Contents, r.Type, r.ResponseID, r.ServiceID,r.RepID FROM Response r join Service s on r.ServiceID = s.ServiceID WHERE s.ServiceID = ' + str(id)
    current_app.logger.info(query)

    cursor = db.get_db().cursor()
    cursor.execute(query)
    column_headers = [x[0] for x in cursor.description]
    json_data = []
    the_data = cursor.fetchall()
    for row in the_data:
        json_data.append(dict(zip(column_headers, row)))
    return jsonify(json_data)
    
@response.route('/response', methods=['POST'])
def add_response():
    cursor = db.get_db().cursor()
    rep_info = request.json
        # current_app.logger.infor(cust_info)
    content = rep_info['CardNumber']
    type = rep_info['CustomerID']
    serviceID = rep_info['ExpirationDate']
    RepID = rep_info['BillingAddress']
    cursor.execute('''
                    INSERT INTO commerce.Response (Contents, Type, ServiceID, RepID)
                    VALUE (%s, %s, %s, %s)
                    ''',(content,type, serviceID, RepID))
    db.get_db().commit()
    return 'added'
