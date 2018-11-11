//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    // Camera view
    var cameraView: CameraView!

    // AV capture session and dispatch queue
    let session = AVCaptureSession()
    let sessionQueue = DispatchQueue(label: AVCaptureSession.self.description(), attributes: [], target: nil)

    var isShowingAlert = false

    override func loadView() {
        cameraView = CameraView()

        view = cameraView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Barcode Scanner"
        
        session.beginConfiguration()

        if let videoDevice = AVCaptureDevice.default(for: .video) {
            if let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice) {
                if (session.canAddInput(videoDeviceInput)) {
                    session.addInput(videoDeviceInput)
                }
            }

            let metadataOutput = AVCaptureMetadataOutput()

            if (session.canAddOutput(metadataOutput)) {
                session.addOutput(metadataOutput)

                metadataOutput.metadataObjectTypes = [
                    .code128,
                    .code39,
                    .code93,
                    .ean13,
                    .ean8,
                    .qr,
                    .upce
                ]

                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            }
        }

        session.commitConfiguration()

        cameraView.layer.session = session
        cameraView.layer.videoGravity = .resizeAspectFill

        // Set initial camera orientation
        let videoOrientation: AVCaptureVideoOrientation
        switch UIApplication.shared.statusBarOrientation {
            case .portrait:
                videoOrientation = .portrait

            case .portraitUpsideDown:
                videoOrientation = .portraitUpsideDown

            case .landscapeLeft:
                videoOrientation = .landscapeLeft

            case .landscapeRight:
                videoOrientation = .landscapeRight

            default:
                videoOrientation = .portrait
        }

        cameraView.layer.connection?.videoOrientation = videoOrientation
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Start AV capture session
        sessionQueue.async {
            self.session.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Stop AV capture session
        sessionQueue.async {
            self.session.stopRunning()
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        // Update camera orientation
        let videoOrientation: AVCaptureVideoOrientation
        switch UIDevice.current.orientation {
            case .portrait:
                videoOrientation = .portrait

            case .portraitUpsideDown:
                videoOrientation = .portraitUpsideDown

            case .landscapeLeft:
                videoOrientation = .landscapeRight

            case .landscapeRight:
                videoOrientation = .landscapeLeft

            default:
                videoOrientation = .portrait
        }

        cameraView.layer.connection?.videoOrientation = videoOrientation
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Display barcode value
        if !isShowingAlert,
            metadataObjects.count > 0,
            metadataObjects.first is AVMetadataMachineReadableCodeObject,
            let scan = metadataObjects.first as? AVMetadataMachineReadableCodeObject {
            let alertController = UIAlertController(title: "Barcode Scanned", message: scan.stringValue, preferredStyle: .alert)

            isShowingAlert = true

            alertController.addAction(UIAlertAction(title: "OK", style: .default) { action in
                self.isShowingAlert = false
            })

            present(alertController, animated: true, completion: nil)
        }
    }
}

class CameraView: UIView {
    override class var layerClass: AnyClass {
        get {
            return AVCaptureVideoPreviewLayer.self
        }
    }

    override var layer: AVCaptureVideoPreviewLayer {
        get {
            return super.layer as! AVCaptureVideoPreviewLayer
        }
    }
}
