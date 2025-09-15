@Component
export default struct WinLosePopup {
  @Link showPopup: boolean;
  @Require win: boolean;

  build() {
    Column() {
      Text(`YOU ${this.win ? 'WON' : 'LOST'}`)
        .fontColor(this.win ? Color.Green : Color.Red)

      Blank().size({ height: 8 })

      Button() {
        SymbolGlyph($r('sys.symbol.arrow_clockwise'))
          .fontColor([Color.White])
      }
      .size({
        width: '100%',
        height: 32
      })
      .onClick(() => {
        this.showPopup = false
      })
    }
    .width('70%')
    .backgroundColor(Color.White)
    .padding(16)
  }
}