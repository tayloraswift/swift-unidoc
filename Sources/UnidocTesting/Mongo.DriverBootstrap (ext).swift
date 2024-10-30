import MongoConfiguration
import MongoDB
import NIOPosix

extension Mongo.DriverBootstrap
{
    public
    static var unidoc:Self
    {
        MongoDB / ["unidoc-mongod"] /?
        {
            $0.executors = .shared(MultiThreadedEventLoopGroup.singleton)
            $0.appname = "example app"
        }
    }
}
