public
protocol VectorVersionComponents:LosslessStringConvertible, RawRepresentable<Int64>, Comparable
{
    init?(_ description:Substring)
    init(rawValue:Int64)
}
