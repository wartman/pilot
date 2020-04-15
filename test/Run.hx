import medic.Runner;
import medic.HtmlReporter;
import pilot.Context;
import pilot.Root;
import pilot.ComponentExample;
#if (js && !nodejs)
  import pilot.platform.dom.Dom;
#else
  import pilot.platform.server.Server;
#end

class Run {

  static function main() {
    #if (js && !nodejs)

      Pilot.css('
        body {
          display: flex;
          font: 14px "Helvetica Neue", Helvetica, Arial, sans-serif;
        }
        html {
          box-sizing: border-box;
        }
        *, *:before, *:after {
          box-sizing: inherit;
        }
        #example-root {
          flex: 1;
          margin-right: 10px;
        }
        #root {
          flex: 1;
        }
        @media screen and (max-width: 750px) {
          body {
            flex-direction: column;
          }
        }
      ', { global: true });

      var exampleRoot = js.Browser.document.getElementById('example-root');
      Dom.mount(exampleRoot, ComponentExample.node({}));

      var root:js.html.Node = js.Browser.document.getElementById('root');
      var context = new Context(new pilot.platform.dom.DomEngine());
      var reporter = new HtmlReporter(new Root(root, context));
      var runner = new Runner(reporter);

    #else

      var runner = new Runner(new medic.DefaultReporter({
        trackProgress: true,
        verbose: true
      }));
    
    #end
    
    runner.add(new pilot.ComponentTest());
    runner.add(new pilot.ProviderTest());
    runner.add(new pilot.HtmlTest());
    runner.add(new pilot.MarkupTest());

    runner.run();

  }

}
