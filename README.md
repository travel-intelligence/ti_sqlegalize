## Overview
**TI SQLLegalize** is an open source project that takes SQL queries and executes
them in a background process. It provides via Web Services an interface to start,
request status and get results of the jobs.

The project is based on Ruby on Rails, and it serves a [JSON API](http://jsonapi.org/)
representation of a relational data domain.

The media type supporting this web service,
known as [RelJSON](https://gist.github.com/ebastien/6d49802c8d34549e52ba7cc5fcddfdfa)
is still at an experimental stage.

## API
* ``baseurl/create?queries={query}``: Launches a job with the query as parameter
* ``baseurl/show?id={id}``: Show the status (and result if finished) of the job 

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


