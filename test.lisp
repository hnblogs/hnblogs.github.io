;;;; Tests
;;;; =====

;;;; The tests in this file test the Lisp source code in gen.lisp.
;;;; These tests does not validate user data in pwd.lisp.
;;;; Validation of user data in pwd.lisp is done by gen.lisp itself
;;;; just before generating the HTML and OPML artefacts.

(require "uiop")


;;; Test Definitions
;;; ----------------

(defparameter *pass* 0)
(defparameter *fail* 0)
(defvar *quit* nil)

(defun set-dev-path ()
  "Utility function to be run manually in development environment."
  (setf *default-pathname-defaults* (truename "~/git/hnpwd/")))

(defmacro test-case (name &body body)
  "Execute a test case and print pass or fail status."
  `(progn
     (let ((test-name (string-downcase ',name)))
       (format t "~&~a: " test-name)
       (handler-case (progn ,@body)
         (:no-error (c)
           (declare (ignore c))
           (incf *pass*)
           (format t "pass~%")
           t)
         (error (c)
           (incf *fail*)
           (format t "FAIL~%")
           (format t "~&  ~a: error: ~a~%" test-name c))))))

(defun test-done ()
  "Print test statistics."
  (format t "~&~%PASS: ~a~%" *pass*)
  (when (plusp *fail*)
    (format t "~&FAIL: ~a~%" *fail*))
  (when *quit*
    (format t "~&~%DONE~%~%")
    (uiop:quit (if (zerop *fail*) 0 1)))
  (zerop *fail*))


;;; Begin Test Cases
;;; ----------------

(defvar *gen-mode* nil)
(defvar *lint-mode* nil)
(load "gen.lisp")
(load "lint.lisp")


;;; Test Cases
;;; ----------

(test-case fstr
  (assert (string= (fstr "") ""))
  (assert (string= (fstr "~a" "hello") "hello"))
  (assert (string= (fstr "~a ~a" "hello" "world") "hello world")))

(test-case write-file
  (write-file "tmp.txt" "foo")
  (let ((text (uiop:read-file-string "tmp.txt")))
    (delete-file "tmp.txt")
    (assert (string= text "foo"))))

(test-case read-list
  (write-file "tmp.txt" "((:a \"apple\") (:b \"ball\"))")
  (let ((data (read-list "tmp.txt")))
    (delete-file "tmp.txt")
    (assert (equal data '((:a "apple") (:b "ball"))))))

(test-case has-duplicates-p
  (assert (has-duplicates-p '(10 10)))
  (assert (has-duplicates-p '(10 20 30 40 10 50)))
  (assert (not (has-duplicates-p '())))
  (assert (not (has-duplicates-p '(10))))
  (assert (not (has-duplicates-p '(10 20 30)))))

(test-case string-starts-with-p
  (assert (string-starts-with-p "" ""))
  (assert (string-starts-with-p "" "foo"))
  (assert (string-starts-with-p "foo" "foo"))
  (assert (string-starts-with-p "foo" "foobar"))
  (assert (not (string-starts-with-p "foo" "")))
  (assert (not (string-starts-with-p "foo" "barfoo"))))

(test-case string-ends-with-p
  (assert (string-ends-with-p "" ""))
  (assert (string-ends-with-p "" "foo"))
  (assert (string-ends-with-p "foo" "foo"))
  (assert (string-ends-with-p "foo" "barfoo"))
  (assert (not (string-ends-with-p "foo" "")))
  (assert (not (string-ends-with-p "foo" "foobar"))))

(test-case string-trim-prefix
  (assert (string= (string-trim-prefix "" "") ""))
  (assert (string= (string-trim-prefix "" "foo") "foo"))
  (assert (string= (string-trim-prefix "foo" "foo") ""))
  (assert (string= (string-trim-prefix "foo" "foobar") "bar"))
  (assert (string= (string-trim-prefix "foo" "") ""))
  (assert (string= (string-trim-prefix "foo" "barfoo") "barfoo")))

(test-case format-date
  (assert (string= (format-date (encode-universal-time 0 0 0 14 1 2026 0))
                   "Wed, 14 Jan 2026 00:00:00 +0000"))
  (assert (string= (format-date (encode-universal-time 0 0 0 14 1 2026 5))
                   "Wed, 14 Jan 2026 05:00:00 +0000"))
  (assert (string= (format-date (encode-universal-time 0 0 0 14 1 2026 -11/2))
                   "Tue, 13 Jan 2026 18:30:00 +0000")))

(test-case parse-domain
  (assert (string= (parse-domain "https://foo/") "foo"))
  (assert (string= (parse-domain "https://foo/bar") "foo"))
  (assert (string= (parse-domain "https://foo/bar/") "foo"))
  (assert (string= (parse-domain "https://example.com/") "example.com"))
  (assert (string= (parse-domain "https://www.example.com/") "www.example.com"))
  (assert (string= (parse-domain "https://www.example.com/bar/") "www.example.com"))
  (assert (string= (parse-domain "https://blog.example.com/bar/") "blog.example.com")))

(test-case parse-short-domain
  (assert (string= (parse-short-domain "https://foo/") "foo"))
  (assert (string= (parse-short-domain "https://foo/bar") "foo"))
  (assert (string= (parse-short-domain "https://foo/bar/") "foo"))
  (assert (string= (parse-short-domain "https://example.com/") "example.com"))
  (assert (string= (parse-short-domain "https://www.example.com/") "example.com"))
  (assert (string= (parse-short-domain "https://www.example.com/bar/") "example.com"))
  (assert (string= (parse-short-domain "https://blog.example.com/bar/") "example.com")))

(test-case validate-name-order
  (assert (=  (length (validate-name-order '((:name "Alice")))) 0))
  (assert (=  (length (validate-name-order '((:name "Alice")
                                             (:name "Bob")))) 0))
  (assert (=  (length (validate-name-order '((:name "Alice")
                                             (:name "Bob")
                                             (:name "Carol")))) 0))
  (assert (=  (length (validate-name-order '((:name "Bob")
                                             (:name "Alice")))) 1))
  (assert (=  (length (validate-name-order '((:name "Bob")
                                             (:name "Alice")
                                             (:name "Carol")))) 1))
  (assert (=  (length (validate-name-order '((:name "Carol")
                                             (:name "Bob")
                                             (:name "Alice")))) 2)))

(test-case validate-bio-basic
  ;; No errors.
  (assert (=  (length (validate-bio-basic '((:bio "foo, bar and baz.")))) 0))
  (assert (=  (length (validate-bio-basic '((:bio "foo, bar & baz.")))) 1))
  ;; 1 error: Ampersand not allowed.
  (assert (=  (length (validate-bio-basic '((:bio "foo, bar & baz.")))) 1))
  ;; 1 error: Vertical bar not allowed.
  (assert (=  (length (validate-bio-basic '((:bio "foo | bar | baz.")))) 1))
  ;; 1 error each: 'ex-' not allowed.
  (assert (=  (length (validate-bio-basic '((:bio "ex-Foo.")))) 1))
  (assert (=  (length (validate-bio-basic '((:bio "Foo ex-Boo.")))) 1))
  ;; 1 error: Full stop missing.
  (assert (=  (length (validate-bio-basic '((:bio "foo, bar and baz")))) 1))
  ;; 1 error: Oxford comma not allowed.
  (assert (=  (length (validate-bio-basic '((:bio "foo, bar, and baz.")))) 1))
  ;; 3 error: Ampersand, Oxford comma and full stop missing.
  (assert (=  (length (validate-bio-basic '((:bio "foo & bar, and baz")))) 3))
  ;; No errors.  Maximum bio length allowed is 80 chars.
  (let ((bio "1234567890123456789012345678901234567890123456789012345678901234567890123456789."))
    (assert (= (length (validate-bio-basic `((:bio ,bio)))) 0)))
  ;; 1 error: Bio length is 81 but maximum length is 80.
  (let ((bio "12345678901234567890123456789012345678901234567890123456789012345678901234567890."))
    (assert (= (length (validate-bio-basic `((:bio ,bio)))) 1))))

(test-case validate-bio-person
  (assert (= (length (validate-bio-person '((:bio "Foo Bar.")))) 0))
  (assert (= (length (validate-bio-person '((:bio "I am Foo.")))) 1))
  (assert (= (length (validate-bio-person '((:bio "I'm Foo.")))) 1))
  (assert (= (length (validate-bio-person '((:bio "Foo am I.")))) 1))
  (assert (= (length (validate-bio-person '((:bio "Foo I am.")))) 1))
  (assert (= (length (validate-bio-person '((:bio "Foo I'm.")))) 1))
  (assert (= (length (validate-bio-person '((:bio "Foo Bar.")
                                            (:bio "I am Foo.")
                                            (:bio "Foo I am.")
                                            (:bio "Foo am I.")))) 3)))

(test-case validate-bio-spacing
  (assert (= (length (validate-bio-spacing '((:bio "Foo.  Bar.  Baz.")))) 0))
  (assert (= (length (validate-bio-spacing '((:bio "Foo. Bar.  Baz.")))) 1))
  (assert (= (length (validate-bio-spacing '((:bio "Foo.  Bar.  Baz.")
                                             (:bio "Foo. Bar.  Baz.")
                                             (:bio "Foo. Bar. Baz.")))) 2)))

(test-case validate-urls-protocol
  (assert (= (length (validate-url-formats '((:site "example/foo/bar/baz/")))) 1))
  (assert (= (length (validate-url-formats '((:site "www.example.com")))) 2)))

(test-case validate-urls-slashes
  (assert (= (length (validate-url-formats '((:site "http://site/")))) 0))
  (assert (= (length (validate-url-formats '((:site "http://site")))) 1))
  (assert (= (length (validate-url-formats '((:blog "http://blog")))) 1))
  (assert (= (length (validate-url-formats '((:feed "http://feed")))) 1))
  (assert (= (length (validate-url-formats '((:about "http://about")))) 1))
  (assert (= (length (validate-url-formats '((:now "http://now")))) 1))
  (assert (= (length (validate-url-formats '((:site "http://site/"
                                              :blog "http://blog/"
                                              :feed "http://feed/"
                                              :about "http://about/"
                                              :now "http://now/")))) 0))
  (assert (= (length (validate-url-formats '((:site "http://site"
                                              :blog "http://blog"
                                              :feed "http://feed"
                                              :about "http://about"
                                              :now "http://now")))) 5)))

(test-case validate-urls-domains
  (assert (= (length (validate-url-domains '((:site "http://example/site/"
                                              :blog "http://example/blog/"
                                              :feed "http://example/feed/"
                                              :about "http://example/about/"
                                              :now "http://example/now/")))) 0))
  (assert (= (length (validate-url-domains '((:site "http://example/site/"
                                              :blog "http://coexample/")))) 1))
  (assert (= (length (validate-url-domains '((:site "http://example/site/"
                                              :feed "http://coexample/")))) 1))
  (assert (= (length (validate-url-domains '((:site "http://example/site/"
                                              :about "http://coexample/")))) 1))
  (assert (= (length (validate-url-domains '((:site "http://example/site/"
                                              :now "http://coexample/")))) 1))
  (assert (= (length (validate-url-domains '((:site "http://example/site/"
                                              :blog "http://example.co/blog/"
                                              :feed "http://co.example/feed/"
                                              :about "http://coexample/about/"
                                              :now "http://exampleco/now/")))) 3)))

(test-case validate-unique-urls
  (assert (= (length (validate-unique-urls '((:site "http://site/")))) 0))
  (assert (= (length (validate-unique-urls '((:site "http://site/"
                                              :blog "http://blog/"
                                              :feed "http://feed/"
                                              :about "http://about/"
                                              :now "http://now/")))) 0))
  (assert (= (length (validate-unique-urls '((:site "http://site/"
                                              :blog "http://site/"
                                              :feed "http://feed/"
                                              :about "http://about/"
                                              :now "http://now/")))) 1))
  (assert (= (length (validate-unique-urls '((:site "http://site/"
                                              :blog "http://blog/"
                                              :feed "http://blog/"
                                              :about "http://about/"
                                              :now "http://now/")))) 1))
  (assert (= (length (validate-unique-urls '((:site "http://site/"
                                              :blog "http://blog/"
                                              :feed "http://feed/"
                                              :about "http://feed/"
                                              :now "http://now/")))) 1))
  (assert (= (length (validate-unique-urls '((:site "http://site/"
                                              :blog "http://blog/"
                                              :feed "http://feed/"
                                              :about "http://about/"
                                              :now "http://about/")))) 1))
  (assert (= (length (validate-unique-urls '((:site "http://site/"
                                              :blog "http://site/"
                                              :feed "http://site/"
                                              :about "http://site/"
                                              :now "http://site/")))) 1)))

(test-case validate-hn-uids
  (assert (= (length (validate-hn-uids '((:hnuid "foo")))) 0))
  (assert (= (length (validate-hn-uids '((:hnuid "foo-bar_baz99")))) 0))
  (assert (= (length (validate-hn-uids '((:hnuid "http://foo/")))) 1))
  (assert (= (length (validate-hn-uids '((:hnuid "https://foo/")))) 1)))


;;; The End
;;; -------

(test-done)
