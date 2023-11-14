#if canImport(Glibc)
import func Glibc.cos
import func Glibc.sin
#elseif canImport(Darwin)
import func Darwin.cos
import func Darwin.sin
#endif

extension SVG
{
    @frozen public
    struct Point<Scalar> where Scalar:CustomStringConvertible
    {
        public
        var x:Scalar
        public
        var y:Scalar

        @inlinable public
        init(_ x:Scalar, _ y:Scalar)
        {
            self.x = x
            self.y = y
        }
    }
}
extension SVG.Point:Equatable where Scalar:Equatable
{
}
extension SVG.Point:Hashable where Scalar:Hashable
{
}
extension SVG.Point:Sendable where Scalar:Sendable
{
}
extension SVG.Point<Float>
{
    @inlinable public
    init(radians:Float, radius:Float = 1.0)
    {
        self.init(radius * _cos(radians), radius * -_sin(radians))
    }
}
extension SVG.Point<Double>
{
    @inlinable public
    init(radians:Double, radius:Double = 1.0)
    {
        self.init(radius * _cos(radians), radius * -_sin(radians))
    }
}
extension SVG.Point:CustomStringConvertible
{
    @inlinable public
    var description:String { "\(self.x),\(self.y)" }
}
