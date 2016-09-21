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
VERSION := 7-SNAPSHOT
RELEASE_TYPE := $(if $(filter %-SNAPSHOT, $(VERSION)),snapshot,release)

DEPEND_SH=depend.sh
DEPDIR=depends

ORGDIR=teradatalabs

#
# In theory, we could just find all of the Dockerfiles and derive IMAGE_DIRS
# from that, but make's dir function includes the trailing slash, which we'd
# have to strip off to get a valid Docker image name.
#
# Also, find on Mac doesn't support -exec {} +
#
IMAGE_DIRS=$(shell find $(ORGDIR) -type f -name Dockerfile -exec dirname {} \;)
DOCKERFILES:=$(addsuffix /Dockerfile,$(IMAGE_DIRS))
DEPS:=$(foreach dockerfile,$(DOCKERFILES),$(DEPDIR)/$(dockerfile:/Dockerfile=.d))

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
# The image directories exist in the filesystem. Make them .PHONY so make
# actually builds them.
#
.PHONY: $(IMAGE_DIRS) $(EXTERNAL_DEPS)

# By default, build all of the images.
all: $(IMAGE_DIRS)

#
# Release images to Dockerhub using docker-release
# https://github.com/kokosing/docker-release
#
.PHONY: release snapshot
release: $(IMAGE_DIRS)
	[ "$(RELEASE_TYPE)" = "$@" ] || ( echo "$(VERSION) is not a $@ version"; exit 1 )
	docker-release --no-build --release $(VERSION) --tag-once $^

snapshot: $(IMAGE_DIRS)
	[ "$(RELEASE_TYPE)" = "$@" ] || ( echo "$(VERSION) is not a $@ version"; exit 1 )
	docker-release --no-build --snapshot --tag-once $^

#
# For generating/cleaning the depends directory without building any images.
# Because the Makefile includes the .d files, and will create them if they
# don't exist, an empty target is sufficient to get make to rebuild the
# dependencies if needed. This is mostly useful for testing changes to the
# script that creates the .d files.
#
.PHONY: dep clean-dep
dep:

clean-dep:
	-rm -r $(DEPDIR)

#
# Include the dependencies for every image we know how to build. These don't
# exist in the repo, but the next rule specifies how to create them. Make will
# run that rule for every .d file in $(DEPS).
#
include $(DEPS)

$(DEPDIR)/%.d: %/Dockerfile $(DEPEND_SH)
	-mkdir -p $(dir $@)
	$(SHELL) $(DEPEND_SH) $< $(IMAGE_DIRS) >$@

#
# Finally, the static pattern rule that actually invokes docker build. If
# teradatalabs/foo has a dependency on a foo_parent image in this repo, make
# knows about it via the included .d file, and builds foo_parent before it
# builds foo.
#
$(IMAGE_DIRS): %: %/Dockerfile
	cd $(dir $<) && docker build -t $@ .

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
