class QGamma {
	loadConfig(isChanged) {
		this.oldBrightness = this.brightness || 100
		this.brightness = effect.readConfig("brightness", 100)
		this.refreshWindows(isChanged)
	}

	refreshWindows(smooth) {
		effects.stackingOrder.forEach(this.animate.bind(this, smooth))
	}
	unanimate(window) {
		if (!window.gammaAnimation) return
		cancel(window.gammaAnimation)
		delete window.gammaAnimation
	}
	animate(smooth, window) {
		this.unanimate(window)
		if (!window.qgammaInited) {
			window.minimizedChanged.connect(this.animate.bind(this, false, window))
			window.qgammaInited = true
		}
		if (!window.visible || window.minimized || this.brightness == 100) {
			return
		}

		window.gammaAnimation = set({
			window: window,
			duration: animationTime(smooth ? 200 : 0),
			curve: QEasingCurve.Linear,
			keepAlive: false,
			animations: [{
				type: Effect.Brightness,
				from: this.oldBrightness / 100,
				to: this.brightness / 100,
			}],
		})
	}

	constructor() {
		this.loadConfig(false)
		effect.configChanged.connect(this.loadConfig.bind(this, true))
		effects.windowAdded.connect(this.animate.bind(this, false))
		effects.desktopChanged.connect(this.refreshWindows.bind(this, false))
		// effects.windowDataChanged.connect(this.windowChanged.bind(this))
	}
}
new QGamma()
