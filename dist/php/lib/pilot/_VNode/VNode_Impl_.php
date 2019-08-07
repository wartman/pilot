<?php
/**
 * Generated by Haxe 4.0.0-rc.3+e3df7a448
 */

namespace pilot\_VNode;

use \php\Boot;
use \pilot\VNodeType;

final class VNode_Impl_ {
	/**
	 * @param object $impl
	 * 
	 * @return object
	 */
	static public function _new ($impl) {
		#src/pilot/VNode.hx:107: lines 107-109
		if ($impl->type === null) {
			#src/pilot/VNode.hx:108: characters 7-31
			$impl->type = VNodeType::VNodeElement();
		}
		#src/pilot/VNode.hx:110: lines 110-112
		if ($impl->children === null) {
			#src/pilot/VNode.hx:111: characters 7-25
			$impl->children = new \Array_hx();
		}
		#src/pilot/VNode.hx:113: characters 21-57
		$_this = $impl->children;
		$result = [];
		$i = 0;
		while ($i < $_this->length) {
			if ($_this->arr[$i] !== null) {
				$result[] = $_this->arr[$i];
			}
			++$i;
		}
		#src/pilot/VNode.hx:113: characters 5-57
		$impl->children = \Array_hx::wrap($result);
		#src/pilot/VNode.hx:114: lines 114-117
		if (\Reflect::hasField($impl->props, "key")) {
			#src/pilot/VNode.hx:115: characters 7-41
			$impl->key = \Reflect::field($impl->props, "key");
			#src/pilot/VNode.hx:116: characters 7-36
			\Reflect::deleteField($impl->props, "key");
		}
		#src/pilot/VNode.hx:118: lines 118-124
		if ($impl->style !== null) {
			#src/pilot/VNode.hx:119: lines 119-123
			if (\Reflect::hasField($impl->props, "className")) {
				#src/pilot/VNode.hx:120: characters 44-54
				$impl1 = $impl->style;
				#src/pilot/VNode.hx:120: characters 9-98
				\Reflect::setField($impl->props, "className", (\Array_hx::wrap([
					$impl1,
					\Reflect::field($impl->props, "className"),
				]))->join(" "));
			} else {
				#src/pilot/VNode.hx:122: characters 9-53
				\Reflect::setField($impl->props, "className", $impl->style);
			}
		}
		#src/pilot/VNode.hx:105: character 3
		return $impl;
	}
}

Boot::registerClass(VNode_Impl_::class, 'pilot._VNode.VNode_Impl_');