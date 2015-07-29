lib = "#{__dirname}/../lib"
Test = require("#{lib}/test")
Path = require("#{lib}/path")
PathTest = new Test('Path')

app_path = Path.normalize("#{__dirname}/../../..")
test = PathTest.set('safe($1)', (args) -> Path.safe(args))
test.should('/foo/bar').return().equal('/foo/bar')
test.should('foo/bar').return().equal("#{app_path}/foo/bar")
test.should('./foo/bar').return().equal("#{app_path}/foo/bar")
test.should('../foo/bar').return().equal(Path.normalize("#{app_path}/../foo/bar"))
test.should('//foo//bar//').return().equal('/foo/bar/')
