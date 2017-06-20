#
# For normal use, VERSION should be a snapshot version. I.e. one ending in
# -SNAPSHOT, such as 35-SNAPSHOT
#
# When a version is final, do the following:
# 1) Change VERSION to a non-SNAPSHOT release: 35-SNAPSHOT -> 35
# 2) Commit the repo
# 3) `make release' to push the images to dockerhub and tag the repo
# 4) Change VERSION to tne next SHAPSHOT release: 35 -> 36-SNAPSHOT
# 5) Commit
# 6) Continue developing
# 7) `make snapshot' as needed to push snapshot images to dockerhub
#
VERSION := 18
RELEASE_TYPE := $(if $(filter %-SNAPSHOT, $(VERSION)),snapshot,release)

LABEL := com.teradata.git.hash=$(shell git rev-parse HEAD)

DEPEND_SH=depend.sh
FLAG_SH=flag.sh
FIND_BROKEN_SYMLINKS_SH=find_broken_symlinks.sh
DEPDIR=depends
FLAGDIR=flags

ORGDIR=teradatalabs

#
# This should be the only place you need to touch to update the version of Java
# we install in the images. Every other variable should be derived directly or
# indirectly from this one, and you should pass those variables to the
# Dockerfiles using ARG and --build-arg.
#
JDK_URL := http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jdk-8u131-linux-x64.rpm
JDK_RPM := $(notdir $(JDK_URL))
INSTALL_JDK_BUILD_ARGS := \
	--build-arg JDK_URL=$(JDK_URL) \
	--build-arg JDK_RPM=$(JDK_RPM)

#
# Generate path to installed JDK from the JDK RPM name.
#
# Assumes that the Java version number in the installed JDK path will remain in
# the format 1.<major version>.0_<update number>
#
# jdk-8u92-linux-x64.rpm -> /usr/java/jdk1.8.0_92/
#
# Use only BREs in sed for cross-platform compatibility.
#
JDK_PATH := $(shell echo $(JDK_RPM) | \
       	sed 's!jdk-\([0-9][0-9]*\)u\([0-9][0-9]*\).*!/usr/java/jdk1.\1.0_\2!')
JDK_PATH_BUILD_ARGS := \
	--build-arg JDK_PATH=$(JDK_PATH)

#
# In theory, we could just find all of the Dockerfiles and derive IMAGE_DIRS
# from that, but make's dir function includes the trailing slash, which we'd
# have to strip off to get a valid Docker image name.
#
# Also, find on Mac doesn't support -exec {} +
#
# Note that the generated .d files also include reverse dependencies so that
# you can e.g. `make cdh5-hive.dependants' and cdh5-hive, and all of its
# dependent images will be rebuilt. This is used in .travis.yml to break the
# build up into pieces based on image that have a large number of direct and
# indirect children.
#
IMAGE_DIRS=$(shell find $(ORGDIR) -type f -name Dockerfile -exec dirname {} \;)
DOCKERFILES:=$(addsuffix /Dockerfile,$(IMAGE_DIRS))
DEPS:=$(foreach dockerfile,$(DOCKERFILES),$(DEPDIR)/$(dockerfile:/Dockerfile=.d))
FLAGS:=$(foreach dockerfile,$(DOCKERFILES),$(FLAGDIR)/$(dockerfile:/Dockerfile=.flags))

#
# Make a list of the Docker images we depend on, but aren't built from
# Dockerfiles in this repository. Order doesn't matter, but sort() has the
# side-effect of making the list unique.
#
EXTERNAL_DEPS := \
	$(sort \
		$(foreach dockerfile,$(DOCKERFILES),\
			$(shell $(SHELL) $(DEPEND_SH) -x $(dockerfile) $(DOCKERFILES))))

#
# Images that can be tested have a capabilities file in their directory. The
# reverse dependencies for tests are handled here. They're listed in separate
# files to avoid having to deal with dependencies between .d and .test.rd files.
#
TESTABLE_IMAGES=$(shell find $(ORGDIR) -type f -name capabilities.txt -exec dirname {} \;)
IMAGE_TESTS=$(addprefix test-,$(TESTABLE_IMAGES))
TEST_RDEPS=$(foreach testable_image,$(TESTABLE_IMAGES),$(DEPDIR)/$(testable_image).test.rd)

