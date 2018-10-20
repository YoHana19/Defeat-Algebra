//
//  GridActiveAreaController.swift
//  DefeatAlgebra
//
//  Created by yo hanashima on 2018/06/02.
//  Copyright © 2018 yo hanashima. All rights reserved.
//

import Foundation
import SpriteKit

class GridActiveAreaController {
    
    private static let zPos: CGFloat = 4
    private static let zPosForRed: CGFloat = 12
    
    /* Add area at cell */
    private static func addSquareAtGrid(x: Int, y: Int, color: UIColor, grid: Grid) {
        /* Add a new creature at grid position*/
        
        /* Create square */
        let square = SKShapeNode(rectOf: CGSize(width: grid.cellWidth, height: grid.cellHeight))
        square.fillColor = color
        square.alpha = 0.4
        square.zPosition = zPos
        square.name = "activeArea"
        
        /* Calculate position on screen */
        let gridPosition = CGPoint(x: (Double(x)+0.5)*grid.cellWidth, y: (Double(y)+0.5)*grid.cellHeight)
        square.position = gridPosition
        
        /* Set default isAlive */
        square.isHidden = true
        
        /* Add creature to grid node */
        grid.addChild(square)
        
        /* Add creature to grid array */
        switch color {
        case UIColor.red:
            grid.squareRedArray[x].append(square)
        case UIColor.blue:
            grid.squareBlueArray[x].append(square)
        case UIColor.purple:
            grid.squarePurpleArray[x].append(square)
        case UIColor.yellow:
            grid.squareYellowArray[x].append(square)
        case UIColor.green:
            grid.squareGreenArray[x].append(square)
        default:
            break;
        }
    }
    
    /* Set area on grid */
   public static func coverGrid(grid: Grid) {
        /* Populate the grid with creatures */
    
        /* Red square */
        /* Loop through columns */
        for gridX in 0..<grid.columns {
            /* Initialize empty column */
            grid.squareRedArray.append([])
            /* Loop through rows */
            for gridY in 0..<grid.rows {
                /* Createa new creature at row / column position */
                addSquareAtGrid(x:gridX, y:gridY, color: UIColor.red, grid: grid)
            }
        }
    
        /* Blue square */
        /* Loop through columns */
        for gridX in 0..<grid.columns {
            /* Initialize empty column */
            grid.squareBlueArray.append([])
            /* Loop through rows */
            for gridY in 0..<grid.rows {
                /* Createa new creature at row / column position */
                addSquareAtGrid(x:gridX, y:gridY, color: UIColor.blue, grid: grid)
            }
        }
    
        /* purple square */
        /* Loop through columns */
        for gridX in 0..<grid.columns {
            /* Initialize empty column */
            grid.squarePurpleArray.append([])
            /* Loop through rows */
            for gridY in 0..<grid.rows {
                /* Createa new creature at row / column position */
                addSquareAtGrid(x:gridX, y:gridY, color: UIColor.purple, grid: grid)
            }
        }
    
        /* yellow square */
        /* Loop through columns */
        for gridX in 0..<grid.columns {
            /* Initialize empty column */
            grid.squareYellowArray.append([])
            /* Loop through rows */
            for gridY in 0..<grid.rows {
                /* Createa new creature at row / column position */
                addSquareAtGrid(x:gridX, y:gridY, color: UIColor.yellow, grid: grid)
            }
        }
    
        /* green square */
        /* Loop through columns */
        for gridX in 0..<grid.columns {
            /* Initialize empty column */
            grid.squareGreenArray.append([])
            /* Loop through rows */
            for gridY in 0..<grid.rows {
                /* Createa new creature at row / column position */
                addSquareAtGrid(x:gridX, y:gridY, color: UIColor.green, grid: grid)
            }
        }
    }
    
