extension Timestamp
{
    /// Timestamp sanity is an often-overlooked aspect of server security. Because Swift’s
    /// “crash early” philosophy around trapping arithmetic overflows is very bad for servers,
    /// server applications should always perform sanity checks on timestamps before using them
    /// to perform **any** kind of date computation.
    @frozen public
    enum Sanity
    {
        /// The year is in the given range.
        case year(in:ClosedRange<Year>)
        /// No sanity checks will be performed.
        case unchecked
    }
}
