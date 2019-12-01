package pilot.example;

import pilot.Component;

class SvgExample extends Component {

  override function render() return html(<ExampleContainer title="Svg Rendering">
    <svg width="620" height="472" xmlns="http://www.w3.org/2000/svg">
      <defs>
        <path id="b" d="m0 0h77v210h-77z" stroke="#000" stroke-width="2"/>
        <path id="a" d="m0 0h77v60h-77z" stroke="#000" stroke-width="2"/>
      </defs>
      <path d="m0 0h620v472h-620z" fill="#fff"/>
      <g transform="translate(2 1)">
        <use fill="#fff" href="#b"/>
        <use x="77" fill="#ff0" href="#b"/>
        <use x="154" fill="#0ff" href="#b"/>
        <use x="231" fill="#0f0" href="#b"/>
        <use x="308" fill="#f0f" href="#b"/>
        <use x="385" fill="red" href="#b"/>
        <use x="462" fill="#00f" href="#b"/>
        <use x="539" href="#b"/>
      </g>
      <g transform="translate(2 230)">
        <use fill="red" href="#a"/>
        <use x="77" fill="red" href="#a"/>
        <use x="154" fill="#fff" href="#a"/>
        <use x="231" fill="#fff" href="#a"/>
        <use x="308" fill="red" href="#a"/>
        <use x="385" fill="red" href="#a"/>
        <use x="462" fill="#fff" href="#a"/>
        <use x="539" fill="#fff" href="#a"/>
      </g>
      <g transform="translate(2 312)">
        <use fill="#0f0" href="#a"/>
        <use x="77" fill="#0f0" href="#a"/>
        <use x="154" fill="#0f0" href="#a"/>
        <use x="231" fill="#0f0" href="#a"/>
        <use x="308" fill="#fff" href="#a"/>
        <use x="385" fill="#fff" href="#a"/>
        <use x="462" fill="#fff" href="#a"/>
        <use x="539" fill="#fff" href="#a"/>
      </g>
      <g transform="translate(2 392)">
        <use fill="#00f" href="#a"/>
        <use x="77" fill="#fff" href="#a"/>
        <use x="154" fill="#00f" href="#a"/>
        <use x="231" fill="#fff" href="#a"/>
        <use x="308" fill="#00f" href="#a"/>
        <use x="385" fill="#fff" href="#a"/>
        <use x="462" fill="#00f" href="#a"/>
        <use x="539" fill="#fff" href="#a"/>
      </g>
      <text font-family="DejaVu Sans" stroke-width="4" x="310" y="174.47" font-size="180" text-anchor="middle">TEST</text>
    </svg>
  </ExampleContainer>);

}
