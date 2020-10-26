# Shopify x Algolia SEO
This repository contains a script that synchronize records positions in collections between Shopify and Algolia for SEO purposes.
This script goes through all the shop published collections and updates manually the order of the first products to match the order rendered by Algolia on the collection pages.

## Setup

### Requirements

#### Local environment
To run this application, you need to have `ruby 2.5.3` installed on your machine.
You also need to have `bundler` installed. You can install it by running `gem install bundler` in your terminal once ruby is installed.

#### Algolia Application

You need to have the Algolia for Shopify app installed on your store with the `Collection Page` feature enabled.
You should also have your `attributeForDistinct` attribute set to `id` in your Algolia dashboard like it is done by default when installing our extension.
This is to ensure we do not fetch two Algolia records (that represent Shopify variants) belonging to the same product.

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

#### Run the program

To launch the program, you have to run this command in the terminal :
```
./bin/init.rb
```

## Usage

### Number of products

By default the program update the position of the `100` first products only.
This value can be changed by adding a `NUMBER_OF_PRODUCTS_TO_ORDER` variable in your `.env` file.
For the current implementation this value cannot go beyond `250`.

### Performance

For a store that has `14` collections that have `20 000` products combined, it takes approximately `40` seconds for the script to complete, which can be approximated to `2.86` second per colleciton.

### Frequency

With real-time indexing, your Algolia index will change every time a product or a collection is updated in Shopify. This means the order of the products might change as well.
We advise you to run this script regularly to keep the synchronization up-to-date.
Ideally, it should be run at least once every hour.

### Operations

The algorithm performs one Algolia search operation per collection updated.

### Logger

The script logs all the requests to Shopify in a  `shopify_api.log` file located in the `/log` folder. This file might get pretty big if the script is run often.
If you want to stop logging the requests, comment the line `ActiveResource::Base.logger = Logger.new('log/shopify_api.log')
` of the `bin/init.rb` file.

