import BSON
import SemanticVersions
import SymbolGraphs
import Symbols
import System_

#if canImport(Testing)
import Testing
#endif

import Testing_

extension SymbolGraphObject<Void>
{
    public static
    func load(swift:SwiftVersion,
        in directory:FilePath.Directory) throws -> Self
    {
        let filename:String = "swift@\(swift.version).bson"
        return try .init(buffer: try (directory / filename).read())
    }

    public static
    func load(package:Symbol.Package,
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
    #if canImport(Testing)
    public
    func roundtrip(in directory:FilePath.Directory) throws
    {
        let file:FilePath = try self.save(in: directory)
        let decoded:Self = try .init(buffer: try file.read())

        #expect(decoded.metadata == self.metadata)
        //  We don’t want to dump the entire symbol graph to the terminal!
        #expect(decoded.graph == self.graph)
    }
    #endif

    public
    func roundtrip(for tests:TestGroup, in directory:FilePath.Directory)
    {
        tests.do
        {
            let file:FilePath = try self.save(in: directory)

            if  let tests:TestGroup = tests / "roundtripping",
                let decoded:Self = tests.do(
                {
                    try .init(buffer: try file.read())
                })
            {
                tests.expect(decoded.metadata ==? self.metadata)
                //  We don’t want to dump the entire symbol graph to the terminal!
                tests.expect(true: decoded.graph == self.graph)
            }
        }
    }
}
