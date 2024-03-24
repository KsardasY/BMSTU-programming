object main {
  class StringMultiSet(d: Map[String, Int]) {
    val dict = d

    def +(other: StringMultiSet): StringMultiSet = new StringMultiSet(
      this.dict ++ other.dict.map {case(k, v) => k -> (v + this.dict.getOrElse(k, 0)) }
    )

    def *(other: StringMultiSet): StringMultiSet = new StringMultiSet(
      this.dict.keySet.intersect(other.dict.keySet).map(k =>
        k -> (this.dict(k) min other.dict(k))).toMap
    )

    def -(other: StringMultiSet): StringMultiSet = new StringMultiSet(
      (this.dict.keySet.intersect(other.dict.keySet).filter(k =>
        this.dict(k) > other.dict(k)) ++ this.dict.keySet.diff(other.dict.keySet)).map(k =>
        k -> (this.dict(k) - other.dict.getOrElse(k, 0))).toMap
    )
  }

  def main(args: Array[String]): Unit = {
    var a = Map[String, Int]("1" -> 30, "2" -> 10, "3" -> 1)
    var b = Map[String, Int]("1" -> 2, "2" -> 11, "4" -> 1)
    var x = new StringMultiSet(a)
    var y = new StringMultiSet(b)
    println((x + y).dict)
    println((x * y).dict)
    println((x - y).dict)
  }
}