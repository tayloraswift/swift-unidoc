import Signatures
import Unidoc

extension ProtocolConformances
{
    struct Iterator
    {
        private
        var base:Dictionary<Unidoc.Scalar, [ProtocolConformance<Culture>]>.Iterator

        init(_ base:Dictionary<Unidoc.Scalar, [ProtocolConformance<Culture>]>.Iterator)
        {
            self.base = base
        }
    }
}
extension ProtocolConformances.Iterator:Sendable where Culture:Sendable
{
}
extension ProtocolConformances.Iterator:IteratorProtocol
{
    mutating
    func next() -> (protocol:Unidoc.Scalar, signatures:[ProtocolConformance<Culture>])?
    {
        self.base.next().map { ($0.key, $0.value) }
    }
}
