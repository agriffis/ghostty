import SwiftUI

class SurfaceScrollView: NSView {
    private let scrollView: NSScrollView
    private let documentView: NSView
    private let surfaceView: Ghostty.SurfaceView
    private var scrollObserver: NSObjectProtocol?
    private var scrollbarStateObserver: NSObjectProtocol?
    
    init(contentSize: CGSize, surfaceView: Ghostty.SurfaceView) {
        self.surfaceView = surfaceView
        // The scroll view is our outermost view that controls all our scrollbar
        // rendering and behavior.
        scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.usesPredominantAxisScrolling = true
        
        // The document view is what the scrollview is actually going
        // to be directly scrolling. We set it up to a "blank" NSView
        // with the desired content size.
        documentView = NSView(frame: NSRect(origin: .zero, size: contentSize))
        scrollView.documentView = documentView
        
        // The document view contains our actual surface as a child.
        // We synchronize the scrolling of the document with this surface
        // so that our primary Ghostty renderer only needs to render the viewport.
        documentView.addSubview(surfaceView)
        
        super.init(frame: .zero)
        
        // Our scroll view is our only view
        addSubview(scrollView)
        
        // We listen for scroll events through bounds notifications on our NSClipView.
        // This is based on: https://christiantietze.de/posts/2018/07/synchronize-nsscrollview/
        scrollView.contentView.postsBoundsChangedNotifications = true
        scrollObserver = NotificationCenter.default.addObserver(
            forName: NSView.boundsDidChangeNotification,
            object: scrollView.contentView,
            queue: .main
        ) { [weak self] notification in
            self?.handleScrollChange(notification)
        }
        
        // Listen for scrollbar updates from Ghostty
        scrollbarStateObserver = NotificationCenter.default.addObserver(
            forName: .ghosttyDidUpdateScrollbar,
            object: surfaceView,
            queue: .main
        ) { [weak self] notification in
            self?.handleScrollbarUpdate(notification)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
    
    deinit {
        if let scrollObserver {
            NotificationCenter.default.removeObserver(scrollObserver)
        }
        if let scrollbarStateObserver {
            NotificationCenter.default.removeObserver(scrollbarStateObserver)
        }
    }
    
    override func setFrameSize(_ newSize: NSSize) {
        super.setFrameSize(newSize)
        
        // Keep the surface view in sync with our frame
        surfaceView.frame.size = newSize
        
        // Inform the actual pty of our size change. In the future we should
        // sync this at all times in SurfaceView itself.
        surfaceView.sizeDidChange(newSize)
    }
    
    override func layout() {
        super.layout()
        
        // Fill entire bounds with scroll view
        scrollView.frame = bounds
        
        // When our scrollview changes make sure our surface view is synchronized
        synchronizeSurfaceView()
    }
    
    // MARK: Scrolling
    
    private func synchronizeSurfaceView() {
        // Move the surface view so that it takes over the entire visible rect.
        // This ensures that as our NSScrollView scrolls around our [blank]
        // document view, our metal view just magically follows it around.
        let visibleRect = scrollView.contentView.documentVisibleRect
        surfaceView.frame = visibleRect
    }
    
    // MARK: Notifications
    
    private func handleScrollChange(_ notification: Notification) {
        synchronizeSurfaceView()
    }
    
    private func handleScrollbarUpdate(_ notification: Notification) {
        guard let scrollbar = notification.userInfo?[SwiftUI.Notification.Name.ScrollbarKey] as? Ghostty.Action.Scrollbar else {
            return
        }
        
        // Convert row units to pixels using cell height
        let cellHeight = surfaceView.cellSize.height
        let totalHeight = CGFloat(scrollbar.total) * cellHeight
        
        // AppKit views are +Y going up so we have to invert it.
        let offsetY = CGFloat(scrollbar.total - scrollbar.offset - scrollbar.len) * cellHeight
        
        // Our width should just be the width of the scrollview since we don't
        // do horizontal scrolling in terminals.
        let newSize = CGSize(width: scrollView.frame.width, height: totalHeight)
        documentView.setFrameSize(newSize)
        
        // Update the scroll position to match the offset
        scrollView.contentView.scroll(to: CGPoint(x: 0, y: offsetY))
        scrollView.reflectScrolledClipView(scrollView.contentView)
    }
}
