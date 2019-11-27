import medic.Runner;
import medic.HtmlReporter;
import pilot.Root;

class Run {

  static function main() {
    var root = new Root(Pilot.dom.getElementById('root'));
    var reporter = new HtmlReporter(root);
    var runner = new Runner(reporter);

    runner.add(new pilot.MarkupTest());

    runner.run();
  }

}
