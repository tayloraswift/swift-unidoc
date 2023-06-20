import Doclinks
import Testing

extension Doclink
{
    static
    func parse(_ expression:String, for tests:TestGroup) -> Self?
    {
        let doclink:Self? = tests.expect(value: .init(expression))

        if  let doclink:Self,
            let tests:TestGroup = tests / "reparse",
            let reparsed:Self = tests.expect(value: .init("\(doclink)"))
        {
            tests.expect(doclink ==? reparsed)
        }

        return doclink
    }
}
