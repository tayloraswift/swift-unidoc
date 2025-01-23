import JSON
import PackageMetadata
import System_
import Testing

@Suite
enum PackageResolved
{
    @Test
    static func Local() throws
    {
        let json:String = """
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
        let resolutions:SPM.DependencyResolutions = try .init(
            parsing: json)
        let expected:[SPM.DependencyPin] = [
            .init(identity: "swift-json",
                location: .local(root: "/swift/swift-json"),
                revision: 0x36ef4bf1e6ae38f881ed253d5656839a046456f1,
                version: .stable(.release(.v(0, 4, 5)))),
        ]

        #expect(resolutions.format == .v2)
        #expect(resolutions.pins == expected)
    }
    @Test
    static func Remote() throws
    {
        let json:String = """
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
        let resolutions:SPM.DependencyResolutions = try .init(
            parsing: json)
        let expected:[SPM.DependencyPin] = [
            .init(identity: "swift-atomics",
                location: .remote(
                    url: "https://github.com/apple/swift-atomics.git"),
                revision: 0xff3d2212b6b093db7f177d0855adbc4ef9c5f036,
                version: .stable(.release(.v(1, 0, 3)))),
            .init(identity: "swift-grammar",
                location: .remote(
                    url: "https://github.com/kelvin13/swift-grammar"),
                revision: 0x69613825b2ad1d0538c59d72e548867ce7568cc2,
                version: .stable(.release(.v(0, 3, 1)))),
        ]

        #expect(resolutions.format == .v2)
        #expect(resolutions.pins == expected)
    }
    @Test
    static func Dogfood() throws
    {
        let filepath:FilePath = "Package.resolved"
        let json:JSON = .init(utf8: try filepath.read()[...])
        let _:SPM.DependencyResolutions = try json.decode()
    }
    @Test
    static func Legacy() throws
    {
        let json:String = """
        {
            "object": {
            "pins": [
                {
                "package": "swift-argument-parser",
                "repositoryURL": "https://github.com/apple/swift-argument-parser.git",
                "state": {
                    "branch": null,
                    "revision": "fee6933f37fde9a5e12a1e4aeaa93fe60116ff2a",
                    "version": "1.2.2"
                }
                }
            ]
            },
            "version": 1
        }
        """

        let resolutions:SPM.DependencyResolutions = try .init(
            parsing: json)
        let expected:[SPM.DependencyPin] =
        [
            .init(identity: "swift-argument-parser",
                location: .remote(
                    url: "https://github.com/apple/swift-argument-parser.git"),
                revision: 0xfee6933f37fde9a5e12a1e4aeaa93fe60116ff2a,
                version: .stable(.release(.v(1, 2, 2)))),
        ]
        #expect(resolutions.format == .v1)
        #expect(resolutions.pins == expected)
    }
}
