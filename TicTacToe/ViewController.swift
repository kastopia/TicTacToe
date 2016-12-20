//
//  ViewController.swift
//  TicTacToe
//
//  Created by Kihoon Kwon on 2016-12-19.
//  Copyright © 2016 Terry Kwon. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let gameManager = GameManager()

    @IBOutlet weak var roundLabel: UILabel!
    @IBOutlet weak var playerTurnLabel: UILabel!
    @IBOutlet weak var gameBoard: UIView!
    @IBOutlet weak var gameSessionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        gameManager.delegate = self
        turnChanged(turn: gameManager.turn) // set default value
        updateGameSessionUI()
        gameManager.startGame()

        // create game tiles
        let gameBoardSize = gameBoard.frame.size
        for row in 0...GameManager.TileSize-1 {
            for column in 0...GameManager.TileSize-1 {
                let tileSizeMultiplier = CGFloat(GameManager.TileSize)
                let tile = TicTacToeTile(row: row, column: column)
                tile.addTarget(gameManager, action: #selector(GameManager.tilePressed(_:)), for: .touchUpInside)
                tile.translatesAutoresizingMaskIntoConstraints = false
                gameBoard.addSubview(tile)
                gameBoard.addConstraints([
                        tile.topAnchor.constraint(equalTo: gameBoard.topAnchor, constant: CGFloat(row)/tileSizeMultiplier*gameBoardSize.height),
                        tile.leadingAnchor.constraint(equalTo: gameBoard.leadingAnchor, constant: CGFloat(column)/tileSizeMultiplier*gameBoardSize.width),
                        tile.widthAnchor.constraint(equalTo: gameBoard.widthAnchor, multiplier: 1.0/tileSizeMultiplier, constant: 0), // 1/n width
                        tile.heightAnchor.constraint(equalTo: gameBoard.heightAnchor, multiplier: 1.0/tileSizeMultiplier, constant: 0) // 1/n height
                    ])
            }
        }
    }
    
    func updateGameSessionUI() {
        var gameSessionText = ""
        for key in GameManager.Player.allValues {
            var winCount = 0
            if let value = gameManager.session[key] {
                winCount = value
            }
            gameSessionText += "\(key.rawValue): \(winCount)\n"
        }

        gameSessionLabel.text = gameSessionText.trimmingCharacters(in: .whitespacesAndNewlines)
        roundLabel.text = "Round \(gameManager.roundCount)"
    }
}

// MARK: GameManagerDelegate Implmenetation

extension ViewController: GameManagerDelegate {

    func turnChanged(turn: GameManager.Player) {
        playerTurnLabel.text = "\(turn.playerString)'s turn"
    }

    func gameFinished(winner: GameManager.Player?) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        switch winner {
        case .none:
            alertController.title = "Draw"
            break
        default:
            alertController.title = "\(winner!.playerString) wins!"
            break
        }
        
        let startNewGame = UIAlertAction(title: "Start new game", style: .default) { [weak self] _ in
            self?.updateGameSessionUI()
            self?.gameManager.startGame()
        }
        alertController.addAction(startNewGame)
        present(alertController, animated: true, completion: nil)
    }

    func boardCleared() {
        for subview in gameBoard.subviews {
            if subview is TicTacToeTile {
                (subview as! TicTacToeTile).setTitle("", for: .normal)
            }
        }
    }

    func invalidMove() {
        let alertController = UIAlertController(title: "Invalid move", message: "Please select another tile.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}
