public
protocol AvailabilityDomain
{
    /// The representation of this domain’s general version bound,
    /// used for the `introduced` and `obsoleted` bounds.
    associatedtype Bound = Never
    /// The representation of this domain’s deprecation indicator.
    associatedtype Deprecation = Never
    /// The representation of this domain’s unavailability indicator.
    associatedtype Unavailability = Never
}
