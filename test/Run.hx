import medic.Runner;
#if (js && !nodejs)
  import medic.HtmlReporter;
  import pilot.Root;
  import pilot.ComponentExample;
#end

class Run {

  static function main() {
    #if (js && !nodejs)
      Pilot.globalCss('
        body {
          display: flex;
        }
        #example-root {
          flex: 1;
          margin-right: 10px;
        }
        #root {
          flex: 1;
        }
      ');

      Pilot.mount(
        Pilot.dom.getElementById('example-root'),
        Pilot.html(<ComponentExample />)
      );

      var root = new Root(Pilot.dom.getElementById('root'));
      var reporter = new HtmlReporter(root);
      var runner = new Runner(reporter);
    #else
      var runner = new Runner();
    #end

    runner.add(new pilot.MarkupTest());

    runner.run();
  }

}
