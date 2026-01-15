;;;; HN Personal Websites Directory Generator
;;;; ========================================

(require "uiop")

(defun write-file (filename text)
  "Write text to file and close the file."
  (with-open-file (f filename :direction :output :if-exists :supersede)
    (write-sequence text f)))

(defun read-list (filename)
  "Read Lisp file."
  (with-open-file (f filename) (read f)))

(defun read-entries ()
  "Read website entries from the data file."
  (remove-if
   (lambda (item)
     (or (equal item '(:end))
         (string= (getf item :site) "")))
   (read-list "pwd.lisp")))

(defun err (message &rest args)
  "Print an error message and exit."
  (format *error-output* "ERROR: ")
  (apply #'format *error-output* message args)
  (terpri *error-output*)
  (uiop:quit 1))

(defun has-duplicates-p (items)
  "Check if there are duplicates in the given items."
  (< (length (remove-duplicates items :test #'equal))
     (length items)))

(defun validate-name-order (items)
  "Check that entries are arranged in the order of names."
  (let ((prev-name)
        (curr-name))
    (dolist (item items)
      (setf curr-name (getf item :name))
      (when (and prev-name (string< curr-name prev-name))
        (err "~a: Entries must be sorted alphabetically by name" curr-name))
      (setf prev-name curr-name))))

(defun validate-bio-length (items)
  "Check that bio entries do not exceed 80 characters."
  (dolist (item items)
    (let ((bio (getf item :bio))
          (max-len 80))
      (when (and bio (> (length bio) max-len))
        (err "~a: Bio of length ~a exceeds maximum allowed length ~a"
             (getf item :name) (length bio) max-len)))))

(defun validate-bio-ampersand (items)
  "Check that bio entries end with a full stop and contain no ampersands."
  (dolist (item items)
    (let ((bio (getf item :bio)))
      (when (and bio (position #\& bio))
        (err "~a: Bio must not contain ampersand (&)" (getf item :name))))))

(defun validate-bio-stop (items)
  "Check that bio entries end with a full stop."
  (dolist (item items)
    (let ((bio (getf item :bio)))
      (when (and bio (char/= (char bio (1- (length bio))) #\.))
        (err "~a: Bio must end with a full stop" (getf item :name))))))

(defun validate-unique-urls (items)
  "Check that there are no duplicates in the URLs within the same entry."
  (dolist (item items)
    (when (has-duplicates-p (remove nil (list (getf item :site)
                                              (getf item :blog)
                                              (getf item :feed)
                                              (getf item :about)
                                              (getf item :now))))
      (err "~a: Entry must not have duplicate URLs" (getf item :name)))))

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
    (format nil "~a, ~2,'0d ~a ~4,'0d ~2,'0d:~2,'0d:~2,'0d UTC"
            (weekday-name day) date (month-name month) year
            hour minute second)))

(defun make-opml-outline (item)
  "Create an outline element for the specified website entry."
  (with-output-to-string (s)
    (when (and (getf item :name) (getf item :feed) (getf item :site))
      (format s
              "      <outline type=\"rss\" text=\"~a\" title=\"~a\" xmlUrl=\"~a\" htmlUrl=\"~a\"/>~%"
              (getf item :name)
              (getf item :name)
              (getf item :feed)
              (getf item :site)))))

(defun make-opml (items)
  "Create OPML file for all feeds."
  (with-output-to-string (s)
    (format s "<?xml version=\"1.0\" encoding=\"UTF-8\"?>~%")
    (format s "<opml version=\"2.0\">~%")
    (format s "  <head>~%")
    (format s "    <title>HN Personal Websites</title>~%")
    (format s "    <dateCreated>~a</dateCreated>~%"
            (format-date (encode-universal-time 0 0 0 14 1 2025 0)))
    (format s "    <dateModified>~a</dateModified>~%"
            (format-date (get-universal-time)))
    (format s "  </head>~%")
    (format s "  <body>~%")
    (format s "    <!-- ~a entries -->~%" (length items))
    (format s "    <outline text=\"HN Personal Websites\" title=\"HN Personal Websites\">~%")
    (loop for item in items
          do (format s "~a" (make-opml-outline item)))
    (format s "    </outline>~%")
    (format s "  </body>~%")
    (format s "</opml>~%")))

(defun parse-host (url)
  "Extract the domain name from the given URL."
  (let* ((host-start (+ (search "://" url) 3))
         (host-end (position #\/ url :start host-start))
         (host (subseq url host-start host-end)))
    (when (and (>= (length host) 4) (string= host "www." :end1 4))
      (setf host (subseq host 4)))
    host))

(defun make-site-link (url)
  (format nil "<a href=\"~a\">~a</a>" url (parse-host url)))

(defun make-nav-link (href text)
  "Create an HTML link."
  (with-output-to-string (s)
    (when href
      (format s "          <a href=\"~a\">~a</a> |~%" href text))))

(defun make-user-link (user text)
  "Create an HTML link."
  (with-output-to-string (s)
    (when user
      (format s "          <a href=\"https://news.ycombinator.com/user?id=~a\">~a</a>~%" user text))))

(defun make-site-bio (bio)
  "Create HTML snippet to display bio."
  (with-output-to-string (s)
    (when bio
      (format s "        <p>~a</p>~%" bio))))

(defun make-html-card (item)
  "Create an HTML section for the specified website entry."
  (with-output-to-string (s)
    (format s "      <section>~%")
    (format s "        <h2>~a</h2>~%" (getf item :name))
    (format s "        <h3>~a</h3>~%" (make-site-link (getf item :site)))
    (format s "        <nav>~%")
    (format s (make-nav-link (getf item :site) "Website"))
    (format s (make-nav-link (getf item :blog) "Blog"))
    (format s (make-nav-link (getf item :about) "About"))
    (format s (make-nav-link (getf item :now) "Now"))
    (format s (make-nav-link (getf item :feed) "Feed"))
    (format s (make-user-link (getf item :hnuid) "HN"))
    (format s "        </nav>~%")
    (format s (make-site-bio (getf item :bio)))
    (format s "      </section>~%")))

(defun make-html (items)
  "Create HTML page with all website entries."
  (with-output-to-string (s)
    (format s "<!DOCTYPE html>~%")
    (format s "<html lang=\"en\">~%")
    (format s "  <head>~%")
    (format s "    <title>HN Personal Websites Directory</title>~%")
    (format s "    <meta charset=\"UTF-8\">~%")
    (format s "    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">~%")
    (format s "    <link rel=\"stylesheet\" href=\"style.css\">~%")
    (format s "    <link rel=\"icon\" type=\"image/png\" href=\"favicon.png\">~%")
    (format s "    <script src=\"script.js\"></script>~%")
    (format s "  </head>~%")
    (format s "  <body>~%")
    (format s "    <h1>HN Personal Websites</h1>~%")
    (format s "    <div>(~a websites)</div>~%" (length items))
    (format s "    <main>~%")
    (loop for item in items
          do (format s "~a" (make-html-card item)))
    (format s "    </main>~%")
    (format s "    <footer>~%")
    (format s "      <hr>~%")
    (format s "      <nav>~%")
    (format s "        <a href=\"https://github.com/hnpwd/hnpwd.github.io#readme\">README</a>~%")
    (format s "        <a href=\"pwd.opml\">OPML</a>~%")
    (format s "        <a href=\"https://web.libera.chat/#hnpwd\">IRC</a>~%")
    (format s "      </nav>~%")
    (format s "      <p>~%")
    (format s "        This website is not affiliated with Y Combinator.~%")
    (format s "        This is a community-maintained directory of~%")
    (format s "        personal websites by active members of the HN community.~%")
    (format s "      </p>~%")
    (format s "      <p>~%")
    (format s "        Last updated on ~a.~%" (format-date (get-universal-time)))
    (format s "      </p>~%")
    (format s "    </footer>~%")
    (format s "  </body>~%")
    (format s "</html>~%")))

(defun main ()
  "Create artefacts."
  (let ((entries (read-entries)))
    (validate-name-order entries)
    (validate-unique-urls entries)
    (validate-bio-length entries)
    (validate-bio-ampersand entries)
    (validate-bio-stop entries)
    (write-file "pwd.opml" (make-opml entries))
    (write-file "index.html" (make-html entries))))

(main)
