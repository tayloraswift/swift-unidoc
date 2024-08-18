import Signatures
import SymbolGraphParts
import Symbols

extension SSGC
{
    /// A shareable reference to a scalar value.
    ///
    /// This reference type is useful because we want to be able to query
    /// things about the existence or knowledge of a scalar, and then
    /// separately write updates to the scalar without looking it up again.
    final
    class DeclObject
    {
        let conditions:Set<GenericConstraint<Symbol.Decl>>
        var namespace:Symbol.Module
        let culture:Symbol.Module
        var access:Symbol.ACL

        /// The outer set is populated by redundant implicit conformances produced by
        /// lib/SymbolGraphGen.
        ///
        /// ```
        /// Foo<T>:Equatable where T:Equatable
        /// Foo<T>:Equatable where T:Hashable
        /// ```
        ///
        /// In the example above, the second conformance likely originated from a
        /// `Foo<T>:Hashable where T:Hashable` conformance.
        var conformances:[Symbol.Decl: Set<Set<GenericConstraint<Symbol.Decl>>>]

        /// The type of the superforms tracked by ``\.value.superforms``.
        var superforms:(any SuperformRelationship.Type)?

        /// The symbols this scalar is lexically-nested in.
        ///
        /// Remarkably, it is possible for certain (Objective C) declarations to have more than
        /// one lexical parent. For example, base class methods can be shared by multiple
        /// subclasses in addition to the base class.
        private(set)
        var scopes:Set<Symbol.Decl>

        private(set)
        var value:Decl

        init(conditions:Set<GenericConstraint<Symbol.Decl>>,
            namespace:Symbol.Module,
            culture:Symbol.Module,
            access:Symbol.ACL,
            value:Decl)
        {
            self.conditions = conditions
            self.namespace = namespace
            self.culture = culture
            self.access = access

            self.conformances = [:]
            self.superforms = nil
            self.scopes = []

            self.value = value
        }
    }
}
extension SSGC.DeclObject
{
    var id:Symbol.Decl
    {
        self.value.id
    }

    var kinks:Phylum.Decl.Kinks
    {
        _read   { yield  self.value.kinks }
        _modify { yield &self.value.kinks }
    }
}
extension SSGC.DeclObject
{
    /// Assigns an origin to this scalar object.
    func assign(origin:Symbol.Decl)
    {
        self.value.origins.insert(origin)
    }
    /// Assigns a lexical scope to this scalar object.
    func assign(scope:Symbol.Decl, by relationship:some NestingRelationship) throws
    {
        guard relationship.validate(source: self.value.phylum)
        else
        {
            throw SSGC.SemanticError.cannot(have: .scope, as: self.value.phylum)
        }

        //  Only (Objective) C declarations can have multiple lexical scopes.
        switch self.scopes.first
        {
        case scope?:
            break

        case let existing?:
            if  case .s = self.id.language
            {
                throw SSGC.LexicalScopeError.multiple(existing, scope)
            }
            else
            {
                fallthrough
            }

        case nil:
            self.scopes.insert(scope)
        }

        self.kinks += relationship.kinks

        if  let origin:Symbol.Decl = relationship.origin
        {
            self.assign(origin: origin)
        }
    }
    /// Adds a superform to this scalar object.
    ///
    /// Each scalar can only accept a single type of superform. For example, if
    /// a scalar is the source of an ``IntrinsicWitnessRelationship``
    /// relationship, it can receive additional superforms of that type, but it
    /// cannot receive a ``OverrideRelationship``, because a scalar cannot
    /// be a default implementation and a protocol requirement at the same time.
    func add<Superform>(superform relationship:Superform) throws
        where Superform:SuperformRelationship
    {
        guard relationship.validate(source: self.value.phylum)
        else
        {
            throw SSGC.SemanticError.cannot(have: .superforms(besides: nil),
                as: self.value.phylum)
        }

        switch self.superforms
        {
        case nil, (is Superform.Type)?:
            self.value.superforms.insert(relationship.target)
            self.kinks += relationship.kinks
            self.superforms = Superform.self

        case let type?:
            throw SSGC.SemanticError.cannot(have: .superforms(besides: type),
                as: self.value.phylum)
        }
        if  let origin:Symbol.Decl = relationship.origin
        {
            self.assign(origin: origin)
        }
    }
    /// Adds a requirement to this scalar object, assuming it is a protocol.
    func add(requirement:Symbol.Decl) throws
    {
        guard case .protocol = self.value.phylum
        else
        {
            throw SSGC.SemanticError.cannot(have: .requirements, as: self.value.phylum)
        }

        self.value.requirements.insert(requirement)
    }
    /// Adds an inhabitant to this scalar object, assuming it is an enum.
    func add(inhabitant:Symbol.Decl) throws
    {
        guard case .enum = self.value.phylum
        else
        {
            throw SSGC.SemanticError.cannot(have: .inhabitants, as: self.value.phylum)
        }

        self.value.inhabitants.insert(inhabitant)
    }
}
