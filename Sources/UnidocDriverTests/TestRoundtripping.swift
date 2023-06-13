import BSONDecoding
import SymbolGraphs
import System
import Testing
import UnidocDriver

func TestRoundtripping(_ tests:TestGroup,
    documentation:DocumentationArchive,
    output:FilePath)
{
    if  let tests:TestGroup = tests / "roundtripping"
    {
        tests.do
        {
            let bson:BSON.Document = .init(encoding: documentation)

            print("Built documentation (\(bson.bytes.count >> 10) KB)")

            try output.overwrite(with: bson.bytes)

            print("Documentation saved to: \(output)")

            let decoded:DocumentationArchive = try .init(buffer: bson.bytes)

            tests.expect(decoded.metadata ==? documentation.metadata)

            //  We don’t want to dump the entire archive to the terminal!
            tests.expect(true: decoded == documentation)
        }
    }
}
