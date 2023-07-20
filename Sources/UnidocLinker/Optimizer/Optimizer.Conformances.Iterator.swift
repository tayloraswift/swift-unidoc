import Signatures
import Unidoc

extension Optimizer.Conformances
{
    struct Iterator:Sendable
    {
        private
        var base:Dictionary<Unidoc.Scalar, [Optimizer.ConformanceSignature]>.Iterator

        init(_ base:Dictionary<Unidoc.Scalar, [Optimizer.ConformanceSignature]>.Iterator)
        {
            self.base = base
        }
    }
}
extension Optimizer.Conformances.Iterator:IteratorProtocol
{
    mutating
    func next() -> (protocol:Unidoc.Scalar, signatures:[Optimizer.ConformanceSignature])?
    {
        self.base.next().map { ($0.key, $0.value) }
    }
}
