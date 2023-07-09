import BSON
import SymbolGraphs
import System
import Testing

extension Documentation
{
    private
    var filename:String
    {
        self.metadata.version.map
        {
            "\(self.metadata.package)@\($0).ss"
        } ?? "\(self.metadata.package).ss"
    }

    @discardableResult
    public
    func save(as filename:String? = nil, in directory:FilePath) throws -> FilePath
    {
        let bson:BSON.Document = .init(encoding: self)

        let file:FilePath = directory / (filename ?? self.filename)
        try file.overwrite(with: bson.bytes)

        return file
    }

    public
    func roundtrip(for tests:TestGroup, in directory:FilePath)
    {
        tests.do
        {
            let file:FilePath = try self.save(in: directory)

            if  let tests:TestGroup = tests / "roundtripping",
                let decoded:Documentation = tests.do({ try .init(buffer: file.read()) })
            {
                tests.expect(decoded.metadata ==? self.metadata)
                //  We don’t want to dump the entire symbol graph to the terminal!
                tests.expect(true: decoded.graph == self.graph)
            }
        }
    }
}
