# Some set up for the application 

from flask import Flask
from flaskext.mysql import MySQL

# create a MySQL object that we will use in other parts of the API
db = MySQL()

def create_app():
    app = Flask(__name__)
    
    # secret key that will be used for securely signing the session 
    # cookie and can be used for any other security related needs by 
    # extensions or your application
    app.config['SECRET_KEY'] = 'someCrazyS3cR3T!Key.!'

    # these are for the DB object to be able to connect to MySQL. 
    app.config['MYSQL_DATABASE_USER'] = 'root'
    app.config['MYSQL_DATABASE_PASSWORD'] = open('/secrets/db_root_password.txt').readline().strip()
    app.config['MYSQL_DATABASE_HOST'] = 'db'
    app.config['MYSQL_DATABASE_PORT'] = 3306
    app.config['MYSQL_DATABASE_DB'] = 'commerce'  # Change this to your DB name

    # Initialize the database object with the settings above. 
    db.init_app(app)
    
    # Add the default route
    # Can be accessed from a web browser
    # http://ip_address:port/
    # Example: localhost:8001
    @app.route("/")
    def welcome():
        return "<h1>Welcome to the 3200 boilerplate app</h1>"

    # Import the various Beluprint Objects
    
    # All the commented out ones are the ones I deleted
    
    # from src.card.card import card
    # from src.cart.cart import cart
    from src.customers.customers import customers
    # from src.drivers.drivers import drivers
    # from src.orderdetails.orderdetails import orderdetails
    # from src.orders.orders import orders
    from src.products.products  import products
    # from src.product_in_cart.product_in_cart  import pic
    # from src.response.response import response
    # from src.service.service import service
    from src.service_representative.service_representative import rep
    from src.shippers.shippers import shippers
    from src.shipping_details.shipping_details import sd
    from src.small_business_owners.small_business_owners import sbs

    # Register the routes from each Blueprint with the app object
    # and give a url prefix to each
    app.register_blueprint(customers,   url_prefix='/c')
    # app.register_blueprint(card,   url_prefix='/card')
    # app.register_blueprint(cart,   url_prefix='/cart')
    # app.register_blueprint(drivers,    url_prefix='/d')
    # app.register_blueprint(orders,    url_prefix='/o')
    # app.register_blueprint(orderdetails,    url_prefix='/od')
    app.register_blueprint(products,    url_prefix='/p')
    # app.register_blueprint(pic,    url_prefix='/pic')
    # app.register_blueprint(response,    url_prefix='/r')
    app.register_blueprint(rep,    url_prefix='/rep')
    app.register_blueprint(shippers,    url_prefix='/shippers')
    # app.register_blueprint(service,    url_prefix='/service')
    app.register_blueprint(sd,    url_prefix='/sd')
    app.register_blueprint(sbs,    url_prefix='/sbs')

    # Don't forget to return the app object
    return app