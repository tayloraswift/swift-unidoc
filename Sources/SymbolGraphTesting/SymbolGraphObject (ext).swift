import BSON
import SemanticVersions
import SymbolGraphs
import Symbols
import System_
import Testing

extension SymbolGraphObject<Void>
{
    public
    static func load(swift:SwiftVersion,
        in directory:FilePath.Directory) throws -> Self
    {
        let filename:String = "swift@\(swift.version).bson"
        return try .init(buffer: try (directory / filename).read())
    }

    public
    static func load(package:Symbol.Package,
        at version:AnyVersion? = nil,
        in directory:FilePath.Directory) throws -> Self
    {
        let filename:String = version.map { "\(package)@\($0).bson" } ?? "\(package).bson"
        return try .init(buffer: try (directory / filename).read())
    }

    @discardableResult
    public
    func save(as filename:String? = nil, in directory:FilePath.Directory) throws -> FilePath
    {
        let bson:BSON.Document = .init(encoding: self)

        let file:FilePath = directory / (filename ?? self.metadata.filename)
        try file.overwrite(with: bson.bytes)

        return file
    }
}
extension SymbolGraphObject<Void>
{
    public
    func roundtrip(in directory:FilePath.Directory) throws
    {
        let file:FilePath = try self.save(in: directory)
        let decoded:Self = try .init(buffer: try file.read())

        #expect(decoded.metadata == self.metadata)
        //  We don’t want to dump the entire symbol graph to the terminal!
        #expect(decoded.graph == self.graph)
    }
}
