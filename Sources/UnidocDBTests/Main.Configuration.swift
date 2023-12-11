import MongoDB
import MongoTesting

extension Main
{
    enum Configuration
    {
    }
}
extension Main.Configuration:MongoTestConfiguration
{
    typealias Login = Mongo.Guest

    static
    let members:Mongo.Seedlist = ["unidoc-mongod"]

    static
    func configure(options:inout Mongo.DriverOptions<Never>)
    {
        options.appname = "example app"
    }
}
