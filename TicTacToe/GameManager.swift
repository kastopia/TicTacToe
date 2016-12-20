//
//  GameManager.swift
//  TicTacToe
//
//  Created by Kihoon Kwon on 2016-12-19.
//  Copyright © 2016 Terry Kwon. All rights reserved.
//

import Foundation

protocol GameManagerDelegate: class {
    func turnChanged(turn: GameManager.Player)
    func gameFinished(winner: GameManager.Player?)
    func boardCleared()
    func invalidMove()
}

class GameManager {

    static let TileSize = 5	 // [TileSize x TileSize] game board.

    weak var delegate: GameManagerDelegate?

    var turn: Player = .playerO {
        didSet {
            delegate?.turnChanged(turn: turn)
        }
    }

    var session = [Player: Int]()
    var roundCount = 1
    private var currentGame = Matrix(rows: GameManager.TileSize, columns: GameManager.TileSize)
    private var moveCount = 0

    // clears the gameboard.
    // .none represents blank state
    private func clearcurrentGame() {
        for row in 0...GameManager.TileSize-1 {
            for column in 0...GameManager.TileSize-1 {
                currentGame[row, column] = .none
            }
        }

        moveCount = 0

        delegate?.boardCleared()
    }
    
    private func gameFinished(winner: Player?) {
        let key: Player = winner ?? .draw

        if let val = session[key] {
            session[key] = val + 1
        }
        else {
            session[key] = 1
        }

        roundCount += 1

        delegate?.gameFinished(winner: winner)
    }
    
    private func checkCurrentGame(row: Int, column: Int) {
        currentGame[row, column] = turn
	
        let TileSize = GameManager.TileSize
        // check row
        for x in 1...TileSize-1 {
            guard let winnerCandidate = currentGame[0, column], // if first row is not blank
                winnerCandidate == currentGame[x, column] else { break } // check with row x

            if x == TileSize-1 { // last tile matches winner candidate
                gameFinished(winner: winnerCandidate)
                return
            }
        }

        // check column
        for y in 1...TileSize-1 {
            guard let winnerCandidate = currentGame[row, 0], // if first row is not blank
                winnerCandidate == currentGame[row, y] else { break } // check with column y

            if y == TileSize-1 { // last tile matches winner candidate
                gameFinished(winner: winnerCandidate)
                return
            }
        }

        // check top left to bottom right diag
        if row == column {
            for diag in 0...TileSize-1 {
                guard let winnerCandidate = currentGame[row, column], // get selected tile
                    winnerCandidate == currentGame[diag, diag] else { break } // check selected tile with [diag][diag]

                if diag == TileSize-1 { // last tile matches winner candidate
                    gameFinished(winner: winnerCandidate)
                    return
                }
            }
        }

        // check top right to bottom left diag
        if row + column == TileSize - 1 {
            for diag in 0...TileSize-1 {
                guard let winnerCandidate = currentGame[row, column], // get selected tile
                    winnerCandidate == currentGame[diag, TileSize-diag-1] else { break } // check selected tile

                if diag == TileSize-1 { // last tile matches winner candidate
                    gameFinished(winner: winnerCandidate)
                    return
                }
            }
        }

        // check for tie
        if moveCount == TileSize*TileSize { // n^2
            gameFinished(winner: .none)
        }
    }

    func startGame() {
        clearcurrentGame()
    }

    @objc func tilePressed(_ tile: TicTacToeTile) {

        if let _ = currentGame[tile.row, tile.column] { // if the tile is occupied
            delegate?.invalidMove()
            return
        }

        moveCount += 1 // increment move count. used to check for draw

        tile.setTitle(turn.tileString, for: .normal)

        checkCurrentGame(row: tile.row, column: tile.column)

        // switch turn lol
        switch turn {
        case .playerO: turn = .playerX
        case .playerX: turn = .playerO
        case .draw: break // dangling case
        }
    }
}

// MARK:: Player Enum
extension GameManager {
    enum Player: String {
        case playerO = "Player O"
        case playerX = "Player X"
        case draw = "Draw"
        
        var playerString: String {
            return rawValue
        }
        
        var tileString: String {
            switch self {
            case .playerO: return "O"
            case .playerX: return "X"
            default: return ""
            }
        }

        static let allValues: [Player] = [.playerO, .playerX, .draw]
    }
}

// MARK:: Matrix Structure
extension GameManager {

    struct Matrix {
        // reference: https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/Subscripts.html
        let rows: Int, columns: Int
        var grid: [GameManager.Player?]
        
        init(rows: Int, columns: Int) {
            self.rows = rows
            self.columns = columns
            grid = Array(repeating: .none, count: rows * columns)
        }
        
        func indexIsValid(row: Int, column: Int) -> Bool {
            return row >= 0 && row < rows && column >= 0 && column < columns
        }
        
        subscript(row: Int, column: Int) -> GameManager.Player? {
            get {
                assert(indexIsValid(row: row, column: column), "Index out of range")
                return grid[(row * columns) + column]
            }
            set {
                assert(indexIsValid(row: row, column: column), "Index out of range")
                grid[(row * columns) + column] = newValue
            }
        }
    }
}
