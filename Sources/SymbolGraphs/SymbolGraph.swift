import SemanticVersions
import JSONDecoding

public
struct SymbolGraph:Sendable
{
    public
    let format:SemanticVersion

    public
    init(format:SemanticVersion)
    {
        self.format = format
    }
}
