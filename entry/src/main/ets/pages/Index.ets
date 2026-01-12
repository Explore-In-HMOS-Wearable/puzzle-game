import BoardItem from '../components/BoardItem';
import WinLosePopup from '../components/WinLosePopup';
import { GameStatus } from '../model/GameStatus';
import Game from '../viewmodel/Game';

@Entry
@Component
struct Index {
  @State @Watch('winLose') game: Game = new Game()
  @State pop: boolean = false;

  winLose() {
    this.pop = this.game.status !== GameStatus.running
  }

  build() {
    RelativeContainer() {
      Grid() {
        ForEach(this.game.board, (num: number) => {
          GridItem() {
            BoardItem({ num: num })
          }
        }, (item: number, index: number) => `${item}`)
      }
      .size({ width: '70%', height: '70%' })
      .alignRules({
        center: { anchor: '__container__', align: VerticalAlign.Center },
        middle: { anchor: '__container__', align: HorizontalAlign.Center }
      })
      .columnsTemplate('1fr 1fr 1fr 1fr')
      .rowsTemplate('1fr 1fr 1fr 1fr')
      .columnsGap(4)
      .rowsGap(4)
      .padding(4)
      .backgroundColor($r('app.color.color_board'))
      .borderRadius(4)
    }
    .height('100%')
    .width('100%')
    .backgroundColor(this.bgColor())
    .gesture(PanGesture({ distance: 50 }).onActionEnd((event) => {
      const verticalDistance = event.offsetY;
      const horizontalDistance = event.offsetX;

      if (Math.abs(verticalDistance) > Math.abs(horizontalDistance)) {
        // vertical movement
        if (verticalDistance < 0) {
          // swipe up
          this.game.swipeUp()
        } else {
          // swipe down
          this.game.swipeDown()
        }
      } else {
        // horizontal movement
        if (horizontalDistance < 0) {
          // swipe left
          this.game.swipeLeft()
        } else {
          // swipe right
          this.game.swipeRight()
        }
      }
    }))
    .bindPopup(this.pop, {
      builder: this.winLosePopupBuilder(),
      autoCancel: false,
      onStateChange: (e) => {
        console.info(JSON.stringify(e.isVisible))
        if (!e.isVisible) {
          this.game.refresh()
        }
      }
    })
  }

  bgColor() {
    switch (this.game.status) {
      case GameStatus.running:
        return $r('app.color.color_background')
      case GameStatus.lose:
        return Color.Red
      case GameStatus.win:
        return Color.Green
      default:
        return $r('app.color.color_background')
    }
  }

  @Builder
  winLosePopupBuilder() {
    WinLosePopup({
      showPopup: this.pop,
      win: this.game.status === GameStatus.win
    })
  }
}