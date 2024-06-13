% Лабораторная работа № 2 «Введение в объетно-ориентированное
  программирование на языке Scala»
% 18 марта 2024 г.
% Андрей Мельников, ИУ9-62Б

### Цель работы
Целью данной работы является изучение базовых объектно-ориентированных возможностей языка Scala.

### Индивидуальный вариант
Мультимножество строк с операциями объединения («+»), пересечения («*») и вычитания («-»). В мультимножестве
одна строка может содержаться в нескольких экземплярах.

### Реализация и тестирование

```scala
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
```

**Вывод тестовой программы на stdout**
```
Map(1 -> 32, 2 -> 21, 3 -> 1, 4 -> 1)
Map(1 -> 2, 2 -> 10)
Map(1 -> 28, 3 -> 1)
```

# Вывод
В ходе данной лабораторной работы был получен опыт разработки на языке Scala, изучены основы
объектно-ориентированного программирования и реализован класс мультимножества.
