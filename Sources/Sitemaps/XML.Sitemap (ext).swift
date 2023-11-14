extension XML.Sitemap
{
    /// Encodes an XML document with the provided closure, which includes
    /// the prefixed `<?xml version="1.0" encoding="UTF-8"?>` declaration.
    @inlinable public static
    func document(with encode:(inout ContentEncoder) throws -> ()) rethrows -> Self
    {
        var xml:Self = """
        <?xml version="1.0" encoding="UTF-8"?>
        """
        try encode(&xml.encoder)
        return xml
    }

    /// Encodes an XML document with the provided async closure, which includes
    /// the prefixed `<?xml version="1.0" encoding="UTF-8"?>` declaration.
    @inlinable public static
    func document(with encode:(inout ContentEncoder) async throws -> ()) async rethrows -> Self
    {
        var xml:Self = """
        <?xml version="1.0" encoding="UTF-8"?>
        """
        try await encode(&xml.encoder)
        return xml
    }
}
extension XML.Sitemap
{
    /// Encodes an XML sitemap index with the provided async closure. This function handles
    /// generating the outer `<sitemapindex>` wrapper; the provided closure should not encode
    /// this tag.
    @inlinable public static
    func index(with encode:(inout ContentEncoder) async throws -> ()) async rethrows -> Self
    {
        try await .document
        {
            (xml:inout ContentEncoder) in

            xml.open(.sitemapindex)
            {
                $0.xmlns = "http://www.sitemaps.org/schemas/sitemap/0.9"
            }
            defer { xml.close(.sitemapindex) }
            try await encode(&xml)
        }
    }
}
