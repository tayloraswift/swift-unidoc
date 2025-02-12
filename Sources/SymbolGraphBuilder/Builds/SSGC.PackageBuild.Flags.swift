import SystemIO

extension SSGC.PackageBuild
{
    @frozen public
    struct Flags
    {
        public
        var swift:[String]
        public
        var cxx:[String]
        public
        var c:[String]

        @inlinable public
        init(swift:[String] = [], cxx:[String] = [], c:[String] = [])
        {
            self.swift = swift
            self.cxx = cxx
            self.c = c
        }
    }
}
