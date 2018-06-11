# README

- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Development](#development)
  - [Testing](#testing)
- [Known Errors](#known-errors)

## Prerequisites

- Ruby 2.3.4
- Node v0.10.26
- Postgres 9

## Getting Started

The local development environment can easily be setup by running the following
command:

    bin/setup

This installs all dependencies, and configures and creates the database. After
the command has finished, the application can be started by running these two
commands:

```
bundle exec rails s -p 4000
npm run webpack-w
```

For convenience, [Foreman](https://github.com/ddollar/foreman) can be used to
run both commands together:

    foreman start

Browse to [localhost:4000](http://localhost:4000) and log in with the demo user
`user@example.com` with the password `password`.

## Development

## Testing

To test with a given seed, run

    bundle exec rake test TESTOPTS="--seed YOURSEEDHERE"

## Known Errors

Are you seeing?
```
ActionView::Template::Error: couldn't find file 'main.bundle' with type 'application/javascript'
```

This is because `main.bundle.js` is in the `.gitignore` for reasons that have to
do with it changing all the time. Run

```
touch app/assets/javascripts/main.bundle.js
```

to fix.

In the future we're going to want to check it in blank and run "assume
unchanged" locally so git never bugs us to check in changes everytime we compile
assets. This can be done with

```
 git update-index --assume-unchanged app/assets/javascripts/main.bundle.js
```
