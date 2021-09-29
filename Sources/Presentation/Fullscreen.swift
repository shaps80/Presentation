import SwiftUI
import Combine

#if os(iOS)

internal struct FullscreenView<Content: View>: UIViewControllerRepresentable {

    let isPresented: Binding<Bool>
    let isModal: Bool
    let transition: UIModalTransitionStyle
    let style: UIModalPresentationStyle
    let onDismiss: (() -> Void)?
    let content: () -> Content

    func makeUIViewController(context: Context) -> UIViewController {
        FullscreenWrapper(isPresented: isPresented, onDismiss: onDismiss, content: content)
    }

    func updateUIViewController(_ controller: UIViewController, context: Context) {
        guard let controller = controller as? FullscreenWrapper<Content> else { return }
        controller.isPresented = isPresented
        controller.isModal = isModal
        controller.transition = transition
        controller.style = style
        controller.onDismiss = onDismiss
        controller.content = content
        controller.presentIfNeeded()
    }
}

private final class FullscreenWrapper<Content: View>: UIViewController {

    var isPresented: Binding<Bool>
    var isModal: Bool = false
    var transition: UIModalTransitionStyle = .coverVertical
    var style: UIModalPresentationStyle = .pageSheet
    var onDismiss: (() -> Void)?
    var content: () -> Content
    private var cancel: AnyCancellable?

    init(isPresented: Binding<Bool>, onDismiss: (() -> Void)?, content: @escaping () -> Content) {
        self.isPresented = isPresented
        self.onDismiss = onDismiss
        self.content = content
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        presentIfNeeded()
    }

    func presentIfNeeded() {
        let isAlreadyPresented = presentedViewController != nil

        if isAlreadyPresented != isPresented.wrappedValue {
            if !isAlreadyPresented {
                let controller = viewController(rootView: content(), isModal: isModal, transition: transition, style: style) { [weak self] in
                    self?.isPresented.wrappedValue = false
                    self?.onDismiss?()
                }
                present(controller, animated: true)
            }
        }
    }

}

#endif
