<?php
/**
 * Generated by Haxe 4.0.0-rc.3+e3df7a448
 */

namespace pilot;

use \php\Boot;

class StatelessWidget implements Widget {
	/**
	 * @return object
	 */
	public function build () {
		#src/pilot/StatelessWidget.hx:7: characters 5-16
		return null;
	}

	/**
	 * @return object
	 */
	public function render () {
		#src/pilot/StatelessWidget.hx:16: characters 5-17
		return $this->build();
	}
}

Boot::registerClass(StatelessWidget::class, 'pilot.StatelessWidget');
