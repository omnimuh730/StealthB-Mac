import WebKit

enum WebViewDragDropScript {
    static let bootstrap = """
    (function() {
        if (window.__stealthDragDropListenersInstalled) { return; }
        window.__stealthDragDropListenersInstalled = true;
        window.__stealthDragDropEnabled = false;

        function shouldBlock() {
            return !window.__stealthDragDropEnabled;
        }

        function block(event) {
            if (!shouldBlock()) { return; }
            event.preventDefault();
            event.stopPropagation();
            event.stopImmediatePropagation();
            return false;
        }

        ['dragenter', 'dragover', 'dragleave', 'drop', 'dragstart'].forEach(function(type) {
            window.addEventListener(type, block, true);
            document.addEventListener(type, block, true);
        });
    })();
    """
}

enum WebViewPolicyScript {
    static func dragDropEnabled(_ enabled: Bool) -> String {
        "window.__stealthDragDropEnabled = \(enabled ? "true" : "false");"
    }

    static let disableTooltips = """
    (function() {
        document.querySelectorAll('[title]').forEach(function(element) {
            element.removeAttribute('title');
        });
        if (window.__stealthTooltipObserver) {
            window.__stealthTooltipObserver.disconnect();
        }
        window.__stealthTooltipObserver = new MutationObserver(function() {
            document.querySelectorAll('[title]').forEach(function(element) {
                element.removeAttribute('title');
            });
        });
        window.__stealthTooltipObserver.observe(document.documentElement, {
            subtree: true,
            childList: true,
            attributes: true,
            attributeFilter: ['title']
        });
    })();
    """

    static let enableTooltips = """
    (function() {
        if (window.__stealthTooltipObserver) {
            window.__stealthTooltipObserver.disconnect();
            window.__stealthTooltipObserver = null;
        }
    })();
    """
}
