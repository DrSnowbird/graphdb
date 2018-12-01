# GraphDB Free + Python 3 + Java 8 + Maven 3.5


## You need to get your own free download version for docker to build successfully
- Default Docker build-arg is set to use 8.4.0 version. You can change that in "docker.env" file.
```
GRAPHDB_VERSION=8.4.0
```
- You can go to Ontotext web site to register to download the free version, **graphdb-free-8.4.0-dist.zip**, and place in this directory as shown below.
- Then, you can use (build.sh: optional to build your own locally) run scripts to start using.
```
.
├── build.sh
├── commit-push.sh
├── docker-compose.yml
├── docker.env
├── Dockerfile
├── graphdb-free-8.4.0-dist.zip
├── Makefile (not recommended to use this)
├── README.md
└── run.sh

```

# Build (if you want to build your own image)
```
./build.sh
```

# Run
```
./run.sh
```

By default, you can access GraphDB Workbench Web UI at

* [http://0.0.0.0:17200/](http://0.0.0.0:17200/) 
* http://<ip_address>:17200/
