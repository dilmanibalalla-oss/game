import AVFoundation

class SoundManager {
    static let shared = SoundManager()
    
    private var players: [String: AVAudioPlayer] = [:]
    
    private init() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
        try? session.setActive(true)
    }
    
    func playCorrect() {
        playSound(frequency: 523.25, duration: 0.08, type: "sine") // C5
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            self.playSound(frequency: 659.25, duration: 0.15, type: "sine") // E5
        }
    }
    
    func playIncorrect() {
        playSound(frequency: 180.0, duration: 0.2, type: "triangle")
    }
    
    func playGreenTap() {
        playSound(frequency: 880.0, duration: 0.1, type: "sine") // A5
    }
    
    private func playSound(frequency: Double, duration: Double, type: String = "sine") {
        let sampleRate = 44100.0
        let numSamples = Int(sampleRate * duration)
        let numChannels = 1
        let bitsPerSample = 16
        
        let headerSize = 44
        let dataSize = numSamples * numChannels * (bitsPerSample / 8)
        let fileSize = headerSize + dataSize - 8
        
        var data = Data(count: headerSize + dataSize)
        
        data.replaceSubrange(0..<4, with: "RIFF".data(using: .ascii)!)
        var tempFileSize = Int32(fileSize)
        withUnsafePointer(to: &tempFileSize) {
            data.replaceSubrange(4..<8, with: Data(bytes: $0, count: 4))
        }
        data.replaceSubrange(8..<12, with: "WAVE".data(using: .ascii)!)
        data.replaceSubrange(12..<16, with: "fmt ".data(using: .ascii)!)
        var formatSize = Int32(16)
        withUnsafePointer(to: &formatSize) {
            data.replaceSubrange(16..<20, with: Data(bytes: $0, count: 4))
        }
        var formatType = Int16(1) // PCM
        withUnsafePointer(to: &formatType) {
            data.replaceSubrange(20..<22, with: Data(bytes: $0, count: 2))
        }
        var channels = Int16(numChannels)
        withUnsafePointer(to: &channels) {
            data.replaceSubrange(22..<24, with: Data(bytes: $0, count: 2))
        }
        var rate = Int32(sampleRate)
        withUnsafePointer(to: &rate) {
            data.replaceSubrange(24..<28, with: Data(bytes: $0, count: 4))
        }
        var byteRate = Int32(sampleRate * Double(numChannels) * Double(bitsPerSample / 8))
        withUnsafePointer(to: &byteRate) {
            data.replaceSubrange(28..<32, with: Data(bytes: $0, count: 4))
        }
        var blockAlign = Int16(numChannels * (bitsPerSample / 8))
        withUnsafePointer(to: &blockAlign) {
            data.replaceSubrange(32..<34, with: Data(bytes: $0, count: 2))
        }
        var bits = Int16(bitsPerSample)
        withUnsafePointer(to: &bits) {
            data.replaceSubrange(34..<36, with: Data(bytes: $0, count: 2))
        }
        data.replaceSubrange(36..<40, with: "data".data(using: .ascii)!)
        var tempDataSize = Int32(dataSize)
        withUnsafePointer(to: &tempDataSize) {
            data.replaceSubrange(40..<44, with: Data(bytes: $0, count: 4))
        }
        
        data.withUnsafeMutableBytes { (buffer: UnsafeMutableRawBufferPointer) -> Void in
            guard let baseAddress = buffer.baseAddress else { return }
            let typedBuffer = baseAddress.assumingMemoryBound(to: Int16.self)
            
            for i in 0..<numSamples {
                let t = Double(i) / sampleRate
                var sampleValue: Double = 0.0
                
                if type == "sine" {
                    sampleValue = sin(2.0 * .pi * frequency * t)
                } else if type == "square" {
                    sampleValue = sin(2.0 * .pi * frequency * t) >= 0 ? 1.0 : -1.0
                } else if type == "triangle" {
                    let period = 1.0 / frequency
                    let phase = (t.truncatingRemainder(dividingBy: period)) / period
                    sampleValue = 4.0 * abs(phase - 0.5) - 1.0
                }
                
                let fadeOutRange = 0.1
                let currentProgress = Double(i) / Double(numSamples)
                if currentProgress > (1.0 - fadeOutRange) {
                    let factor = (1.0 - currentProgress) / fadeOutRange
                    sampleValue *= factor
                }
                
                let val = Int16(sampleValue * 32767.0)
                typedBuffer[22 + i] = val
            }
        }
        
        do {
            let player = try AVAudioPlayer(data: data)
            player.prepareToPlay()
            player.play()
            
            let key = UUID().uuidString
            players[key] = player
            
            DispatchQueue.main.asyncAfter(deadline: .now() + duration + 0.1) {
                self.players.removeValue(forKey: key)
            }
        } catch {
            print("Failed to initialize AVAudioPlayer: \(error)")
        }
    }
}
