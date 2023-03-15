import JSON
import PackageResolution
import System
import Testing

@main
enum Main:SyncTests
{
    static
    func run(tests:Tests)
    {
        if  let tests:TestGroup = tests / "json"
        {
            let json:String =
            """
            {
              "pins" : [
                {
                  "identity" : "swift-atomics",
                  "kind" : "remoteSourceControl",
                  "location" : "https://github.com/apple/swift-atomics.git",
                  "state" : {
                    "revision" : "ff3d2212b6b093db7f177d0855adbc4ef9c5f036",
                    "version" : "1.0.3"
                  }
                },
                {
                  "identity" : "swift-grammar",
                  "kind" : "remoteSourceControl",
                  "location" : "https://github.com/kelvin13/swift-grammar",
                  "state" : {
                    "revision" : "69613825b2ad1d0538c59d72e548867ce7568cc2",
                    "version" : "0.3.1"
                  }
                }
              ],
              "version" : 2
            }
            """
            tests.do
            {
                let json:JSON.Object = try .init(parsing: json)
                let expected:PackageResolution =
                [
                    .init(id: "swift-atomics",
                        requirement: .version(.init(1, 0, 3)),
                        revision: "ff3d2212b6b093db7f177d0855adbc4ef9c5f036",
                        location: "https://github.com/apple/swift-atomics.git"),
                    .init(id: "swift-grammar",
                        requirement: .version(.init(0, 3, 1)),
                        revision: "69613825b2ad1d0538c59d72e548867ce7568cc2",
                        location: "https://github.com/kelvin13/swift-grammar"),
                ]
                tests.expect(try .init(json: json) ==? expected)
            }
        }
        if  let tests:TestGroup = tests / "dogfood"
        {
            tests.do
            {
                let filepath:FilePath = "Package.resolved"
                let file:[UInt8] = try filepath.read()
                let json:JSON.Object = try .init(parsing: file)

                let _:PackageResolution = try .init(json: json)
            }
        }
    }
}
