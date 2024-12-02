import ArgumentParser
import MongoClusters

extension Unidoc
{
    @frozen public
    struct DatabaseOptions:ParsableArguments
    {
        @Option(
            name: [.customLong("mongod"), .customLong("mongo"), .customShort("m")],
            help: "The name of a host running mongod to connect to, and optionally, the port")
        public
        var mongod:Mongo.Host = "localhost"

        @Option(
            name: [.customLong("replica-set"), .customShort("s")],
            help: "The name of a replica set to connect to")
        public
        var rs:String = "unidoc-rs"

        public
        init() {}

        public
        init(mongod:Mongo.Host, rs:String)
        {
            self.mongod = mongod
            self.rs = rs
        }
    }
}
