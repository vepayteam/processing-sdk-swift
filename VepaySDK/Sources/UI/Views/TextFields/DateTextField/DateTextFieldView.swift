//
//  DateTextFieldView.swift
//  VepaySDK
//
//  Created by Bohdan Hrozian on 3/26/25.
//

import SwiftUI

//@available(iOS 13.0, *)
//public struct VeapyDateTextFieldView: UIViewRepresentable {
//
//
//    // Field
//    public let placeholder: String
//
//    public let contentType: UITextContentType?
//    public let keyboardType: UIKeyboardType
//
//    // Coordinator
//
//    @ObservedObject public var state: ProfileTextField.Field
//    public let isEditing: Bool
//    public let onSubmit: () -> Void
//    public let foregroundColor: UIColor
//
//    // MARK: - Private
//
//    public func makeUIView(context: Context) -> VepayDateTextField {
//        let field = VepayDateTextField()
//        field.placeholder = placeholder
//        field.defaultDelegate = context.coordinator
//        field.textField.textContentType = contentType
//        field.textField.keyboardType = keyboardType
//        field.setMinHeight = false
//        field.withGradient = false
//        field.formatter = state.formatter as? VepayDateTextFormatter
//
//        context.coordinator.isEditing = isEditing
//        return field
//    }
//    
//    public func makeCoordinator() -> Coordinator {
//        Coordinator(onSubmit: onSubmit, state: _state, isEditing: isEditing)
//    }
//
//    public func updateUIView(_ view: VepayDateTextField, context: Context) {
//        context.coordinator.isEditing = isEditing
//        view.setContentHuggingPriority(.defaultHigh, for: .vertical)
//        view.setContentCompressionResistancePriority(.required, for: .vertical)
//
//        view.textField.textColor = foregroundColor
//        view.tintColor = foregroundColor
//        context.coordinator.set(state: _state)
//        if view.textField.text != state.text {
//            view.textField.text = state.text
//        }
//    }
//
//    public final class Coordinator: NSObject, VepayCommonTextFieldDelegate {
//        @ObservedObject public var state: ProfileTextField.Field
//        public let onSubmit: () -> Void
//        public var isEditing: Bool
//        
//        public func set(state: ObservedObject<ProfileTextField.Field>) {
//            self._state = state
//        }
//
//        init(onSubmit: @escaping () -> Void, state: ObservedObject<ProfileTextField.Field>, isEditing: Bool) {
//            self.onSubmit = onSubmit
//            self._state = state
//            self.isEditing = isEditing
//        }
//
//        func textFieldShouldBeginEditing(_ field: VepayCommonTextField) -> Bool {
//            isEditing
//        }
//
//        func textFieldShouldChangeCharacters(_ field: VepayCommonTextField) -> Bool {
//            isEditing
//        }
//        
//        func textFieldUpdated(_ field: VepayCommonTextField, text: String) {
//            if text != self.state.text {
//                self.state.text = text
//            }
//        }
//        
//        func textFieldReadyChanged(_ field: VepayCommonTextField, ready: Bool) {
//            state.withoutError = ready
//        }
//        
//        public func textFieldShouldReturn(_ field: VepayCommonTextField) -> Bool {
//            onSubmit()
//            return true
//        }
//
//    }
//
//}
