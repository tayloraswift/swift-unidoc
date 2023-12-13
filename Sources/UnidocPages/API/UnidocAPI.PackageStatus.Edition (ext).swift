import UnidocAutomation
import UnidocQueries
import UnidocRecords

extension UnidocAPI.PackageStatus.Edition
{
    init?(from output:Unidex.EditionOutput)
    {
        self.init(coordinate: output.edition.version,
            graphs: output.graph != nil ? 1 : 0,
            tag: output.edition.name)
    }
}
