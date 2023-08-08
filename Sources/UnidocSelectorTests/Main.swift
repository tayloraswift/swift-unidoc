import Testing
import UnidocSelectors

@main
enum Main:SyncTests
{
    static
    func run(tests:Tests)
    {
        if  let tests:TestGroup = tests / "Unversioned"
        {
            let zone:Selector.Zone = .init("swift-taylor")

            tests.expect(zone ==? .init(package: "swift-taylor", version: nil))

            // if  let tests:TestGroup = tests / "Trunk"
            // {
            //     let selector:Selector = .init(.docs, "swift-taylor", [])

            //     tests.expect(selector ==? .init(planes: .docs, zone: zone, stem: ""))
            // }
            // if  let tests:TestGroup = tests / "Module"
            // {
            //     let selector:Selector = .init(.docs, "swift-taylor", ["cats"])

            //     tests.expect(selector ==? .init(planes: .docs, zone: zone, stem: "cats"))
            // }
            // if  let tests:TestGroup = tests / "Global"
            // {
            //     let selector:Selector = .init(.docs, "swift-taylor", ["cats.adoptCat"])

            //     tests.expect(selector ==? .init(planes: .docs,
            //         zone: zone,
            //         stem: "cats\tadoptCat"))
            // }
            // if  let tests:TestGroup = tests / "GlobalWithParentheses"
            // {
            //     let selector:Selector = .init(.docs, "swift-taylor", ["cats.adoptCat()"])

            //     tests.expect(selector ==? .init(planes: .docs,
            //         zone: zone,
            //         stem: "cats\tadoptCat"))
            // }
            // if  let tests:TestGroup = tests / "GlobalWithArguments"
            // {
            //     let selector:Selector = .init(.docs, "swift-taylor", ["cats.adoptCat(named:)"])

            //     tests.expect(selector ==? .init(planes: .docs,
            //         zone: zone,
            //         stem: "cats\tadoptCat(named:)"))
            // }
            // if  let tests:TestGroup = tests / "Type" / "TopLevel"
            // {
            //     let selector:Selector = .init(.docs, "swift-taylor", ["cats", "cat"])

            //     tests.expect(selector ==? .init(planes: .docs, zone: zone, stem: "cats cat"))
            // }
            // if  let tests:TestGroup = tests / "Type" / "Nested"
            // {
            //     let selector:Selector = .init(.docs, "swift-taylor", ["cats", "cat", "color"])

            //     tests.expect(selector ==? .init(planes: .docs,
            //         zone: zone,
            //         stem: "cats cat color"))
            // }
            // if  let tests:TestGroup = tests / "Method"
            // {
            //     let selector:Selector = .init(.docs, "swift-taylor", ["cats", "cat.color"])

            //     tests.expect(selector ==? .init(planes: .docs,
            //         zone: zone,
            //         stem: "cats cat\tcolor"))
            // }
        }
        if  let tests:TestGroup = tests / "Versioned"
        {
            let zone:Selector.Zone = .init("swift-taylor:1.0.0")

            tests.expect(zone ==? .init(package: "swift-taylor", version: "1.0.0"))

            // if  let tests:TestGroup = tests / "Versioned" / "Trunk"
            // {
            //     let selector:Selector = .init(.docs, "swift-taylor:1.0.0", [])

            //     tests.expect(selector ==? .init(planes: .docs,
            //         zone: zone,
            //         stem: ""))
            // }
            // if  let tests:TestGroup = tests / "Versioned" / "Module"
            // {
            //     let selector:Selector = .init(.docs, "swift-taylor:1.0.0", ["cats"])

            //     tests.expect(selector ==? .init(planes: .docs,
            //         zone: zone,
            //         stem: "cats"))
            // }
            // if  let tests:TestGroup = tests / "Versioned" / "Global"
            // {
            //     let selector:Selector = .init(.docs, "swift-taylor:1.0.0", ["cats.adoptCat"])

            //     tests.expect(selector ==? .init(planes: .docs,
            //         zone: zone,
            //         stem: "cats\tadoptCat"))
            // }
            // if  let tests:TestGroup = tests / "Versioned" / "Type"
            // {
            //     let selector:Selector = .init(.docs, "swift-taylor:1.0.0", ["cats", "cat"])

            //     tests.expect(selector ==? .init(planes: .docs,
            //         zone: zone,
            //         stem: "cats cat"))
            // }
        }
    }
}
