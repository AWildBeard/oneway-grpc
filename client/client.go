package main

import (
	"context"
	"fmt"

	pb "github.com/AWildBeard/oneway-grpc/oneway"
	"google.golang.org/grpc"
)

func main() {
	fmt.Println("Hello World!")
	var client pb.OneWayClient
	if conn, err := grpc.Dial("127.0.0.1:10001", grpc.WithInsecure()); err == nil {
		defer conn.Close()
		client = pb.NewOneWayClient(conn)
	} else {
		fmt.Printf("Failed to dial server: %v\n", err)
		return
	}

	var req = pb.HelloRequest{}
	req.Msg = "Hello World!"
	if rsp, err := client.SendMessage(context.Background(), &req); err == nil {
		fmt.Printf("Got response: %v\n", rsp.GetCode())
	} else {
		fmt.Printf("Failed to SendMessage: %v\n", err)
	}
}
