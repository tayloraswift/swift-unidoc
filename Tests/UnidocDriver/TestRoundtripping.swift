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
        let object:DocumentationObject = try await artifacts.build()
        let bson:BSON.Document = .init(encoding: object)

        print("Built documentation (\(bson.bytes.count >> 10) KB)")

        try output.overwrite(with: bson.bytes)

        print("Documentation saved to: \(output)")

        let decoded:DocumentationObject = try .init(buffer: bson.bytes)

        tests.expect(decoded.metadata ==? object.metadata)

        //  We don’t want to dump the entire archive to the terminal!
        tests.expect(true: decoded == object)
    }
}
