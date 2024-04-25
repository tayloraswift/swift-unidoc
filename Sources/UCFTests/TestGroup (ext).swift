import Testing_

extension TestGroup
{
    func roundtrip<Format>(_ expression:String,
        through _:Format.Type = Format.self) -> Format?
        where Format:Equatable & LosslessStringConvertible
    {
        let value:Format? = self.expect(value: .init(expression))
        if  let value:Format,
            let tests:TestGroup = self / "Roundtripping",
            let roundtripped:Format = tests.expect(value: .init("\(value)"))
        {
            tests.expect(value ==? roundtripped)
        }
        return value
    }
}
