import Codelinks
import Testing

extension Codelink
{
    static
    func parse(_ expression:String, for tests:TestGroup) -> Self?
    {
        let codelink:Self? = tests.expect(value: .init(expression))

        if  let codelink:Self,
            let tests:TestGroup = tests / "reparse",
            let reparsed:Self = tests.expect(value: .init("\(codelink)"))
        {
            tests.expect(codelink ==? reparsed)
        }

        return codelink
    }
}
