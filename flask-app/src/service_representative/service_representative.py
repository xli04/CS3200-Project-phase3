########################################################
# Sample customers blueprint of endpoints
# Remove this file if you are not using it in your project
########################################################

from flask import Blueprint, request, jsonify, make_response, current_app
import json
from src import db


rep = Blueprint('rep', __name__)

# Get all the rep from the database
@rep.route('/rep', methods=['GET'])
def get_rep():
    # get a cursor object from the database
    cursor = db.get_db().cursor()

    # use cursor to query the database for a list of rep
    cursor.execute('SELECT * FROM ServiceRepresentative')

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

@rep.route('/rep/<id>', methods=['GET'])
def get_rep_detail (id):

    query = 'SELECT * FROM ServiceRepresentative WHERE EmployeeID = ' + str(id)
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
@rep.route('/rep/all_services/<id>', methods=['GET'])
def get_rep_responses(id):
    cursor = db.get_db().cursor()
    cursor.execute('''
                   SELECT Response.Contents, Response.Type AS ResponseType, Service.Type AS ServiceType,
                   Description, StartTime, EndTime  
                   FROM Service NATURAL JOIN Response
                   WHERE Response.RepID  = {0}
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



# Gets that specific service
@rep.route('/rep/service/<service_id>/', methods=['GET','PUT', 'DELETE'])
def handle_rep_response(service_id):
    # get a cursor object from the database
    cursor = db.get_db().cursor()
    
    if request.method == 'GET':
        
        cursor.execute(f'''
                       SELECT *
                       FROM Service
                       WHERE ServiceID = ${service_id}
                       ''')
    elif request.method == 'PUT':
        # Update the service details
        service_info = request.json
        service_type = service_info['Type']
        order_id = service_info['OrderID']
        start_time = service_info['StartTime']
        end_time = service_info['EndTime']
        description = service_info['Description']
        
        # Construct the UPDATE query
        update_query = '''
                       UPDATE Service
                       SET Type = %s, OrderID = %s, StartTime = %s, EndTime = %s, Description = %s
                       WHERE ServiceID = %s
                       '''
        cursor.execute(update_query, (service_type, order_id, start_time, end_time, description, service_id))
        db.get_db().commit()
        
        
    elif request.method == 'DELETE':
        cursor.execute(f'''
                       DELETE 
                       FROM Service
                       WHERE ServiceID = ${service_id}
                       ''')
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