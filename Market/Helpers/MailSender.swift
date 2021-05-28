//
//  MailSender.swift
//  Market
//
//  Created by Conor Andrews on 13/05/2021.
//

import Foundation
import skpsmtpmessage

class MailSender: NSObject, SKPSMTPMessageDelegate {
    
    static let shared = MailSender()
    
    func sendEmail(subject: String, body: String) {
        let message = SKPSMTPMessage()
        message.relayHost = "smtp.gmail.com"
        message.login = "login@gmail.com"
        message.pass = "password"
        message.requiresAuth = true
        message.wantsSecure = true
        message.relayPorts = [587]
        message.fromEmail = "no-reply@prettyinpaper.com"
        message.toEmail = "to@gmail.com"
        message.subject = subject
        let messagePart = [kSKPSMTPPartContentTypeKey: "text/plain; charset=UTF-8", kSKPSMTPPartMessageKey: body]
        message.parts = [messagePart]
        message.delegate = self
        message.send()
    }
    
    func messageSent(_ message: SKPSMTPMessage!) {
        print("Successfully sent email!")
    }
    
    func messageFailed(_ message: SKPSMTPMessage!, error: Error!) {
        print("Email sending failed!")
    }
}
