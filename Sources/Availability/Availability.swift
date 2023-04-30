@frozen public 
struct Availability:Equatable, Sendable
{
    public
    var universal:Clauses<UniversalDomain>?
    
    @usableFromInline
    var platforms:[PlatformDomain: Clauses<PlatformDomain>]
    @usableFromInline
    var agnostics:[AgnosticDomain: Clauses<AgnosticDomain>]
    
    @inlinable public
    init(_ universal:Clauses<UniversalDomain>?,
        agnostics:[AgnosticDomain: Clauses<AgnosticDomain>] = [:],
        platforms:[PlatformDomain: Clauses<PlatformDomain>] = [:])
    {
        self.universal = universal
        self.agnostics = agnostics
        self.platforms = platforms
    }
}
extension Availability:ExpressibleByDictionaryLiteral
{
    @inlinable public
    init(dictionaryLiteral:(Never, Never)...)
    {
        self.init(nil)
    }
}
extension Availability
{
    @inlinable public
    var isEmpty:Bool 
    {
        self.universal == nil &&
        self.agnostics.isEmpty &&
        self.platforms.isEmpty
    }

    @inlinable public
    subscript(domain:PlatformDomain) -> Clauses<PlatformDomain>?
    {
        _read
        {
            yield  self.platforms[domain]
        }
        _modify
        {
            yield &self.platforms[domain]
        }
    }
    @inlinable public
    subscript(domain:AgnosticDomain) -> Clauses<AgnosticDomain>?
    {
        _read
        {
            yield  self.agnostics[domain]
        }
        _modify
        {
            yield &self.agnostics[domain]
        }
    }
}
extension Availability
{
    @inlinable public
    var isGenerallyRecommended:Bool 
    {
        self.universal?.isGenerallyRecommended ?? true &&
        self[.swift]?.isGenerallyRecommended ?? true
    }
}
