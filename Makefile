DEPEND_SH=depend.sh
DEPDIR=depends

ORGDIR=teradatalabs

#
# In theory, we could just find all of the Dockerfiles and derive IMAGE_DIRS
# from that, but make's dir function includes the trailing slash, which we'd
# have to strip off to get a valid Docker tag name.
#
# Also, find on Mac doesn't support -exec {} +
#
IMAGE_DIRS=$(shell find $(ORGDIR) -type f -name Dockerfile -exec dirname {} \;)
DOCKERFILES:=$(addsuffix /Dockerfile,$(IMAGE_DIRS))
DEPS:=$(foreach dockerfile,$(DOCKERFILES),$(DEPDIR)/$(dockerfile:/Dockerfile=.d))

#
# The image directories exist in the filesystem. Make them .PHONY so make
# actually builds them.
#
.PHONY: $(IMAGE_DIRS)

# By default, build all of the images.
all: $(IMAGE_DIRS)

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
# Finally, the pattern rule that actually invokes docker build. If
# teradatalabs/foo has a dependency on a foo_parent image in this repo, make
# knows about it via the included .d file, and builds foo_parent before it
# builds foo.
#
$(IMAGE_DIRS): %: %/Dockerfile
	cd $(dir $<) && docker build -t $@ .
