// Protocol Buffers
/*
	A method of SERIALIZING STRUCTURED DATA; useful as RPC mechanism; for comms over a wire, or for storing data; includes an INTERFACE DESCRIPTION LANGUAGE that describes the structure of some data and a program that generates source code from that description for generating or parsing a stream of bytes that represents the structured data.

	Protocol buffer data is structured as messages, where each message is a small logical record of information containing a series of name-value pairs called fields @ `.proto` file; data structure is self-describing format; stored/transmitted/handled in BINARY FORM;

	Go compiler & gRPC plugin generate both CLIENT and SERVER -side code from the data structure file, `protoc`.

	.proto
		PROTO DEFINITION FILE; defines data structures (called messages) and services.package f06ygo

	protoc
		.proto COMPILER; generates code that can be invoked by a sender or recipient of these data structures. For example,

		E.g., `example.proto` is compiled into `example.pb.cc` and `example.pb.h`, which will define C++ classes for each message and service that `example.proto` defines.

	Messages are serialized into a binary wire format which is compact, forward- and backward-compatible, but NOT SELF-DESCRIBING.

	Wikipedia     https://en.wikipedia.org/wiki/Protocol_Buffers
	ProtoBuf Doc  https://developers.google.com/protocol-buffers/docs/proto3
	gRPC          https://grpc.io/docs/quickstart/go.html

	Client app directly calls methods on a server app, perhaps on a different machine, as if it was a local object. Based on the idea of defining a service, specifying the methods that can be called remotely with their parameters and return types. On the server side, the server implements this interface and runs a gRPC server to handle client calls. On the client side, the client (stub) that provides the same methods as the server. By default gRPC uses PROTOCOL BUFFERS; mature open source mechanism for serializing structured data.

	ALTERNATIVEs
		Apache Thrift (Facebook)
		Microsoft Bond

		Apache Avro [self describing]
			Avro does not require that code be generated. Data is always accompanied by a schema that permits full processing of that data without code generation, static datatypes, etc. This facilitates construction of generic data-processing systems and languages.
			http://avro.apache.org/docs/current/

		FlatBuffers [spawn of ProtoBuf]
			https://google.github.io/flatbuffers/

*/