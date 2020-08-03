## Overview

**TI SQLLegalize** is an open source project that takes SQL queries and executes them in a background process.
It provides via Web Services an interface to start, request status and get results of the jobs.

The project is based on Ruby on Rails, and it serves a [JSON API](http://jsonapi.org/) representation of a relational data domain.

The media type supporting this web service, known as [RelJSON](https://gist.github.com/ebastien/6d49802c8d34549e52ba7cc5fcddfdfa) is still at an experimental stage.

## API

### Usage and browsing the API

As a JSON:API standard, the API is organized around resources accessed through a single entry point, and linked together with relationships.

The entry point of the API is the `/entry` URL, then next URLs can be accessed by following links and relationships from the resulting JSON.

All examples in this section are taken with the `ti_sqlegalize` Rails engine mounted in a Rails application at `http://localhost/v2`

Example:
```bash
curl http://localhost/v2/entry
```
```json
{
   "data" : {
      "type" : "entry",
      "links" : {
         "self" : "http://localhost/v2/entry"
      },
      "relationships" : {
         "queries" : {
            "links" : {
               "related" : "http://localhost/v2/queries"
            }
         },
         "schemas" : {
            "links" : {
               "related" : "http://localhost/v2/schemas"
            }
         }
      },
      "id" : "1"
   }
}
```

In this example, the schemas resource can be accessed following the URL given at `['data']['relationships']['schemas']['links']['related']`

For example, browsing the API in Ruby:

```ruby
require 'net/http'
require 'json'
json_entry = JSON.parse(Net::HTTP.get(URI('http://localhost/v2/entry')))
# Here we have the JSON for the entry resource
schemas_url = json_entry['data']['relationships']['schemas']['links']['related']
json_schemas = JSON.parse(Net::HTTP.get(URI(schemas_url)))
# Here we have the JSON for the schemas resource
```

Each resource can have a set of attributes accessible in `['data']['attributes']` of each JSON.

Each HTTP response will use HTTP status codes to indicate eventual errors. Refer to the [HTTP status codes](https://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html) to get the meaning out of them.

Non-documented properties of the returned JSON (pagination, limits...) are specific to the JSON:API standard and are documented on the [JSON:API specification](https://jsonapi.org/).

### JSON:API model

Here is the model of resources with their relations and attributes, published by the API, with links to each resource's details:

<pre><code>
<a href="#resource_entry">entry</a>
│
└── <a href="#resource_schema">schemas</a>
│   │   description
│   │   name
│   │
│   └── <a href="#resource_relation">relations</a>
│       │   heading
│       │   name
│       │
│       └── <a href="#resource_heading">heading_&lt;heading_name&gt;</a>
│       │   │   name
│       │   │   primitive
│       │
│       └── <a href="#resource_body">body</a>
│           │   tuples
│
└── <a href="#resource_query">queries</a>
    │   sql
    │   status
    │
    └── <a href="#resource_relation">relations</a>
        │   heading
        │   sql
        │
        └── <a href="#resource_heading">heading_&lt;heading_name&gt;</a>
        │   │   name
        │   │   primitive
        │
        └── <a href="#resource_body">body</a>
            │   tuples

</code></pre>

### API resources

#### <a name="resource_entry"></a>Entry

This resource is the entry point of the API.

Relationships:
* `schemas`: Info regarding schemas:
  Links:
  * [`related`](#resource_schema): URL accessing schemas.
* `queries`: Info regarding schemas:
  Links:
  * [`related`](#resource_query): URL accessing queries.

Example of data structure:
```json
{
   "relationships" : {
      "schemas" : {
         "links" : {
            "related" : "http://localhost/v2/schemas"
         }
      },
      "queries" : {
         "links" : {
            "related" : "http://localhost/v2/queries"
         }
      }
   },
   "id" : "1",
   "links" : {
      "self" : "http://localhost/v2/entry"
   },
   "type" : "entry"
}
```

##### Method `GET`: Get the entry point

Example:
```bash
curl http://localhost/v2/entry
```
```json
{
   "data" : {
      "type" : "entry",
      "links" : {
         "self" : "http://localhost/v2/entry"
      },
      "relationships" : {
         "queries" : {
            "links" : {
               "related" : "http://localhost/v2/queries"
            }
         },
         "schemas" : {
            "links" : {
               "related" : "http://localhost/v2/schemas"
            }
         }
      },
      "id" : "1"
   }
}
```

#### <a name="resource_schema"></a>Schema

A schema represents a group of relations associated to a given name.
It can be seen as a way to group relational tables in a functional sense.

Attributes:
* `description` (String): Schema description
* `name` (String): Schema name

Relationships:
* `relations`: Info regarding relations in this schema:
  Links:
  * [`related`](#resource_relation): URL accessing this schema's relations.

Example of data structure:
```json
{
   "relationships" : {
      "relations" : {
         "links" : {
            "related" : "http://localhost/v2/schemas/MARKET/relations"
         }
      }
   },
   "id" : "MARKET",
   "attributes" : {
      "description" : "Market schema",
      "name" : "MARKET"
   },
   "type" : "schema",
   "links" : {
      "self" : "http://localhost/v2/schemas/MARKET"
   }
}
```

##### Method `GET`: Get the list of schemas

Example:
```bash
curl http://localhost/v2/schemas
```
```json
{
   "data" : [
      {
         "relationships" : {
            "relations" : {
               "links" : {
                  "related" : "http://localhost/v2/schemas/MARKET/relations"
               }
            }
         },
         "id" : "MARKET",
         "attributes" : {
            "description" : "Market schema",
            "name" : "MARKET"
         },
         "type" : "schema",
         "links" : {
            "self" : "http://localhost/v2/schemas/MARKET"
         }
      }
   ],
   "links" : {
      "self" : "http://localhost/v2/schemas"
   }
}
```

#### <a name="resource_relation"></a>Relation

A relation is grouping tuples under a given header and name.
It can be seen as a table with headings and a body made of rows.

Attributes:
* `heading` (Array&lt;String&gt;): List of heading names this relation has (similar to column names)
* `name` (String): Name of this relation (similar to table name)
* `sql` (String): SQL statement that created this relation. Only visible if the relation comes from a query.

Relationships:
* `heading_<heading_name>`: Info regarding a particular heading:
  Data:
  * `id` (String): ID of this heading
  * `type` (String): Type of this heading
  Links:
  * [`related`](#resource_heading): URL accessing this heading.
* `body`: Info regarding the data associated to this relation
  Links:
  * [`related`](#resource_body): URL accessing this relation's body.

Example of data structure:
```json
{
   "links" : {
      "self" : "http://localhost/v2/relations/fd76368d-ccc0-44be-8e1f-adbcd2e1c4ff"
   },
   "relationships" : {
      "heading_PAX" : {
         "data" : {
            "id" : "INTEGER",
            "type" : "domain"
         },
         "links" : {
            "related" : "http://localhost/v2/relations/fd76368d-ccc0-44be-8e1f-adbcd2e1c4ff/heading/PAX"
         }
      },
      "heading_BOARD_CITY" : {
         "data" : {
            "type" : "domain",
            "id" : "IATA_CITY"
         },
         "links" : {
            "related" : "http://localhost/v2/relations/fd76368d-ccc0-44be-8e1f-adbcd2e1c4ff/heading/BOARD_CITY"
         }
      },
      "body" : {
         "links" : {
            "related" : "http://localhost/v2/relations/fd76368d-ccc0-44be-8e1f-adbcd2e1c4ff/body"
         }
      }
   },
   "attributes" : {
      "name" : "BOOKINGS_OND",
      "heading" : [
         "BOARD_CITY",
         "PAX"
      ]
   },
   "id" : "fd76368d-ccc0-44be-8e1f-adbcd2e1c4ff",
   "type" : "relation"
}
```

##### Method `GET`: Get the list of relations

Example:
```bash
curl http://localhost/v2/schemas/MARKET/relations
```
```json
{
   "data" : [
      {
         "attributes" : {
            "heading" : [
               "BOARD_CITY",
               "PAX"
            ],
            "name" : "BOOKINGS_OND"
         },
         "links" : {
            "self" : "http://localhost/v2/relations/212764da-b690-4581-8edd-88db7498a71c"
         },
         "id" : "212764da-b690-4581-8edd-88db7498a71c",
         "type" : "relation",
         "relationships" : {
            "body" : {
               "links" : {
                  "related" : "http://localhost/v2/relations/212764da-b690-4581-8edd-88db7498a71c/body"
               }
            },
            "heading_PAX" : {
               "data" : {
                  "type" : "domain",
                  "id" : "INTEGER"
               },
               "links" : {
                  "related" : "http://localhost/v2/relations/212764da-b690-4581-8edd-88db7498a71c/heading/PAX"
               }
            },
            "heading_BOARD_CITY" : {
               "data" : {
                  "id" : "IATA_CITY",
                  "type" : "domain"
               },
               "links" : {
                  "related" : "http://localhost/v2/relations/212764da-b690-4581-8edd-88db7498a71c/heading/BOARD_CITY"
               }
            }
         }
      }
   ],
   "links" : {
      "self" : "http://localhost/v2/schemas/MARKET/relations"
   }
}
```

#### <a name="resource_heading"></a>Heading

A heading represents a typed header that can be used to interpret the body of a relation.

Attributes:
* `name` (String): Domain name of this heading
* `primitive` (String): Type primitive of data belonging to this domain

Relationships:
* `relations`: Relation to which this heading belongs.
  Links:
  * [`related`](#link_get_schema_relations_related): URL accessing this relation.

Example of data structure:
```json
{
   "links" : {
      "self" : "http://localhost/v2/domains/INTEGER"
   },
   "type" : "domain",
   "attributes" : {
      "name" : "INTEGER",
      "primitive" : "INTEGER"
   },
   "relationships" : {
      "relations" : {
         "links" : {
            "related" : "http://localhost/v2/domains/INTEGER/relations"
         }
      }
   },
   "id" : "INTEGER"
}
```

##### Method `GET`: Get info on a heading

Example:
```bash
curl http://localhost/v2/relations/f90be808-854f-4904-b27d-c2b4be680f9b/heading/PAX
```
```json
{
   "data" : {
      "links" : {
         "self" : "http://localhost/v2/domains/INTEGER"
      },
      "attributes" : {
         "name" : "INTEGER",
         "primitive" : "INTEGER"
      },
      "relationships" : {
         "relations" : {
            "links" : {
               "related" : "http://localhost/v2/domains/INTEGER/relations"
            }
         }
      },
      "id" : "INTEGER",
      "type" : "domain"
   }
}
```

#### <a name="resource_body"></a>Body

A relation's body contain the tuples of the relation.
It can be as a list of rows.

Attributes:
* `tuples` (Array): Data array

Relationships:
* `relations`: Relation to which this body belongs.
  Links:
  * [`related`](#link_get_schema_relations_related): URL accessing this relation.

Example of data structure:
```json
{
   "id" : "fd76368d-ccc0-44be-8e1f-adbcd2e1c4ff",
   "type" : "body",
   "links" : {
      "self" : "http://localhost/v2/relations/fd76368d-ccc0-44be-8e1f-adbcd2e1c4ff/body"
   },
   "attributes" : {
      "tuples" : [
         [
            "NCE"
         ]
      ]
   },
   "relationships" : {
      "relation" : {
         "links" : {
            "related" : "http://localhost/v2/relations/fd76368d-ccc0-44be-8e1f-adbcd2e1c4ff"
         }
      }
   }
}
```

##### Method `GET`: Get info on a relation's body

Query parameters:
* `q_limit` (Integer): The maximum number of tuples to return [default = 1]
* `q_offset` (Integer): Index of the first tuple to be returned [default = 0]


Example:
```bash
curl http://localhost/v2/relations/f90be808-854f-4904-b27d-c2b4be680f9b/body
```
```json
{
   "meta" : {
      "count" : 0,
      "offset" : 0,
      "limit" : 1
   },
   "data" : {
      "id" : "f90be808-854f-4904-b27d-c2b4be680f9b",
      "attributes" : {
         "tuples" : []
      },
      "type" : "body",
      "links" : {
         "self" : "http://localhost/v2/relations/f90be808-854f-4904-b27d-c2b4be680f9b/body"
      },
      "relationships" : {
         "relation" : {
            "links" : {
               "related" : "http://localhost/v2/relations/f90be808-854f-4904-b27d-c2b4be680f9b"
            }
         }
      }
   }
}
```

Other example, when the relation comes from a query:
```bash
curl http://localhost/v2/queries/5b506ed71522284b8d29fd96fc91d476_9/result/body
```
```json
{
   "meta" : {
      "offset" : 0,
      "count" : 3,
      "limit" : 1
   },
   "data" : {
      "links" : {
         "self" : "http://localhost/v2/queries/5b506ed71522284b8d29fd96fc91d476_9/result/body"
      },
      "id" : "5b506ed71522284b8d29fd96fc91d476_9",
      "relationships" : {
         "relation" : {
            "links" : {
               "related" : "http://localhost/v2/queries/5b506ed71522284b8d29fd96fc91d476_9/result"
            }
         }
      },
      "type" : "body",
      "attributes" : {
         "tuples" : [
            [
               "NCE"
            ]
         ]
      }
   }
}
```

Other example, when the relation comes from a query and we use limit and offset parameters:
```bash
curl 'http://localhost/v2/queries/5cf97942948ed9afb10d95c27e38ba1f_11/result/body?q_limit=2&q_offset=1'
```
```json
{
   "data" : {
      "attributes" : {
         "tuples" : [
            [
               "CDG"
            ],
            [
               "MAD"
            ]
         ]
      },
      "links" : {
         "self" : "http://localhost/v2/queries/5cf97942948ed9afb10d95c27e38ba1f_11/result/body"
      },
      "relationships" : {
         "relation" : {
            "links" : {
               "related" : "http://localhost/v2/queries/5cf97942948ed9afb10d95c27e38ba1f_11/result"
            }
         }
      },
      "id" : "5cf97942948ed9afb10d95c27e38ba1f_11",
      "type" : "body"
   },
   "meta" : {
      "offset" : 1,
      "limit" : 2,
      "count" : 3
   }
}
```

#### <a name="resource_query"></a>Query

A query represents an SQL query on the relations.
It has a life cycle (as it is executed asynchronously), with status indicating where it is in the flow: created, running, finished or error.

Attributes:
* `sql` (String): SQL string of the query.
* `status` (String): Status of the query (can be created, running, finished or error).

Relationships:
* `result`: Result of this query (only available if status is finished).
  Links:
  * [`related`](#link_get_schema_relations_related): URL accessing this result.

Example of data structure:
```json
{
   "relationships" : {
      "result" : {
         "links" : {
            "related" : "http://localhost/v2/queries/95e1bd0bdc1bc9ca0bdc9ac8d742d560_3/result"
         }
      }
   },
   "attributes" : {
      "status" : "finished",
      "sql" : "SELECT `BOARD_CITY`\nFROM `MARKET`.`BOOKINGS_OND`"
   },
   "type" : "query",
   "id" : "95e1bd0bdc1bc9ca0bdc9ac8d742d560_3",
   "links" : {
      "self" : "http://localhost/v2/queries/95e1bd0bdc1bc9ca0bdc9ac8d742d560_3"
   }
}
```

##### Method `GET`: Get info on a given query

Example:
```bash
curl http://localhost/v2/queries/5b506ed71522284b8d29fd96fc91d476_9
```
```json
{
   "data" : {
      "type" : "query",
      "id" : "5b506ed71522284b8d29fd96fc91d476_9",
      "attributes" : {
         "status" : "finished",
         "sql" : "SELECT `BOARD_CITY`\nFROM `MARKET`.`BOOKINGS_OND`"
      },
      "relationships" : {
         "result" : {
            "links" : {
               "related" : "http://localhost/v2/queries/5b506ed71522284b8d29fd96fc91d476_9/result"
            }
         }
      },
      "links" : {
         "self" : "http://localhost/v2/queries/5b506ed71522284b8d29fd96fc91d476_9"
      }
   }
}
```

##### Method `POST`: Create a new query

Parameters:
* `data` (Hash): Structure defining the query:
  * `type` (String): Type of data being sent. Value should be `query`.
  * `attributes` (Hash): List of attributes defining the query:
    * `sql` (String): The query expressed as an SQL query.

Example:
```bash
curl http://localhost/v2/queries -X POST -d '{"data": {"type": "query", "attributes": {"sql": "SELECT BOARD_CITY FROM MARKET.BOOKINGS_OND"}}}' -H "Content-Type: application/json"
```
```json
{
   "data" : {
      "type" : "query",
      "attributes" : {
         "sql" : "SELECT `BOARD_CITY`\nFROM `MARKET`.`BOOKINGS_OND`",
         "status" : "created"
      },
      "links" : {
         "self" : "http://localhost/v2/queries/dc78a6e9184b44d5321216030e6615aa_10"
      },
      "id" : "dc78a6e9184b44d5321216030e6615aa_10"
   }
}
```

## How does it work
It is based upon Resque (background jobs with Redis) and SQLiterate.
TISqlegalize exposes 3 Web Services, as we can see in its ``config.rb`` file:
```ruby
TiSqlegalize::Engine.routes.draw do
  get '/profile', to: redirect('/profile.txt')
  resources :queries, only: [:create, :show]
end
```

Then the controller parses the query with SQLiterate and creates a Query Model and runs it:
```ruby
    def create
      query = params['queries']
      return invalid_params unless query && query.is_a?(Hash)
      sql = query['sql']
      return invalid_params unless sql && sql.is_a?(String)
      ast = SQLiterate::QueryParser.new.parse sql
      return invalid_params unless ast
 
      #The query object is created from the query
      #the enqueue method ensures the job is queued and executed
      query = Query.new sql
      query.create!
      query.enqueue!
 
      href = query_url(query.id)
      rep = {
        queries: {
          id: query.id,
          href: href,
          sql: sql,
          tables: ast.tables
        }
      }
      response.headers['Location'] = href
      render_api json: rep, status: 201
    end
```

The ``show`` method in the controller shows the status of the job
and, if finished, would provide the result of the query (with a limit
of 10,000 rows):
```ruby
    def show
      id = params[:id]
      offset = [params[:offset].to_i, 0].max
      limit = [[params[:limit].to_i, 1].max, 10000].min
 
      query = Query.find(id)
      if query
        rep = {
          queries: {
            id: id,
            href: query_url(id),
            status: query.status,
            offset: offset,
            limit: limit,
            quota: query.quota,
            count: query.count,
            schema: query.schema,
            rows: query[offset, limit]
          }
        }
        render_api json: rep, status: 200
      else
        render_api json: {}, status: 404
      end
    end
```

## Development

In order to locally test the library, first install dependencies:

```bash
bundle install
```

Then run the tests
```bash
bundle exec rspec
```

If you want to run the tests against a [TI Calcite](https://github.com/travel-intelligence/ti_calcite) server, just build a Jar of TI Calcite (check TI Calcite documentation to know how to do it) and provide the path to the Jar using the `TI_CALCITE_JAR` environment variable:

```bash
TI_CALCITE_JAR=/path/to/ti-calcite-all.jar bundle exec rspec
```
