package main

import (
	"context"
	"flag"
	"fmt"
	"net"

	pb "github.com/AWildBeard/oneway-grpc/oneway"
	"google.golang.org/grpc"
)

var (
	port int
)

func init() {
	flag.IntVar(&port, "port", 10001, "Specify the port that the gRPC server will be started on")
}

func main() {
	flag.Parse()

	var server = grpc.NewServer()
	var onewayServer = onewayServer{}
	if sckt, err := net.Listen("tcp", fmt.Sprintf(":%d", port)); err == nil {

		pb.RegisterOneWayServer(server, &onewayServer)
		server.Serve(sckt)
	} else {
		fmt.Printf("Failed to open socket on port %d. Port may be in use.\n", port)
		return
	}
}

type onewayServer struct{}

func (ons *onewayServer) SendMessage(cntx context.Context, req *pb.HelloRequest) (*pb.HelloResponse, error) {
	fmt.Printf("Received message: %s\n", req.GetMsg())

	return &pb.HelloResponse{Code: 0}, nil
}
