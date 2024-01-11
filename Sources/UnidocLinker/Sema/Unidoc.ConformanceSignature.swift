extension Unidoc
{
    struct ConformanceSignature:Equatable, Hashable
    {
        /// The protocol that a conforming type conforms to.
        let conformance:Unidoc.Scalar
        /// The culture that declares the conformance.
        let culture:Int

        private
        init(conformance:Unidoc.Scalar, culture:Int)
        {
            self.conformance = conformance
            self.culture = culture
        }
    }
}
extension Unidoc.ConformanceSignature
{
    static
    func conforms(to conformance:Unidoc.Scalar, in culture:Int) -> Self
    {
        .init(conformance: conformance, culture: culture)
    }
}
