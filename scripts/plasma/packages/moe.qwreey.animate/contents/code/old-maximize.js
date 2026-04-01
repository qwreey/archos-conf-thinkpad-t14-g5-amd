const OPEN_ANIMATE_IGNORE_LIST = [
	"fcitx fcitx"
]
const GEOMETRY_ANIMATE_IGNORE_LIST = [
	"plasmashell org.kde.plasmashell"
]
// TODO: add full screen animation
// TODO: add fullscreen plasmashell gui (eg: fullscreen application menu)
class QPopupAnimation {
	// Check window types
	shouldAnimate(window) {
		if (effects.hasActiveFullScreenEffect
			|| !window.visible) {
			return false
		}
		if (window.deleted && window.skipsCloseAnimation) {
			return false
		}
		if (!window.deleted
			&& effect.isGrabbed(window, Effect.WindowAddedGrabRole)) {
			return false
		}
		if (window.deleted
			&& effect.isGrabbed(window, Effect.WindowClosedGrabRole)) {
			return false
		}
		return true
	}
	isDialogWindow(window) {
		if (window.dialog || window.transient || window.modal) {
			return true
		}
		return false
	}
	isPopupWindow(window) {
		if (window.windowClass == " "
			|| OPEN_ANIMATE_IGNORE_LIST.indexOf(window.windowClass) != -1) {
			return false
		}

		if (window.popupWindow || window.outline
			|| window.notification || window.onScreenDisplay
			|| window.criticalNotification) {
			return true
		}

		if (!window.managed) {
			if (window.utility) {
				return false
			} else {
				return true
			}
		}

		return false
	}

	// Manage force blur
	unforceBlur(window) {
		if (window.forceBlurUntil <= new Date().getTime()) {
			window.setData(Effect.WindowForceBlurRole, null)
		}
	}
	forceBlur(window, time) {
		window.forceBlurUntil = new Date().getTime() + time - 10
		window.setData(Effect.WindowForceBlurRole, true)
	}

	// Dialog animation
	dialogAdded(window) {
		if (effects.hasActiveFullScreenEffect
			|| !this.isDialogWindow(window)
			|| !effect.grab(window, Effect.WindowAddedGrabRole)) {
			return
		}
		this.forceBlur(window, this.dialogOpenDuration)
		window.qOpenAnimation = animate({
			window: window,
			duration: this.dialogOpenDuration,
			animations: [{
				curve: QEasingCurve.OutExpo,
				type: Effect.Scale,
				from: 1.09,
			}, {
				curve: QEasingCurve.OutCubic,
				type: Effect.Opacity,
				from: 0.3,
			}]
		})
	}
	dialogClosed(window) {
		if (effects.hasActiveFullScreenEffect
			|| !this.isDialogWindow(window)
			|| window.skipsCloseAnimation
			|| !effect.grab(window, Effect.WindowClosedGrabRole)) {
			return
		}
		this.forceBlur(window, this.dialogCloseDuration)
		window.qOpenAnimation = animate({
			window: window,
			duration: this.dialogCloseDuration,
			animations: [{
				curve: QEasingCurve.OutExpo,
				type: Effect.Scale,
				to: 1.05,
			}, {
				curve: QEasingCurve.OutCubic,
				type: Effect.Opacity,
				to: 0.0,
			}]
		})
	}

	// Lockscreen animation
	lockscreenAdded(window) {
		window.lockscreenAddedAnimation = animate({
			window: window,
			duration: animationTime(3800),
			animations: [{
				curve: QEasingCurve.OutExpo,
				type: Effect.Scale,
				from: 0.96,
			}, {
				curve: QEasingCurve.OutCubic,
				type: Effect.Opacity,
				from: 0.3,
			}],
		})
	}
	lockscreenClosed(window) {
		if (window.lockscreenAddedAnimation) {
			cancel(window.lockscreenAddedAnimation)
			delete window.lockscreenAddedAnimation
		}

		animate({
			window: window,
			duration: animationTime(860),
			animations: [{
				curve: QEasingCurve.OutQuint,
				type: Effect.Translation,
				to: {
					value1: 0,
					value2: -window.geometry.height,
				},
			}, {
				curve: QEasingCurve.OutQuint,
				type: Effect.Clip,
				to: {
					value1: 1,
					value2: 0,
				},
				targetAnchor: Effect.Top, // 3
			}, {
				curve: QEasingCurve.OutCubic,
				type: Effect.Opacity,
				to: 0.8,
			}],
		})

		for (const item of effects.stackingOrder) {
			if (!item.visible || item.lockScreen) continue
			animate({
				window: item,
				duration: animationTime(1200),
				animations: [{
					curve: QEasingCurve.OutSine,
					type: Effect.Brightness,
					from: 0.11,
					to: 1,
				}],
			})
		}
	}

