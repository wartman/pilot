<?php
/**
 * Generated by Haxe 4.0.0-rc.3+e3df7a448
 */

namespace pilot;

use \php\_Boot\HxAnon;
use \php\Boot;

class Renderer {
	/**
	 * @param mixed $props
	 * 
	 * @return \Array_hx
	 */
	static public function handleAttributes ($props) {
		#src/pilot/Renderer.hx:34: lines 34-38
		$_g = new \Array_hx();
		#src/pilot/Renderer.hx:34: characters 29-34
		$_g1_keys = \Reflect::fields($props);
		$_g1_index = 0;
		#src/pilot/Renderer.hx:34: lines 34-38
		while ($_g1_index < $_g1_keys->length) {
			#src/pilot/Renderer.hx:34: characters 29-34
			$key = ($_g1_keys->arr[$_g1_index++] ?? null);
			$_g2 = new HxAnon([
				"value" => \Reflect::field($props, $key),
				"key" => $key,
			]);
			$k = $_g2->key;
			#src/pilot/Renderer.hx:34: lines 34-38
			$idx = $_g->length;
			$tmp = null;
			$__hx__switch = ($_g2->value);
			if ($__hx__switch === false) {
				$tmp = null;
			} else if ($__hx__switch === true) {
				$tmp = "" . ($k??'null') . " = \"" . ($k??'null') . "\"";
			}
			$_g->arr[$idx] = $tmp;

			++$_g->length;

		}

		$result = [];
		$i = 0;
		while ($i < $_g->length) {
			if ($_g->arr[$i] !== null) {
				$result[] = $_g->arr[$i];
			}
			++$i;
		}
		return \Array_hx::wrap($result);
	}

	/**
	 * @param object $vnode
	 * 
	 * @return string
	 */
	static public function render ($vnode) {
		#src/pilot/Renderer.hx:10: characters 19-29
		$__hx__switch = ($vnode->type->index);
		if ($__hx__switch === 1) {
			#src/pilot/Renderer.hx:28: characters 9-36
			return htmlspecialchars($vnode->name, ENT_QUOTES | ENT_HTML401);
		} else if ($__hx__switch === 0 || $__hx__switch === 2) {
			#src/pilot/Renderer.hx:12: characters 9-36
			$out = "<" . ($vnode->name??'null');
			#src/pilot/Renderer.hx:13: characters 9-51
			$attrs = Renderer::handleAttributes($vnode->props);
			#src/pilot/Renderer.hx:14: lines 14-16
			if ($attrs->length > 0) {
				#src/pilot/Renderer.hx:15: characters 11-39
				$out = ($out??'null') . " " . ($attrs->join(" ")??'null');
			}
			#src/pilot/Renderer.hx:17: lines 17-19
			if ($vnode->children->length === 0) {
				#src/pilot/Renderer.hx:18: characters 11-28
				return ($out??'null') . "/>";
			}
			#src/pilot/Renderer.hx:21: characters 13-60
			$_g = new \Array_hx();
			#src/pilot/Renderer.hx:21: characters 15-58
			$_g1 = 0;
			$_g2 = $vnode->children;
			while ($_g1 < $_g2->length) {
				#src/pilot/Renderer.hx:21: characters 45-58
				$x = Renderer::render(($_g2->arr[$_g1++] ?? null));
				$_g->arr[$_g->length] = $x;
				++$_g->length;
			}

			#src/pilot/Renderer.hx:20: lines 20-22
			return ($out??'null') . ($_g->join("")??'null') . (("</" . ($vnode->name??'null') . ">")??'null');
		} else if ($__hx__switch === 3) {
			#src/pilot/Renderer.hx:24: characters 9-56
			$_g3 = new \Array_hx();
			#src/pilot/Renderer.hx:24: characters 11-54
			$_g11 = 0;
			$_g21 = $vnode->children;
			while ($_g11 < $_g21->length) {
				#src/pilot/Renderer.hx:24: characters 41-54
				$x1 = Renderer::render(($_g21->arr[$_g11++] ?? null));
				$_g3->arr[$_g3->length] = $x1;
				++$_g3->length;
			}

			#src/pilot/Renderer.hx:24: characters 9-65
			return $_g3->join("");
		} else if ($__hx__switch === 4) {
			#src/pilot/Renderer.hx:26: characters 9-11
			return "";
		}
	}
}

Boot::registerClass(Renderer::class, 'pilot.Renderer');
