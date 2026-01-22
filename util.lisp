;;;; HNPWD Utilities
;;;; ===============

(defun fstr (fmt &rest args)
  "Format string using specified format and arguments."
  (apply #'format nil fmt args))

(defun jstr (&rest strings)
  "Join strings into a single string."
  (apply #'concatenate 'string strings))

(defun write-file (filename text)
  "Write text to file and close the file."
  (with-open-file (f filename :direction :output :if-exists :supersede)
    (write-sequence text f)))

(defun read-list (filename)
  "Read Lisp file."
  (with-open-file (f filename) (read f)))

(defun read-entries (filename)
  "Read website entries from the data file."
  (remove-if
   (lambda (item)
     (or (equal item '(:begin))
         (equal item '(:end))
         (string= (getf item :site) "")))
   (read-list filename)))

(defun has-duplicates-p (items)
  "Check if there are duplicates in the given items."
  (< (length (remove-duplicates items :test #'equal))
     (length items)))

(defun string-starts-with-p (prefix string)
  "Check if the given string starts with the given prefix."
  (and (<= (length prefix) (length string))
       (string= prefix string :end2 (length prefix))))


(defun string-ends-with-p (suffix string)
  "Check if the given string ends with the given suffix."
  (let ((suffix-length (length suffix))
        (string-length (length string)))
    (and (<= suffix-length string-length)
         (string= suffix string
                  :start2 (- string-length suffix-length)))))

(defun string-trim-prefix (prefix string)
  "Remove the given prefix from the given string."
  (if (string-starts-with-p prefix string)
      (subseq string (length prefix))
      string))

(defun weekday-name (weekday-index)
  "Given an index, return the corresponding day of week."
  (nth weekday-index '("Mon" "Tue" "Wed" "Thu" "Fri" "Sat" "Sun")))

(defun month-name (month-number)
  "Given a number, return the corresponding month."
  (nth (1- month-number) '("Jan" "Feb" "Mar" "Apr" "May" "Jun"
                           "Jul" "Aug" "Sep" "Oct" "Nov" "Dec")))

(defun format-date (universal-time)
  "Convert universal-time (integer) to RFC-2822 date string."
  (multiple-value-bind (second minute hour date month year day dst)
      (decode-universal-time universal-time 0)
    (declare (ignore dst))
    (fstr "~a, ~2,'0d ~a ~4,'0d ~2,'0d:~2,'0d:~2,'0d +0000"
          (weekday-name day) date (month-name month) year
          hour minute second)))

(defun parse-domain (url)
  "Extract domain name from the given URL."
  (let* ((start (+ (search "://" url) 3))
         (end (position #\/ url :start start)))
    (subseq url start end)))

(defun parse-short-domain (url)
  "Extract a neat domain name from the given URL."
  (let* ((host (parse-domain url)))
    (setf host (string-trim-prefix "www." host))
    (setf host (string-trim-prefix "blog." host))))
