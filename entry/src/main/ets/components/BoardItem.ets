import { GameNum } from '../model/GameNum';

@Component
export default struct BoardItem {
  @Require num: GameNum;

  build() {
    RelativeContainer() {
      if (this.num != GameNum._0) {
        Text(this.num.toString())
          .fontColor(this.textColor())
          .fontSize(14)
          .alignRules({
            center: { anchor: '__container__', align: VerticalAlign.Center },
            middle: { anchor: '__container__', align: HorizontalAlign.Center }
          })
      }
    }
    .height('100%')
    .width('100%')
    .borderRadius(4)
    .backgroundColor(this.cellColor())
  }

  textColor() {
    return this.num < 8 ? Color.Black : Color.White
  }

  cellColor() {
    switch (this.num) {
      case GameNum._0:
        return $r('app.color.color_empty')
      case GameNum._2:
        return $r('app.color.color_2')
      case GameNum._4:
        return $r('app.color.color_4')
      case GameNum._8:
        return $r('app.color.color_8')
      case GameNum._16:
        return $r('app.color.color_16')
      case GameNum._32:
        return $r('app.color.color_32')
      case GameNum._64:
        return $r('app.color.color_64')
      case GameNum._128:
        return $r('app.color.color_128')
      case GameNum._256:
        return $r('app.color.color_256')
      case GameNum._512:
        return $r('app.color.color_512')
      case GameNum._1024:
        return $r('app.color.color_1024')
      case GameNum._2048:
        return $r('app.color.color_2048')
    }
  }
}