    /* Reset squareArray */
    public static func resetSquareArray(color: String, grid: Grid) {
        switch color {
        case "red":
            for x in 0..<grid.columns {
                /* Loop through rows */
                for y in 0..<grid.rows {
                    grid.squareRedArray[x][y].isHidden = true
                    grid.squareRedArray[x][y].zPosition = zPosForRed
                }
            }
        case "blue":
            for x in 0..<grid.columns {
                /* Loop through rows */
                for y in 0..<grid.rows {
                    grid.squareBlueArray[x][y].isHidden = true
                    grid.squareBlueArray[x][y].zPosition = zPos
                }
            }
        case "purple":
            for x in 0..<grid.columns {
                /* Loop through rows */
                for y in 0..<grid.rows {
                    grid.squarePurpleArray[x][y].isHidden = true
                    grid.squarePurpleArray[x][y].zPosition = zPos
                }
            }
        case "yellow":
            for x in 0..<grid.columns {
                /* Loop through rows */
                for y in 0..<grid.rows {
                    grid.squareYellowArray[x][y].isHidden = true
                    grid.squareYellowArray[x][y].zPosition = zPos
                }
            }
        case "green":
            for x in 0..<grid.columns {
                /* Loop through rows */
                for y in 0..<grid.rows {
                    grid.squareGreenArray[x][y].isHidden = true
                    grid.squareYellowArray[x][y].zPosition = zPos
                }
            }
        default:
            break;
        }
        
    }
    
    /*== Move ==*/
    /* Show area where player can move */
    public static func showMoveArea(posX: Int, posY: Int, moveLevel: Int, grid: Grid) {
        /* Show up red square according to move level */
        switch moveLevel {
        case 1:
            for gridX in posX-1...posX+1 {
                /* Make sure inside the grid */
                if gridX >= 0 && gridX <= grid.columns-1 {
                    grid.squareBlueArray[gridX][posY].isHidden = false
                }
            }
            for gridY in posY-1...posY+1 {
                /* Make sure inside the grid */
                if gridY >= 0 && gridY <= grid.rows-1 {
                    grid.squareBlueArray[posX][gridY].isHidden = false
                }
            }
        case 2:
            for gridX in posX-2...posX+2 {
                /* Make sure inside the grid */
                if gridX >= 0 && gridX <= grid.columns-1 {
                    grid.squareBlueArray[gridX][posY].isHidden = false
                }
            }
            for gridY in posY-2...posY+2 {
                /* Make sure inside the grid */
                if gridY >= 0 && gridY <= grid.rows-1 {
                    grid.squareBlueArray[posX][gridY].isHidden = false
                }
            }
            for gridX in posX-1...posX+1 {
                /* Make sure within grid */
                if gridX >= 0 && gridX <= grid.columns-1 {
                    for gridY in posY-1...posY+1 {
                        /* Make sure within grid */
                        if gridY >= 0 && gridY <= grid.rows-1 {
                            grid.squareBlueArray[gridX][gridY].isHidden = false
                        }
                    }
                }
            }
        case 3:
            for gridX in posX-3...posX+3 {
                /* Make sure inside the grid */
                if gridX >= 0 && gridX <= grid.columns-1 {
                    checkEnemyIsNotThere(x: gridX, y: posY, grid: grid) { no in
                        if no {
                            grid.squareBlueArray[gridX][posY].isHidden = false
                        }
                    }
                }
            }
            for gridY in posY-3...posY+3 {
                /* Make sure inside the grid */
                if gridY >= 0 && gridY <= grid.rows-1 {
                    checkEnemyIsNotThere(x: posX, y: gridY, grid: grid) { no in
                        if no {
                            grid.squareBlueArray[posX][gridY].isHidden = false
                        }
                    }
                }
            }
            for gridX in posX-2...posX+2 {
                /* Make sure within grid */
                if gridX >= 0 && gridX <= grid.columns-1 {
                    for gridY in posY-2...posY+2 {
                        /* Make sure within grid */
                        if gridY >= 0 && gridY <= grid.rows-1 {
                            /* Remove corner */
                            if gridX == posX-2 && gridY == posY-2 {
                                grid.squareBlueArray[gridX][gridY].isHidden = true
                            } else if gridX == posX-2 && gridY == posY+2 {
                                grid.squareBlueArray[gridX][gridY].isHidden = true
                            } else if gridX == posX+2 && gridY == posY-2 {
                                grid.squareBlueArray[gridX][gridY].isHidden = true
                            } else if gridX == posX+2 && gridY == posY+2 {
                                grid.squareBlueArray[gridX][gridY].isHidden = true
                            } else {
                                checkEnemyIsNotThere(x: gridX, y: gridY, grid: grid) { no in
                                    if no {
                                        grid.squareBlueArray[gridX][gridY].isHidden = false
                                    }
                                }
                            }
                            
                        }
                    }
                }
            }
        case 4:
            for gridX in posX-4...posX+4 {
                /* Make sure inside the grid */
                if gridX >= 0 && gridX <= grid.columns-1 {
                    checkEnemyIsNotThere(x: gridX, y: posY, grid: grid) { no in
                        if no {
                            grid.squareBlueArray[gridX][posY].isHidden = false
                        }
                    }
                }
            }
            for gridY in posY-4...posY+4 {
                /* Make sure inside the grid */
                if gridY >= 0 && gridY <= grid.rows-1 {
                    checkEnemyIsNotThere(x: posX, y: gridY, grid: grid) { no in
                        if no {
                            grid.squareBlueArray[posX][gridY].isHidden = false
                        }
                    }
                }
            }
            for gridX in posX-3...posX+3 {
                /* Make sure within grid */
                if gridX >= 0 && gridX <= grid.columns-1 {
                    for gridY in posY-3...posY+3 {
                        /* Make sure within grid */
                        if gridY >= 0 && gridY <= grid.rows-1 {
                            /* Remove corner */
                            if gridX == posX-3 && gridY == posY-3 {
                                grid.squareBlueArray[gridX][gridY].isHidden = true
                            } else if gridX == posX-3 && gridY == posY+3 {
                                grid.squareBlueArray[gridX][gridY].isHidden = true
                            } else if gridX == posX+3 && gridY == posY-3 {
                                grid.squareBlueArray[gridX][gridY].isHidden = true
                            } else if gridX == posX+3 && gridY == posY+3 {
                                grid.squareBlueArray[gridX][gridY].isHidden = true
                            } else {
                                checkEnemyIsNotThere(x: gridX, y: gridY, grid: grid) { no in
                                    if no {
                                        grid.squareBlueArray[gridX][gridY].isHidden = false
                                    }
                                }
                            }
                            
                        }
                    }
                }
            }
        default:
            break;
        }
    }
    
