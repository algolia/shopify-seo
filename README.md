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
**Important** :
The number of products retrieved by Algolia through a search is limited (see [paginationLimitedTo](https://www.algolia.com/doc/api-reference/api-parameters/paginationLimitedTo/) parameter).
It means that only the first `N` number of products will be correctly ordered in Shopify, `N` being the number of products that can be retrieved through a search (so `N = paginationLimitedTo`).
The rest will keep the Shopify order.

#### Private application

You need to create a private Shopify application to get the credentials that will be used by this program to make the changes on your Shopify collections.
You can find the steps on how to create a private app and generate credentials from the Shopify Admin in this [tutorial](https://shopify.dev/tutorials/authenticate-a-private-app-with-shopify-admin).

**Important** :
The private app has to have the `Read and Write` permission on `Products` for it to work.

### Configuration

#### Clone the repository
Clone this repository on your local environement and go to the project folder.

#### Create the config file
At the root of this project, create a file named `.env`  and add the following in it :
```
ALGOLIA_APP_ID=Your algolia application id
ALGOLIA_SEARCH_API_KEY=Your algolia search api key
SHOPIFY_API_KEY=Your Shopify private app api key
SHOPIFY_PASSWORD=Your Shopify private app password
SHOP_DOMAIN=your-shop-name.myshopify.com
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
./bin/init.rb
```
## Performance

For a store that has `14` collections that have `20 000` products combined, it takes approximately `93` seconds for the script to complete.
We can approximate the time to process `4.64` seconds for `1000` products.
What takes the most time is fetching all the products of each Shopify collection from Shopify.
This fetching is necessary since we have to pass all the product ids to Shopify to update the products order, and Algolia might not have all these product ids.
Indeed, if a product has been hidden through a merchandising rule or is not published, it won't appear on Algolia.

## Usage

With real-time indexing, your Algolia index will change every time a product or a collection is updated in Shopify. This means the order of the products might change as well.
We advise you to run this script regularly to keep the synchronization up-to-date.
Ideally, it should be run once every hour. We believe it should at least be run once a day if the traffic is high on your store.
