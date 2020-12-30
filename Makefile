#
# For normal use, VERSION should be a snapshot version. I.e. one ending in
# -SNAPSHOT, such as 35-SNAPSHOT
#
# When a version is final, do the following:
# 1) Change VERSION to a non-SNAPSHOT release: 35-SNAPSHOT -> 35
# 2) Commit the repo
# 3) `make release' to push the images to dockerhub
# 4) Change VERSION to tne next SNAPSHOT release: 35 -> 36-SNAPSHOT
# 5) Commit
# 6) Continue developing
# 7) `make snapshot' as needed to push snapshot images to dockerhub
#
VERSION := 37-SNAPSHOT
RELEASE_TYPE := $(if $(filter %-SNAPSHOT, $(VERSION)),snapshot,release)

LABEL := io.prestosql.git.hash=$(shell git rev-parse HEAD)

LABEL_PARENT_SH=bin/label-parent.sh
DEPEND_SH=bin/depend.sh
FLAG_SH=bin/flag.sh
PUSH_SH=bin/push.sh
TEST_SH=bin/test.sh
BUILDDIR=build
DEPDIR=$(BUILDDIR)/depends
FLAGDIR=$(BUILDDIR)/flags
ORGDIR=prestodev

#
# In theory, we could just find all of the Dockerfiles and derive IMAGE_DIRS
# from that, but make's dir function includes the trailing slash, which we'd
# have to strip off to get a valid Docker image name.
#
# Also, find on Mac doesn't support -exec {} +
#
# Note that the generated .d files also include reverse dependencies so that
# you can e.g. `make hdp2.6-base.dependants' and hdp2.6-hive, and all of its
# dependent images will be rebuilt. This is used in .travis.yml to break the
# build up into pieces based on image that have a large number of direct and
# indirect children.
#
IMAGE_DIRS := $(shell find $(ORGDIR) -type f -name Dockerfile -exec dirname {} \;)
UNLABELLED_TAGS := $(addsuffix @unlabelled,$(IMAGE_DIRS))
PARENT_CHECKS := $(addsuffix -parent-check,$(IMAGE_DIRS))
LATEST_TAGS := $(addsuffix @latest,$(IMAGE_DIRS))
VERSION_TAGS := $(addsuffix @$(VERSION),$(IMAGE_DIRS))
GIT_HASH := $(shell git rev-parse --short HEAD)
GIT_HASH_TAGS := $(addsuffix @$(GIT_HASH),$(IMAGE_DIRS))
DOCKERFILES := $(addsuffix /Dockerfile,$(IMAGE_DIRS))
DEPS := $(foreach dockerfile,$(DOCKERFILES),$(DEPDIR)/$(dockerfile:/Dockerfile=.d))
FLAGS := $(foreach dockerfile,$(DOCKERFILES),$(FLAGDIR)/$(dockerfile:/Dockerfile=.flags))

RELEASE_TAGS := $(VERSION_TAGS) $(LATEST_TAGS)
SNAPSHOT_TAGS := $(GIT_HASH_TAGS)

#
# Make a list of the Docker images we depend on, but aren't built from
# Dockerfiles in this repository. Order doesn't matter, but sort() has the
# side-effect of making the list unique.
#
EXTERNAL_DEPS = \
	$(sort \
		$(foreach dockerfile,$(DOCKERFILES),\
			$(shell $(SHELL) $(DEPEND_SH) -x $(dockerfile) $(call docker-tag,$(UNLABELLED_TAGS)))))

#
# Image tags in the Makefile use @ instead of : in full image:tag names.  This
# is because there's no way to escape a colon in a target or prerequisite
# name[0]. docker-tag reverses this transformation for places where we need to
# interact with docker using its image:tag convention.
#
# [0] http://www.mail-archive.com/bug-make@gnu.org/msg03318.html
#
# Must be a recursively expanded variable to use with $(call ...)
#
docker-tag = $(subst @,:,$(1))

#
# Various variables that define targets need to be .PHONY so that Make
# continues to build them if a file with a matching name somehow comes into
# existence
#
.PHONY: $(IMAGE_DIRS) $(LATEST_TAGS) $(UNLABELLED_TAGS) $(VERSION_TAGS) $(GIT_HASH_TAGS)
.PHONY: $(PARENT_CHECKS) $(IMAGE_TESTS) $(EXTERNAL_DEPS)

# By default, build all of the images.
all: images

images: $(LATEST_TAGS)

#
# Release images to Dockerhub
#
.PHONY: release push-release snapshot push-snapshot

release: require-clean-repo require-on-master require-release-version push-release

push-release: $(RELEASE_TAGS)
	$(SHELL) $(PUSH_SH) $(call docker-tag,$^)

snapshot: require-clean-repo require-snapshot-version push-snapshot

push-snapshot: $(SNAPSHOT_TAGS)
	$(SHELL) $(PUSH_SH) $(call docker-tag,$^)

#
# Create tags without pushing. This is probably only useful for testing.
#
.PHONY: release-tags snapshot-tags
release-tags: $(RELEASE_TAGS)
snapshot-tags: $(SNAPSHOT_TAGS)

