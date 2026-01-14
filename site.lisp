(defun write-file (filename text)
  "Write text to file and close the file."
  (with-open-file (f filename :direction :output :if-exists :supersede)
    (write-sequence text f)))

(defun read-list (filename)
  "Read Lisp file."
  (with-open-file (f filename) (read f)))

(defun read-blogs ()
  "Read blog entries from blogs.lisp."
  (remove-if
   (lambda (item)
     (string= (getf item :blog) "https://example.com/"))
   (read-list "blogs.lisp")))

(defun make-opml-outline (item)
  (with-output-to-string (s)
    (when (and (getf item :name) (getf item :feed) (getf item :blog))
      (format s
              "    <outline type=\"rss\" text=\"~a\" title=\"~a\" xmlUrl=\"~a\" htmlUrl=\"~a\"/>~%"
              (getf item :name)
              (getf item :name)
              (getf item :feed)
              (getf item :blog)))))

(defun make-opml (items)
  "Create OPML file for all feeds."
  (with-output-to-string (s)
    (format s "<?xml version=\"1.0\" encoding=\"UTF-8\"?>~%")
    (format s "<opml version=\"2.0\">~%")
    (format s "  <head>~%")
    (format s "    <title>HN Personal Blogs</title>~%")
    (format s "  </head>~%")
    (format s "  <body>~%")
    (format s "    <outline text=\"HN Blogs\" title=\"HN Blogs\">~%")
    (loop for item in items
          do (format s "~a" (make-opml-outline item)))
    (format s "    </outline>~%")
    (format s "  </body>~%")
    (format s "</opml>~%")))

(defun make-html-link (href text)
  "Create an HTML link."
  (with-output-to-string (s)
    (when href
      (format s "        <a href=\"~a\">~a</a>~%" href text))))

(defun make-html-card (item)
  "Create an HTML section for the specified blog entry."
  (with-output-to-string (s)
    (format s "      <section>~%")
    (format s "        <h2>~a</h2>~%" (getf item :name))
    (format s "        <nav>~%")
    (format s (make-html-link (getf item :blog) "Website"))
    (format s (make-html-link (getf item :about) "About"))
    (format s (make-html-link (getf item :now) "Now"))
    (format s (make-html-link (getf item :feed) "Feed"))
    (format s (make-html-link (getf item :hnuid) "HN"))
    (format s "        </nav>~%")
    (format s "        <p>~a</p>~%" (or (getf item :bio) ""))
    (format s "      </section>~%")))

(defun make-html (items)
  "Create HTML page with all blog entries."
  (with-output-to-string (s)
    (format s "<!DOCTYPE html>~%")
    (format s "<html lang=\"en\">~%")
    (format s "  <head>~%")
    (format s "    <title>HN Personal Blogs</title>~%")
    (format s "    <meta charset=\"UTF-8\">~%")
    (format s "    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">~%")
    (format s "    <link rel=\"stylesheet\" href=\"style.css\">~%")
    (format s "    <link rel=\"icon\" type=\"image/png\" href=\"favicon.png\">~%")
    (format s "    <script src=\"script.js\"></script>~%")
    (format s "  </head>~%")
    (format s "  <body>~%")
    (format s "    <h1>HN Personal Blogs</h1>~%")
    (format s "    <main>~%")
    (loop for item in items
          do (format s "~a" (make-html-card item)))
    (format s "    </main>~%")
    (format s "    <footer>~%")
    (format s "      <nav>~%")
    (format s "        <a href=\"https://github.com/hnblogs/hnblogs.github.io#README\">README</a>~%")
    (format s "        <a href=\"blogs.opml\">OPML</a>~%")
    (format s "        <a href=\"https://web.libera.chat/#hnblogs\">IRC</a>~%")
    (format s "      </nav>~%")
    (format s "    </footer>~%")
    (format s "  </body>~%")
    (format s "</html>~%")))

(defun main ()
  "Create artefacts."
  (let ((blogs (read-blogs)))
    (write-file "blogs.opml" (make-opml blogs))
    (write-file "index.html" (make-html blogs))))

(main)
