# README

This is a utility service that can be used to convert an USD value to Euros, on any date since year 2000. It pulls a list of exchange rates in CSV format, from a bank and stores them in a local DB. Each time a client requests an exchange rate of a specific date, the application checks if the requested exchange rate, is already available in its database, in order to serve it. If not, it pulls a fresh CSV list, searches for the requested value in it and updates asynchronously the database with the missing values.

### Stack
* Ruby 2.2.4
* Rails 5.0.6
* PostgeSQL 10

### Arcitecture
The RoR application is provided as a service to external consumers. For the time being, two endpoints are exposed: 
* *us_dollars_to_euros/:on/:amount* 
* *exchange_rates/:on*

with show actions available for each one. The first one takes two parameters, the date of the exchange rate *(:on)* and the amount *(:amount)* of dollars to be calculated in euros. The second one, accepts one parameter *(:on)* as the date of the exchange rate and it returns its value. The API is RESTful, keeping the potential of full CRUD operations for its consumers. 

### Database creation
[Install PostgreSQL]:http://postgresguide.com/setup/install.html
Make sure you create a role with the credentials, found in *config/database.yml*, in your PostgreSQL database.

### Deployment instructions
Just make a local copy of the folder of the application, navigate in it and open a terminal. 

### Database initialization
Type the following:
* `rake db:create`
* `rake db:migrate`
* `rake db:migrate RAILS_ENV=test`
* `rake db:seed`
* `rake db:seed RAILS_ENV=test`
* `rake jobs:work`

### How to run the test suite
Type:
`rspec spec`

### Services (job queues, cache servers, search engines, etc.)
* Start rails server in development environment:
`rails s`
* Visit:
`http://localhost:3000/`
to use the social media lists UI
* Perform a GET request to:
`http://localhost:3000/us_dollars_to_euros/2017-11-5/100`
to convert 100 US dollars to Euros, based on the exchange rate of 2017-11-5.
* Perform a GET request to:
`http://localhost:3000/exchange_rates/2017-11-5`
to get the US dollars to Euros exchange rate of 2017-11-5.
* To update the database with the latest exchange rates just perform a GET request to:
`http://localhost:3000/exchange_rates/<current_date>