#
# Targets for sanity-checking the repo prior to doing a release or snapshot.
# Use $(shell git ...) so the output of the git command shows up on the command
# line.
#
.PHONY: require-clean-repo require-on-master
require-clean-repo:
	test -z "$(shell git status --porcelain)" || ( echo "Repository is not clean"; exit 1 )

require-on-master:
	test "$(shell git rev-parse --abbrev-ref HEAD)" = "master" || ( echo "Current branch must be master"; exit 1 )

require-%-version:
	[ "$(RELEASE_TYPE)" = "$*" ] || ( echo "$(VERSION) is not a $* version"; exit 1 )

#
# For generating/cleaning the depends directory without building any images.
# Because the Makefile includes the .d files, and will create them if they
# don't exist, an empty target is sufficient to get make to rebuild the
# dependencies if needed. This is mostly useful for testing changes to the
# script that creates the .d files.
#
.PHONY: meta
meta:

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
	$(SHELL) $(DEPEND_SH) -d $< $(call docker-tag,$(UNLABELLED_TAGS)) >$@

$(FLAGDIR)/%.flags: %/Dockerfile $(FLAG_SH)
	-mkdir -p $(dir $@)
	$(SHELL) $(FLAG_SH) $< >$@

#
# Images in the repo that are built FROM other images in the repo are built
# from the special tag `unlabelled'. This is because LABEL data creates a new
# layer in the image. Without building from the `unlabelled' tag, all direct or
# indirect child images have to be fully rebuilt when the LABEL data changes.
# Since we include the git hash in the LABEL data, this changes frequently.
#
# We take the approach of building the :latest tag first, then finding the
# parent of the layer containing the LABEL information, and tagging that as
# :unlabelled. This works because all of the LABEL information applied via a
# --label option(s) to `docker build' is put in a single layer at the top of
# the resulting stack of layers.
#
$(UNLABELLED_TAGS): %@unlabelled: %/Dockerfile %@latest
	docker tag $(shell $(SHELL) $(LABEL_PARENT_SH) $*:latest) $(call docker-tag,$@)

#
# We don't need to specify any (real) dependencies other than the Dockerfile
# for the image because these are .PHONY targets. In particular, if the DBFLAGS
# for an image have changed without the Dockerfile changing, it's OK because
# we'll invoke docker build for the image anyway and let Docker figure out if
# anything has changed that requires a rebuild.
#
$(LATEST_TAGS): %@latest: %/Dockerfile %-parent-check
	@echo
	@echo "Building [$@] image"
	@echo
	cd $* && time $(SHELL) -c "( tar -czh . | docker build ${BUILD_ARGS} $(DBFLAGS_$*) -t $(call docker-tag,$@) --label $(LABEL) - )"
	docker history $(call docker-tag,$@)

$(VERSION_TAGS): %@$(VERSION): %@latest
	docker tag $(call docker-tag,$^) $(call docker-tag,$@)

$(GIT_HASH_TAGS): %@$(GIT_HASH): %@latest
	docker tag $(call docker-tag,$^) $(call docker-tag,$@)

#
# Verify that the parent image specified in the Dockerfile is either
# 1. External
# 2. Has the tag :unlabelled
#
$(PARENT_CHECKS): %-parent-check: %/Dockerfile $(DEPEND_SH)
	$(SHELL) $(DEPEND_SH) -p unlabelled $< $(call docker-tag,$(UNLABELLED_TAGS))

#
# This makes it possible it possible to type `make prestodev/image' without
# specifying @latest
#
$(IMAGE_DIRS): %: %@latest

#
# Static pattern rule to pull docker images that are external dependencies of
# this repository.
#
$(EXTERNAL_DEPS): %:
	docker pull $(call docker-tag,$@)

#
# Targets and variables for creating the dependency graph of the docker images
# as an image file.
#
GVDIR=$(BUILDDIR)/graphviz
GVWHOLE=$(GVDIR)/dependency_graph.gv
DEPENDENCY_GRAPH=$(GVDIR)/dependency_graph.svg
GVFRAGS=$(addprefix $(GVDIR)/,$(addsuffix .gv.frag,$(IMAGE_DIRS)))

.PHONY: graph
graph: $(DEPENDENCY_GRAPH)

$(DEPENDENCY_GRAPH): $(GVWHOLE) Makefile
	dot -T svg $(filter %.gv,$^) > $@

$(GVWHOLE): $(GVFRAGS) Makefile
	echo "digraph {" >$@
	echo 'size="14!" pack=true packmode="array2"' >>$@
	cat $(filter %.gv.frag,$^) >>$@
	echo "}" >>$@

$(GVFRAGS): $(GVDIR)/%.gv.frag: %/Dockerfile $(DEPEND_SH)
	-mkdir -p $(dir $@)
	$(SHELL) $(DEPEND_SH) -g $< $(call docker-tag,$(UNLABELLED_TAGS)) >$@

.PHONY: test
test: 
	$(TEST_SH) $(IMAGE_TO_TEST)

.PHONY: clean
clean:
	-rm -r $(BUILDDIR)
