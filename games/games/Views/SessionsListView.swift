import SwiftUI

struct SessionListView: View {
    let cluster: SessionCluster
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List(cluster.sessions) { session in
                HStack {
                    VStack(alignment: .leading) {
                        Text(session.mode).font(.headline)
                        Text(session.timestamp.formatted()).font(.caption)
                    }
                    Spacer()
                    Text("\(session.score) pts").bold()
                }
            }
            .navigationTitle("Sessions at Location")
            .toolbar { Button("Done") { dismiss() } }
        }
    }
}
