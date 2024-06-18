import Testing_
import UCF

extension Main
{
    struct Anchors
    {
    }
}
extension Main.Anchors:TestBattery
{
    static
    func run(tests:TestGroup)
    {
        if  let tests:TestGroup = tests / "Empty"
        {
            tests.expect("" ==? UCF.AnchorMangling.init(
                mangling: ""))
        }
        if  let tests:TestGroup = tests / "OneWord"
        {
            tests.expect("overview" ==? UCF.AnchorMangling.init(
                mangling: "Overview"))
        }
        if  let tests:TestGroup = tests / "TwoWords"
        {
            tests.expect("basic-usage" ==? UCF.AnchorMangling.init(
                mangling: "Basic usage"))
        }
        if  let tests:TestGroup = tests / "Punctuation"
        {
            tests.expect("""
                swifties-of-america-dont-forget-to-claim-your-free-hoodie-before-the-deadline
                """ ==? UCF.AnchorMangling.init(
                mangling: """
                Swifties of America! Don’t forget to claim your FREE hoodie before the deadline!
                """))
        }
    }
}
