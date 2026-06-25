import AppKit
import WebKit

final class StealthWKWebView: WKWebView {
    var allowsDragAndDrop = false {
        didSet { applyDragAndDropPolicy() }
    }

    override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
        applyDragAndDropPolicy()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    func applyDragAndDropPolicy() {
        if allowsDragAndDrop {
            registerForDraggedTypes([.URL, .fileURL, .string, .html, .rtf, .tiff, .png])
        } else {
            unregisterDraggedTypes(in: self)
        }

        evaluateJavaScript(
            WebViewPolicyScript.dragDropEnabled(allowsDragAndDrop),
            completionHandler: nil
        )
    }

    override func layout() {
        super.layout()
        if !allowsDragAndDrop {
            unregisterDraggedTypes(in: self)
        }
    }

    override func draggingEntered(_ sender: any NSDraggingInfo) -> NSDragOperation {
        allowsDragAndDrop ? super.draggingEntered(sender) : []
    }

    override func draggingUpdated(_ sender: any NSDraggingInfo) -> NSDragOperation {
        allowsDragAndDrop ? super.draggingUpdated(sender) : []
    }

    override func prepareForDragOperation(_ sender: any NSDraggingInfo) -> Bool {
        allowsDragAndDrop ? super.prepareForDragOperation(sender) : false
    }

    override func performDragOperation(_ sender: any NSDraggingInfo) -> Bool {
        allowsDragAndDrop ? super.performDragOperation(sender) : false
    }

    override func concludeDragOperation(_ sender: (any NSDraggingInfo)?) {
        guard allowsDragAndDrop else { return }
        super.concludeDragOperation(sender)
    }

    private func unregisterDraggedTypes(in view: NSView) {
        view.unregisterDraggedTypes()
        for subview in view.subviews {
            unregisterDraggedTypes(in: subview)
        }
    }
}
