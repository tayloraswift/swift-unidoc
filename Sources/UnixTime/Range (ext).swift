extension Range<UnixDate>
{
    @inlinable public static
    func year(_ year:Timestamp.Year) -> Self?
    {
        guard
        let a:UnixDate = .init(utc: .init(year: year)),
        let b:UnixDate = .init(utc: .init(year: year.advanced(by: 1)))
        else
        {
            return nil
        }

        return a ..< b
    }
}
