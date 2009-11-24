 ; LispMeObjects unit tests
 ; uses LispMeUnit
 ; evaluate (allTests)

 (define (allTests)
  (clearTests)
  (classTests)
  (instanceTests)
  (sendTests)
  (setTests)
  (superTests)
  (TestRunner))

 (define (classTests)
  (defTest "object initialize"
    (clearClasses)
    (assertTrue "object was not created" (getClass 'object)))
  (defTest "create class test"
    (clearClasses)
    (class 'test 'object '(one 1))
    (let ((test (getClass 'test)))
      (assert "test was wrong" equal? '(object (one 1)) test)))
  (defTest "undefined class test"
    (clearClasses)
    (assertFalse "junk should not exist" (getClass 'junk))))

 (define (instanceTests)
  (defTest "create instance"
    (clearClasses)
    (assert "super class wrong" equal? '(object) (new 'object)))
  (defTest "create with initial values"
    (clearClasses)
    (assert "instance wrong" equal? 
      '(object (test 3)(test2 2)) 
     (new 'object '(test 3) '(test2 2)))))

 (define (setTests)
  (defTest "set new slot"
    (clearClasses)
    (let ((instance (new 'object)))
      (send instance 'set 'test 5)
      (assert "slot had wrong value" = 5 (send instance 'test))
      (assert "object structure wrong" equal? '(object (test 5)) instance)))
  (defTest "set existing slot"
    (clearClasses)
    (let ((instance (new 'object '(test 3))))
      (send instance 'set 'test 5)
      (assert "slot had wrong value" = 5 (send instance 'test))
      (assert "didn't override value" equal? '(object (test 5)) instance))))

 (define (superTests)
  (defTest "test super"
    (clearClasses)
    (class 'test1 'object '(test 1))
    (class 'test2 'test1 '(test 2))
    (let ((instance (new 'test2 '(test 3))))
      (assert "instance wrong" = 3 (send instance 'test))
      (assert "super wrong" = 2 (send (send instance 'super) 'test))
      (assert "super super wrong" = 1 (send (send (send instance 'super) 'super) 'test)))))

 (define (sendTests)
  (defTest "send to class"
    (clearClasses)
    (class 'test 'object '(one 1))
    (assert "message was wrong" = 1 (send (getClass 'test) 'one)))
  (defTest "send to instance"
    (clearClasses)
    (class 'test 'object '(one 1))
    (assert "message was wrong" = 1 (send (new 'test) 'one)))
  (defTest "send unkown"
    (clearClasses)
    (class 'test 'object '(one 1))
    (assertFalse "message should be unknown" (send (new 'test) 'junk)))
  (defTest "send method"
    (clearClasses)
    (class 'test2 'object 
      `(plusTwo 
        ,(lambda (self aNumber) 
          (+ aNumber 2))))
    (assert "method should run" = 5 (send (new 'test2) 'plusTwo 3)))
  (defTest "complex method"
    (clearClasses)
    (class 'test 'object 
      `(sumup 
        ,(lambda (self aNumber) 
          (send self 'set 'sum (+ (send self 'sum) aNumber)))) 
      '(sum 0))
    (let ((instance (new 'test)))
      (send instance 'sumup 1)
      (send instance 'sumup 2)
      (send instance 'sumup 3)
      (assert "didn't sum correctly" = 6 (send instance 'sum))))
  (defTest "lazy init"
    (clearClasses)
    (class 'test 'object 
      `(c ,(lambda (self)
          (send self 'set 'c 
            (* (send self 'a)(send self 'b)))))
      '(b 3))
    (class 'test2 'test '(a 2))
    (class 'test3 'test '(a 3))
    (let ((instance (new 'test2)))
      (assert "message wrong" = 6 (send instance 'c))
      (assert "test2 was wrong" equal? instance '(test2 (c 6)))
      (assert "second message wrong" = 9 (send (new 'test3) 'c)))))
