import { GameNum } from '../model/GameNum';
import { GameStatus } from '../model/GameStatus';
import { cryptoFramework } from '@kit.CryptoArchitectureKit';

@Observed
export default class Game {
  board: number[] = this._init();
  status: GameStatus = GameStatus.running

  private _init() {
    const newList = Array<number>(16).fill(0)
    //select two random indexes to put initial2's
    const indexes: Set<number> = new Set<number>()
    while (indexes.size < 2) {
      indexes.add(this._getRandomIndex())
    }
    indexes.forEach((num) => {
      newList[num] = 2
    })

    return newList;
  }

  private _checkGame() {
    // check if win
    if (this.board.some((val) => val === GameNum._2048)) {
      this.status = GameStatus.win;
    }

    // check if the board is full and no move exists
    if (this.board.every((val) => val !== 0) && !this._moveExists()) {
      this.status = GameStatus.lose
    }
    // else game can continue
  }

  private _moveExists() {
    // reshape flat list as board
    const board2D: number[][] = [];
    for (let i = 0; i < this.board.length; i += 4) {
      board2D.push(this.board.slice(i, i + 4));
    }

    // check each row and column
    for (let row = 0; row < board2D.length; row++) {
      for (let col = 0; col < board2D[row].length - 1; col++) {
        if (board2D[row][col] === board2D[row][col + 1]) {
          return true;
        }

        // if not last row, compare with next row
        if (row < board2D.length - 1) {
          if (board2D[row][col] === board2D[row + 1][col]) {
            return true
          }
        }
      }
    }

    // else
    return false
  }

  private getRandomValue(): number {
    try {
      const random = cryptoFramework.createRandom();
      const randomBytes = random.generateRandomSync(4);
      const view = new DataView(randomBytes.data.buffer);
      const randomUint32 = view.getUint32(0, false);
      return randomUint32 / 4294967296;
    } catch (error) {
      console.error('Random generation error:', error);
      return 1
    }
  }

  private _getRandomIndex(max: number = 15) {
    return Math.round(this.getRandomValue() * max);
  }

  private _addItem(arr: number[]) {
    const emptyIndexes = arr.map((value, index) => value === 0 ? index : -1).filter((val) => val >= 0)
    const index = emptyIndexes[this._getRandomIndex(emptyIndexes.length - 1)]

    const arrCopy = Array.from(arr);
    arrCopy[index] = [2, 4][this._getRandomIndex(1)]
    return arrCopy;
  }

  private _isEmpty(line: number[]) {
    return line.every((value) => value === 0)
  }

  private _swipeAndMerge(line: number[]) {
    // return line if empty
    if (this._isEmpty(line)) {
      return line
    }

    // first clear zeros
    const noZeros = line.filter((value) => value !== 0)

    // if two near elements are same, if three are same first two should merge
    // 2,2 -> 4
    // 2,2,2 -> 4,2
    const newLine: number[] = []
    for (let i = 0; i < noZeros.length; i++) {
      // if last element, push to new newLine
      if (i === noZeros.length - 1) {
        newLine.push(noZeros[i])
      } else if (noZeros[i] === noZeros[i + 1]) { // check if two elements should merge
        newLine.push(noZeros[i] * 2)
        i++;
      } else { // no merge, push element
        newLine.push(noZeros[i])
      }
    }

    // fill new line with 0's to make its length 4
    if (newLine.length < 4) {
      newLine.push(...new Array(4 - newLine.length).fill(0))
    }

    return newLine
  }

  private _boardChanged(newBoard: number[]) {
    return !this.board.every((val, index) => val === newBoard[index])
  }

  private _rotateRight90(matrix: number[][]) {
    return matrix[0].map((_, index) => matrix.map(row => row[index]).reverse())
  }

  private _rotateLeft90(matrix: number[][]) {
    return matrix[0].map((_, index) => matrix.map(row => row[row.length - 1 - index]));
  }

  refresh() {
    this.board = this._init();
    this.status = GameStatus.running
  }

  swipeLeft() {
    if (this.status !== GameStatus.running) {
      return
    }

    // reshape flat list as board
    const board2D: number[][] = [];
    for (let i = 0; i < this.board.length; i += 4) {
      board2D.push(this.board.slice(i, i + 4));
    }

    // swipe and merge
    for (let i = 0; i < board2D.length; i++) {
      board2D[i] = this._swipeAndMerge(board2D[i])
    }

    // flatten board as list
    let newBoard = board2D.flat()

    // add new element if the board changed
    if (this._boardChanged(newBoard)) {
      newBoard = this._addItem(newBoard)
      this.board = newBoard;

      this._checkGame();
    }
  }

  swipeRight() {
    if (this.status !== GameStatus.running) {
      return
    }

    // reshape flat list as board
    let board2D: number[][] = [];
    for (let i = 0; i < this.board.length; i += 4) {
      board2D.push(this.board.slice(i, i + 4));
    }

    // rotate 180 to make it compatible with the merge function
    board2D = this._rotateRight90(this._rotateRight90(board2D))

    // swipe and merge
    for (let i = 0; i < board2D.length; i++) {
      board2D[i] = this._swipeAndMerge(board2D[i])
    }

    // rotate 180 back
    board2D = this._rotateLeft90(this._rotateLeft90(board2D))

    // flatten board as list
    let newBoard = board2D.flat()

    // add new element if the board changed
    if (this._boardChanged(newBoard)) {
      newBoard = this._addItem(newBoard)
      this.board = newBoard;

      this._checkGame();
    }
  }

  swipeUp() {
    if (this.status !== GameStatus.running) {
      return
    }

    // reshape flat list as board
    let board2D: number[][] = [];
    for (let i = 0; i < this.board.length; i += 4) {
      board2D.push(this.board.slice(i, i + 4));
    }

    // rotate 90 to make it compatible with the merge function
    board2D = this._rotateLeft90(board2D)

    // swipe and merge
    for (let i = 0; i < board2D.length; i++) {
      board2D[i] = this._swipeAndMerge(board2D[i])
    }

    // rotate 90 back
    board2D = this._rotateRight90(board2D)

    // flatten board as list
    let newBoard = board2D.flat()

    // add new element if the board changed
    if (this._boardChanged(newBoard)) {
      newBoard = this._addItem(newBoard)
      this.board = newBoard;

      this._checkGame();
    }
  }

  swipeDown() {
    if (this.status !== GameStatus.running) {
      return
    }

    // reshape flat list as board
    let board2D: number[][] = [];
    for (let i = 0; i < this.board.length; i += 4) {
      board2D.push(this.board.slice(i, i + 4));
    }

    // rotate 90 to make it compatible with the merge function
    board2D = this._rotateRight90(board2D)

    // swipe and merge
    for (let i = 0; i < board2D.length; i++) {
      board2D[i] = this._swipeAndMerge(board2D[i])
    }

    // rotate 90 back
    board2D = this._rotateLeft90(board2D)

    // flatten board as list
    let newBoard = board2D.flat()

    // add new element if the board changed
    if (this._boardChanged(newBoard)) {
      newBoard = this._addItem(newBoard)
      this.board = newBoard;

      this._checkGame();
    }
  }
}