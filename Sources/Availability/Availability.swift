import SemanticVersions

@frozen public 
struct Availability:Equatable, Sendable
{
    @usableFromInline
    var platforms:
    [
        Platform: Domain<Unavailable, DeprecatedMask, SemanticVersionMask>
    ]
    @usableFromInline
    var agnostics:
    [
        Agnostic: Domain<Never, SemanticVersionMask, SemanticVersionMask>
    ]

    @usableFromInline
    var all:Domain<Never, Deprecated, Never>?
    
    @inlinable public
    init(_ all:Domain<Never, Deprecated, Never>?,
        agnostics:[Agnostic: Domain<Never, SemanticVersionMask, SemanticVersionMask>] = [:],
        platforms:[Platform: Domain<Unavailable, DeprecatedMask, SemanticVersionMask>] = [:])
    {
        self.all = all
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
        self.all == nil &&
        self.agnostics.isEmpty &&
        self.platforms.isEmpty
    }

    @inlinable public
    subscript(domain:Platform) -> Domain<Unavailable, DeprecatedMask, SemanticVersionMask>?
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
    subscript(domain:Agnostic) -> Domain<Never, SemanticVersionMask, SemanticVersionMask>?
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
    @inlinable public
    subscript(_:Never?) -> Domain<Never, Deprecated, Never>?
    {
        _read
        {
            yield  self.all
        }
        _modify
        {
            yield &self.all
        }
    }
}
extension Availability
{
    @inlinable public
    var isGenerallyUsable:Bool 
    {
        self[nil]?.isGenerallyUsable ?? true && self[.swift]?.isGenerallyUsable ?? true
    }
}
