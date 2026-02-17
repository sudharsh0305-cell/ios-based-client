import Foundation
import SwiftUI
import Combine


final class WebSocketManager: ObservableObject {

    private var webSocketTask: URLSessionWebSocketTask?
    private var session: URLSession?
    private var pingTimer: Timer?

    func connect() {
        guard let url = URL(string: "wss://echo.websocket.events") else { return }

        let request = URLRequest(url: url)

        session = URLSession(configuration: .default)
        webSocketTask = session?.webSocketTask(with: request)
        webSocketTask?.resume()

        print("Connected")

        receiveMessage()
        startPing()
    }

    func disconnect() {
        pingTimer?.invalidate()
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        print("Disconnected")
    }

    func send(message: String) {
        let msg = URLSessionWebSocketTask.Message.string(message)

        webSocketTask?.send(msg) { error in
            if let error = error {
                print("Send error:", error)
            }
        }
    }

    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .failure(let error):
                print("Receive error:", error)

            case .success(let message):
                switch message {
                case .string(let text):
                    print("Received:", text)
                case .data(let data):
                    print("Received data:", data)
                @unknown default:
                    break
                }
            }

            self?.receiveMessage()
        }
    }

    private func startPing() {
        pingTimer = Timer.scheduledTimer(withTimeInterval: 25, repeats: true) { [weak self] _ in
            self?.webSocketTask?.sendPing { _ in }
        }
    }
}
