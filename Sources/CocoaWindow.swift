//
//  CocoaWindow.swift
//  Vista
//
//  Created by Patrick Horlebein on 06.12.15.
//  Copyright © 2015 Piay Softworks. All rights reserved.
//

import Foundation
import AppKit
import GLKit
import VistaCommon

// TODO(Patrick): Make a protocoll to define the methods a native window needs to have
public class CocoaWindow {

    let window: NSWindow

    let delegate: CocoaWindowDelegate

    public var title: String {
        set {
            window.title = newValue
        }
        get {
            return window.title
        }
    }

    public var frame: NSRect {
        set {
            window.setFrame(newValue, display: true, animate: true)
        }
        get {
            return window.frame
        }
    }

    public init(withRect frame: NSRect, delegate: WindowDelegate, kernel: OpenGLKernel, onClose: (Void -> Void)?) {
        window = NSWindow(contentRect: frame,
                                styleMask: NSTitledWindowMask |
                                           NSClosableWindowMask |
                                           NSResizableWindowMask |
                                           NSMiniaturizableWindowMask,
                                  backing: .Buffered,
                                  `defer`: false)
        window.releasedWhenClosed = false
        window.center()
        window.title = "Untitled"
        window.acceptsMouseMovedEvents = true
        window.restorable = false

        let attributes: [NSOpenGLPixelFormatAttribute] =
        [
            //UInt32(NSOpenGLPFAWindow),
            UInt32(NSOpenGLPFAAccelerated),
            UInt32(NSOpenGLPFADoubleBuffer),
            UInt32(NSOpenGLPFAClosestPolicy),
            UInt32(NSOpenGLPFAColorSize), 24,
            UInt32(NSOpenGLPFAAlphaSize), 8,
            UInt32(NSOpenGLPFADepthSize), 24,
            UInt32(NSOpenGLPFAStencilSize), 8,
            //UInt32(NSOpenGLPFAMultisample),
            //UInt32(NSOpenGLPFASampleBuffers), UInt32(1),
            //UInt32(NSOpenGLPFASamples), UInt32(4),
            //UInt32(NSOpenGLPFAMinimumPolicy),
            UInt32(NSOpenGLPFAOpenGLProfile), UInt32(NSOpenGLProfileVersion4_1Core),
            0
        ]
        let pixelFormat = NSOpenGLPixelFormat(attributes: attributes)!;
        let view: CocoaGLView = CocoaGLView(frame: NSRect(origin: CGPointZero, size: frame.size),
                                  pixelFormat: pixelFormat,
                                       kernel: kernel)!
        view.wantsBestResolutionOpenGLSurface = true

        window.contentView = view
        self.delegate = CocoaWindowDelegate(withDelegate: delegate, onClose: onClose)
        window.delegate = self.delegate
    }

    public var onClose: (Void -> Void)? {
        set {
            delegate.onClose = newValue
        }
        get {
            return delegate.onClose
        }
    }

    public func makeCurrent() {
        window.makeKeyAndOrderFront(window)
        window.makeMainWindow()
    }

    public func pollEvents() -> [Event] {
        return []
    }

    public func close() {
    }
}

internal class CocoaGLView: NSOpenGLView {

    let kernel: OpenGLKernel?


    init?(frame frameRect: NSRect, pixelFormat format: NSOpenGLPixelFormat?, kernel: OpenGLKernel) {
        self.kernel = kernel
        super.init(frame: frameRect, pixelFormat: format)
    }

    required init?(coder: NSCoder) {
        self.kernel = nil
        super.init(coder: coder)
    }

    override func prepareOpenGL() {
        var vsync: GLint = 1
        withUnsafePointer(&vsync) { (pointer: UnsafePointer<GLint>) -> Void in
            openGLContext?.setValues(pointer, forParameter: .GLCPSwapInterval)
        }
        kernel?.prepareOpenGL()
    }

    override func drawRect(dirtyRect: NSRect) {
        glClearColor(0.1, 0.5, 1, 0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        openGLContext?.flushBuffer()
    }
}

internal class CocoaWindowDelegate: NSObject, NSWindowDelegate {

    let delegate: WindowDelegate

    internal var onClose: (Void -> Void)?


    init(withDelegate delegate: WindowDelegate, onClose: (Void -> Void)?) {
        self.delegate = delegate
        self.onClose = onClose
    }

    func windowWillClose(notification: NSNotification) {
        onClose?()
        delegate.windowWillClose();
    }

    func windowWillMiniaturize(notification: NSNotification) {
        delegate.windowWillMiniaturize()
    }
}
