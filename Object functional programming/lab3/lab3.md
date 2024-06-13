% Лабораторная работа № 3 «Обобщённые классы в Scala»
% 1 апреля 2024 г.
% Андрей Мельников, ИУ9-62Б

# Цель работы
Целью данной работы является приобретение навыков разработки обобщённых классов на языке Scala с
использованием неявных преобразований типов.

# Индивидуальный вариант
Класс EqualitySystem[T], представляющий систему равенств вида a = b, где a и b — имена переменных или значения
типа T. В классе должно быть реализовано две операции: добавление нового равенства; проверка, существует ли
решение системы. В случае, если тип T — числовой, дополнительно должна быть реализована операция, возвращающая
значение переменной, возвращающая Option[T]. Значения должны назначаться переменным произвольно, но так, чтобы
система равенств не нарушалась.

# Реализация

```scala
object main {
  class EquationSystem[T] {
    var equations = List.empty[(Any, Any)]
    var variable_values = scala.collection.mutable.Map[String, T]()

    def add_equation(equation: (Any, Any)): Unit = {
      if (equation._1.isInstanceOf[String] && equation._2.isInstanceOf[String]) {
        this.equations = this.equations :+ equation
      } else {
        this.equations = equation :: this.equations
      }

      var new_variables = List.empty[String]

      def set_values(variable: String, used_variables: List[String]): List[String] = {
        var new_used_variables = used_variables :+ variable
        for (equation <- this.equations) {
          if (equation._1.isInstanceOf[String] && equation._2.isInstanceOf[String]) {
            if (equation._1 == variable) {
              this.variable_values(equation._2.toString) = this.variable_values(equation._1.toString)
              if (!new_used_variables.contains(equation._2)) {
                new_used_variables = set_values(equation._2.toString, new_used_variables)
              }
            } else if (equation._2 == variable) {
              this.variable_values(equation._1.toString) = this.variable_values(equation._2.toString)
              if (!new_used_variables.contains(equation._1)) {
                new_used_variables = set_values(equation._1.toString, new_used_variables)
              }
            }
          }
        }
        new_used_variables
      }

      for (equation <- this.equations) {
        new_variables = List.empty[String]
        if (!equation._1.isInstanceOf[String] && equation._2.isInstanceOf[String]) {
          this.variable_values(equation._2.toString) = equation._1.asInstanceOf[T]
          new_variables = set_values(equation._2.toString, new_variables)
        } else if (!equation._2.isInstanceOf[String] && equation._1.isInstanceOf[String]) {
          this.variable_values(equation._1.toString) = equation._2.asInstanceOf[T]
          new_variables = set_values(equation._1.toString, new_variables)
        }
      }
    }

    def solve_exists(): Boolean = {
      var res = true
      for (equation <- this.equations) {
        if (equation._1.isInstanceOf[String] && this.variable_values.contains(equation._1.toString)) {
          if (equation._2.isInstanceOf[String]) {
            println(0)
            res = res && (this.variable_values(equation._1.toString) == this.variable_values(
equation._2.toString))
          } else {
            println(1)
            res = res && (this.variable_values(equation._1.toString) == equation._2.asInstanceOf[T])
          }
        } else if (equation._2.isInstanceOf[String] && this.variable_values.contains(equation._2.toString)) {
          res = res && (this.variable_values(equation._2.toString) == equation._1)
        } else if (!equation._1.isInstanceOf[String] && !equation._2.isInstanceOf[String]) {
          res = res && (equation._1.asInstanceOf[T] == equation._2.asInstanceOf[T])
        }
      }
      res
    }

    def get_value(variable: String)(implicit num : Numeric[T]): Option[T] = {
      if (this.solve_exists()) {
        if (this.variable_values.contains(variable)) {
          Option(this.variable_values(variable))
        } else {
          Option(1.asInstanceOf[T])
        }
      } else {
        None
      }
    }
  }

  def main(args: Array[String]): Unit = {
    val system = new EquationSystem[Int]()
    system.add_equation("a", "b")
    system.add_equation("c", "b")
    system.add_equation("c", "d")
    system.add_equation("a", "e")
    system.add_equation(1, "e")
    system.add_equation(1, "a")
    system.add_equation("g", "h")
    if (system.solve_exists()) {
      println("Система имеет решение")
    } else {
      println("Система не имеет решения")
    }
    println("Значение переменной d: " + system.get_value("d").toString)
    println("Значение переменной h: " + system.get_value("h").toString)

    val system2 = new EquationSystem[Int]()

    system2.add_equation(11, "x")
    system2.add_equation("y", "z")
    if (system2.solve_exists()) {
      println("Система имеет решение")
    } else {
      println("Система не имеет решения")
    }
    println(system2.get_value("y"))
  }
}
```

# Тестирование

Результат запуска программы:

```
0
0
0
0
Система имеет решение
0
0
0
0
Значение переменной d: Some(1)
0
0
0
0
Значение переменной h: Some(1)
Система имеет решение
Some(1)
```

# Вывод
В ходе данной лабораторной работы были получены навыки разработки обобщённых классов на языке Scala с
использованием неявных преобразований типов и реализован обобщённый класс системы равенств.
