CFSSL=`which cfssl`
CFSSLJSON=`which cfssljson`

CFSSL ?= docker run --rm -v `pwd`:/etc/cfssl dhiltgen/cfssl
CFSSLJSON ?= docker run -i --rm -v `pwd`:/etc/cfssl --entrypoint cfssljson dhiltgen/cfssl

CLIENT ?= client

all: gen-ca gen-server

gen-ca:
	${CFSSL} gencert -initca ca-csr.json | \
	${CFSSLJSON} -bare ca

gen-server:
	mkdir -p ./server
	${CFSSL} gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=swarm swarm-csr.json | \
	${CFSSLJSON} -bare ./server/server

gen-client-certs:
	mkdir -p ./clients
	echo '{"CN":"${CLIENT}","hosts":[""],"key":{"algo":"rsa","size":2048}}' > ./clients/${CLIENT}-csr.json
	${CFSSL} gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=client ./clients/${CLIENT}-csr.json | \
	${CFSSLJSON} -bare ./clients/${CLIENT}
