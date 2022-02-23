(define call/cc call-with-current-continuation)
(define ie (interaction-environment))
(define *env* #f)
(display "#1 assert\n")


(define-syntax use-assertions
  (syntax-rules ()
    ((use-assertations) (call/cc (lambda (f) (set! *env* f))))))


(define-syntax assert
  (syntax-rules ()
    ((assert expr)
     (if (not expr)
         (begin (display "FAILED: ") (display (quote expr)) (newline) (*env*))))))


(use-assertions) ; инициализация каркаса


(define (sqr x)
  (assert (>= x 0)) ; Утверждение: x ДОЛЖЕН БЫТЬ >= 0
  (sqrt x))


(map sqr '(1 2 3 4 5)) ; ВЕРНЕТ список значений в программу
(map sqr '(-2 -1 0 1 2)) ; ВЫВЕДЕТ в консоль сообщение и завершит работу программы


;#2
(display "\n#2 save/load-data\n")


(define (save-data path)
  (call-with-output-file path
  (lambda (port) (write data port))))


(define (load-data path)
  (call-with-input-file path
    (lambda (port) (read port))))


(define data (load-data "input.txt"))
(display data)


(define (count-line file)
  (call-with-input-file file
    (lambda (port)
      (define s1 "")
      (define s2 "")
      (define (read-loop count)
        (set! s1 s2)
        (set! s2 (read-char port))
        (if (eof-object? s2)
            count
            (if (or (and (equal? s2 #\return) (not (equal? s1 #\newline))) (and (equal? s2 #\newline) (not (equal? s1 #\newline)) (not (equal? s1 #\return))))
                (read-loop (+ count 1))
                (read-loop count))))
      (read-loop 0))))


(display "\n(count-line \"L_4.scm\") -> ")
(count-line "L_4.scm")


;#3 tribonacci
(display "\n#3 tribonacci\n")


(define (tribonacci-with-mem n)
  (let ((memory (make-vector (+ n 1))))
    (let loop ((x n))
      (cond
        ((<= x 1) 0)
        ((= x 2) 1)
        (else (if (zero? (vector-ref memory x))
                  (vector-set! memory x (+ (loop (- x 1)) (loop (- x 2)) (loop (- x 3)))))
         (vector-ref memory x))))))


(define (tribonacci b)
  (cond
    ((<= b 1) 0)
    ((= b 2) 1)
    (else (+ (tribonacci (- b 1)) (tribonacci (- b 2)) (tribonacci (- b 3))))))


(display "(tribonacci-with-mem 4) -> ")
(tribonacci-with-mem 4)


;#4 my-if
(display "\n#4 my-if\n")


(define-syntax my-if
  (syntax-rules ()
    ((my-if cond? t-expr f-expr)
     (let ((t-prom (delay t-expr))
           (f-prom (delay f-expr)))
       (force (or (and cond? t-prom) f-prom))))))


(display "-does my-if work correctly?\n")
(my-if "-does my-if work correctly?\n"
       (display "-yes\n")
       (display "no\n"))


;#5 my-let/*
(display "\n#5 my-let/*\n")


(define-syntax my-let
  (syntax-rules ()
    ((my-let ((var1 val1) ...) expr1 ...)
     ((lambda (var1 ...) expr1 ...) val1 ...))))


(define-syntax my-let*
  (syntax-rules ()
    ((my-let* () expr1 ...)
     (my-let () expr1 ...))
    ((my-let* ((var1 val1)) expr1 ...)
     (my-let ((var1 val1)) expr1 ...))
    ((my-let* ((var1 val1) (var2 val2) ...) expr1 ...)
     (my-let ((var1 val1))
             (my-let* ((var2 val2) ...) expr1 ...)))))


(display "-does my-let* work correctly?\n")
(my-let* ((a #f) (b (not a)))
         (if b
             (display "-yes\n")
             (display "no\n")))


;#6 
(display "\n#6\n")


(define-syntax when
  (syntax-rules ()
    ((_ cond? . expr)
     (and cond? (begin . expr)))))
(define-syntax unless
  (syntax-rules ()
    ((_ cond? . expr)
     (and (not cond?)
          (begin . expr)))))


(define-syntax for
  (syntax-rules (in arr)
    ((for i in xxs expr ...)
     (let loop ((f xxs))
       (if (not (null? f))
           (let ((i (car f))) expr ...
             (loop (cdr f))))))
    ((for xxs arr i expr ...)
     (for i in xxs expr ...))))


(define-syntax while
  (syntax-rules ()
    ((_ cond? . expr)
     (let loop ()
       (if cond? (begin (begin . expr) (loop)))))))


(define-syntax repeat
  (syntax-rules (until)
    ((repeat (expr ...)until cond?)
     (let loop ()
       expr ...
       (if (not cond?)
           (loop))))))


(define-syntax cout
  (syntax-rules (<< endl)
    ((cout) (display ""))
    ((cout endl . body)
     (begin
       (newline)
       (cout . body)))
    ((cout << . body)
     (cout . body))
    ((cout expr . body)
     (begin
       (display expr)
       (cout . body)))))

(cout << "print " << 1 << endl << "sys.stdout.write " << 2 << endl)