	// Popup animation
	popupAdded(window) {
		if (effects.hasActiveFullScreenEffect
			|| !this.isPopupWindow(window)
			|| !effect.grab(window, Effect.WindowAddedGrabRole)) {
			return
		}
		this.forceBlur(window, this.popupOpenDuration)
		window.qOpenAnimation = animate({
			window: window,
			duration: this.popupOpenDuration,
			animations: [{
				curve: QEasingCurve.OutExpo,
				type: Effect.Scale,
				from: 0.96,
			}, {
				curve: QEasingCurve.OutCubic,
				type: Effect.Opacity,
				from: 0.3,
			}]
		})
	}
	popupClosed(window) {
		if (effects.hasActiveFullScreenEffect
			|| !this.isPopupWindow(window)
			|| window.skipsCloseAnimation
			|| !effect.grab(window, Effect.WindowClosedGrabRole)) {
			return
		}
		this.forceBlur(window, this.popupCloseDuration)
		window.qCloseAnimation = animate({
			window: window,
			duration: this.popupCloseDuration,
			animations: [{
				curve: QEasingCurve.OutExpo,
				type: Effect.Scale,
				to: 0.92
			}, {
				curve: QEasingCurve.OutCubic,
				type: Effect.Opacity,
				to: 0.0
			}]
		})
	}

	// Geometry animation functions
	animateGeometryChange(window, oldGeometry, newGeometry) {
		if (window.qGeometryChange) {
			cancel(window.qGeometryChange)
			delete window.qGeometryChange
		}

		const oldVolume = oldGeometry.height * oldGeometry.width
		const newVolume = newGeometry.height * newGeometry.width
		const curve = oldVolume < newVolume ? QEasingCurve.OutExpo : QEasingCurve.OutQuint

		this.forceBlur(window, this.maximizeDuration)
		window.qGeometryChange = animate({
			window: window,
			duration: this.maximizeDuration,
			animations: [{
				type: Effect.Size,
				from: {
					value1: oldGeometry.width,
					value2: oldGeometry.height
				},
				to: {
					value1: newGeometry.width,
					value2: newGeometry.height
				},
				curve: curve
			}, {
				type: Effect.Translation,
				from: {
					value1: oldGeometry.x - newGeometry.x - (newGeometry.width / 2 - oldGeometry.width / 2),
					value2: oldGeometry.y - newGeometry.y - (newGeometry.height / 2 - oldGeometry.height / 2)
				},
				to: {
					value1: 0,
					value2: 0
				},
				curve: curve
			}]
		})
	}
	prepareCrossFade(window) {
		if (window.qGeometryChange) {
			cancel(window.qGeometryChange)
			delete window.qGeomhhetryChange
		}
		if (!window.qCrossFadeAnimation
			|| !retarget(window.qCrossFadeAnimation, 1.0, 80000)) {
			window.qCrossFadeAnimation = animate({
				window: window,
				duration: 80000,
				animations: [{
					type: Effect.CrossFadePrevious,
					to: 1.0,
					from: 0.0,
					curve: QEasingCurve.OutQuart
				}]
			})
		}
	}
	retargetCrossFade(window) {
		if (!window.qCrossFadeAnimation) return
		retarget(
			window.qCrossFadeAnimation,
			1.0, this.maximizeCrossFadeDuration
		)
	}
	geometryChangeCancelByClose(window) {
		if (window.qCrossFadeAnimation) {
			cancel(window.qCrossFadeAnimation)
			delete window.qCrossFadeAnimation
		}
		if (window.qGeometryChange) {
			cancel(window.qGeometryChange)
			delete window.qGeometryChange
		}
	}

	// maximize animation
	windowMaximizedStateAboutToChange(window) {
		window.skipGeometryAnimation = true
		if (!window.visible || !window.onCurrentDesktop) return
		if (window.resize && this.userWindowDragging) return

		// Save old geometry and add cross fade animation
		window.maximizeOldGeometry = Object.assign({}, window.geometry)
		this.prepareCrossFade(window)
	}
	windowMaximizedStateChanged(window) {
		if (window.skipGeometryAnimation) {
			delete window.skipGeometryAnimation
		}
		if (!window.maximizeOldGeometry) return
		if (!window.visible || !window.onCurrentDesktop) {
			delete window.maximizeOldGeometry
			return
		}

		// Run geometry animate, retarget cross fade and apply force blur
		this.animateGeometryChange(
			window, window.maximizeOldGeometry, window.geometry
		)
		delete window.maximizeOldGeometry
		this.retargetCrossFade(window)
	}