#
# The image directories exist in the filesystem. Make them .PHONY so make
# actually builds them.
#
.PHONY: $(IMAGE_DIRS) $(IMAGE_TESTS) $(EXTERNAL_DEPS) $(TEST_RDEPS)

# By default, build all of the images.
all: images tests

images: $(IMAGE_DIRS)

tests: $(IMAGE_TESTS)

#
# Release images to Dockerhub using docker-release
# https://github.com/kokosing/docker-release
#
.PHONY: release snapshot
release: all
	[ "$(RELEASE_TYPE)" = "$@" ] || ( echo "$(VERSION) is not a $@ version"; exit 1 )
	docker-release --no-build --release $(VERSION) --tag-once $^

snapshot: all
	[ "$(RELEASE_TYPE)" = "$@" ] || ( echo "$(VERSION) is not a $@ version"; exit 1 )
	docker-release --no-build --snapshot --tag-once $^

#
# For generating/cleaning the depends directory without building any images.
# Because the Makefile includes the .d files, and will create them if they
# don't exist, an empty target is sufficient to get make to rebuild the
# dependencies if needed. This is mostly useful for testing changes to the
# script that creates the .d files.
#
.PHONY: dep clean-dep flag clean-flag check-links
dep:

clean-dep:
	-rm -r $(DEPDIR)

flag:

clean-flag:
	-rm -r $(FLAGDIR)

check-links:
	$(SHELL) $(FIND_BROKEN_SYMLINKS_SH)

#
# Include the dependencies for every image we know how to build. These don't
# exist in the repo, but the next rule specifies how to create them. Make will
# run that rule for every .d file in $(DEPS).
#
include $(DEPS)
include $(FLAGS)
include $(TEST_RDEPS)

$(DEPDIR)/%.d: %/Dockerfile $(DEPEND_SH)
	-mkdir -p $(dir $@)
	$(SHELL) $(DEPEND_SH) $< $(IMAGE_DIRS) >$@

$(FLAGDIR)/%.flags: %/Dockerfile $(FLAG_SH)
	-mkdir -p $(dir $@)
	$(SHELL) $(FLAG_SH) $< >$@

#
# Generate .test.rd files, adding a test target for an image to the dependants
# of its corresponding image.
#
# Note that the .test.rd files need to be updated if the Makefile changes
# because the Makefile is what generates the .test.rd files.
#
$(TEST_RDEPS): depends/%.test.rd: Makefile
	-mkdir -p $(dir $@)
	echo $*.dependants: test-$* >"$@"

#
# Finally, the static pattern rule that actually invokes docker build. If
# teradatalabs/foo has a dependency on a foo_parent image in this repo, make
# knows about it via the included .d file, and builds foo_parent before it
# builds foo.
#
# We don't need to specify any dependencies other than the Dockerfile for the
# image because these are .PHONY targets. In particular, if the DBFLAGS for an
# image have changed without the Dockerfile changing, it's OK because we'll
# invoke docker build for the image anyway and let Docker figure out if
# anything has changed that requires a rebuild.
#
$(IMAGE_DIRS): %: %/Dockerfile check-links
	@echo
	@echo "Building [$*] image"
	@echo
	cd $(dir $<) && time $(SHELL) -c "( tar -czh . | docker build $(DBFLAGS_$@) -t $@ --label $(LABEL) - )"

$(IMAGE_TESTS): test-%: % %/capabilities.txt
	@echo "Running tests for [$*]"
	@echo
	export TESTED_IMAGE=$* && \
	  cd test && \
	  docker-compose up -t 0 -d hadoop-master && \
	  time docker-compose run -e EXPECTED_CAPABILITIES="`cat ../$*/capabilities.txt | tr '\n' ' '`" --rm test-runner

#
# Static pattern rule to pull docker images that are external dependencies of
# this repository.
#
# Note that the $(DEPEND_SH) script substitutes : -> @ in the image:tag of
# external dependencies because there's no way to escape a colon in a target or
# prerequisite name[0]. The subst() function reverses this transformation for
# docker pull.
#
# [0] http://www.mail-archive.com/bug-make@gnu.org/msg03318.html
#
$(EXTERNAL_DEPS): %:
	docker pull $(subst @,:,$@)
