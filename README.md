
## Project Overview - ByteBoutique
We aim to create an **E-commerce website** that will cater to small businesses who need a platform to grow. Small businesses often have a hard time gaining customers due to the presence of large corporations with significantly more funds to invest into marketing. Online retailers like **Etsy and Shopify** were originally founded to solve this problem. However, these websites have become inundated by extra fees, fraudulent sellers, and an excess of sellers who are constantly in competition with each other. Our application will aim to solve this issue by **providing small businesses with a sleek, streamlined platform** on which they can sell their products. Customers will be provided with a **trustworthy** payment platform and skilled customer service representatives who can address any issues with their products. Furthermore, there will be financial incentives for sellers in the form of bidding on items, smaller seller fees, and smaller shipping fees that are handled by the company. 

In this repo, we established a relational data model for ByteBoutique, containing personas Customers, Small Business Seller, and Service Representatives, each handling some tasks in relations to Orders, Service, and Products. 

## Files/Containers
This repo contains a  setup for spinning up 3 Docker containers: 
-  A MySQL 8 container for obvious reasons
-  A Python Flask container to implement a REST API
-  A Local AppSmith Server

## How to setup and start the containers
**Important** - you need Docker Desktop installed

1. Clone this repository: `git clone https://github.com/xli04/Project-phase2`

1. Create a file named `db_root_password.txt` in the `secrets/` folder and put inside of it the root password for MySQL. This password will be used to connect the MySQL database. 
1. Create a file named `db_password.txt` in the `secrets/` folder and put inside of it the password you want to use for the a non-root user named webapp. 

1. In a terminal or command prompt, navigate to the folder with the `docker-compose.yml` file.
1. Build the images with `docker compose build`
1. Start the containers with `docker compose up`.  To run in detached mode, run `docker compose up -d`. 






## How to Use this app
After the containers are running, users are able to access the database through API calls with `web:4000/` to request response from the database.

For example, if you wish to get all the customer information, the API call would be a GET request for  `web:4000/c/customers`.



## Team Members
* Xu Li,
* YuFeng Lin,
* Khushi Shah
* Noah Jackson
* Jasdeep Singh

