import Testing
import UnidocQueries

@main
enum Main:SyncTests
{
    static
    func run(tests:Tests)
    {
        if  let tests:TestGroup = tests / "DeepQuery"
        {
            if  let tests:TestGroup = tests / "Unversioned" / "Trunk"
            {
                let query:DeepQuery = .init(.docs, "swift-taylor", [])

                tests.expect(query ==? .init(.docs,
                    package: "swift-taylor",
                    version: nil,
                    stem: ""))
            }
            if  let tests:TestGroup = tests / "Unversioned" / "Module"
            {
                let query:DeepQuery = .init(.docs, "swift-taylor", ["cats"])

                tests.expect(query ==? .init(.docs,
                    package: "swift-taylor",
                    version: nil,
                    stem: "cats"))
            }
            if  let tests:TestGroup = tests / "Unversioned" / "Global"
            {
                let query:DeepQuery = .init(.docs, "swift-taylor", ["cats.adoptCat"])

                tests.expect(query ==? .init(.docs,
                    package: "swift-taylor",
                    version: nil,
                    stem: "cats\tadoptCat"))
            }
            if  let tests:TestGroup = tests / "Unversioned" / "GlobalWithParentheses"
            {
                let query:DeepQuery = .init(.docs, "swift-taylor", ["cats.adoptCat()"])

                tests.expect(query ==? .init(.docs,
                    package: "swift-taylor",
                    version: nil,
                    stem: "cats\tadoptCat"))
            }
            if  let tests:TestGroup = tests / "Unversioned" / "GlobalWithArguments"
            {
                let query:DeepQuery = .init(.docs, "swift-taylor", ["cats.adoptCat(named:)"])

                tests.expect(query ==? .init(.docs,
                    package: "swift-taylor",
                    version: nil,
                    stem: "cats\tadoptCat(named:)"))
            }
            if  let tests:TestGroup = tests / "Unversioned" / "Type" / "TopLevel"
            {
                let query:DeepQuery = .init(.docs, "swift-taylor", ["cats", "cat"])

                tests.expect(query ==? .init(.docs,
                    package: "swift-taylor",
                    version: nil,
                    stem: "cats cat"))
            }
            if  let tests:TestGroup = tests / "Unversioned" / "Type" / "Nested"
            {
                let query:DeepQuery = .init(.docs, "swift-taylor", ["cats", "cat", "color"])

                tests.expect(query ==? .init(.docs,
                    package: "swift-taylor",
                    version: nil,
                    stem: "cats cat color"))
            }
            if  let tests:TestGroup = tests / "Unversioned" / "Method"
            {
                let query:DeepQuery = .init(.docs, "swift-taylor", ["cats", "cat.color"])

                tests.expect(query ==? .init(.docs,
                    package: "swift-taylor",
                    version: nil,
                    stem: "cats cat\tcolor"))
            }

            if  let tests:TestGroup = tests / "Versioned" / "Trunk"
            {
                let query:DeepQuery = .init(.docs, "swift-taylor:1.0.0", [])

                tests.expect(query ==? .init(.docs,
                    package: "swift-taylor",
                    version: "1.0.0",
                    stem: ""))
            }
            if  let tests:TestGroup = tests / "Versioned" / "Module"
            {
                let query:DeepQuery = .init(.docs, "swift-taylor:1.0.0", ["cats"])

                tests.expect(query ==? .init(.docs,
                    package: "swift-taylor",
                    version: "1.0.0",
                    stem: "cats"))
            }
            if  let tests:TestGroup = tests / "Versioned" / "Global"
            {
                let query:DeepQuery = .init(.docs, "swift-taylor:1.0.0", ["cats.adoptCat"])

                tests.expect(query ==? .init(.docs,
                    package: "swift-taylor",
                    version: "1.0.0",
                    stem: "cats\tadoptCat"))
            }
            if  let tests:TestGroup = tests / "Versioned" / "Type"
            {
                let query:DeepQuery = .init(.docs, "swift-taylor:1.0.0", ["cats", "cat"])

                tests.expect(query ==? .init(.docs,
                    package: "swift-taylor",
                    version: "1.0.0",
                    stem: "cats cat"))
            }
        }
    }
}
