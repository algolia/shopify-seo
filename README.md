# Shopify x Algolia SEO
This repository contains a script that synchronize records positions in collections between Shopify and Algolia for SEO purposes.
This script goes through all the shop published collections and update manually the product orders of these collections to match the order rendered by Algolia on the collection pages.

## Setup

### Requirements

#### Local environment
To run this application, you need to have `ruby 2.5.3` installed on your machine.
You also need to have `bundler` installed. You can install it by running `gem install bundler` in your terminal once ruby is installed.

#### Algolia Application

You need to have the Algolia for Shopify app installed on your store with the `Collection Page` feature enabled.

#### Private application

You need to create a private Shopify application to get the credentials that will be used by this program to make the changes on your Shopify collections.
You can find the steps on how to create a private app and generate credentials from the Shopify Admin in this [tutorial](https://shopify.dev/tutorials/authenticate-a-private-app-with-shopify-admin).

**Important** :
The private app has to have the `Read and Write` permission on `Products` for it to work.

### Configuration

#### Clone the repository
Clone this repository on your local environement and go to the project folder.

#### Create the config file
At the root of this project, create a `.env` file and add the following in it :
```
ALGOLIA_APP_ID=Your algolia application id
ALGOLIA_API_KEY=Your algolia api key (with write permissions)
SHOPIFY_API_KEY=Your Shopify private app api key
SHOPIFY_PASSWORD=Your Shopify private app password
SHOP_NAME=your-shop-name
INDEX_NAME=Name of the Algolia products index of your store
```

#### Install gems
Run this command to install the gems used by this program :
```
bundle install
```

## Run the program

To launch the program, you have to run this command in the terminal :
```
ruby update_shopify_products_position_in_collections.rb
```
