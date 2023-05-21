import BSONDecoding
import SymbolGraphs
import System
import Testing
import UnidocDriver

func TestRoundtripping(_ tests:TestGroup,
    artifacts:DocumentationArtifacts,
    output:FilePath) async
{
    guard let tests:TestGroup = tests / "roundtripping"
    else
    {
        return
    }
    await tests.do
    {
        let archive:DocumentationArchive = try await artifacts.build()
        let bson:BSON.Document = .init(encoding: archive)

        print("Built documentation (\(bson.bytes.count >> 10) KB)")

        try output.overwrite(with: bson.bytes)

        print("Documentation saved to: \(output)")

        let decoded:DocumentationArchive = try .init(bson: .init(bson))

        tests.expect(decoded.metadata ==? archive.metadata)
        tests.expect(decoded.modules ==? archive.modules)

        //  We don’t want to dump the entire archive to the terminal!
        tests.expect(true: decoded == archive)
    }
}