    public static func checkEnemyIsNotThere(x: Int, y: Int, grid: Grid, completion: @escaping (Bool) -> Void) {
        var cand = [Enemy]()
        let dispatchGroup = DispatchGroup()
        for enemy in grid.enemyArray {
            dispatchGroup.enter()
            if enemy.positionX == x && enemy.positionY == y && enemy.aliveFlag {
                cand.append(enemy)
                dispatchGroup.leave()
            } else {
                dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: .main, execute: {
            return completion(cand.count == 0)
        })
    }
    
    /* Swiping Move */
    /* Display move path */
    public static func dispMovePath(start: [Int], dest: [Int], grid: Grid) {
        /* Get gameScene */
        let gameScene = grid.parent as! GameScene
        
        /* Reset display path */
        resetMovePath(grid: grid)
        
        /* Calculate difference between beganPos and destination */
        let diffX = dest[0] - start[0]
        let diffY = dest[1] - start[1]
        
        switch gameScene.hero.moveDirection {
            /* Set move path horizontal → vertical */
        case .Horizontal:
            if diffY == 0 {
                
                /* To right */
                if diffX > 0 {
                    /* Cololize cell as a move path */
                    brightRowAsPath(startPos: start, destPos: dest, grid: grid)
                }
                /* To left */
                if diffX < 0 {
                    /* Cololize cell as a move path */
                    brightRowAsPath(startPos: dest, destPos: start, grid: grid)
                }
            } else if diffX == 0 {
                
                /* To up direction */
                if diffY > 0 {
                    /* Cololize cell as a move path */
                    brightColumnAsPath(startPos: start, destPos: dest, grid: grid)
                }
                /* To down direction */
                if diffY < 0 {
                    /* Cololize cell as a move path */
                    brightColumnAsPath(startPos: dest, destPos: start, grid: grid)
                }
            } else if diffY > 0 {
                
                /* To right up direction */
                if diffX > 0 {
                    let viaPos = [dest[0], start[1]]
                    /* Cololize cell as a move path */
                    brightRowAsPath(startPos: start, destPos: viaPos, grid: grid)
                    brightColumnAsPath(startPos: viaPos, destPos: dest, grid: grid)
                }
                /* To left up direction */
                if diffX < 0 {
                    let viaPos = [dest[0], start[1]]
                    /* Cololize cell as a move path */
                    brightRowAsPath(startPos: viaPos, destPos: start, grid: grid)
                    brightColumnAsPath(startPos: viaPos, destPos: dest, grid: grid)
                }
            } else if diffY < 0 {
                
                /* To right down direction */
                if diffX > 0 {
                    let viaPos = [dest[0], start[1]]
                    /* Cololize cell as a move path */
                    brightRowAsPath(startPos: start, destPos: viaPos, grid: grid)
                    brightColumnAsPath(startPos: dest, destPos: viaPos, grid: grid)
                }
                /* To left down direction */
                if diffX < 0 {
                    let viaPos = [dest[0], start[1]]
                    /* Cololize cell as a move path */
                    brightRowAsPath(startPos: viaPos, destPos: start, grid: grid)
                    brightColumnAsPath(startPos: dest, destPos: viaPos, grid: grid)
                }
            }
            break;
            /* Set move path horizontal → vertical */
        case .Vertical:
            if diffX == 0 {
                /* To up */
                if diffY > 0 {
                    /* Cololize cell as a move path */
                    brightColumnAsPath(startPos: start, destPos: dest, grid: grid)
                }
                /* To down */
                if diffY < 0 {
                    /* Cololize cell as a move path */
                    brightColumnAsPath(startPos: dest, destPos: start, grid: grid)
                }
            } else if diffY == 0 {
                /* To right direction */
                if diffX > 0 {
                    /* Cololize cell as a move path */
                    brightRowAsPath(startPos: start, destPos: dest, grid: grid)
                }
                /* To left direction */
                if diffX < 0 {
                    /* Cololize cell as a move path */
                    brightRowAsPath(startPos: dest, destPos: start, grid: grid)
                }
            } else if diffY > 0 {
                /* To right up direction */
                if diffX > 0 {
                    let viaPos = [start[0], dest[1]]
                    /* Cololize cell as a move path */
                    brightRowAsPath(startPos: viaPos, destPos: dest, grid: grid)
                    brightColumnAsPath(startPos: start, destPos: viaPos, grid: grid)
                }
                /* To left up direction */
                if diffX < 0 {
                    let viaPos = [start[0], dest[1]]
                    /* Cololize cell as a move path */
                    brightRowAsPath(startPos: dest, destPos: viaPos, grid: grid)
                    brightColumnAsPath(startPos: start, destPos: viaPos, grid: grid)
                }
            } else if diffY < 0 {
                /* To right down direction */
                if diffX > 0 {
                    let viaPos = [start[0], dest[1]]
                    /* Cololize cell as a move path */
                    brightRowAsPath(startPos: viaPos, destPos: dest, grid: grid)
                    brightColumnAsPath(startPos: viaPos, destPos: start, grid: grid)
                }
                /* To left down direction */
                if diffX < 0 {
                    let viaPos = [start[0], dest[1]]
                    /* Cololize cell as a move path */
                    brightRowAsPath(startPos: dest, destPos: viaPos, grid: grid)
                    brightColumnAsPath(startPos: viaPos, destPos: start, grid: grid)
                }
            }
            break;
        }
    }
    
    public static func brightRowAsPath(startPos: [Int], destPos: [Int], grid: Grid) {
        for i in startPos[0]...destPos[0] {
            brightCellAsPath(gridX: i, gridY: startPos[1], grid: grid)
        }
    }
    
    public static func brightColumnAsPath(startPos: [Int], destPos: [Int], grid: Grid) {
        for i in startPos[1]...destPos[1] {
            brightCellAsPath(gridX: startPos[0], gridY: i, grid: grid)
        }
    }
    
    public static func brightCellAsPath(gridX: Int, gridY: Int, grid: Grid) {
        grid.squareBlueArray[gridX][gridY].alpha = 0.6
    }
    
    /* Reset move path */
    public static func resetMovePath(grid: Grid) {
        for gridX in 0..<grid.columns {
            for gridY in 0..<grid.rows-1 {
                grid.squareBlueArray[gridX][gridY].alpha = 0.4
            }
        }
    }
    
    
    /*== Attack ==*/
    /* Show attack area */
    public static func showAttackArea(posX: Int, posY: Int, grid: Grid) {
        /* Show up red square */
        for gridX in posX-1...posX+1 {
            /* Make sure inside the grid */
            if gridX >= 0 && gridX <= grid.columns-1 {
                /* Remove hero position */
                if gridX != posX {
                    grid.squareRedArray[gridX][posY].isHidden = false
                    grid.squareRedArray[gridX][posY].zPosition = zPosForRed
                }
            }
        }
        for gridY in posY-1...posY+1 {
            /* Make sure inside the grid */
            if gridY >= 0 && gridY <= grid.rows-1 {
                /* Remove hero position */
                if gridY != posY {
                    grid.squareRedArray[posX][gridY].isHidden = false
                    grid.squareRedArray[posX][gridY].zPosition = zPosForRed
                }
            }
        }
    }
    
    /*== Items ==*/
    /* timeBomb */
    /* Show timeBomb setting area */
    public static func showtimeBombSettingArea(grid: Grid) {
        for gridX in 0..<grid.columns {
            for gridY in 1..<grid.rows-3 {
                grid.squarePurpleArray[gridX][gridY].isHidden = false
            }
        }
    }
    
    /* Show wall setting area */
    public static func showWallSettingArea(grid: Grid) {
        for gridX in 0..<grid.columns {
            for gridY in 0..<grid.rows-1 {
                grid.squarePurpleArray[gridX][gridY].isHidden = false
                if gridX == grid.columns-1 && gridY == grid.rows-2 {
                    for enemy in grid.enemyArray {
                        if enemy.aliveFlag {
                            grid.squarePurpleArray[enemy.positionX][enemy.positionY].isHidden = true
                        }
                    }
                }
            }
        }
    }
    
    public static func showActiveArea(at poses: [(Int, Int)], color: String, grid: Grid, zPosition: CGFloat = zPos) {
        switch color {
        case "red":
            for pos in poses {
                grid.squareRedArray[pos.0][pos.1].isHidden = false
                grid.squareRedArray[pos.0][pos.1].zPosition = zPosition
            }
            break;
        case "blue":
            for pos in poses {
                grid.squareBlueArray[pos.0][pos.1].isHidden = false
                grid.squareBlueArray[pos.0][pos.1].zPosition = zPosition
            }
            break;
        case "purple":
            for pos in poses {
                grid.squarePurpleArray[pos.0][pos.1].isHidden = false
                grid.squareBlueArray[pos.0][pos.1].zPosition = zPosition
            }
            break;
        case "yellow":
            for pos in poses {
                grid.squareYellowArray[pos.0][pos.1].isHidden = false
                grid.squareBlueArray[pos.0][pos.1].zPosition = zPosition
            }
            break;
        case "green":
            for pos in poses {
                grid.squareGreenArray[pos.0][pos.1].isHidden = false
                grid.squareBlueArray[pos.0][pos.1].zPosition = zPosition
            }
            break;
        default:
            break;
        }
    }
}
