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
            res = res && (this.variable_values(equation._1.toString) == this.variable_values(equation._2.toString))
          } else {
            println(1)
            res = res && (this.variable_values(equation._1.toString) == equation._2.asInstanceOf[T])
          }
        } else if (equation._2.isInstanceOf[String] && this.variable_values.contains(equation._2.toString)) {
          // println(2, this.variable_values(equation._2.toString), equation._1, this.variable_values(equation._2.toString) == equation._1)
          // println(this.variable_values)
          res = res && (this.variable_values(equation._2.toString) == equation._1)
        } else if (!equation._1.isInstanceOf[String] && !equation._2.isInstanceOf[String]) {
          // println(3, equation._1.isInstanceOf[T])
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
