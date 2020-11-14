# Medlibra

Welcome! You’ve generated an app using dry-web-roda.

## First steps

1. Run `bundle`
2. Review `.env` & `.env.test` (and make a copy to e.g. `.example.env` if you want example settings checked in). In
particular, ensure that your PostgreSQL username and password are specified in the `DATABASE_URL` variable as follows:
`postgres://username:password@your_host/...`.
3. Run `bundle exec rake db:create` to create the development database.
4. Run `RACK_ENV=test bundle exec rake db:create` to create the test database.
5. Add your own steps to `bin/setup`
6. Run the app with `bundle exec rerun -- rackup --port 4000 config.ru`
7. Initialize git with `git init` and make your initial commit


## Using docker-compose for local development

1. Copy .example.env into .env, fill blanks.
2. Run `docker-compose up postgres`, wait for db to init.
3. Run `docker-compose build`
4. Run `docker-compose up`, you are good to go.

Currently db will be inited with db/structure.sql, can be replaced with fresh dump when I get one.