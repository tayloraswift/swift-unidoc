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
        if  let tests:TestGroup = tests / "local"
        {
            let json:String =
            """
            {
              "pins" : [
                {
                  "identity" : "swift-json",
                  "kind" : "localSourceControl",
                  "location" : "/swift/swift-json",
                  "state" : {
                    "revision" : "36ef4bf1e6ae38f881ed253d5656839a046456f1",
                    "version" : "0.4.5"
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
                    .init(id: "swift-json",
                        reference: .version(.init(0, 4, 5)),
                        revision: .init("36ef4bf1e6ae38f881ed253d5656839a046456f1"),
                        location: .local(file: "/swift/swift-json")),
                ]
                tests.expect(try .init(json: json) ==? expected)
            }
        }
        if  let tests:TestGroup = tests / "remote"
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
                        reference: .version(.init(1, 0, 3)),
                        revision: .init("ff3d2212b6b093db7f177d0855adbc4ef9c5f036"),
                        location: .remote(url: "https://github.com/apple/swift-atomics.git")),
                    .init(id: "swift-grammar",
                        reference: .version(.init(0, 3, 1)),
                        revision: .init("69613825b2ad1d0538c59d72e548867ce7568cc2"),
                        location: .remote(url: "https://github.com/kelvin13/swift-grammar")),
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
