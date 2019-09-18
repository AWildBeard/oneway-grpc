#include "../oneway/oneway.grpc.pb.h"
#include "../oneway/oneway.pb.h"

#include <grpc/grpc.h>
#include <grpcpp/channel.h>
#include <grpcpp/client_context.h>
#include <grpcpp/create_channel.h>
#include <grpcpp/security/credentials.h>

using grpc::Channel;
using grpc::ClientContext;
using grpc::ClientReader;
using grpc::ClientReaderWriter;
using grpc::ClientWriter;
using grpc::Status;
using oneway::HelloRequest;
using oneway::HelloResponse;
using oneway::OneWay;

class OneWayClient {
    public:
    OneWayClient(std::shared_ptr<Channel> channel) : stub_(OneWay::NewStub(channel)) {}
    int SendMessage(const HelloRequest& req) {
        ClientContext context;
        HelloResponse rsp;
        Status status = stub_->SendMessage(&context, req, &rsp);

        return (status.ok())? rsp.code() : -1;
    }
    private:
    std::unique_ptr<OneWay::Stub> stub_;
};

int main(void) {
    OneWayClient client(grpc::CreateChannel("127.0.0.1:10001", 
                                            grpc::InsecureChannelCredentials()));

    HelloRequest req;
    std::string message = "Hello World! From c++!";
    req.set_msg(message);

    std::cout << "Got response: " << client.SendMessage(req) << std::endl;

    return 0;
}