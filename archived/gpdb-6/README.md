## Running the Docker Container

The container exposes port 5432 to allow for external connections to Greenplum database.

```
docker run --name gpdb -p 5432:5432 -d testing/gpdb-6:latest
```

The container can take anywhere from 30 seconds to a few minutes to start up, depending on the host machine.
Use `docker logs gpdb` if you have difficulty connecting to see what isn't going to plan.
You'll see a message `Database successfully started` in the logs when it is ready to accept connections.

The default database is called `gpadmin`, but you can specify it by setting the `DATABASE` environment variable
when starting your container, e.g.:

```
docker run --name gpdb -p 5432:5432 -e DATABASE=tpch -d testing/gpdb-6:latest
```

## Usage

`gpadmin` is both the user name and password.

You can login to GPDB using `psql` that is inside the container or on the host if you have `psql` installed.

In the container:

```bash
$ docker exec -it gpdb psql
psql (9.4.24)
Type "help" for help.

gpadmin=# CREATE TABLE foo (a BIGINT) DISTRIBUTED RANDOMLY;
CREATE TABLE
gpadmin=# insert into foo values (1), (2), (3);
INSERT 0 3
gpadmin=# SELECT * FROM foo;
 2
 3
 1
```

On the host, if you have `psql`:

```bash
psql -h localhost -U gpadmin
Password for user gpadmin:
psql (12.3, server 9.4.24)
Type "help" for help.

gpadmin=#
```

If you changed the database name, provide it as an extra argument to `psql` (not necessary when using `docker exec`):

```bash
psql -h localhost -U gpadmin tpch
```
