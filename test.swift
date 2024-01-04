struct S1
{
    let a:[Int]
    let b:[Int]

    consuming
    func f() -> [Int]
    {
        var a:[Int] = self.a

        a += self.b

        return a
    }
}

struct S2:~Copyable
{
    let a:[Int]
    let b:[Int]

    consuming
    func f() -> [Int]
    {
        var a:[Int] = self.a

        a += self.b

        return a
    }
}
