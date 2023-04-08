import Codelinks
import Testing

@main
enum Main:SyncTests
{
    static
    func run(tests:Tests)
    {
        if  let tests:TestGroup = tests / "identifiers"
        {
            if  let tests:TestGroup = tests / "underscore"
            {
                tests.expect(value: Codelink.Identifier.init("_"))
            }
            if  let tests:TestGroup = tests / "letter"
            {
                tests.expect(value: Codelink.Identifier.init("x"))
            }
            if  let tests:TestGroup = tests / "number-suffix"
            {
                tests.expect(value: Codelink.Identifier.init("x0"))
            }
            if  let tests:TestGroup = tests / "number-prefix"
            {
                tests.expect(nil: Codelink.Identifier.init("0x"))
            }
            if  let tests:TestGroup = tests / "spaces"
            {
                tests.expect(nil: Codelink.Identifier.init("x x"))
            }
        }
        if  let tests:TestGroup = tests / "operators"
        {
            if  let tests:TestGroup = tests / "underscore"
            {
                tests.expect(nil: Codelink.Operator.init("_"))
            }
            if  let tests:TestGroup = tests / "letter"
            {
                tests.expect(nil: Codelink.Operator.init("x"))
            }
            if  let tests:TestGroup = tests / "plus"
            {
                tests.expect(value: Codelink.Operator.init("+"))
            }
            if  let tests:TestGroup = tests / "slash"
            {
                tests.expect(value: Codelink.Operator.init("/"))
            }
            if  let tests:TestGroup = tests / "plusplus"
            {
                tests.expect(value: Codelink.Operator.init("++"))
            }
            if  let tests:TestGroup = tests / "dots"
            {
                tests.expect(value: Codelink.Operator.init("..."))
            }
            if  let tests:TestGroup = tests / "dots-invalid"
            {
                tests.expect(nil: Codelink.Operator.init("+.."))
            }
            if  let tests:TestGroup = tests / "spaces"
            {
                tests.expect(nil: Codelink.Identifier.init("+ +"))
            }
        }
        if  let tests:TestGroup = tests / "operators" / "reserved"
        {
            for (pattern, name):(String, String) in
            [
                (".", "dot"),
                ("=", "equals"),
                ("->", "arrow"),
                ("//", "line-comment"),
                ("/*", "block-comment-start"),
                ("*/", "block-comment-end"),
            ]
            {
                if  let tests:TestGroup = tests / name
                {
                    tests.expect(nil: Codelink.Operator.init(pattern))
                }
            }
        }
    }
}
