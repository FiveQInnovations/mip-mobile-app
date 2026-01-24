//
//  AudioPlayerView.swift
//  FFCI
//
//  Audio player component using AVPlayer for native iOS playback
//

import SwiftUI
import AVFoundation
import Combine
import os.log

private let logger = Logger(subsystem: "com.fiveq.ffci", category: "AudioPlayerView")

// MARK: - Audio Player State Manager

class AudioPlayerState: ObservableObject {
    @Published var isPlaying = false
    @Published var duration: TimeInterval = 0
    @Published var currentTime: TimeInterval = 0
    @Published var isLoading = true
    @Published var error: String?
    
    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var timeObserver: Any?
    private var statusObserver: NSKeyValueObservation?
    private var timeControlStatusObserver: NSKeyValueObservation?
    private var durationObserver: NSKeyValueObservation?
    private var cancellables = Set<AnyCancellable>()
    
    func setupPlayer(url: URL) {
        // Configure audio session for background playback
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default)
            try audioSession.setActive(true)
            logger.notice("Audio session configured for background playback")
        } catch {
            logger.error("Failed to configure audio session: \(error.localizedDescription)")
        }
        
        // Create player item
        playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        
        // Observe player item status using KVO
        statusObserver = playerItem?.observe(\.status, options: [.new]) { [weak self] item, _ in
            DispatchQueue.main.async {
                self?.handlePlayerItemStatus(item.status)
            }
        }
        
        // Observe playback state using KVO
        timeControlStatusObserver = player?.observe(\.timeControlStatus, options: [.new]) { [weak self] player, _ in
            DispatchQueue.main.async {
                self?.handleTimeControlStatus(player.timeControlStatus)
            }
        }
        
        // Observe duration using KVO
        durationObserver = playerItem?.observe(\.duration, options: [.new]) { [weak self] item, _ in
            DispatchQueue.main.async {
                let duration = item.duration
                if duration.isValid && !duration.isIndefinite {
                    self?.duration = duration.seconds
                }
            }
        }
        
        // Set up periodic time observer
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            self?.currentTime = time.seconds
        }
        
        // Observe playback end
        NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime, object: playerItem)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.handlePlaybackEnded()
            }
            .store(in: &cancellables)
        
        logger.notice("Audio player setup complete for URL: \(url.absoluteString)")
    }
    
    private func handlePlayerItemStatus(_ status: AVPlayerItem.Status) {
        switch status {
        case .readyToPlay:
            isLoading = false
            error = nil
            if let duration = playerItem?.duration, duration.isValid && !duration.isIndefinite {
                self.duration = duration.seconds
            }
            logger.notice("Player item ready to play")
        case .failed:
            isLoading = false
            let errorMessage = playerItem?.error?.localizedDescription ?? "Failed to load audio"
            self.error = errorMessage
            logger.error("Player item failed: \(errorMessage)")
        case .unknown:
            isLoading = true
        @unknown default:
            isLoading = true
        }
    }
    
    private func handleTimeControlStatus(_ status: AVPlayer.TimeControlStatus) {
        switch status {
        case .playing:
            isPlaying = true
            isLoading = false
        case .paused:
            isPlaying = false
            isLoading = false
        case .waitingToPlayAtSpecifiedRate:
            isLoading = true
        @unknown default:
            break
        }
    }
    
    private func handlePlaybackEnded() {
        isPlaying = false
        currentTime = 0
        player?.seek(to: .zero)
        logger.notice("Playback ended, reset to start")
    }
    
    func play() {
        player?.play()
        logger.notice("Play requested")
    }
    
    func pause() {
        player?.pause()
        logger.notice("Pause requested")
    }
    
    func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }
    
    func seek(to time: TimeInterval) {
        let cmTime = CMTime(seconds: time, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player?.seek(to: cmTime)
        currentTime = time
        logger.notice("Seek to \(time) seconds")
    }
    
    func cleanup() {
        if let timeObserver = timeObserver {
            player?.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
        
        statusObserver?.invalidate()
        statusObserver = nil
        timeControlStatusObserver?.invalidate()
        timeControlStatusObserver = nil
        durationObserver?.invalidate()
        durationObserver = nil
        
        cancellables.removeAll()
        player?.pause()
        player = nil
        playerItem = nil
        
        // Deactivate audio session
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            logger.error("Failed to deactivate audio session: \(error.localizedDescription)")
        }
        
        logger.notice("Audio player cleaned up")
    }
}

// MARK: - Audio Player View

struct AudioPlayerView: View {
    let url: String
    let title: String?
    let artist: String?
    
    @StateObject private var playerState = AudioPlayerState()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Title and Artist
            if let title = title {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            if let artist = artist {
                Text(artist)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Error State
            if let error = playerState.error {
                VStack(spacing: 8) {
                    Text("Error loading audio")
                        .font(.caption)
                        .foregroundColor(.red)
                    Text(error)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            } else {
                // Progress Slider
                VStack(spacing: 8) {
                    Slider(
                        value: Binding(
                            get: { playerState.duration > 0 ? playerState.currentTime / playerState.duration : 0 },
                            set: { fraction in
                                let newTime = fraction * playerState.duration
                                playerState.seek(to: newTime)
                            }
                        ),
                        in: 0...1
                    )
                    .disabled(playerState.isLoading || playerState.duration == 0)
                    
                    // Time Display
                    HStack {
                        Text(formatTime(playerState.currentTime))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(formatTime(playerState.duration))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Play/Pause Button
                HStack {
                    Spacer()
                    Button(action: {
                        playerState.togglePlayPause()
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color("PrimaryColor"))
                                .frame(width: 64, height: 64)
                            
                            if playerState.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Image(systemName: playerState.isPlaying ? "pause.fill" : "play.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .disabled(playerState.error != nil || (playerState.duration == 0 && !playerState.isLoading))
                    Spacer()
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
        .onAppear {
            if let audioURL = URL(string: url) {
                playerState.setupPlayer(url: audioURL)
            } else {
                playerState.error = "Invalid audio URL"
                logger.error("Invalid audio URL: \(url)")
            }
        }
        .onDisappear {
            playerState.cleanup()
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        guard time.isFinite && !time.isNaN else {
            return "0:00"
        }
        let totalSeconds = Int(time)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview {
    AudioPlayerView(
        url: "https://example.com/audio.mp3",
        title: "Sample Audio",
        artist: "Sample Artist"
    )
    .padding()
}
