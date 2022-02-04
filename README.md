# README

Tiny app for fetching and querying the sanctioned entity lists from the US Department of Treasury and the UN Security council.

## Requirements

1. Postgres running locally, a `reglab_poi_api` user with password `password`.
2. Ruby 3.0
3. Bundler

## Setup

- Clone the repo and move to the new directory.
- `bundler install` to install dependencies.
- `bundle exec rails db:setup && bundle exec rails db:migrate` to prepare the database.
- `bundle exec rspec` to run the tests.
- Fill your dev database by running `bundle exec rails fetch_sanction_list:un_sc_consolidated_list` and/or `bundle exec rails fetch_sanction_list:us_treasury_sdn`.
- Run the app locally with `bundle exec rails server`

## Usage

The app exposes two endpoints:

- `/healthcheck`, which always returns 200 with an empty body to GET requests.
- `/search`, which accepts POST requests containing a JSON body.

The body of the POST request to `/search` should be a JSON object containing a single key named `fullname`, like so:
```ruby
{ "fullname": "SHEIN" }
```

The response will be a JSON object containing two keys, `exact_match` and `results`:
```
{
  "exact_match": true,
  "results": [
    {
      "id": 89883,
      "list_id": 26445,
      "parent_id": null,
      "full_name": "SHEIN, Andrey",
      "entity_type": "Individual",
      "sanction_program": "UKRAINE-EO13661",
      "authority": "us_treasury_sdn",
      "title": "Deputy Head of the Border Directorate - Head of the Coast Guard Unit of the Federal Security Service of the Russian Federation",
      "remarks": null,
      "created_at": "2022-02-04T19:28:15.770Z",
      "updated_at": "2022-02-04T19:28:15.770Z"
    },
    {
      "id": 91381,
      "list_id": 31945,
      "parent_id": null,
      "full_name": "SHEIN, Win",
      "entity_type": "Individual",
      "sanction_program": "BURMA-EO14014",
      "authority": "us_treasury_sdn",
      "title": "Minister for Planning, Finance, and Industry",
      "remarks": null,
      "created_at": "2022-02-04T19:28:15.770Z",
      "updated_at": "2022-02-04T19:28:15.770Z"
    },
    # <some other partial matches omitted for brevity>
  ]
}
```

The `results` key will be an array containing the details of any individuals or entities that were at least a partial match with the search term. It will match on anything close enough on the `similarity` metric as defined by the `pg_trgm` extension and can be tweaked according to the docs for that extension. There is also an `exact_match` key that indicates whether any of the search results was an exact match for the search term.

It is recommended to run the `fetch_sanction_list:un_sc_consolidated_list` and `fetch_sanction_list:us_treasury_sdn` rake tasks periodically to fetch the latest version of the lists, as people may be added or removed at any time.

The `/search` endpoint (but not the healthcheck) is protected with HTTP Basic Auth if the `HTTP_BASIC_USER` and `HTTP_BASIC_PASSWORD` environments variable are set.