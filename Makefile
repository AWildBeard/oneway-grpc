GO = go build -o 
GO_CLIENT_SOURCES := golang/client/client.go
GO_CLIENT_OUT := golang/client/go_client
GO_SERVER_SOURCES := golang/server/server.go
GO_SERVER_OUT := golang/server/go_server

PROTOC = protoc

CXX = g++
CPP_SERVER_SOURCES := cpp/server/server.cpp
CPP_CLIENT_SOURCES := cpp/client/client.cpp
CPP_SERVER_OUT := cpp/server/cpp_server
CPP_CLIENT_OUT := cpp/client/cpp_client
CPPFLAGS += `pkg-config --cflags protobuf grpc`
LDFLAGS += -L/usr/lib `pkg-config --libs protobuf grpc++`\
			-pthread \
			-Wl,--no-as-needed -lgrpc++_reflection -Wl,--as-needed\
			-ldl

GRPC_CPP_PLUGIN := grpc_cpp_plugin 
GRPC_CPP_PLUGIN_PATH ?= `which $(GRPC_CPP_PLUGIN)`

PROTO_PATH = proto/
CPP_PROTO_OUT = cpp/oneway/
GOLANG_PROTO_OUT = golang/oneway/

vpath %.proto $(PROTO_PATH)

all: go_server go_client cpp_server cpp_client
	@echo ""
	@echo "The golang server is @ $(GO_SERVER_OUT)"
	@echo "The golang client is @ $(GO_CLIENT_OUT)"
	@echo "The  cpp   server is @ $(CPP_SERVER_OUT)"
	@echo "The  cpp   client is @ $(CPP_CLIENT_OUT)"

go_server: oneway.pb.go
	@echo ""
	@echo "Compiling golang server target"
	$(GO) $(GO_SERVER_OUT) $(GO_SERVER_SOURCES)

go_client: oneway.pb.go
	@echo ""
	@echo "Compiling golang client target"
	$(GO) $(GO_CLIENT_OUT) $(GO_CLIENT_SOURCES)

cpp_server: oneway.pb.cc oneway.grpc.pb.cc
	@echo ""
	@echo "Compiling cpp server target"
	$(CXX) \
	$(CPP_PROTO_OUT)$(word 1, $^) $(CPP_PROTO_OUT)$(word 2, $^) $(CPP_SERVER_SOURCES) \
	$(LDFLAGS) -o $(CPP_SERVER_OUT)

cpp_client: oneway.pb.cc oneway.grpc.pb.cc
	@echo ""
	@echo "Compiling cpp client target"
	$(CXX) \
		$(CPP_PROTO_OUT)$(word 1, $^) $(CPP_PROTO_OUT)$(word 2, $^) $(CPP_CLIENT_SOURCES) \
		$(LDFLAGS) -o $(CPP_CLIENT_OUT)

%.grpc.pb.cc: %.proto
	@$(PROTOC) -I $(PROTO_PATH) --grpc_out=$(CPP_PROTO_OUT) --plugin=protoc-gen-grpc=$(GRPC_CPP_PLUGIN_PATH) $<

%.pb.cc: %.proto
	@$(PROTOC) -I $(PROTO_PATH) --cpp_out=$(CPP_PROTO_OUT) $<

%.pb.go: %.proto
	@$(PROTOC) -I $(PROTO_PATH) --go_out=plugins=grpc:$(GOLANG_PROTO_OUT) $<

clean:
	find cpp/ -type f -not -name '.gitignore' -not -name 'server.cc' -delete
	find golang/ -type f -not -name 'client.go' -not -name 'server.go' -not -name '.gitignore' -delete
