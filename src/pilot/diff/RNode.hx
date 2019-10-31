package pilot.diff;

enum RNode<Real:{}> {
  RNative<Attrs>(node:Real, attrs:Attrs);
  RWidget<Attrs>(widget:Widget<Real>);
}

// class RNodeTools {

//   public static function getNode(rNode:RNode) {

//   }

// }
