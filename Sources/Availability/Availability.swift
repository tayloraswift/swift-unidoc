@frozen public
struct Availability:Equatable, Sendable
{
    public
    var universal:Clauses<UniversalDomain>?

    public
    var platforms:[PlatformDomain: Clauses<PlatformDomain>]
    public
    var agnostic:[AgnosticDomain: Clauses<AgnosticDomain>]

    @inlinable public
    init(_ universal:Clauses<UniversalDomain>? = nil,
        platforms:[PlatformDomain: Clauses<PlatformDomain>] = [:],
        agnostic:[AgnosticDomain: Clauses<AgnosticDomain>] = [:])
    {
        self.universal = universal
        self.platforms = platforms
        self.agnostic = agnostic
    }
}
extension Availability
{
    @inlinable public
    var isEmpty:Bool
    {
        self.universal == nil &&
        self.platforms.isEmpty &&
        self.agnostic.isEmpty
    }
}
extension Availability
{
    @inlinable public
    var isGenerallyRecommended:Bool
    {
        self.universal?.isGenerallyRecommended ?? true
        &&  self.agnostic[.swift]?.isGenerallyRecommended ?? true
        &&  self.agnostic[.swiftPM]?.isGenerallyRecommended ?? true
    }
}
