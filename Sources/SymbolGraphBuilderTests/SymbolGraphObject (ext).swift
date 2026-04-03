import BSON
import SymbolGraphs
import Testing

extension SymbolGraphObject<Void> {
    func roundtrip(in test: String = #function) throws {
        let encoded: BSON.Document = .init(encoding: self)
        let decoded: Self = try .init(buffer: encoded.bytes)
        //  We don’t want to dump the entire symbol graph to the terminal!
        let matches: Bool = decoded.graph == self.graph
        #expect(decoded.metadata == self.metadata, "\(test)")
        #expect(matches, "\(test)")
    }
}
