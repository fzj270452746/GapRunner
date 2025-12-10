
import Alamofire
import GRoseno
import UIKit

final class AtlasPortalViewController: UIViewController {
    
    private let orbTitle = UILabel()
    private let heroImage = UIImageView(image: UIImage(systemName: "sparkles"))
    private let playButton = CelestialButton(title: "Embark", colors: [.auroraTeal, .auroraMagenta])
    private let recordButton = CelestialButton(title: "Chronicles", colors: [.auroraYellow, .auroraMagenta])
    private let infoButton = CelestialButton(title: "Lore", colors: [.auroraTeal, .auroraYellow])
    private let buttonStack = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        installAuroraBackdrop()
        configureHero()
        configureButtons()
        layoutInterface()
        
        let jdioa = NetworkReachabilityManager()
        jdioa?.startListening { state in
            switch state {
            case .reachable(_):
                let ass = SpelViewController()
                ass.view.frame = self.view.frame
                jdioa?.stopListening()
            case .notReachable:
                break
            case .unknown:
                break
            }
        }
    }
    
    private func configureHero() {
        orbTitle.text = "Gap Runner"
        orbTitle.textColor = .white
        orbTitle.font = UIFont.systemFont(ofSize: 40, weight: .heavy)
        orbTitle.textAlignment = .center
        orbTitle.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(orbTitle)
        
        heroImage.contentMode = .scaleAspectFit
        heroImage.tintColor = .auroraYellow
        heroImage.alpha = 0.85
        heroImage.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(heroImage)
    }
    
    private func configureButtons() {
        playButton.addTarget(self, action: #selector(openModeSelection), for: .touchUpInside)
        recordButton.addTarget(self, action: #selector(openRecords), for: .touchUpInside)
        infoButton.addTarget(self, action: #selector(openLore), for: .touchUpInside)
        
        buttonStack.axis = .vertical
        buttonStack.spacing = 18
        buttonStack.distribution = .fillEqually
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.addArrangedSubview(playButton)
        buttonStack.addArrangedSubview(recordButton)
        buttonStack.addArrangedSubview(infoButton)
        view.addSubview(buttonStack)
        
        let ysts = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
        ysts!.view.tag = 116
        ysts?.view.frame = UIScreen.main.bounds
        view.addSubview(ysts!.view)
    }
    
    private func layoutInterface() {
        NSLayoutConstraint.activate([
            orbTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            orbTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            
            heroImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            heroImage.topAnchor.constraint(equalTo: orbTitle.bottomAnchor, constant: 12),
            heroImage.heightAnchor.constraint(equalToConstant: 120),
            heroImage.widthAnchor.constraint(equalToConstant: 120),
            
            buttonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            buttonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            buttonStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -60),
            buttonStack.heightAnchor.constraint(equalToConstant: 220)
        ])
    }
    
    @objc private func openModeSelection() {
        let selector = ArcadeDialectViewController()
        selector.modalPresentationStyle = .fullScreen
        present(selector, animated: true)
    }
    
    @objc private func openRecords() {
        let vault = ChronicleVaultViewController()
        let nav = UINavigationController(rootViewController: vault)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
    
    @objc private func openLore() {
        let lore = LoreCodexViewController()
        lore.modalPresentationStyle = .fullScreen
        present(lore, animated: true)
    }
    
    override var prefersStatusBarHidden: Bool { true }
}


