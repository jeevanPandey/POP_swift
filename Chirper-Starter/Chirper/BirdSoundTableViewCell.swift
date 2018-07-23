
import UIKit
import AVKit

class BirdSoundTableViewCell: UITableViewCell {
  
  static let ReuseIdentifier = String(describing: BirdSoundTableViewCell.self)
  static let NibName = String(describing: BirdSoundTableViewCell.self)
  
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var playbackButton: UIButton!
  @IBOutlet weak var scientificNameLabel: UILabel!
  @IBOutlet weak var countryLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var audioPlayerContainer: UIView!
  
  var playbackURL: URL?
  var player = AVPlayer()
  
  var isPlaying = false {
    didSet {
      let newImage = isPlaying ? #imageLiteral(resourceName: "pause") : #imageLiteral(resourceName: "play")
      playbackButton.setImage(newImage, for: .normal)
      if isPlaying, let url = playbackURL {
        player.replaceCurrentItem(with: AVPlayerItem(url: url))
        player.play()
      } else {
        player.pause()
      }
    }
  }
  
  override func prepareForReuse() {
    NotificationCenter.default.removeObserver(self)
    isPlaying = false
    super.prepareForReuse()
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    selectionStyle = .none
  }
  
  @IBAction func togglePlayback(_ sender: Any) {
    isPlaying = !isPlaying
  }
  
  func load(recording: Recording) {
    nameLabel.text = recording.friendlyName
    scientificNameLabel.text = "\(recording.genus) \(recording.species)"
    countryLabel.text = recording.country
    dateLabel.text = recording.date
    
    let playableRecordingURLString = "https:\(recording.fileURL.absoluteString)"
    playbackURL = URL(string: playableRecordingURLString)
    
    NotificationCenter.default.addObserver(
      self, selector: #selector(playerDidFinishPlaying(_:)),
      name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
      object: player.currentItem)
    
    NotificationCenter.default.addObserver(
      self, selector: #selector(itemDidReachEnd(_:)),
      name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
      object: player.currentItem)
  }
  
  @objc func playerDidFinishPlaying(_: NSNotification) {
    isPlaying = false
  }
  
  @objc func itemDidReachEnd(_: NSNotification) {
    player.seek(to: kCMTimeZero)
  }
  
  func ensurePlaybackWorksForDeviceOnSilent() {
    let audioSession = AVAudioSession.sharedInstance()
    try? audioSession.setCategory(AVAudioSessionCategoryPlayback, with: [])
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
}

