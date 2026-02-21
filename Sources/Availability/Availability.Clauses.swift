extension Availability {
    @frozen public struct Clauses<Domain> where Domain: AvailabilityDomain {
        public let unavailable: Domain.Unavailability?
        public let deprecated: Domain.Deprecation?
        public let introduced: Domain.Bound?
        public let obsoleted: Domain.Bound?
        public let renamed: String?
        public let message: String?

        @inlinable public init(
            unavailable: Domain.Unavailability? = nil,
            deprecated: Domain.Deprecation? = nil,
            introduced: Domain.Bound? = nil,
            obsoleted: Domain.Bound? = nil,
            renamed: String? = nil,
            message: String? = nil
        ) {
            self.unavailable = unavailable
            self.deprecated = deprecated
            self.introduced = introduced
            self.obsoleted = obsoleted
            self.renamed = renamed
            self.message = message
        }
    }
}
extension Availability.Clauses: Sendable
    where   Domain.Unavailability: Sendable,
    Domain.Deprecation: Sendable,
    Domain.Bound: Sendable {
}
extension Availability.Clauses: Equatable
    where   Domain.Unavailability: Equatable,
    Domain.Deprecation: Equatable,
    Domain.Bound: Equatable {
}
extension Availability.Clauses: Hashable
    where   Domain.Unavailability: Hashable,
    Domain.Deprecation: Hashable,
    Domain.Bound: Hashable {
}
extension Availability.Clauses {
    @inlinable public var isGenerallyRecommended: Bool {
        if  case nil = self.unavailable,
            case nil = self.deprecated,
            case nil = self.obsoleted {
            true
        } else {
            false
        }
    }
}
