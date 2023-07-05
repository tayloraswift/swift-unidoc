import SymbolGraphs
import UnidocLinker

extension Snapshot
{
    init(from docs:Documentation, receipt:SnapshotReceipt)
    {
        self.init(id: receipt.id,
            package: receipt.package,
            version: receipt.version,
            metadata: docs.metadata,
            graph: docs.graph)
    }
}
