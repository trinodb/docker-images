# Teradata docker images

## Docker Image Names

The docker images in this repository are expected to be given names of the form
teradatalabs/cdh5-hive. The Dockerfile and other files needed to build the
teradatalabs/cdh5-hive image are located in the directory
teradatalabs/cdh5-hive.

Generally speaking, the images should *not* be built manually with docker
build.

## Building docker images

The docker images should be built using `make`. To build the docker image named
`teradatalabs/cdh5-hive`, run `make teradatalabs/cdh5-hive`. Make will build
the image and its dependencies in the correct order.

If you are going to release an image, you should release it and all of its
dependencies. Master and slave images should be be built from the same chain of
parent images. You can ensure that both are built from the same set of parent
images by running e.g. `make teradatalabs/cdh5-hive-master
terdatalabs/cdh5-hive-slave`

## Releasing (pushing) docker image

When you push (release) docker image to docker hub you should follow below  docker image releasing convention:
 - for snapshot versions (work in progress) a tag 'latest' should be updated and a separate tag should be created with git commit hash
 - for regular releases, all the rules of snapshot releasing applies and a new tag should be created with an increasing unique number. It is recommended to tag git version so it could be possible to match docker hub image version with source code version. Moreover we should avoid doing a release from other than master branch.

### Manual

Doing a snapshot release:

```
docker login
make teradatalabs/cdh5-hive
docker push teradatalabs/cdh5-hive:latest
docker tag teradatalabs/cdh5-hive:latest teradatalabs/cdh5-hive:<git_commit_head_commit_id>
docker push teradatalabs/cdh5-hive:<git_commit_head_commit_id>
```

Doing a release version:

```
# make sure you are on 'master' branch
docker login
make teradatalabs/cdh5-hive
docker push teradatalabs/cdh5-hive:latest
docker tag teradatalabs/cdh5-hive:latest teradatalabs/cdh5-hive:<git_commit_head_commit_id>
docker push teradatalabs/cdh5-hive:<git_commit_head_commit_id>
docker tag teradatalabs/cdh5-hive:latest teradatalabs/cdh5-hive:5
docker push teradatalabs/cdh5-hive:5
git tag teradatalabs/cdh5-hive/5
git push --tags
```

### Using docker-release tool

See https://github.com/kokosing/docker-release

Doing a snapshot:

```
docker login
docker-release -s teradatalabs/cdh5-hive
```

Doing a release version:

```
docker login
docker-release teradatalabs/cdh5-hive
```
 
## How the build system works.

At a high level, a docker image depends on two things:

1. Its Dockerfile
2. Its parent image, specified by the from FROM line in the Dockerfile.

Using the relative directory from the root of the repo as the image name, we
could, in principle, write a rule of the form

```
teradatalabs/foo: teradatalabs/foo/Dockerfile $(extract_parent teradatalabs/foo/Dockerfile)
	cd teradatalabs/foo && docker build -t teradatalabs/foo .
```

Using automatic variables we could shorten that to the following:

```
teradatalabs/foo: $@/Dockerfile $(extract_parent $@/Dockerfile)
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
teradatalabs/foo: teradatalabs/foo_parent
teradatalabs/foo: teradatalabs/foo/Dockerfile
	...
```

The strategy is to include a separate file that specifies the dependency on
the parent image. This file isn't in the repo, so the Makefile has a rule to
make it from the image's Dockerfile. The second rule specifies the dependency
on the Dockerfile and builds the image using docker build.

[Recursive Make Considered Harmful](http://lcgapp.cern.ch/project/architecture/recursive_make.pdf)
explains this technique in section 5.4 and applies it to C source files and the
.h files they include. I've adapted it here.

The depend.sh script generates a .d file in $(DEPDIR) from the Dockerfile for
the image:

```
$(DEPDIR)/teradatalabs/foo.d: teradatalabs/foo/Dockerfile
	...
```

The corresponding .d file will take one of two forms:

1. if foo's parent is built from this repository

   ```
   teradatalabs/foo: teradatalabs/foo_parent
   ```

2. if foo's parent should be pulled from dockerhub

   ```
   teradatalabs/foo:
   ```

In the first case, make now knows that foo_parent is a dependency of foo, and
builds it first.

In the second case, we don't add a dependency for make, and docker itself is
responsible for pulling foo's parent from dockerhub as part of the docker build
process.

A major difference between the approach explained in Recursive Make
Considered Harmful is that depend.sh needs to know what images the repo knows
how to build so it can output the second form for parent images we *don't*
know how to build. We do this by passing in the names of all of the images we
know how to build.
