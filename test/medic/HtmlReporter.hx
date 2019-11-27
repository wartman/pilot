package medic;

import pilot.Root;
import pilot.Component;

class HtmlReporter implements Reporter {

  final root:Root;
  final infos:Array<TestInfo> = [];

  public function new(root:Root) {
    this.root = root;
  }

  public function progress(info:TestInfo):Void {
    infos.push(info);
  }

  public function report(result:Result):Void {
    var total:Int = 0;
    var success:Int = 0;
    var failed:Int = 0;
    var fullStatus = '';
    var errors:Array<TestInfo> = [];

    for (c in result.cases) {
      for (test in c.tests) {
        total++;
        switch test.status {
          case Passed: 
            success++;
          case Failed(_): 
            failed++;
            errors.push(test);
        }
      }
    }

    // todo: rethink this display
    fullStatus += '\n${failed == 0 ? 'OK' : 'FAILED'} ${total} tests, ${success} success, ${failed} failed';

    root.update(Pilot.html(<>
      <h1>Test Results</h1>
      <pre>{fullStatus}</pre>
      <if {errors.length > 0}>
        <h2>Errors</h2>
        <ul>
          <for {info in errors}>
            <TestReport info={info} />
          </for>
        </ul>
      </if>
    </>));
  }

}

class TestReport extends Component {

  @:attribute var info:TestInfo;

  override function render() return html(<li>
    <h3>{info.name}::{info.field}()</h3>
    <if {info.description.length > 0}>
      <p>{info.description}</p>
    </if>
    <pre>Status: {display(info.status)}</pre>
  </li>);

  function display(status:TestInfo.TestStatus):String {
    return switch status {
      case Passed: 'Passed';
      case Failed(e): switch e {
        case Warning(message): '(warning) ${message}';
        case Assertion(message, pos): '(failed) ${pos.fileName}:${pos.lineNumber} - ${message}';
        case UnhandledException(message, backtrace): '(unhandled exception) ${message} ${backtrace}';
        case Multiple(errors): [ for (e in errors) display(Failed(e)) ].join(''); 
      }
    }
  }

}