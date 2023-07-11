import MongoDB
import HTML
import HTMLRendering
import HTTPServer

extension Page
{
    struct Admin
    {
        private
        let configuration:Mongo.ReplicaSetConfiguration

        init(configuration:Mongo.ReplicaSetConfiguration)
        {
            self.configuration = configuration
        }
    }
}
extension Page.Admin
{
    var html:HTML
    {
        .document
        {
            $0[.html, { $0[.lang] = "en" }]
            {
                $0[.head]
                {
                    $0[.meta] { $0[.charset] = "utf-8" }
                    $0[.title] = "Administrator Tools"
                }

                $0[.body]
                {
                    $0[.form]
                    {
                        $0[.enctype] = "multipart/form-data"
                        $0[.action] = "/admin/action/upload"
                        $0[.method] = "post"
                    }
                    content:
                    {
                        $0[.p]
                        {
                            $0[.input]
                            {
                                $0[.multiple] = true
                                $0[.name] = "documentation-binary"
                                $0[.type] = "file"
                            }
                        }
                        $0[.p]
                        {
                            $0[.button] { $0[.type] = "submit" } = "Upload Snapshots"
                        }
                    }

                    $0[.hr]

                    $0[.form]
                    {
                        $0[.enctype] = "multipart/form-data"
                        $0[.action] = "/admin/action/rebuild"
                        $0[.method] = "post"
                    }
                    content:
                    {
                        $0[.p]
                        {
                            $0[.button] { $0[.type] = "submit" } = "Rebuild Collections"
                        }
                    }

                    $0[.hr]

                    $0[.form]
                    {
                        $0[.enctype] = "application/x-www-form-urlencoded"
                        $0[.action] = "/admin/drop-database"
                        $0[.method] = "get"
                    }
                    content:
                    {
                        $0[.p]
                        {
                            $0[.button] { $0[.type] = "submit" } = "Drop Database"
                        }
                    }

                    $0[.hr]

                    $0[.h2] = "Replica set information"

                    $0[.dl]
                    {
                        $0[.dt] = "name"
                        $0[.dd] = self.configuration.name

                        $0[.dt] = "members"
                        $0[.dd] = "\(self.configuration.members.map(\.host.description))"

                        $0[.dt] = "version"
                        $0[.dd] = "\(self.configuration.version)"

                        $0[.dt] = "term"
                        $0[.dd] = "\(self.configuration.term)"
                    }
                }
            }
        }
    }
}
