#include "../oneway/oneway.grpc.pb.h"
#include "../oneway/oneway.pb.h"

#include <iostream>
#include <grpc/grpc.h>
#include <grpcpp/server.h>
#include <grpcpp/server_builder.h>
#include <grpcpp/server_context.h>
#include <grpcpp/security/server_credentials.h>

using grpc::Server;
using grpc::ServerBuilder;
using grpc::ServerContext;
using grpc::ServerReader;
using grpc::ServerReaderWriter;
using grpc::ServerWriter;
using grpc::Status;
using oneway::OneWay;

class OneWayImpl final : public OneWay::Service {
    public:

    // We just want the message from the 'request'
    Status SendMessage(::grpc::ServerContext* context, const ::oneway::HelloRequest* request, ::oneway::HelloResponse* response) {
        std::cout << "got message: " << request->msg() << std::endl;
        response->set_code(0); // Be sure to set the response code.

        return Status::OK;
    }

    private:
};

// This function is a hard copy-paste from the docs with minimal changes
void RunServer() {
    std::string server_address("0.0.0.0:10001");
    OneWayImpl service;

    ServerBuilder builder;
    builder.AddListeningPort(server_address, grpc::InsecureServerCredentials());
    builder.RegisterService(&service);

    std::unique_ptr<Server> server(builder.BuildAndStart());
    std::cout << "Server listening on " << server_address << std::endl;

    server->Wait();
}

// God I feel like a scrub
int main() {

    RunServer();
    
    return 0;
}
