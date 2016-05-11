# Teradata docker images

## Releasing (pushing) docker image

When you push (release) docker image to docker hub you should follow below  docker image releasing convention:
 - for snapshot versions (work in progress) a tag 'latest' should be updated and a separate tag should be created with git commit hash
 - for regular releases, all the rules of snapshot releasing applies and a new tag should be created with an increasing unique number. It is recommended to tag git version so it could be possible to match docker hub image version with source code version. Moreover we should avoid doing a release from other than master branch.

### Manual

Doing a snapshot release:

```
docker login
cd teradatalabs/cdh5-hive
docker build -t teradatalabs/cdh5-hive:latest .
docker push teradatalabs/cdh5-hive:latest
docker tag teradatalabs/cdh5-hive:latest teradatalabs/cdh5-hive:<git_commit_head_commit_id>
docker push teradatalabs/cdh5-hive:<git_commit_head_commit_id>
```

Doing a release version:

```
# make sure you are on 'master' branch
docker login
cd teradatalabs/cdh5-hive
docker build -t teradatalabs/cdh5-hive:latest .
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
 
