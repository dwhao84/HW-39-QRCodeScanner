//
//  QRCodeScannerViewController.swift
//  HW#39-QRCodeScanner
//
//  Created by Dawei Hao on 2023/11/25.
//

import UIKit
import AVFoundation
import Vision
import VisionKit
import MessageUI

class QRCodeScannerViewController: UIViewController {

    let qrcodeScannerButton: UIButton = UIButton(type: .system)

    var observation: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        print("Into the scannerView")

        configureQRcodeScannerButton()

    }
    
    func configureQRcodeScannerButton () {
        // view
        let bgColor: UIColor = .white
        self.view.backgroundColor = bgColor

        // Button
        var configuration = UIButton.Configuration.plain()
        qrcodeScannerButton.tintColor = .systemBlue
        configuration.image = UIImage(systemName: "qrcode.viewfinder")
        configuration.preferredSymbolConfigurationForImage = .init(pointSize: 60)
        configuration.imagePlacement = .top
        configuration.titleAlignment = .center
        configuration.title = "Tap me"
        configuration.imagePadding = 20
        qrcodeScannerButton.configuration = configuration
        // addTarget
        qrcodeScannerButton.addTarget(self, action: #selector(qrCodeScannerTapped), for: .touchUpInside)
        view.addSubview(qrcodeScannerButton)

        // Button's Auto-Layout
        qrcodeScannerButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            qrcodeScannerButton.widthAnchor.constraint(equalToConstant: 100),
            qrcodeScannerButton.heightAnchor.constraint(equalToConstant: 100),
            qrcodeScannerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            qrcodeScannerButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc func qrCodeScannerTapped (_ sender : UIButton ) {
        print("QRCode scanner tapped")
        let documentCameraController = VNDocumentCameraViewController()
        documentCameraController.delegate = self
        present(documentCameraController, animated: true)
    }

    func sendingMessage () {
        if MFMessageComposeViewController.canSendText() {
            let composeVC = MFMessageComposeViewController()
            // The message who want to receive.
            composeVC.recipients = ["1922"]
            // The content we want to sending.
            composeVC.body = "\(observation)\n統一時代百貨\n本次簡訊限防疫目的使用"
            composeVC.messageComposeDelegate = self
            self.present(composeVC, animated: true, completion: nil)
        } else {
            print("error handing")
        }
    }

    func sendingEmail () {
        let mailComposeVC = MFMailComposeViewController()
        mailComposeVC.mailComposeDelegate = self
        mailComposeVC.setSubject("")
        mailComposeVC.setMessageBody("", isHTML: true)
    }
}

// MARK: - Extension
// VNDocumentCameraViewControllerDelegate
extension QRCodeScannerViewController: VNDocumentCameraViewControllerDelegate {
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {

        // Requests the image of a page at a specified index.
        let image = scan.imageOfPage(at: scan.pageCount - 1)
        print(image)
        processImage(image: image)
        // disppear
        dismiss(animated: true, completion: nil)
    }

    // 使用 VNImageRequestHandler & VNDetectBarcodesRequest 解析圖片裡的 QR Code
    func processImage(image: UIImage) {

        // Generate the  VNImageRequestHandler and parse the cgImage by instance cgImage from my created.
        guard let cgImage = image.cgImage else {
            print("Failed to get cgimage from input image")
            return
        }

        // Let handler could be able to read the by VNImageRequestHandler cgImage.
        let handler = VNImageRequestHandler(cgImage: cgImage)

        let request = VNDetectContoursRequest { request, error in
            if let observation = request.results?.first as? VNBarcodeObservation,
               observation.symbology == .qr {                                      // Make sure the symbology is qrCode.
                print(observation.payloadStringValue ?? "")                        // Print the observation's result.
            }
        }
        do {
            try handler.perform([request])
            sendingMessage()
            print(observation)
        } catch {
            print("error")
        }
    }
}


// MFMessageComposeViewControllerDelegate
extension QRCodeScannerViewController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {

        // Dismiss the message compose view controller.
        controller.dismiss(animated: true, completion: nil)
    }
}

extension QRCodeScannerViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {

        // Dismiss the mail compose view controller.
        controller.dismiss(animated: true)
    }
}
