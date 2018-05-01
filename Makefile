PORT=10053
GIMG=golang:1.10
IMG=unimock/docker-ddns:develop

image:
	docker build -t ${IMG} .

console:
	docker run -it -p 8080:8080 -p ${PORT}:53 -p ${PORT}:53/udp --rm ${IMG} bash

devconsole:
	docker run -it --rm -v ${PWD}/rest-api:/usr/src/app -w /usr/src/app ${GIMG} bash

server_test:
	docker run -it --name dyndns -p 8080:8080 -p ${PORT}:53 -p ${PORT}:53/udp --env-file envfile --rm ${IMG}
	
server_login:
	docker exec -it dyndns bash

unit_tests:
	docker run -it --rm -v ${PWD}/rest-api:/go/src/dyndns -w /go/src/dyndns ${GIMG} bash -c "go get && go test -v"

api_test:
	curl "http://localhost:8080/update?secret=changeme&domain=foo&addr=1.2.3.4&info=INFO_OK"
	dig -p ${PORT} @localhost foo.example.org
	dig -p ${PORT} @localhost foo.example.org TXT

api_test_multiple_domains:
	curl "http://localhost:8080/update?secret=changeme&domain=foo,bar,baz&addr=1.2.3.4"
	dig -p ${PORT} @localhost foo.example.org
	dig -p ${PORT} @localhost bar.example.org
	dig -p ${PORT} @localhost baz.example.org

api_test_invalid_params:
	curl "http://localhost:8080/update?secret=changeme&addr=1.2.3.4"
	dig -p ${PORT} @localhost foo.example.org

api_test_recursion:
	dig -p ${PORT} @localhost google.com

deploy: image
	docker run -it -d -p 8080:8080 -p ${PORT}:53 -p ${PORT}:53/udp --env-file envfile --name=dyndns ${IMG}
	
push: image
	docker login
	docker push ${IMG}
