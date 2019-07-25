<?php
/**
 * Generated by Haxe 4.0.0-rc.3+e3df7a448
 */

namespace _Array;

use \php\Boot;
use \php\_Boot\HxClosure;

class ArrayIterator {
	/**
	 * @var \Array_hx
	 */
	public $arr;
	/**
	 * @var int
	 */
	public $idx;

	/**
	 * @param \Array_hx $arr
	 * 
	 * @return void
	 */
	public function __construct ($arr) {
		#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:235: characters 3-17
		$this->arr = $arr;
		#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:236: characters 3-10
		$this->idx = 0;
	}

	/**
	 * @param string $method
	 * 
	 * @return HxClosure
	 */
	public function __get ($method) {
		#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:250: lines 250-253
		if ($method === "hasNext" || $method === "next") {
			#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:251: characters 28-54
			$target = $this;
			if (is_string($target)) {
				return Boot::getStaticClosure($target, $method);
			} else {
				return Boot::getInstanceClosure($target, $method);
			}
		} else {
			#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:252: characters 12-16
			return null;
		}
	}

	/**
	 * @return bool
	 */
	public function hasNext () {
		#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:240: characters 3-26
		return $this->idx < $this->arr->length;
	}

	/**
	 * @return mixed
	 */
	public function next () {
		#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:244: characters 3-20
		return ($this->arr->arr[$this->idx++] ?? null);
	}
}

Boot::registerClass(ArrayIterator::class, '_Array.ArrayIterator');
