const OPEN_ANIMATE_IGNORE_LIST = [
	"fcitx fcitx"
]
const GEOMETRY_ANIMATE_IGNORE_LIST = [
	" ",
	"plasmashell org.kde.plasmashell"
]
const DEBUG_ENABLE = false
function debug(msg) {
	if (DEBUG_ENABLE) print("moe.qwreey.animate: " + msg)
}

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
	animateResize(window, oldGeometry, newGeometry) {
		if (!this.crossFadeRetarget(window)) return false
		this.qAnimateResizeTime = new Date().getTime()
		this.qAnimateResizeOldGeometry = oldGeometry
		this.qAnimateResizeNewGeometry = Object.assign({}, newGeometry)
		this.animateResizeInner(window, oldGeometry, newGeometry)
		return false
	}
	animateResizeRetarget(window, newGeometry) {
		if (this.userWindowDragging) return false
		if (this.qAnimateResizeNewGeometry.height == newGeometry.height
			&& this.qAnimateResizeNewGeometry.width == newGeometry.width
		) return false
		if (this.qAnimateResizeTime + this.maximizeDuration < new Date().getTime()) return false
		this.qAnimateResizeNewGeometry = Object.assign({}, newGeometry)
		this.animateResizeInner(window, this.qAnimateResizeOldGeometry, newGeometry)
		return true
	}
	animateResizeInner(window, oldGeometry, newGeometry) {
		const oldVolume = oldGeometry.height * oldGeometry.width
		const newVolume = newGeometry.height * newGeometry.width
		const curve = oldVolume < newVolume ? QEasingCurve.OutExpo : QEasingCurve.OutQuint

		// Run geometry animate, retarget cross fade and apply force blur
		if (window.qAnimateResize) cancel(window.qAnimateResize)
		this.forceBlur(window, this.maximizeDuration)
		window.qAnimateResize = animate({
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
	animateResizeCancel(window) {
		if (window.qCrossFadeAnimation) {
			const animation = window.qCrossFadeAnimation
			delete window.qCrossFadeAnimation
			cancel(animation)
		}
		if (window.qAnimateResize) {
			const animation = window.qAnimateResize
			delete window.qAnimateResize
			cancel(animation)
		}
	}
	crossFadePrepare(window) {
		if (window.qAnimateResize) {
			const animation = window.qAnimateResize
			delete window.qAnimateResize
			cancel(animation)
		}
		if (!window.qCrossFadeAnimation
			|| !retarget(window.qCrossFadeAnimation, 1.0, 1000)) {
			window.qCrossFadeAnimation = animate({
				window: window,
				duration: 1000,
				animations: [{
					type: Effect.CrossFadePrevious,
					to: 1.0,
					from: 0.0,
					curve: QEasingCurve.OutQuart
				}]
			})
		}
	}
	crossFadeRetarget(window) {
		if (!window.qCrossFadeAnimation) return false
		return retarget(
			window.qCrossFadeAnimation,
			1.0, this.maximizeCrossFadeDuration
		)
	}

	// Frame change animation
	isGeometryChangeAnimationTarget(window) {
		// Check not visible
		if (!window.visible || !window.onCurrentDesktop)
			return false

		// Check user dragging
		if ((window.move || window.resize) && this.userWindowDragging)
			return false

		// Check not supported window type
		if (
			(!window.normalWindow && !window.dialog && !window.modal)
			|| (!window.managed || window.specialWindow)
			|| (GEOMETRY_ANIMATE_IGNORE_LIST.indexOf(window.windowClass) != -1)
		) return false

		// Check another window dragging
		for (const another of effects.stackingOrder) {
			if (another == window) continue
			if (another.resize) return false
		}


		return true
	}
	windowFrameGeometryAboutToChange(window) {
		debug("geo about change")

		// Kill animation when user intended to resizing
		if (!window.move && window.resize && this.userWindowDragging) {
			this.animateResizeCancel(window)
			return
		}

		if (window.maximizeChange) return
		if (!this.isGeometryChangeAnimationTarget(window)) return
		this.crossFadePrepare(window)
		this.geometryAboutToChangeQueued = true
	}
	windowFrameGeometryChanged(window, oldGeometry) {
		debug("geo changed")

		// Retarget animation when user or application fastly change geometry
		if (!this.geometryAboutToChangeQueued) {
			this.animateResizeRetarget(window, window.geometry)
			return
		}
		delete this.geometryAboutToChangeQueued

		this.animateResize(
			window, oldGeometry, window.geometry
		)
	}
	windowMaximizedStateAboutToChange(window) {
		debug("maxi about changed")

		window.maximizeChange = true
		if (!window.move && window.resize && this.userWindowDragging) return
		this.crossFadePrepare(window)
		window.oldGeometry = Object.assign({}, window.geometry)
	}
	windowMaximizedStateChanged(window) {
		debug("maxi changed")

		if (!window.maximizeChange) return
		delete window.maximizeChange
		if (!window.oldGeometry) return

		this.animateResize(
			window, window.oldGeometry, window.geometry
		)
		delete window.oldGeometry
	}
	windowStartUserMovedResized(_window) {
		this.userWindowDragging = true
	}
	windowFinishUserMovedResized(_window) {
		this.userWindowDragging = false
	}

	// Handle window
	windowChanged(window, role) {
		if (role == Effect.WindowAddedGrabRole
			&& window.qOpenAnimation
			&& effect.isGrabbed(window, role)) {
			const animation = window.qOpenAnimation
			delete window.qOpenAnimation
			cancel(animation)
		} else if (role == Effect.WindowClosedGrabRole
			&& window.qCloseAnimation
			&& effect.isGrabbed(window, role)) {
			const animation = window.qCloseAnimation
			delete window.qCloseAnimation
			cancel(animation)
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
		this.animateResizeCancel(window)
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
	minimizedChanged(window) {
		this.animateResizeCancel(window)
	}
	windowInit(window) {
		window.windowMaximizedStateChanged.connect(this.windowMaximizedStateChanged.bind(this))
		window.windowMaximizedStateAboutToChange.connect(this.windowMaximizedStateAboutToChange.bind(this))
		window.windowStartUserMovedResized.connect(this.windowStartUserMovedResized.bind(this))
		window.windowFinishUserMovedResized.connect(this.windowFinishUserMovedResized.bind(this))
		window.windowFrameGeometryAboutToChange.connect(this.windowFrameGeometryAboutToChange.bind(this))
		window.windowFrameGeometryChanged.connect(this.windowFrameGeometryChanged.bind(this))
		window.minimizedChanged.connect(this.minimizedChanged.bind(this))
	}

	loadConfig() {
		this.popupCloseDuration = animationTime(260)
		this.popupOpenDuration = animationTime(240)
		this.dialogOpenDuration = animationTime(290)
		this.dialogCloseDuration = animationTime(280)
		this.maximizeDuration = animationTime(390)
		this.maximizeCrossFadeDuration = animationTime(200)
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
