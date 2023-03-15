import JSON
import PackageManifest
import System
import Testing

@main
enum Main:SyncTests
{
    static
    func run(tests:Tests)
    {
        if  let tests:TestGroup = tests / "dependencies" / "filesystem"
        {
            let json:String =
            """
            {
              "cLanguageStandard" : null,
              "cxxLanguageStandard" : null,
              "dependencies" : [
                {
                  "fileSystem" : [
                    {
                      "identity" : "swift-json",
                      "path" : "/swift/swift-json",
                      "productFilter" : null
                    }
                  ]
                }
              ],
              "name" : "swift-unidoc",
              "packageKind" : {
                "root" : [
                  "/swift/swift-unidoc"
                ]
              },
              "pkgConfig" : null,
              "platforms" : [
                {
                  "options" : [
            
                  ],
                  "platformName" : "macos",
                  "version" : "11.0"
                }
              ],
              "products" : [],
              "providers" : null,
              "swiftLanguageVersions" : null,
              "targets" : [],
              "toolsVersion" : {
                "_version" : "5.7.0"
              }
            }
            """
            tests.do
            {
                let json:JSON.Object = try .init(parsing: json)
                let expected:PackageManifest = .init(id: "swift-unidoc",
                    root: "/swift/swift-unidoc",
                    products: [])
                tests.expect(try .init(json: json) ==? expected)
            }
        }
        if  let tests:TestGroup = tests / "integration" / "testmodules"
        {
            tests.do
            {
                let filepath:FilePath = "TestModules/Package.swift.json"
                let file:[UInt8] = try filepath.read()
                let json:JSON.Object = try .init(parsing: file)

                let manifest:PackageManifest = try .init(json: json)
                
                tests.expect(manifest.id ==? "swift-unidoc-testmodules")
                tests.expect(manifest.root ==? "/swift/swift-unidoc/TestModules")
            }
        }
    }
}
