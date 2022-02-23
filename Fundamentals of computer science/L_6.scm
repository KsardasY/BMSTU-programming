(load "unit-test.scm")

;#1

;<expression> := <content> FINISH-SYMBOL
;<content> := <fraction> | <other-symbols> | <content> <fraction> | <content> <other-symbols>
;<fraction> := <sign> <number> SLASH <number>
;<number> := <digit> | <number> <digit>
;<digit> := 0|1|2|3|4|5|6|7|8|9
;<other-symbols> := ASCII-SYMBOLS
;<sign> := - | +

;FINISH-SYMBOL
(define finish-symbol #\⛔)

;функции работы с потоком

;<expression> := <content> FINISH-SYMBOL
(define (make-stream str)
  (append (string->list str) (list finish-symbol))
  )


(define (peek stream)
  (if (null? stream)
      #f
      (car stream)))

(define (next stream)
  (if (null? stream)
      #f
      (cdr stream))
  )

(define (next-col x stream)
  (letrec ((loop (lambda (xs x)
                   (if (or (= x 0) (null? xs))
                       xs
                       (loop (cdr xs) (- x 1))
                       )
                   ))
           )
    (loop stream x))
  )

;<sign> := - | +
(define (Sign? symb)
  (or (equal? symb #\-) (equal? symb #\+))
  )
(define (peak-sign char)
  (cond ((equal? char #\-) -1)
        (else 1))
  )
;<digit> := 0|1|2|3|4|5|6|7|8|9
(define (Digit? char)
  (or (equal? char #\0) (equal? char #\1) (equal? char #\2) (equal? char #\3) (equal? char #\4)
      (equal? char #\5) (equal? char #\6) (equal? char #\7) (equal? char #\8) (equal? char #\9))
  )
      
(define (scan-digit char)
  (cond ((equal? char #\0) 0) ((equal? char #\1) 1) ((equal? char #\2) 2) ((equal? char #\3) 3)
        ((equal? char #\4) 4) ((equal? char #\5) 5) ((equal? char #\6) 6) ((equal? char #\7) 7)
        ((equal? char #\8) 8) ((equal? char #\9) 9) (else #f))
  )
        
;<number> := <digit> | <number> <digit>
(define (Num? stream)
  (if (null? stream) 
      #f
      (letrec ((loop (lambda (xs)
                       (if (null? xs)
                           #t
                           (and (Digit? (peek xs)) (loop (cdr xs)))
                           )
                       ))
               )
        (loop stream)             
        )
      )
  )
(define (Num stream)
  (letrec ((loop (lambda (xs res)
                   (if (null? xs)
                       res
                       (loop (cdr xs) (+ (* res 10) (scan-digit (car xs))))
                       )
                   )))
    (loop stream 0)
    )
  )
    
;<fraction> := <sign> <number> SLASH <number>
(define (frac stream) 
  (letrec (
           (stream-numerator '())
           (stream-denominator '())
           (sign 1)
           (make-stream-loop (lambda (xs1 xs2 finish)
                               (if (or (equal? (peek xs1) finish) (equal? (peek xs1) finish-symbol) (null? xs1))  ;2a13/122d221f    (2 1 3)
                                   xs2
                                   (make-stream-loop (cdr xs1) (append xs2 (list (peek xs1))) finish)
                                   )
                               ))
           )
    ;sign
    (if (Sign? (peek stream))
        (begin (set! sign (peak-sign (peek stream))) (set! stream (next stream)))
        )
    ;numerator
    (set! stream-numerator (make-stream-loop stream '() #\/))
    (set! stream (next-col (length stream-numerator) stream))

    ;SLASH
    (if (eq? (peek stream) #\/)
        (begin
          (set! stream (next stream))
          ;denominator
          (set! stream-denominator (make-stream-loop stream '() finish-symbol))
          (set! stream (next-col (length stream-denominator) stream))
          
          (if (and (Num? stream-numerator) (Num? stream-denominator))
              (list (* sign (Num stream-numerator)) (Num stream-denominator))
              #f
              )
          )
        #f)
    )
  )

;<content> := <fraction> | <other-symbols> | <content> <fraction> | <content> <other-symbols>
(define (fracs stream)
  (letrec ((x #f)
           (list-fracs '())
           (loop (lambda (xs fracs)
                   (if (equal? (peek xs) finish-symbol)
                       fracs
                       (if (or (Digit? (peek xs)) (Sign? (peek xs)))
                           (begin (set! x (try-frac xs))
                                  (if (null? x)
                                      ;(loop (cdr xs) fracs) ;если вернуть эту строку то рпограмма будет выделять все сущ. дроби
                                      #f
                                      (loop (next-col (length x) xs) (append fracs (frac x)))
                                      ))
                           (if (null? xs)
                               fracs
                               (loop (cdr xs) fracs))
                           )
                       )))
           (try-frac (lambda (xs)
                       (letrec ((loop2 (lambda (xs1 xs2 res)
                                         (if (null? xs1)
                                             res
                                             (begin (set! xs2 (append xs2 (list (car xs1))))  ;+23432432/34  
                                                    (if (frac xs2)
                                                        (set! res xs2))
                                                    (loop2 (cdr xs1) xs2 res))
                                             )
                                         )))
                         (loop2 xs '() '())
                         )
                       ))
           (complete-fracs (lambda (xs1 xs2) ;(1 2 3 4) -> (1/2 3/4)
                             (if (null? xs1)
                                 xs2
                                 (complete-fracs (cdr (cdr xs1)) (append xs2 (list (/ (car xs1) (car (cdr xs1))))))
                                 )
                             ))
           )
    
    (set! list-fracs (loop stream '()))
    (if (eq? list-fracs #f)
        #f
        (complete-fracs list-fracs '())
        )
    )
  )                                     
                                   
(define (check-frac str)
  (if (frac (make-stream str))
      #t
      #f)
  )

(define (scan-frac str)
  (if (check-frac str)
      (/ (car (frac (make-stream str))) (car (cdr (frac (make-stream str)))))
      #f
      )
  )

(define (scan-many-fracs str)
  (fracs (make-stream str))
  )


;#2
(define-syntax for
  (syntax-rules (in as)
    ((for x in xs . actions) (letrec ((loop (lambda (xs1)
                                              (if (not (null? xs1))
                                                  (let ((x (car xs1)))
                                                    (begin (begin . actions) (loop (cdr xs1))))
                                                  )
                                              )))
                               (loop xs))
                             )
    ((for xs as x . actions) (for x in xs . actions))
    )
  )


(define (s->s s)
  (if (symbol? s)
      (symbol->string s)
      (string->symbol s)))


(define-syntax define-struct
  (syntax-rules ()
    ((_ name (fields ... ))
     (begin
       (eval
        (list 'define (list
                       (s->s (string-append "make-" (s->s 'name)))
                       'fields ...)
              (list 'list
                    (s->s 'name)
                    (list 'map 'list
                          (cons 'list (map s->s '(fields ...)))
                          (cons 'list '(fields ...)))))
        (interaction-environment))
       (eval
        (list 'define (list
                       (s->s (string-append (s->s 'name)  "?"))
                       'struct)
              (list 'and
                    (list 'pair? 'struct)
                    (list 'equal? (list 'car 'struct) (s->s 'name))))
        (interaction-environment))
       (let ((fields-stringed (map s->s '(fields ...))))
         (for field in fields-stringed
           (eval
            (list 'define (list
                           (s->s (string-append (s->s 'name) "-" field))
                           'struct)
                  (list 'cadr (list 'assq field (list 'cadr 'struct))))
            (interaction-environment)))
         (for field in fields-stringed
           (eval
            (list 'define (list
                           (s->s (string-append "set-" (s->s 'name) "-" field "!"))
                           'struct
                           'val)
                  (list 'set-car! (list 'cdr (list 'assq field (list 'cadr 'struct))) 'val))
            (interaction-environment))))))))


(define-struct stream (symbols))


(define (stream-peek stream)
  (if (pair? (stream-symbols stream))
      (let ((symbol (car (stream-symbols stream))))
        symbol)))


(define (stream-next stream)
  (let ((symbol (car (stream-symbols stream))))
    (set-stream-symbols! stream (cdr (stream-symbols stream)))
    ))


(define (string->stream str)
  (make-stream (string->list (string-append str (string finish-symbol)))))


(define (vector->stream vec)
  (make-stream (append (vector->list vec) (list finish-symbol))))


(define (parse vec)
  (letrec (
           (stream (vector->stream vec))
           (special-words (map list (list finish-symbol 'endif 'end)))
           (parse-finish-symbol (lambda ()
                                  (let ((finish (stream-peek stream)))
                                    (if (equal? finish finish-symbol)
                                         (begin (stream-next stream) finish)
                                         )
                                    ))
                                )
           (parse-program (lambda ()
                            (let ((articles (parse-articles))
                                  (body (parse-body))
                                  (finish (parse-finish-symbol)))
                              (and (and articles body finish)
                                   (list articles body))))
                          )
           (parse-articles (lambda ()
                             (let* ((article (parse-article))
                                    (articles (and
                                               (not (equal? article '()))
                                               article
                                               (parse-articles))))
                               (if (and article articles (not (equal? article '())))
                                   (cons article articles)
                                   article)))
                           )
           (parse-define (lambda ()
                           (let ((def (stream-peek stream)))
                             (and (equal? def 'define)
                                  (begin (stream-next stream) def))))
                         )
           (parse-end (lambda ()
                        (let ((end (stream-peek stream)))
                          (and (equal? end 'end)
                               (begin (stream-next stream) end)))
                        ))
           (parse-word (lambda ()
                         (let ((word (stream-peek stream)))
                           (begin
                             (stream-next stream)
                             word))
                         )
                       )
           (parse-article (lambda ()
                            (let* ((def (parse-define))
                                   (word (and def (parse-word)))
                                   (body (and word (parse-body)))
                                   (end (and body (parse-end))))
                              (if def
                                  (and def word body end
                                       (list word body))
                                  '())
                              )
                            )
                          )
           (parse-endif (lambda ()
                          (let ((endif (stream-peek stream)))
                            (and (equal? endif 'endif)
                                 (begin (stream-next stream) endif)))))
           (parse-body (lambda ()
                         (let ((first (stream-peek stream)))
                           (cond
                             ((equal? first 'if)
                              (stream-next stream)
                              (let* ((body (parse-body))
                                     (endif (and body (parse-endif)))
                                     (body-next (and endif (parse-body))))
                                (and first body endif body-next
                                     (append (list (append (list first body)))  body-next))))
                             ((number? first)
                              (stream-next stream)
                              (let ((body (parse-body)))
                                (and first body
                                     (cons first body))))
                             ((not (assq first special-words))
                              (stream-next stream)
                              (let ((body (parse-body)))
                                (and first body
                                     (cons first body))))
                             (else '())
                             )))))
    (parse-program)))


(define tests#2 (list
                 (test (parse #(1 2 +)) '(() (1 2 +)))
                 (test (parse #(x dup 0 swap if drop -1 endif)) '(() (x dup 0 swap (if (drop -1)))))
                 (test (parse #( define -- 1 - end
                                  define =0? dup 0 = end
                                  define =1? dup 1 = end
                                  define factorial
                                  =0? if drop 1 exit endif
                                  =1? if drop 1 exit endif
                                  dup --
                                  factorial
                                  *
                                  end
                                  0 factorial
                                  1 factorial
                                  2 factorial
                                  3 factorial
                                  4 factorial )) '(((-- (1 -))
                                                    (=0? (dup 0 =))
                                                    (=1? (dup 1 =))
                                                    (factorial
                                                     (=0? (if (drop 1 exit)) =1? (if (drop 1 exit)) dup -- factorial *)))
                                                   (0 factorial 1 factorial 2 factorial 3 factorial 4 factorial)))
                 (test (parse #(if 1 2 endif if 3 4)) #f)
                 (test (parse #(define word w1 w2 w3)) #f)
                 (test (parse #(define =0? dup 0 = end 
                                 define <0? dup 0 < end 
                                 define signum 
                                 =0? if exit endif 
                                 <0? if drop -1 exit endif 
                                 drop 
                                 1 
                                 end 
                                 0 signum 
                                 -2 signum )) '(((=0? (dup 0 =)) (<0? (dup 0 <)) (signum (=0? (if (exit)) <0? (if (drop -1 exit)) drop 1))) (0 signum -2 signum)))
                 (test (parse #(1 2 if + if dup - endif endif dup)) '(() (1 2 (if (+ (if (dup -)))) dup)))
                 (test (parse #(define abs 
                                 dup 0 < 
                                 if neg endif 
                                 end 
                                 9 abs 
                                 -9 abs)) '(((abs (dup 0 < (if (neg))))) (9 abs -9 abs)))
                 (test (parse #(display if end endif)) #f)
                 (test (parse #(if define if endif)) #f)
                 ))


(run-tests tests#2)

(define tests#2 (list
                 (test (parse #(1 2 +)) '(() (1 2 +)))
                 (test (parse #(x dup 0 swap if drop -1 endif)) '(() (x dup 0 swap (if (drop -1)))))
                 (test (parse #( define -- 1 - end
                                  define =0? dup 0 = end
                                  define =1? dup 1 = end
                                  define factorial
                                  =0? if drop 1 exit endif
                                  =1? if drop 1 exit endif
                                  dup --
                                  factorial
                                  *
                                  end
                                  0 factorial
                                  1 factorial
                                  2 factorial
                                  3 factorial
                                  4 factorial )) '(((-- (1 -))
                                                    (=0? (dup 0 =))
                                                    (=1? (dup 1 =))
                                                    (factorial
                                                     (=0? (if (drop 1 exit)) =1? (if (drop 1 exit)) dup -- factorial *)))
                                                   (0 factorial 1 factorial 2 factorial 3 factorial 4 factorial)))
                 (test (parse #(if 1 2 endif if 3 4)) #f)
                 (test (parse #(define word w1 w2 w3)) #f)
                 (test (parse #(define =0? dup 0 = end 
                                 define <0? dup 0 < end 
                                 define signum 
                                 =0? if exit endif 
                                 <0? if drop -1 exit endif 
                                 drop 
                                 1 
                                 end 
                                 0 signum 
                                 -2 signum )) '(((=0? (dup 0 =)) (<0? (dup 0 <)) (signum (=0? (if (exit)) <0? (if (drop -1 exit)) drop 1))) (0 signum -2 signum)))
                 (test (parse #(1 2 if + if dup - endif endif dup)) '(() (1 2 (if (+ (if (dup -)))) dup)))
                 (test (parse #(define abs 
                                 dup 0 < 
                                 if neg endif 
                                 end 
                                 9 abs 
                                 -9 abs)) '(((abs (dup 0 < (if (neg))))) (9 abs -9 abs)))
                 (test (parse #(display if end endif)) #f)
                 (test (parse #(if define if endif)) #f)
                 ))


(run-tests tests#2)
