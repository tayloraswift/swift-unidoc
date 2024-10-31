import BSON
import SymbolGraphs
import Testing_

extension SymbolGraphObject<Void>
{
    func roundtrip(for tests:TestGroup)
    {
        guard
        let tests:TestGroup = tests / "roundtripping"
        else
        {
            return
        }

        let encoded:BSON.Document = .init(encoding: self)

        guard
        let decoded:Self = tests.do({ try .init(buffer: encoded.bytes) })
        else
        {
            return
        }

        tests.expect(decoded.metadata ==? self.metadata)
        //  We don’t want to dump the entire symbol graph to the terminal!
        tests.expect(true: decoded.graph == self.graph)
    }
}
