# Prestodb docker images

## Docker Image Names

The docker images in this repository are expected to be given names of the form
prestodb/hdp2.5-hive. The Dockerfile and other files needed to build the
prestodb/hdp2.5-hive image are located in the directory
prestodb/hdp2.5-hive.

Generally speaking, the images should *not* be built manually with docker
build.

## Building docker images

The docker images should be built using `make`. To build the docker image named
`prestodb/hdp2.5-hive`, run `make prestodb/hdp2.5-hive`. Make will build
the image and its dependencies in the correct order.

If you want to build a base image and all the images depending on it,
you can use the `*.dependants` targets. E.g.

```
make prestodb/hdp2.5-base.dependants
```

will build the `hdp2.5-base` and all the images depending on it (transitively).

## Releasing (pushing) docker image

All of the docker images in the repository share the same version number. This
is because most of the images depend on a parent image that is also in the
repository (e.g. prestodb/hdp2.5-hive is FROM prestodb/hdp2.5-base),
or are meant to be used together in testing (prestodb/hdp2.5-hive and
prestodb/hdp2.5-hive-kerberized).

Having all of the images on the same version number make troubleshooting easy:
If all of the docker images you are using have the same version number then
they are in a consistent state. 

This means that we treat the repository as a single codebase that creates
multiple artifacts (Docker images) that all need to be released together. The
Makefile uses [docker-release](https://github.com/kokosing/docker-release) to
automate this process and ensure that the images on dockerhub are in a
consistent state provided all of the push operations run to completion.

docker-release also handles tagging the images and repository appropriately so
that you can easily find the Dockerfile used to create an image starting from
just the tags on a Docker image.

Best practice for publishing a snapshot or release version is to use the Jenkins job.  Login to Jenkins and search for `docker-images`.  If you must publish a new version manually, follow these steps:

To release a snapshot version of the repository do the following

1. `docker login`
2. Verify in the Makefile that `VERSION` is set to something ending in -SNAPSHOT.
3. `make snapshot`

To release a release (final) version of the repository do the following

1. `docker login`
2. Verify in the Makefile that `VERSION` is set to something *not* ending in -SNAPSHOT.
3. `make release`

To release a snapshot or final version, you must log in to docker using the
docker `login` command.

### Typical workflow

Normally developers are working on a snapshot version of the next release, and
the `VERSION` macro in the Makefile should be set to a snapshot version such as
35-SNAPSHOT. A typical workflow is as follows:

1. Develop changes
2. Commit changes
3. `make snapshot` to push snapshot releases to dockerhub as needed
4. Repeat as needed

Eventually, version 35-SNAPSHOT is ready for release. To release version 35, do
the following:

1. Change `VERSION` to the release version: 35-SNAPSHOT -> 35
2. Commit the repository
3. `make release` to push the images to dockerhub and tag the repository
4. Change `VERSION` to the next snapshot version: 35 -> 36-SNAPSHOT
5. Commit the repository
6. Continue developing as described above

`make snapshot` does the following:

* Updates the 'latest' tag for the image on dockerhub
* Creates a tag for the image with the git hash of the git repository on dockerhub

`make release` does the following:

* Updates the 'latest' tag for the image on dockerhub
* Creates a tag for the image on dockerhub with the git hash of the git repository
* Creates a tag for the image on dockerhub with the $(VERSION) specified in the Makefile
* Creates a tag in the git repository with the name release-$(VERSION)

`docker-release` enforces several rules about the state of the repository when pushing to dockerhub:

* For a snapshot or a release, the repository must be in a clean state (no uncommitted files)
* For a release, the branch must be master

## Upgrading Docker images for consumers

For a project that uses Travis for continuous integration, you can upgrade the
docker images used by the project using the following process.

1. Develop locally, testing your changes
2. When you are satisfied with your changes, run `make snapshot` to release a snapshot build to dockerhub.
3. Create a branch of the dependent project
4. Set the tag for the images on the project to the tag of the snapshot build
5. Push the branch to github.
6. Merge your changes into docker-images/master
7. Update the release version as described above, and run `make release`
8. Create a PR against upstream/master that uses the new release of the docker images.
9. After Travis passes, merge the PR

## Docker build arguments (ARG, --build-arg)

Docker build arguments are documented in the [Dockerfile
reference](https://docs.docker.com/engine/reference/builder/#/arg)

Args are used by specifying the ARG directive in a Dockerfile:

```
ARG FOO
RUN echo $FOO >/etc/foo
```

The value of FOO then needs to be set in the Makefile:

```
FOO := Docker images build on $(shell uname -s) are superior to all others.
```

Note that `docker build` does *not* allow the variable reference `$FOO` to be
written `${FOO}` or `$(FOO)`. Further note that it won't warn you about this;
instead, you'll likely end up with an error later in the build or a broken
image.

`docker build` won't let you pass `--build-arg`s that don't have a
corresponding key in the Dockerfile. This means that the build system can't
just pass the union of all of the `--build-arg`s needed by every Dockerfile in
the repository. The build system handles this largely the same way it handles
figuring out what the correct dependency order is for building the images,
described below.

Build args with a default value are not handled at present. Feel free to add
that functionality in `bin/flag.sh` if needed.

## Java

Individual Dockerfiles shouldn't contain the URL for downloading Java, the name
of the RPM, or the path that java gets installed in. Doing this makes upgrading
Java across the repo a pain with a bunch of touch points.

Instead, the build system exposes the [Docker build
arguments](https://docs.docker.com/engine/reference/builder/#/arg) `JDK_URL`,
`JDK_RPM`, and `JDK_PATH`. These can be used in your Dockerfile as follows:

```
ARG JDK_URL
RUN wget $JDK_URL
```

## How the build system works.

At a high level, a docker image depends on two things:

1. Its Dockerfile
2. Its parent image, specified by the from FROM line in the Dockerfile.

Using the relative directory from the root of the repo as the image name, we
could, in principle, write a rule of the form

```
prestodb/foo: prestodb/foo/Dockerfile $(extract_parent prestodb/foo/Dockerfile)
	cd prestodb/foo && docker build -t prestodb/foo .
```

Using automatic variables we could shorten that to the following:

```
prestodb/foo: $@/Dockerfile $(extract_parent $@/Dockerfile)
	cd $@ && docker build -t $@ .
```

This is conceptually valid, but it doesn't work: Automatic variables aren't
available in the prerequisites. The solution to solve that is to use a
pattern rule:

```
$(images): %: %/Dockerfile $(extract_parent %/Dockerfile)
	...
```

That almost works. Almost because you can't use the stem (%) in a [function
call](https://www.gnu.org/savannah-checkouts/gnu/make/manual/html_node/Pattern-Rules.html).

Instead, we can use three features of make together to accomplish the same thing.

1. You can specify the same target multiple times with different
dependencies. Make will build all of the dependencies before running the
commands to build the target.
2. you can use the include directive to tell make to include another file.
3. If a file specified by an include directive doesn't exist, make will
look for a rule to create that file.

```
prestodb/foo: prestodb/foo_parent
prestodb/foo: prestodb/foo/Dockerfile
	...
```

The strategy is to include a separate file that specifies the dependency on
the parent image. This file isn't in the repo, so the Makefile has a rule to
make it from the image's Dockerfile. The second rule specifies the dependency
on the Dockerfile and builds the image using docker build.

[Recursive Make Considered Harmful](http://lcgapp.cern.ch/project/architecture/recursive_make.pdf)
explains this technique in section 5.4 and applies it to C source files and the
.h files they include. I've adapted it here.

The `bin/depend.sh` script generates a .d file in $(DEPDIR) from the Dockerfile for
the image:

```
$(DEPDIR)/prestodb/foo.d: prestodb/foo/Dockerfile
	...
```

The corresponding .d file will take one of two forms:

1. if foo's parent is built from this repository

   ```
   prestodb/foo: prestodb/foo_parent
   ```

2. if foo's parent should be pulled from dockerhub

   ```
   prestodb/foo:
   ```

In the first case, make now knows that foo_parent is a dependency of foo, and
builds it first.

In the second case, we don't add a dependency for make, and docker itself is
responsible for pulling foo's parent from dockerhub as part of the docker build
process.

A major difference between the approach explained in Recursive Make
Considered Harmful is that `bin/depend.sh` needs to know what images the repo knows
how to build so it can output the second form for parent images we *don't*
know how to build. We do this by passing in the names of all of the images we
know how to build.
