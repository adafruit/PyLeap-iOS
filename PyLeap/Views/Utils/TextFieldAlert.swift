// from: https://stackoverflow.com/questions/56726663/how-to-add-a-textfield-to-alert-in-swiftui

import SwiftUI
import Foundation
import Combine
import SwiftUI

class TextFieldAlertViewController: UIViewController {
    
    init(isPresented: Binding<Bool>, alert: TextFieldAlert) {
        self._isPresented = isPresented
        self.alert = alert
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("TODO")
    }
    
    
    @Binding private var isPresented: Bool
    private var alert: TextFieldAlert
    
    // MARK: - Private Properties
    private var subscription: AnyCancellable?
    
    // MARK: - Lifecycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentAlertController()
    }
    
    private func presentAlertController() {
        guard subscription == nil else { return } // present only once
        
        let alertController = UIAlertController(title: alert.title, message: alert.message, preferredStyle: .alert)
        // add a textField and create a subscription to update the `text` binding
        alertController.addTextField {
            $0.text = self.alert.defaultText
        }
        if let cancel = alert.cancel {
            alertController.addAction(UIAlertAction(title: cancel, style: .cancel) { _ in
                self.isPresented = false
            })
        }
        let textField = alertController.textFields?.first
        alertController.addAction(UIAlertAction(title: alert.accept, style: .default) { _ in
            self.isPresented = false
            self.alert.action(textField?.text)
        })
        present(alertController, animated: true, completion: nil)
    }
}

struct TextFieldAlert {
    let title: String
    let message: String?
    var defaultText: String = ""
    public var accept: String = "Done" // The left-most button label
    public var cancel: String? = "Cancel" // The optional cancel (right-most) button label
    public var action: (String?) -> Void // Triggers when either of the two buttons closes the dialog
}

struct AlertWrapper:  UIViewControllerRepresentable {
    
    @Binding var isPresented: Bool
    let alert: TextFieldAlert
    
    typealias UIViewControllerType = TextFieldAlertViewController
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<AlertWrapper>) -> UIViewControllerType {
        TextFieldAlertViewController(isPresented: $isPresented, alert: alert)
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: UIViewControllerRepresentableContext<AlertWrapper>) {
        // no update needed
    }
}

struct TextFieldWrapper<PresentingView: View>: View {
    
    @Binding var isPresented: Bool
    let presentingView: PresentingView
    let content: TextFieldAlert
    
    
    var body: some View {
        ZStack {
            if (isPresented) {
                AlertWrapper(isPresented: $isPresented, alert: content)
            }
            presentingView
        }
    }
}

extension View {
    func alert(isPresented: Binding<Bool>, _ content: TextFieldAlert) -> some View {
        TextFieldWrapper(isPresented: isPresented, presentingView: self, content: content)
    }
}
