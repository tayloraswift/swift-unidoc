import Testing
import UCF

@Suite
struct Anchors
{
    @Test
    static func Empty()
    {
        #expect("" == UCF.AnchorMangling.init(mangling: ""))
    }
    @Test
    static func OneWord()
    {
        #expect("overview" == UCF.AnchorMangling.init(mangling: "Overview"))
    }
    @Test
    static func TwoWords()
    {
        #expect("basic-usage" == UCF.AnchorMangling.init(mangling: "Basic usage"))
    }
    @Test
    static func Punctuation()
    {
        #expect("""
            swifties-of-america-dont-forget-to-claim-your-free-hoodie-before-the-deadline
            """ == UCF.AnchorMangling.init(
            mangling: """
            Swifties of America! Don’t forget to claim your FREE hoodie before the deadline!
            """))
    }
}
