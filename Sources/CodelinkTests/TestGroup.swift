import Codelinks
import Testing

extension TestGroup
{
    func parse(codelink:String) -> Codelink?
    {
        let codelink:Codelink? = self.expect(value: .init(parsing: codelink))

        if  let codelink:Codelink,
            let tests:TestGroup = self / "reparse",
            let reparsed:Codelink = self.expect(value: .init(parsing: codelink.description))
        {
            tests.expect(codelink ==? reparsed)
        }

        return codelink
    }
}
