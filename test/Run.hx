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

// Todo: for some reason, I got very sloppy with my tests and
//       most of the unit tests DON'T just test the class they're 
//       supposed to. Clean this up?
class Run {

  static function main() {
    #if (js && !nodejs)

      js.Browser.document.body.classList.add(Pilot.css('
        @global {
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
        }
      '));

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
    
    runner.add(new pilot.StateTest());
    runner.add(new pilot.DifferTest());
    runner.add(new pilot.ComponentTest());
    runner.add(new pilot.HtmlTest());
    runner.add(new pilot.MarkupTest());

    runner.run();

  }

}
