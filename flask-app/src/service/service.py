########################################################
# Sample customers blueprint of endpoints
# Remove this file if you are not using it in your project
########################################################

from flask import Blueprint, request, jsonify, make_response, current_app
import json
from src import db


service = Blueprint('service', __name__)

# Get all the service from the database
@service.route('/service', methods=['GET'])
def get_service():
    # get a cursor object from the database
    cursor = db.get_db().cursor()

    # use cursor to query the database for a list of service
    cursor.execute('SELECT * FROM Service')

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

@service.route('/service/<id>', methods=['GET'])
def get_service_detail (id):

    query = 'SELECT * FROM Service WHERE ServiceID = ' + str(id)
    current_app.logger.info(query)

    cursor = db.get_db().cursor()
    cursor.execute(query)
    column_headers = [x[0] for x in cursor.description]
    json_data = []
    the_data = cursor.fetchall()
    for row in the_data:
        json_data.append(dict(zip(column_headers, row)))
    return jsonify(json_data)

@service.route('/service', methods=['PUT'])
def update_service():
    cursor = db.get_db().cursor()
    rep_info = request.json
        # current_app.logger.infor(cust_info)
    endTime = rep_info['EndTime']
    ServiceID = rep_info['ServiceID']
    cursor.execute('''
        UPDATE Service
        SET EndTime = %s
        WHERE ServiceID = %s
        ''', (endTime, ServiceID))
    db.get_db().commit()
    return 'updated'
    
