import SwiftUI

struct ContentView: View {

    @StateObject private var socket = WebSocketManager()

    var body: some View {
        VStack(spacing: 20) {

            Button("Connect") {
                socket.connect()
            }

            Button("Send Message") {
                socket.send(message: "Hello from iOS")
            }

            Button("Disconnect") {
                socket.disconnect()
            }
        }
        .padding()
    }
}
