package pilot2.diff;

enum RNode<Real:{}> {
  RNative<Attrs>(node:Real, attrs:Attrs);
  RWidget<Attrs>(widget:Widget<Real>);
  RKeyed(key:Key, node:RNode<Real>);
}

// class RNodeTools {

//   public static function getNode(rNode:RNode) {

//   }

// }
