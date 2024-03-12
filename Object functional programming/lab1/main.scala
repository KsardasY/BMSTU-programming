object main {
  val condition = (x: Int) => x % 12 == 0

  val arith: (Int => Boolean) => (Int, Int, Int) => List[Int] =
    p => {
      case (0, num, step) => Nil
      case (cnt, num, step) if p(num) => num::arith(p)(cnt - 1, num + step, step)
      case (cnt, num, step) => arith(p)(cnt, num + step, step)
    }

  def main(args: Array[String]): Unit = {
    println(arith(condition)(3, 6, 6))
  }
}