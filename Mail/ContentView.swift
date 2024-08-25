//
//  ContentView.swift
//  Mail
//
//  Created by Thibault Giraudon on 25/08/2024.
//

import SwiftUI
import MessageUI

struct MailView: UIViewControllerRepresentable {
    @Environment(\.dismiss) var dismiss
    @Binding var result: Result<MFMailComposeResult, Error>?
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        var parent: MailView
        
        init(_ parent: MailView) {
            self.parent = parent
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            defer {
                parent.dismiss()
            }
            if let error = error {
                parent.result = .failure(error)
            } else {
                parent.result = .success(result)
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = context.coordinator
        vc.setToRecipients(["thibault.giraudon@gmail.com"])
        vc.setSubject("FuelTracker Review")
        vc.setMessageBody("Hello, I'm using FuelTracker to track my fuel consumption. It's really useful!", isHTML: false)
        return vc
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {
        // Nothing to update here
    }
    
    static func canSendMail() -> Bool {
        return MFMailComposeViewController.canSendMail()
    }
}

struct ContentView: View {
    @State private var showingMailView = false
    @State private var mailResult: Result<MFMailComposeResult, Error>? = nil
    @State private var alertMessage: String?
    @State private var alertIsPresented: Bool = false
    
    var body: some View {
        VStack {
            Button("Send Email") {
                showingMailView.toggle()
            }
            .disabled(!MailView.canSendMail())
            .sheet(isPresented: $showingMailView) {
                MailView(result: $mailResult)
                    .onAppear {
                        
                    }
                    .onDisappear {
                        if let result = mailResult {
                            switch result {
                            case .success(let mailResult):
                                switch mailResult {
                                case .sent:
                                    alertMessage = "Mail sent successfully!"
                                    alertIsPresented = true
                                case .saved:
                                    alertMessage = "Mail saved as draft."
                                    alertIsPresented = true
                                case .cancelled:
                                    alertMessage = "Mail cancelled."
                                    alertIsPresented = true
                                case .failed:
                                    alertMessage = "Mail failed to send."
                                    alertIsPresented = true
                                @unknown default:
                                    alertMessage = "Unknown error."
                                    alertIsPresented = true
                                }
                            case .failure(let error):
                                alertMessage = error.localizedDescription
                            }
                        }
                    }
            }
            .alert(isPresented: $alertIsPresented) {
                Alert(title: Text("Mail Status"), message: Text(alertMessage!), dismissButton: .default(Text("OK")))
            }
        }
    }
}


#Preview {
    ContentView()
}
