import Testing
import UCF

@Suite
struct Doclinks:ParsingSuite
{
    typealias Format = Doclink

    @Test
    static func Empty()
    {
        #expect(nil == Doclink.init(""))
    }
    @Test
    static func NoScheme()
    {
        #expect(nil == Doclink.init("Blossom"))
    }
    @Test
    static func WrongScheme()
    {
        #expect(nil == Doclink.init("dic://Blossom"))
    }
    @Test
    static func TooManySlashes()
    {
        #expect(nil == Doclink.init("doc:///Blossom"))
    }

    @Test
    static func AbsoluteNoComponents() throws
    {
        let doclink:Doclink = try Self.roundtrip("doc://")
        #expect(doclink == .init(absolute: true, path: []))
    }
    @Test
    static func AbsoluteOneComponent() throws
    {
        let doclink:Doclink = try Self.roundtrip("doc://Blossom")
        #expect(doclink == .init(absolute: true, path: ["Blossom"]))
    }
    @Test
    static func AbsoluteManyComponents() throws
    {
        let doclink:Doclink = try Self.roundtrip("doc://Blossom/Buttercup/Bubbles")
        #expect(doclink == .init(absolute: true,
            path: ["Blossom", "Buttercup", "Bubbles"]))
    }
    @Test
    static func AbsoluteNormalization() throws
    {
        let doclink:Doclink = try Self.roundtrip("doc://Blossom/./Buttercup//Mojo/../Bubbles/")
        #expect(doclink == .init(absolute: true,
            path: ["Blossom", "Buttercup", "Bubbles"]))
    }
    @Test
    static func AbsoluteOverNormalization() throws
    {
        let doclink:Doclink = try Self.roundtrip("doc://Bubbles/../../..")
        #expect(doclink == .init(absolute: true, path: []))
    }

    @Test
    static func RelativeNoComponents() throws
    {
        let doclink:Doclink = try Self.roundtrip("doc:")
        #expect(doclink == .init(absolute: false, path: []))
    }
    @Test
    static func RelativeOneComponent() throws
    {
        let doclink:Doclink = try Self.roundtrip("doc:Blossom")
        #expect(doclink == .init(absolute: false, path: ["Blossom"]))
    }
    @Test
    static func RelativeManyComponents() throws
    {
        let doclink:Doclink = try Self.roundtrip("doc:Blossom/Buttercup/Bubbles")
        #expect(doclink == .init(absolute: false,
            path: ["Blossom", "Buttercup", "Bubbles"]))
    }
    @Test
    static func RelativeNormalization() throws
    {
        let doclink:Doclink = try Self.roundtrip("doc:/Blossom/./Buttercup//Mojo/../Bubbles/")
        #expect(doclink == .init(absolute: false,
            path: ["Blossom", "Buttercup", "Bubbles"]))
    }
    @Test
    static func RelativeOverNormalization() throws
    {
        let doclink:Doclink = try Self.roundtrip("doc:Bubbles/../../..")
        #expect(doclink == .init(absolute: false, path: []))
    }

    @Test
    static func PercentEncoding() throws
    {
        let doclink:Doclink = try Self.roundtrip("doc:Ingredient%20X")
        #expect(doclink == .init(absolute: false, path: ["Ingredient X"]))
    }

    @Test
    static func Fragment() throws
    {
        let doclink:Doclink = try Self.roundtrip("doc:Professor#Laboratory%20Rules")
        #expect(doclink == .init(absolute: false,
            path: ["Professor"],
            fragment: "Laboratory Rules"))
    }
}