	// Frame change animation
	isGeometryChangeAnimationTarget(window) {
		// Check skip
		if (window.skipGeometryAnimation)
			return false
		// Check not visible
		if (!window.visible || !window.onCurrentDesktop)
			return false
		// Check user dragging
		if ((window.move || window.resize) && this.userWindowDragging)
			return false
		// Check not supported window type
		if (!window.normalWindow && !window.dialog && !window.modal)
			return false
		if (!window.managed || window.windowClass == " " || !window.moveable || window.specialWindow)
			return false
		if (GEOMETRY_ANIMATE_IGNORE_LIST.indexOf(window.windowClass) != -1)
			return false
		// Check another animation
		if (window.forceBlurForName && window.forceBlurForName != "frame")
			return false
		return true
	}
	windowFrameGeometryAboutToChange(window) {
		if (!this.isGeometryChangeAnimationTarget(window)) return
		this.prepareCrossFade(window)
	}
	windowFrameGeometryChanged(window, oldGeometry) {
		// Check skip
		if (!this.isGeometryChangeAnimationTarget(window)) return

		// Run geometry animate, retarget cross fade and apply force blur
		this.animateGeometryChange(
			window, oldGeometry, window.geometry
		)
		this.retargetCrossFade(window)
	}

	// Handle window
	windowChanged(window, role) {
		if (role == Effect.WindowAddedGrabRole
			&& window.qOpenAnimation
			&& effect.isGrabbed(window, role)) {
			cancel(window.qOpenAnimation)
			delete window.qOpenAnimation
		} else if (role == Effect.WindowClosedGrabRole
			&& window.qCloseAnimation
			&& effect.isGrabbed(window, role)) {
			cancel(window.qCloseAnimation)
			delete window.qCloseAnimation
		}
	}
	windowAdded(window) {
		if (!this.shouldAnimate(window)) {
			return
		}
		if (this.isDialogWindow(window)) {
			this.dialogAdded(window)
		} else if (this.isPopupWindow(window)) {
			this.popupAdded(window)
		} else if (window.lockScreen) {
			this.lockscreenAdded(window)
		}
	}
	windowClosed(window) {
		this.geometryChangeCancelByClose(window)
		if (!this.shouldAnimate(window)) {
			return
		}
		if (this.isDialogWindow(window)) {
			this.dialogClosed(window)
		} else if (this.isPopupWindow(window)) {
			this.popupClosed(window)
		} else if (window.lockScreen) {
			this.lockscreenClosed(window)
		}
	}
	windowStartUserMovedResized(_window) {
		this.userWindowDragging = true
	}
	windowFinishUserMovedResized(_window) {
		this.userWindowDragging = false
	}
	windowInit(window) {
		// window.windowMaximizedStateChanged.connect(this.windowMaximizedStateChanged.bind(this))
		// window.windowMaximizedStateAboutToChange.connect(this.windowMaximizedStateAboutToChange.bind(this))
		window.windowStartUserMovedResized.connect(this.windowStartUserMovedResized.bind(this))
		window.windowFinishUserMovedResized.connect(this.windowFinishUserMovedResized.bind(this))
		window.windowFrameGeometryAboutToChange.connect(this.windowFrameGeometryAboutToChange.bind(this))
		window.windowFrameGeometryChanged.connect(this.windowFrameGeometryChanged.bind(this))
	}

	loadConfig() {
		this.popupCloseDuration = animationTime(260)
		this.popupOpenDuration = animationTime(240)
		this.dialogOpenDuration = animationTime(290)
		this.dialogCloseDuration = animationTime(280)
		this.maximizeDuration = animationTime(390)
		this.maximizeCrossFadeDuration = animationTime(260)
	}

	constructor() {
		this.loadConfig()
		effect.configChanged.connect(this.loadConfig.bind(this))
		effect.animationEnded.connect(this.unforceBlur.bind(this))
		effects.windowAdded.connect(this.windowAdded.bind(this))
		effects.windowAdded.connect(this.windowInit.bind(this))
		effects.windowClosed.connect(this.windowClosed.bind(this))
		effects.windowDataChanged.connect(this.windowChanged.bind(this))
		effects.stackingOrder.forEach(this.windowInit.bind(this))
	}
}
new QPopupAnimation()
