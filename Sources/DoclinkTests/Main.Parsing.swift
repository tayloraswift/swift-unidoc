import Doclinks
import Testing

extension Main
{
    struct Parsing
    {
    }
}
extension Main.Parsing:TestBattery
{
    static
    func run(tests:TestGroup)
    {
        if  let tests:TestGroup = tests / "Empty"
        {
            tests.expect(nil: Doclink.init(""))
        }
        if  let tests:TestGroup = tests / "NoScheme"
        {
            tests.expect(nil: Doclink.init("Blossom"))
        }
        if  let tests:TestGroup = tests / "WrongScheme"
        {
            tests.expect(nil: Doclink.init("dic://Blossom"))
        }
        if  let tests:TestGroup = tests / "TooManySlashes"
        {
            tests.expect(nil: Doclink.init("doc:///Blossom"))
        }

        if  let tests:TestGroup = tests / "Absolute" / "NoComponents",
            let doclink:Doclink = .parse("doc://", for: tests)
        {
            tests.expect(doclink ==? .init(absolute: true, path: []))
        }
        if  let tests:TestGroup = tests / "Absolute" / "OneComponent",
            let doclink:Doclink = .parse("doc://Blossom", for: tests)
        {
            tests.expect(doclink ==? .init(absolute: true, path: ["Blossom"]))
        }
        if  let tests:TestGroup = tests / "Absolute" / "ManyComponents",
            let doclink:Doclink = .parse("doc://Blossom/Buttercup/Bubbles", for: tests)
        {
            tests.expect(doclink ==? .init(absolute: true,
                path: ["Blossom", "Buttercup", "Bubbles"]))
        }
        if  let tests:TestGroup = tests / "Absolute" / "Normalization",
            let doclink:Doclink = .parse("doc://Blossom/./Buttercup//Mojo/../Bubbles/",
                for: tests)
        {
            tests.expect(doclink ==? .init(absolute: true,
                path: ["Blossom", "Buttercup", "Bubbles"]))
        }
        if  let tests:TestGroup = tests / "Absolute" / "OverNormalization",
            let doclink:Doclink = .parse("doc://Bubbles/../../..", for: tests)
        {
            tests.expect(doclink ==? .init(absolute: true, path: []))
        }

        if  let tests:TestGroup = tests / "Relative" / "NoComponents",
            let doclink:Doclink = .parse("doc:", for: tests)
        {
            tests.expect(doclink ==? .init(absolute: false, path: []))
        }
        if  let tests:TestGroup = tests / "Relative" / "OneComponent",
            let doclink:Doclink = .parse("doc:Blossom", for: tests)
        {
            tests.expect(doclink ==? .init(absolute: false, path: ["Blossom"]))
        }
        if  let tests:TestGroup = tests / "Relative" / "ManyComponents",
            let doclink:Doclink = .parse("doc:Blossom/Buttercup/Bubbles", for: tests)
        {
            tests.expect(doclink ==? .init(absolute: false,
                path: ["Blossom", "Buttercup", "Bubbles"]))
        }
        if  let tests:TestGroup = tests / "Relative" / "Normalization",
            let doclink:Doclink = .parse("doc:/Blossom/./Buttercup//Mojo/../Bubbles/",
                for: tests)
        {
            tests.expect(doclink ==? .init(absolute: false,
                path: ["Blossom", "Buttercup", "Bubbles"]))
        }
        if  let tests:TestGroup = tests / "Relative" / "OverNormalization",
            let doclink:Doclink = .parse("doc:Bubbles/../../..", for: tests)
        {
            tests.expect(doclink ==? .init(absolute: false, path: []))
        }

        if  let tests:TestGroup = tests / "PercentEncoding",
            let doclink:Doclink = .parse("doc:Ingredient%20X", for: tests)
        {
            tests.expect(doclink ==? .init(absolute: false, path: ["Ingredient X"]))
        }
    }
}
