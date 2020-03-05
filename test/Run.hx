import medic.Runner;
import medic.HtmlReporter;
import pilot.Root;
import pilot.ComponentExample;

class Run {

  static function main() {
    #if (js && !nodejs)

      Pilot.globalCss('
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
      ');

      var exampleRoot = Pilot.document.getElementById('example-root'); 
      Pilot.mount(
        exampleRoot,
        Pilot.html(<ComponentExample />)
      );

      var root = Pilot.document.getElementById('root');
      var reporter = new HtmlReporter(new Root(root));
      var runner = new Runner(reporter);

      runner.add(new pilot.ComponentTest());
      runner.add(new pilot.ProviderTest());
      runner.add(new pilot.MarkupTest());
      runner.add(new pilot.PluginTest());

      runner.run();

    #else

      var runner = new Runner(new medic.DefaultReporter({
        trackProgress: true,
        verbose: true
      }));
      runner.add(new pilot.ComponentTest());
      runner.add(new pilot.ProviderTest());
      runner.add(new pilot.MarkupTest());
      runner.add(new pilot.PluginTest());
      runner.run();

    #end
  }

}
