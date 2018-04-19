PROJECT?=git.soma.salesforce.com/dsp/ursa
REPO?=/go/src/${PROJECT}
APP?=ursa
PORT?=9090
BIN_HOME?=/bin

RELEASE?=0.0.1
COMMIT?=$(shell git rev-parse --short HEAD)
BUILD_TIME?=$(shell date -u '+%Y-%m-%d_%H:%M:%S')
CONTAINER_IMAGE?=${APP}
BUILD_CONTAINER?=${APP}-build

GOLANG_DOCKER_REGISTRY?=dva-registry.internal.salesforce.com
GOLANG_DOCKER_IMAGE?=${GOLANG_DOCKER_REGISTRY}/dva/golang:7
GOOS?=linux
GOARCH?=amd64

clean:
	rm -f ${APP}

test:
	go test -v -race ./...

go-build: clean
	CGO_ENABLED=0 GOOS=${GOOS} GOARCH=${GOARCH} go build \
		-ldflags "-s -w -X ${PROJECT}/version.Release=${RELEASE} \
		-X ${PROJECT}/version.Commit=${COMMIT} -X ${PROJECT}/version.BuildTime=${BUILD_TIME}" \
		-installsuffix cgo \
		-o ${APP}

build-darwin: clean
	CGO_ENABLED=0 GOOS=darwin GOARCH=${GOARCH} go build \
		-ldflags "-s -w -X ${PROJECT}/version.Release=${RELEASE} \
		-X ${PROJECT}/version.Commit=${COMMIT} -X ${PROJECT}/version.BuildTime=${BUILD_TIME}" \
		-installsuffix cgo \
		-o ${APP}

docker-build: clean
	# docker login $(GOLANG_DOCKER_REGISTRY)
	docker build -t $(BUILD_CONTAINER):$(RELEASE) -f Dockerfile.build \
		--build-arg GOLANG_DOCKER_IMAGE=$(GOLANG_DOCKER_IMAGE) \
		--build-arg APP=$(APP) \
		--build-arg REPO=$(REPO)  \
		--build-arg PROJECT=$(PROJECT) \
		--build-arg RELEASE=$(RELEASE) \
		--build-arg COMMIT=$(COMMIT) \
		--build-arg BUILD_TIME=$(BUILD_TIME) \
		.
	docker rm -f $(BUILD_CONTAINER) || true
	docker create --name $(BUILD_CONTAINER) $(BUILD_CONTAINER):$(RELEASE)
	docker cp $(BUILD_CONTAINER):$(REPO)/$(APP) .
	docker rm -f $(BUILD_CONTAINER)

run-darwin:build-darwin
	./${APP}

docker-build-and-run:docker-build
	./${APP}

go-build-and-run:go-build
	./${APP}

container: docker-build
	docker build -t $(CONTAINER_IMAGE):$(RELEASE) -f Dockerfile --build-arg APP=$(APP) --build-arg BIN_HOME=$(BIN_HOME)  .

docker-run: container
	docker stop $(APP):$(RELEASE) || true && docker rm $(APP):$(RELEASE) || true
	docker run -it -u 7447:7447 --name ${APP} -p ${PORT}:${PORT} --rm -e "PORT=${PORT}" $(APP):$(RELEASE) $(BIN_HOME)/$(APP)
	# docker run -it -u 7447:7447 --name ${APP} -p ${PORT}:${PORT}  -e "PORT=${PORT}" $(APP):$(RELEASE)

push: container
	docker push $(CONTAINER_IMAGE):$(RELEASE)
