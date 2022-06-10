# Harmony Database Setup

## Dependencies
- Docker Postgres Image

## Run Database
`docker run -d -v postgresql:/var/lib/postgresql/data -p 5432:5432 -e POSTGRES_PASSWORD=postgres --user postgres --name postgres postgres:14`
`docker run -d -v cloudbeaver:/opt/cloudbeaver/workspace -p 8978:8978 --name cloudbeaver dbeaver/cloudbeaver`